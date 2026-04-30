unit UGeoCodeMainForm;

{$HINTS OFF}

interface

uses
  Winapi.ActiveX,
  Winapi.WebView2,
  Winapi.Windows,
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.TypInfo,
  Vcl.Controls,
  Vcl.Edge,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  uGMLib.Core.Types,
  uGMLib.GeoCode,
  uGMLib.Map,
  uGMLib.Vcl.Map;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAddressEdit: TEdit;
    FAddressLabel: TLabel;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FBrowser: TEdgeBrowser;
    FCenterMapButton: TButton;
    FControlPanel: TPanel;
    FGeocodeAddressButton: TButton;
    FGeocodePlaceIdButton: TButton;
    FLatEdit: TEdit;
    FLatLabel: TLabel;
    FLngEdit: TEdit;
    FLngLabel: TLabel;
    FLoadSampleButton: TButton;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapReady: Boolean;
    FPlaceIdEdit: TEdit;
    FPlaceIdLabel: TLabel;
    FRegionEdit: TEdit;
    FRegionLabel: TLabel;
    FReverseGeocodeButton: TButton;
    FStatusLabel: TLabel;
    FLanguageEdit: TEdit;
    FLanguageLabel: TLabel;
    procedure ActivateButtonClick(Sender: TObject);
    procedure AddressGeocodeButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure BuildUi;
    procedure CenterMapButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure GeocodePlaceIdButtonClick(Sender: TObject);
    procedure HandleGeoCodeCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
    procedure HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    procedure ReverseGeocodeButtonClick(Sender: TObject);
    procedure SyncGeoCodeSettings;
    function TryReadFloat(const AEdit: TCustomEdit; out AValue: Double): Boolean;
    procedure UpdateStatus(const AText: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

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
  SyncGeoCodeSettings;
  CenterMapButtonClick(nil);

  if not FMap.Active then
  begin
    FMap.Active := True;
    Log('Map activation requested.');
    UpdateStatus('Loading map...');
  end
  else
    Log('Map is already active.');
end;

procedure TMainForm.AddressGeocodeButtonClick(Sender: TObject);
begin
  if Trim(FAddressEdit.Text) = '' then
  begin
    Log('Address is empty.');
    Exit;
  end;

  SyncGeoCodeSettings;
  if not FMap.Active then
    ActivateButtonClick(nil);

  FMap.GeoCode.Address := Trim(FAddressEdit.Text);
  FMap.GeoCode.Geocode(FMap.GeoCode.Address);
  Log(Format('Geocode request sent for address: %s', [FMap.GeoCode.Address]));
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser;
  AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Log('WebView created.')
  else
    Log(Format('WebView creation failed. HRESULT=0x%.8x', [Cardinal(AResult)]));
end;

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib GeoCodeLab';
  Width := 1500;
  Height := 880;

  FControlPanel := TPanel.Create(Self);
  FControlPanel.Parent := Self;
  FControlPanel.Align := alTop;
  FControlPanel.Height := 170;
  FControlPanel.BevelOuter := bvNone;
  FControlPanel.Padding.Left := 12;
  FControlPanel.Padding.Top := 10;
  FControlPanel.Padding.Right := 12;
  FControlPanel.Padding.Bottom := 8;

  FAPIKeyLabel := TLabel.Create(Self);
  FAPIKeyLabel.Parent := FControlPanel;
  FAPIKeyLabel.SetBounds(12, 10, 60, 18);
  FAPIKeyLabel.Caption := 'API key';

  FAPIKeyEdit := TEdit.Create(Self);
  FAPIKeyEdit.Parent := FControlPanel;
  FAPIKeyEdit.SetBounds(12, 34, 420, 24);

  FLanguageLabel := TLabel.Create(Self);
  FLanguageLabel.Parent := FControlPanel;
  FLanguageLabel.SetBounds(452, 10, 60, 18);
  FLanguageLabel.Caption := 'Lang';

  FLanguageEdit := TEdit.Create(Self);
  FLanguageEdit.Parent := FControlPanel;
  FLanguageEdit.SetBounds(452, 34, 70, 24);

  FRegionLabel := TLabel.Create(Self);
  FRegionLabel.Parent := FControlPanel;
  FRegionLabel.SetBounds(540, 10, 60, 18);
  FRegionLabel.Caption := 'Region';

  FRegionEdit := TEdit.Create(Self);
  FRegionEdit.Parent := FControlPanel;
  FRegionEdit.SetBounds(540, 34, 70, 24);

  FAddressLabel := TLabel.Create(Self);
  FAddressLabel.Parent := FControlPanel;
  FAddressLabel.SetBounds(12, 66, 80, 18);
  FAddressLabel.Caption := 'Address';

  FAddressEdit := TEdit.Create(Self);
  FAddressEdit.Parent := FControlPanel;
  FAddressEdit.SetBounds(12, 90, 520, 24);

  FLatLabel := TLabel.Create(Self);
  FLatLabel.Parent := FControlPanel;
  FLatLabel.SetBounds(552, 66, 70, 18);
  FLatLabel.Caption := 'Lat';

  FLatEdit := TEdit.Create(Self);
  FLatEdit.Parent := FControlPanel;
  FLatEdit.SetBounds(552, 90, 110, 24);

  FLngLabel := TLabel.Create(Self);
  FLngLabel.Parent := FControlPanel;
  FLngLabel.SetBounds(676, 66, 70, 18);
  FLngLabel.Caption := 'Lng';

  FLngEdit := TEdit.Create(Self);
  FLngEdit.Parent := FControlPanel;
  FLngEdit.SetBounds(676, 90, 110, 24);

  FPlaceIdLabel := TLabel.Create(Self);
  FPlaceIdLabel.Parent := FControlPanel;
  FPlaceIdLabel.SetBounds(804, 66, 80, 18);
  FPlaceIdLabel.Caption := 'PlaceId';

  FPlaceIdEdit := TEdit.Create(Self);
  FPlaceIdEdit.Parent := FControlPanel;
  FPlaceIdEdit.SetBounds(804, 90, 360, 24);

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlPanel;
  FActivateButton.SetBounds(1180, 32, 120, 26);
  FActivateButton.Caption := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FCenterMapButton := TButton.Create(Self);
  FCenterMapButton.Parent := FControlPanel;
  FCenterMapButton.SetBounds(1312, 32, 120, 26);
  FCenterMapButton.Caption := 'Center map';
  FCenterMapButton.OnClick := CenterMapButtonClick;

  FGeocodeAddressButton := TButton.Create(Self);
  FGeocodeAddressButton.Parent := FControlPanel;
  FGeocodeAddressButton.SetBounds(1180, 66, 120, 26);
  FGeocodeAddressButton.Caption := 'Geocode addr.';
  FGeocodeAddressButton.OnClick := AddressGeocodeButtonClick;

  FReverseGeocodeButton := TButton.Create(Self);
  FReverseGeocodeButton.Parent := FControlPanel;
  FReverseGeocodeButton.SetBounds(1312, 66, 120, 26);
  FReverseGeocodeButton.Caption := 'Reverse';
  FReverseGeocodeButton.OnClick := ReverseGeocodeButtonClick;

  FGeocodePlaceIdButton := TButton.Create(Self);
  FGeocodePlaceIdButton.Parent := FControlPanel;
  FGeocodePlaceIdButton.SetBounds(1180, 100, 120, 26);
  FGeocodePlaceIdButton.Caption := 'Geocode id';
  FGeocodePlaceIdButton.OnClick := GeocodePlaceIdButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FControlPanel;
  FLoadSampleButton.SetBounds(1312, 100, 120, 26);
  FLoadSampleButton.Caption := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlPanel;
  FStatusLabel.SetBounds(12, 126, 600, 18);
  FStatusLabel.Caption := 'Ready';

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := Self;
  FLogMemo.Align := alBottom;
  FLogMemo.Height := 220;
  FLogMemo.ReadOnly := True;
  FLogMemo.ScrollBars := ssVertical;
  FLogMemo.Lines.Clear;

  FBrowser := TEdgeBrowser.Create(Self);
  FBrowser.Parent := Self;
  FBrowser.Align := alClient;
end;

procedure TMainForm.CenterMapButtonClick(Sender: TObject);
var
  Latitude: Double;
  Longitude: Double;
  Coordinate: TGMLibLatLng;
begin
  if not TryReadFloat(FLatEdit, Latitude) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryReadFloat(FLngEdit, Longitude) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  Coordinate := TGMLibLatLng.Create(Latitude, Longitude);
  try
    FMap.GeoCode.Location.Assign(Coordinate);
    FMap.CenterMapTo(Coordinate);
  finally
    Coordinate.Free;
  end;

  Log(Format('Map center requested at %s, %s', [
    FloatToStr(Latitude, TFormatSettings.Invariant),
    FloatToStr(Longitude, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.ConfigureBrowser;
begin
  {$IFDEF MSWINDOWS}
  SetBooleanPropertyIfPublished(FBrowser, 'AllowSingleSignOnUsingOSPrimaryAccount', False);
  SetStringPropertyIfPublished(FBrowser, 'TargetCompatibleBrowserVersion', '117.0.2045.28');
  SetStringPropertyIfPublished(FBrowser, 'UserDataFolder', '%LOCALAPPDATA%\bds.exe.WebView2');
  {$ENDIF}
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BuildUi;
  ConfigureBrowser;
  InitializeMap;
  InitializeDefaults;
  FBrowser.OnCreateWebViewCompleted := BrowserCreateWebViewCompleted;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;

  if Assigned(FBrowser) then
    FBrowser.CloseWebView;
  FMap.Free;
  inherited;
end;

procedure TMainForm.GeocodePlaceIdButtonClick(Sender: TObject);
begin
  if Trim(FPlaceIdEdit.Text) = '' then
  begin
    Log('PlaceId is empty.');
    Exit;
  end;

  SyncGeoCodeSettings;
  if not FMap.Active then
    ActivateButtonClick(nil);

  FMap.GeoCode.PlaceId := Trim(FPlaceIdEdit.Text);
  FMap.GeoCode.GeocodePlaceId(FMap.GeoCode.PlaceId);
  Log(Format('Geocode request sent for placeId: %s', [FMap.GeoCode.PlaceId]));
end;

procedure TMainForm.HandleGeoCodeCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
var
  FirstLocation: TGMLibLatLng;
  i: Integer;
  ResultItem: TGMGeocodeResult;
begin
  Log(Format('Geocode completed. requestId=%s status=%s results=%d', [
    AResponse.RequestId,
    AResponse.Status,
    Length(AResponse.Results)
  ]));

  if AResponse.ErrorMessage <> '' then
    Log('Error: ' + AResponse.ErrorMessage);

  for i := 0 to High(AResponse.Results) do
  begin
    ResultItem := AResponse.Results[i];
    Log(Format('  #%d %s | placeId=%s | loc=(%s,%s) | type=%s | partial=%s | types=%s', [
      i + 1,
      ResultItem.FormattedAddress,
      ResultItem.PlaceId,
      FloatToStr(ResultItem.Latitude, TFormatSettings.Invariant),
      FloatToStr(ResultItem.Longitude, TFormatSettings.Invariant),
      ResultItem.LocationType,
      BoolToStr(ResultItem.PartialMatch, True),
      ResultItem.TypesText
    ]));
  end;

  if AResponse.TryGetFirstLocation(FirstLocation) then
  try
    FLatEdit.Text := FloatToStr(FirstLocation.Lat, TFormatSettings.Invariant);
    FLngEdit.Text := FloatToStr(FirstLocation.Lng, TFormatSettings.Invariant);
    FMap.CenterMapTo(FirstLocation);
    if FMap.Options.Zoom < 14 then
      FMap.Options.Zoom := 14;
    Log('Map centered to the first geocode result.');
  finally
    FirstLocation.Free;
  end;
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng;
  const APlaceId: string);
var
  PlaceIdText: string;
begin
  if not Assigned(ALatLng) then
    Exit;

  FLatEdit.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  FLngEdit.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);
  FMap.GeoCode.Location.Assign(ALatLng);
  PlaceIdText := APlaceId;
  if PlaceIdText = '' then
    PlaceIdText := '<none>';
  Log(Format('Map click at %s, %s (placeId=%s)', [
    FLatEdit.Text,
    FLngEdit.Text,
    PlaceIdText
  ]));
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  FMapReady := True;
  Log('Map ready');
  UpdateStatus('Map ready');
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FLanguageEdit.Text := 'es';
  FRegionEdit.Text := 'es';
  FAddressEdit.Text := 'Placa de Catalunya, Barcelona';
  FLatEdit.Text := '41.3874';
  FLngEdit.Text := '2.1686';
  FPlaceIdEdit.Text := '';
  SyncGeoCodeSettings;
  UpdateStatus('Ready');
  Log('GeoCodeLab initialized.');
end;

procedure TMainForm.InitializeMap;
var
  Center: TGMLibLatLng;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
  Center := TGMLibLatLng.Create(41.3874, 2.1686);
  try
    FMap.Options.Center.Assign(Center);
    FMap.GeoCode.Location.Assign(Center);
  finally
    Center.Free;
  end;
  FMap.Options.Zoom := 12;
  FMap.Options.MapTypeControl := True;
  FMap.Options.ZoomControl := True;
  FMap.OnMapClick := HandleMapClick;
  FMap.OnMapReady := HandleMapReady;
  FMap.GeoCode.OnCompleted := HandleGeoCodeCompleted;
  FMap.GeoCode.Language := Trim(FLanguageEdit.Text);
  FMap.GeoCode.Region := Trim(FRegionEdit.Text);
end;

procedure TMainForm.LoadSampleButtonClick(Sender: TObject);
begin
  InitializeDefaults;
  SyncGeoCodeSettings;
  CenterMapButtonClick(nil);
  Log('Sample values loaded.');
end;

procedure TMainForm.Log(const AText: string);
begin
  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainForm.ReverseGeocodeButtonClick(Sender: TObject);
var
  Latitude: Double;
  Longitude: Double;
  Coordinate: TGMLibLatLng;
begin
  SyncGeoCodeSettings;
  if not FMap.Active then
    ActivateButtonClick(nil);

  if not TryReadFloat(FLatEdit, Latitude) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryReadFloat(FLngEdit, Longitude) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  Coordinate := TGMLibLatLng.Create(Latitude, Longitude);
  try
    FMap.GeoCode.Location.Assign(Coordinate);
    FMap.GeoCode.ReverseGeocode(Coordinate);
  finally
    Coordinate.Free;
  end;

  Log(Format('Reverse geocode request sent for %s, %s', [
    FLatEdit.Text,
    FLngEdit.Text
  ]));
end;

procedure TMainForm.SyncGeoCodeSettings;
begin
  FMap.GeoCode.Language := Trim(FLanguageEdit.Text);
  FMap.GeoCode.Region := Trim(FRegionEdit.Text);
end;

function TMainForm.TryReadFloat(const AEdit: TCustomEdit; out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(Trim(AEdit.Text), AValue, TFormatSettings.Invariant);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusLabel.Caption := 'Status: ' + AText;
end;

end.
