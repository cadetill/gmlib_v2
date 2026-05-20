unit URoutesMainForm;

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
  uGMLib.Map,
  uGMLib.Routes,
  uGMLib.Fmx.Map;

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
    FBrowser: TWebBrowser;
    FClearButton: TButton;
    FComputeButton: TButton;
    FFieldsEdit: TEdit;
    FFieldsLabel: TLabel;
    FLoadSampleButton: TButton;
    FLogLayout: TLayout;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapIdEdit: TEdit;
    FMapIdLabel: TLabel;
    FMapLayout: TLayout;
    FQueryHideButton: TButton;
    FQueryList: TListBox;
    FQueryListLabel: TLabel;
    FQueryShowButton: TButton;
    FResultHideButton: TButton;
    FResultList: TListBox;
    FResultListLabel: TLabel;
    FResultShowButton: TButton;
    FRouteLayout: TLayout;
    FRouteMemo: TMemo;
    FRouteMemoLabel: TLabel;
    FRoutesLayout: TLayout;
    FStatusLabel: TLabel;
    FTopLayout: TLayout;
    procedure ActivateButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ClearButtonClick(Sender: TObject);
    procedure ComputeButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
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
    procedure QueryListChange(Sender: TObject);
    procedure QueryShowButtonClick(Sender: TObject);
    procedure RefreshQueryList;
    procedure RefreshResultList;
    procedure ResultHideButtonClick(Sender: TObject);
    procedure ResultListChange(Sender: TObject);
    procedure ResultShowButtonClick(Sender: TObject);
    procedure SetMapCenter(const ALatitude, ALongitude: Double);
    procedure UpdateStatus(const AText: string);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); override;
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

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
  FMap.Routes.RequestFields := Trim(FFieldsEdit.Text);
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

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Routes Lab';
  Width := 1440;
  Height := 860;

  FTopLayout := TLayout.Create(Self);
  FTopLayout.Parent := Self;
  FTopLayout.Align := TAlignLayout.Top;
  FTopLayout.Height := 94;
  FTopLayout.Padding.Left := 12;
  FTopLayout.Padding.Top := 10;
  FTopLayout.Padding.Right := 12;
  FTopLayout.Padding.Bottom := 8;

  FAPIKeyLabel := TLabel.Create(Self);
  FAPIKeyLabel.Parent := FTopLayout;
  FAPIKeyLabel.Position.X := 4;
  FAPIKeyLabel.Position.Y := 4;
  FAPIKeyLabel.Text := 'API key';

  FAPIKeyEdit := TEdit.Create(Self);
  FAPIKeyEdit.Parent := FTopLayout;
  FAPIKeyEdit.Position.X := 4;
  FAPIKeyEdit.Position.Y := 28;
  FAPIKeyEdit.Width := 360;

  FMapIdLabel := TLabel.Create(Self);
  FMapIdLabel.Parent := FTopLayout;
  FMapIdLabel.Position.X := 382;
  FMapIdLabel.Position.Y := 4;
  FMapIdLabel.Text := 'Map ID';

  FMapIdEdit := TEdit.Create(Self);
  FMapIdEdit.Parent := FTopLayout;
  FMapIdEdit.Position.X := 382;
  FMapIdEdit.Position.Y := 28;
  FMapIdEdit.Width := 180;

  FFieldsLabel := TLabel.Create(Self);
  FFieldsLabel.Parent := FTopLayout;
  FFieldsLabel.Position.X := 582;
  FFieldsLabel.Position.Y := 4;
  FFieldsLabel.Text := 'Request fields';

  FFieldsEdit := TEdit.Create(Self);
  FFieldsEdit.Parent := FTopLayout;
  FFieldsEdit.Position.X := 582;
  FFieldsEdit.Position.Y := 28;
  FFieldsEdit.Width := 408;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FTopLayout;
  FActivateButton.Position.X := 1002;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 110;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FTopLayout;
  FLoadSampleButton.Position.X := 1120;
  FLoadSampleButton.Position.Y := 26;
  FLoadSampleButton.Width := 120;
  FLoadSampleButton.Text := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  FComputeButton := TButton.Create(Self);
  FComputeButton.Parent := FTopLayout;
  FComputeButton.Position.X := 4;
  FComputeButton.Position.Y := 60;
  FComputeButton.Width := 110;
  FComputeButton.Text := 'Compute route';
  FComputeButton.OnClick := ComputeButtonClick;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FTopLayout;
  FClearButton.Position.X := 128;
  FClearButton.Position.Y := 60;
  FClearButton.Width := 94;
  FClearButton.Text := 'Clear route';
  FClearButton.OnClick := ClearButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FTopLayout;
  FStatusLabel.Position.X := 236;
  FStatusLabel.Position.Y := 64;
  FStatusLabel.Text := 'Ready';

  FLogLayout := TLayout.Create(Self);
  FLogLayout.Parent := Self;
  FLogLayout.Align := TAlignLayout.Bottom;
  FLogLayout.Height := 200;
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

  FRouteLayout := TLayout.Create(Self);
  FRouteLayout.Parent := Self;
  FRouteLayout.Align := TAlignLayout.Left;
  FRouteLayout.Width := 340;

  FRouteMemoLabel := TLabel.Create(Self);
  FRouteMemoLabel.Parent := FRouteLayout;
  FRouteMemoLabel.Align := TAlignLayout.Top;
  FRouteMemoLabel.Text := 'Route request';
  FRouteMemoLabel.Height := 24;

  FRouteMemo := TMemo.Create(Self);
  FRouteMemo.Parent := FRouteLayout;
  FRouteMemo.Align := TAlignLayout.Client;
  FRouteMemo.WordWrap := False;
  FRouteMemo.ShowScrollBars := True;

  FRoutesLayout := TLayout.Create(Self);
  FRoutesLayout.Parent := Self;
  FRoutesLayout.Align := TAlignLayout.Right;
  FRoutesLayout.Width := 320;

  FQueryListLabel := TLabel.Create(Self);
  FQueryListLabel.Parent := FRoutesLayout;
  FQueryListLabel.Align := TAlignLayout.Top;
  FQueryListLabel.Height := 24;
  FQueryListLabel.Text := 'Stored queries';

  FQueryShowButton := TButton.Create(Self);
  FQueryShowButton.Parent := FRoutesLayout;
  FQueryShowButton.Align := TAlignLayout.Top;
  FQueryShowButton.Height := 28;
  FQueryShowButton.Text := 'Show query';
  FQueryShowButton.OnClick := QueryShowButtonClick;

  FQueryHideButton := TButton.Create(Self);
  FQueryHideButton.Parent := FRoutesLayout;
  FQueryHideButton.Align := TAlignLayout.Top;
  FQueryHideButton.Height := 28;
  FQueryHideButton.Text := 'Hide query';
  FQueryHideButton.OnClick := QueryHideButtonClick;

  FQueryList := TListBox.Create(Self);
  FQueryList.Parent := FRoutesLayout;
  FQueryList.Align := TAlignLayout.Top;
  FQueryList.Height := 220;
  FQueryList.OnChange := QueryListChange;

  FResultListLabel := TLabel.Create(Self);
  FResultListLabel.Parent := FRoutesLayout;
  FResultListLabel.Align := TAlignLayout.Top;
  FResultListLabel.Height := 24;
  FResultListLabel.Text := 'Query results';

  FResultShowButton := TButton.Create(Self);
  FResultShowButton.Parent := FRoutesLayout;
  FResultShowButton.Align := TAlignLayout.Top;
  FResultShowButton.Height := 28;
  FResultShowButton.Text := 'Show result';
  FResultShowButton.OnClick := ResultShowButtonClick;

  FResultHideButton := TButton.Create(Self);
  FResultHideButton.Parent := FRoutesLayout;
  FResultHideButton.Align := TAlignLayout.Top;
  FResultHideButton.Height := 28;
  FResultHideButton.Text := 'Hide result';
  FResultHideButton.OnClick := ResultHideButtonClick;

  FResultList := TListBox.Create(Self);
  FResultList.Parent := FRoutesLayout;
  FResultList.Align := TAlignLayout.Client;
  FResultList.OnChange := ResultListChange;

  FMapLayout := TLayout.Create(Self);
  FMapLayout.Parent := Self;
  FMapLayout.Align := TAlignLayout.Client;

  FMap := TGMLibMap.Create(Self);
  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := FMapLayout;
  FBrowser.Align := TAlignLayout.Client;
  FBrowser.WindowsEngine := TWindowsEngine.EdgeOnly;
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

procedure TMainForm.ConfigureBrowser;
begin
  FBrowser.WindowsEngine := TWindowsEngine.EdgeOnly;
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
  if (FQueryList.ItemIndex < 0) or (FQueryList.ItemIndex >= FMap.Routes.QueryCount) then
    Exit;
  Result := FMap.Routes.Queries[FQueryList.ItemIndex];
end;

function TMainForm.GetSelectedResult: TGMRouteQueryResult;
var
  Query: TGMRouteQuery;
begin
  Result := nil;
  Query := GetSelectedQuery;
  if not Assigned(Query) then
    Exit;
  if (FResultList.ItemIndex < 0) or (FResultList.ItemIndex >= Query.Count) then
    Exit;
  Result := Query.ResultItems[FResultList.ItemIndex];
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
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
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
    FRouteMemo.Lines.Clear;
    for Point in SampleRoute do
      if Point.Kind = rikAddress then
        FRouteMemo.Lines.Add('A|' + Point.Text)
      else
        FRouteMemo.Lines.Add(Format('L|%s,%s', [
          FloatToStr(Point.Lat, TFormatSettings.Invariant),
          FloatToStr(Point.Lng, TFormatSettings.Invariant)
        ]));
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

procedure TMainForm.QueryListChange(Sender: TObject);
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
  Item: TListBoxItem;
  SelectedIndex: Integer;
begin
  SelectedIndex := FQueryList.ItemIndex;
  FQueryList.BeginUpdate;
  try
    FQueryList.Clear;
    if not Assigned(FMap) then
      Exit;
    for i := 0 to FMap.Routes.QueryCount - 1 do
    begin
      Item := TListBoxItem.Create(FQueryList);
      Item.Text := DescribeQuery(FMap.Routes.Queries[i]);
      FQueryList.AddObject(Item);
    end;
  finally
    FQueryList.EndUpdate;
  end;

  if (SelectedIndex >= 0) and (SelectedIndex < FQueryList.Count) then
    FQueryList.ItemIndex := SelectedIndex
  else if FQueryList.Count > 0 then
    FQueryList.ItemIndex := FQueryList.Count - 1;
end;

procedure TMainForm.RefreshResultList;
var
  i: Integer;
  Item: TListBoxItem;
  Query: TGMRouteQuery;
  SelectedIndex: Integer;
begin
  Query := GetSelectedQuery;
  SelectedIndex := FResultList.ItemIndex;
  FResultList.BeginUpdate;
  try
    FResultList.Clear;
    if not Assigned(Query) then
      Exit;
    for i := 0 to Query.Count - 1 do
    begin
      Item := TListBoxItem.Create(FResultList);
      Item.Text := DescribeResult(Query.ResultItems[i], i);
      FResultList.AddObject(Item);
    end;
  finally
    FResultList.EndUpdate;
  end;

  if (SelectedIndex >= 0) and (SelectedIndex < FResultList.Count) then
    FResultList.ItemIndex := SelectedIndex
  else if FResultList.Count > 0 then
    FResultList.ItemIndex := 0;
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
  Log(Format('Result hidden: %s / %d', [Query.RequestId, FResultList.ItemIndex + 1]));
end;

procedure TMainForm.ResultListChange(Sender: TObject);
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
  Log(Format('Result shown: %s / %d', [Query.RequestId, FResultList.ItemIndex + 1]));
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
  FStatusLabel.Text := AText;
end;

end.

