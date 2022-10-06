unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GMLib.Classes, GMLib.Map, GMLib.Map.Vcl,
  Vcl.ExtCtrls, uCEFChromiumCore, uCEFChromium, uCEFWinControl, uCEFWindowParent,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, Vcl.CheckLst,
  UMapFrame,

  uCEFConstants, uCEFInterfaces, uCEFTypes,
  GMLib.LatLngBounds, GMLib.LatLng, GMLib.Sets;

type
  TMainFrm = class(TForm)
    GMMapChrm1: TGMMapChrm;
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    mEvents: TMemo;
    Timer1: TTimer;
    MapFrame1: TMapFrame;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Chromium1AfterCreated(Sender: TObject;
      const browser: ICefBrowser);
    procedure Chromium1Close(Sender: TObject; const browser: ICefBrowser;
      var aAction: TCefCloseBrowserAction);
    procedure Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure GMMapChrm1ActiveChange(Sender: TObject);
    procedure GMMapChrm1BoundsChanged(Sender: TObject;
      NewBounds: TGMLatLngBounds);
    procedure GMMapChrm1CenterChanged(Sender: TObject; LatLng: TGMLatLng; X,
      Y: Double);
    procedure GMMapChrm1Click(Sender: TObject; LatLng: TGMLatLng; X, Y: Double);
    procedure GMMapChrm1Contextmenu(Sender: TObject; LatLng: TGMLatLng; X,
      Y: Double);
    procedure GMMapChrm1DblClick(Sender: TObject; LatLng: TGMLatLng; X,
      Y: Double);
    procedure GMMapChrm1Drag(Sender: TObject);
    procedure GMMapChrm1DragEnd(Sender: TObject);
    procedure GMMapChrm1DragStart(Sender: TObject);
    procedure GMMapChrm1IntervalEventsChange(Sender: TObject);
    procedure GMMapChrm1MapTypeIdChanged(Sender: TObject;
      NewMapTypeId: TGMMapTypeId);
    procedure GMMapChrm1MouseMove(Sender: TObject; LatLng: TGMLatLng; X,
      Y: Double);
    procedure GMMapChrm1MouseOut(Sender: TObject; LatLng: TGMLatLng; X,
      Y: Double);
    procedure GMMapChrm1MouseOver(Sender: TObject; LatLng: TGMLatLng; X,
      Y: Double);
    procedure GMMapChrm1PropertyChanges(Owner: TObject; PropName: string);
    procedure GMMapChrm1ZoomChanged(Sender: TObject; NewZoom: Integer);
    procedure GMMapChrm1PrecisionChange(Sender: TObject);
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

uses
  System.TypInfo,
  GMLib.Transform.Vcl;

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

  MapFrame1.GMMap := GMMapChrm1;

  FCanClose := False;
  FClosing  := False;
  if not( Chromium1.CreateBrowser( CEFWindowParent1 ) ) then
    Timer1.Enabled := True;
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

procedure TMainFrm.GMMapChrm1ActiveChange(Sender: TObject);
begin
  mEvents.Lines.Add('OnActiveChanged event fired');
end;

procedure TMainFrm.GMMapChrm1BoundsChanged(Sender: TObject;
  NewBounds: TGMLatLngBounds);
begin
  mEvents.Lines.Add('OnBoundsChanged event fired: ' + NewBounds.ToStr);
end;

procedure TMainFrm.GMMapChrm1CenterChanged(Sender: TObject; LatLng: TGMLatLng;
  X, Y: Double);
begin
  mEvents.Lines.Add('OnCenterChanged event fired: ' + LatLng.ToStr);

  MapFrame1.eLat.OnChange := nil;
  MapFrame1.eLng.OnChange := nil;

  MapFrame1.eLat.Text := LatLng.LatToStr;
  MapFrame1.eLng.Text := LatLng.LngToStr;

  MapFrame1.eLat.OnChange := MapFrame1.eLatChange;
  MapFrame1.eLng.OnChange := MapFrame1.eLngChange;
end;

procedure TMainFrm.GMMapChrm1Click(Sender: TObject; LatLng: TGMLatLng; X,
  Y: Double);
begin
  mEvents.Lines.Add('OnClick event fired: ' + LatLng.ToStr);
end;

procedure TMainFrm.GMMapChrm1Contextmenu(Sender: TObject; LatLng: TGMLatLng; X,
  Y: Double);
begin
  mEvents.Lines.Add('OnContextmenu event fired: ' + LatLng.ToStr);
end;

procedure TMainFrm.GMMapChrm1DblClick(Sender: TObject; LatLng: TGMLatLng; X,
  Y: Double);
begin
  mEvents.Lines.Add('OnDblClick event fired: ' + LatLng.ToStr);
end;

procedure TMainFrm.GMMapChrm1Drag(Sender: TObject);
begin
  mEvents.Lines.Add('OnDrag event fired');
end;

procedure TMainFrm.GMMapChrm1DragEnd(Sender: TObject);
begin
  mEvents.Lines.Add('OnDragEnd event fired');
end;

procedure TMainFrm.GMMapChrm1DragStart(Sender: TObject);
begin
  mEvents.Lines.Add('OnDragStart event fired');
end;

procedure TMainFrm.GMMapChrm1IntervalEventsChange(Sender: TObject);
begin
  mEvents.Lines.Add('OnIntervalEventsChange event fired');
end;

procedure TMainFrm.GMMapChrm1MapTypeIdChanged(Sender: TObject;
  NewMapTypeId: TGMMapTypeId);
begin
  mEvents.Lines.Add('OnMapTypeIdChanged event fired: ' + TGMTransform.MapTypeIdToStr(NewMapTypeId));
end;

procedure TMainFrm.GMMapChrm1MouseMove(Sender: TObject; LatLng: TGMLatLng; X,
  Y: Double);
begin
  mEvents.Lines.Add('OnMouseMove event fired: ' + LatLng.ToStr);
end;

procedure TMainFrm.GMMapChrm1MouseOut(Sender: TObject; LatLng: TGMLatLng; X,
  Y: Double);
begin
  mEvents.Lines.Add('OnMouseOut event fired: ' + LatLng.ToStr);
end;

procedure TMainFrm.GMMapChrm1MouseOver(Sender: TObject; LatLng: TGMLatLng; X,
  Y: Double);
begin
  mEvents.Lines.Add('OnMouseOver event fired: ' + LatLng.ToStr);
end;

procedure TMainFrm.GMMapChrm1PrecisionChange(Sender: TObject);
begin
  mEvents.Lines.Add('OnPrecisionChange event fired');
end;

procedure TMainFrm.GMMapChrm1PropertyChanges(Owner: TObject; PropName: string);
begin
  mEvents.Lines.Add('OnPropertyChanges event fired: ' + PropName);
  if Pos('maptypeid', LowerCase(PropName)) > 0 then
    MapFrame1.GetMapTypeIds(MapFrame1.clbMTIds, MapFrame1.cbMapTypeId);
end;

procedure TMainFrm.GMMapChrm1ZoomChanged(Sender: TObject; NewZoom: Integer);
begin
  mEvents.Lines.Add('OnZoomChanged event fired: ' + NewZoom.ToString);
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
