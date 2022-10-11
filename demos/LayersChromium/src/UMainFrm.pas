unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GMLib.Classes, GMLib.Map, GMLib.Map.Vcl,
  Vcl.ExtCtrls, uCEFChromiumCore, uCEFChromium, uCEFWinControl, uCEFWindowParent,

  uCEFConstants, uCEFInterfaces, uCEFTypes, Vcl.StdCtrls, ULayersFrame;

type
  TMainFrm = class(TForm)
    GMMapChrm1: TGMMapChrm;
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    Timer1: TTimer;
    LayersFrame1: TLayersFrame;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Chromium1AfterCreated(Sender: TObject;
      const browser: ICefBrowser);
    procedure Chromium1Close(Sender: TObject; const browser: ICefBrowser;
      var aAction: TCefCloseBrowserAction);
    procedure Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
  private
  protected
    // Variables to control when can we destroy the form safely
    FCanClose: Boolean;  // Set to True in TChromium.OnBeforeClose
    FClosing : Boolean;  // Set to True in the CloseQuery event.

    // You have to handle this two messages to call NotifyMoveOrResizeStarted or some page elements will be misaligned.
    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;

    procedure BrowserDestroyMsg(var aMessage : TMessage); message CEF_DESTROY;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

{ TMainFrm }

procedure TMainFrm.BrowserDestroyMsg(var aMessage: TMessage);
begin
  CEFWindowParent1.Free;
end;

procedure TMainFrm.Chromium1AfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  PostMessage(Handle, CEF_AFTERCREATED, 0, 0);
end;

procedure TMainFrm.Chromium1BeforeClose(Sender: TObject;
  const browser: ICefBrowser);
begin
  FCanClose := True;
  PostMessage( Handle, WM_CLOSE, 0, 0 );
end;

procedure TMainFrm.Chromium1Close(Sender: TObject; const browser: ICefBrowser;
  var aAction: TCefCloseBrowserAction);
begin
  PostMessage(Handle, CEF_DESTROY, 0, 0);
  aAction := cbaDelay;
end;

constructor TMainFrm.Create(AOwner: TComponent);
begin
  inherited;

  FCanClose := False;
  FClosing  := False;
  if not( Chromium1.CreateBrowser( CEFWindowParent1 ) ) then
    Timer1.Enabled := True;

  LayersFrame1.GMMap := GMMapChrm1;
end;

procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if GMMapChrm1.Active then
    GMMapChrm1.Active := False;

  CanClose := FCanClose;
  if not(FClosing) then
  begin
    FClosing := True;
    Visible  := False;
    Chromium1.CloseBrowser(True);
  end;
end;

procedure TMainFrm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if ( not( Chromium1.CreateBrowser( CEFWindowParent1 ) ) and ( not( Chromium1.Initialized ) ) ) then
    Timer1.Enabled := True;
end;

procedure TMainFrm.WMMove(var aMessage: TWMMove);
begin
  inherited;
  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

procedure TMainFrm.WMMoving(var aMessage: TMessage);
begin
  inherited;
  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

end.
