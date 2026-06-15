unit UMainForm;

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  FMX.WebBrowser,
  uMapLib.Core.LatLng,
  uMapLib.Core.Offline,
  uMapLib.Offline.Types,
  uOSMLib.Map,
  uOSMLib.Fmx.Map,
  uOSMLib.Fmx.Marker;

type
  TMainForm = class(TForm)
    TopToolBar: TToolBar;
    btnActivate: TButton;
    btnResetView: TButton;
    btnTogglePopup: TButton;
    lblStatus: TLabel;
    LogMemo: TMemo;
    MapHost: TLayout;
    WebBrowser1: TWebBrowser;
    procedure btnActivateClick(Sender: TObject);
    procedure btnResetViewClick(Sender: TObject);
    procedure btnTogglePopupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private const
    cDefaultLat = 42.5063;
    cDefaultLng = 1.5218;
    cDefaultZoom = 13.0;
    cDefaultStyleUrl = 'https://tiles.openfreemap.org/styles/liberty';
    cDefaultMapLibreCssUrl = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.css';
    cDefaultMapLibreJsUrl = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.js';
    cDefaultRemoteTileTemplate = 'https://tiles.openfreemap.org/planet/latest/{z}/{x}/{y}.pbf';
  private
    FCurrentMode: TMapLibMapMode;
    FMap: TOSMLibFmxMap;
    FMapReady: Boolean;
    FMarker: TOSMFmxMarkerItem;
    FPopup: TOSMPopupItem;
    procedure ActivateMode(AMode: TMapLibMapMode);
    function BuildCoordinateText(ALat, ALng: Double): string;
    procedure ConfigureBrowser;
    procedure CreateOrUpdatePopup(const ATitle: string; ALat, ALng: Double);
    procedure EnsureTestMarker;
    procedure HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMapError(Sender: TObject; const AMessage: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandleMarkerClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMarkerDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleOfflineError(Sender: TObject; AErrorCode: Integer;
      const AUserMessage, ATechnicalMessage: string);
    procedure InitializeMap;
    procedure Log(const AText: string);
    function MapModeToText(AMode: TMapLibMapMode): string;
    procedure UpdateStatus(const AText: string);
  public
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.btnActivateClick(Sender: TObject);
begin
  ActivateMode(omOnline);
end;

procedure TMainForm.btnResetViewClick(Sender: TObject);
begin
  ActivateMode(omHybrid);
end;

procedure TMainForm.btnTogglePopupClick(Sender: TObject);
begin
  ActivateMode(omOffline);
end;

procedure TMainForm.ActivateMode(AMode: TMapLibMapMode);
begin
  if not Assigned(FMap) then
    Exit;

  if FMap.Active then
    FMap.Active := False;

  FMapReady := False;
  FCurrentMode := AMode;
  FMap.CenterLat := cDefaultLat;
  FMap.CenterLng := cDefaultLng;
  FMap.Zoom := cDefaultZoom;
  FMap.StyleUrl := cDefaultStyleUrl;
  FMap.StyleTemplateFileName := '';
  FMap.GlyphsRootPath := '';

  case AMode of
    omOnline:
      begin
        FMap.OfflinePolicy := opPreferOnline;
        FMap.RemoteTileTemplate := '';
        FMap.MapLibreCssUrl := cDefaultMapLibreCssUrl;
        FMap.MapLibreJsUrl := cDefaultMapLibreJsUrl;
      end;
    omOffline:
      begin
        FMap.OfflinePolicy := opOfflineOnly;
        FMap.RemoteTileTemplate := cDefaultRemoteTileTemplate;
        FMap.MapLibreCssUrl := '';
        FMap.MapLibreJsUrl := '';
      end;
  else
    begin
      FMap.OfflinePolicy := opPreferOffline;
      FMap.RemoteTileTemplate := cDefaultRemoteTileTemplate;
      FMap.MapLibreCssUrl := '';
      FMap.MapLibreJsUrl := '';
    end;
  end;

  FMap.MapMode := AMode;
  UpdateStatus('Loading ' + MapModeToText(AMode) + ' map...');
  Log(Format('%s activation requested. Storage=%s', [
    MapModeToText(AMode),
    FMap.OfflineStoragePath
  ]));
  FMap.Active := True;
end;

function TMainForm.BuildCoordinateText(ALat, ALng: Double): string;
begin
  Result := Format('%s'#13#10'Lat: %.6f'#13#10'Lng: %.6f', [
    DateTimeToStr(Now), ALat, ALng
  ]);
end;

procedure TMainForm.ConfigureBrowser;
begin
{$IFDEF MSWINDOWS}
  WebBrowser1.WindowsEngine := TWindowsEngine.EdgeOnly;
{$ENDIF}
end;

procedure TMainForm.CreateOrUpdatePopup(const ATitle: string; ALat, ALng: Double);
begin
  if not Assigned(FPopup) then
  begin
    FPopup := FMap.Popups.Add;
    FPopup.Options.PresetStyle := ppsNote;
    FPopup.Options.ContentType := pctText;
    FPopup.Options.CloseOnMove := False;
    FPopup.Options.CloseOnClick := False;
    FPopup.Options.MaxWidth := 260;
  end;

  if Assigned(FMarker) then
    FPopup.AnchorObjectId := FMarker.ObjectId;
  FPopup.Options.Content := BuildCoordinateText(ALat, ALng);
  if ATitle <> '' then
    FPopup.Options.Content := ATitle + #13#10 + FPopup.Options.Content;
  FPopup.Options.Visible := True;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;
  FMap.Free;
  inherited;
end;

procedure TMainForm.EnsureTestMarker;
begin
  if Assigned(FMarker) then
    Exit;

  FMarker := FMap.Markers.Add(cDefaultLat, cDefaultLng, 'Mobile test marker');
  FMarker.Kind := mkPin;
  FMarker.Draggable := True;
  FMarker.PinOptions.BackgroundColor := TAlphaColorRec.Deepskyblue;
  FMarker.PinOptions.BorderColor := TAlphaColorRec.White;
  FMarker.PinOptions.GlyphTextColor := TAlphaColorRec.White;
  FMarker.PinOptions.GlyphText := 'OSM';
  FMarker.OnClick := HandleMarkerClick;
  FMarker.OnDragEnd := HandleMarkerDragEnd;

  CreateOrUpdatePopup('Marker ready', FMarker.Lat, FMarker.Lng);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ConfigureBrowser;
  LogMemo.Lines.Clear;
  UpdateStatus('Idle');
  btnActivate.Text := 'Online';
  btnResetView.Text := 'Hybrid';
  btnTogglePopup.Text := 'Offline';
  InitializeMap;
  TThread.Queue(nil,
    procedure
    begin
      btnActivateClick(nil);
    end);
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  EnsureTestMarker;
  FMarker.Lat := ALatLng.Lat;
  FMarker.Lng := ALatLng.Lng;
  CreateOrUpdatePopup('Map tap', ALatLng.Lat, ALatLng.Lng);
  UpdateStatus(Format('Tap %.5f, %.5f', [ALatLng.Lat, ALatLng.Lng]));
  Log(Format('Map click at %.6f, %.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleMapError(Sender: TObject; const AMessage: string);
begin
  UpdateStatus('Error');
  Log('Map error: ' + AMessage);
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  FMapReady := True;
  EnsureTestMarker;
  UpdateStatus(MapModeToText(FCurrentMode) + ' ready');
  Log(MapModeToText(FCurrentMode) + ' map ready.');
  if FCurrentMode <> omOnline then
    Log('Runtime base URL: ' + FMap.GetRuntimeBaseUrl);
end;

procedure TMainForm.HandleMarkerClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  CreateOrUpdatePopup('Marker tap', ALatLng.Lat, ALatLng.Lng);
  UpdateStatus('Marker tapped');
  Log(Format('Marker click at %.6f, %.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleMarkerDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  CreateOrUpdatePopup('Marker drag end', ALatLng.Lat, ALatLng.Lng);
  UpdateStatus('Marker drag end');
  Log(Format('Marker drag end at %.6f, %.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleOfflineError(Sender: TObject; AErrorCode: Integer;
  const AUserMessage, ATechnicalMessage: string);
begin
  UpdateStatus('Offline error');
  Log(Format('Offline error %d: %s | %s', [
    AErrorCode,
    AUserMessage,
    ATechnicalMessage
  ]));
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TOSMLibFmxMap.Create(nil);
  FMap.Browser := WebBrowser1;
  FCurrentMode := omOnline;
  FMap.MapMode := omOnline;
  FMap.StyleUrl := cDefaultStyleUrl;
  FMap.MapLibreCssUrl := cDefaultMapLibreCssUrl;
  FMap.MapLibreJsUrl := cDefaultMapLibreJsUrl;
  FMap.RemoteTileTemplate := cDefaultRemoteTileTemplate;
  FMap.CenterLat := cDefaultLat;
  FMap.CenterLng := cDefaultLng;
  FMap.Zoom := cDefaultZoom;
  FMap.OnMapReady := HandleMapReady;
  FMap.OnClick := HandleMapClick;
  FMap.OnError := HandleMapError;
  FMap.OnOfflineError := HandleOfflineError;
end;

procedure TMainForm.Log(const AText: string);
begin
  LogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

function TMainForm.MapModeToText(AMode: TMapLibMapMode): string;
begin
  case AMode of
    omOffline:
      Result := 'Offline';
    omHybrid:
      Result := 'Hybrid';
  else
    Result := 'Online';
  end;
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  lblStatus.Text := AText;
end;

end.
