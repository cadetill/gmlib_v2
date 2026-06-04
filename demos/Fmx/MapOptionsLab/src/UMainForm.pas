unit UMainForm;

interface

uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.Types,
  FMX.WebBrowser,
  uGMLib.Core.Types,
  uGMLib.Fmx.Map,
  uGMLib.Google.Types,
  uGMLib.MapOptions;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FApplyOptionsButton: TButton;
    FApplyViewButton: TButton;
    FBrowser: TWebBrowser;
    FCameraControlCheck: TCheckBox;
    FCameraPositionCombo: TComboBox;
    FCenterLatEdit: TEdit;
    FCenterLatLabel: TLabel;
    FCenterLngEdit: TEdit;
    FCenterLngLabel: TLabel;
    FClickableIconsCheck: TCheckBox;
    FColorSchemeCombo: TComboBox;
    FControlLayout: TLayout;
    FControlSizeEdit: TEdit;
    FDisableDefaultUICheck: TCheckBox;
    FDisableDoubleClickZoomCheck: TCheckBox;
    FFullscreenControlCheck: TCheckBox;
    FFullscreenPositionCombo: TComboBox;
    FGestureHandlingCombo: TComboBox;
    FKeyboardShortcutsCheck: TCheckBox;
    FLastCenterLogAt: TDateTime;
    FLastCenterSignature: string;
    FLastMapTypeIdSignature: string;
    FLastZoomSignature: string;
    FLogLayout: TLayout;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapIdEdit: TEdit;
    FMapLayout: TLayout;
    FMapTypeControlCheck: TCheckBox;
    FMapTypeHybridCheck: TCheckBox;
    FMapTypeIdCombo: TComboBox;
    FMapTypePositionCombo: TComboBox;
    FMapTypeRoadmapCheck: TCheckBox;
    FMapTypeSatelliteCheck: TCheckBox;
    FMapTypeStyleCombo: TComboBox;
    FMapTypeTerrainCheck: TCheckBox;
    FOptionsScroll: TVertScrollBox;
    FRenderingTypeCombo: TComboBox;
    FRootLayout: TLayout;
    FStatusLabel: TLabel;
    FStatusValueLabel: TLabel;
    FStreetViewControlCheck: TCheckBox;
    FStreetViewPositionCombo: TComboBox;
    FZoomControlCheck: TCheckBox;
    FZoomEdit: TEdit;
    FZoomLabel: TLabel;
    FZoomPositionCombo: TComboBox;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyOptionsButtonClick(Sender: TObject);
    procedure ApplyViewButtonClick(Sender: TObject);
    function BuildMapTypeIds: TGMMapTypeIds;
    procedure BuildUi;
    procedure ConfigureBrowser;
    procedure CreateCheckBox(AParent: TFmxObject; const ACaption: string;
      var ATop: Single; out ACheckBox: TCheckBox);
    procedure CreateComboBox(AParent: TFmxObject; const ACaption: string;
      var ATop: Single; out AComboBox: TComboBox);
    procedure CreateEdit(AParent: TFmxObject; const ACaption, AValue: string;
      var ATop: Single; out AEdit: TEdit);
    procedure CreateSectionLabel(AParent: TFmxObject; const ACaption: string;
      var ATop: Single);
    procedure HandleBoundsChanged(Sender: TObject; ABounds: TGMLatLngBounds);
    procedure HandleCenterChanged(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleContextMenu(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure HandleDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleDrag(Sender: TObject);
    procedure HandleDragEnd(Sender: TObject);
    procedure HandleDragStart(Sender: TObject);
    procedure HandleHeadingChanged(Sender: TObject; AHeading: Double);
    procedure HandleIdle(Sender: TObject);
    procedure HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandleMapTypeIdChanged(Sender: TObject; AMapTypeId: TGMMapTypeId);
    procedure HandleMouseOut(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMouseOver(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleProjectionChanged(Sender: TObject);
    procedure HandleRenderingTypeChanged(Sender: TObject; ARenderingType: TGMRenderingType);
    procedure HandleTilesLoaded(Sender: TObject);
    procedure HandleTiltChanged(Sender: TObject; ATilt: Integer);
    procedure HandleZoomChanged(Sender: TObject; AZoom: Integer);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure Log(const AText: string);
    function PositionFromCombo(ACombo: TComboBox): TGMControlPosition;
    function PositionToComboIndex(AValue: TGMControlPosition): Integer;
    procedure PopulateCombos;
    procedure UpdateStatus(const AText: string);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

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
  FMap.Options.CameraControl := FCameraControlCheck.IsChecked;
  FMap.Options.CameraControlOptions.Position := PositionFromCombo(FCameraPositionCombo);
  FMap.Options.ClickableIcons := FClickableIconsCheck.IsChecked;
  if FColorSchemeCombo.ItemIndex >= 0 then
    FMap.Options.ColorScheme := TGMColorScheme(FColorSchemeCombo.ItemIndex);
  if Trim(FControlSizeEdit.Text) <> '' then
    FMap.Options.ControlSize := StrToIntDef(Trim(FControlSizeEdit.Text), 0);
  FMap.Options.DisableDefaultUI := FDisableDefaultUICheck.IsChecked;
  FMap.Options.DisableDoubleClickZoom := FDisableDoubleClickZoomCheck.IsChecked;
  FMap.Options.FullscreenControl := FFullscreenControlCheck.IsChecked;
  FMap.Options.FullscreenControlOptions.Position := PositionFromCombo(FFullscreenPositionCombo);
  FMap.Options.GestureHandling := TGMGestureHandling(FGestureHandlingCombo.ItemIndex);
  FMap.Options.KeyboardShortcuts := FKeyboardShortcutsCheck.IsChecked;
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
  FMap.Options.MapTypeControl := FMapTypeControlCheck.IsChecked;
  FMap.Options.MapTypeControlOptions.MapTypeIds := BuildMapTypeIds;
  FMap.Options.MapTypeControlOptions.Position := PositionFromCombo(FMapTypePositionCombo);
  FMap.Options.MapTypeControlOptions.Style := TGMMapTypeControlStyle(FMapTypeStyleCombo.ItemIndex);
  FMap.Options.MapTypeId := TGMMapTypeId(FMapTypeIdCombo.ItemIndex);
  if FRenderingTypeCombo.ItemIndex >= 0 then
    FMap.Options.RenderingType := TGMRenderingType(FRenderingTypeCombo.ItemIndex);
  FMap.Options.StreetViewControl := FStreetViewControlCheck.IsChecked;
  FMap.Options.StreetViewControlOptions.Position := PositionFromCombo(FStreetViewPositionCombo);
  FMap.Options.ZoomControl := FZoomControlCheck.IsChecked;
  FMap.Options.ZoomControlOptions.Position := PositionFromCombo(FZoomPositionCombo);
  Log('Map options applied.');
end;

procedure TMainForm.ApplyViewButtonClick(Sender: TObject);
var
  coordinate: TMapLibLatLng;
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

  coordinate := TMapLibLatLng.Create(latitude, longitude);
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

function TMainForm.BuildMapTypeIds: TGMMapTypeIds;
begin
  Result := [];
  if FMapTypeRoadmapCheck.IsChecked then
    Include(Result, mtRoadmap);
  if FMapTypeSatelliteCheck.IsChecked then
    Include(Result, mtSatellite);
  if FMapTypeHybridCheck.IsChecked then
    Include(Result, mtHybrid);
  if FMapTypeTerrainCheck.IsChecked then
    Include(Result, mtTerrain);
end;

procedure TMainForm.BuildUi;
var
  optionsTop: Single;
begin
  Caption := 'GMLib FMX Map Options Lab';
  Width := 1380;
  Height := 960;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 88;
  FControlLayout.Padding.Left := 12;
  FControlLayout.Padding.Top := 10;
  FControlLayout.Padding.Right := 12;
  FControlLayout.Padding.Bottom := 8;

  FAPIKeyLabel := TLabel.Create(Self);
  FAPIKeyLabel.Parent := FControlLayout;
  FAPIKeyLabel.Position.X := 4;
  FAPIKeyLabel.Position.Y := 4;
  FAPIKeyLabel.Text := 'API key';

  FAPIKeyEdit := TEdit.Create(Self);
  FAPIKeyEdit.Parent := FControlLayout;
  FAPIKeyEdit.Position.X := 4;
  FAPIKeyEdit.Position.Y := 28;
  FAPIKeyEdit.Width := 360;

  FCenterLatLabel := TLabel.Create(Self);
  FCenterLatLabel.Parent := FControlLayout;
  FCenterLatLabel.Position.X := 384;
  FCenterLatLabel.Position.Y := 4;
  FCenterLatLabel.Text := 'Latitude';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := FControlLayout;
  FCenterLatEdit.Position.X := 384;
  FCenterLatEdit.Position.Y := 28;
  FCenterLatEdit.Width := 90;

  FCenterLngLabel := TLabel.Create(Self);
  FCenterLngLabel.Parent := FControlLayout;
  FCenterLngLabel.Position.X := 490;
  FCenterLngLabel.Position.Y := 4;
  FCenterLngLabel.Text := 'Longitude';

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := FControlLayout;
  FCenterLngEdit.Position.X := 490;
  FCenterLngEdit.Position.Y := 28;
  FCenterLngEdit.Width := 90;

  FZoomLabel := TLabel.Create(Self);
  FZoomLabel.Parent := FControlLayout;
  FZoomLabel.Position.X := 596;
  FZoomLabel.Position.Y := 4;
  FZoomLabel.Text := 'Zoom';

  FZoomEdit := TEdit.Create(Self);
  FZoomEdit.Parent := FControlLayout;
  FZoomEdit.Position.X := 596;
  FZoomEdit.Position.Y := 28;
  FZoomEdit.Width := 60;

  FApplyViewButton := TButton.Create(Self);
  FApplyViewButton.Parent := FControlLayout;
  FApplyViewButton.Position.X := 676;
  FApplyViewButton.Position.Y := 26;
  FApplyViewButton.Width := 100;
  FApplyViewButton.Text := 'Apply view';
  FApplyViewButton.OnClick := ApplyViewButtonClick;

  FApplyOptionsButton := TButton.Create(Self);
  FApplyOptionsButton.Parent := FControlLayout;
  FApplyOptionsButton.Position.X := 790;
  FApplyOptionsButton.Position.Y := 26;
  FApplyOptionsButton.Width := 120;
  FApplyOptionsButton.Text := 'Apply options';
  FApplyOptionsButton.OnClick := ApplyOptionsButtonClick;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 924;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 120;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlLayout;
  FStatusLabel.Position.X := 1064;
  FStatusLabel.Position.Y := 8;
  FStatusLabel.Text := 'Status';

  FStatusValueLabel := TLabel.Create(Self);
  FStatusValueLabel.Parent := FControlLayout;
  FStatusValueLabel.Position.X := 1064;
  FStatusValueLabel.Position.Y := 30;
  FStatusValueLabel.Text := 'Ready';

  FRootLayout := TLayout.Create(Self);
  FRootLayout.Parent := Self;
  FRootLayout.Align := TAlignLayout.Client;

  FOptionsScroll := TVertScrollBox.Create(Self);
  FOptionsScroll.Parent := FRootLayout;
  FOptionsScroll.Align := TAlignLayout.Left;
  FOptionsScroll.Width := 320;
  FOptionsScroll.Padding.Left := 8;
  FOptionsScroll.Padding.Top := 8;
  FOptionsScroll.Padding.Right := 8;
  FOptionsScroll.Padding.Bottom := 8;

  FMapLayout := TLayout.Create(Self);
  FMapLayout.Parent := FRootLayout;
  FMapLayout.Align := TAlignLayout.Client;

  FLogLayout := TLayout.Create(Self);
  FLogLayout.Parent := FMapLayout;
  FLogLayout.Align := TAlignLayout.Bottom;
  FLogLayout.Height := 220;
  FLogLayout.Padding.Left := 12;
  FLogLayout.Padding.Top := 8;
  FLogLayout.Padding.Right := 12;
  FLogLayout.Padding.Bottom := 12;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := FLogLayout;
  FLogMemo.Align := TAlignLayout.Client;
  FLogMemo.ReadOnly := True;
  FLogMemo.WordWrap := False;
  FLogMemo.ShowScrollBars := True;

  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := FMapLayout;
  FBrowser.Align := TAlignLayout.Client;

  optionsTop := 8;
  CreateSectionLabel(FOptionsScroll, 'General', optionsTop);
  CreateCheckBox(FOptionsScroll, 'ClickableIcons', optionsTop, FClickableIconsCheck);
  CreateCheckBox(FOptionsScroll, 'DisableDefaultUI', optionsTop, FDisableDefaultUICheck);
  CreateCheckBox(FOptionsScroll, 'DisableDoubleClickZoom', optionsTop, FDisableDoubleClickZoomCheck);
  CreateCheckBox(FOptionsScroll, 'KeyboardShortcuts', optionsTop, FKeyboardShortcutsCheck);
  CreateComboBox(FOptionsScroll, 'GestureHandling', optionsTop, FGestureHandlingCombo);
  CreateComboBox(FOptionsScroll, 'MapTypeId', optionsTop, FMapTypeIdCombo);

  CreateSectionLabel(FOptionsScroll, 'Startup only', optionsTop);
  CreateComboBox(FOptionsScroll, 'ColorScheme', optionsTop, FColorSchemeCombo);
  CreateEdit(FOptionsScroll, 'ControlSize', '', optionsTop, FControlSizeEdit);
  CreateEdit(FOptionsScroll, 'MapId', '', optionsTop, FMapIdEdit);
  CreateComboBox(FOptionsScroll, 'RenderingType', optionsTop, FRenderingTypeCombo);

  CreateSectionLabel(FOptionsScroll, 'Controls', optionsTop);
  CreateCheckBox(FOptionsScroll, 'CameraControl', optionsTop, FCameraControlCheck);
  CreateComboBox(FOptionsScroll, 'Camera position', optionsTop, FCameraPositionCombo);
  CreateCheckBox(FOptionsScroll, 'FullscreenControl', optionsTop, FFullscreenControlCheck);
  CreateComboBox(FOptionsScroll, 'Fullscreen position', optionsTop, FFullscreenPositionCombo);
  CreateCheckBox(FOptionsScroll, 'MapTypeControl', optionsTop, FMapTypeControlCheck);
  CreateComboBox(FOptionsScroll, 'MapTypeControl style', optionsTop, FMapTypeStyleCombo);
  CreateComboBox(FOptionsScroll, 'MapTypeControl position', optionsTop, FMapTypePositionCombo);
  CreateCheckBox(FOptionsScroll, 'StreetViewControl', optionsTop, FStreetViewControlCheck);
  CreateComboBox(FOptionsScroll, 'StreetView position', optionsTop, FStreetViewPositionCombo);
  CreateCheckBox(FOptionsScroll, 'ZoomControl', optionsTop, FZoomControlCheck);
  CreateComboBox(FOptionsScroll, 'Zoom position', optionsTop, FZoomPositionCombo);

  CreateSectionLabel(FOptionsScroll, 'MapTypeIds', optionsTop);
  CreateCheckBox(FOptionsScroll, 'Roadmap', optionsTop, FMapTypeRoadmapCheck);
  CreateCheckBox(FOptionsScroll, 'Satellite', optionsTop, FMapTypeSatelliteCheck);
  CreateCheckBox(FOptionsScroll, 'Hybrid', optionsTop, FMapTypeHybridCheck);
  CreateCheckBox(FOptionsScroll, 'Terrain', optionsTop, FMapTypeTerrainCheck);
end;

procedure TMainForm.ConfigureBrowser;
begin
  {$IFDEF MSWINDOWS}
  FBrowser.WindowsEngine := TWindowsEngine.EdgeOnly;
  {$ENDIF}
end;

constructor TMainForm.CreateNew(AOwner: TComponent; Dummy: NativeInt);
begin
  inherited;
  BuildUi;
  ConfigureBrowser;
  PopulateCombos;
  InitializeMap;
  InitializeDefaults;
end;

procedure TMainForm.CreateCheckBox(AParent: TFmxObject; const ACaption: string;
  var ATop: Single; out ACheckBox: TCheckBox);
begin
  ACheckBox := TCheckBox.Create(Self);
  ACheckBox.Parent := AParent;
  ACheckBox.Position.X := 12;
  ACheckBox.Position.Y := ATop;
  ACheckBox.Width := 260;
  ACheckBox.Text := ACaption;
  ATop := ATop + 30;
end;

procedure TMainForm.CreateComboBox(AParent: TFmxObject; const ACaption: string;
  var ATop: Single; out AComboBox: TComboBox);
var
  labelControl: TLabel;
begin
  labelControl := TLabel.Create(Self);
  labelControl.Parent := AParent;
  labelControl.Position.X := 12;
  labelControl.Position.Y := ATop;
  labelControl.Text := ACaption;

  AComboBox := TComboBox.Create(Self);
  AComboBox.Parent := AParent;
  AComboBox.Position.X := 12;
  AComboBox.Position.Y := ATop + 20;
  AComboBox.Width := 270;
  ATop := ATop + 58;
end;

procedure TMainForm.CreateEdit(AParent: TFmxObject; const ACaption, AValue: string;
  var ATop: Single; out AEdit: TEdit);
var
  labelControl: TLabel;
begin
  labelControl := TLabel.Create(Self);
  labelControl.Parent := AParent;
  labelControl.Position.X := 12;
  labelControl.Position.Y := ATop;
  labelControl.Text := ACaption;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := AParent;
  AEdit.Position.X := 12;
  AEdit.Position.Y := ATop + 20;
  AEdit.Width := 270;
  AEdit.Text := AValue;
  ATop := ATop + 58;
end;

procedure TMainForm.CreateSectionLabel(AParent: TFmxObject; const ACaption: string;
  var ATop: Single);
var
  labelControl: TLabel;
begin
  labelControl := TLabel.Create(Self);
  labelControl.Parent := AParent;
  labelControl.Position.X := 12;
  labelControl.Position.Y := ATop;
  labelControl.Text := ACaption;
  ATop := ATop + 28;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;

  inherited;
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

procedure TMainForm.HandleCenterChanged(Sender: TObject; ALatLng: TMapLibLatLng);
var
  centerSignature: string;
begin
  FCenterLatEdit.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  FCenterLngEdit.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);

  centerSignature := Format('%.6f,%.6f', [ALatLng.Lat, ALatLng.Lng], TFormatSettings.Invariant);
  if (centerSignature = FLastCenterSignature) and
     ((Now - FLastCenterLogAt) < EncodeTime(0, 0, 1, 0)) then
    Exit;

  FLastCenterSignature := centerSignature;
  FLastCenterLogAt := Now;
  Log(Format('Center changed from map: %s, %s', [
    FCenterLatEdit.Text,
    FCenterLngEdit.Text
  ]));
end;

procedure TMainForm.HandleDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Map double click at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleContextMenu(Sender: TObject; ALatLng: TMapLibLatLng;
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
  Log(Format('Heading changed from map: %s', [
    FloatToStr(AHeading, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng;
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
var
  signature: string;
begin
  FMapTypeIdCombo.ItemIndex := Ord(AMapTypeId);
  signature := MapTypeIdNames[AMapTypeId];
  if signature = FLastMapTypeIdSignature then
    Exit;

  FLastMapTypeIdSignature := signature;
  Log(Format('MapTypeId changed from map: %s', [signature]));
end;

procedure TMainForm.HandleMouseOut(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Map mouse out at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMouseOver(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Map mouse over at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
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
  Log(Format('Tilt changed from map: %d', [ATilt]));
end;

procedure TMainForm.HandleZoomChanged(Sender: TObject; AZoom: Integer);
var
  zoomSignature: string;
begin
  FZoomEdit.Text := IntToStr(AZoom);
  zoomSignature := FZoomEdit.Text;
  if zoomSignature = FLastZoomSignature then
    Exit;

  FLastZoomSignature := zoomSignature;
  Log(Format('Zoom changed from map: %d', [AZoom]));
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FCenterLatEdit.Text := '41.3874';
  FCenterLngEdit.Text := '2.1686';
  FZoomEdit.Text := '12';

  FClickableIconsCheck.IsChecked := True;
  FDisableDefaultUICheck.IsChecked := False;
  FDisableDoubleClickZoomCheck.IsChecked := False;
  FKeyboardShortcutsCheck.IsChecked := True;
  FCameraControlCheck.IsChecked := False;
  FFullscreenControlCheck.IsChecked := True;
  FMapTypeControlCheck.IsChecked := True;
  FStreetViewControlCheck.IsChecked := True;
  FZoomControlCheck.IsChecked := True;
  FMapTypeRoadmapCheck.IsChecked := True;
  FMapTypeSatelliteCheck.IsChecked := True;
  FMapTypeHybridCheck.IsChecked := True;
  FMapTypeTerrainCheck.IsChecked := True;

  FGestureHandlingCombo.ItemIndex := Ord(ghAuto);
  FMapTypeIdCombo.ItemIndex := Ord(mtRoadmap);
  FMapTypeStyleCombo.ItemIndex := Ord(mtcsDropdownMenu);
  FColorSchemeCombo.ItemIndex := Ord(csLight);
  FRenderingTypeCombo.ItemIndex := Ord(rtRaster);

  FCameraPositionCombo.ItemIndex := PositionToComboIndex(cpInlineStartBlockEnd);
  FFullscreenPositionCombo.ItemIndex := PositionToComboIndex(cpRightTop);
  FMapTypePositionCombo.ItemIndex := PositionToComboIndex(cpTopRight);
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
  if ACombo.ItemIndex < 0 then
    Exit(cpTopRight);

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
  PositionNames: array[0..7] of string = (
    'TopLeft', 'TopCenter', 'TopRight', 'LeftCenter',
    'RightTop', 'RightCenter', 'BottomLeft', 'BottomRight'
  );
  PositionValues: array[0..7] of TGMControlPosition = (
    cpTopLeft, cpTopCenter, cpTopRight, cpLeftCenter,
    cpRightTop, cpRightCenter, cpBottomLeft, cpBottomRight
  );

  procedure AddPositions(ACombo: TComboBox);
  var
    i: Integer;
  begin
    for i := Low(PositionNames) to High(PositionNames) do
      ACombo.Items.AddObject(PositionNames[i], TObject(NativeInt(PositionValues[i])));
  end;
begin
  AddPositions(FCameraPositionCombo);
  AddPositions(FFullscreenPositionCombo);
  AddPositions(FMapTypePositionCombo);
  AddPositions(FStreetViewPositionCombo);
  AddPositions(FZoomPositionCombo);

  FGestureHandlingCombo.Items.Add('Auto');
  FGestureHandlingCombo.Items.Add('Cooperative');
  FGestureHandlingCombo.Items.Add('Greedy');
  FGestureHandlingCombo.Items.Add('None');

  FMapTypeIdCombo.Items.Add('Roadmap');
  FMapTypeIdCombo.Items.Add('Satellite');
  FMapTypeIdCombo.Items.Add('Hybrid');
  FMapTypeIdCombo.Items.Add('Terrain');

  FMapTypeStyleCombo.Items.Add('Default');
  FMapTypeStyleCombo.Items.Add('DropdownMenu');
  FMapTypeStyleCombo.Items.Add('HorizontalBar');

  FColorSchemeCombo.Items.Add('Light');
  FColorSchemeCombo.Items.Add('Dark');
  FColorSchemeCombo.Items.Add('FollowSystem');

  FRenderingTypeCombo.Items.Add('Raster');
  FRenderingTypeCombo.Items.Add('Vector');
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusValueLabel.Text := AText;
end;

end.

