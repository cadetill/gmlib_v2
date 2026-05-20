unit UGeoCodeMainForm;

{$HINTS OFF}

interface

uses
  System.Classes,
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
  uGMLib.GeoCode,
  uGMLib.Fmx.Map;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAddressEdit: TEdit;
    FAddressLabel: TLabel;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FBrowser: TWebBrowser;
    FCenterMapButton: TButton;
    FControlLayout: TLayout;
    FGeocodeAddressButton: TButton;
    FGeocodePlaceIdButton: TButton;
    FLatEdit: TEdit;
    FLatLabel: TLabel;
    FLanguageEdit: TEdit;
    FLanguageLabel: TLabel;
    FLngEdit: TEdit;
    FLngLabel: TLabel;
    FLoadSampleButton: TButton;
    FLogLayout: TLayout;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapReady: Boolean;
    FPlaceIdEdit: TEdit;
    FPlaceIdLabel: TLabel;
    FRegionEdit: TEdit;
    FRegionLabel: TLabel;
    FReverseGeocodeButton: TButton;
    FStatusLabel: TLabel;
    FStatusValueLabel: TLabel;
    procedure ActivateButtonClick(Sender: TObject);
    procedure AddressGeocodeButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure CenterMapButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure GeocodePlaceIdButtonClick(Sender: TObject);
    procedure HandleGeoCodeCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
    procedure HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    procedure ReverseGeocodeButtonClick(Sender: TObject);
    procedure SyncGeoCodeSettings;
    function TryReadFloat(const AEdit: TEdit; out AValue: Double): Boolean;
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

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib GeoCodeLab';
  Width := 1500;
  Height := 880;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 170;
  FControlLayout.Padding.Left := 12;
  FControlLayout.Padding.Top := 10;
  FControlLayout.Padding.Right := 12;
  FControlLayout.Padding.Bottom := 8;

  FAPIKeyLabel := TLabel.Create(Self);
  FAPIKeyLabel.Parent := FControlLayout;
  FAPIKeyLabel.Position.X := 12;
  FAPIKeyLabel.Position.Y := 6;
  FAPIKeyLabel.Text := 'API key';

  FAPIKeyEdit := TEdit.Create(Self);
  FAPIKeyEdit.Parent := FControlLayout;
  FAPIKeyEdit.Position.X := 12;
  FAPIKeyEdit.Position.Y := 30;
  FAPIKeyEdit.Width := 420;

  FLanguageLabel := TLabel.Create(Self);
  FLanguageLabel.Parent := FControlLayout;
  FLanguageLabel.Position.X := 452;
  FLanguageLabel.Position.Y := 6;
  FLanguageLabel.Text := 'Lang';

  FLanguageEdit := TEdit.Create(Self);
  FLanguageEdit.Parent := FControlLayout;
  FLanguageEdit.Position.X := 452;
  FLanguageEdit.Position.Y := 30;
  FLanguageEdit.Width := 70;

  FRegionLabel := TLabel.Create(Self);
  FRegionLabel.Parent := FControlLayout;
  FRegionLabel.Position.X := 540;
  FRegionLabel.Position.Y := 6;
  FRegionLabel.Text := 'Region';

  FRegionEdit := TEdit.Create(Self);
  FRegionEdit.Parent := FControlLayout;
  FRegionEdit.Position.X := 540;
  FRegionEdit.Position.Y := 30;
  FRegionEdit.Width := 70;

  FAddressLabel := TLabel.Create(Self);
  FAddressLabel.Parent := FControlLayout;
  FAddressLabel.Position.X := 12;
  FAddressLabel.Position.Y := 62;
  FAddressLabel.Text := 'Address';

  FAddressEdit := TEdit.Create(Self);
  FAddressEdit.Parent := FControlLayout;
  FAddressEdit.Position.X := 12;
  FAddressEdit.Position.Y := 86;
  FAddressEdit.Width := 520;

  FLatLabel := TLabel.Create(Self);
  FLatLabel.Parent := FControlLayout;
  FLatLabel.Position.X := 552;
  FLatLabel.Position.Y := 62;
  FLatLabel.Text := 'Lat';

  FLatEdit := TEdit.Create(Self);
  FLatEdit.Parent := FControlLayout;
  FLatEdit.Position.X := 552;
  FLatEdit.Position.Y := 86;
  FLatEdit.Width := 110;

  FLngLabel := TLabel.Create(Self);
  FLngLabel.Parent := FControlLayout;
  FLngLabel.Position.X := 676;
  FLngLabel.Position.Y := 62;
  FLngLabel.Text := 'Lng';

  FLngEdit := TEdit.Create(Self);
  FLngEdit.Parent := FControlLayout;
  FLngEdit.Position.X := 676;
  FLngEdit.Position.Y := 86;
  FLngEdit.Width := 110;

  FPlaceIdLabel := TLabel.Create(Self);
  FPlaceIdLabel.Parent := FControlLayout;
  FPlaceIdLabel.Position.X := 804;
  FPlaceIdLabel.Position.Y := 62;
  FPlaceIdLabel.Text := 'PlaceId';

  FPlaceIdEdit := TEdit.Create(Self);
  FPlaceIdEdit.Parent := FControlLayout;
  FPlaceIdEdit.Position.X := 804;
  FPlaceIdEdit.Position.Y := 86;
  FPlaceIdEdit.Width := 360;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 1180;
  FActivateButton.Position.Y := 30;
  FActivateButton.Width := 120;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FCenterMapButton := TButton.Create(Self);
  FCenterMapButton.Parent := FControlLayout;
  FCenterMapButton.Position.X := 1312;
  FCenterMapButton.Position.Y := 30;
  FCenterMapButton.Width := 120;
  FCenterMapButton.Text := 'Center map';
  FCenterMapButton.OnClick := CenterMapButtonClick;

  FGeocodeAddressButton := TButton.Create(Self);
  FGeocodeAddressButton.Parent := FControlLayout;
  FGeocodeAddressButton.Position.X := 1180;
  FGeocodeAddressButton.Position.Y := 64;
  FGeocodeAddressButton.Width := 120;
  FGeocodeAddressButton.Text := 'Geocode addr.';
  FGeocodeAddressButton.OnClick := AddressGeocodeButtonClick;

  FReverseGeocodeButton := TButton.Create(Self);
  FReverseGeocodeButton.Parent := FControlLayout;
  FReverseGeocodeButton.Position.X := 1312;
  FReverseGeocodeButton.Position.Y := 64;
  FReverseGeocodeButton.Width := 120;
  FReverseGeocodeButton.Text := 'Reverse';
  FReverseGeocodeButton.OnClick := ReverseGeocodeButtonClick;

  FGeocodePlaceIdButton := TButton.Create(Self);
  FGeocodePlaceIdButton.Parent := FControlLayout;
  FGeocodePlaceIdButton.Position.X := 1180;
  FGeocodePlaceIdButton.Position.Y := 98;
  FGeocodePlaceIdButton.Width := 120;
  FGeocodePlaceIdButton.Text := 'Geocode id';
  FGeocodePlaceIdButton.OnClick := GeocodePlaceIdButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FControlLayout;
  FLoadSampleButton.Position.X := 1312;
  FLoadSampleButton.Position.Y := 98;
  FLoadSampleButton.Width := 120;
  FLoadSampleButton.Text := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlLayout;
  FStatusLabel.Position.X := 12;
  FStatusLabel.Position.Y := 128;
  FStatusLabel.Text := 'Status';

  FStatusValueLabel := TLabel.Create(Self);
  FStatusValueLabel.Parent := FControlLayout;
  FStatusValueLabel.Position.X := 72;
  FStatusValueLabel.Position.Y := 128;
  FStatusValueLabel.Text := 'Ready';

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
  FLogMemo.Lines.Clear;
  FLogMemo.ShowScrollBars := True;

  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := Self;
  FBrowser.Align := TAlignLayout.Client;
end;

procedure TMainForm.CenterMapButtonClick(Sender: TObject);
var
  Latitude: Double;
  Longitude: Double;
  Coordinate: TMapLibLatLng;
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

  Coordinate := TMapLibLatLng.Create(Latitude, Longitude);
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
  FBrowser.WindowsEngine := TWindowsEngine.EdgeOnly;
  {$ENDIF}
end;

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
  FirstLocation: TMapLibLatLng;
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

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng;
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
  Center: TMapLibLatLng;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
  Center := TMapLibLatLng.Create(41.3874, 2.1686);
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
  Coordinate: TMapLibLatLng;
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

  Coordinate := TMapLibLatLng.Create(Latitude, Longitude);
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

function TMainForm.TryReadFloat(const AEdit: TEdit; out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(Trim(AEdit.Text), AValue, TFormatSettings.Invariant);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusValueLabel.Text := AText;
end;

end.

