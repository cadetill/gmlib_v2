unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.StrUtils, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.WebView2, Winapi.ActiveX, Vcl.Edge, System.TypInfo,
  uGMLib.Core.Types,
  uGMLib.Vcl.Map;

type
  TMainForm = class(TForm)
    ControlPanel: TPanel;
    APIKeyLabel: TLabel;
    CenterLatLabel: TLabel;
    CenterLngLabel: TLabel;
    ZoomLabel: TLabel;
    StatusLabel: TLabel;
    APIKeyEdit: TEdit;
    CenterLatEdit: TEdit;
    CenterLngEdit: TEdit;
    ZoomEdit: TEdit;
    ApplyViewButton: TButton;
    ActivateButton: TButton;
    LogPanel: TPanel;
    LogMemo: TMemo;
    Browser: TEdgeBrowser;
    procedure ApplyViewButtonClick(Sender: TObject);
    procedure ActivateButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser;
      AResult: HRESULT);
  private
    FLastCenterLogAt: TDateTime;
    FLastCenterSignature: string;
    FLastMapTypeIdSignature: string;
    FLastZoomSignature: string;
    FMap: TGMLibMap;
  protected
    procedure HandleCenterChanged(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure HandleMapTypeIdChanged(Sender: TObject; AMapTypeId: TGMMapTypeId);
    procedure HandleMapReady(Sender: TObject);
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
  FMap.APIKey := Trim(APIKeyEdit.Text);

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

procedure TMainForm.ApplyViewButtonClick(Sender: TObject);
var
  coordinate: TGMLibLatLng;
  latitude: Double;
  longitude: Double;
  zoomLevel: Integer;
begin
  if not TryStrToFloat(Trim(CenterLatEdit.Text), latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(CenterLngEdit.Text), longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  if not TryStrToInt(Trim(ZoomEdit.Text), zoomLevel) then
  begin
    Log('Invalid zoom value.');
    Exit;
  end;

  coordinate := TGMLibLatLng.Create(latitude, longitude);
  try
    FMap.Options.Center := coordinate;
  finally
    coordinate.Free;
  end;

  FMap.Options.Zoom := zoomLevel;
  Log(Format('View applied. Center=(%s, %s) Zoom=%d', [
    FloatToStr(latitude, TFormatSettings.Invariant),
    FloatToStr(longitude, TFormatSettings.Invariant),
    zoomLevel
  ]));
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser;
  AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Log('WebView created.')
  else
    Log(Format('WebView creation failed. HRESULT=0x%.8x', [Cardinal(AResult)]));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SetBooleanPropertyIfPublished(Browser, 'AllowSingleSignOnUsingOSPrimaryAccount', False);
  SetStringPropertyIfPublished(Browser, 'TargetCompatibleBrowserVersion', '117.0.2045.28');
  SetStringPropertyIfPublished(Browser, 'UserDataFolder', '%LOCALAPPDATA%\bds.exe.WebView2');
  InitializeMap;
  InitializeDefaultValues;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FMap) then
    FMap.Active := False;

  Browser.CloseWebView;
end;

procedure TMainForm.HandleCenterChanged(Sender: TObject; ALatLng: TGMLibLatLng);
var
  centerSignature: string;
begin
  CenterLatEdit.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  CenterLngEdit.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);

  centerSignature := Format('%.6f,%.6f', [ALatLng.Lat, ALatLng.Lng], TFormatSettings.Invariant);
  if (centerSignature = FLastCenterSignature) and ((Now - FLastCenterLogAt) < EncodeTime(0, 0, 1, 0)) then
    Exit;

  FLastCenterSignature := centerSignature;
  FLastCenterLogAt := Now;
  Log(Format('Center changed from map: %s, %s', [
    CenterLatEdit.Text,
    CenterLngEdit.Text
  ]));
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng;
  const APlaceId: string);
begin
  Log(Format('Map click at %s, %s (placeId=%s)', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant),
    IfThen(APlaceId <> '', APlaceId, '<none>')
  ]));
end;

procedure TMainForm.HandleMapTypeIdChanged(Sender: TObject;
  AMapTypeId: TGMMapTypeId);
const
  MapTypeIdNames: array[TGMMapTypeId] of string = ('roadmap', 'satellite', 'hybrid', 'terrain');
var
  signature: string;
begin
  signature := MapTypeIdNames[AMapTypeId];
  if signature = FLastMapTypeIdSignature then
    Exit;

  FLastMapTypeIdSignature := signature;
  Log(Format('MapTypeId changed from map: %s', [signature]));
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  Log('Map ready event received.');
  UpdateStatus('Map ready');
end;

procedure TMainForm.HandleZoomChanged(Sender: TObject; AZoom: Integer);
var
  zoomSignature: string;
begin
  ZoomEdit.Text := IntToStr(AZoom);
  zoomSignature := ZoomEdit.Text;
  if zoomSignature = FLastZoomSignature then
    Exit;

  FLastZoomSignature := zoomSignature;
  Log(Format('Zoom changed from map: %d', [AZoom]));
end;

procedure TMainForm.InitializeDefaultValues;
begin
  APIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  CenterLatEdit.Text := '41.3874';
  CenterLngEdit.Text := '2.1686';
  ZoomEdit.Text := '12';
  UpdateStatus('Ready');
  Log('Demo initialized. Enter an API key and press Activate map.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := Browser;
  FMap.Options.MapTypeControl := True;
  FMap.Options.MapTypeControlOptions.MapTypeIds := [mtRoadmap, mtSatellite, mtHybrid, mtTerrain];
  FMap.Options.MapTypeControlOptions.Position := cpTopRight;
  FMap.Options.MapTypeControlOptions.Style := mtcsDropdownMenu;
  FMap.Options.ZoomControl := True;
  FMap.Options.ZoomControlOptions.Position := cpLeftCenter;
  FMap.OnCenterChanged := HandleCenterChanged;
  FMap.OnMapClick := HandleMapClick;
  FMap.OnMapTypeIdChanged := HandleMapTypeIdChanged;
  FMap.OnMapReady := HandleMapReady;
  FMap.OnZoomChanged := HandleZoomChanged;
end;

procedure TMainForm.Log(const AText: string);
begin
  while LogMemo.Lines.Count >= 500 do
    LogMemo.Lines.Delete(0);

  LogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  StatusLabel.Caption := AText;
end;

end.
