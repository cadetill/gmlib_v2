unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GMLib.Classes, GMLib.Map, GMLib.Map.Vcl,
  Vcl.ExtCtrls, uCEFChromiumCore, uCEFChromium, uCEFWinControl, uCEFWindowParent,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,

  uCEFConstants, uCEFInterfaces, uCEFTypes,
  GMLib.LatLngBounds, GMLib.LatLng, GMLib.Sets, Vcl.CheckLst;

type
  TMainFrm = class(TForm)
    GMMapChrm1: TGMMapChrm;
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    Timer1: TTimer;
    Panel2: TPanel;
    cbActive: TCheckBox;
    pcPages: TPageControl;
    tsGeneral: TTabSheet;
    tsMapOptions: TTabSheet;
    eIntervalEvents: TSpinEdit;
    lIntervalEvents: TLabel;
    cbAPIVersion: TComboBox;
    lAPIVersion: TLabel;
    cbAPILang: TComboBox;
    lAPILang: TLabel;
    eAPIKey: TEdit;
    lAPIKey: TLabel;
    cbAPIRegion: TComboBox;
    lAPIRegion: TLabel;
    cbLanguage: TComboBox;
    lLanguage: TLabel;
    mEvents: TMemo;
    lBackgroundColor: TLabel;
    cbBackgroundColor: TColorBox;
    gbCenter: TGroupBox;
    lLat: TLabel;
    eLat: TEdit;
    eLng: TEdit;
    lLng: TLabel;
    cbClickableIcons: TCheckBox;
    cbDisableDoubleClickZoom: TCheckBox;
    pcObjects: TPageControl;
    tsFullScreenControl: TTabSheet;
    cbFullScreenControl: TCheckBox;
    cbFSPosition: TComboBox;
    lFSPosition: TLabel;
    tsMapTypeControl: TTabSheet;
    lMTPosition: TLabel;
    cbMTPosition: TComboBox;
    clbMTIds: TCheckListBox;
    tsRestriction: TTabSheet;
    cbREnabled: TCheckBox;
    cbRStrictBounds: TCheckBox;
    gbRNE: TGroupBox;
    lRNELat: TLabel;
    lRNELng: TLabel;
    eRNELat: TEdit;
    eRNELng: TEdit;
    gbRSW: TGroupBox;
    lRSWLat: TLabel;
    lRSWLng: TLabel;
    eRSWLat: TEdit;
    eRSWLng: TEdit;
    tsRotateControl: TTabSheet;
    cbRotateControl: TCheckBox;
    cbRotPosition: TComboBox;
    lRotPosition: TLabel;
    tsScaleControl: TTabSheet;
    cbMapTypeControl: TCheckBox;
    cbMTStyle: TComboBox;
    lMTStyle: TLabel;
    cbScaleControl: TCheckBox;
    cbSStyle: TComboBox;
    lSStyle: TLabel;
    tsStreetViewControl: TTabSheet;
    cbStreetViewControl: TCheckBox;
    cbSVPosition: TComboBox;
    lSVPosition: TLabel;
    tsZoomControl: TTabSheet;
    cbZoomControl: TCheckBox;
    lZPosition: TLabel;
    cbZPosition: TComboBox;
    Edit1: TEdit;
    Label2: TLabel;
    lMTIds: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Chromium1AfterCreated(Sender: TObject;
      const browser: ICefBrowser);
    procedure Chromium1Close(Sender: TObject; const browser: ICefBrowser;
      var aAction: TCefCloseBrowserAction);
    procedure Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbActiveClick(Sender: TObject);
    procedure cbAPILangChange(Sender: TObject);
    procedure cbAPIRegionChange(Sender: TObject);
    procedure cbAPIVersionChange(Sender: TObject);
    procedure cbLanguageChange(Sender: TObject);
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
    procedure eIntervalEventsChange(Sender: TObject);
    procedure cbFullScreenControlClick(Sender: TObject);
  private
    procedure GetAPILang;
    procedure GetAPIRegion;
    procedure GetAPIVersion;
    procedure GetLanguages;
    procedure SetPropToComponents;
    procedure GetPosition(cb: TComboBox; Selected: string);
    procedure GetMapTypeIds(clb: TCheckListBox);
    procedure GetMapTypeStyle;
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

procedure TMainFrm.cbActiveClick(Sender: TObject);
begin
  GMMapChrm1.Active := cbActive.Checked;
end;

procedure TMainFrm.cbAPILangChange(Sender: TObject);
begin
  GMMapChrm1.APILang := TGMTransform.StrToAPILang(cbAPILang.Text);
end;

procedure TMainFrm.cbAPIRegionChange(Sender: TObject);
begin
  GMMapChrm1.APIRegion := TGMTransform.StrToAPIRegion(cbAPIRegion.Text);
end;

procedure TMainFrm.cbAPIVersionChange(Sender: TObject);
begin
  GMMapChrm1.APIVer := TGMTransform.StrToAPIVer(cbAPIVersion.Text);
end;

procedure TMainFrm.cbFullScreenControlClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.FullScreenControl := cbFullScreenControl.Checked;
end;

procedure TMainFrm.cbLanguageChange(Sender: TObject);
begin
  GMMapChrm1.Language := TGMTransform.StrToLang(cbLanguage.Text);
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

  pcPages.ActivePage := tsGeneral;
  pcObjects.ActivePage := tsFullScreenControl;

  GetAPILang;
  GetAPIRegion;
  GetAPIVersion;
  GetLanguages;

  SetPropToComponents;

  FCanClose := False;
  FClosing  := False;
  if not( Chromium1.CreateBrowser( CEFWindowParent1 ) ) then
    Timer1.Enabled := True;
end;

procedure TMainFrm.eAPIKeyChange(Sender: TObject);
begin
  GMMapChrm1.APIKey := eAPIKey.Text;
end;

procedure TMainFrm.eIntervalEventsChange(Sender: TObject);
begin
  GMMapChrm1.IntervalEvents := eIntervalEvents.Value;
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

procedure TMainFrm.GetAPILang;
var
  Value: TGMAPILang;
begin
  cbAPILang.Items.Clear;
  for Value := Low(TGMAPILang) to High(TGMAPILang) do
    cbAPILang.Items.Add( GetEnumName(TypeInfo(TGMAPILang), Ord(Value)) );
  cbAPILang.ItemIndex := cbAPILang.Items.IndexOf('lEnglish');
end;

procedure TMainFrm.GetAPIRegion;
var
  Value: TGMAPIRegion;
begin
  cbAPIRegion.Items.Clear;
  for Value := Low(TGMAPIRegion) to High(TGMAPIRegion) do
    cbAPIRegion.Items.Add( GetEnumName(TypeInfo(TGMAPIRegion), Ord(Value)) );
  cbAPIRegion.ItemIndex := cbAPIRegion.Items.IndexOf('rAndorra');
end;

procedure TMainFrm.GetAPIVersion;
var
  Value: TGMAPIVer;
begin
  cbAPIVersion.Items.Clear;
  for Value := Low(TGMAPIVer) to High(TGMAPIVer) do
    cbAPIVersion.Items.Add( GetEnumName(TypeInfo(TGMAPIVer), Ord(Value)) );
  cbAPIVersion.ItemIndex := cbAPIVersion.Items.IndexOf('avWeekly');
end;

procedure TMainFrm.GetLanguages;
var
  Value: TGMLang;
begin
  cbLanguage.Items.Clear;
  for Value := Low(TGMLang) to High(TGMLang) do
    cbLanguage.Items.Add( GetEnumName(TypeInfo(TGMLang), Ord(Value)) );
  cbLanguage.ItemIndex := cbLanguage.Items.IndexOf('lnEnglish');
end;

procedure TMainFrm.GetMapTypeIds(clb: TCheckListBox);
var
  Value: TGMMapTypeId;
  Idx: Integer;
begin
  clb.Items.Clear;
  for Value := Low(TGMMapTypeId) to High(TGMMapTypeId) do
  begin
    Idx := clb.Items.Add( TGMTransform.MapTypeIdToStr(Value) );
    if Value in GMMapChrm1.MapOptions.MapTypeControlOptions.MapTypeIds then
      clb.Checked[Idx] := True;
  end;
end;

procedure TMainFrm.GetMapTypeStyle;
var
  Value: TGMMapTypeControlStyle;
begin
  cbMTStyle.Items.Clear;
  for Value := Low(TGMMapTypeControlStyle) to High(TGMMapTypeControlStyle) do
    cbMTStyle.Items.Add( TGMTransform.MapTypeControlStyleToStr(Value) );
  cbMTStyle.ItemIndex := cbMTStyle.Items.IndexOf(TGMTransform.MapTypeControlStyleToStr( GMMapChrm1.MapOptions.MapTypeControlOptions.Style ));
end;

procedure TMainFrm.GetPosition(cb: TComboBox; Selected: string);
var
  Value: TGMControlPosition;
begin
  cb.Items.Clear;
  for Value := Low(TGMControlPosition) to High(TGMControlPosition) do
    cb.Items.Add( TGMTransform.PositionToStr(Value) );
  cb.ItemIndex := cb.Items.IndexOf(Selected);
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
end;

procedure TMainFrm.GMMapChrm1ZoomChanged(Sender: TObject; NewZoom: Integer);
begin
  mEvents.Lines.Add('OnZoomChanged event fired: ' + NewZoom.ToString);
end;

procedure TMainFrm.SetPropToComponents;
begin
  cbBackgroundColor.Selected := GMMapChrm1.MapOptions.BackgroundColor;
  eLat.Text := GMMapChrm1.MapOptions.Center.LatToStr;
  eLng.Text := GMMapChrm1.MapOptions.Center.LngToStr;

  cbFullScreenControl.Checked := GMMapChrm1.MapOptions.FullScreenControl;
  GetPosition(cbFSPosition, TGMTransform.PositionToStr(GMMapChrm1.MapOptions.FullScreenControlOptions.Position));

  cbMapTypeControl.Checked := GMMapChrm1.MapOptions.MapTypeControl;
  GetPosition(cbMTPosition, TGMTransform.PositionToStr(GMMapChrm1.MapOptions.MapTypeControlOptions.Position));
  GetMapTypeIds(clbMTIds);
  GetMapTypeStyle;
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
