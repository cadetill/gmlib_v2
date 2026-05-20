unit UElevationMainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Math,
  System.SysUtils,
  System.TypInfo,
  Vcl.Controls,
  Vcl.Edge,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Winapi.ActiveX,
  Winapi.WebView2,
  uGMLib.Core.Types,
  uGMLib.Elevation,
  uGMLib.Vcl.Map,
  uGMLib.Vcl.Polyline;

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
    FProfileLabel: TLabel;
    FProfilePanel: TPanel;
    FProfileBox: TPaintBox;
    FMapPanel: TPanel;
    FPathPolyline: TGMVclPolylineItem;
    FStatusLabel: TLabel;
    FTopPanel: TPanel;
    FBrowser: TEdgeBrowser;
    FLastElevationResults: TGMElevationResults;
    procedure ActivateButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure BuildLayout;
    procedure ClearPathButtonClick(Sender: TObject);
    procedure ConfigureMap;
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
    procedure ProfileBoxPaint(Sender: TObject);
    procedure SetMapCenter(const ALatitude, ALongitude: Double);
    procedure UpdateElevationProfile(const AResponse: TGMElevationResponse);
    procedure UpdateStatus(const AText: string);
  public
    constructor Create(AOwner: TComponent); override;
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

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BuildLayout;
  ConfigureMap;
  InitializeMap;
  InitializeDefaults;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;

  if Assigned(FMap) then
    FMap.Free;

  inherited;
end;

procedure TMainForm.BuildLayout;
begin
  Caption := 'GMLib VCL Elevation Lab';
  Width := 1280;
  Height := 860;
  Position := poScreenCenter;

  FTopPanel := TPanel.Create(Self);
  FTopPanel.Parent := Self;
  FTopPanel.Align := alTop;
  FTopPanel.Height := 88;
  FTopPanel.BevelOuter := bvNone;

  FAPIKeyLabel := TLabel.Create(Self);
  FAPIKeyLabel.Parent := FTopPanel;
  FAPIKeyLabel.Left := 16;
  FAPIKeyLabel.Top := 10;
  FAPIKeyLabel.Caption := 'API key';

  FAPIKeyEdit := TEdit.Create(Self);
  FAPIKeyEdit.Parent := FTopPanel;
  FAPIKeyEdit.Left := 16;
  FAPIKeyEdit.Top := 32;
  FAPIKeyEdit.Width := 360;

  FMapIdLabel := TLabel.Create(Self);
  FMapIdLabel.Parent := FTopPanel;
  FMapIdLabel.Left := 392;
  FMapIdLabel.Top := 10;
  FMapIdLabel.Caption := 'Map ID';

  FMapIdEdit := TEdit.Create(Self);
  FMapIdEdit.Parent := FTopPanel;
  FMapIdEdit.Left := 392;
  FMapIdEdit.Top := 32;
  FMapIdEdit.Width := 180;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FTopPanel;
  FActivateButton.Left := 590;
  FActivateButton.Top := 30;
  FActivateButton.Width := 110;
  FActivateButton.Caption := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FTopPanel;
  FLoadSampleButton.Left := 714;
  FLoadSampleButton.Top := 30;
  FLoadSampleButton.Width := 122;
  FLoadSampleButton.Caption := 'Load sample path';
  FLoadSampleButton.OnClick := LoadSamplePathButtonClick;

  FElevationAlongButton := TButton.Create(Self);
  FElevationAlongButton.Parent := FTopPanel;
  FElevationAlongButton.Left := 848;
  FElevationAlongButton.Top := 30;
  FElevationAlongButton.Width := 132;
  FElevationAlongButton.Caption := 'Elevation along';
  FElevationAlongButton.OnClick := ElevationAlongButtonClick;

  FElevationLocationsButton := TButton.Create(Self);
  FElevationLocationsButton.Parent := FTopPanel;
  FElevationLocationsButton.Left := 992;
  FElevationLocationsButton.Top := 30;
  FElevationLocationsButton.Width := 144;
  FElevationLocationsButton.Caption := 'Elevation locations';
  FElevationLocationsButton.OnClick := ElevationLocationsButtonClick;

  FClearPathButton := TButton.Create(Self);
  FClearPathButton.Parent := FTopPanel;
  FClearPathButton.Left := 1148;
  FClearPathButton.Top := 30;
  FClearPathButton.Width := 100;
  FClearPathButton.Caption := 'Clear path';
  FClearPathButton.OnClick := ClearPathButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FTopPanel;
  FStatusLabel.Left := 16;
  FStatusLabel.Top := 62;
  FStatusLabel.Caption := 'Ready';

  FMapPanel := TPanel.Create(Self);
  FMapPanel.Parent := Self;
  FMapPanel.Align := alClient;
  FMapPanel.BevelOuter := bvNone;

  FProfilePanel := TPanel.Create(Self);
  FProfilePanel.Parent := Self;
  FProfilePanel.Align := alBottom;
  FProfilePanel.Height := 180;
  FProfilePanel.BevelOuter := bvLowered;
  FProfilePanel.Caption := '';

  FProfileLabel := TLabel.Create(Self);
  FProfileLabel.Parent := FProfilePanel;
  FProfileLabel.Align := alTop;
  FProfileLabel.Height := 18;
  FProfileLabel.Caption := 'Elevation profile';

  FProfileBox := TPaintBox.Create(Self);
  FProfileBox.Parent := FProfilePanel;
  FProfileBox.Align := alClient;
  FProfileBox.OnPaint := ProfileBoxPaint;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := Self;
  FLogMemo.Align := alBottom;
  FLogMemo.Height := 210;
  FLogMemo.ReadOnly := True;
  FLogMemo.ScrollBars := ssVertical;
  FLogMemo.WordWrap := False;

  FMap := TGMLibMap.Create(Self);
  FBrowser := TEdgeBrowser.Create(Self);
  FBrowser.Parent := FMapPanel;
  FBrowser.Align := alClient;
  SetBooleanPropertyIfPublished(FBrowser, 'AllowSingleSignOnUsingOSPrimaryAccount', False);
  SetStringPropertyIfPublished(FBrowser, 'TargetCompatibleBrowserVersion', '117.0.2045.28');
  SetStringPropertyIfPublished(FBrowser, 'UserDataFolder', '%LOCALAPPDATA%\bds.exe.WebView2');
  FBrowser.OnCreateWebViewCompleted := BrowserCreateWebViewCompleted;
  FMap.Browser := FBrowser;
end;

procedure TMainForm.ConfigureMap;
begin
  FMap.OnMapReady := HandleMapReady;
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
  FMap.Elevations.Map := FMap;
  FMap.Elevations.Samples := 80;
  FMap.Elevations.OnCompleted := HandleElevationCompleted;
end;

procedure TMainForm.SetMapCenter(const ALatitude, ALongitude: Double);
var
  Center: TMapLibLatLng;
begin
  Center := TMapLibLatLng.Create(ALatitude, ALongitude);
  try
    FMap.Options.Center := Center;
  finally
    Center.Free;
  end;
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

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Log('WebView created.')
  else
    Log(Format('WebView creation failed. HRESULT=0x%.8x', [Cardinal(AResult)]));
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
  FPathPolyline.Options.StrokeColor := RGB(65, 105, 225);
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
    FMap.Elevations.Samples := 200;
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
  FProfileBox.Invalidate;
end;

procedure TMainForm.ProfileBoxPaint(Sender: TObject);
var
  Canvas: TCanvas;
  W, H: Integer;
  Margin: Integer;
  PlotW, PlotH: Integer;
  i: Integer;
  MinElev, MaxElev: Double;
  RangeElev: Double;
  X1, Y1: Integer;
  function MapX(const Index: Integer): Integer;
  begin
    if Length(FLastElevationResults) <= 1 then
      Exit(Margin);
    Result := Margin + Round((Index / (Length(FLastElevationResults) - 1)) * PlotW);
  end;
  function MapY(const Elev: Double): Integer;
  begin
    if SameValue(RangeElev, 0) then
      Exit(Margin + PlotH div 2);
    Result := Margin + Round((MaxElev - Elev) / RangeElev * PlotH);
  end;
begin
  Canvas := FProfileBox.Canvas;
  W := FProfileBox.Width;
  H := FProfileBox.Height;
  Margin := 16;
  PlotW := Max(10, W - (Margin * 2));
  PlotH := Max(10, H - (Margin * 2));

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Rect(0, 0, W, H));
  Canvas.Pen.Color := clSilver;
  Canvas.Rectangle(Margin, Margin, W - Margin, H - Margin);

  if Length(FLastElevationResults) = 0 then
  begin
    Canvas.Font.Color := clGray;
    Canvas.TextOut(Margin + 8, Margin + 8, 'No elevation data yet');
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

  Canvas.Pen.Color := clNavy;
  Canvas.Pen.Width := 2;
  for i := 0 to High(FLastElevationResults) do
  begin
    X1 := MapX(i);
    Y1 := MapY(FLastElevationResults[i].Elevation);
    if i = 0 then
      Canvas.MoveTo(X1, Y1)
    else
      Canvas.LineTo(X1, Y1);
  end;

  Canvas.Font.Color := clGray;
  Canvas.TextOut(Margin + 8, H - Margin - 18, Format('Min %.1f m', [MinElev]));
  Canvas.TextOut(W - Margin - 110, H - Margin - 18, Format('Max %.1f m', [MaxElev]));
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
  FStatusLabel.Caption := AText;
end;

end.

