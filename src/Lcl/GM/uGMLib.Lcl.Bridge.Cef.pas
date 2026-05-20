{**
  @abstract(Transporte LCL basado en CEF4Delphi.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad implementa un bridge para `TChromiumWindow` usando el mismo
  contrato que el resto de transportes del mapa.
}
unit uGMLib.Lcl.Bridge.Cef;

{$I ..\..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes, Forms, SysUtils, StrUtils, URIParser{$ELSE}System.Classes, System.NetEncoding, System.StrUtils, System.SysUtils{$ENDIF},
  uCEFChromium,
  uCEFChromiumWindow,
  uCEFChromiumEvents,
  uCEFInterfaces,
  uCEFTypes,
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uMapLib.Core.Messages,
  uMapLib.Core.Types;

type
  {** @abstract(ImplementaciÃ³n del transporte CEF para LCL.) }
  TGMLibLclCefBridge = class(TInterfacedObject, IMapBridgeTransport, IMapBridgeJavaScriptNamespace)
  private const
    cMessagePrefix = 'https://gmlib.local/__gmlib_message__?';
  private
    FBrowser: TChromiumWindow;
    FIsReady: Boolean;
    FOnMessageReceived: TMapBridgeMessageReceivedEvent;
    FOldAfterCreated: TOnAfterCreated;
    FOldBeforeResourceLoad: TOnBeforeResourceLoad;
    FOldLoadEnd: TOnLoadEnd;
    FPendingHtml: string;
    FPendingMessageJson: string;
    FJavaScriptNamespace: string;
    procedure DoAfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure DoBeforeResourceLoad(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const request: ICefRequest; const callback: ICefCallback;
      out Result: TCefReturnValue);
    procedure DoLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
      httpStatusCode: Integer);
    function GetChromium: TChromium;
    procedure DeliverPendingMessage;
    procedure DeliverPendingMessageAsync(Data: PtrInt);
    procedure QueuePendingMessage;
    function TryExtractMessageJson(const AUrl: string; out AJson: string): Boolean;
    procedure SetJavaScriptNamespace(const ANamespace: string);
    function GetJavaScriptNamespace: string;
    procedure LoadPendingHtml;
    procedure NotifyMessageReceived(const AMessage: string);
  protected
    function GetBackend: TGMBridgeBackend;
    function GetIsReady: Boolean;
  public
    constructor Create(ABrowser: TChromiumWindow); reintroduce;
    destructor Destroy; override;

    procedure AttachBrowser(const ABrowser: TComponent); overload;
    procedure AttachBrowser(ABrowser: TChromiumWindow); overload;
    procedure DetachBrowser;
    procedure ExecuteJavaScript(const AScript: string);
    procedure LoadHtml(const AHtml: string);
    procedure PostCommand(const AEnvelope: TMapLibMessageEnvelope);
    procedure SetOnMessageReceived(const AHandler: TMapBridgeMessageReceivedEvent);
  end;

implementation

function CreateLclCefBridgeForBrowser(const ABrowser: TComponent;
  const ACurrentBridge: IMapBridgeTransport): IMapBridgeTransport;
begin
  Result := nil;
  if not (ABrowser is TChromiumWindow) then
    Exit;

  if Assigned(ACurrentBridge) and (ACurrentBridge.Backend = bbCEF) then
  begin
    ACurrentBridge.AttachBrowser(ABrowser);
    Result := ACurrentBridge;
    Exit;
  end;

  Result := TGMLibLclCefBridge.Create(TChromiumWindow(ABrowser));
end;

{ TGMLibLclCefBridge }

constructor TGMLibLclCefBridge.Create(ABrowser: TChromiumWindow);
begin
  inherited Create;
  FPendingHtml := '';
  FIsReady := False;
  FJavaScriptNamespace := 'gmlib';
  AttachBrowser(ABrowser);
end;

destructor TGMLibLclCefBridge.Destroy;
begin
  DetachBrowser;
  inherited;
end;

procedure TGMLibLclCefBridge.AttachBrowser(ABrowser: TChromiumWindow);
var
  Chromium: TChromium;
begin
  if FBrowser = ABrowser then
    Exit;

  DetachBrowser;
  FBrowser := ABrowser;

  Chromium := GetChromium;
  if Assigned(Chromium) then
  begin
    FOldAfterCreated := Chromium.OnAfterCreated;
    FOldBeforeResourceLoad := Chromium.OnBeforeResourceLoad;
    FOldLoadEnd := Chromium.OnLoadEnd;

    Chromium.OnAfterCreated := @DoAfterCreated;
    Chromium.OnBeforeResourceLoad := @DoBeforeResourceLoad;
    Chromium.OnLoadEnd := @DoLoadEnd;
  end;
end;

procedure TGMLibLclCefBridge.AttachBrowser(const ABrowser: TComponent);
begin
  if not Assigned(ABrowser) then
  begin
    DetachBrowser;
    Exit;
  end;

  if ABrowser is TChromiumWindow then
    AttachBrowser(TChromiumWindow(ABrowser))
  else
    raise Exception.Create('Unsupported browser component for CEF bridge.');
end;

procedure TGMLibLclCefBridge.DetachBrowser;
var
  Chromium: TChromium;
begin
  Chromium := GetChromium;
  if Assigned(Chromium) then
  begin
    Chromium.OnAfterCreated := FOldAfterCreated;
    Chromium.OnBeforeResourceLoad := FOldBeforeResourceLoad;
    Chromium.OnLoadEnd := FOldLoadEnd;
  end;

  FBrowser := nil;
  FOldAfterCreated := nil;
  FOldBeforeResourceLoad := nil;
  FOldLoadEnd := nil;
  FPendingHtml := '';
  FPendingMessageJson := '';
  FIsReady := False;
end;

procedure TGMLibLclCefBridge.DoAfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  if Assigned(FOldAfterCreated) then
    FOldAfterCreated(Sender, browser);

  if FPendingHtml <> '' then
    LoadPendingHtml;
end;

procedure TGMLibLclCefBridge.DoBeforeResourceLoad(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; const callback: ICefCallback;
  out Result: TCefReturnValue);
var
  MessageJson: string;
begin
  Result := RV_CONTINUE;

  if Assigned(request) and TryExtractMessageJson(string(request.Url), MessageJson) then
  begin
    Result := RV_CANCEL;
    FPendingMessageJson := MessageJson;
    QueuePendingMessage;
    Exit;
  end;

  if Assigned(FOldBeforeResourceLoad) then
    FOldBeforeResourceLoad(Sender, browser, frame, request, callback, Result);
end;

procedure TGMLibLclCefBridge.DoLoadEnd(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if frame.IsMain then
    FIsReady := True;

  if Assigned(FOldLoadEnd) then
    FOldLoadEnd(Sender, browser, frame, httpStatusCode);
end;

procedure TGMLibLclCefBridge.ExecuteJavaScript(const AScript: string);
var
  Chromium: TChromium;
begin
  if (AScript = '') then
    Exit;

  Chromium := GetChromium;
  if not Assigned(Chromium) then
    Exit;

  Chromium.ExecuteJavaScript(ustring(AScript), ustring('about:blank'), ustring(''), ustring(''), 0);
end;

function TGMLibLclCefBridge.GetBackend: TGMBridgeBackend;
begin
  Result := bbCEF;
end;

function TGMLibLclCefBridge.GetChromium: TChromium;
begin
  Result := nil;

  if Assigned(FBrowser) then
    Result := FBrowser.ChromiumBrowser;
end;

function TGMLibLclCefBridge.GetIsReady: Boolean;
begin
  Result := FIsReady;
end;

procedure TGMLibLclCefBridge.LoadHtml(const AHtml: string);
var
  Chromium: TChromium;
begin
  if not Assigned(FBrowser) then
    Exit;

  FIsReady := False;
  FPendingHtml := AHtml;

  Chromium := GetChromium;
  if Assigned(Chromium) and Chromium.Initialized then
    LoadPendingHtml
  else
    FBrowser.CreateBrowser;
end;

procedure TGMLibLclCefBridge.LoadPendingHtml;
var
  Chromium: TChromium;
begin
  Chromium := GetChromium;

  if (FPendingHtml = '') or not Assigned(Chromium) then
    Exit;

  Chromium.LoadString(ustring(FPendingHtml), ustring(''), ustring(''));
end;

procedure TGMLibLclCefBridge.NotifyMessageReceived(const AMessage: string);
var
  Envelope: TMapLibMessageEnvelope;
begin
  if not Assigned(FOnMessageReceived) then
    Exit;

  try
    Envelope := MapLibMessageEnvelopeFromJson(AMessage);
  except
    Exit;
  end;
  FOnMessageReceived(Self, Envelope);
end;

procedure TGMLibLclCefBridge.DeliverPendingMessage;
var
  MessageJson: string;
begin
  MessageJson := FPendingMessageJson;
  FPendingMessageJson := '';
  if MessageJson <> '' then
    NotifyMessageReceived(MessageJson);
end;

procedure TGMLibLclCefBridge.DeliverPendingMessageAsync(Data: PtrInt);
begin
  if Data <> 0 then
  begin
    { suppress unused-parameter hint for Lazarus }
  end;
  DeliverPendingMessage;
end;

procedure TGMLibLclCefBridge.QueuePendingMessage;
begin
  Application.QueueAsyncCall(@DeliverPendingMessageAsync, 0);
end;

procedure TGMLibLclCefBridge.PostCommand(const AEnvelope: TMapLibMessageEnvelope);
begin
  {$IFDEF FPC}
  ExecuteJavaScript(Format('window.%s.receiveCommand(%s);', [FJavaScriptNamespace, MapLibMessageEnvelopeToJson(AEnvelope)]));
  {$ELSE}
  ExecuteJavaScript(Format('window.%s.receiveCommand(%s);', [FJavaScriptNamespace, AEnvelope.ToJson]));
  {$ENDIF}
end;

function TGMLibLclCefBridge.GetJavaScriptNamespace: string;
begin
  Result := FJavaScriptNamespace;
end;

procedure TGMLibLclCefBridge.SetJavaScriptNamespace(const ANamespace: string);
begin
  if Trim(ANamespace) = '' then
    FJavaScriptNamespace := 'gmlib'
  else
    FJavaScriptNamespace := Trim(ANamespace);
end;

procedure TGMLibLclCefBridge.SetOnMessageReceived(const AHandler: TMapBridgeMessageReceivedEvent);
begin
  FOnMessageReceived := AHandler;
end;

function TGMLibLclCefBridge.TryExtractMessageJson(const AUrl: string; out AJson: string): Boolean;
var
  Params: TStringList;
  UrlRemainder: string;
  ParsedUri: TURI;
begin
  Result := StartsText(cMessagePrefix, AUrl);
  if not Result then
    Exit;

  AJson := '';
  UrlRemainder := Copy(AUrl, Length(cMessagePrefix) + 1, MaxInt);
  Params := TStringList.Create;
  try
    Params.Delimiter := '&';
    Params.StrictDelimiter := True;
    ParsedUri := ParseURI('http://gmlib.local/?' + UrlRemainder, True);
    Params.DelimitedText := ParsedUri.Params;
    {$IFDEF FPC}
    AJson := Params.Values['data'];
    {$ELSE}
    AJson := TNetEncoding.URL.Decode(Params.Values['data']);
    {$ENDIF}
    Result := AJson <> '';
  finally
    Params.Free;
  end;
end;

initialization
  RegisterBridgeFactory(@CreateLclCefBridgeForBrowser);

end.




