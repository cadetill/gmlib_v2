unit UMapFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.CheckLst, Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,

  GMLib.Map.Vcl;

type
  TMapFrame = class(TFrame)
    cbActive: TCheckBox;
    pcPages: TPageControl;
    tsGeneral: TTabSheet;
    lIntervalEvents: TLabel;
    lAPIVersion: TLabel;
    lAPILang: TLabel;
    lAPIKey: TLabel;
    lAPIRegion: TLabel;
    lLanguage: TLabel;
    eIntervalEvents: TSpinEdit;
    cbAPIVersion: TComboBox;
    cbAPILang: TComboBox;
    eAPIKey: TEdit;
    cbAPIRegion: TComboBox;
    cbLanguage: TComboBox;
    tsMapOptions: TTabSheet;
    lBackgroundColor: TLabel;
    cbBackgroundColor: TColorBox;
    gbCenter: TGroupBox;
    lLat: TLabel;
    lLng: TLabel;
    eLat: TEdit;
    eLng: TEdit;
    cbClickableIcons: TCheckBox;
    cbDisableDoubleClickZoom: TCheckBox;
    pcObjects: TPageControl;
    tsFullScreenControl: TTabSheet;
    lFSPosition: TLabel;
    cbFullScreenControl: TCheckBox;
    cbFSPosition: TComboBox;
    tsMapTypeControl: TTabSheet;
    lMTPosition: TLabel;
    lMTStyle: TLabel;
    lMTIds: TLabel;
    lMapTypeId: TLabel;
    cbMTPosition: TComboBox;
    clbMTIds: TCheckListBox;
    cbMapTypeControl: TCheckBox;
    cbMTStyle: TComboBox;
    cbMapTypeId: TComboBox;
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
    lRotPosition: TLabel;
    cbRotateControl: TCheckBox;
    cbRotPosition: TComboBox;
    tsScaleControl: TTabSheet;
    lSStyle: TLabel;
    cbScaleControl: TCheckBox;
    cbSStyle: TComboBox;
    tsStreetViewControl: TTabSheet;
    lSVPosition: TLabel;
    cbStreetViewControl: TCheckBox;
    cbSVPosition: TComboBox;
    tsZoomControl: TTabSheet;
    lZPosition: TLabel;
    lZoom: TLabel;
    lMaxZoom: TLabel;
    lMinZoom: TLabel;
    cbZoomControl: TCheckBox;
    cbZPosition: TComboBox;
    eZoom: TEdit;
    eMaxZoom: TEdit;
    eMinZoom: TEdit;
    cbNoClear: TCheckBox;
    cbKeyboardShortcuts: TCheckBox;
    cbIsFractionalZoomEnabled: TCheckBox;
    Label1: TLabel;
    procedure cbActiveClick(Sender: TObject);
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbAPILangChange(Sender: TObject);
    procedure cbAPIRegionChange(Sender: TObject);
    procedure cbAPIVersionChange(Sender: TObject);
    procedure eIntervalEventsChange(Sender: TObject);
    procedure cbLanguageChange(Sender: TObject);
    procedure cbBackgroundColorChange(Sender: TObject);
    procedure eLatChange(Sender: TObject);
    procedure eLngChange(Sender: TObject);
    procedure cbClickableIconsClick(Sender: TObject);
    procedure cbDisableDoubleClickZoomClick(Sender: TObject);
    procedure cbNoClearClick(Sender: TObject);
    procedure cbKeyboardShortcutsClick(Sender: TObject);
    procedure cbIsFractionalZoomEnabledClick(Sender: TObject);
    procedure cbFullScreenControlClick(Sender: TObject);
    procedure cbFSPositionChange(Sender: TObject);
    procedure cbMapTypeIdChange(Sender: TObject);
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
    procedure cbRotateControlClick(Sender: TObject);
    procedure cbRotPositionChange(Sender: TObject);
    procedure cbScaleControlClick(Sender: TObject);
    procedure cbSStyleChange(Sender: TObject);
    procedure cbStreetViewControlClick(Sender: TObject);
    procedure cbSVPositionChange(Sender: TObject);
    procedure eZoomChange(Sender: TObject);
    procedure cbZoomControlClick(Sender: TObject);
    procedure cbZPositionChange(Sender: TObject);
    procedure eMaxZoomChange(Sender: TObject);
    procedure eMinZoomChange(Sender: TObject);
  private
    FGMMap: TGMMap;
    procedure SetGMMap(const Value: TGMMap);
  protected
    procedure SetPropToComponents;

    procedure GetAPILang;
    procedure GetAPIRegion;
    procedure GetAPIVersion;
    procedure GetLanguages;

    procedure GetPosition(cb: TComboBox; Selected: string);
    procedure GetMapTypeStyle;
    procedure GetScaleStyle;
  public
    constructor Create(AOwner: TComponent); override;

    procedure GetMapTypeIds(clb: TCheckListBox; cb: TComboBox);

    property GMMap: TGMMap read FGMMap write SetGMMap;
  end;

  // because GMMap property (from the frame) is an object from TGMMap class and this class has
  //  all properties protected, I need to define this class to do public all properties
  TGMPublic = class(TGMMap);

implementation

uses
  System.TypInfo,
  GMLib.Sets, GMLib.Transform.Vcl;

{$R *.dfm}

procedure TMapFrame.cbActiveClick(Sender: TObject);
begin
  TGMPublic(GMMap).Active := cbActive.Checked;
end;

procedure TMapFrame.cbAPILangChange(Sender: TObject);
begin
  TGMPublic(GMMap).APILang := TGMTransform.StrToAPILang(cbAPILang.Text);
end;

procedure TMapFrame.cbAPIRegionChange(Sender: TObject);
begin
  TGMPublic(GMMap).APIRegion := TGMTransform.StrToAPIRegion(cbAPIRegion.Text);
end;

procedure TMapFrame.cbAPIVersionChange(Sender: TObject);
begin
  TGMPublic(GMMap).APIVer := TGMTransform.StrToAPIVer(cbAPIVersion.Text);
end;

procedure TMapFrame.cbBackgroundColorChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.BackgroundColor := cbBackgroundColor.Selected;
end;

procedure TMapFrame.cbClickableIconsClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.ClickableIcons := cbClickableIcons.Checked;
end;

procedure TMapFrame.cbDisableDoubleClickZoomClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.DisableDoubleClickZoom := cbDisableDoubleClickZoom.Checked;
end;

procedure TMapFrame.cbFSPositionChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.FullScreenControlOptions.Position := TGMTransform.StrToPosition(cbFSPosition.Text);
end;

procedure TMapFrame.cbFullScreenControlClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.FullScreenControl := cbFullScreenControl.Checked;
end;

procedure TMapFrame.cbIsFractionalZoomEnabledClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.IsFractionalZoomEnabled := cbIsFractionalZoomEnabled.Checked;
end;

procedure TMapFrame.cbKeyboardShortcutsClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.KeyboardShortcuts := cbKeyboardShortcuts.Checked;
end;

procedure TMapFrame.cbLanguageChange(Sender: TObject);
begin
  TGMPublic(GMMap).Language := TGMTransform.StrToLang(cbLanguage.Text);
end;

procedure TMapFrame.cbMapTypeControlClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.MapTypeControl := cbMapTypeControl.Checked;
end;

procedure TMapFrame.cbMapTypeIdChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.MapTypeId := TGMTransform.StrToMapTypeId(cbMapTypeId.Text);
end;

procedure TMapFrame.cbMTPositionChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.MapTypeControlOptions.Position := TGMTransform.StrToPosition(cbMTPosition.Text);
end;

procedure TMapFrame.cbMTStyleChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.MapTypeControlOptions.Style := TGMTransform.StrToMapTypeControlStyle(cbMTStyle.Text);
end;

procedure TMapFrame.cbNoClearClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.NoClear := cbNoClear.Checked;
end;

procedure TMapFrame.cbREnabledClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Restriction.Enabled := cbREnabled.Checked;
end;

procedure TMapFrame.cbRotateControlClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.RotateControl := cbRotateControl.Checked;
end;

procedure TMapFrame.cbRotPositionChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.RotateControlOptions.Position := TGMTransform.StrToPosition(cbRotPosition.Text);
end;

procedure TMapFrame.cbRStrictBoundsClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Restriction.StrictBounds := cbRStrictBounds.Checked;
end;

procedure TMapFrame.cbScaleControlClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.ScaleControl := cbScaleControl.Checked;
end;

procedure TMapFrame.cbSStyleChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.ScaleControlOptions.Style := TGMTransform.StrToScaleControlStyle(cbSStyle.Text);
end;

procedure TMapFrame.cbStreetViewControlClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.StreetViewControl := cbStreetViewControl.Checked;
end;

procedure TMapFrame.cbSVPositionChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.StreetViewControlOptions.Position := TGMTransform.StrToPosition(cbSVPosition.Text);
end;

procedure TMapFrame.cbZoomControlClick(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.ZoomControl := cbZoomControl.Checked;
end;

procedure TMapFrame.cbZPositionChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.ZoomControlOptions.Position := TGMTransform.StrToPosition(cbZPosition.Text);
end;

procedure TMapFrame.clbMTIdsClickCheck(Sender: TObject);
var
  i: Integer;
begin
  TGMPublic(GMMap).MapOptions.MapTypeControlOptions.MapTypeIds := [];
  for i := 0 to clbMTIds.Count - 1 do
  begin
    if clbMTIds.Checked[i] then
      TGMPublic(GMMap).MapOptions.MapTypeControlOptions.MapTypeIds := TGMPublic(GMMap).MapOptions.MapTypeControlOptions.MapTypeIds + [TGMTransform.StrToMapTypeId(clbMTIds.Items[i])];
  end;
end;

constructor TMapFrame.Create(AOwner: TComponent);
begin
  inherited;

  pcPages.ActivePage := tsGeneral;
  pcObjects.ActivePage := tsFullScreenControl;
end;

procedure TMapFrame.eAPIKeyChange(Sender: TObject);
begin
  TGMPublic(GMMap).APIKey := eAPIKey.Text;
end;

procedure TMapFrame.eIntervalEventsChange(Sender: TObject);
begin
  TGMPublic(GMMap).IntervalEvents := eIntervalEvents.Value;
end;

procedure TMapFrame.eLatChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Center.Lat := TGMTransform.GetStrToDouble(eLat.Text);
end;

procedure TMapFrame.eLngChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Center.Lng := TGMTransform.GetStrToDouble(eLng.Text);
end;

procedure TMapFrame.eMaxZoomChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.MaxZoom := TGMTransform.GetStrToInteger(eMaxZoom.Text);
end;

procedure TMapFrame.eMinZoomChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.MinZoom := TGMTransform.GetStrToInteger(eMinZoom.Text);
end;

procedure TMapFrame.eRNELatChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.NE.Lat := TGMTransform.GetStrToDouble(eRNELat.Text);
end;

procedure TMapFrame.eRNELngChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.NE.Lng := TGMTransform.GetStrToDouble(eRNELng.Text);
end;

procedure TMapFrame.eRSWLatChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.SW.Lat := TGMTransform.GetStrToDouble(eRSWLat.Text);
end;

procedure TMapFrame.eRSWLngChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.SW.Lng := TGMTransform.GetStrToDouble(eRSWLng.Text);
end;

procedure TMapFrame.eZoomChange(Sender: TObject);
begin
  TGMPublic(GMMap).MapOptions.Zoom := TGMTransform.GetStrToInteger(eZoom.Text);
end;

procedure TMapFrame.GetAPILang;
var
  Value: TGMAPILang;
begin
  cbAPILang.Items.Clear;
  for Value := Low(TGMAPILang) to High(TGMAPILang) do
    cbAPILang.Items.Add( GetEnumName(TypeInfo(TGMAPILang), Ord(Value)) );

  cbAPILang.ItemIndex := cbAPILang.Items.IndexOf( GetEnumName(TypeInfo(TGMAPILang), Ord(TGMPublic(GMMap).APILang)) );
end;

procedure TMapFrame.GetAPIRegion;
var
  Value: TGMAPIRegion;
begin
  cbAPIRegion.Items.Clear;
  for Value := Low(TGMAPIRegion) to High(TGMAPIRegion) do
    cbAPIRegion.Items.Add( GetEnumName(TypeInfo(TGMAPIRegion), Ord(Value)) );
  cbAPIRegion.ItemIndex := cbAPIRegion.Items.IndexOf( GetEnumName(TypeInfo(TGMAPIRegion), Ord(TGMPublic(GMMap).APIRegion)) );
end;

procedure TMapFrame.GetAPIVersion;
var
  Value: TGMAPIVer;
begin
  cbAPIVersion.Items.Clear;
  for Value := Low(TGMAPIVer) to High(TGMAPIVer) do
    cbAPIVersion.Items.Add( GetEnumName(TypeInfo(TGMAPIVer), Ord(Value)) );
  cbAPIVersion.ItemIndex := cbAPIVersion.Items.IndexOf( GetEnumName(TypeInfo(TGMAPIVer), Ord(TGMPublic(GMMap).APIVer)) );
end;

procedure TMapFrame.GetLanguages;
var
  Value: TGMLang;
begin
  cbLanguage.Items.Clear;
  for Value := Low(TGMLang) to High(TGMLang) do
    cbLanguage.Items.Add( GetEnumName(TypeInfo(TGMLang), Ord(Value)) );
  cbLanguage.ItemIndex := cbLanguage.Items.IndexOf( GetEnumName(TypeInfo(TGMLang), Ord(TGMPublic(GMMap).Language)) );
end;

procedure TMapFrame.GetMapTypeIds(clb: TCheckListBox; cb: TComboBox);
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
    if Value in TGMPublic(GMMap).MapOptions.MapTypeControlOptions.MapTypeIds then
      clb.Checked[Idx] := True;
  end;
  cb.ItemIndex := cb.Items.IndexOf(TGMTransform.MapTypeIdToStr( TGMPublic(GMMap).MapOptions.MapTypeId ));
end;

procedure TMapFrame.GetMapTypeStyle;
var
  Value: TGMMapTypeControlStyle;
begin
  cbMTStyle.Items.Clear;
  for Value := Low(TGMMapTypeControlStyle) to High(TGMMapTypeControlStyle) do
    cbMTStyle.Items.Add( TGMTransform.MapTypeControlStyleToStr(Value) );
  cbMTStyle.ItemIndex := cbMTStyle.Items.IndexOf(TGMTransform.MapTypeControlStyleToStr( TGMPublic(GMMap).MapOptions.MapTypeControlOptions.Style ));
end;

procedure TMapFrame.GetPosition(cb: TComboBox; Selected: string);
var
  Value: TGMControlPosition;
begin
  cb.Items.Clear;
  for Value := Low(TGMControlPosition) to High(TGMControlPosition) do
    cb.Items.Add( TGMTransform.PositionToStr(Value) );
  cb.ItemIndex := cb.Items.IndexOf(Selected);
end;

procedure TMapFrame.GetScaleStyle;
var
  Value: TGMScaleControlStyle;
begin
  cbSStyle.Items.Clear;
  for Value := Low(TGMScaleControlStyle) to High(TGMScaleControlStyle) do
    cbSStyle.Items.Add( TGMTransform.ScaleControlStyleToStr(Value) );
  cbSStyle.ItemIndex := cbSStyle.Items.IndexOf(TGMTransform.ScaleControlStyleToStr( TGMPublic(GMMap).MapOptions.ScaleControlOptions.Style ));
end;

procedure TMapFrame.SetGMMap(const Value: TGMMap);
begin
  if FGMMap = Value then
    Exit;

  FGMMap := Value;

  GetAPILang;
  GetAPIRegion;
  GetAPIVersion;
  GetLanguages;

  SetPropToComponents;
end;

procedure TMapFrame.SetPropToComponents;
begin
  eAPIKey.Text := TGMPublic(GMMap).APIKey;
  cbActive.Checked := TGMPublic(GMMap).Active;

  cbBackgroundColor.Selected := TGMPublic(GMMap).MapOptions.BackgroundColor;
  eLat.Text := TGMPublic(GMMap).MapOptions.Center.LatToStr;
  eLng.Text := TGMPublic(GMMap).MapOptions.Center.LngToStr;
  cbClickableIcons.Checked := TGMPublic(GMMap).MapOptions.ClickableIcons;
  cbDisableDoubleClickZoom.Checked := TGMPublic(GMMap).MapOptions.DisableDoubleClickZoom;
  cbNoClear.Checked := TGMPublic(GMMap).MapOptions.NoClear;
  cbKeyboardShortcuts.Checked := TGMPublic(GMMap).MapOptions.KeyboardShortcuts;
  cbIsFractionalZoomEnabled.Checked := TGMPublic(GMMap).MapOptions.IsFractionalZoomEnabled;

  cbFullScreenControl.Checked := TGMPublic(GMMap).MapOptions.FullScreenControl;
  GetPosition(cbFSPosition, TGMTransform.PositionToStr(TGMPublic(GMMap).MapOptions.FullScreenControlOptions.Position));

  cbMapTypeControl.Checked := TGMPublic(GMMap).MapOptions.MapTypeControl;
  GetPosition(cbMTPosition, TGMTransform.PositionToStr(TGMPublic(GMMap).MapOptions.MapTypeControlOptions.Position));
  GetMapTypeIds(clbMTIds, cbMapTypeId);
  GetMapTypeStyle;

  cbREnabled.Checked := TGMPublic(GMMap).MapOptions.Restriction.Enabled;
  cbRStrictBounds.Checked := TGMPublic(GMMap).MapOptions.Restriction.StrictBounds;
  eRNELat.Text := TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.NE.LatToStr;
  eRNELng.Text := TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.NE.LngToStr;
  eRSWLat.Text := TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.SW.LatToStr;
  eRSWLng.Text := TGMPublic(GMMap).MapOptions.Restriction.LatLngBounds.SW.LngToStr;

  cbRotateControl.Checked := TGMPublic(GMMap).MapOptions.RotateControl;
  GetPosition(cbRotPosition, TGMTransform.PositionToStr(TGMPublic(GMMap).MapOptions.RotateControlOptions.Position));

  cbScaleControl.Checked := TGMPublic(GMMap).MapOptions.ScaleControl;
  GetScaleStyle;

  cbStreetViewControl.Checked := TGMPublic(GMMap).MapOptions.StreetViewControl;
  GetPosition(cbSVPosition, TGMTransform.PositionToStr(TGMPublic(GMMap).MapOptions.StreetViewControlOptions.Position));

  cbZoomControl.Checked := TGMPublic(GMMap).MapOptions.ZoomControl;
  GetPosition(cbZPosition, TGMTransform.PositionToStr(TGMPublic(GMMap).MapOptions.ZoomControlOptions.Position));
  eZoom.Text := TGMPublic(GMMap).MapOptions.Zoom.ToString;
  eMaxZoom.Text := TGMPublic(GMMap).MapOptions.MaxZoom.ToString;
  eMinZoom.Text := TGMPublic(GMMap).MapOptions.MinZoom.ToString;
end;

end.
