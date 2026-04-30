unit UMainForm;

interface

uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,
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
  uGMLib.Fmx.Map,
  uGMLib.Fmx.Polyline, FMX.ScrollBox;

type
  TPolylineCoordinate = record
    Lat: Double;
    Lng: Double;
  end;

  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FApplyPolylineButton: TButton;
    FApplyViewButton: TButton;
    FBrowser: TWebBrowser;
    FCenterLatEdit: TEdit;
    FCenterLatLabel: TLabel;
    FCenterLngEdit: TEdit;
    FCenterLngLabel: TLabel;
    FClearPolylineButton: TButton;
    FControlLayout: TLayout;
    FDraggableCheck: TCheckBox;
    FEditableCheck: TCheckBox;
    FLastCenterSignature: string;
    FLastZoomSignature: string;
    FLoadSampleButton: TButton;
    FLogLayout: TLayout;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FPathMemo: TMemo;
    FPathLayout: TLayout;
    FPathLabel: TLabel;
    FPolylineCountLabel: TLabel;
    FPolylineCountValueLabel: TLabel;
    FPolylineOptionsLayout: TLayout;
    FPrimaryPolyline: TGMFmxPolylineItem;
    FStrokeColorEdit: TEdit;
    FStrokeOpacityEdit: TEdit;
    FStrokeWeightEdit: TEdit;
    FVisibleCheck: TCheckBox;
    FUpdatingPathMemo: Boolean;
    FZoomEdit: TEdit;
    FZoomLabel: TLabel;
    FZoomToPolylineButton: TButton;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyPolylineButtonClick(Sender: TObject);
    procedure ApplyViewButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ClearPolylineButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure EnsurePrimaryPolyline;
    procedure LoadSampleButtonClick(Sender: TObject);
    function ParsePathMemo(out ACoordinates: TArray<TPolylineCoordinate>): Boolean;
    procedure PopulateSamplePath;
    procedure RebindPrimaryPolyline;
    procedure HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandlePolylineClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandlePolylineDrag(Sender: TObject);
    procedure HandlePolylineDragEnd(Sender: TObject);
    procedure HandlePolylineDragStart(Sender: TObject);
    procedure HandlePolylinePathChanged(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure Log(const AText: string);
    procedure UpdatePathMemoFromPolyline;
    procedure UpdatePolylineCount;
    procedure UpdateStatus(const AText: string);
    procedure ZoomToPolylineButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.Types;

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

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
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

procedure TMainForm.ApplyPolylineButtonClick(Sender: TObject);
var
  Coordinates: TArray<TPolylineCoordinate>;
  Coordinate: TPolylineCoordinate;
  Opacity: Double;
  Weight: Integer;
begin
  if not ParsePathMemo(Coordinates) then
    Exit;

  if not TryStrToFloat(Trim(FStrokeOpacityEdit.Text), Opacity, TFormatSettings.Invariant) then
  begin
    Log('Invalid stroke opacity value.');
    Exit;
  end;

  if not TryStrToInt(Trim(FStrokeWeightEdit.Text), Weight) then
  begin
    Log('Invalid stroke weight value.');
    Exit;
  end;

  EnsurePrimaryPolyline;
  FMap.Polylines.BeginUpdate;
  try
    FPrimaryPolyline.Options.Path.Clear;
    for Coordinate in Coordinates do
      FPrimaryPolyline.Options.Path.Add(Coordinate.Lat, Coordinate.Lng);

    FPrimaryPolyline.Options.Visible := FVisibleCheck.IsChecked;
    FPrimaryPolyline.Options.Editable := FEditableCheck.IsChecked;
    FPrimaryPolyline.Options.Draggable := FDraggableCheck.IsChecked;
    FPrimaryPolyline.Options.StrokeColor := CssToAlphaColor(Trim(FStrokeColorEdit.Text));
    FPrimaryPolyline.Options.StrokeOpacity := Opacity;
    FPrimaryPolyline.Options.StrokeWeight := Weight;
  finally
    FMap.Polylines.EndUpdate;
  end;

  UpdatePolylineCount;
  Log(Format('Polyline applied with %d points.', [Length(Coordinates)]));
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

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Polyline Lab';
  Width := 1280;
  Height := 900;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 94;
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
  FAPIKeyEdit.Width := 340;

  FCenterLatLabel := TLabel.Create(Self);
  FCenterLatLabel.Parent := FControlLayout;
  FCenterLatLabel.Position.X := 360;
  FCenterLatLabel.Position.Y := 4;
  FCenterLatLabel.Text := 'Latitude';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := FControlLayout;
  FCenterLatEdit.Position.X := 360;
  FCenterLatEdit.Position.Y := 28;
  FCenterLatEdit.Width := 96;

  FCenterLngLabel := TLabel.Create(Self);
  FCenterLngLabel.Parent := FControlLayout;
  FCenterLngLabel.Position.X := 470;
  FCenterLngLabel.Position.Y := 4;
  FCenterLngLabel.Text := 'Longitude';

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := FControlLayout;
  FCenterLngEdit.Position.X := 470;
  FCenterLngEdit.Position.Y := 28;
  FCenterLngEdit.Width := 96;

  FZoomLabel := TLabel.Create(Self);
  FZoomLabel.Parent := FControlLayout;
  FZoomLabel.Position.X := 580;
  FZoomLabel.Position.Y := 4;
  FZoomLabel.Text := 'Zoom';

  FZoomEdit := TEdit.Create(Self);
  FZoomEdit.Parent := FControlLayout;
  FZoomEdit.Position.X := 580;
  FZoomEdit.Position.Y := 28;
  FZoomEdit.Width := 66;

  FApplyViewButton := TButton.Create(Self);
  FApplyViewButton.Parent := FControlLayout;
  FApplyViewButton.Position.X := 666;
  FApplyViewButton.Position.Y := 26;
  FApplyViewButton.Width := 110;
  FApplyViewButton.Text := 'Apply view';
  FApplyViewButton.OnClick := ApplyViewButtonClick;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 790;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 110;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FControlLayout;
  FLoadSampleButton.Position.X := 914;
  FLoadSampleButton.Position.Y := 26;
  FLoadSampleButton.Width := 120;
  FLoadSampleButton.Text := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  FApplyPolylineButton := TButton.Create(Self);
  FApplyPolylineButton.Parent := FControlLayout;
  FApplyPolylineButton.Position.X := 1048;
  FApplyPolylineButton.Position.Y := 26;
  FApplyPolylineButton.Width := 120;
  FApplyPolylineButton.Text := 'Apply polyline';
  FApplyPolylineButton.OnClick := ApplyPolylineButtonClick;

  FZoomToPolylineButton := TButton.Create(Self);
  FZoomToPolylineButton.Parent := FControlLayout;
  FZoomToPolylineButton.Position.X := 1182;
  FZoomToPolylineButton.Position.Y := 26;
  FZoomToPolylineButton.Width := 130;
  FZoomToPolylineButton.Text := 'Zoom to polyline';
  FZoomToPolylineButton.OnClick := ZoomToPolylineButtonClick;

  FPolylineCountLabel := TLabel.Create(Self);
  FPolylineCountLabel.Parent := FControlLayout;
  FPolylineCountLabel.Position.X := 4;
  FPolylineCountLabel.Position.Y := 62;
  FPolylineCountLabel.Text := 'Polylines';

  FPolylineCountValueLabel := TLabel.Create(Self);
  FPolylineCountValueLabel.Parent := FControlLayout;
  FPolylineCountValueLabel.Position.X := 72;
  FPolylineCountValueLabel.Position.Y := 62;
  FPolylineCountValueLabel.Text := '0';

  FVisibleCheck := TCheckBox.Create(Self);
  FVisibleCheck.Parent := FControlLayout;
  FVisibleCheck.Position.X := 120;
  FVisibleCheck.Position.Y := 58;
  FVisibleCheck.Text := 'Visible';

  FEditableCheck := TCheckBox.Create(Self);
  FEditableCheck.Parent := FControlLayout;
  FEditableCheck.Position.X := 200;
  FEditableCheck.Position.Y := 58;
  FEditableCheck.Text := 'Editable';

  FDraggableCheck := TCheckBox.Create(Self);
  FDraggableCheck.Parent := FControlLayout;
  FDraggableCheck.Position.X := 290;
  FDraggableCheck.Position.Y := 58;
  FDraggableCheck.Text := 'Draggable';

  FPolylineOptionsLayout := TLayout.Create(Self);
  FPolylineOptionsLayout.Parent := Self;
  FPolylineOptionsLayout.Align := TAlignLayout.Left;
  FPolylineOptionsLayout.Width := 360;
  FPolylineOptionsLayout.Padding.Left := 12;
  FPolylineOptionsLayout.Padding.Top := 8;
  FPolylineOptionsLayout.Padding.Right := 8;
  FPolylineOptionsLayout.Padding.Bottom := 8;

  FPathLayout := TLayout.Create(Self);
  FPathLayout.Parent := FPolylineOptionsLayout;
  FPathLayout.Align := TAlignLayout.Top;
  FPathLayout.Height := 286;

  FPathLabel := TLabel.Create(Self);
  FPathLabel.Parent := FPathLayout;
  FPathLabel.Align := TAlignLayout.Top;
  FPathLabel.Text := 'Path';

  FPathMemo := TMemo.Create(Self);
  FPathMemo.Parent := FPathLayout;
  FPathMemo.Align := TAlignLayout.Bottom;
  FPathMemo.Height := 250;
  FPathMemo.WordWrap := False;
  FPathMemo.ShowScrollBars := True;

  FStrokeColorEdit := TEdit.Create(Self);
  FStrokeColorEdit.Parent := FPolylineOptionsLayout;
  FStrokeColorEdit.Align := TAlignLayout.Top;
  FStrokeColorEdit.Height := 34;
  FStrokeColorEdit.Text := '#c026d3';
  FStrokeColorEdit.Margins.Bottom := 8;

  FStrokeOpacityEdit := TEdit.Create(Self);
  FStrokeOpacityEdit.Parent := FPolylineOptionsLayout;
  FStrokeOpacityEdit.Align := TAlignLayout.Top;
  FStrokeOpacityEdit.Height := 34;
  FStrokeOpacityEdit.Text := '0.85';
  FStrokeOpacityEdit.Margins.Bottom := 8;

  FStrokeWeightEdit := TEdit.Create(Self);
  FStrokeWeightEdit.Parent := FPolylineOptionsLayout;
  FStrokeWeightEdit.Align := TAlignLayout.Top;
  FStrokeWeightEdit.Height := 34;
  FStrokeWeightEdit.Text := '4';
  FStrokeWeightEdit.Margins.Bottom := 8;

  FLogLayout := TLayout.Create(Self);
  FLogLayout.Parent := Self;
  FLogLayout.Align := TAlignLayout.Bottom;
  FLogLayout.Height := 210;
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

procedure TMainForm.ClearPolylineButtonClick(Sender: TObject);
begin
  FMap.Polylines.Clear;
  FPrimaryPolyline := nil;
  UpdatePolylineCount;
  Log('Polyline collection cleared.');
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

procedure TMainForm.EnsurePrimaryPolyline;
begin
  if Assigned(FPrimaryPolyline) and (FPrimaryPolyline.Collection = FMap.Polylines) then
    Exit;

  if FMap.Polylines.Count = 0 then
    FPrimaryPolyline := FMap.Polylines.Add
  else
    FPrimaryPolyline := FMap.Polylines[0];

  FPrimaryPolyline.OnClick := HandlePolylineClick;
  FPrimaryPolyline.OnDrag := HandlePolylineDrag;
  FPrimaryPolyline.OnDragStart := HandlePolylineDragStart;
  FPrimaryPolyline.OnDragEnd := HandlePolylineDragEnd;
  FPrimaryPolyline.OnPathChanged := HandlePolylinePathChanged;
end;

procedure TMainForm.LoadSampleButtonClick(Sender: TObject);
begin
  PopulateSamplePath;
  Log('Sample path loaded into the editor.');
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
  Log('Map ready event received.');
end;

procedure TMainForm.HandlePolylineClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline click at %s, %s', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandlePolylineDrag(Sender: TObject);
begin
  Log('Polyline dragging.');
end;

procedure TMainForm.HandlePolylineDragEnd(Sender: TObject);
begin
  Log('Polyline drag end.');
end;

procedure TMainForm.HandlePolylineDragStart(Sender: TObject);
begin
  Log('Polyline drag start.');
end;

procedure TMainForm.HandlePolylinePathChanged(Sender: TObject);
begin
  RebindPrimaryPolyline;
  UpdatePathMemoFromPolyline;
  Log('Polyline path changed from map.');
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FCenterLatEdit.Text := '41.3874';
  FCenterLngEdit.Text := '2.1686';
  FZoomEdit.Text := '6';
  FVisibleCheck.IsChecked := True;
  FEditableCheck.IsChecked := True;
  FDraggableCheck.IsChecked := False;
  FStrokeColorEdit.Text := '#c026d3';
  FStrokeOpacityEdit.Text := '0.85';
  FStrokeWeightEdit.Text := '4';
  UpdateStatus('Ready');
  PopulateSamplePath;
  UpdatePolylineCount;
  Log('Polyline lab initialized.');
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

procedure TMainForm.Log(const AText: string);
begin
  while FLogMemo.Lines.Count >= 500 do
    FLogMemo.Lines.Delete(0);

  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

function TMainForm.ParsePathMemo(out ACoordinates: TArray<TPolylineCoordinate>): Boolean;
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
var
  Coordinate: TPolylineCoordinate;
  i: Integer;
  Latitude: Double;
  Longitude: Double;
  Line: string;
begin
  SetLength(ACoordinates, 0);

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

    Coordinate.Lat := Latitude;
    Coordinate.Lng := Longitude;
    SetLength(ACoordinates, Length(ACoordinates) + 1);
    ACoordinates[High(ACoordinates)] := Coordinate;
  end;

  if Length(ACoordinates) < 2 then
  begin
    Log('The polyline needs at least two points.');
    Exit(False);
  end;

  Result := True;
end;

procedure TMainForm.PopulateSamplePath;
begin
  FPathMemo.Lines.BeginUpdate;
  try
    FPathMemo.Lines.Text :=
      '41.3874,2.1686' + sLineBreak +
      '41.9028,12.4964' + sLineBreak +
      '45.4642,9.1900' + sLineBreak +
      '48.8566,2.3522';
  finally
    FPathMemo.Lines.EndUpdate;
  end;
end;

procedure TMainForm.RebindPrimaryPolyline;
begin
  if FMap.Polylines.Count = 0 then
    FPrimaryPolyline := nil
  else
    FPrimaryPolyline := FMap.Polylines[0];

  if Assigned(FPrimaryPolyline) then
  begin
    FPrimaryPolyline.OnClick := HandlePolylineClick;
    FPrimaryPolyline.OnDrag := HandlePolylineDrag;
    FPrimaryPolyline.OnDragStart := HandlePolylineDragStart;
    FPrimaryPolyline.OnDragEnd := HandlePolylineDragEnd;
    FPrimaryPolyline.OnPathChanged := HandlePolylinePathChanged;
  end;
end;

procedure TMainForm.UpdatePathMemoFromPolyline;
var
  i: Integer;
begin
  if FUpdatingPathMemo or not Assigned(FPrimaryPolyline) then
    Exit;

  FUpdatingPathMemo := True;
  try
    FPathMemo.Lines.BeginUpdate;
    try
      FPathMemo.Lines.Clear;
      for i := 0 to FPrimaryPolyline.Options.Path.Count - 1 do
        FPathMemo.Lines.Add(Format('%.6f,%.6f', [
          FPrimaryPolyline.Options.Path[i].Lat,
          FPrimaryPolyline.Options.Path[i].Lng
        ], TFormatSettings.Invariant));
    finally
      FPathMemo.Lines.EndUpdate;
    end;
  finally
    FUpdatingPathMemo := False;
  end;
end;

procedure TMainForm.UpdatePolylineCount;
begin
  FPolylineCountValueLabel.Text := IntToStr(FMap.Polylines.Count);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
//  FStatusValueLabel.Text := AText;
end;

procedure TMainForm.ZoomToPolylineButtonClick(Sender: TObject);
begin
  if FMap.Polylines.Count = 0 then
  begin
    Log('There is no polyline to zoom.');
    Exit;
  end;

  FMap.Polylines.ZoomToPoints(True);
  Log('ZoomToPoints requested for visible polylines.');
end;

end.
