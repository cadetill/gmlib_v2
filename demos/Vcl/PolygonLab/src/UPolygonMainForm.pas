unit UPolygonMainForm;

interface

uses
  Winapi.WebView2,
  Winapi.Windows,
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Edge,
  Vcl.StdCtrls,
  uGMLib.Core.Types,
  uGMLib.Map,
  uGMLib.MapOptions,
  uGMLib.Polygon,
  uGMLib.Vcl.Map,
  uGMLib.Vcl.Polygon, Winapi.ActiveX;

type
  TMainForm = class(TForm)
    Browser: TEdgeBrowser;
    ControlPanel: TPanel;
    ApplyButton: TButton;
    ClearButton: TButton;
    ActivateButton: TButton;
    ZoomToPolygonButton: TButton;
    LogMemo: TMemo;
  private
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FApplyViewButton: TButton;
    FCenterLatEdit: TEdit;
    FCenterLatLabel: TLabel;
    FCenterLngEdit: TEdit;
    FCenterLngLabel: TLabel;
    FEditableCheck: TCheckBox;
    FDraggableCheck: TCheckBox;
    FFillColorEdit: TEdit;
    FFillColorLabel: TLabel;
    FFillOpacityEdit: TEdit;
    FFillOpacityLabel: TLabel;
    FGeodesicCheck: TCheckBox;
    FLoadSampleButton: TButton;
    FOptionsPanel: TPanel;
    FPathLabel: TLabel;
    FPathMemo: TMemo;
    FPolygonCountCaptionLabel: TLabel;
    FPolygonCountValueLabel: TLabel;
    FStatusLabel: TLabel;
    FStatusValueLabel: TLabel;
    FStrokeColorEdit: TEdit;
    FStrokeColorLabel: TLabel;
    FStrokeOpacityEdit: TEdit;
    FStrokeOpacityLabel: TLabel;
    FStrokeWeightEdit: TEdit;
    FStrokeWeightLabel: TLabel;
    FZoomEdit: TEdit;
    FZoomLabel: TLabel;
    FVisibleCheck: TCheckBox;
    FMap: TGMLibMap;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure ApplyViewButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure BuildUi;
    procedure ClearButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    function ParsePathMemo(out ALatitudes, ALongitudes: TArray<Double>): Boolean;
    procedure PopulateSamplePath;
    procedure UpdatePolygonCount;
    procedure UpdateStatus(const AText: string);
    procedure ZoomToPolygonButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

function CssToVclColor(const ACssValue: string): TColor;
var
  RgbValue: Integer;
begin
  if (Length(ACssValue) = 7) and (ACssValue[1] = '#') then
  begin
    RgbValue := StrToIntDef('$' + Copy(ACssValue, 2, 6), -1);
    if RgbValue >= 0 then
      Exit(RGB(GetBValue(RgbValue), GetGValue(RgbValue), GetRValue(RgbValue)));
  end;

  Result := clNone;
end;

function TryParseCoordinateLine(const ALine: string; out ALatitude, ALongitude: Double): Boolean;
var
  Line: string;
  Parts: TArray<string>;
begin
  Line := Trim(ALine);
  Result := False;
  if Line = '' then
    Exit;

  Parts := SplitString(Line, ',');
  if Length(Parts) <> 2 then
    Exit;

  Result :=
    TryStrToFloat(Trim(Parts[0]), ALatitude, TFormatSettings.Invariant) and
    TryStrToFloat(Trim(Parts[1]), ALongitude, TFormatSettings.Invariant);
end;

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  Log('ActivateButtonClick start');
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  ApplyViewButtonClick(nil);

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

procedure TMainForm.ApplyButtonClick(Sender: TObject);
var
  ALatitudes: TArray<Double>;
  ALongitudes: TArray<Double>;
  FillOpacity: Double;
  StrokeOpacity: Double;
  StrokeWeight: Integer;
  i: Integer;
  Polygon: TGMVclPolygonItem;
begin
  if not ParsePathMemo(ALatitudes, ALongitudes) then
    Exit;

  if not TryStrToFloat(Trim(FFillOpacityEdit.Text), FillOpacity, TFormatSettings.Invariant) then
  begin
    Log('Invalid fill opacity value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(FStrokeOpacityEdit.Text), StrokeOpacity, TFormatSettings.Invariant) then
  begin
    Log('Invalid stroke opacity value.');
    Exit;
  end;

  if not TryStrToInt(Trim(FStrokeWeightEdit.Text), StrokeWeight) then
  begin
    Log('Invalid stroke weight value.');
    Exit;
  end;

  if not FMap.Active then
  begin
    Log('Map not active. Click Activate first.');
    Exit;
  end;

  FMap.Polygons.BeginUpdate;
  try
    if FMap.Polygons.Count = 0 then
      Polygon := FMap.Polygons.Add
    else
      Polygon := TGMVclPolygonItem(FMap.Polygons[0]);

    Polygon.Options.Path.Clear;
    for i := 0 to High(ALatitudes) do
      Polygon.Options.Path.Add(ALatitudes[i], ALongitudes[i]);

    Polygon.Options.Visible := FVisibleCheck.Checked;
    Polygon.Options.Editable := FEditableCheck.Checked;
    Polygon.Options.Draggable := FDraggableCheck.Checked;
    Polygon.Options.Geodesic := FGeodesicCheck.Checked;
    Polygon.Options.FillColor := CssToVclColor(Trim(FFillColorEdit.Text));
    Polygon.Options.FillOpacity := FillOpacity;
    Polygon.Options.StrokeColor := CssToVclColor(Trim(FStrokeColorEdit.Text));
    Polygon.Options.StrokeOpacity := StrokeOpacity;
    Polygon.Options.StrokeWeight := StrokeWeight;
  finally
    FMap.Polygons.EndUpdate;
  end;

  UpdatePolygonCount;
  Log(Format('Polygon applied with %d point(s).', [Length(ALatitudes)]));
end;

procedure TMainForm.ApplyViewButtonClick(Sender: TObject);
var
  Center: TGMLibLatLng;
  Latitude: Double;
  Longitude: Double;
  ZoomLevel: Integer;
begin
  if not TryStrToFloat(Trim(FCenterLatEdit.Text), Latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(FCenterLngEdit.Text), Longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  if not TryStrToInt(Trim(FZoomEdit.Text), ZoomLevel) then
  begin
    Log('Invalid zoom value.');
    Exit;
  end;

  Center := TGMLibLatLng.Create(Latitude, Longitude);
  try
    FMap.Options.Center := Center;
  finally
    Center.Free;
  end;

  FMap.Options.Zoom := ZoomLevel;
  Log(Format('View applied. Center=(%s, %s) Zoom=%d', [
    FloatToStr(Latitude, TFormatSettings.Invariant),
    FloatToStr(Longitude, TFormatSettings.Invariant),
    ZoomLevel
  ]));
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser;
  AResult: HRESULT);
begin
  Log('WebView created');
end;

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib VCL Polygon Lab';
  Width := 1420;
  Height := 920;

  Browser.Parent := Self;
  Browser.Align := alClient;

  ControlPanel.Parent := Self;
  ControlPanel.Align := alTop;
  ControlPanel.Caption := '';
  ControlPanel.Height := 156;
  ControlPanel.BevelOuter := bvNone;

  LogMemo.Parent := Self;
  LogMemo.Align := alBottom;
  LogMemo.Height := 220;
  LogMemo.ReadOnly := True;
  LogMemo.ScrollBars := ssBoth;
  LogMemo.WordWrap := False;

  FOptionsPanel := TPanel.Create(Self);
  FOptionsPanel.Parent := Self;
  FOptionsPanel.Align := alLeft;
  FOptionsPanel.Width := 380;
  FOptionsPanel.BevelOuter := bvNone;
  FOptionsPanel.Padding.Left := 12;
  FOptionsPanel.Padding.Top := 8;
  FOptionsPanel.Padding.Right := 8;
  FOptionsPanel.Padding.Bottom := 8;

  FAPIKeyLabel := TLabel.Create(Self);
  FAPIKeyLabel.Parent := ControlPanel;
  FAPIKeyLabel.Left := 4;
  FAPIKeyLabel.Top := 4;
  FAPIKeyLabel.Caption := 'API key';

  FAPIKeyEdit := TEdit.Create(Self);
  FAPIKeyEdit.Parent := ControlPanel;
  FAPIKeyEdit.Left := 4;
  FAPIKeyEdit.Top := 24;
  FAPIKeyEdit.Width := 280;

  FCenterLatLabel := TLabel.Create(Self);
  FCenterLatLabel.Parent := ControlPanel;
  FCenterLatLabel.Left := 302;
  FCenterLatLabel.Top := 4;
  FCenterLatLabel.Caption := 'Latitude';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := ControlPanel;
  FCenterLatEdit.Left := 302;
  FCenterLatEdit.Top := 24;
  FCenterLatEdit.Width := 90;

  FCenterLngLabel := TLabel.Create(Self);
  FCenterLngLabel.Parent := ControlPanel;
  FCenterLngLabel.Left := 408;
  FCenterLngLabel.Top := 4;
  FCenterLngLabel.Caption := 'Longitude';

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := ControlPanel;
  FCenterLngEdit.Left := 408;
  FCenterLngEdit.Top := 24;
  FCenterLngEdit.Width := 90;

  FZoomLabel := TLabel.Create(Self);
  FZoomLabel.Parent := ControlPanel;
  FZoomLabel.Left := 514;
  FZoomLabel.Top := 4;
  FZoomLabel.Caption := 'Zoom';

  FZoomEdit := TEdit.Create(Self);
  FZoomEdit.Parent := ControlPanel;
  FZoomEdit.Left := 514;
  FZoomEdit.Top := 24;
  FZoomEdit.Width := 60;

  FApplyViewButton := TButton.Create(Self);
  FApplyViewButton.Parent := ControlPanel;
  FApplyViewButton.Left := 592;
  FApplyViewButton.Top := 22;
  FApplyViewButton.Width := 100;
  FApplyViewButton.Caption := 'Apply view';
  FApplyViewButton.OnClick := ApplyViewButtonClick;

  ActivateButton.Parent := ControlPanel;
  ActivateButton.Left := 706;
  ActivateButton.Top := 22;
  ActivateButton.Width := 110;
  ActivateButton.Caption := 'Activate map';
  ActivateButton.OnClick := ActivateButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := ControlPanel;
  FLoadSampleButton.Left := 830;
  FLoadSampleButton.Top := 22;
  FLoadSampleButton.Width := 110;
  FLoadSampleButton.Caption := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  ApplyButton.Parent := ControlPanel;
  ApplyButton.Left := 954;
  ApplyButton.Top := 22;
  ApplyButton.Width := 120;
  ApplyButton.Caption := 'Apply polygon';
  ApplyButton.OnClick := ApplyButtonClick;

  ZoomToPolygonButton.Parent := ControlPanel;
  ZoomToPolygonButton.Left := 1088;
  ZoomToPolygonButton.Top := 22;
  ZoomToPolygonButton.Width := 126;
  ZoomToPolygonButton.Caption := 'Zoom to polygon';
  ZoomToPolygonButton.OnClick := ZoomToPolygonButtonClick;

  ClearButton.Parent := ControlPanel;
  ClearButton.Left := 1232;
  ClearButton.Top := 22;
  ClearButton.Width := 110;
  ClearButton.Caption := 'Clear polygons';
  ClearButton.OnClick := ClearButtonClick;

  FPolygonCountCaptionLabel := TLabel.Create(Self);
  FPolygonCountCaptionLabel.Parent := ControlPanel;
  FPolygonCountCaptionLabel.Left := 4;
  FPolygonCountCaptionLabel.Top := 62;
  FPolygonCountCaptionLabel.Caption := 'Polygons';

  FPolygonCountValueLabel := TLabel.Create(Self);
  FPolygonCountValueLabel.Parent := ControlPanel;
  FPolygonCountValueLabel.Left := 70;
  FPolygonCountValueLabel.Top := 62;
  FPolygonCountValueLabel.Caption := '0';

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := ControlPanel;
  FStatusLabel.Left := 520;
  FStatusLabel.Top := 62;
  FStatusLabel.Caption := 'Status';

  FStatusValueLabel := TLabel.Create(Self);
  FStatusValueLabel.Parent := ControlPanel;
  FStatusValueLabel.Left := 574;
  FStatusValueLabel.Top := 62;
  FStatusValueLabel.Caption := 'Ready';

  FVisibleCheck := TCheckBox.Create(Self);
  FVisibleCheck.Parent := ControlPanel;
  FVisibleCheck.Left := 140;
  FVisibleCheck.Top := 92;
  FVisibleCheck.Caption := 'Visible';

  FEditableCheck := TCheckBox.Create(Self);
  FEditableCheck.Parent := ControlPanel;
  FEditableCheck.Left := 220;
  FEditableCheck.Top := 92;
  FEditableCheck.Caption := 'Editable';

  FDraggableCheck := TCheckBox.Create(Self);
  FDraggableCheck.Parent := ControlPanel;
  FDraggableCheck.Left := 312;
  FDraggableCheck.Top := 92;
  FDraggableCheck.Caption := 'Draggable';

  FGeodesicCheck := TCheckBox.Create(Self);
  FGeodesicCheck.Parent := ControlPanel;
  FGeodesicCheck.Left := 416;
  FGeodesicCheck.Top := 92;
  FGeodesicCheck.Caption := 'Geodesic';

  FFillColorLabel := TLabel.Create(Self);
  FFillColorLabel.Parent := FOptionsPanel;
  FFillColorLabel.Align := alTop;
  FFillColorLabel.Caption := 'Fill color';

  FFillColorEdit := TEdit.Create(Self);
  FFillColorEdit.Parent := FOptionsPanel;
  FFillColorEdit.Align := alTop;
  FFillColorEdit.Height := 32;
  FFillColorEdit.Text := '#f59e0b';
  FFillColorEdit.Margins.Bottom := 8;

  FFillOpacityLabel := TLabel.Create(Self);
  FFillOpacityLabel.Parent := FOptionsPanel;
  FFillOpacityLabel.Align := alTop;
  FFillOpacityLabel.Caption := 'Fill opacity';

  FFillOpacityEdit := TEdit.Create(Self);
  FFillOpacityEdit.Parent := FOptionsPanel;
  FFillOpacityEdit.Align := alTop;
  FFillOpacityEdit.Height := 32;
  FFillOpacityEdit.Text := '0.35';
  FFillOpacityEdit.Margins.Bottom := 8;

  FStrokeColorLabel := TLabel.Create(Self);
  FStrokeColorLabel.Parent := FOptionsPanel;
  FStrokeColorLabel.Align := alTop;
  FStrokeColorLabel.Caption := 'Stroke color';

  FStrokeColorEdit := TEdit.Create(Self);
  FStrokeColorEdit.Parent := FOptionsPanel;
  FStrokeColorEdit.Align := alTop;
  FStrokeColorEdit.Height := 32;
  FStrokeColorEdit.Text := '#0f172a';
  FStrokeColorEdit.Margins.Bottom := 8;

  FStrokeOpacityLabel := TLabel.Create(Self);
  FStrokeOpacityLabel.Parent := FOptionsPanel;
  FStrokeOpacityLabel.Align := alTop;
  FStrokeOpacityLabel.Caption := 'Stroke opacity';

  FStrokeOpacityEdit := TEdit.Create(Self);
  FStrokeOpacityEdit.Parent := FOptionsPanel;
  FStrokeOpacityEdit.Align := alTop;
  FStrokeOpacityEdit.Height := 32;
  FStrokeOpacityEdit.Text := '0.9';
  FStrokeOpacityEdit.Margins.Bottom := 8;

  FStrokeWeightLabel := TLabel.Create(Self);
  FStrokeWeightLabel.Parent := FOptionsPanel;
  FStrokeWeightLabel.Align := alTop;
  FStrokeWeightLabel.Caption := 'Stroke weight';

  FStrokeWeightEdit := TEdit.Create(Self);
  FStrokeWeightEdit.Parent := FOptionsPanel;
  FStrokeWeightEdit.Align := alTop;
  FStrokeWeightEdit.Height := 32;
  FStrokeWeightEdit.Text := '3';
  FStrokeWeightEdit.Margins.Bottom := 8;

  FPathLabel := TLabel.Create(Self);
  FPathLabel.Parent := FOptionsPanel;
  FPathLabel.Align := alTop;
  FPathLabel.Caption := 'Path';

  FPathMemo := TMemo.Create(Self);
  FPathMemo.Parent := FOptionsPanel;
  FPathMemo.Align := alClient;
  FPathMemo.ScrollBars := ssBoth;
  FPathMemo.WordWrap := False;

  Browser.OnCreateWebViewCompleted := BrowserCreateWebViewCompleted;

  Browser.SendToBack;
  ControlPanel.BringToFront;
  FOptionsPanel.BringToFront;
  LogMemo.BringToFront;
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  FMap.Polygons.Clear;
  UpdatePolygonCount;
  Log('Polygons cleared');
end;

procedure TMainForm.ConfigureBrowser;
begin
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  BuildUi;
  ConfigureBrowser;
  InitializeMap;
  InitializeDefaults;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;

  inherited;
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
begin
  Log(Format('Map click at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  UpdateStatus('Map ready');
  UpdatePolygonCount;
  Log('Map ready event received.');
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FCenterLatEdit.Text := '41.3874';
  FCenterLngEdit.Text := '2.1686';
  FZoomEdit.Text := '7';
  FVisibleCheck.Checked := True;
  FEditableCheck.Checked := True;
  FDraggableCheck.Checked := False;
  FGeodesicCheck.Checked := False;
  FFillColorEdit.Text := '#f59e0b';
  FFillOpacityEdit.Text := '0.35';
  FStrokeColorEdit.Text := '#0f172a';
  FStrokeOpacityEdit.Text := '0.9';
  FStrokeWeightEdit.Text := '3';
  PopulateSamplePath;
  UpdateStatus('Ready');
  UpdatePolygonCount;
  Log('Polygon lab initialized.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := Browser;
  FMap.APIKey := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMap.Options.MapId := TGMMapId(GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID'));
  FMap.Options.MapTypeControl := True;
  FMap.Options.MapTypeControlOptions.Position := cpTopRight;
  FMap.Options.ZoomControl := True;
  FMap.Options.ZoomControlOptions.Position := cpLeftCenter;
  FMap.OnMapClick := HandleMapClick;
  FMap.OnMapReady := HandleMapReady;
end;

procedure TMainForm.LoadSampleButtonClick(Sender: TObject);
begin
  PopulateSamplePath;
  Log('Sample polygon path loaded into the editor.');
end;

procedure TMainForm.Log(const AText: string);
begin
  while LogMemo.Lines.Count >= 500 do
    LogMemo.Lines.Delete(0);

  LogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

function TMainForm.ParsePathMemo(out ALatitudes, ALongitudes: TArray<Double>): Boolean;
var
  i: Integer;
  Latitude: Double;
  Longitude: Double;
  Line: string;
begin
  SetLength(ALatitudes, 0);
  SetLength(ALongitudes, 0);

  for i := 0 to FPathMemo.Lines.Count - 1 do
  begin
    Line := Trim(FPathMemo.Lines[i]);
    if Line = '' then
      Continue;

    if not TryParseCoordinateLine(Line, Latitude, Longitude) then
    begin
      Log(Format('Invalid coordinate at line %d. Use "lat,lng".', [i + 1]));
      Exit(False);
    end;

    SetLength(ALatitudes, Length(ALatitudes) + 1);
    ALatitudes[High(ALatitudes)] := Latitude;
    SetLength(ALongitudes, Length(ALongitudes) + 1);
    ALongitudes[High(ALongitudes)] := Longitude;
  end;

  if Length(ALatitudes) < 3 then
  begin
    Log('The polygon needs at least 3 points.');
    Exit(False);
  end;

  Result := True;
end;

procedure TMainForm.PopulateSamplePath;
begin
  FPathMemo.Lines.BeginUpdate;
  try
    FPathMemo.Lines.Text :=
      '41.3928,2.1548' + sLineBreak +
      '41.3928,2.1812' + sLineBreak +
      '41.3782,2.1812' + sLineBreak +
      '41.3782,2.1548';
  finally
    FPathMemo.Lines.EndUpdate;
  end;
end;

procedure TMainForm.UpdatePolygonCount;
begin
  FPolygonCountValueLabel.Caption := IntToStr(FMap.Polygons.Count);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusValueLabel.Caption := AText;
end;

procedure TMainForm.ZoomToPolygonButtonClick(Sender: TObject);
begin
  if FMap.Polygons.Count = 0 then
  begin
    Log('There is no polygon to zoom.');
    Exit;
  end;

  FMap.Polygons.ZoomToPoints(True);
  Log('ZoomToPoints requested for visible polygons.');
end;

end.
