{**
  @abstract(Esqueleto inicial del bridge WebView2 para VCL.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define un transporte mínimo para `WebView2`. La integración real
  de mensajes y ciclo de vida se completará en la siguiente iteración.
}
unit uGMLib.Vcl.Bridge.WebView2;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  Vcl.ExtCtrls,
  Vcl.Edge,
  Vcl.OleCtrls,
  Winapi.WebView2,
  uGMLib.Core.Bridge,
  uGMLib.Core.Messages,
  uGMLib.Core.Types;

type
  {** @abstract(Implementación inicial del transporte WebView2.) }
  TGMLibWebView2Bridge = class(TInterfacedObject, IGMBridgeTransport)
  private
    FBrowser: TEdgeBrowser;
    FIsReady: Boolean;
    FOnMessageReceived: TGMBridgeMessageReceivedEvent;
    FOldCreateWebViewCompleted: TWebViewStatusEvent;
    FOldNavigationCompleted: TNavigationCompletedEvent;
    FPendingHtml: string;
    FOldWebMessageReceived: TWebMessageReceivedEvent;
    FCommandQueue: TList<string>;
    FFlushTimer: TTimer;
    FFlushInProgress: Boolean;
    procedure DoCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure DoNavigationCompleted(Sender: TCustomEdgeBrowser; IsSuccess: Boolean;
      WebErrorStatus: TOleEnum);
    procedure DoWebMessageReceived(Sender: TCustomEdgeBrowser;
      Args: TWebMessageReceivedEventArgs);
    procedure DoFlushTimer(Sender: TObject);
    procedure FlushPendingJavaScripts;
  protected
    function GetBackend: TGMBridgeBackend;
    function GetIsReady: Boolean;
  public
    constructor Create(ABrowser: TEdgeBrowser); reintroduce;
    destructor Destroy; override;

    procedure AttachBrowser(const ABrowser: TComponent); overload;
    procedure AttachBrowser(ABrowser: TEdgeBrowser); overload;
    procedure DetachBrowser;
    procedure ExecuteJavaScript(const AScript: string);
    procedure LoadHtml(const AHtml: string);
    procedure NotifyMessageReceived(const AMessage: string);
    procedure PostCommand(const AEnvelope: TGMMessageEnvelope);
    procedure SetOnMessageReceived(const AHandler: TGMBridgeMessageReceivedEvent);
    procedure SetReady(AValue: Boolean);
  end;

implementation

uses
  Winapi.ActiveX;

{ TGMLibWebView2Bridge }

procedure TGMLibWebView2Bridge.AttachBrowser(ABrowser: TEdgeBrowser);
begin
  if FBrowser = ABrowser then
    Exit;

  DetachBrowser;
  FBrowser := ABrowser;

  if Assigned(FBrowser) then
  begin
    FOldCreateWebViewCompleted := FBrowser.OnCreateWebViewCompleted;
    FOldNavigationCompleted := FBrowser.OnNavigationCompleted;
    FOldWebMessageReceived := FBrowser.OnWebMessageReceived;

    FBrowser.OnCreateWebViewCompleted := DoCreateWebViewCompleted;
    FBrowser.OnNavigationCompleted := DoNavigationCompleted;
    FBrowser.OnWebMessageReceived := DoWebMessageReceived;
  end;
end;

procedure TGMLibWebView2Bridge.AttachBrowser(const ABrowser: TComponent);
begin
  if not Assigned(ABrowser) then
  begin
    DetachBrowser;
    Exit;
  end;

  if ABrowser is TEdgeBrowser then
    AttachBrowser(TEdgeBrowser(ABrowser))
  else
    raise Exception.Create('Unsupported browser component for WebView2 bridge.');
end;

constructor TGMLibWebView2Bridge.Create(ABrowser: TEdgeBrowser);
begin
  inherited Create;
  FPendingHtml := '';
  FCommandQueue := TList<string>.Create;
  FFlushTimer := TTimer.Create(nil);
  FFlushTimer.Enabled := False;
  FFlushTimer.Interval := 1;
  FFlushTimer.OnTimer := DoFlushTimer;
  AttachBrowser(ABrowser);
end;

destructor TGMLibWebView2Bridge.Destroy;
begin
  DetachBrowser;
  FFlushTimer.Free;
  FCommandQueue.Free;
  inherited;
end;

procedure TGMLibWebView2Bridge.DetachBrowser;
begin
  if Assigned(FBrowser) then
  begin
    FBrowser.OnCreateWebViewCompleted := FOldCreateWebViewCompleted;
    FBrowser.OnNavigationCompleted := FOldNavigationCompleted;
    FBrowser.OnWebMessageReceived := FOldWebMessageReceived;
  end;

  FBrowser := nil;
  FOldCreateWebViewCompleted := nil;
  FOldNavigationCompleted := nil;
  FOldWebMessageReceived := nil;
  FFlushInProgress := False;
  if Assigned(FFlushTimer) then
    FFlushTimer.Enabled := False;
end;

procedure TGMLibWebView2Bridge.DoCreateWebViewCompleted(Sender: TCustomEdgeBrowser;
  AResult: HRESULT);
begin
  if Succeeded(AResult) and (FPendingHtml <> '') then
    FBrowser.NavigateToString(FPendingHtml);

  if Assigned(FOldCreateWebViewCompleted) then
    FOldCreateWebViewCompleted(Sender, AResult);
end;

procedure TGMLibWebView2Bridge.DoNavigationCompleted(Sender: TCustomEdgeBrowser;
  IsSuccess: Boolean; WebErrorStatus: TOleEnum);
begin
  FIsReady := IsSuccess;
  if Assigned(FFlushTimer) then
    FFlushTimer.Enabled := FCommandQueue.Count > 0;

  if Assigned(FOldNavigationCompleted) then
    FOldNavigationCompleted(Sender, IsSuccess, WebErrorStatus);
end;

procedure TGMLibWebView2Bridge.DoWebMessageReceived(Sender: TCustomEdgeBrowser;
  Args: TWebMessageReceivedEventArgs);
var
  MessageArgs: ICoreWebView2WebMessageReceivedEventArgs;
  MessageAsString: PWideChar;
begin
  MessageArgs := Args as ICoreWebView2WebMessageReceivedEventArgs;
  MessageAsString := nil;
  MessageArgs.TryGetWebMessageAsString(MessageAsString);
  try
    if Assigned(MessageAsString) then
      NotifyMessageReceived(MessageAsString);
  finally
    if Assigned(MessageAsString) then
      CoTaskMemFree(MessageAsString);
  end;

  if Assigned(FOldWebMessageReceived) then
    FOldWebMessageReceived(Sender, Args);
end;

procedure TGMLibWebView2Bridge.ExecuteJavaScript(const AScript: string);
begin
  if (AScript = '') or not Assigned(FBrowser) then
    Exit;

  FCommandQueue.Add(AScript);
  if Assigned(FFlushTimer) then
    FFlushTimer.Enabled := True;
end;

function TGMLibWebView2Bridge.GetBackend: TGMBridgeBackend;
begin
  Result := bbWebView2;
end;

function TGMLibWebView2Bridge.GetIsReady: Boolean;
begin
  Result := FIsReady;
end;

procedure TGMLibWebView2Bridge.LoadHtml(const AHtml: string);
begin
  if not Assigned(FBrowser) then
    Exit;

  FIsReady := False;
  FPendingHtml := AHtml;
  FFlushInProgress := False;

  if FBrowser.NavigateToString(AHtml) then
    Exit;

  FBrowser.CreateWebView;
end;

procedure TGMLibWebView2Bridge.NotifyMessageReceived(const AMessage: string);
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

procedure TGMLibWebView2Bridge.PostCommand(const AEnvelope: TGMMessageEnvelope);
begin
  ExecuteJavaScript(
    Format('window.gmlib.receiveCommand(%s);', [AEnvelope.ToJson])
  );
end;

procedure TGMLibWebView2Bridge.DoFlushTimer(Sender: TObject);
begin
  FlushPendingJavaScripts;
end;

procedure TGMLibWebView2Bridge.FlushPendingJavaScripts;
var
  Script: string;
begin
  if FFlushInProgress or not FIsReady or not Assigned(FBrowser) then
    Exit;

  if FCommandQueue.Count = 0 then
  begin
    if Assigned(FFlushTimer) then
      FFlushTimer.Enabled := False;
    Exit;
  end;

  FFlushInProgress := True;
  try
    while FCommandQueue.Count > 0 do
    begin
      Script := FCommandQueue[0];
      FCommandQueue.Delete(0);
      FBrowser.ExecuteScript(Script);
    end;
  finally
    FFlushInProgress := False;
  end;

  if Assigned(FFlushTimer) then
    FFlushTimer.Enabled := FCommandQueue.Count > 0;
end;

procedure TGMLibWebView2Bridge.SetOnMessageReceived(
  const AHandler: TGMBridgeMessageReceivedEvent);
begin
  FOnMessageReceived := AHandler;
end;

procedure TGMLibWebView2Bridge.SetReady(AValue: Boolean);
begin
  FIsReady := AValue;
end;

end.
