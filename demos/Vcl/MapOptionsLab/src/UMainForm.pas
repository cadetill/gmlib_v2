{**
  @abstract(Demo VCL de laboratorio para validar opciones del mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define un formulario construido por código para probar de forma
  rápida opciones de TGMLibMap antes y después de activar el mapa.
}
unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.Graphics,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Edge,
  uGMLib.Core.Types, uGMLib.MapOptions, uGMLib.Vcl.Map;

type
  {** @abstract(Formulario principal de la demo `MapOptionsLab`.) }
  TMainForm = class(TForm)
  private
    FMap: TGMLibMap;
    FRootPanel: TPanel;
    FOptionsPanel: TScrollBox;
    FMapPanel: TPanel;
    FTopPanel: TPanel;
    FLogPanel: TPanel;
    FBrowser: TEdgeBrowser;
    FLogMemo: TMemo;
    FStatusLabel: TLabel;
    FAPIKeyEdit: TEdit;
    FCenterLatEdit: TEdit;
    FCenterLngEdit: TEdit;
    FZoomEdit: TEdit;
    FApplyViewButton: TButton;
    FApplyOptionsButton: TButton;
    FActivateButton: TButton;
    FCameraControlCheck: TCheckBox;
    FClickableIconsCheck: TCheckBox;
    FDisableDefaultUICheck: TCheckBox;
    FDisableDoubleClickZoomCheck: TCheckBox;
    FDraggingCursorEdit: TEdit;
    FDraggableCursorEdit: TEdit;
    FFullscreenControlCheck: TCheckBox;
    FHeadingEdit: TEdit;
    FHeadingInteractionEnabledCheck: TCheckBox;
    FIsFractionalZoomEnabledCheck: TCheckBox;
    FKeyboardShortcutsCheck: TCheckBox;
    FMapTypeControlCheck: TCheckBox;
    FRotateControlCheck: TCheckBox;
    FScaleControlCheck: TCheckBox;
    FScrollwheelCheck: TCheckBox;
    FStreetViewControlCheck: TCheckBox;
    FTiltEdit: TEdit;
    FTiltInteractionEnabledCheck: TCheckBox;
    FZoomControlCheck: TCheckBox;
    FMapTypeRoadmapCheck: TCheckBox;
    FMapTypeSatelliteCheck: TCheckBox;
    FMapTypeHybridCheck: TCheckBox;
    FMapTypeTerrainCheck: TCheckBox;
    FColorSchemeCombo: TComboBox;
    FControlSizeEdit: TEdit;
    FGestureHandlingCombo: TComboBox;
    FMapIdEdit: TEdit;
    FMapTypeIdCombo: TComboBox;
    FMapTypeStyleCombo: TComboBox;
    FCameraPositionCombo: TComboBox;
    FFullscreenPositionCombo: TComboBox;
    FMapTypePositionCombo: TComboBox;
    FMaxZoomEdit: TEdit;
    FMinZoomEdit: TEdit;
    FNoClearCheck: TCheckBox;
    FRenderingTypeCombo: TComboBox;
    FRestrictionEastEdit: TEdit;
    FRestrictionNorthEdit: TEdit;
    FRestrictionSouthEdit: TEdit;
    FRestrictionStrictBoundsCheck: TCheckBox;
    FRestrictionWestEdit: TEdit;
    FRotatePositionCombo: TComboBox;
    FStreetViewPositionCombo: TComboBox;
    FZoomPositionCombo: TComboBox;
    function BuildMapTypeIds: TGMMapTypeIds;
    function PositionFromCombo(ACombo: TComboBox): TGMControlPosition;
    function PositionToComboIndex(AValue: TGMControlPosition): Integer;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyOptionsButtonClick(Sender: TObject);
    procedure ApplyViewButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure BuildLayout;
    procedure CreateCheckBox(AParent: TWinControl; const ACaption: string; ATop: Integer; out ACheckBox: TCheckBox);
    procedure CreateComboBox(AParent: TWinControl; const ACaption: string; ATop: Integer; out AComboBox: TComboBox);
    procedure CreateEdit(AParent: TWinControl; const ACaption, AValue: string; ALeft, ATop, AWidth: Integer; out AEdit: TEdit);
    procedure HandleBoundsChanged(Sender: TObject; ABounds: TGMLatLngBounds);
    procedure CreateSectionLabel(AParent: TWinControl; const ACaption: string; ATop: Integer);
    procedure HandleCenterChanged(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure HandleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleDrag(Sender: TObject);
    procedure HandleDragEnd(Sender: TObject);
    procedure HandleDragStart(Sender: TObject);
    procedure HandleHeadingChanged(Sender: TObject; AHeading: Double);
    procedure HandleIdle(Sender: TObject);
    procedure HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandleMapTypeIdChanged(Sender: TObject; AMapTypeId: TGMMapTypeId);
    procedure HandleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleProjectionChanged(Sender: TObject);
    procedure HandleRenderingTypeChanged(Sender: TObject; ARenderingType: TGMRenderingType);
    procedure HandleTilesLoaded(Sender: TObject);
    procedure HandleTiltChanged(Sender: TObject; ATilt: Integer);
    procedure HandleZoomChanged(Sender: TObject; AZoom: Integer);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure Log(const AText: string);
    procedure PopulateCombos;
    procedure UpdateStatus(const AText: string);
  protected
  public
    {** @abstract(Crea el formulario y construye la UI del laboratorio.) }
    constructor Create(AOwner: TComponent); override;
    {** @abstract(Libera recursos asociados al mapa y al navegador embebido.) }
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

uses
  Winapi.ActiveX, System.StrUtils, System.TypInfo;

procedure SetBooleanPropertyIfPublished(AInstance: TObject;
  const APropertyName: string; const AValue: Boolean);
var
  PropInfo: PPropInfo;
begin
  if not Assigned(AInstance) then
    Exit;

  PropInfo := GetPropInfo(AInstance, APropertyName);
  if Assigned(PropInfo) then
    SetOrdProp(AInstance, PropInfo, Ord(AValue));
end;

procedure SetStringPropertyIfPublished(AInstance: TObject;
  const APropertyName, AValue: string);
var
  PropInfo: PPropInfo;
begin
  if not Assigned(AInstance) then
    Exit;

  PropInfo := GetPropInfo(AInstance, APropertyName);
  if Assigned(PropInfo) then
    SetStrProp(AInstance, PropInfo, AValue);
end;

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  ApplyViewButtonClick(nil);
  ApplyOptionsButtonClick(nil);

  if not FMap.Active then
  begin
    FMap.Active := True;
    Log('Map activation requested.');
    if FMap.APIKey = '' then
      Log('Loading Google Maps API without API key.')
    else
      Log('Loading Google Maps API with API key.');
    UpdateStatus('Loading map...');
  end
  else
    Log('Map is already active.');
end;

procedure TMainForm.ApplyOptionsButtonClick(Sender: TObject);
begin
  FMap.Options.ClickableIcons := FClickableIconsCheck.Checked;
  FMap.Options.CameraControl := FCameraControlCheck.Checked;
  FMap.Options.CameraControlOptions.Position := PositionFromCombo(FCameraPositionCombo);
  FMap.Options.DisableDefaultUI := FDisableDefaultUICheck.Checked;
  FMap.Options.DisableDoubleClickZoom := FDisableDoubleClickZoomCheck.Checked;
  FMap.Options.DraggableCursor := Trim(FDraggableCursorEdit.Text);
  FMap.Options.DraggingCursor := Trim(FDraggingCursorEdit.Text);
  if FColorSchemeCombo.ItemIndex >= 0 then
    FMap.Options.ColorScheme := TGMColorScheme(FColorSchemeCombo.ItemIndex);
  if Trim(FControlSizeEdit.Text) <> '' then
    FMap.Options.ControlSize := StrToIntDef(Trim(FControlSizeEdit.Text), 0);
  FMap.Options.FullscreenControl := FFullscreenControlCheck.Checked;
  FMap.Options.FullscreenControlOptions.Position := PositionFromCombo(FFullscreenPositionCombo);
  FMap.Options.GestureHandling := TGMGestureHandling(FGestureHandlingCombo.ItemIndex);
  if Trim(FHeadingEdit.Text) <> '' then
    FMap.Options.Heading := StrToFloatDef(Trim(FHeadingEdit.Text), 0, TFormatSettings.Invariant);
  FMap.Options.HeadingInteractionEnabled := FHeadingInteractionEnabledCheck.Checked;
  FMap.Options.IsFractionalZoomEnabled := FIsFractionalZoomEnabledCheck.Checked;
  FMap.Options.KeyboardShortcuts := FKeyboardShortcutsCheck.Checked;
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
  FMap.Options.MapTypeControl := FMapTypeControlCheck.Checked;
  FMap.Options.MapTypeControlOptions.MapTypeIds := BuildMapTypeIds;
  FMap.Options.MapTypeControlOptions.Position := PositionFromCombo(FMapTypePositionCombo);
  FMap.Options.MapTypeControlOptions.Style := TGMMapTypeControlStyle(FMapTypeStyleCombo.ItemIndex);
  FMap.Options.MapTypeId := TGMMapTypeId(FMapTypeIdCombo.ItemIndex);
  if Trim(FMaxZoomEdit.Text) <> '' then
    FMap.Options.MaxZoom := StrToIntDef(Trim(FMaxZoomEdit.Text), 0);
  if Trim(FMinZoomEdit.Text) <> '' then
    FMap.Options.MinZoom := StrToIntDef(Trim(FMinZoomEdit.Text), 0);
  FMap.Options.NoClear := FNoClearCheck.Checked;
  if FRenderingTypeCombo.ItemIndex >= 0 then
    FMap.Options.RenderingType := TGMRenderingType(FRenderingTypeCombo.ItemIndex);
  if Trim(FRestrictionNorthEdit.Text) <> '' then
    FMap.Options.Restriction.LatLngBounds.North := StrToFloatDef(Trim(FRestrictionNorthEdit.Text), 0, TFormatSettings.Invariant);
  if Trim(FRestrictionSouthEdit.Text) <> '' then
    FMap.Options.Restriction.LatLngBounds.South := StrToFloatDef(Trim(FRestrictionSouthEdit.Text), 0, TFormatSettings.Invariant);
  if Trim(FRestrictionEastEdit.Text) <> '' then
    FMap.Options.Restriction.LatLngBounds.East := StrToFloatDef(Trim(FRestrictionEastEdit.Text), 0, TFormatSettings.Invariant);
  if Trim(FRestrictionWestEdit.Text) <> '' then
    FMap.Options.Restriction.LatLngBounds.West := StrToFloatDef(Trim(FRestrictionWestEdit.Text), 0, TFormatSettings.Invariant);
  FMap.Options.Restriction.StrictBounds := FRestrictionStrictBoundsCheck.Checked;
  FMap.Options.RotateControl := FRotateControlCheck.Checked;
  FMap.Options.RotateControlOptions.Position := PositionFromCombo(FRotatePositionCombo);
  FMap.Options.ScaleControl := FScaleControlCheck.Checked;
  FMap.Options.ScaleControlOptions.Style := scsDefault;
  FMap.Options.Scrollwheel := FScrollwheelCheck.Checked;
  FMap.Options.StreetViewControl := FStreetViewControlCheck.Checked;
  FMap.Options.StreetViewControlOptions.Position := PositionFromCombo(FStreetViewPositionCombo);
  if Trim(FTiltEdit.Text) <> '' then
    FMap.Options.Tilt := StrToIntDef(Trim(FTiltEdit.Text), 0);
  FMap.Options.TiltInteractionEnabled := FTiltInteractionEnabledCheck.Checked;
  FMap.Options.ZoomControl := FZoomControlCheck.Checked;
  FMap.Options.ZoomControlOptions.Position := PositionFromCombo(FZoomPositionCombo);
  Log('Map options applied.');
end;

procedure TMainForm.ApplyViewButtonClick(Sender: TObject);
var
  coordinate: TGMLibLatLng;
  latitude: Double;
  longitude: Double;
  zoomLevel: Integer;
begin
  if not TryStrToFloat(Trim(FCenterLatEdit.Text), latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(FCenterLngEdit.Text), longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  if not TryStrToInt(Trim(FZoomEdit.Text), zoomLevel) then
  begin
    Log('Invalid zoom value.');
    Exit;
  end;

  coordinate := TGMLibLatLng.Create(latitude, longitude);
  try
    FMap.Options.Center := coordinate;
  finally
    coordinate.Free;
  end;

  FMap.Options.Zoom := zoomLevel;
  Log(Format('View applied. Center=(%s, %s) Zoom=%d', [
    FloatToStr(latitude, TFormatSettings.Invariant),
    FloatToStr(longitude, TFormatSettings.Invariant),
    zoomLevel
  ]));
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Log('WebView created.')
  else
    Log(Format('WebView creation failed. HRESULT=0x%.8x', [Cardinal(AResult)]));
end;

function TMainForm.BuildMapTypeIds: TGMMapTypeIds;
begin
  Result := [];
  if FMapTypeRoadmapCheck.Checked then Include(Result, mtRoadmap);
  if FMapTypeSatelliteCheck.Checked then Include(Result, mtSatellite);
  if FMapTypeHybridCheck.Checked then Include(Result, mtHybrid);
  if FMapTypeTerrainCheck.Checked then Include(Result, mtTerrain);
end;

procedure TMainForm.BuildLayout;
var
  y: Integer;
  groupBox: TGroupBox;
begin
  Caption := 'GMLib VCL Map Options Lab';
  Width := 1380;
  Height := 980;
  Position := poScreenCenter;
  Font.Name := 'Segoe UI';
  Font.Height := -12;

  FTopPanel := TPanel.Create(Self);
  FTopPanel.Parent := Self;
  FTopPanel.Align := alTop;
  FTopPanel.Height := 78;
  FTopPanel.BevelOuter := bvNone;

  CreateEdit(FTopPanel, 'API key', '', 16, 28, 420, FAPIKeyEdit);
  CreateEdit(FTopPanel, 'Latitude', '41.3874', 456, 28, 90, FCenterLatEdit);
  CreateEdit(FTopPanel, 'Longitude', '2.1686', 562, 28, 90, FCenterLngEdit);
  CreateEdit(FTopPanel, 'Zoom', '12', 668, 28, 60, FZoomEdit);

  FApplyViewButton := TButton.Create(Self);
  FApplyViewButton.Parent := FTopPanel;
  FApplyViewButton.Left := 748;
  FApplyViewButton.Top := 26;
  FApplyViewButton.Width := 100;
  FApplyViewButton.Caption := 'Apply view';
  FApplyViewButton.OnClick := ApplyViewButtonClick;

  FApplyOptionsButton := TButton.Create(Self);
  FApplyOptionsButton.Parent := FTopPanel;
  FApplyOptionsButton.Left := 860;
  FApplyOptionsButton.Top := 26;
  FApplyOptionsButton.Width := 120;
  FApplyOptionsButton.Caption := 'Apply options';
  FApplyOptionsButton.OnClick := ApplyOptionsButtonClick;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FTopPanel;
  FActivateButton.Left := 992;
  FActivateButton.Top := 26;
  FActivateButton.Width := 120;
  FActivateButton.Caption := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FTopPanel;
  FStatusLabel.Left := 1130;
  FStatusLabel.Top := 31;
  FStatusLabel.Caption := 'Ready';

  FRootPanel := TPanel.Create(Self);
  FRootPanel.Parent := Self;
  FRootPanel.Align := alClient;
  FRootPanel.BevelOuter := bvNone;

  FOptionsPanel := TScrollBox.Create(Self);
  FOptionsPanel.Parent := FRootPanel;
  FOptionsPanel.Align := alLeft;
  FOptionsPanel.Width := 320;
  FOptionsPanel.VertScrollBar.Visible := True;

  FMapPanel := TPanel.Create(Self);
  FMapPanel.Parent := FRootPanel;
  FMapPanel.Align := alClient;
  FMapPanel.BevelOuter := bvNone;

  FLogPanel := TPanel.Create(Self);
  FLogPanel.Parent := FMapPanel;
  FLogPanel.Align := alBottom;
  FLogPanel.Height := 180;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := FLogPanel;
  FLogMemo.Align := alClient;
  FLogMemo.ReadOnly := True;
  FLogMemo.ScrollBars := ssVertical;
  FLogMemo.WordWrap := False;

  FBrowser := TEdgeBrowser.Create(Self);
  FBrowser.Parent := FMapPanel;
  FBrowser.Align := alClient;
  SetBooleanPropertyIfPublished(FBrowser, 'AllowSingleSignOnUsingOSPrimaryAccount', False);
  SetStringPropertyIfPublished(FBrowser, 'TargetCompatibleBrowserVersion', '117.0.2045.28');
  SetStringPropertyIfPublished(FBrowser, 'UserDataFolder', '%LOCALAPPDATA%\bds.exe.WebView2');
  FBrowser.OnCreateWebViewCompleted := BrowserCreateWebViewCompleted;

  y := 12;
  groupBox := TGroupBox.Create(Self);
  groupBox.Parent := FOptionsPanel;
  groupBox.Left := 8;
  groupBox.Top := y;
  groupBox.Width := 290;
  groupBox.Height := 1290;
  groupBox.Caption := 'Map options';
  y := 24;
  CreateCheckBox(groupBox, 'CameraControl', y, FCameraControlCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'Camera position', y, FCameraPositionCombo); Inc(y, 52);
  CreateCheckBox(groupBox, 'ClickableIcons', y, FClickableIconsCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'ColorScheme (startup only)', y, FColorSchemeCombo); Inc(y, 52);
  CreateEdit(groupBox, 'ControlSize (startup only)', '', 12, y + 18, 250, FControlSizeEdit); Inc(y, 52);
  CreateCheckBox(groupBox, 'DisableDefaultUI', y, FDisableDefaultUICheck); Inc(y, 28);
  CreateCheckBox(groupBox, 'DisableDoubleClickZoom', y, FDisableDoubleClickZoomCheck); Inc(y, 28);
  CreateEdit(groupBox, 'DraggableCursor', '', 12, y + 18, 250, FDraggableCursorEdit); Inc(y, 52);
  CreateEdit(groupBox, 'DraggingCursor', '', 12, y + 18, 250, FDraggingCursorEdit); Inc(y, 52);
  CreateCheckBox(groupBox, 'FullscreenControl', y, FFullscreenControlCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'Fullscreen position', y, FFullscreenPositionCombo); Inc(y, 52);
  CreateComboBox(groupBox, 'GestureHandling', y, FGestureHandlingCombo); Inc(y, 52);
  CreateEdit(groupBox, 'Heading', '------', 12, y + 18, 250, FHeadingEdit); Inc(y, 52);
  CreateCheckBox(groupBox, 'HeadingInteractionEnabled', y, FHeadingInteractionEnabledCheck); Inc(y, 28);
  CreateCheckBox(groupBox, 'IsFractionalZoomEnabled', y, FIsFractionalZoomEnabledCheck); Inc(y, 28);
  CreateCheckBox(groupBox, 'KeyboardShortcuts', y, FKeyboardShortcutsCheck); Inc(y, 28);
  CreateEdit(groupBox, 'MapId (startup only)', '', 12, y + 18, 250, FMapIdEdit); Inc(y, 52);
  CreateCheckBox(groupBox, 'MapTypeControl', y, FMapTypeControlCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'MapTypeId', y, FMapTypeIdCombo); Inc(y, 52);
  CreateComboBox(groupBox, 'MapTypeControl style', y, FMapTypeStyleCombo); Inc(y, 52);
  CreateComboBox(groupBox, 'MapTypeControl position', y, FMapTypePositionCombo); Inc(y, 52);
  CreateEdit(groupBox, 'MaxZoom', '', 12, y + 18, 250, FMaxZoomEdit); Inc(y, 52);
  CreateEdit(groupBox, 'MinZoom', '', 12, y + 18, 250, FMinZoomEdit); Inc(y, 52);
  CreateCheckBox(groupBox, 'NoClear', y, FNoClearCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'RenderingType (startup only)', y, FRenderingTypeCombo); Inc(y, 52);
  CreateSectionLabel(groupBox, 'Restriction', y); Inc(y, 24);
  CreateEdit(groupBox, 'North', '', 12, y + 18, 250, FRestrictionNorthEdit); Inc(y, 52);
  CreateEdit(groupBox, 'South', '', 12, y + 18, 250, FRestrictionSouthEdit); Inc(y, 52);
  CreateEdit(groupBox, 'East', '', 12, y + 18, 250, FRestrictionEastEdit); Inc(y, 52);
  CreateEdit(groupBox, 'West', '', 12, y + 18, 250, FRestrictionWestEdit); Inc(y, 52);
  CreateCheckBox(groupBox, 'Restriction.StrictBounds', y, FRestrictionStrictBoundsCheck); Inc(y, 28);
  CreateSectionLabel(groupBox, 'MapTypeIds', y); Inc(y, 24);
  CreateCheckBox(groupBox, 'Roadmap', y, FMapTypeRoadmapCheck); Inc(y, 24);
  CreateCheckBox(groupBox, 'Satellite', y, FMapTypeSatelliteCheck); Inc(y, 24);
  CreateCheckBox(groupBox, 'Hybrid', y, FMapTypeHybridCheck); Inc(y, 24);
  CreateCheckBox(groupBox, 'Terrain', y, FMapTypeTerrainCheck); Inc(y, 28);
  CreateCheckBox(groupBox, 'Scrollwheel', y, FScrollwheelCheck); Inc(y, 28);
  CreateEdit(groupBox, 'Tilt', '', 12, y + 18, 250, FTiltEdit); Inc(y, 52);
  CreateCheckBox(groupBox, 'TiltInteractionEnabled', y, FTiltInteractionEnabledCheck);

  groupBox := TGroupBox.Create(Self);
  groupBox.Parent := FOptionsPanel;
  groupBox.Left := 8;
  groupBox.Top := 1314;
  groupBox.Width := 290;
  groupBox.Height := 240;
  groupBox.Caption := 'Visible controls';
  y := 24;
  CreateCheckBox(groupBox, 'RotateControl', y, FRotateControlCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'Rotate position', y, FRotatePositionCombo); Inc(y, 52);
  CreateCheckBox(groupBox, 'ScaleControl', y, FScaleControlCheck); Inc(y, 28);
  CreateCheckBox(groupBox, 'StreetViewControl', y, FStreetViewControlCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'StreetView position', y, FStreetViewPositionCombo); Inc(y, 52);
  CreateCheckBox(groupBox, 'ZoomControl', y, FZoomControlCheck); Inc(y, 28);
  CreateComboBox(groupBox, 'Zoom position', y, FZoomPositionCombo);
end;

procedure TMainForm.CreateCheckBox(AParent: TWinControl; const ACaption: string; ATop: Integer; out ACheckBox: TCheckBox);
begin
  ACheckBox := TCheckBox.Create(Self);
  ACheckBox.Parent := AParent;
  ACheckBox.Left := 12;
  ACheckBox.Top := ATop;
  ACheckBox.Width := 250;
  ACheckBox.Caption := ACaption;
end;

procedure TMainForm.CreateComboBox(AParent: TWinControl; const ACaption: string; ATop: Integer; out AComboBox: TComboBox);
var
  labelControl: TLabel;
begin
  labelControl := TLabel.Create(Self);
  labelControl.Parent := AParent;
  labelControl.Left := 12;
  labelControl.Top := ATop;
  labelControl.Caption := ACaption;

  AComboBox := TComboBox.Create(Self);
  AComboBox.Parent := AParent;
  AComboBox.Left := 12;
  AComboBox.Top := ATop + 18;
  AComboBox.Width := 250;
  AComboBox.Style := csDropDownList;
end;

procedure TMainForm.CreateEdit(AParent: TWinControl; const ACaption, AValue: string; ALeft, ATop, AWidth: Integer; out AEdit: TEdit);
var
  labelControl: TLabel;
begin
  labelControl := TLabel.Create(Self);
  labelControl.Parent := AParent;
  labelControl.Left := ALeft;
  labelControl.Top := 10;
  labelControl.Caption := ACaption;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := AParent;
  AEdit.Left := ALeft;
  AEdit.Top := ATop;
  AEdit.Width := AWidth;
  AEdit.Text := AValue;
end;

procedure TMainForm.HandleBoundsChanged(Sender: TObject; ABounds: TGMLatLngBounds);
begin
  Log(Format('Bounds changed: N=%s S=%s E=%s W=%s', [
    FloatToStr(ABounds.North, TFormatSettings.Invariant),
    FloatToStr(ABounds.South, TFormatSettings.Invariant),
    FloatToStr(ABounds.East, TFormatSettings.Invariant),
    FloatToStr(ABounds.West, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.CreateSectionLabel(AParent: TWinControl; const ACaption: string; ATop: Integer);
var
  labelControl: TLabel;
begin
  labelControl := TLabel.Create(Self);
  labelControl.Parent := AParent;
  labelControl.Left := 12;
  labelControl.Top := ATop;
  labelControl.Caption := ACaption;
  labelControl.Font.Style := [fsBold];
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BuildLayout;
  PopulateCombos;
  InitializeMap;
  InitializeDefaults;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;

  if Assigned(FBrowser) then
    FBrowser.CloseWebView;
  inherited;
end;

procedure TMainForm.HandleCenterChanged(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  FCenterLatEdit.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  FCenterLngEdit.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);
  Log(Format('Center changed from map: %s, %s', [FCenterLatEdit.Text, FCenterLngEdit.Text]));
end;

procedure TMainForm.HandleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Map double click at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng;
  const APlaceId: string);
begin
  Log(Format('Map context menu at %s, %s (placeId=%s)', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant),
    IfThen(APlaceId <> '', APlaceId, '<none>')
  ]));
end;

procedure TMainForm.HandleDrag(Sender: TObject);
begin
  Log('Map drag.');
end;

procedure TMainForm.HandleDragEnd(Sender: TObject);
begin
  Log('Map drag end.');
end;

procedure TMainForm.HandleDragStart(Sender: TObject);
begin
  Log('Map drag start.');
end;

procedure TMainForm.HandleIdle(Sender: TObject);
begin
  Log('Map idle.');
end;

procedure TMainForm.HandleHeadingChanged(Sender: TObject; AHeading: Double);
begin
  FHeadingEdit.Text := FloatToStr(AHeading, TFormatSettings.Invariant);
  Log(Format('Heading changed from map: %s', [
    FloatToStr(AHeading, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng;
  const APlaceId: string);
begin
  Log(Format('Map click at %s, %s (placeId=%s)', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant),
    IfThen(APlaceId <> '', APlaceId, '<none>')
  ]));
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  Log('Map ready event received.');
  UpdateStatus('Map ready');
end;

procedure TMainForm.HandleMapTypeIdChanged(Sender: TObject; AMapTypeId: TGMMapTypeId);
const
  MapTypeIdNames: array[TGMMapTypeId] of string = ('roadmap', 'satellite', 'hybrid', 'terrain');
begin
  FMapTypeIdCombo.ItemIndex := Ord(AMapTypeId);
  Log(Format('MapTypeId changed from map: %s', [MapTypeIdNames[AMapTypeId]]));
end;

procedure TMainForm.HandleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Map mouse out at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Map mouse over at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Map mouse move at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleProjectionChanged(Sender: TObject);
begin
  Log('Map projection changed.');
end;

procedure TMainForm.HandleRenderingTypeChanged(Sender: TObject;
  ARenderingType: TGMRenderingType);
const
  RenderingTypeNames: array[TGMRenderingType] of string = ('raster', 'vector');
begin
  FRenderingTypeCombo.ItemIndex := Ord(ARenderingType);
  Log(Format('RenderingType changed from map: %s', [
    RenderingTypeNames[ARenderingType]
  ]));
end;

procedure TMainForm.HandleTilesLoaded(Sender: TObject);
begin
  Log('Map tiles loaded.');
end;

procedure TMainForm.HandleTiltChanged(Sender: TObject; ATilt: Integer);
begin
  FTiltEdit.Text := IntToStr(ATilt);
  Log(Format('Tilt changed from map: %d', [ATilt]));
end;

procedure TMainForm.HandleZoomChanged(Sender: TObject; AZoom: Integer);
begin
  FZoomEdit.Text := IntToStr(AZoom);
  Log(Format('Zoom changed from map: %d', [AZoom]));
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FCameraControlCheck.Checked := False;
  FClickableIconsCheck.Checked := True;
  FColorSchemeCombo.ItemIndex := Ord(csLight);
  FControlSizeEdit.Text := '';
  FDisableDefaultUICheck.Checked := False;
  FDisableDoubleClickZoomCheck.Checked := False;
  FDraggableCursorEdit.Text := '';
  FDraggingCursorEdit.Text := '';
  FFullscreenControlCheck.Checked := True;
  FHeadingEdit.Text := '';
  FHeadingInteractionEnabledCheck.Checked := False;
  FIsFractionalZoomEnabledCheck.Checked := False;
  FKeyboardShortcutsCheck.Checked := True;
  FMapIdEdit.Text := '';
  FMapTypeControlCheck.Checked := True;
  FMaxZoomEdit.Text := '';
  FMinZoomEdit.Text := '';
  FNoClearCheck.Checked := False;
  FRenderingTypeCombo.ItemIndex := Ord(rtRaster);
  FRestrictionNorthEdit.Text := '';
  FRestrictionSouthEdit.Text := '';
  FRestrictionEastEdit.Text := '';
  FRestrictionWestEdit.Text := '';
  FRestrictionStrictBoundsCheck.Checked := False;
  FRotateControlCheck.Checked := False;
  FScaleControlCheck.Checked := False;
  FScrollwheelCheck.Checked := False;
  FStreetViewControlCheck.Checked := True;
  FTiltEdit.Text := '';
  FTiltInteractionEnabledCheck.Checked := False;
  FZoomControlCheck.Checked := True;
  FMapTypeRoadmapCheck.Checked := True;
  FMapTypeSatelliteCheck.Checked := True;
  FMapTypeHybridCheck.Checked := True;
  FMapTypeTerrainCheck.Checked := True;
  FGestureHandlingCombo.ItemIndex := Ord(ghAuto);
  FMapTypeIdCombo.ItemIndex := Ord(mtRoadmap);
  FMapTypeStyleCombo.ItemIndex := Ord(mtcsDropdownMenu);
  FCameraPositionCombo.ItemIndex := PositionToComboIndex(cpInlineStartBlockEnd);
  FFullscreenPositionCombo.ItemIndex := PositionToComboIndex(cpRightTop);
  FMapTypePositionCombo.ItemIndex := PositionToComboIndex(cpTopRight);
  FRotatePositionCombo.ItemIndex := PositionToComboIndex(cpTopLeft);
  FStreetViewPositionCombo.ItemIndex := PositionToComboIndex(cpTopLeft);
  FZoomPositionCombo.ItemIndex := PositionToComboIndex(cpLeftCenter);
  UpdateStatus('Ready');
  Log('Options lab initialized.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
  FMap.OnBoundsChanged := HandleBoundsChanged;
  FMap.OnCenterChanged := HandleCenterChanged;
  FMap.OnContextMenu := HandleContextMenu;
  FMap.OnDblClick := HandleDblClick;
  FMap.OnDrag := HandleDrag;
  FMap.OnDragEnd := HandleDragEnd;
  FMap.OnDragStart := HandleDragStart;
  FMap.OnHeadingChanged := HandleHeadingChanged;
  FMap.OnIdle := HandleIdle;
  FMap.OnMapClick := HandleMapClick;
  FMap.OnMapReady := HandleMapReady;
  FMap.OnMapTypeIdChanged := HandleMapTypeIdChanged;
  FMap.OnMouseOut := HandleMouseOut;
  FMap.OnMouseOver := HandleMouseOver;
  FMap.OnMouseMove := HandleMouseMove;
  FMap.OnProjectionChanged := HandleProjectionChanged;
  FMap.OnRenderingTypeChanged := HandleRenderingTypeChanged;
  FMap.OnTilesLoaded := HandleTilesLoaded;
  FMap.OnTiltChanged := HandleTiltChanged;
  FMap.OnZoomChanged := HandleZoomChanged;
end;

procedure TMainForm.Log(const AText: string);
begin
  while FLogMemo.Lines.Count >= 500 do
    FLogMemo.Lines.Delete(0);

  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

function TMainForm.PositionFromCombo(ACombo: TComboBox): TGMControlPosition;
begin
  Result := TGMControlPosition(NativeInt(ACombo.Items.Objects[ACombo.ItemIndex]));
end;

function TMainForm.PositionToComboIndex(AValue: TGMControlPosition): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FZoomPositionCombo.Items.Count - 1 do
  begin
    if TGMControlPosition(NativeInt(FZoomPositionCombo.Items.Objects[i])) = AValue then
      Exit(i);
  end;
end;

procedure TMainForm.PopulateCombos;
const
  PositionNames: array[0..7] of string = ('TopLeft', 'TopCenter', 'TopRight', 'LeftCenter', 'RightTop', 'RightCenter', 'BottomLeft', 'BottomRight');
  PositionValues: array[0..7] of TGMControlPosition = (cpTopLeft, cpTopCenter, cpTopRight, cpLeftCenter, cpRightTop, cpRightCenter, cpBottomLeft, cpBottomRight);

  procedure AddPositions(ACombo: TComboBox);
  begin
    for var i := Low(PositionNames) to High(PositionNames) do
      ACombo.Items.AddObject(PositionNames[i], TObject(NativeInt(PositionValues[i])));
  end;
begin
  AddPositions(FCameraPositionCombo);
  AddPositions(FFullscreenPositionCombo);
  AddPositions(FMapTypePositionCombo);
  AddPositions(FRotatePositionCombo);
  AddPositions(FStreetViewPositionCombo);
  AddPositions(FZoomPositionCombo);

  FGestureHandlingCombo.Items.Add('Auto');
  FGestureHandlingCombo.Items.Add('Cooperative');
  FGestureHandlingCombo.Items.Add('Greedy');
  FGestureHandlingCombo.Items.Add('None');

  FColorSchemeCombo.Items.Add('Light');
  FColorSchemeCombo.Items.Add('Dark');
  FColorSchemeCombo.Items.Add('FollowSystem');

  FMapTypeIdCombo.Items.Add('Roadmap');
  FMapTypeIdCombo.Items.Add('Satellite');
  FMapTypeIdCombo.Items.Add('Hybrid');
  FMapTypeIdCombo.Items.Add('Terrain');

  FMapTypeStyleCombo.Items.Add('Default');
  FMapTypeStyleCombo.Items.Add('DropdownMenu');
  FMapTypeStyleCombo.Items.Add('HorizontalBar');

  FRenderingTypeCombo.Items.Add('Raster');
  FRenderingTypeCombo.Items.Add('Vector');
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusLabel.Caption := AText;
end;

end.




