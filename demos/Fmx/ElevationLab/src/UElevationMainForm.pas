unit UElevationMainForm;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.UITypes,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Graphics,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.Types,
  FMX.WebBrowser,
  FMX.Objects,
  uGMLib.Core.Types,
  uGMLib.Elevation,
  uGMLib.Fmx.Map,
  uGMLib.Fmx.Polyline;

type
  TPathPoint = record
    Lat: Double;
    Lng: Double;
  end;

  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FClearPathButton: TButton;
    FElevationAlongButton: TButton;
    FElevationLocationsButton: TButton;
    FLoadSampleButton: TButton;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapIdEdit: TEdit;
    FMapIdLabel: TLabel;
    FMapLayout: TLayout;
    FProfileLayout: TLayout;
    FProfileLabel: TLabel;
    FProfileBox: TPaintBox;
    FPathPolyline: TGMFmxPolylineItem;
    FStatusLabel: TLabel;
    FStatusValueLabel: TLabel;
    FControlLayout: TLayout;
    FLogLayout: TLayout;
    FBrowser: TWebBrowser;
    FLastElevationResults: TGMElevationResults;
    procedure ActivateButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ClearPathButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure EnsurePathPolyline;
    procedure ExecuteElevation(AAlongPath: Boolean);
    procedure ElevationAlongButtonClick(Sender: TObject);
    procedure ElevationLocationsButtonClick(Sender: TObject);
    procedure HandleElevationCompleted(Sender: TObject; const AResponse: TGMElevationResponse);
    procedure HandleMapReady(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSamplePathButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    procedure ProfileBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure SetMapCenter(const ALatitude, ALongitude: Double);
    procedure UpdateElevationProfile(const AResponse: TGMElevationResponse);
    procedure UpdateStatus(const AText: string);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

const
  SamplePath: array[0..5] of TPathPoint = (
    (Lat: 41.3874; Lng: 2.1686),
    (Lat: 42.1401; Lng: 2.5142),
    (Lat: 43.3183; Lng: 3.0573),
    (Lat: 44.8378; Lng: -0.5792),
    (Lat: 45.7640; Lng: 4.8357),
    (Lat: 46.2044; Lng: 6.1432)
  );

constructor TMainForm.CreateNew(AOwner: TComponent; Dummy: NativeInt);
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

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Elevation Lab';
  Width := 1280;
  Height := 860;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 84;
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

  FMapIdLabel := TLabel.Create(Self);
  FMapIdLabel.Parent := FControlLayout;
  FMapIdLabel.Position.X := 382;
  FMapIdLabel.Position.Y := 4;
  FMapIdLabel.Text := 'Map ID';

  FMapIdEdit := TEdit.Create(Self);
  FMapIdEdit.Parent := FControlLayout;
  FMapIdEdit.Position.X := 382;
  FMapIdEdit.Position.Y := 28;
  FMapIdEdit.Width := 180;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 580;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 110;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FControlLayout;
  FLoadSampleButton.Position.X := 704;
  FLoadSampleButton.Position.Y := 26;
  FLoadSampleButton.Width := 122;
  FLoadSampleButton.Text := 'Load sample path';
  FLoadSampleButton.OnClick := LoadSamplePathButtonClick;

  FElevationAlongButton := TButton.Create(Self);
  FElevationAlongButton.Parent := FControlLayout;
  FElevationAlongButton.Position.X := 838;
  FElevationAlongButton.Position.Y := 26;
  FElevationAlongButton.Width := 132;
  FElevationAlongButton.Text := 'Elevation along';
  FElevationAlongButton.OnClick := ElevationAlongButtonClick;

  FElevationLocationsButton := TButton.Create(Self);
  FElevationLocationsButton.Parent := FControlLayout;
  FElevationLocationsButton.Position.X := 982;
  FElevationLocationsButton.Position.Y := 26;
  FElevationLocationsButton.Width := 144;
  FElevationLocationsButton.Text := 'Elevation locations';
  FElevationLocationsButton.OnClick := ElevationLocationsButtonClick;

  FClearPathButton := TButton.Create(Self);
  FClearPathButton.Parent := FControlLayout;
  FClearPathButton.Position.X := 1138;
  FClearPathButton.Position.Y := 26;
  FClearPathButton.Width := 100;
  FClearPathButton.Text := 'Clear path';
  FClearPathButton.OnClick := ClearPathButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlLayout;
  FStatusLabel.Position.X := 4;
  FStatusLabel.Position.Y := 58;
  FStatusLabel.Text := 'Status';

  FStatusValueLabel := TLabel.Create(Self);
  FStatusValueLabel.Parent := FControlLayout;
  FStatusValueLabel.Position.X := 56;
  FStatusValueLabel.Position.Y := 58;
  FStatusValueLabel.Text := 'Ready';

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

  FMapLayout := TLayout.Create(Self);
  FMapLayout.Parent := Self;
  FMapLayout.Align := TAlignLayout.Client;

  FProfileLayout := TLayout.Create(Self);
  FProfileLayout.Parent := Self;
  FProfileLayout.Align := TAlignLayout.Bottom;
  FProfileLayout.Height := 180;
  FProfileLayout.Padding.Left := 12;
  FProfileLayout.Padding.Top := 8;
  FProfileLayout.Padding.Right := 12;
  FProfileLayout.Padding.Bottom := 8;

  FProfileLabel := TLabel.Create(Self);
  FProfileLabel.Parent := FProfileLayout;
  FProfileLabel.Align := TAlignLayout.Top;
  FProfileLabel.Height := 18;
  FProfileLabel.Text := 'Elevation profile';

  FMap := TGMLibMap.Create(Self);
  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := FMapLayout;
  FBrowser.Align := TAlignLayout.Client;
  FMap.Browser := FBrowser;

  FProfileBox := TPaintBox.Create(Self);
  FProfileBox.Parent := FProfileLayout;
  FProfileBox.Align := TAlignLayout.Client;
  FProfileBox.OnPaint := ProfileBoxPaint;
end;

procedure TMainForm.ConfigureBrowser;
begin
  {$IFDEF MSWINDOWS}
  TWebBrowser(FMap.Browser).WindowsEngine := TWindowsEngine.EdgeOnly;
  {$ENDIF}
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMapIdEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID');
  if FMapIdEdit.Text = '' then
    FMapIdEdit.Text := 'DEMO_MAP_ID';
  UpdateStatus('Ready');
  Log('Elevation demo initialized.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
  SetMapCenter(44.0, 1.0);
  FMap.Options.Zoom := 5;
  FMap.BridgeInterval := 100;
  FMap.Elevations.Map := FMap;
  FMap.Elevations.Samples := 32;
  FMap.Elevations.OnCompleted := HandleElevationCompleted;
  FMap.OnMapReady := HandleMapReady;
end;

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
  SetMapCenter(44.0, 1.0);
  FMap.Options.Zoom := 5;

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

procedure TMainForm.SetMapCenter(const ALatitude, ALongitude: Double);
var
  Center: TGMLibLatLng;
begin
  Center := TGMLibLatLng.Create(ALatitude, ALongitude);
  try
    FMap.Options.Center := Center;
  finally
    Center.Free;
  end;
end;

procedure TMainForm.EnsurePathPolyline;
begin
  if Assigned(FPathPolyline) and (FPathPolyline.Collection = FMap.Polylines) then
    Exit;

  if FMap.Polylines.Count = 0 then
    FPathPolyline := FMap.Polylines.Add
  else
    FPathPolyline := FMap.Polylines[0];

  FPathPolyline.Options.Visible := True;
  FPathPolyline.Options.Editable := False;
  FPathPolyline.Options.Draggable := False;
  FPathPolyline.Options.Clickable := True;
  FPathPolyline.Options.Geodesic := True;
  FPathPolyline.Options.StrokeColor := TAlphaColorRec.Royalblue;
  FPathPolyline.Options.StrokeOpacity := 0.92;
  FPathPolyline.Options.StrokeWeight := 4;
end;

procedure TMainForm.ExecuteElevation(AAlongPath: Boolean);
begin
  if not FMap.Active then
  begin
    Log('Activate the map first.');
    Exit;
  end;

  EnsurePathPolyline;
  if FPathPolyline.Options.Path.Count < 2 then
  begin
    Log('Load a sample path before requesting elevation.');
    Exit;
  end;

  FMap.Elevations.AddLatLngFromPolyline(FPathPolyline, True);
  if AAlongPath then
  begin
    FMap.Elevations.ElevationType := etAlongPath;
    FMap.Elevations.Samples := 32;
    Log('Requesting elevation along path samples (route profile).');
  end
  else
  begin
    FMap.Elevations.ElevationType := etForLocations;
    FMap.Elevations.Samples := 2;
    Log('Requesting elevation for discrete locations.');
  end;

  FMap.Elevations.Execute;
end;

procedure TMainForm.ElevationAlongButtonClick(Sender: TObject);
begin
  ExecuteElevation(True);
end;

procedure TMainForm.ElevationLocationsButtonClick(Sender: TObject);
begin
  ExecuteElevation(False);
end;

procedure TMainForm.HandleElevationCompleted(Sender: TObject; const AResponse: TGMElevationResponse);
var
  i: Integer;
  ResultCount: Integer;
  ElevationResult: TGMElevationResult;
begin
  UpdateElevationProfile(AResponse);
  ResultCount := Length(AResponse.Results);
  Log(Format('Elevation completed. Status=%s Error=%s Results=%d', [
    AResponse.Status,
    AResponse.ErrorMessage,
    ResultCount
  ]));

  for i := 0 to ResultCount - 1 do
  begin
    ElevationResult := AResponse.Results[i];
    Log(Format('  #%d lat=%.6f lng=%.6f elev=%.2f res=%.2f', [
      i + 1,
      ElevationResult.Latitude,
      ElevationResult.Longitude,
      ElevationResult.Elevation,
      ElevationResult.Resolution
    ]));
    if i >= 4 then
      Break;
  end;

  if ResultCount > 5 then
    Log(Format('  ... %d more results', [ResultCount - 5]));

  UpdateStatus(Format('Completed: %d results', [ResultCount]));
end;

procedure TMainForm.UpdateElevationProfile(const AResponse: TGMElevationResponse);
begin
  FLastElevationResults := AResponse.Results;
  FProfileBox.Repaint;
end;

procedure TMainForm.ProfileBoxPaint(Sender: TObject; Canvas: TCanvas);
var
  W, H: Single;
  Margin: Single;
  PlotW, PlotH: Single;
  i: Integer;
  MinElev, MaxElev: Double;
  RangeElev: Double;
  X1, Y1: Single;
  function MapX(const Index: Integer): Single;
  begin
    if Length(FLastElevationResults) <= 1 then
      Exit(Margin);
    Result := Margin + ((Index / (Length(FLastElevationResults) - 1)) * PlotW);
  end;
  function MapY(const Elev: Double): Single;
  begin
    if SameValue(RangeElev, 0) then
      Exit(Margin + PlotH * 0.5);
    Result := Margin + (((MaxElev - Elev) / RangeElev) * PlotH);
  end;
begin
  W := FProfileBox.Width;
  H := FProfileBox.Height;
  Margin := 16;
  PlotW := Max(10, W - (Margin * 2));
  PlotH := Max(10, H - (Margin * 2));

  Canvas.Clear(TAlphaColors.White);
  Canvas.Stroke.Color := TAlphaColors.Silver;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawRect(RectF(Margin, Margin, W - Margin, H - Margin), 0, 0, [], 1);

  if Length(FLastElevationResults) = 0 then
  begin
    Canvas.Fill.Color := TAlphaColors.Gray;
    Canvas.FillText(RectF(Margin + 8, Margin + 8, W - Margin - 8, H - Margin - 8),
      'No elevation data yet', False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
    Exit;
  end;

  MinElev := FLastElevationResults[0].Elevation;
  MaxElev := MinElev;
  for i := 0 to High(FLastElevationResults) do
  begin
    if FLastElevationResults[i].Elevation < MinElev then
      MinElev := FLastElevationResults[i].Elevation;
    if FLastElevationResults[i].Elevation > MaxElev then
      MaxElev := FLastElevationResults[i].Elevation;
  end;
  RangeElev := MaxElev - MinElev;
  if RangeElev <= 0 then
    RangeElev := 1;

  Canvas.Stroke.Color := TAlphaColors.Navy;
  Canvas.Stroke.Thickness := 2;
  for i := 0 to High(FLastElevationResults) do
  begin
    X1 := MapX(i);
    Y1 := MapY(FLastElevationResults[i].Elevation);
    if i = 0 then
      Canvas.DrawLine(PointF(X1, Y1), PointF(X1, Y1), 1)
    else
      Canvas.DrawLine(PointF(MapX(i - 1), MapY(FLastElevationResults[i - 1].Elevation)), PointF(X1, Y1), 1);
  end;

  Canvas.Fill.Color := TAlphaColors.Gray;
  Canvas.FillText(RectF(Margin + 8, H - Margin - 24, W - Margin - 8, H - Margin), Format('Min %.1f m    Max %.1f m', [MinElev, MaxElev]),
    False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  Log('Map ready event received.');
  UpdateStatus('Map ready');
end;

procedure TMainForm.LoadSamplePathButtonClick(Sender: TObject);
var
  Point: TPathPoint;
begin
  EnsurePathPolyline;
  FPathPolyline.Options.Path.Clear;
  for Point in SamplePath do
    FPathPolyline.Options.Path.Add(Point.Lat, Point.Lng);

  if FMap.Active then
    FMap.Polylines.ZoomToPoints(True);

  Log(Format('Sample path loaded with %d points.', [Length(SamplePath)]));
end;

procedure TMainForm.Log(const AText: string);
begin
  while FLogMemo.Lines.Count >= 500 do
    FLogMemo.Lines.Delete(0);

  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainForm.ClearPathButtonClick(Sender: TObject);
begin
  if Assigned(FPathPolyline) then
  begin
    FPathPolyline.Options.Path.Clear;
    FPathPolyline := nil;
  end;

  if FMap.Polylines.Count > 0 then
    FMap.Polylines.Clear;

  Log('Path cleared.');
  UpdateStatus('Path cleared');
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusValueLabel.Text := AText;
end;

end.
