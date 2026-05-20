unit URoutesMainForm;

interface

uses
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Edge,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.ActiveX,
  Winapi.WebView2,
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.TypInfo,
  uGMLib.Core.Types,
  uGMLib.Map,
  uGMLib.Routes,
  uGMLib.Vcl.Map;

type
  TRouteInputKind = (
    rikLatLng,
    rikAddress
  );

  TRouteInput = record
    Kind: TRouteInputKind;
    Lat: Double;
    Lng: Double;
    Text: string;
  end;

  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FBrowser: TEdgeBrowser;
    FClearButton: TButton;
    FComputeButton: TButton;
    FFieldsEdit: TEdit;
    FFieldsLabel: TLabel;
    FLoadSampleButton: TButton;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapIdEdit: TEdit;
    FMapIdLabel: TLabel;
    FMapPanel: TPanel;
    FQueryHideButton: TButton;
    FQueryListBox: TListBox;
    FQueryListLabel: TLabel;
    FQueryShowButton: TButton;
    FResultHideButton: TButton;
    FResultListBox: TListBox;
    FResultListLabel: TLabel;
    FResultShowButton: TButton;
    FRouteMemo: TMemo;
    FRouteMemoLabel: TLabel;
    FRoutePanel: TPanel;
    FRoutesPanel: TPanel;
    FStatusLabel: TLabel;
    FTopPanel: TPanel;
    procedure ActivateButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure BuildLayout;
    procedure ClearButtonClick(Sender: TObject);
    procedure ComputeButtonClick(Sender: TObject);
    procedure ConfigureMap;
    function DescribeQuery(AQuery: TGMRouteQuery): string;
    function DescribeResult(AResult: TGMRouteQueryResult; AIndex: Integer): string;
    function GetSelectedQuery: TGMRouteQuery;
    function GetSelectedResult: TGMRouteQueryResult;
    procedure HandleMapReady(Sender: TObject);
    procedure HandleRouteCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    function ParseRouteMemo(out APoints: TArray<TRouteInput>): Boolean;
    procedure PopulateSampleRoute;
    procedure QueryHideButtonClick(Sender: TObject);
    procedure QueryListBoxClick(Sender: TObject);
    procedure QueryShowButtonClick(Sender: TObject);
    procedure RefreshQueryList;
    procedure RefreshResultList;
    procedure ResultHideButtonClick(Sender: TObject);
    procedure ResultListBoxClick(Sender: TObject);
    procedure ResultShowButtonClick(Sender: TObject);
    procedure SetMapCenter(const ALatitude, ALongitude: Double);
    procedure UpdateStatus(const AText: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

const
  SampleRoute: array[0..5] of TRouteInput = (
    (Kind: rikAddress; Lat: 0; Lng: 0; Text: 'Barcelona, Spain'),
    (Kind: rikLatLng; Lat: 41.8919; Lng: 12.5113; Text: ''),
    (Kind: rikAddress; Lat: 0; Lng: 0; Text: 'Lyon, France'),
    (Kind: rikLatLng; Lat: 45.7640; Lng: 4.8357; Text: ''),
    (Kind: rikAddress; Lat: 0; Lng: 0; Text: 'Geneva, Switzerland'),
    (Kind: rikAddress; Lat: 0; Lng: 0; Text: 'Paris, France')
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
  FMap.Free;
  inherited;
end;

procedure TMainForm.BuildLayout;
begin
  Caption := 'GMLib VCL Routes Lab';
  Width := 1440;
  Height := 860;
  Position := poScreenCenter;

  FTopPanel := TPanel.Create(Self);
  FTopPanel.Parent := Self;
  FTopPanel.Align := alTop;
  FTopPanel.Height := 92;
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

  FFieldsLabel := TLabel.Create(Self);
  FFieldsLabel.Parent := FTopPanel;
  FFieldsLabel.Left := 590;
  FFieldsLabel.Top := 10;
  FFieldsLabel.Caption := 'Request fields';

  FFieldsEdit := TEdit.Create(Self);
  FFieldsEdit.Parent := FTopPanel;
  FFieldsEdit.Left := 590;
  FFieldsEdit.Top := 32;
  FFieldsEdit.Width := 414;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FTopPanel;
  FActivateButton.Left := 1020;
  FActivateButton.Top := 30;
  FActivateButton.Width := 110;
  FActivateButton.Caption := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FTopPanel;
  FLoadSampleButton.Left := 1144;
  FLoadSampleButton.Top := 30;
  FLoadSampleButton.Width := 120;
  FLoadSampleButton.Caption := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  FComputeButton := TButton.Create(Self);
  FComputeButton.Parent := FTopPanel;
  FComputeButton.Left := 16;
  FComputeButton.Top := 60;
  FComputeButton.Width := 110;
  FComputeButton.Caption := 'Compute route';
  FComputeButton.OnClick := ComputeButtonClick;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FTopPanel;
  FClearButton.Left := 140;
  FClearButton.Top := 60;
  FClearButton.Width := 94;
  FClearButton.Caption := 'Clear route';
  FClearButton.OnClick := ClearButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FTopPanel;
  FStatusLabel.Left := 252;
  FStatusLabel.Top := 64;
  FStatusLabel.Caption := 'Ready';

  FRoutePanel := TPanel.Create(Self);
  FRoutePanel.Parent := Self;
  FRoutePanel.Align := alLeft;
  FRoutePanel.Width := 340;
  FRoutePanel.BevelOuter := bvNone;

  FRouteMemoLabel := TLabel.Create(Self);
  FRouteMemoLabel.Parent := FRoutePanel;
  FRouteMemoLabel.Align := alTop;
  FRouteMemoLabel.Caption := 'Route request';

  FRouteMemo := TMemo.Create(Self);
  FRouteMemo.Parent := FRoutePanel;
  FRouteMemo.Align := alClient;
  FRouteMemo.ScrollBars := ssVertical;
  FRouteMemo.WordWrap := False;

  FRoutesPanel := TPanel.Create(Self);
  FRoutesPanel.Parent := Self;
  FRoutesPanel.Align := alRight;
  FRoutesPanel.Width := 320;
  FRoutesPanel.BevelOuter := bvNone;

  FQueryListLabel := TLabel.Create(Self);
  FQueryListLabel.Parent := FRoutesPanel;
  FQueryListLabel.Align := alTop;
  FQueryListLabel.Caption := 'Stored queries';

  FQueryShowButton := TButton.Create(Self);
  FQueryShowButton.Parent := FRoutesPanel;
  FQueryShowButton.Align := alTop;
  FQueryShowButton.Height := 28;
  FQueryShowButton.Caption := 'Show query';
  FQueryShowButton.OnClick := QueryShowButtonClick;

  FQueryHideButton := TButton.Create(Self);
  FQueryHideButton.Parent := FRoutesPanel;
  FQueryHideButton.Align := alTop;
  FQueryHideButton.Height := 28;
  FQueryHideButton.Caption := 'Hide query';
  FQueryHideButton.OnClick := QueryHideButtonClick;

  FQueryListBox := TListBox.Create(Self);
  FQueryListBox.Parent := FRoutesPanel;
  FQueryListBox.Align := alTop;
  FQueryListBox.Height := 220;
  FQueryListBox.OnClick := QueryListBoxClick;

  FResultListLabel := TLabel.Create(Self);
  FResultListLabel.Parent := FRoutesPanel;
  FResultListLabel.Align := alTop;
  FResultListLabel.Caption := 'Query results';

  FResultShowButton := TButton.Create(Self);
  FResultShowButton.Parent := FRoutesPanel;
  FResultShowButton.Align := alTop;
  FResultShowButton.Height := 28;
  FResultShowButton.Caption := 'Show result';
  FResultShowButton.OnClick := ResultShowButtonClick;

  FResultHideButton := TButton.Create(Self);
  FResultHideButton.Parent := FRoutesPanel;
  FResultHideButton.Align := alTop;
  FResultHideButton.Height := 28;
  FResultHideButton.Caption := 'Hide result';
  FResultHideButton.OnClick := ResultHideButtonClick;

  FResultListBox := TListBox.Create(Self);
  FResultListBox.Parent := FRoutesPanel;
  FResultListBox.Align := alClient;
  FResultListBox.OnClick := ResultListBoxClick;

  FMapPanel := TPanel.Create(Self);
  FMapPanel.Parent := Self;
  FMapPanel.Align := alClient;
  FMapPanel.BevelOuter := bvNone;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := Self;
  FLogMemo.Align := alBottom;
  FLogMemo.Height := 200;
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

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  if Assigned(FMap) then
    FMap.Routes.Clear;
  RefreshQueryList;
  RefreshResultList;
  UpdateStatus('Routes cleared');
  Log('Stored route queries cleared.');
end;

procedure TMainForm.ComputeButtonClick(Sender: TObject);
var
  Query: TGMRouteQuery;
  RoutePoints: TArray<TRouteInput>;
  i: Integer;
begin
  if not ParseRouteMemo(RoutePoints) then
    Exit;

  if Length(RoutePoints) < 2 then
  begin
    Log('Route needs at least 2 points.');
    Exit;
  end;

  if not Assigned(FMap) then
    Exit;

  if RoutePoints[0].Kind = rikAddress then
  begin
    FMap.Routes.OriginAddress := RoutePoints[0].Text;
    FMap.Routes.OriginLocation.Lat := 0;
    FMap.Routes.OriginLocation.Lng := 0;
  end
  else
  begin
    FMap.Routes.OriginAddress := '';
    FMap.Routes.OriginLocation.Lat := RoutePoints[0].Lat;
    FMap.Routes.OriginLocation.Lng := RoutePoints[0].Lng;
  end;

  if RoutePoints[High(RoutePoints)].Kind = rikAddress then
  begin
    FMap.Routes.DestinationAddress := RoutePoints[High(RoutePoints)].Text;
    FMap.Routes.DestinationLocation.Lat := 0;
    FMap.Routes.DestinationLocation.Lng := 0;
  end
  else
  begin
    FMap.Routes.DestinationAddress := '';
    FMap.Routes.DestinationLocation.Lat := RoutePoints[High(RoutePoints)].Lat;
    FMap.Routes.DestinationLocation.Lng := RoutePoints[High(RoutePoints)].Lng;
  end;

  FMap.Routes.IntermediateWaypoints.Clear;
  for i := 1 to High(RoutePoints) - 1 do
  begin
    if RoutePoints[i].Kind = rikAddress then
      FMap.Routes.IntermediateWaypoints.Add(RoutePoints[i].Text)
    else
      FMap.Routes.IntermediateWaypoints.Add(RoutePoints[i].Lat, RoutePoints[i].Lng);
  end;

  FMap.Routes.RequestFields := Trim(FFieldsEdit.Text);
  if FMap.Routes.RequestFields = '' then
    FMap.Routes.RequestFields := 'path,legs,distanceMeters,durationMillis,staticDurationMillis,localizedValues,routeLabels,warnings';

  UpdateStatus('Computing route...');
  Log(Format('Requesting route with %d points and fields: %s', [Length(RoutePoints), FMap.Routes.RequestFields]));
  Query := FMap.Routes.ExecuteQuery;
  if Assigned(Query) then
    Log('Route query created: ' + Query.RequestId);
  RefreshQueryList;
  RefreshResultList;
end;

procedure TMainForm.ConfigureMap;
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
end;

function TMainForm.DescribeQuery(AQuery: TGMRouteQuery): string;
begin
  if not Assigned(AQuery) then
    Exit('');

  Result := Format('[%s] %s status=%s results=%d', [
    IfThen(AQuery.Visible, 'x', ' '),
    AQuery.RequestId,
    AQuery.Status,
    AQuery.Count
  ]);
end;

function TMainForm.DescribeResult(AResult: TGMRouteQueryResult;
  AIndex: Integer): string;
begin
  if not Assigned(AResult) then
    Exit('');

  Result := Format('[%s] Result %d distance=%.0fm duration=%dms points=%d', [
    IfThen(AResult.Visible, 'x', ' '),
    AIndex + 1,
    AResult.ResponseResult.DistanceMeters,
    AResult.ResponseResult.DurationMillis,
    AResult.PolylineOptions.Path.Count
  ]);
end;

function TMainForm.GetSelectedQuery: TGMRouteQuery;
begin
  Result := nil;
  if not Assigned(FMap) then
    Exit;
  if (FQueryListBox.ItemIndex < 0) or (FQueryListBox.ItemIndex >= FMap.Routes.QueryCount) then
    Exit;
  Result := TGMRouteQuery(FQueryListBox.Items.Objects[FQueryListBox.ItemIndex]);
end;

function TMainForm.GetSelectedResult: TGMRouteQueryResult;
var
  Query: TGMRouteQuery;
begin
  Result := nil;
  Query := GetSelectedQuery;
  if not Assigned(Query) then
    Exit;
  if (FResultListBox.ItemIndex < 0) or (FResultListBox.ItemIndex >= Query.Count) then
    Exit;
  Result := TGMRouteQueryResult(FResultListBox.Items.Objects[FResultListBox.ItemIndex]);
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  Log('Map ready.');
  UpdateStatus('Map ready');
end;

procedure TMainForm.HandleRouteCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
begin
  UpdateStatus(Format('Route status: %s (%d results)', [AResponse.Status, Length(AResponse.Results)]));
  Log(Format('Route completed. Status=%s Error=%s Results=%d', [
    AResponse.Status,
    AResponse.ErrorMessage,
    Length(AResponse.Results)
  ]));
  RefreshQueryList;
  RefreshResultList;
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMapIdEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID');
  FFieldsEdit.Text := 'path,legs,distanceMeters,durationMillis,staticDurationMillis,localizedValues,routeLabels,warnings';
  PopulateSampleRoute;
end;

procedure TMainForm.InitializeMap;
begin
  SetMapCenter(43.0, 8.0);
  FMap.Options.Zoom := 5;
  FMap.OnMapReady := HandleMapReady;
  FMap.Routes.OnCompleted := HandleRouteCompleted;
  FMap.Routes.RequestFields := FFieldsEdit.Text;
  RefreshQueryList;
  RefreshResultList;
end;

procedure TMainForm.LoadSampleButtonClick(Sender: TObject);
begin
  PopulateSampleRoute;
  Log('Sample route loaded.');
end;

procedure TMainForm.Log(const AText: string);
begin
  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

function TMainForm.ParseRouteMemo(out APoints: TArray<TRouteInput>): Boolean;
var
  i: Integer;
  KindText: string;
  LatValue: Double;
  Line: string;
  LngValue: Double;
  Parts: TArray<string>;
  PayloadText: string;
begin
  Result := False;
  SetLength(APoints, 0);

  for i := 0 to FRouteMemo.Lines.Count - 1 do
  begin
    Line := Trim(FRouteMemo.Lines[i]);
    if Line = '' then
      Continue;

    KindText := '';
    PayloadText := Line;
    Parts := Line.Split(['|']);
    if Length(Parts) = 2 then
    begin
      KindText := Trim(UpperCase(Parts[0]));
      PayloadText := Trim(Parts[1]);
    end
    else if Length(Parts) > 2 then
    begin
      Log(Format('Invalid route entry at line %d: %s', [i + 1, Line]));
      Exit;
    end;

    if (KindText = 'A') or (KindText = 'ADDR') or (KindText = 'ADDRESS') then
    begin
      SetLength(APoints, Length(APoints) + 1);
      APoints[High(APoints)].Kind := rikAddress;
      APoints[High(APoints)].Text := PayloadText;
      Continue;
    end;

    if (KindText = 'L') or (KindText = 'LAT') or (KindText = 'LATLNG') or (KindText = 'POINT') then
    begin
      Parts := PayloadText.Split([',']);
      if Length(Parts) <> 2 then
      begin
        Log(Format('Invalid lat/lng at line %d: %s', [i + 1, Line]));
        Exit;
      end;

      if not TryStrToFloat(Trim(Parts[0]), LatValue, TFormatSettings.Invariant) or
         not TryStrToFloat(Trim(Parts[1]), LngValue, TFormatSettings.Invariant) then
      begin
        Log(Format('Invalid numeric values at line %d: %s', [i + 1, Line]));
        Exit;
      end;

      SetLength(APoints, Length(APoints) + 1);
      APoints[High(APoints)].Kind := rikLatLng;
      APoints[High(APoints)].Lat := LatValue;
      APoints[High(APoints)].Lng := LngValue;
      Continue;
    end;

    Parts := PayloadText.Split([',']);
    if Length(Parts) = 2 then
    begin
      if TryStrToFloat(Trim(Parts[0]), LatValue, TFormatSettings.Invariant) and
         TryStrToFloat(Trim(Parts[1]), LngValue, TFormatSettings.Invariant) then
      begin
        SetLength(APoints, Length(APoints) + 1);
        APoints[High(APoints)].Kind := rikLatLng;
        APoints[High(APoints)].Lat := LatValue;
        APoints[High(APoints)].Lng := LngValue;
        Continue;
      end;
    end;

    SetLength(APoints, Length(APoints) + 1);
    APoints[High(APoints)].Kind := rikAddress;
    APoints[High(APoints)].Text := PayloadText;
  end;

  Result := Length(APoints) >= 2;
end;

procedure TMainForm.PopulateSampleRoute;
var
  Point: TRouteInput;
begin
  FRouteMemo.Lines.BeginUpdate;
  try
    FRouteMemo.Clear;
    for Point in SampleRoute do
    begin
      if Point.Kind = rikAddress then
        FRouteMemo.Lines.Add('A|' + Point.Text)
      else
        FRouteMemo.Lines.Add(Format('L|%s,%s', [
          FloatToStr(Point.Lat, TFormatSettings.Invariant),
          FloatToStr(Point.Lng, TFormatSettings.Invariant)
        ]));
    end;
  finally
    FRouteMemo.Lines.EndUpdate;
  end;
end;

procedure TMainForm.QueryHideButtonClick(Sender: TObject);
var
  Query: TGMRouteQuery;
begin
  Query := GetSelectedQuery;
  if not Assigned(Query) then
    Exit;
  Query.Visible := False;
  RefreshQueryList;
  RefreshResultList;
  Log('Query hidden: ' + Query.RequestId);
end;

procedure TMainForm.QueryListBoxClick(Sender: TObject);
begin
  RefreshResultList;
end;

procedure TMainForm.QueryShowButtonClick(Sender: TObject);
var
  Query: TGMRouteQuery;
begin
  Query := GetSelectedQuery;
  if not Assigned(Query) then
    Exit;
  Query.Visible := True;
  RefreshQueryList;
  RefreshResultList;
  Log('Query shown: ' + Query.RequestId);
end;

procedure TMainForm.RefreshQueryList;
var
  i: Integer;
  SelectedIndex: Integer;
begin
  SelectedIndex := FQueryListBox.ItemIndex;
  FQueryListBox.Items.BeginUpdate;
  try
    FQueryListBox.Clear;
    if not Assigned(FMap) then
      Exit;
    for i := 0 to FMap.Routes.QueryCount - 1 do
      FQueryListBox.Items.AddObject(DescribeQuery(FMap.Routes.Queries[i]), FMap.Routes.Queries[i]);
  finally
    FQueryListBox.Items.EndUpdate;
  end;

  if (SelectedIndex >= 0) and (SelectedIndex < FQueryListBox.Items.Count) then
    FQueryListBox.ItemIndex := SelectedIndex
  else if FQueryListBox.Items.Count > 0 then
    FQueryListBox.ItemIndex := FQueryListBox.Items.Count - 1;
end;

procedure TMainForm.RefreshResultList;
var
  i: Integer;
  Query: TGMRouteQuery;
  SelectedIndex: Integer;
begin
  Query := GetSelectedQuery;
  SelectedIndex := FResultListBox.ItemIndex;
  FResultListBox.Items.BeginUpdate;
  try
    FResultListBox.Clear;
    if not Assigned(Query) then
      Exit;
    for i := 0 to Query.Count - 1 do
      FResultListBox.Items.AddObject(DescribeResult(Query.ResultItems[i], i), Query.ResultItems[i]);
  finally
    FResultListBox.Items.EndUpdate;
  end;

  if (SelectedIndex >= 0) and (SelectedIndex < FResultListBox.Items.Count) then
    FResultListBox.ItemIndex := SelectedIndex
  else if FResultListBox.Items.Count > 0 then
    FResultListBox.ItemIndex := 0;
end;

procedure TMainForm.ResultHideButtonClick(Sender: TObject);
var
  Query: TGMRouteQuery;
  RouteResult: TGMRouteQueryResult;
begin
  Query := GetSelectedQuery;
  RouteResult := GetSelectedResult;
  if not Assigned(Query) or not Assigned(RouteResult) then
    Exit;
  RouteResult.Visible := False;
  RefreshQueryList;
  RefreshResultList;
  Log(Format('Result hidden: %s / %d', [Query.RequestId, FResultListBox.ItemIndex + 1]));
end;

procedure TMainForm.ResultListBoxClick(Sender: TObject);
begin
  RefreshResultList;
end;

procedure TMainForm.ResultShowButtonClick(Sender: TObject);
var
  Query: TGMRouteQuery;
  RouteResult: TGMRouteQueryResult;
begin
  Query := GetSelectedQuery;
  RouteResult := GetSelectedResult;
  if not Assigned(Query) or not Assigned(RouteResult) then
    Exit;
  RouteResult.Visible := True;
  RefreshQueryList;
  RefreshResultList;
  Log(Format('Result shown: %s / %d', [Query.RequestId, FResultListBox.ItemIndex + 1]));
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

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusLabel.Caption := AText;
end;

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  ConfigureMap;
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
  if FMap.Options.MapId = '' then
    Log('Map ID left empty. Routes will still try to run, but map styling may be limited.');
  SetMapCenter(43.0, 8.0);
  FMap.Options.Zoom := 5;

  if not FMap.Active then
  begin
    FMap.Active := True;
    Log('Map activation requested.');
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

end.

