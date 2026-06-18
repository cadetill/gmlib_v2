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
  {$IFDEF FPC}Classes, Forms, SysUtils, StrUtils, URIParser, httpdefs{$ELSE}System.Classes, System.NetEncoding, System.StrUtils, System.SysUtils{$ENDIF},
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
  TGMLibLclCefBridge = class(TInterfacedObject, IMapBridgeTransport,
    IMapBridgeJavaScriptNamespace, IMapBridgeDocumentBaseUrl, IMapBridgeNavigation)
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
    FPendingUrl: string;
    FPendingMessages: TStringList;
    FPendingMessagesLock: TRTLCriticalSection;
    FJavaScriptNamespace: string;
    FDocumentBaseUrl: string;
    procedure DoAfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure DoBeforeResourceLoad(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const request: ICefRequest; const callback: ICefCallback;
      out Result: TCefReturnValue);
    procedure DoLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
      httpStatusCode: Integer);
    function GetChromium: TChromium;
    procedure DeliverPendingMessages;
    procedure DeliverPendingMessageAsync(Data: PtrInt);
    procedure QueuePendingMessage;
    function TryExtractMessageJson(const AUrl: string; out AJson: string): Boolean;
    procedure SetJavaScriptNamespace(const ANamespace: string);
    function GetJavaScriptNamespace: string;
    procedure SetDocumentBaseUrl(const AValue: string);
    function GetDocumentBaseUrl: string;
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
    procedure Navigate(const AUrl: string);
    procedure PostCommand(const AEnvelope: TMapLibMessageEnvelope);
    procedure SetOnMessageReceived(const AHandler: TMapBridgeMessageReceivedEvent);
  end;

implementation

procedure AppendLclBridgeTrace(const AMessage: string);
{$IFDEF FPC}
var
  logLines: TStringList;
  logFileName: string;
begin
  try
    logFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'gmlib_lcl_hybrid_trace.log';
    logLines := TStringList.Create;
    try
      if FileExists(logFileName) then
        logLines.LoadFromFile(logFileName);
      logLines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' [LclBridge] ' + AMessage);
      logLines.SaveToFile(logFileName);
    finally
      logLines.Free;
    end;
  except
    // Logging must never break the runtime.
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

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
  FPendingUrl := '';
  FPendingMessages := TStringList.Create;
  InitCriticalSection(FPendingMessagesLock);
  FIsReady := False;
  FJavaScriptNamespace := 'gmlib';
  FDocumentBaseUrl := 'http://127.0.0.1/';
  AttachBrowser(ABrowser);
end;

destructor TGMLibLclCefBridge.Destroy;
begin
  DetachBrowser;
  FPendingMessages.Free;
  DoneCriticalSection(FPendingMessagesLock);
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
  FPendingUrl := '';
  if Assigned(FPendingMessages) then
  begin
    EnterCriticalSection(FPendingMessagesLock);
    try
      FPendingMessages.Clear;
    finally
      LeaveCriticalSection(FPendingMessagesLock);
    end;
  end;
  FIsReady := False;
end;

procedure TGMLibLclCefBridge.DoAfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  if Assigned(FOldAfterCreated) then
    FOldAfterCreated(Sender, browser);

  if FPendingUrl <> '' then
    Navigate(FPendingUrl)
  else if FPendingHtml <> '' then
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
    AppendLclBridgeTrace('DoBeforeResourceLoad url=' + string(request.Url));
    AppendLclBridgeTrace('DoBeforeResourceLoad json=' + MessageJson);
    Result := RV_CANCEL;
    EnterCriticalSection(FPendingMessagesLock);
    try
      FPendingMessages.Add(MessageJson);
    finally
      LeaveCriticalSection(FPendingMessagesLock);
    end;
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
  FPendingUrl := '';

  Chromium := GetChromium;
  if Assigned(Chromium) and Chromium.Initialized then
    LoadPendingHtml
  else
    FBrowser.CreateBrowser;
end;

procedure TGMLibLclCefBridge.Navigate(const AUrl: string);
var
  Chromium: TChromium;
begin
  if (Trim(AUrl) = '') or not Assigned(FBrowser) then
    Exit;

  FIsReady := False;
  FPendingHtml := '';
  FPendingUrl := AUrl;
  Chromium := GetChromium;
  if Assigned(Chromium) and Chromium.Initialized then
  begin
    AppendLclBridgeTrace('Navigate url=' + AUrl);
    FPendingUrl := '';
    Chromium.LoadURL(ustring(AUrl));
  end
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

  AppendLclBridgeTrace('LoadPendingHtml baseUrl=' + FDocumentBaseUrl);
  Chromium.LoadString(ustring(FPendingHtml), ustring(FDocumentBaseUrl), ustring(''));
end;

procedure TGMLibLclCefBridge.NotifyMessageReceived(const AMessage: string);
var
  Envelope: TMapLibMessageEnvelope;
begin
  if not Assigned(FOnMessageReceived) then
    Exit;

  AppendLclBridgeTrace('NotifyMessageReceived raw=' + AMessage);
  try
    Envelope := MapLibMessageEnvelopeFromJson(AMessage);
  except
    on E: Exception do
    begin
      AppendLclBridgeTrace('NotifyMessageReceived parse exception: ' + E.Message);
    Exit;
    end;
  end;
  AppendLclBridgeTrace('NotifyMessageReceived parsed type=' + Envelope.MessageType +
    ' target=' + Envelope.TargetId + ' payload=' + Envelope.Payload);
  FOnMessageReceived(Self, Envelope);
end;

procedure TGMLibLclCefBridge.DeliverPendingMessages;
var
  I: Integer;
  pendingCopy: TStringList;
begin
  pendingCopy := TStringList.Create;
  try
    EnterCriticalSection(FPendingMessagesLock);
    try
      pendingCopy.Assign(FPendingMessages);
      FPendingMessages.Clear;
    finally
      LeaveCriticalSection(FPendingMessagesLock);
    end;
    for I := 0 to pendingCopy.Count - 1 do
      if pendingCopy[I] <> '' then
        NotifyMessageReceived(pendingCopy[I]);
  finally
    pendingCopy.Free;
  end;
end;

procedure TGMLibLclCefBridge.DeliverPendingMessageAsync(Data: PtrInt);
begin
  if Data <> 0 then
  begin
    { suppress unused-parameter hint for Lazarus }
  end;
  DeliverPendingMessages;
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

function TGMLibLclCefBridge.GetDocumentBaseUrl: string;
begin
  Result := FDocumentBaseUrl;
end;

procedure TGMLibLclCefBridge.SetJavaScriptNamespace(const ANamespace: string);
begin
  if Trim(ANamespace) = '' then
    FJavaScriptNamespace := 'gmlib'
  else
    FJavaScriptNamespace := Trim(ANamespace);
end;

procedure TGMLibLclCefBridge.SetDocumentBaseUrl(const AValue: string);
begin
  if Trim(AValue) = '' then
    FDocumentBaseUrl := 'http://127.0.0.1/'
  else
    FDocumentBaseUrl := Trim(AValue);
end;

procedure TGMLibLclCefBridge.SetOnMessageReceived(const AHandler: TMapBridgeMessageReceivedEvent);
begin
  FOnMessageReceived := AHandler;
end;

function TGMLibLclCefBridge.TryExtractMessageJson(const AUrl: string; out AJson: string): Boolean;
var
  UrlRemainder: string;
  dataStart: Integer;
  seqStart: Integer;
  encodedData: string;
begin
  Result := StartsText(cMessagePrefix, AUrl);
  if not Result then
    Exit;

  AJson := '';
  UrlRemainder := Copy(AUrl, Length(cMessagePrefix) + 1, MaxInt);
  dataStart := Pos('data=', UrlRemainder);
  if dataStart <= 0 then
    Exit(False);

  encodedData := Copy(UrlRemainder, dataStart + Length('data='), MaxInt);
  seqStart := Pos('&seq=', encodedData);
  if seqStart > 0 then
    encodedData := Copy(encodedData, 1, seqStart - 1);

  {$IFDEF FPC}
  AJson := HTTPDecode(encodedData);
  {$ELSE}
  AJson := TNetEncoding.URL.Decode(encodedData);
  {$ENDIF}
  Result := AJson <> '';
end;

initialization
  RegisterBridgeFactory(@CreateLclCefBridgeForBrowser);

end.




