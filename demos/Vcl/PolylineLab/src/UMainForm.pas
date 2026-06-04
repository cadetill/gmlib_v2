unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.StrUtils, System.SysUtils, System.Variants, System.Classes,
  System.Types, System.TypInfo, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
   Vcl.Edge, Winapi.WebView2, uGMLib.Core.Types, uGMLib.Google.Types, uGMLib.Vcl.Map, uGMLib.Vcl.Polyline,
  Winapi.ActiveX;

type
  TPolylineCoordinate = record
    Lat: Double;
    Lng: Double;
  end;

  TMainForm = class(TForm)
    TopPanel: TPanel;
    APIKeyLabel: TLabel;
    CenterLatLabel: TLabel;
    CenterLngLabel: TLabel;
    ZoomLabel: TLabel;
    StatusTitleLabel: TLabel;
    StatusValueLabel: TLabel;
    APIKeyEdit: TEdit;
    CenterLatEdit: TEdit;
    CenterLngEdit: TEdit;
    ZoomEdit: TEdit;
    ApplyViewButton: TButton;
    ActivateButton: TButton;
    LeftPanel: TPanel;
    PathLabel: TLabel;
    PathMemo: TMemo;
    PolylineButtonsPanel: TPanel;
    LoadSampleButton: TButton;
    ApplyPolylineButton: TButton;
    ZoomToPolylineButton: TButton;
    ClearPolylineButton: TButton;
    PolylineOptionsGroup: TGroupBox;
    VisibleCheckBox: TCheckBox;
    EditableCheckBox: TCheckBox;
    DraggableCheckBox: TCheckBox;
    StrokeColorLabel: TLabel;
    StrokeWeightLabel: TLabel;
    StrokeOpacityLabel: TLabel;
    StrokeColorBox: TColorBox;
    StrokeWeightEdit: TEdit;
    StrokeOpacityEdit: TEdit;
    Browser: TEdgeBrowser;
    Splitter1: TSplitter;
    LogPanel: TPanel;
    LogMemo: TMemo;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyPolylineButtonClick(Sender: TObject);
    procedure ApplyViewButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure ClearPolylineButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure ZoomToPolylineButtonClick(Sender: TObject);
  private
    FLastCenterSignature: string;
    FLastZoomSignature: string;
    FMap: TGMLibMap;
    FPrimaryPolyline: TGMVclPolylineItem;
    FUpdatingPathMemo: Boolean;
    procedure AttachPolylineHandlers(APolyline: TGMVclPolylineItem);
    procedure EnsurePrimaryPolyline;
    function ParsePathMemo(out ACoordinates: TArray<TPolylineCoordinate>): Boolean;
    procedure PopulateSamplePath;
    procedure RebindPrimaryPolyline;
    procedure UpdatePathMemoFromPolyline;
  protected
    procedure HandleCenterChanged(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandlePolylineClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineDrag(Sender: TObject);
    procedure HandlePolylineDragEnd(Sender: TObject);
    procedure HandlePolylineDragStart(Sender: TObject);
    procedure HandlePolylinePathChanged(Sender: TObject);
    procedure HandleZoomChanged(Sender: TObject; AZoom: Integer);
    procedure InitializeDefaultValues;
    procedure InitializeMap;
    procedure Log(const AText: string);
    procedure UpdateStatus(const AText: string);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
{$HINTS OFF}

procedure SetBooleanPropertyIfPublished(AInstance: TObject; const APropertyName: string; const AValue: Boolean);
var
  PropInfo: PPropInfo;
begin
  if not Assigned(AInstance) then
    Exit;

  PropInfo := GetPropInfo(AInstance, APropertyName);
  if Assigned(PropInfo) then
    SetOrdProp(AInstance, PropInfo, Ord(AValue));
end;

procedure SetStringPropertyIfPublished(AInstance: TObject; const APropertyName, AValue: string);
var
  PropInfo: PPropInfo;
begin
  if not Assigned(AInstance) then
    Exit;

  PropInfo := GetPropInfo(AInstance, APropertyName);
  if Assigned(PropInfo) then
    SetStrProp(AInstance, PropInfo, AValue);
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
  FMap.APIKey := Trim(APIKeyEdit.Text);
  ApplyViewButtonClick(nil);

  if not FMap.Active then
  begin
    FMap.Active := True;
    Log('Map activation requested.');
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

  if not TryStrToFloat(Trim(StrokeOpacityEdit.Text), Opacity, TFormatSettings.Invariant) then
  begin
    Log('Invalid stroke opacity value.');
    Exit;
  end;

  if not TryStrToInt(Trim(StrokeWeightEdit.Text), Weight) then
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

    FPrimaryPolyline.Options.Visible := VisibleCheckBox.Checked;
    FPrimaryPolyline.Options.Editable := EditableCheckBox.Checked;
    FPrimaryPolyline.Options.Draggable := DraggableCheckBox.Checked;
    FPrimaryPolyline.Options.StrokeColor := StrokeColorBox.Selected;
    FPrimaryPolyline.Options.StrokeOpacity := Opacity;
    FPrimaryPolyline.Options.StrokeWeight := Weight;
  finally
    FMap.Polylines.EndUpdate;
  end;

  Log(Format('Polyline applied with %d points.', [Length(Coordinates)]));
end;

procedure TMainForm.ApplyViewButtonClick(Sender: TObject);
var
  Center: TMapLibLatLng;
  Latitude: Double;
  Longitude: Double;
  ZoomLevel: Integer;
begin
  if not TryStrToFloat(Trim(CenterLatEdit.Text), Latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(CenterLngEdit.Text), Longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  if not TryStrToInt(Trim(ZoomEdit.Text), ZoomLevel) then
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

procedure TMainForm.AttachPolylineHandlers(APolyline: TGMVclPolylineItem);
begin
  if not Assigned(APolyline) then
    Exit;

  APolyline.OnClick := HandlePolylineClick;
  APolyline.OnDrag := HandlePolylineDrag;
  APolyline.OnDragEnd := HandlePolylineDragEnd;
  APolyline.OnDragStart := HandlePolylineDragStart;
  APolyline.OnPathChanged := HandlePolylinePathChanged;
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Log('WebView created.')
  else
    Log(Format('WebView creation failed. HRESULT=0x%.8x', [Cardinal(AResult)]));
end;

procedure TMainForm.ClearPolylineButtonClick(Sender: TObject);
begin
  FMap.Polylines.Clear;
  FPrimaryPolyline := nil;
  Log('All polylines cleared.');
end;

procedure TMainForm.EnsurePrimaryPolyline;
begin
  if Assigned(FPrimaryPolyline) and (FPrimaryPolyline.Collection = FMap.Polylines) then
    Exit;

  if FMap.Polylines.Count = 0 then
    FPrimaryPolyline := FMap.Polylines.Add
  else
    FPrimaryPolyline := FMap.Polylines[0];

  AttachPolylineHandlers(FPrimaryPolyline);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SetBooleanPropertyIfPublished(Browser, 'AllowSingleSignOnUsingOSPrimaryAccount', False);
  SetStringPropertyIfPublished(Browser, 'TargetCompatibleBrowserVersion', '117.0.2045.28');
  SetStringPropertyIfPublished(Browser, 'UserDataFolder', '%LOCALAPPDATA%\bds.exe.WebView2');

  InitializeMap;
  InitializeDefaultValues;
  PopulateSamplePath;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FMap) then
  begin
    FMap.Active := False;
    FreeAndNil(FMap);
  end;

  if Assigned(Browser) then
  begin
    Browser.OnCreateWebViewCompleted := nil;
    Browser.OnNavigationCompleted := nil;
    Browser.OnWebMessageReceived := nil;
    Browser.CloseWebView;
  end;

end;

procedure TMainForm.HandleCenterChanged(Sender: TObject; ALatLng: TMapLibLatLng);
var
  Signature: string;
begin
  CenterLatEdit.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  CenterLngEdit.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);

  Signature := Format('%.6f,%.6f', [ALatLng.Lat, ALatLng.Lng], TFormatSettings.Invariant);
  if Signature = FLastCenterSignature then
    Exit;

  FLastCenterSignature := Signature;
  Log(Format('Center changed from map: %s, %s', [CenterLatEdit.Text, CenterLngEdit.Text]));
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
  Log('Map ready event received.');
end;

procedure TMainForm.HandlePolylineClick(Sender: TObject; ALatLng: TMapLibLatLng);
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

procedure TMainForm.HandleZoomChanged(Sender: TObject; AZoom: Integer);
var
  Signature: string;
begin
  ZoomEdit.Text := IntToStr(AZoom);
  Signature := ZoomEdit.Text;
  if Signature = FLastZoomSignature then
    Exit;

  FLastZoomSignature := Signature;
  Log(Format('Zoom changed from map: %d', [AZoom]));
end;

procedure TMainForm.InitializeDefaultValues;
begin
  APIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  CenterLatEdit.Text := '41.3874';
  CenterLngEdit.Text := '2.1686';
  ZoomEdit.Text := '6';
  VisibleCheckBox.Checked := True;
  EditableCheckBox.Checked := True;
  DraggableCheckBox.Checked := False;
  StrokeColorBox.Selected := clRed;
  StrokeOpacityEdit.Text := '0.85';
  StrokeWeightEdit.Text := '4';
  UpdateStatus('Ready');
  Log('Polyline demo initialized. Review the sample path and press Activate map.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := Browser;
  FMap.Options.MapTypeControl := True;
  FMap.Options.MapTypeControlOptions.Position := cpTopRight;
  FMap.Options.ZoomControl := True;
  FMap.Options.ZoomControlOptions.Position := cpLeftCenter;
  FMap.OnCenterChanged := HandleCenterChanged;
  FMap.OnMapClick := HandleMapClick;
  FMap.OnMapReady := HandleMapReady;
  FMap.OnZoomChanged := HandleZoomChanged;
end;

procedure TMainForm.LoadSampleButtonClick(Sender: TObject);
begin
  PopulateSamplePath;
  Log('Sample path loaded into the editor.');
end;

procedure TMainForm.Log(const AText: string);
begin
  while LogMemo.Lines.Count >= 500 do
    LogMemo.Lines.Delete(0);

  LogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

function TMainForm.ParsePathMemo(out ACoordinates: TArray<TPolylineCoordinate>): Boolean;
var
  Coordinate: TPolylineCoordinate;
  i: Integer;
  Latitude: Double;
  Longitude: Double;
  Line: string;
begin
  SetLength(ACoordinates, 0);

  for i := 0 to PathMemo.Lines.Count - 1 do
  begin
    Line := Trim(PathMemo.Lines[i]);
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
  PathMemo.Lines.BeginUpdate;
  try
    PathMemo.Lines.Text :=
      '41.3874,2.1686' + sLineBreak +
      '41.9028,12.4964' + sLineBreak +
      '45.4642,9.1900' + sLineBreak +
      '48.8566,2.3522';
  finally
    PathMemo.Lines.EndUpdate;
  end;
end;

procedure TMainForm.RebindPrimaryPolyline;
begin
  if FMap.Polylines.Count = 0 then
    FPrimaryPolyline := nil
  else
    FPrimaryPolyline := FMap.Polylines[0];

  AttachPolylineHandlers(FPrimaryPolyline);
end;

procedure TMainForm.UpdatePathMemoFromPolyline;
var
  i: Integer;
begin
  if FUpdatingPathMemo or not Assigned(FPrimaryPolyline) then
    Exit;

  FUpdatingPathMemo := True;
  try
    PathMemo.Lines.BeginUpdate;
    try
      PathMemo.Clear;
      for i := 0 to FPrimaryPolyline.Options.Path.Count - 1 do
        PathMemo.Lines.Add(Format('%.6f,%.6f', [
          FPrimaryPolyline.Options.Path[i].Lat,
          FPrimaryPolyline.Options.Path[i].Lng
        ], TFormatSettings.Invariant));
    finally
      PathMemo.Lines.EndUpdate;
    end;
  finally
    FUpdatingPathMemo := False;
  end;
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  StatusValueLabel.Caption := AText;
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

