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
    eZoom: TEdit;
    lZoom: TLabel;
    lMTIds: TLabel;
    eMaxZoom: TEdit;
    lMaxZoom: TLabel;
    eMinZoom: TEdit;
    lMinZoom: TLabel;
    cbNoClear: TCheckBox;
    cbMapTypeId: TComboBox;
    lMapTypeId: TLabel;
    cbKeyboardShortcuts: TCheckBox;
    cbIsFractionalZoomEnabled: TCheckBox;
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
    procedure cbFSPositionChange(Sender: TObject);
    procedure cbMapTypeControlClick(Sender: TObject);
    procedure cbMTPositionChange(Sender: TObject);
    procedure cbMTStyleChange(Sender: TObject);
    procedure clbMTIdsClickCheck(Sender: TObject);
    procedure cbREnabledClick(Sender: TObject);
    procedure cbRStrictBoundsClick(Sender: TObject);
    procedure eRNELatChange(Sender: TObject);
    procedure eRNELngChange(Sender: TObject);
    procedure eRSWLatChange(Sender: TObject);
    procedure eRSWLngChange(Sender: TObject);
    procedure cbClickableIconsClick(Sender: TObject);
    procedure cbDisableDoubleClickZoomClick(Sender: TObject);
    procedure cbBackgroundColorChange(Sender: TObject);
    procedure eLatChange(Sender: TObject);
    procedure eLngChange(Sender: TObject);
    procedure cbRotateControlClick(Sender: TObject);
    procedure cbRotPositionChange(Sender: TObject);
    procedure cbZPositionChange(Sender: TObject);
    procedure cbZoomControlClick(Sender: TObject);
    procedure eZoomChange(Sender: TObject);
    procedure eMaxZoomChange(Sender: TObject);
    procedure eMinZoomChange(Sender: TObject);
    procedure cbScaleControlClick(Sender: TObject);
    procedure cbSStyleChange(Sender: TObject);
    procedure cbStreetViewControlClick(Sender: TObject);
    procedure cbSVPositionChange(Sender: TObject);
    procedure cbNoClearClick(Sender: TObject);
    procedure cbMapTypeIdChange(Sender: TObject);
    procedure cbKeyboardShortcutsClick(Sender: TObject);
    procedure cbIsFractionalZoomEnabledClick(Sender: TObject);
  private
    procedure GetAPILang;
    procedure GetAPIRegion;
    procedure GetAPIVersion;
    procedure GetLanguages;
    procedure SetPropToComponents;
    procedure GetPosition(cb: TComboBox; Selected: string);
    procedure GetMapTypeIds(clb: TCheckListBox; cb: TComboBox);
    procedure GetMapTypeStyle;
    procedure GetScaleStyle;
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

procedure TMainFrm.cbBackgroundColorChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.BackgroundColor := cbBackgroundColor.Selected;
end;

procedure TMainFrm.cbClickableIconsClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.ClickableIcons := cbClickableIcons.Checked;
end;

procedure TMainFrm.cbDisableDoubleClickZoomClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.DisableDoubleClickZoom := cbDisableDoubleClickZoom.Checked;
end;

procedure TMainFrm.cbFSPositionChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.FullScreenControlOptions.Position := TGMTransform.StrToPosition(cbFSPosition.Text);
end;

procedure TMainFrm.cbFullScreenControlClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.FullScreenControl := cbFullScreenControl.Checked;
end;

procedure TMainFrm.cbIsFractionalZoomEnabledClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.IsFractionalZoomEnabled := cbIsFractionalZoomEnabled.Checked;
end;

procedure TMainFrm.cbKeyboardShortcutsClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.KeyboardShortcuts := cbKeyboardShortcuts.Checked;
end;

procedure TMainFrm.cbLanguageChange(Sender: TObject);
begin
  GMMapChrm1.Language := TGMTransform.StrToLang(cbLanguage.Text);
end;

procedure TMainFrm.cbMapTypeControlClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.MapTypeControl := cbMapTypeControl.Checked;
end;

procedure TMainFrm.cbMapTypeIdChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.MapTypeId := TGMTransform.StrToMapTypeId(cbMapTypeId.Text);
end;

procedure TMainFrm.cbMTPositionChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.MapTypeControlOptions.Position := TGMTransform.StrToPosition(cbMTPosition.Text);
end;

procedure TMainFrm.cbMTStyleChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.MapTypeControlOptions.Style := TGMTransform.StrToMapTypeControlStyle(cbMTStyle.Text);
end;

procedure TMainFrm.cbNoClearClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.NoClear := cbNoClear.Checked;
end;

procedure TMainFrm.cbREnabledClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Restriction.Enabled := cbREnabled.Checked;
end;

procedure TMainFrm.cbRotateControlClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.RotateControl := cbRotateControl.Checked;
end;

procedure TMainFrm.cbRotPositionChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.RotateControlOptions.Position := TGMTransform.StrToPosition(cbRotPosition.Text);
end;

procedure TMainFrm.cbRStrictBoundsClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Restriction.StrictBounds := cbRStrictBounds.Checked;
end;

procedure TMainFrm.cbScaleControlClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.ScaleControl := cbScaleControl.Checked;
end;

procedure TMainFrm.cbSStyleChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.ScaleControlOptions.Style := TGMTransform.StrToScaleControlStyle(cbSStyle.Text);
end;

procedure TMainFrm.cbStreetViewControlClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.StreetViewControl := cbStreetViewControl.Checked;
end;

procedure TMainFrm.cbSVPositionChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.StreetViewControlOptions.Position := TGMTransform.StrToPosition(cbSVPosition.Text);
end;

procedure TMainFrm.cbZoomControlClick(Sender: TObject);
begin
  GMMapChrm1.MapOptions.ZoomControl := cbZoomControl.Checked;
end;

procedure TMainFrm.cbZPositionChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.ZoomControlOptions.Position := TGMTransform.StrToPosition(cbZPosition.Text);
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

procedure TMainFrm.clbMTIdsClickCheck(Sender: TObject);
var
  i: Integer;
begin
  GMMapChrm1.MapOptions.MapTypeControlOptions.MapTypeIds := [];
  for i := 0 to clbMTIds.Count - 1 do
  begin
    if clbMTIds.Checked[i] then
      GMMapChrm1.MapOptions.MapTypeControlOptions.MapTypeIds := GMMapChrm1.MapOptions.MapTypeControlOptions.MapTypeIds + [TGMTransform.StrToMapTypeId(clbMTIds.Items[i])];
  end;
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

procedure TMainFrm.eLatChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Center.Lat := TGMTransform.GetStrToDouble(eLat.Text);
end;

procedure TMainFrm.eLngChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Center.Lng := TGMTransform.GetStrToDouble(eLng.Text);
end;

procedure TMainFrm.eMaxZoomChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.MaxZoom := TGMTransform.GetStrToInteger(eMaxZoom.Text);
end;

procedure TMainFrm.eMinZoomChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.MinZoom := TGMTransform.GetStrToInteger(eMinZoom.Text);
end;

procedure TMainFrm.eRNELatChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Restriction.LatLngBounds.NE.Lat := TGMTransform.GetStrToDouble(eRNELat.Text);
end;

procedure TMainFrm.eRNELngChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Restriction.LatLngBounds.NE.Lng := TGMTransform.GetStrToDouble(eRNELng.Text);
end;

procedure TMainFrm.eRSWLatChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Restriction.LatLngBounds.SW.Lat := TGMTransform.GetStrToDouble(eRSWLat.Text);
end;

procedure TMainFrm.eRSWLngChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Restriction.LatLngBounds.SW.Lng := TGMTransform.GetStrToDouble(eRSWLng.Text);
end;

procedure TMainFrm.eZoomChange(Sender: TObject);
begin
  GMMapChrm1.MapOptions.Zoom := TGMTransform.GetStrToInteger(eZoom.Text);
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

procedure TMainFrm.GetMapTypeIds(clb: TCheckListBox; cb: TComboBox);
var
  Value: TGMMapTypeId;
  Idx: Integer;
begin
  clb.Items.Clear;
  cb.Items.Clear;
  for Value := Low(TGMMapTypeId) to High(TGMMapTypeId) do
  begin
    Idx := clb.Items.Add( TGMTransform.MapTypeIdToStr(Value) );
    cb.Items.Add( GetEnumName(TypeInfo(TGMMapTypeId), Ord(Value)) );
    if Value in GMMapChrm1.MapOptions.MapTypeControlOptions.MapTypeIds then
      clb.Checked[Idx] := True;
  end;
  cb.ItemIndex := cb.Items.IndexOf(TGMTransform.MapTypeIdToStr( GMMapChrm1.MapOptions.MapTypeId ));
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

procedure TMainFrm.GetScaleStyle;
var
  Value: TGMScaleControlStyle;
begin
  cbSStyle.Items.Clear;
  for Value := Low(TGMScaleControlStyle) to High(TGMScaleControlStyle) do
    cbSStyle.Items.Add( TGMTransform.ScaleControlStyleToStr(Value) );
  cbSStyle.ItemIndex := cbSStyle.Items.IndexOf(TGMTransform.ScaleControlStyleToStr( GMMapChrm1.MapOptions.ScaleControlOptions.Style ));
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

  eLat.OnChange := nil;
  eLng.OnChange := nil;

  eLat.Text := LatLng.LatToStr;
  eLng.Text := LatLng.LngToStr;

  eLat.OnChange := eLatChange;
  eLng.OnChange := eLngChange;
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
  if SameText(PropName, 'MapTypeId') then
    GetMapTypeIds(clbMTIds, cbMapTypeId);
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
  cbClickableIcons.Checked := GMMapChrm1.MapOptions.ClickableIcons;
  cbDisableDoubleClickZoom.Checked := GMMapChrm1.MapOptions.DisableDoubleClickZoom;
  cbNoClear.Checked := GMMapChrm1.MapOptions.NoClear;
  cbKeyboardShortcuts.Checked := GMMapChrm1.MapOptions.KeyboardShortcuts;
  cbIsFractionalZoomEnabled.Checked := GMMapChrm1.MapOptions.IsFractionalZoomEnabled;

  cbFullScreenControl.Checked := GMMapChrm1.MapOptions.FullScreenControl;
  GetPosition(cbFSPosition, TGMTransform.PositionToStr(GMMapChrm1.MapOptions.FullScreenControlOptions.Position));

  cbMapTypeControl.Checked := GMMapChrm1.MapOptions.MapTypeControl;
  GetPosition(cbMTPosition, TGMTransform.PositionToStr(GMMapChrm1.MapOptions.MapTypeControlOptions.Position));
  GetMapTypeIds(clbMTIds, cbMapTypeId);
  GetMapTypeStyle;

  cbREnabled.Checked := GMMapChrm1.MapOptions.Restriction.Enabled;
  cbRStrictBounds.Checked := GMMapChrm1.MapOptions.Restriction.StrictBounds;
  eRNELat.Text := GMMapChrm1.MapOptions.Restriction.LatLngBounds.NE.LatToStr;
  eRNELng.Text := GMMapChrm1.MapOptions.Restriction.LatLngBounds.NE.LngToStr;
  eRSWLat.Text := GMMapChrm1.MapOptions.Restriction.LatLngBounds.SW.LatToStr;
  eRSWLng.Text := GMMapChrm1.MapOptions.Restriction.LatLngBounds.SW.LngToStr;

  cbRotateControl.Checked := GMMapChrm1.MapOptions.RotateControl;
  GetPosition(cbRotPosition, TGMTransform.PositionToStr(GMMapChrm1.MapOptions.RotateControlOptions.Position));

  cbScaleControl.Checked := GMMapChrm1.MapOptions.ScaleControl;
  GetScaleStyle;

  cbStreetViewControl.Checked := GMMapChrm1.MapOptions.StreetViewControl;
  GetPosition(cbSVPosition, TGMTransform.PositionToStr(GMMapChrm1.MapOptions.StreetViewControlOptions.Position));

  cbZoomControl.Checked := GMMapChrm1.MapOptions.ZoomControl;
  GetPosition(cbZPosition, TGMTransform.PositionToStr(GMMapChrm1.MapOptions.ZoomControlOptions.Position));
  eZoom.Text := GMMapChrm1.MapOptions.Zoom.ToString;
  eMaxZoom.Text := GMMapChrm1.MapOptions.MaxZoom.ToString;
  eMinZoom.Text := GMMapChrm1.MapOptions.MinZoom.ToString;
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
