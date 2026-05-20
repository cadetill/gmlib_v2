unit UPolygonMainForm;

interface

uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.Types,
  FMX.WebBrowser,
  uGMLib.Core.Types,
  uGMLib.Polygon,
  uGMLib.Fmx.Map,
  uGMLib.Fmx.Polygon, FMX.ScrollBox;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FApplyPolygonButton: TButton;
    FApplyViewButton: TButton;
    FBrowser: TWebBrowser;
    FCenterLatEdit: TEdit;
    FCenterLatLabel: TLabel;
    FCenterLngEdit: TEdit;
    FCenterLngLabel: TLabel;
    FClearPolygonButton: TButton;
    FControlLayout: TLayout;
    FEditableCheck: TCheckBox;
    FDraggableCheck: TCheckBox;
    FFillColorEdit: TEdit;
    FFillOpacityEdit: TEdit;
    FGeodesicCheck: TCheckBox;
    FLoadSampleButton: TButton;
    FLogLayout: TLayout;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FStatusLabel: TLabel;
    FStatusValueLabel: TLabel;
    FPathLabel: TLabel;
    FPathLayout: TLayout;
    FPathMemo: TMemo;
    FPolygonCountCaptionLabel: TLabel;
    FPolygonCountValueLabel: TLabel;
    FPolygonOptionsLayout: TLayout;
    FPrimaryPolygon: TGMFmxPolygonItem;
    FStrokeColorEdit: TEdit;
    FStrokeOpacityEdit: TEdit;
    FStrokeWeightEdit: TEdit;
    FVisibleCheck: TCheckBox;
    FUpdatingPathMemo: Boolean;
    FZoomEdit: TEdit;
    FZoomLabel: TLabel;
    FZoomToPolygonButton: TButton;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyPolygonButtonClick(Sender: TObject);
    procedure ApplyViewButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ClearPolygonButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure EnsurePrimaryPolygon;
    procedure HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandlePolygonClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonContextMenu(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonDrag(Sender: TObject);
    procedure HandlePolygonDragEnd(Sender: TObject);
    procedure HandlePolygonDragStart(Sender: TObject);
    procedure HandlePolygonMouseDown(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonMouseOut(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonMouseOver(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonMouseUp(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonPathChanged(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    function ParsePathMemo(out ALatitudes, ALongitudes: TArray<Double>): Boolean;
    procedure PopulateSamplePath;
    procedure RebindPrimaryPolygon;
    procedure UpdatePathMemoFromPolygon;
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

{$R *.fmx}
{$HINTS OFF}

function CssToAlphaColor(const ACssValue: string): TAlphaColor;
var
  RgbValue: Integer;
begin
  if (Length(ACssValue) = 7) and (ACssValue[1] = '#') then
  begin
    RgbValue := StrToIntDef('$' + Copy(ACssValue, 2, 6), -1);
    if RgbValue >= 0 then
      Exit($FF000000 or Cardinal(RgbValue));
  end;

  Result := 0;
end;

function TryParseCoordinateLine(const ALine: string; out ALatitude, ALongitude: Double): Boolean;
var
  Line: string;
  Parts: TStringDynArray;
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

procedure TMainForm.ApplyPolygonButtonClick(Sender: TObject);
var
  ALatitudes: TArray<Double>;
  ALongitudes: TArray<Double>;
  FillOpacity: Double;
  StrokeOpacity: Double;
  StrokeWeight: Integer;
  i: Integer;
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

  EnsurePrimaryPolygon;
  FMap.Polygons.BeginUpdate;
  try
    FPrimaryPolygon.Options.Path.Clear;
    for i := 0 to High(ALatitudes) do
      FPrimaryPolygon.Options.Path.Add(ALatitudes[i], ALongitudes[i]);

    FPrimaryPolygon.Options.Visible := FVisibleCheck.IsChecked;
    FPrimaryPolygon.Options.Editable := FEditableCheck.IsChecked;
    FPrimaryPolygon.Options.Draggable := FDraggableCheck.IsChecked;
    FPrimaryPolygon.Options.Geodesic := FGeodesicCheck.IsChecked;
    FPrimaryPolygon.Options.FillColor := CssToAlphaColor(Trim(FFillColorEdit.Text));
    FPrimaryPolygon.Options.FillOpacity := FillOpacity;
    FPrimaryPolygon.Options.StrokeColor := CssToAlphaColor(Trim(FStrokeColorEdit.Text));
    FPrimaryPolygon.Options.StrokeOpacity := StrokeOpacity;
    FPrimaryPolygon.Options.StrokeWeight := StrokeWeight;
  finally
    FMap.Polygons.EndUpdate;
  end;

  UpdatePolygonCount;
  Log(Format('Polygon applied with %d point(s).', [Length(ALatitudes)]));
end;

procedure TMainForm.ApplyViewButtonClick(Sender: TObject);
var
  Center: TMapLibLatLng;
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

  Center := TMapLibLatLng.Create(Latitude, Longitude);
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

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Polygon Lab';
  Width := 1420;
  Height := 920;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 156;
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
  FAPIKeyEdit.Width := 280;

  FCenterLatLabel := TLabel.Create(Self);
  FCenterLatLabel.Parent := FControlLayout;
  FCenterLatLabel.Position.X := 302;
  FCenterLatLabel.Position.Y := 4;
  FCenterLatLabel.Text := 'Latitude';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := FControlLayout;
  FCenterLatEdit.Position.X := 302;
  FCenterLatEdit.Position.Y := 28;
  FCenterLatEdit.Width := 90;

  FCenterLngLabel := TLabel.Create(Self);
  FCenterLngLabel.Parent := FControlLayout;
  FCenterLngLabel.Position.X := 408;
  FCenterLngLabel.Position.Y := 4;
  FCenterLngLabel.Text := 'Longitude';

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := FControlLayout;
  FCenterLngEdit.Position.X := 408;
  FCenterLngEdit.Position.Y := 28;
  FCenterLngEdit.Width := 90;

  FZoomLabel := TLabel.Create(Self);
  FZoomLabel.Parent := FControlLayout;
  FZoomLabel.Position.X := 514;
  FZoomLabel.Position.Y := 4;
  FZoomLabel.Text := 'Zoom';

  FZoomEdit := TEdit.Create(Self);
  FZoomEdit.Parent := FControlLayout;
  FZoomEdit.Position.X := 514;
  FZoomEdit.Position.Y := 28;
  FZoomEdit.Width := 60;

  FApplyViewButton := TButton.Create(Self);
  FApplyViewButton.Parent := FControlLayout;
  FApplyViewButton.Position.X := 592;
  FApplyViewButton.Position.Y := 26;
  FApplyViewButton.Width := 100;
  FApplyViewButton.Text := 'Apply view';
  FApplyViewButton.OnClick := ApplyViewButtonClick;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 706;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 110;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FControlLayout;
  FLoadSampleButton.Position.X := 830;
  FLoadSampleButton.Position.Y := 26;
  FLoadSampleButton.Width := 110;
  FLoadSampleButton.Text := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  FApplyPolygonButton := TButton.Create(Self);
  FApplyPolygonButton.Parent := FControlLayout;
  FApplyPolygonButton.Position.X := 954;
  FApplyPolygonButton.Position.Y := 26;
  FApplyPolygonButton.Width := 120;
  FApplyPolygonButton.Text := 'Apply polygon';
  FApplyPolygonButton.OnClick := ApplyPolygonButtonClick;

  FZoomToPolygonButton := TButton.Create(Self);
  FZoomToPolygonButton.Parent := FControlLayout;
  FZoomToPolygonButton.Position.X := 1088;
  FZoomToPolygonButton.Position.Y := 26;
  FZoomToPolygonButton.Width := 126;
  FZoomToPolygonButton.Text := 'Zoom to polygon';
  FZoomToPolygonButton.OnClick := ZoomToPolygonButtonClick;

  FClearPolygonButton := TButton.Create(Self);
  FClearPolygonButton.Parent := FControlLayout;
  FClearPolygonButton.Position.X := 1232;
  FClearPolygonButton.Position.Y := 26;
  FClearPolygonButton.Width := 110;
  FClearPolygonButton.Text := 'Clear polygons';
  FClearPolygonButton.OnClick := ClearPolygonButtonClick;

  FPolygonCountCaptionLabel := TLabel.Create(Self);
  FPolygonCountCaptionLabel.Parent := FControlLayout;
  FPolygonCountCaptionLabel.Position.X := 4;
  FPolygonCountCaptionLabel.Position.Y := 62;
  FPolygonCountCaptionLabel.Text := 'Polygons';

  FPolygonCountValueLabel := TLabel.Create(Self);
  FPolygonCountValueLabel.Parent := FControlLayout;
  FPolygonCountValueLabel.Position.X := 70;
  FPolygonCountValueLabel.Position.Y := 62;
  FPolygonCountValueLabel.Text := '0';

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlLayout;
  FStatusLabel.Position.X := 520;
  FStatusLabel.Position.Y := 62;
  FStatusLabel.Text := 'Status';

  FStatusValueLabel := TLabel.Create(Self);
  FStatusValueLabel.Parent := FControlLayout;
  FStatusValueLabel.Position.X := 574;
  FStatusValueLabel.Position.Y := 62;
  FStatusValueLabel.Text := 'Ready';

  FVisibleCheck := TCheckBox.Create(Self);
  FVisibleCheck.Parent := FControlLayout;
  FVisibleCheck.Position.X := 140;
  FVisibleCheck.Position.Y := 92;
  FVisibleCheck.Text := 'Visible';

  FEditableCheck := TCheckBox.Create(Self);
  FEditableCheck.Parent := FControlLayout;
  FEditableCheck.Position.X := 220;
  FEditableCheck.Position.Y := 92;
  FEditableCheck.Text := 'Editable';

  FDraggableCheck := TCheckBox.Create(Self);
  FDraggableCheck.Parent := FControlLayout;
  FDraggableCheck.Position.X := 312;
  FDraggableCheck.Position.Y := 92;
  FDraggableCheck.Text := 'Draggable';

  FGeodesicCheck := TCheckBox.Create(Self);
  FGeodesicCheck.Parent := FControlLayout;
  FGeodesicCheck.Position.X := 416;
  FGeodesicCheck.Position.Y := 92;
  FGeodesicCheck.Text := 'Geodesic';

  FPolygonOptionsLayout := TLayout.Create(Self);
  FPolygonOptionsLayout.Parent := Self;
  FPolygonOptionsLayout.Align := TAlignLayout.Left;
  FPolygonOptionsLayout.Width := 380;
  FPolygonOptionsLayout.Padding.Left := 12;
  FPolygonOptionsLayout.Padding.Top := 8;
  FPolygonOptionsLayout.Padding.Right := 8;
  FPolygonOptionsLayout.Padding.Bottom := 8;

  FFillColorEdit := TEdit.Create(Self);
  FFillColorEdit.Parent := FPolygonOptionsLayout;
  FFillColorEdit.Align := TAlignLayout.Top;
  FFillColorEdit.Height := 34;
  FFillColorEdit.Text := '#f59e0b';
  FFillColorEdit.Margins.Bottom := 8;

  FFillOpacityEdit := TEdit.Create(Self);
  FFillOpacityEdit.Parent := FPolygonOptionsLayout;
  FFillOpacityEdit.Align := TAlignLayout.Top;
  FFillOpacityEdit.Height := 34;
  FFillOpacityEdit.Text := '0.35';
  FFillOpacityEdit.Margins.Bottom := 8;

  FStrokeColorEdit := TEdit.Create(Self);
  FStrokeColorEdit.Parent := FPolygonOptionsLayout;
  FStrokeColorEdit.Align := TAlignLayout.Top;
  FStrokeColorEdit.Height := 34;
  FStrokeColorEdit.Text := '#0f172a';
  FStrokeColorEdit.Margins.Bottom := 8;

  FStrokeOpacityEdit := TEdit.Create(Self);
  FStrokeOpacityEdit.Parent := FPolygonOptionsLayout;
  FStrokeOpacityEdit.Align := TAlignLayout.Top;
  FStrokeOpacityEdit.Height := 34;
  FStrokeOpacityEdit.Text := '0.9';
  FStrokeOpacityEdit.Margins.Bottom := 8;

  FStrokeWeightEdit := TEdit.Create(Self);
  FStrokeWeightEdit.Parent := FPolygonOptionsLayout;
  FStrokeWeightEdit.Align := TAlignLayout.Top;
  FStrokeWeightEdit.Height := 34;
  FStrokeWeightEdit.Text := '3';
  FStrokeWeightEdit.Margins.Bottom := 8;

  FPathLabel := TLabel.Create(Self);
  FPathLabel.Parent := FPolygonOptionsLayout;
  FPathLabel.Align := TAlignLayout.Top;
  FPathLabel.Text := 'Path';

  FPathLayout := TLayout.Create(Self);
  FPathLayout.Parent := FPolygonOptionsLayout;
  FPathLayout.Align := TAlignLayout.Client;
  FPathLayout.Padding.Top := 6;

  FPathMemo := TMemo.Create(Self);
  FPathMemo.Parent := FPathLayout;
  FPathMemo.Align := TAlignLayout.Client;
  FPathMemo.WordWrap := False;
  FPathMemo.ShowScrollBars := True;

  FLogLayout := TLayout.Create(Self);
  FLogLayout.Parent := Self;
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
  FBrowser.Parent := Self;
  FBrowser.Align := TAlignLayout.Client;
end;

procedure TMainForm.ClearPolygonButtonClick(Sender: TObject);
begin
  FMap.Polygons.Clear;
  FPrimaryPolygon := nil;
  UpdatePolygonCount;
  Log('All polygons cleared.');
end;

procedure TMainForm.ConfigureBrowser;
begin
  {$IFDEF MSWINDOWS}
  FBrowser.WindowsEngine := TWindowsEngine.EdgeOnly;
  {$ENDIF}
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

procedure TMainForm.EnsurePrimaryPolygon;
begin
  if Assigned(FPrimaryPolygon) and (FPrimaryPolygon.Collection = FMap.Polygons) then
    Exit;

  if FMap.Polygons.Count = 0 then
    FPrimaryPolygon := FMap.Polygons.Add
  else
    FPrimaryPolygon := FMap.Polygons[0];

  if Assigned(FPrimaryPolygon) then
  begin
    FPrimaryPolygon.OnClick := HandlePolygonClick;
    FPrimaryPolygon.OnContextMenu := HandlePolygonContextMenu;
    FPrimaryPolygon.OnDblClick := HandlePolygonDblClick;
    FPrimaryPolygon.OnDrag := HandlePolygonDrag;
    FPrimaryPolygon.OnDragEnd := HandlePolygonDragEnd;
    FPrimaryPolygon.OnDragStart := HandlePolygonDragStart;
    FPrimaryPolygon.OnMouseDown := HandlePolygonMouseDown;
    FPrimaryPolygon.OnMouseMove := HandlePolygonMouseMove;
    FPrimaryPolygon.OnMouseOut := HandlePolygonMouseOut;
    FPrimaryPolygon.OnMouseOver := HandlePolygonMouseOver;
    FPrimaryPolygon.OnMouseUp := HandlePolygonMouseUp;
    FPrimaryPolygon.OnPathChanged := HandlePolygonPathChanged;
  end;
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
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

procedure TMainForm.HandlePolygonClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon click at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonContextMenu(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon context menu at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon double click at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonDrag(Sender: TObject);
begin
  Log('Polygon dragging.');
end;

procedure TMainForm.HandlePolygonDragEnd(Sender: TObject);
begin
  Log('Polygon drag end.');
end;

procedure TMainForm.HandlePolygonDragStart(Sender: TObject);
begin
  Log('Polygon drag start.');
end;

procedure TMainForm.HandlePolygonMouseDown(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon mouse down at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon mouse move at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonMouseOut(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon mouse out at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonMouseOver(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon mouse over at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonMouseUp(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Polygon mouse up at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolygonPathChanged(Sender: TObject);
begin
  RebindPrimaryPolygon;
  UpdatePathMemoFromPolygon;
  UpdatePolygonCount;
  Log('Polygon path changed from map.');
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FCenterLatEdit.Text := '41.3874';
  FCenterLngEdit.Text := '2.1686';
  FZoomEdit.Text := '7';
  FVisibleCheck.IsChecked := True;
  FEditableCheck.IsChecked := True;
  FDraggableCheck.IsChecked := False;
  FGeodesicCheck.IsChecked := False;
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
  FMap.Browser := FBrowser;
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
  while FLogMemo.Lines.Count >= 500 do
    FLogMemo.Lines.Delete(0);

  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
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

procedure TMainForm.RebindPrimaryPolygon;
begin
  if FMap.Polygons.Count = 0 then
    FPrimaryPolygon := nil
  else
    FPrimaryPolygon := FMap.Polygons[0];

  if Assigned(FPrimaryPolygon) then
  begin
    FPrimaryPolygon.OnClick := HandlePolygonClick;
    FPrimaryPolygon.OnContextMenu := HandlePolygonContextMenu;
    FPrimaryPolygon.OnDblClick := HandlePolygonDblClick;
    FPrimaryPolygon.OnDrag := HandlePolygonDrag;
    FPrimaryPolygon.OnDragEnd := HandlePolygonDragEnd;
    FPrimaryPolygon.OnDragStart := HandlePolygonDragStart;
    FPrimaryPolygon.OnMouseDown := HandlePolygonMouseDown;
    FPrimaryPolygon.OnMouseMove := HandlePolygonMouseMove;
    FPrimaryPolygon.OnMouseOut := HandlePolygonMouseOut;
    FPrimaryPolygon.OnMouseOver := HandlePolygonMouseOver;
    FPrimaryPolygon.OnMouseUp := HandlePolygonMouseUp;
    FPrimaryPolygon.OnPathChanged := HandlePolygonPathChanged;
  end;
end;

procedure TMainForm.UpdatePathMemoFromPolygon;
var
  i: Integer;
begin
  if FUpdatingPathMemo or not Assigned(FPrimaryPolygon) then
    Exit;

  FUpdatingPathMemo := True;
  try
    FPathMemo.Lines.BeginUpdate;
    try
      FPathMemo.Lines.Clear;
      for i := 0 to FPrimaryPolygon.Options.Path.Count - 1 do
        FPathMemo.Lines.Add(Format('%.6f,%.6f', [
          FPrimaryPolygon.Options.Path[i].Lat,
          FPrimaryPolygon.Options.Path[i].Lng
        ], TFormatSettings.Invariant));
    finally
      FPathMemo.Lines.EndUpdate;
    end;
  finally
    FUpdatingPathMemo := False;
  end;
end;

procedure TMainForm.UpdatePolygonCount;
begin
  FPolygonCountValueLabel.Text := IntToStr(FMap.Polygons.Count);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusValueLabel.Text := AText;
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

