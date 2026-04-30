{**
  @abstract(Transporte FMX mínimo basado en @code(TWebBrowser).)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad implementa un bridge ligero para el slice inicial de `TGMMap`
  en `FMX`, cargando HTML inline y recibiendo mensajes JavaScript mediante una
  URL interna interceptada por el navegador.
}
unit uGMLib.Fmx.Bridge.WebBrowser;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.JSON,
  System.Math,
  System.NetEncoding,
  System.SysUtils,
  System.Generics.Collections,
  FMX.WebBrowser,
  FMX.Types,
  uGMLib.Core.Bridge,
  uGMLib.Core.Messages,
  uGMLib.Core.Types;

type
  {** @abstract(Implementación inicial del transporte FMX con @code(TWebBrowser).) }
  TGMLibFmxWebBrowserBridge = class(TInterfacedObject, IGMBridgeTransport)
  private const
    cMessagePrefix = 'https://gmlib.local/__gmlib_message__?';
  private
    FBrowser: TWebBrowser;
    FIsReady: Boolean;
    FOnMessageReceived: TGMBridgeMessageReceivedEvent;
    FOldDidFinishLoad: TWebBrowserDidFinishLoad;
{$IF CompilerVersion >= 37}
    FOldShouldLoadURL: TWebBrowserShouldLoadURL;
{$IFEND}
    FOldShouldStartLoadWithRequest: TWebBrowserShouldStartLoadWithRequest;
    FPollInFlight: Boolean;
    FPollTimer: TTimer;
    FCommandQueue: TList<string>;
    FFlushInProgress: Boolean;
    function GetPollInterval: Integer;
    procedure SetPollInterval(const Value: Integer);
    procedure DoDidFinishLoad(ASender: TObject);
    procedure DoPollTimer(Sender: TObject);
{$IF CompilerVersion >= 37}
    procedure DoShouldLoadURL(ASender: TObject; const URL: string; var ACancel: Boolean);
    function NormalizeJavaScriptResult(const AResult: string): string;
{$IFEND}
    procedure DoShouldStartLoadWithRequest(ASender: TObject; const URL: string);
    procedure PollMessageQueue;
    procedure FlushPendingJavaScripts;
    function TryExtractMessageJson(const AUrl: string; out AJson: string): Boolean;
  protected
    function GetBackend: TGMBridgeBackend;
    function GetIsReady: Boolean;
  public
    constructor Create(ABrowser: TWebBrowser); reintroduce;
    destructor Destroy; override;

    procedure AttachBrowser(const ABrowser: TComponent); overload;
    procedure AttachBrowser(ABrowser: TWebBrowser); overload;
    procedure DetachBrowser;
    procedure ExecuteJavaScript(const AScript: string);
    procedure LoadHtml(const AHtml: string);
    procedure NotifyMessageReceived(const AMessage: string);
    procedure PostCommand(const AEnvelope: TGMMessageEnvelope);
    procedure SetOnMessageReceived(const AHandler: TGMBridgeMessageReceivedEvent);
    property PollInterval: Integer read GetPollInterval write SetPollInterval;
  end;

implementation

{ TGMLibFmxWebBrowserBridge }

procedure TGMLibFmxWebBrowserBridge.AttachBrowser(ABrowser: TWebBrowser);
begin
  if FBrowser = ABrowser then
    Exit;

  DetachBrowser;
  FBrowser := ABrowser;

  if Assigned(FBrowser) then
  begin
    FOldDidFinishLoad := FBrowser.OnDidFinishLoad;
{$IF CompilerVersion >= 37}
    FOldShouldLoadURL := FBrowser.OnShouldLoadURL;
{$IFEND}
    FOldShouldStartLoadWithRequest := FBrowser.OnShouldStartLoadWithRequest;

    FBrowser.OnDidFinishLoad := DoDidFinishLoad;
{$IF CompilerVersion >= 37}
    FBrowser.OnShouldLoadURL := DoShouldLoadURL;
{$IFEND}
    FBrowser.OnShouldStartLoadWithRequest := DoShouldStartLoadWithRequest;
  end;
end;

procedure TGMLibFmxWebBrowserBridge.AttachBrowser(const ABrowser: TComponent);
begin
  if not Assigned(ABrowser) then
  begin
    DetachBrowser;
    Exit;
  end;

  if ABrowser is TWebBrowser then
    AttachBrowser(TWebBrowser(ABrowser))
  else
    raise Exception.Create('Unsupported browser component for FMX bridge.');
end;

constructor TGMLibFmxWebBrowserBridge.Create(ABrowser: TWebBrowser);
begin
  inherited Create;
  FPollTimer := TTimer.Create(nil);
  FPollTimer.Enabled := False;
  FPollTimer.Interval := 100;
  FPollTimer.OnTimer := DoPollTimer;
  FCommandQueue := TList<string>.Create;
  AttachBrowser(ABrowser);
end;

destructor TGMLibFmxWebBrowserBridge.Destroy;
begin
  DetachBrowser;
  FPollTimer.Free;
  FCommandQueue.Free;
  inherited;
end;

procedure TGMLibFmxWebBrowserBridge.DetachBrowser;
begin
  if Assigned(FBrowser) then
  begin
    FBrowser.OnDidFinishLoad := FOldDidFinishLoad;
{$IF CompilerVersion >= 37}
    FBrowser.OnShouldLoadURL := FOldShouldLoadURL;
{$IFEND}
    FBrowser.OnShouldStartLoadWithRequest := FOldShouldStartLoadWithRequest;
  end;

  FBrowser := nil;
  FOldDidFinishLoad := nil;
{$IF CompilerVersion >= 37}
  FOldShouldLoadURL := nil;
{$IFEND}
  FOldShouldStartLoadWithRequest := nil;
  FPollInFlight := False;
  FFlushInProgress := False;
  if Assigned(FPollTimer) then
    FPollTimer.Enabled := False;
end;

procedure TGMLibFmxWebBrowserBridge.DoDidFinishLoad(ASender: TObject);
begin
  FIsReady := True;
  FPollInFlight := False;
  if Assigned(FPollTimer) then
    FPollTimer.Enabled := True;
  FlushPendingJavaScripts;

  if Assigned(FOldDidFinishLoad) then
    FOldDidFinishLoad(ASender);
end;

procedure TGMLibFmxWebBrowserBridge.DoPollTimer(Sender: TObject);
begin
  PollMessageQueue;
  FlushPendingJavaScripts;
end;

procedure TGMLibFmxWebBrowserBridge.DoShouldStartLoadWithRequest(
  ASender: TObject; const URL: string);
var
  messageJson: string;
begin
  if TryExtractMessageJson(URL, messageJson) then
  begin
    NotifyMessageReceived(messageJson);
    Exit;
  end;

  if Assigned(FOldShouldStartLoadWithRequest) then
    FOldShouldStartLoadWithRequest(ASender, URL);
end;

{$IF CompilerVersion >= 37}
procedure TGMLibFmxWebBrowserBridge.DoShouldLoadURL(ASender: TObject;
  const URL: string; var ACancel: Boolean);
var
  messageJson: string;
begin
  if TryExtractMessageJson(URL, messageJson) then
  begin
    ACancel := True;
    NotifyMessageReceived(messageJson);
    Exit;
  end;

  if Assigned(FOldShouldLoadURL) then
    FOldShouldLoadURL(ASender, URL, ACancel);
end;
{$IFEND}

procedure TGMLibFmxWebBrowserBridge.ExecuteJavaScript(const AScript: string);
begin
  if (AScript = '') or not Assigned(FBrowser) then
    Exit;

  FCommandQueue.Add(AScript);
  if Assigned(FPollTimer) then
    FPollTimer.Enabled := True;
end;

function TGMLibFmxWebBrowserBridge.GetBackend: TGMBridgeBackend;
begin
  Result := bbFMX;
end;

function TGMLibFmxWebBrowserBridge.GetIsReady: Boolean;
begin
  Result := FIsReady;
end;

procedure TGMLibFmxWebBrowserBridge.LoadHtml(const AHtml: string);
begin
  if not Assigned(FBrowser) then
    Exit;

  FIsReady := False;
  FPollInFlight := False;
  FFlushInProgress := False;
  if Assigned(FPollTimer) then
    FPollTimer.Enabled := False;
  FBrowser.LoadFromStrings(AHtml, 'https://gmlib.local/');
end;

procedure TGMLibFmxWebBrowserBridge.NotifyMessageReceived(const AMessage: string);
var
  Envelope: TGMMessageEnvelope;
begin
  if not Assigned(FOnMessageReceived) then
    Exit;

  try
    Envelope := TGMMessageEnvelope.FromJson(AMessage);
  except
    Exit;
  end;
  FOnMessageReceived(Self, Envelope);
end;

procedure TGMLibFmxWebBrowserBridge.PostCommand(const AEnvelope: TGMMessageEnvelope);
begin
  ExecuteJavaScript(
    Format('window.gmlib.receiveCommand(%s);', [AEnvelope.ToJson])
  );
end;

procedure TGMLibFmxWebBrowserBridge.FlushPendingJavaScripts;
var
  Script: string;
begin
  if FFlushInProgress or not FIsReady or not Assigned(FBrowser) then
    Exit;

  if FCommandQueue.Count = 0 then
  begin
    if Assigned(FPollTimer) and not FPollInFlight then
      FPollTimer.Enabled := True;
    Exit;
  end;

  FFlushInProgress := True;
  try
    while FCommandQueue.Count > 0 do
    begin
      Script := FCommandQueue[0];
      FCommandQueue.Delete(0);
      FBrowser.EvaluateJavaScript(Script);
    end;
  finally
    FFlushInProgress := False;
  end;

  if Assigned(FPollTimer) then
    FPollTimer.Enabled := True;
end;

procedure TGMLibFmxWebBrowserBridge.PollMessageQueue;
begin
  if not FIsReady or FPollInFlight or not Assigned(FBrowser) then
    Exit;

{$IF CompilerVersion < 37}
  Exit;
{$ELSE}
  FPollInFlight := True;
  FBrowser.EvaluateJavaScript(
    '(function(){' +
    '  if (!window.gmlib || !window.gmlib.__messageQueue) { return JSON.stringify([]); }' +
    '  var items = window.gmlib.__messageQueue.slice();' +
    '  window.gmlib.__messageQueue = [];' +
    '  return JSON.stringify(items);' +
    '})()',
    procedure(const AResult: string)
    var
      JsonArray: TJSONArray;
      JsonValue: TJSONValue;
      NormalizedResult: string;
      i: Integer;
    begin
      try
        NormalizedResult := NormalizeJavaScriptResult(AResult);
        if NormalizedResult = '' then
          Exit;

        JsonValue := TJSONObject.ParseJSONValue(NormalizedResult);
        try
          if not (JsonValue is TJSONArray) then
            Exit;

          JsonArray := TJSONArray(JsonValue);
          for i := 0 to JsonArray.Count - 1 do
            NotifyMessageReceived(JsonArray.Items[i].ToJSON);
        finally
          JsonValue.Free;
        end;
      finally
        FPollInFlight := False;
      end;
    end
  );
{$IFEND}
end;

procedure TGMLibFmxWebBrowserBridge.SetOnMessageReceived(
  const AHandler: TGMBridgeMessageReceivedEvent);
begin
  FOnMessageReceived := AHandler;
end;

function TGMLibFmxWebBrowserBridge.GetPollInterval: Integer;
begin
  Result := FPollTimer.Interval;
end;

procedure TGMLibFmxWebBrowserBridge.SetPollInterval(const Value: Integer);
begin
  FPollTimer.Interval := EnsureRange(Value, 20, 1000);
end;

{$IF CompilerVersion >= 37}
function TGMLibFmxWebBrowserBridge.NormalizeJavaScriptResult(
  const AResult: string): string;
var
  JsonValue: TJSONValue;
begin
  Result := Trim(AResult);
  if Result = '' then
    Exit;

  JsonValue := TJSONObject.ParseJSONValue(Result);
  try
    if JsonValue is TJSONString then
      Result := TJSONString(JsonValue).Value;
  finally
    JsonValue.Free;
  end;
end;
{$IFEND}

function TGMLibFmxWebBrowserBridge.TryExtractMessageJson(const AUrl: string;
  out AJson: string): Boolean;
var
  params: TStringList;
  urlRemainder: string;
begin
  Result := AUrl.StartsWith(cMessagePrefix, True);
  if not Result then
    Exit;

  AJson := '';
  urlRemainder := AUrl.Substring(Length(cMessagePrefix));
  params := TStringList.Create;
  try
    params.Delimiter := '&';
    params.StrictDelimiter := True;
    params.DelimitedText := urlRemainder;
    AJson := TNetEncoding.URL.Decode(params.Values['data']);
    Result := AJson <> '';
  finally
    params.Free;
  end;
end;

end.
