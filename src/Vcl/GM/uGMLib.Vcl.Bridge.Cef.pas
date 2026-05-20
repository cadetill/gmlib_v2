{**
  @abstract(Transporte VCL basado en CEF4Delphi.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad implementa un bridge para `TChromiumWindow` usando el mismo
  contrato que el resto de transportes del mapa.
}
unit uGMLib.Vcl.Bridge.Cef;

{$I ..\..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.NetEncoding,
  System.StrUtils,
  System.SysUtils,
  uCEFChromium,
  uCEFChromiumWindow,
  uCEFChromiumEvents,
  uCEFInterfaces,
  uCEFRequest,
  uCEFTypes,
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uMapLib.Core.Messages,
  uMapLib.Core.Types;

type
  {** @abstract(ImplementaciÃ³n del transporte CEF para VCL.) }
  TGMLibCefBridge = class(TInterfacedObject, IMapBridgeTransport, IMapBridgeJavaScriptNamespace)
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

function CreateCefBridgeForBrowser(const ABrowser: TComponent;
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

  Result := TGMLibCefBridge.Create(TChromiumWindow(ABrowser));
end;

{ TGMLibCefBridge }

procedure TGMLibCefBridge.AttachBrowser(ABrowser: TChromiumWindow);
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

    Chromium.OnAfterCreated := DoAfterCreated;
    Chromium.OnBeforeResourceLoad := DoBeforeResourceLoad;
    Chromium.OnLoadEnd := DoLoadEnd;
  end;
end;

procedure TGMLibCefBridge.AttachBrowser(const ABrowser: TComponent);
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

constructor TGMLibCefBridge.Create(ABrowser: TChromiumWindow);
begin
  inherited Create;
  FPendingHtml := '';
  FIsReady := False;
  FJavaScriptNamespace := 'gmlib';
  AttachBrowser(ABrowser);
end;

destructor TGMLibCefBridge.Destroy;
begin
  DetachBrowser;
  inherited;
end;

procedure TGMLibCefBridge.DetachBrowser;
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

procedure TGMLibCefBridge.DoAfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  if Assigned(FOldAfterCreated) then
    FOldAfterCreated(Sender, browser);

  if FPendingHtml <> '' then
    LoadPendingHtml;
end;

procedure TGMLibCefBridge.DoBeforeResourceLoad(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; const callback: ICefCallback;
  out Result: TCefReturnValue);
var
  MessageJson: string;
begin
  Result := RV_CONTINUE;

  if Assigned(request) and TryExtractMessageJson(request.Url, MessageJson) then
  begin
    Result := RV_CANCEL;
    FPendingMessageJson := MessageJson;
    QueuePendingMessage;
    Exit;
  end;

  if Assigned(FOldBeforeResourceLoad) then
    FOldBeforeResourceLoad(Sender, browser, frame, request, callback, Result);
end;

procedure TGMLibCefBridge.DoLoadEnd(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if frame.IsMain then
    FIsReady := True;

  if Assigned(FOldLoadEnd) then
    FOldLoadEnd(Sender, browser, frame, httpStatusCode);
end;

procedure TGMLibCefBridge.ExecuteJavaScript(const AScript: string);
var
  Chromium: TChromium;
begin
  if (AScript = '') then
    Exit;

  Chromium := GetChromium;
  if not Assigned(Chromium) then
    Exit;

  Chromium.ExecuteJavaScript(AScript, 'about:blank', '', '', 0);
end;

function TGMLibCefBridge.GetBackend: TGMBridgeBackend;
begin
  Result := bbCEF;
end;

function TGMLibCefBridge.GetChromium: TChromium;
begin
  Result := nil;

  if Assigned(FBrowser) then
    Result := FBrowser.ChromiumBrowser;
end;

function TGMLibCefBridge.GetIsReady: Boolean;
begin
  Result := FIsReady;
end;

procedure TGMLibCefBridge.LoadHtml(const AHtml: string);
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

procedure TGMLibCefBridge.LoadPendingHtml;
var
  Chromium: TChromium;
begin
  Chromium := GetChromium;

  if (FPendingHtml = '') or not Assigned(Chromium) then
    Exit;

  Chromium.LoadString(FPendingHtml, '', '');
end;

procedure TGMLibCefBridge.NotifyMessageReceived(const AMessage: string);
var
  Envelope: TMapLibMessageEnvelope;
begin
  if not Assigned(FOnMessageReceived) then
    Exit;

  try
    Envelope := TMapLibMessageEnvelope.FromJson(AMessage);
  except
    Exit;
  end;
  FOnMessageReceived(Self, Envelope);
end;

procedure TGMLibCefBridge.DeliverPendingMessage;
var
  MessageJson: string;
begin
  MessageJson := FPendingMessageJson;
  FPendingMessageJson := '';
  if MessageJson <> '' then
    NotifyMessageReceived(MessageJson);
end;

procedure TGMLibCefBridge.QueuePendingMessage;
begin
  TThread.Synchronize(nil, DeliverPendingMessage);
end;

procedure TGMLibCefBridge.PostCommand(const AEnvelope: TMapLibMessageEnvelope);
begin
  ExecuteJavaScript(Format('window.%s.receiveCommand(%s);', [FJavaScriptNamespace, AEnvelope.ToJson]));
end;

function TGMLibCefBridge.GetJavaScriptNamespace: string;
begin
  Result := FJavaScriptNamespace;
end;

procedure TGMLibCefBridge.SetJavaScriptNamespace(const ANamespace: string);
begin
  if Trim(ANamespace) = '' then
    FJavaScriptNamespace := 'gmlib'
  else
    FJavaScriptNamespace := Trim(ANamespace);
end;

procedure TGMLibCefBridge.SetOnMessageReceived(const AHandler: TMapBridgeMessageReceivedEvent);
begin
  FOnMessageReceived := AHandler;
end;

function TGMLibCefBridge.TryExtractMessageJson(const AUrl: string;
  out AJson: string): Boolean;
var
  Params: TStringList;
  UrlRemainder: string;
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
    Params.DelimitedText := UrlRemainder;
    AJson := TNetEncoding.URL.Decode(Params.Values['data']);
    Result := AJson <> '';
  finally
    Params.Free;
  end;
end;

initialization
  RegisterBridgeFactory(CreateCefBridgeForBrowser);

end.
