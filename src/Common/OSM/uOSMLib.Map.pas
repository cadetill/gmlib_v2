{**
  @abstract(Initial OSM/MapLibre map component skeleton.)
}
unit uOSMLib.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  SysUtils,
  StrUtils,
{$ELSE}
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.JSON,
{$ENDIF}
  uMapLib.Core.Bridge,
  uMapLib.Core.Component,
  uMapLib.Core.LatLng,
  uMapLib.Core.Messages,
  uMapLib.Offline.RegionManager,
  uMapLib.Offline.Types,
  uMapLib.Core.Offline,
  uMapLib.Core.Types,
  uGMLib.Platform.Format;

type
  TOSMMapReadyEvent = procedure(Sender: TObject) of object;
  TOSMMapSimpleEvent = procedure(Sender: TObject) of object;
  TOSMMapCoordinateEvent = procedure(Sender: TObject; ALatLng: TMapLibLatLng) of object;
  TOSMMarkerCoordinateEvent = procedure(Sender: TObject; ALatLng: TMapLibLatLng) of object;
  TOSMMapViewChangedEvent = procedure(Sender: TObject; ACenter: TMapLibLatLng; AZoom, ABearing, APitch: Double) of object;
  TOSMMapBoundsChangedEvent = procedure(Sender: TObject; ANorth, ASouth, AEast, AWest: Double) of object;
  TOSMMapErrorEvent = procedure(Sender: TObject; const AMessage: string) of object;

  TOSMMarkerItem = class(TCollectionItem)
  private
    FLat: Double;
    FLng: Double;
    FObjectId: TGMObjectId;
    FTitle: string;
    FVisible: Boolean;
    FOnClick: TOSMMarkerCoordinateEvent;
    FOnDragStart: TOSMMarkerCoordinateEvent;
    FOnDrag: TOSMMarkerCoordinateEvent;
    FOnDragEnd: TOSMMarkerCoordinateEvent;
    procedure Changed;
    procedure SetLat(const Value: Double);
    procedure SetLng(const Value: Double);
    procedure SetObjectId(const Value: TGMObjectId);
    procedure SetTitle(const Value: string);
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function BuildAddPayload: string;
    function BuildSetOptionsPayload: string;
  published
    property ObjectId: TGMObjectId read FObjectId write SetObjectId;
    property Lat: Double read FLat write SetLat;
    property Lng: Double read FLng write SetLng;
    property Title: string read FTitle write SetTitle;
    property Visible: Boolean read FVisible write SetVisible default True;
    property OnClick: TOSMMarkerCoordinateEvent read FOnClick write FOnClick;
    property OnDragStart: TOSMMarkerCoordinateEvent read FOnDragStart write FOnDragStart;
    property OnDrag: TOSMMarkerCoordinateEvent read FOnDrag write FOnDrag;
    property OnDragEnd: TOSMMarkerCoordinateEvent read FOnDragEnd write FOnDragEnd;
  end;

  TOSMMarkers = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TOSMMarkerItem;
    procedure DoChanged;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TOSMMarkerItem; reintroduce; overload;
    function Add(ALat, ALng: Double; const ATitle: string = ''): TOSMMarkerItem; overload;
    procedure Clear;
    function DeleteByObjectId(const AObjectId: TGMObjectId): Boolean;
    function FindByObjectId(const AObjectId: TGMObjectId): TOSMMarkerItem;
    function ZoomToMarkers: Boolean;
    procedure NotifyItemChanged;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    property Items[Index: Integer]: TOSMMarkerItem read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TOSMMap = class(TMapLibComponent)
  private
    FActive: Boolean;
    // FOfflineMode: Boolean;
    // FMapMode: TMapLibMapMode;
    // FOfflinePolicy: TMapLibOfflinePolicy;
    // FOfflineTileProvider: TMapLibOfflineTileProvider;
    FBridge: IMapBridgeTransport;
    FOfflineRegionManager: IMapLibOfflineRegionManager;
    FOfflineStoragePath: string;
    FCenterLat: Double;
    FCenterLng: Double;
    FMapId: TGMObjectId;
    FOnMapReady: TOSMMapReadyEvent;
    FOnClick: TOSMMapCoordinateEvent;
    FOnContextMenu: TOSMMapCoordinateEvent;
    FOnDblClick: TOSMMapCoordinateEvent;
    FOnMouseDown: TOSMMapCoordinateEvent;
    FOnMouseMove: TOSMMapCoordinateEvent;
    FOnMouseOut: TOSMMapCoordinateEvent;
    FOnMouseOver: TOSMMapCoordinateEvent;
    FOnMouseUp: TOSMMapCoordinateEvent;
    FOnTouchCancel: TOSMMapSimpleEvent;
    FOnTouchEnd: TOSMMapSimpleEvent;
    FOnTouchMove: TOSMMapSimpleEvent;
    FOnTouchStart: TOSMMapSimpleEvent;
    FOnMoveStart: TOSMMapViewChangedEvent;
    FOnMove: TOSMMapViewChangedEvent;
    FOnMoveEnd: TOSMMapViewChangedEvent;
    FOnDragStart: TOSMMapViewChangedEvent;
    FOnDrag: TOSMMapViewChangedEvent;
    FOnDragEnd: TOSMMapViewChangedEvent;
    FOnZoomStart: TOSMMapViewChangedEvent;
    FOnZoom: TOSMMapViewChangedEvent;
    FOnZoomEnd: TOSMMapViewChangedEvent;
    FOnRotateStart: TOSMMapViewChangedEvent;
    FOnRotate: TOSMMapViewChangedEvent;
    FOnRotateEnd: TOSMMapViewChangedEvent;
    FOnPitchStart: TOSMMapViewChangedEvent;
    FOnPitch: TOSMMapViewChangedEvent;
    FOnPitchEnd: TOSMMapViewChangedEvent;
    FOnBoxZoomStart: TOSMMapSimpleEvent;
    FOnBoxZoomEnd: TOSMMapSimpleEvent;
    FOnBoxZoomCancel: TOSMMapSimpleEvent;
    FOnResize: TOSMMapSimpleEvent;
    FOnRender: TOSMMapSimpleEvent;
    FOnIdle: TOSMMapSimpleEvent;
    FOnLoad: TOSMMapSimpleEvent;
    FOnData: TOSMMapSimpleEvent;
    FOnDataLoading: TOSMMapSimpleEvent;
    FOnDataAbort: TOSMMapSimpleEvent;
    FOnSourceData: TOSMMapSimpleEvent;
    FOnSourceDataLoading: TOSMMapSimpleEvent;
    FOnSourceDataAbort: TOSMMapSimpleEvent;
    FOnStyleData: TOSMMapSimpleEvent;
    FOnStyleDataLoading: TOSMMapSimpleEvent;
    FOnStyleImageMissing: TOSMMapSimpleEvent;
    FOnTerrain: TOSMMapSimpleEvent;
    FOnProjectionTransition: TOSMMapSimpleEvent;
    FOnWebGLContextLost: TOSMMapSimpleEvent;
    FOnWebGLContextRestored: TOSMMapSimpleEvent;
    FOnWheel: TOSMMapSimpleEvent;
    FOnBoundsChanged: TOSMMapBoundsChangedEvent;
    FOnError: TOSMMapErrorEvent;
    
    // Eventos offline
    FOnOfflineDownloadProgress: TMapLibOfflineDownloadProgressEvent;
    FOnOfflineRegionReady: TMapLibOfflineRegionReadyEvent;
    FOnOfflineError: TMapLibOfflineErrorEvent;

    FMarkers: TOSMMarkers;
    FStyleUrl: string;
    // FOfflineStyleUrl: string;
    // FOfflineRasterTilesUrlTemplate: string;
    // FOfflineTileJsonUrl: string;
    // FRuntimeOfflineTileJsonUrl: string;
    // FRuntimeOfflineStyleUrl: string;
    // FRuntimeOfflineAssetsBaseUrl: string;
    // FLastOfflineSetupError: string;
    // FOfflineServerExecutable: string;
    // FOfflineServerPort: Integer;
    // FOfflineServerEnabled: Boolean;
    // FOfflinePmtilesArchivePath: string;
    FMapLibreCssUrl: string;
    FMapLibreJsUrl: string;
    FZoom: Double;
    FBearing: Double;
    FPitch: Double;
    procedure SetActive(const Value: Boolean);
    procedure SetBridge(const Value: IMapBridgeTransport);
    procedure SetCenterLat(const Value: Double);
    procedure SetCenterLng(const Value: Double);
    procedure SetMapId(const Value: TGMObjectId);
    procedure SetStyleUrl(const Value: string);
    procedure SetOfflineStoragePath(const Value: string);
    // procedure SetOfflineStyleUrl(const Value: string);
    // procedure SetOfflineRasterTilesUrlTemplate(const Value: string);
    // procedure SetOfflineTileJsonUrl(const Value: string);
    // procedure SetOfflineServerExecutable(const Value: string);
    // procedure SetOfflineServerPort(const Value: Integer);
    // procedure SetOfflineServerEnabled(const Value: Boolean);
    procedure SetMapLibreCssUrl(const Value: string);
    procedure SetMapLibreJsUrl(const Value: string);
    // procedure SetOfflineMode(const Value: Boolean);
    // procedure SetOfflinePolicy(const Value: TMapLibOfflinePolicy);
    // procedure SetOfflineTileProvider(const Value: TMapLibOfflineTileProvider);
    // procedure SetOfflineRegionManager(const Value: IMapLibOfflineRegionManager);
    // procedure SetMapMode(const Value: TMapLibMapMode);
    procedure SetZoom(const Value: Double);
    procedure HandleOfflineDownloadProgress(Sender: TObject; const AJobId: string; APercent: Double; ABytesDone, ABytesTotal: Int64);
    procedure HandleOfflineRegionReady(Sender: TObject; const ARegionId: TMapLibOfflineRegionId);
    procedure HandleOfflineError(Sender: TObject; AErrorCode: Integer; const AUserMessage, ATechnicalMessage: string);
    procedure BridgeMessageReceived(Sender: TObject; const AEnvelope: TMapLibMessageEnvelope);
    function BuildSetViewPayload: string;
    function BuildSetStylePayload: string;
    function BuildMarkerAddEnvelope(AMarker: TOSMMarkerItem): TMapLibMessageEnvelope;
    function CreateEnvelope(const AMessageType, APayload: string): TMapLibMessageEnvelope;
    procedure SyncViewToBridge;
    procedure SyncMarkersToBridge;
    procedure MarkersChanged(Sender: TObject);
    procedure DispatchMapEvent(const AEventName, APayload: string);
    procedure DispatchMarkerEvent(const AEventName, APayload: string);
    function TryGetLatLngFromPayload(const APayload: string; out ALatLng: TMapLibLatLng): Boolean;
    function TryGetMarkerClickFromPayload(const APayload: string; out AMarkerId: TGMObjectId;
      out ALatLng: TMapLibLatLng): Boolean;
    function TryGetViewFromPayload(const APayload: string; out ACenter: TMapLibLatLng; out AZoom, ABearing, APitch: Double): Boolean;
    function TryGetBoundsFromPayload(const APayload: string; out ANorth, ASouth, AEast, AWest: Double): Boolean;
    function GetErrorMessageFromPayload(const APayload: string): string;
    procedure NotifyProtocolError(const AContext: string; const E: Exception);
  protected
    function GetDocumentationUrl: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure FitBounds(ANorth, ASouth, AEast, AWest: Double);
    function BuildJsBootstrapConfig: string;
    procedure ApplyStyle;
    function ResolveStyleUrl: string;
    // function ResolveOfflineStyleUrl: string;
    function ResolveMapLibreCssUrl: string;
    function ResolveMapLibreJsUrl: string;
    // function ResolveMapModeName: string;
    // function ResolveOfflineStyleRuntimeUrl: string;
    // function ResolveOfflineAssetsBaseUrl: string;
    // function ResolveLastOfflineSetupError: string;
    // procedure EnsureOfflineTileSourceReady;
    // procedure StopOfflineTileServer;
    property Bridge: IMapBridgeTransport read FBridge write SetBridge;
    property OfflineRegionManager: IMapLibOfflineRegionManager read FOfflineRegionManager;
  published
    property Active: Boolean read FActive write SetActive default False;
    property OfflineStoragePath: string read FOfflineStoragePath write SetOfflineStoragePath;
    // property MapMode: TMapLibMapMode read FMapMode write SetMapMode default omOnline;
    // property OfflineMode: Boolean read FOfflineMode write SetOfflineMode default False;
    // property OfflinePolicy: TMapLibOfflinePolicy read FOfflinePolicy write SetOfflinePolicy
    //   default opPreferOffline;
    // property OfflineTileProvider: TMapLibOfflineTileProvider read FOfflineTileProvider
    //   write SetOfflineTileProvider default otpAuto;
    property CenterLat: Double read FCenterLat write SetCenterLat;
    property CenterLng: Double read FCenterLng write SetCenterLng;
    property MapId: TGMObjectId read FMapId write SetMapId;
    property OnMapReady: TOSMMapReadyEvent read FOnMapReady write FOnMapReady;
    property OnClick: TOSMMapCoordinateEvent read FOnClick write FOnClick;
    property OnContextMenu: TOSMMapCoordinateEvent read FOnContextMenu write FOnContextMenu;
    property OnDblClick: TOSMMapCoordinateEvent read FOnDblClick write FOnDblClick;
    property OnMouseDown: TOSMMapCoordinateEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TOSMMapCoordinateEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseOut: TOSMMapCoordinateEvent read FOnMouseOut write FOnMouseOut;
    property OnMouseOver: TOSMMapCoordinateEvent read FOnMouseOver write FOnMouseOver;
    property OnMouseUp: TOSMMapCoordinateEvent read FOnMouseUp write FOnMouseUp;
    property OnTouchCancel: TOSMMapSimpleEvent read FOnTouchCancel write FOnTouchCancel;
    property OnTouchEnd: TOSMMapSimpleEvent read FOnTouchEnd write FOnTouchEnd;
    property OnTouchMove: TOSMMapSimpleEvent read FOnTouchMove write FOnTouchMove;
    property OnTouchStart: TOSMMapSimpleEvent read FOnTouchStart write FOnTouchStart;
    property OnMoveStart: TOSMMapViewChangedEvent read FOnMoveStart write FOnMoveStart;
    property OnMove: TOSMMapViewChangedEvent read FOnMove write FOnMove;
    property OnMoveEnd: TOSMMapViewChangedEvent read FOnMoveEnd write FOnMoveEnd;
    property OnDragStart: TOSMMapViewChangedEvent read FOnDragStart write FOnDragStart;
    property OnDrag: TOSMMapViewChangedEvent read FOnDrag write FOnDrag;
    property OnDragEnd: TOSMMapViewChangedEvent read FOnDragEnd write FOnDragEnd;
    property OnZoomStart: TOSMMapViewChangedEvent read FOnZoomStart write FOnZoomStart;
    property OnZoom: TOSMMapViewChangedEvent read FOnZoom write FOnZoom;
    property OnZoomEnd: TOSMMapViewChangedEvent read FOnZoomEnd write FOnZoomEnd;
    property OnRotateStart: TOSMMapViewChangedEvent read FOnRotateStart write FOnRotateStart;
    property OnRotate: TOSMMapViewChangedEvent read FOnRotate write FOnRotate;
    property OnRotateEnd: TOSMMapViewChangedEvent read FOnRotateEnd write FOnRotateEnd;
    property OnPitchStart: TOSMMapViewChangedEvent read FOnPitchStart write FOnPitchStart;
    property OnPitch: TOSMMapViewChangedEvent read FOnPitch write FOnPitch;
    property OnPitchEnd: TOSMMapViewChangedEvent read FOnPitchEnd write FOnPitchEnd;
    property OnBoxZoomStart: TOSMMapSimpleEvent read FOnBoxZoomStart write FOnBoxZoomStart;
    property OnBoxZoomEnd: TOSMMapSimpleEvent read FOnBoxZoomEnd write FOnBoxZoomEnd;
    property OnBoxZoomCancel: TOSMMapSimpleEvent read FOnBoxZoomCancel write FOnBoxZoomCancel;
    property OnResize: TOSMMapSimpleEvent read FOnResize write FOnResize;
    property OnRender: TOSMMapSimpleEvent read FOnRender write FOnRender;
    property OnIdle: TOSMMapSimpleEvent read FOnIdle write FOnIdle;
    property OnLoad: TOSMMapSimpleEvent read FOnLoad write FOnLoad;
    property OnData: TOSMMapSimpleEvent read FOnData write FOnData;
    property OnDataLoading: TOSMMapSimpleEvent read FOnDataLoading write FOnDataLoading;
    property OnDataAbort: TOSMMapSimpleEvent read FOnDataAbort write FOnDataAbort;
    property OnSourceData: TOSMMapSimpleEvent read FOnSourceData write FOnSourceData;
    property OnSourceDataLoading: TOSMMapSimpleEvent read FOnSourceDataLoading write FOnSourceDataLoading;
    property OnSourceDataAbort: TOSMMapSimpleEvent read FOnSourceDataAbort write FOnSourceDataAbort;
    property OnStyleData: TOSMMapSimpleEvent read FOnStyleData write FOnStyleData;
    property OnStyleDataLoading: TOSMMapSimpleEvent read FOnStyleDataLoading write FOnStyleDataLoading;
    property OnStyleImageMissing: TOSMMapSimpleEvent read FOnStyleImageMissing write FOnStyleImageMissing;
    property OnTerrain: TOSMMapSimpleEvent read FOnTerrain write FOnTerrain;
    property OnProjectionTransition: TOSMMapSimpleEvent read FOnProjectionTransition write FOnProjectionTransition;
    property OnWebGLContextLost: TOSMMapSimpleEvent read FOnWebGLContextLost write FOnWebGLContextLost;
    property OnWebGLContextRestored: TOSMMapSimpleEvent read FOnWebGLContextRestored write FOnWebGLContextRestored;
    property OnWheel: TOSMMapSimpleEvent read FOnWheel write FOnWheel;
    property OnBoundsChanged: TOSMMapBoundsChangedEvent read FOnBoundsChanged write FOnBoundsChanged;
    property OnError: TOSMMapErrorEvent read FOnError write FOnError;
    property OnOfflineDownloadProgress: TMapLibOfflineDownloadProgressEvent read FOnOfflineDownloadProgress write FOnOfflineDownloadProgress;
    property OnOfflineRegionReady: TMapLibOfflineRegionReadyEvent read FOnOfflineRegionReady write FOnOfflineRegionReady;
    property OnOfflineError: TMapLibOfflineErrorEvent read FOnOfflineError write FOnOfflineError;
    property Markers: TOSMMarkers read FMarkers;
    property StyleUrl: string read FStyleUrl write SetStyleUrl;
    // property OfflineStyleUrl: string read FOfflineStyleUrl write SetOfflineStyleUrl;
    // property OfflineRasterTilesUrlTemplate: string read FOfflineRasterTilesUrlTemplate write SetOfflineRasterTilesUrlTemplate;
    // property OfflineTileJsonUrl: string read FOfflineTileJsonUrl write SetOfflineTileJsonUrl;
    // property OfflineServerEnabled: Boolean read FOfflineServerEnabled write SetOfflineServerEnabled default True;
    // property OfflineServerExecutable: string read FOfflineServerExecutable write SetOfflineServerExecutable;
    // property OfflineServerPort: Integer read FOfflineServerPort write SetOfflineServerPort default 8090;
    property MapLibreCssUrl: string read FMapLibreCssUrl write SetMapLibreCssUrl;
    property MapLibreJsUrl: string read FMapLibreJsUrl write SetMapLibreJsUrl;
    property Zoom: Double read FZoom write SetZoom;
    property Bearing: Double read FBearing;
    property Pitch: Double read FPitch;
  end;

function GetOSMMapStyleUrl(AMap: TOSMMap): string;
function GetOSMMapLibreCssUrl(AMap: TOSMMap): string;
function GetOSMMapLibreJsUrl(AMap: TOSMMap): string;
// function GetOSMOfflineRasterTilesUrlTemplate(AMap: TOSMMap): string;
// function GetOSMOfflineTileJsonUrl(AMap: TOSMMap): string;
// function GetOSMOfflineStyleRuntimeUrl(AMap: TOSMMap): string;
// function GetOSMOfflineAssetsBaseUrl(AMap: TOSMMap): string;

implementation

uses
  // uMapLib.Offline.TileServer,
{$IFDEF MSWINDOWS}
  {$IFDEF FPC}
  Windows,
  WinInet,
  {$ELSE}
  Winapi.Windows,
  Winapi.WinInet,
  {$ENDIF}
{$ENDIF}
  System.IOUtils;

const
  DEFAULT_MAPLIBRE_STYLE_URL = 'https://tiles.openfreemap.org/styles/bright';
  DEFAULT_MAPLIBRE_CSS_URL = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.css';
  DEFAULT_MAPLIBRE_JS_URL = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.js';

type
{$IFDEF MSWINDOWS}
  TOSMExternalPmTilesServer = class(TInterfacedObject, IMapLibOfflineTileServer)
  private
    FExecutablePath: string;
    FArchivePath: string;
    FPort: Integer;
    FProcessHandle: THandle;
    FBaseUrl: string;
    FLastError: string;
  public
    constructor Create(const AExecutablePath, AArchivePath: string; APort: Integer);
    destructor Destroy; override;
    function Start: Boolean;
    procedure Stop;
    function IsRunning: Boolean;
    function GetBaseUrl: string;
    function GetLastError: string;
  end;
{$ENDIF}

{$IFDEF MSWINDOWS}
function HttpUrlIsReachable(const AUrl: string): Boolean;
var
  hInternet: Pointer;
  hUrl: Pointer;
begin
  Result := False;
  hInternet := InternetOpen(PChar('GMLib-OSM-OfflineCheck'), 0, nil, nil, 0);
  if hInternet = nil then
    Exit;
  try
    hUrl := InternetOpenUrl(hInternet, PChar(AUrl), nil, 0,
      $80000000 or $04000000, 0);
    if hUrl <> nil then
    begin
      InternetCloseHandle(hUrl);
      Result := True;
    end;
  finally
    InternetCloseHandle(hInternet);
  end;
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
{ TOSMExternalPmTilesServer }

constructor TOSMExternalPmTilesServer.Create(const AExecutablePath, AArchivePath: string; APort: Integer);
begin
  inherited Create;
  FExecutablePath := AExecutablePath;
  FArchivePath := AArchivePath;
  FPort := APort;
  FProcessHandle := 0;
  FBaseUrl := Format('http://127.0.0.1:%d/', [FPort]);
  FLastError := '';
end;

destructor TOSMExternalPmTilesServer.Destroy;
begin
  Stop;
  inherited;
end;

function TOSMExternalPmTilesServer.Start: Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  commandLine: string;
  workDir: string;
  exitCode: Cardinal;
begin
  Result := False;
  FLastError := '';
  if IsRunning then
    Exit(True);

  if (FExecutablePath = '') or (not FileExists(FExecutablePath)) then
  begin
    FLastError := 'Offline server executable was not found.';
    Exit(False);
  end;

  if (FArchivePath = '') or (not FileExists(FArchivePath)) then
  begin
    FLastError := 'Offline PMTiles archive was not found.';
    Exit(False);
  end;

  commandLine := Format('"%s" serve "%s" --port %d --interface 127.0.0.1 --cors=* --public-url=http://127.0.0.1:%d',
    [FExecutablePath, ExcludeTrailingPathDelimiter(ExtractFileDir(FArchivePath)), FPort, FPort]);
  workDir := ExtractFilePath(FExecutablePath);
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;
  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

  if not CreateProcess(nil, PChar(commandLine), nil, nil, False,
    CREATE_NO_WINDOW, nil, PChar(workDir), StartupInfo, ProcessInfo) then
  begin
    {$IFDEF FPC}
    FLastError := SysErrorMessage(Windows.GetLastError);
    {$ELSE}
    FLastError := SysErrorMessage(Winapi.Windows.GetLastError);
    {$ENDIF}
    Exit(False);
  end;

  CloseHandle(ProcessInfo.hThread);
  FProcessHandle := ProcessInfo.hProcess;
  Sleep(250);
  if not IsRunning then
  begin
    exitCode := 0;
    GetExitCodeProcess(FProcessHandle, exitCode);
    FLastError := Format('Offline tile server terminated during startup (exit code %d).', [exitCode]);
    CloseHandle(FProcessHandle);
    FProcessHandle := 0;
    Exit(False);
  end;
  Result := True;
end;

procedure TOSMExternalPmTilesServer.Stop;
begin
  if FProcessHandle = 0 then
    Exit;

  if WaitForSingleObject(FProcessHandle, 0) = WAIT_TIMEOUT then
    TerminateProcess(FProcessHandle, 0);
  CloseHandle(FProcessHandle);
  FProcessHandle := 0;
end;

function TOSMExternalPmTilesServer.IsRunning: Boolean;
begin
  Result := (FProcessHandle <> 0) and (WaitForSingleObject(FProcessHandle, 0) = WAIT_TIMEOUT);
end;

function TOSMExternalPmTilesServer.GetBaseUrl: string;
begin
  Result := FBaseUrl;
end;

function TOSMExternalPmTilesServer.GetLastError: string;
begin
  Result := FLastError;
end;
{$ENDIF}

{ TOSMMarkerItem }

constructor TOSMMarkerItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FVisible := True;
end;

procedure TOSMMarkerItem.Assign(Source: TPersistent);
var
  SourceMarker: TOSMMarkerItem;
begin
  if Source is TOSMMarkerItem then
  begin
    SourceMarker := TOSMMarkerItem(Source);
    FObjectId := SourceMarker.ObjectId;
    FLat := SourceMarker.Lat;
    FLng := SourceMarker.Lng;
    FTitle := SourceMarker.Title;
    FVisible := SourceMarker.Visible;
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

function TOSMMarkerItem.BuildAddPayload: string;
begin
  Result := Format(
    '{"objectId":"%s","lat":%.15g,"lng":%.15g,"title":"%s","visible":%s}',
    [
      StringReplace(string(FObjectId), '"', '\"', [rfReplaceAll]),
      FLat,
      FLng,
      StringReplace(FTitle, '"', '\"', [rfReplaceAll]),
      LowerCase(BoolToStr(FVisible, True))
    ],
    GMLibInvariantFormatSettings
  );
end;

function TOSMMarkerItem.BuildSetOptionsPayload: string;
begin
  Result := Format(
    '{"objectId":"%s","lat":%.15g,"lng":%.15g,"visible":%s}',
    [
      StringReplace(string(FObjectId), '"', '\"', [rfReplaceAll]),
      FLat,
      FLng,
      LowerCase(BoolToStr(FVisible, True))
    ],
    GMLibInvariantFormatSettings
  );
end;

procedure TOSMMarkerItem.Changed;
begin
  if Collection is TOSMMarkers then
    TOSMMarkers(Collection).NotifyItemChanged;
end;

procedure TOSMMarkerItem.SetLat(const Value: Double);
begin
  if FLat = Value then
    Exit;
  FLat := Value;
  Changed;
end;

procedure TOSMMarkerItem.SetLng(const Value: Double);
begin
  if FLng = Value then
    Exit;
  FLng := Value;
  Changed;
end;

procedure TOSMMarkerItem.SetObjectId(const Value: TGMObjectId);
begin
  if FObjectId = Value then
    Exit;
  FObjectId := Value;
  Changed;
end;

procedure TOSMMarkerItem.SetTitle(const Value: string);
begin
  if FTitle = Value then
    Exit;
  FTitle := Value;
  Changed;
end;

procedure TOSMMarkerItem.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;
  FVisible := Value;
  Changed;
end;

{ TOSMMarkers }

constructor TOSMMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TOSMMarkerItem);
end;

function TOSMMarkers.Add: TOSMMarkerItem;
begin
  Result := TOSMMarkerItem(inherited Add);
  if Result.ObjectId = '' then
    Result.ObjectId := TGMObjectId(Format('osm_marker_%d', [Result.Index + 1]));
end;

function TOSMMarkers.Add(ALat, ALng: Double; const ATitle: string): TOSMMarkerItem;
begin
{$IFDEF FPC}
  Result := nil;
{$ENDIF}
  Result := Add;
  if Assigned(Result) then
  begin
    Result.Lat := ALat;
    Result.Lng := ALng;
    Result.Title := ATitle;
  end;
end;

procedure TOSMMarkers.Clear;
begin
  inherited Clear;
  DoChanged;
end;

function TOSMMarkers.DeleteByObjectId(const AObjectId: TGMObjectId): Boolean;
var
  Marker: TOSMMarkerItem;
begin
  Result := False;
  Marker := FindByObjectId(AObjectId);
  if not Assigned(Marker) then
    Exit;
  Delete(Marker.Index);
  Result := True;
end;

procedure TOSMMarkers.DoChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TOSMMarkers.FindByObjectId(const AObjectId: TGMObjectId): TOSMMarkerItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(string(Items[I].ObjectId), string(AObjectId)) then
      Exit(Items[I]);
end;

function TOSMMarkers.GetItem(Index: Integer): TOSMMarkerItem;
begin
  Result := TOSMMarkerItem(inherited Items[Index]);
end;

function TOSMMarkers.ZoomToMarkers: Boolean;
var
  I: Integer;
  Marker: TOSMMarkerItem;
  North: Double;
  South: Double;
  East: Double;
  West: Double;
  OwnerMap: TOSMMap;
begin
  Result := False;
  if not (Owner is TOSMMap) then
    Exit;

  OwnerMap := TOSMMap(Owner);
  if Count = 0 then
    Exit;

  North := -90;
  South := 90;
  East := -180;
  West := 180;
  for I := 0 to Count - 1 do
  begin
    Marker := Items[I];
    if not Marker.Visible then
      Continue;

    if Marker.Lat > North then
      North := Marker.Lat;
    if Marker.Lat < South then
      South := Marker.Lat;
    if Marker.Lng > East then
      East := Marker.Lng;
    if Marker.Lng < West then
      West := Marker.Lng;
    Result := True;
  end;

  if Result then
    OwnerMap.FitBounds(North, South, East, West);
end;

procedure TOSMMarkers.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  DoChanged;
end;

procedure TOSMMarkers.NotifyItemChanged;
begin
  DoChanged;
end;

{$IFNDEF FPC}
function TryParsePayloadObject(const APayload: string; out AJsonObject: TJSONObject): Boolean;
var
  JsonValue: TJSONValue;
begin
  Result := False;
  AJsonObject := nil;

  try
    JsonValue := TJSONObject.ParseJSONValue(APayload);
  except
    Exit;
  end;

  if not (JsonValue is TJSONObject) then
  begin
    JsonValue.Free;
    Exit;
  end;

  AJsonObject := TJSONObject(JsonValue);
  Result := True;
end;
{$ENDIF}

constructor TOSMMap.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCenterLat := 0;
  FCenterLng := 0;
  FMapId := 'OSMLib_MAP';
  FStyleUrl := DEFAULT_MAPLIBRE_STYLE_URL;
  // FOfflineStyleUrl := '';
  // FOfflineRasterTilesUrlTemplate := '';
  // FOfflineTileJsonUrl := '';
  // FRuntimeOfflineTileJsonUrl := '';
  // FRuntimeOfflineStyleUrl := '';
  // FRuntimeOfflineAssetsBaseUrl := '';
  // FLastOfflineSetupError := '';
  // FOfflineServerExecutable := '';
  // FOfflineServerPort := 8090;
  // FOfflineServerEnabled := True;
  // FOfflinePmtilesArchivePath := '';
  FMapLibreCssUrl := DEFAULT_MAPLIBRE_CSS_URL;
  FMapLibreJsUrl := DEFAULT_MAPLIBRE_JS_URL;
  FZoom := 1;
  FBearing := 0;
  FPitch := 0;
  // FOfflineMode := False;
  // FMapMode := omOnline;
  // FOfflinePolicy := opPreferOffline;
  // FOfflineTileProvider := otpAuto;
  FOfflineStoragePath := '';
  FOfflineRegionManager := TMapLibOfflineRegionManager.Create(FOfflineStoragePath);
  FOfflineRegionManager.OnDownloadProgress := HandleOfflineDownloadProgress;
  FOfflineRegionManager.OnRegionReady := HandleOfflineRegionReady;
  FOfflineRegionManager.OnOfflineError := HandleOfflineError;
  FMarkers := TOSMMarkers.Create(Self);
{$IFDEF FPC}
  FMarkers.OnChange := @MarkersChanged;
{$ELSE}
  FMarkers.OnChange := MarkersChanged;
{$ENDIF}
end;

destructor TOSMMap.Destroy;
begin
  // StopOfflineTileServer;
  FMarkers.Free;
  inherited Destroy;
end;

function TOSMMap.GetDocumentationUrl: string;
begin
  Result := 'https://maplibre.org/maplibre-gl-js/docs/';
end;

procedure TOSMMap.FitBounds(ANorth, ASouth, AEast, AWest: Double);
var
  Payload: string;
begin
  if not Assigned(FBridge) then
    Exit;

  Payload := Format(
    '{"north":%.15g,"south":%.15g,"east":%.15g,"west":%.15g}',
    [ANorth, ASouth, AEast, AWest],
    GMLibInvariantFormatSettings
  );
  FBridge.PostCommand(CreateEnvelope('map.fit_bounds', Payload));
end;

function TOSMMap.ResolveStyleUrl: string;
begin
  Result := FStyleUrl;
end;

function GetOSMMapStyleUrl(AMap: TOSMMap): string;
var
  isHttp: Boolean;
begin
  if Assigned(AMap) then
    Result := AMap.ResolveStyleUrl
  else
    Result := DEFAULT_MAPLIBRE_STYLE_URL;

  isHttp := StartsText('http://', Result) or StartsText('https://', Result);
  if (Result <> '') and not isHttp and FileExists(Result) then
    Result := 'file:///' + StringReplace(ExpandFileName(Result), '\', '/', [rfReplaceAll]);
end;

function TOSMMap.ResolveMapLibreCssUrl: string;
begin
  if Trim(FMapLibreCssUrl) <> '' then
    Result := FMapLibreCssUrl
  else
    Result := DEFAULT_MAPLIBRE_CSS_URL;
end;

function TOSMMap.ResolveMapLibreJsUrl: string;
begin
  if Trim(FMapLibreJsUrl) <> '' then
    Result := FMapLibreJsUrl
  else
    Result := DEFAULT_MAPLIBRE_JS_URL;
end;

function GetOSMMapLibreCssUrl(AMap: TOSMMap): string;
begin
  if Assigned(AMap) then
    Result := AMap.ResolveMapLibreCssUrl
  else
    Result := DEFAULT_MAPLIBRE_CSS_URL;
end;

function GetOSMMapLibreJsUrl(AMap: TOSMMap): string;
begin
  if Assigned(AMap) then
    Result := AMap.ResolveMapLibreJsUrl
  else
    Result := DEFAULT_MAPLIBRE_JS_URL;
end;

procedure TOSMMap.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;

  if Value then
    Activate
  else
    Deactivate;
end;

procedure TOSMMap.SetBridge(const Value: IMapBridgeTransport);
begin
  if FBridge = Value then
    Exit;

  FBridge := Value;
  if Assigned(FBridge) then
{$IFDEF FPC}
    FBridge.SetOnMessageReceived(@BridgeMessageReceived);
{$ELSE}
    FBridge.SetOnMessageReceived(BridgeMessageReceived);
{$ENDIF}
end;

procedure TOSMMap.SetCenterLat(const Value: Double);
begin
  if FCenterLat = Value then
    Exit;
  FCenterLat := Value;
  SyncViewToBridge;
end;

procedure TOSMMap.SetCenterLng(const Value: Double);
begin
  if FCenterLng = Value then
    Exit;
  FCenterLng := Value;
  SyncViewToBridge;
end;

procedure TOSMMap.SetMapId(const Value: TGMObjectId);
begin
  if FMapId = Value then
    Exit;
  FMapId := Value;
end;

procedure TOSMMap.SetStyleUrl(const Value: string);
begin
  if FStyleUrl = Value then
    Exit;

  FStyleUrl := Value;
  ApplyStyle;
end;

procedure TOSMMap.SetOfflineStoragePath(const Value: string);
begin
  if FOfflineStoragePath = Value then
    Exit;
  FOfflineStoragePath := Value;
  if Assigned(FOfflineRegionManager) and (FOfflineRegionManager is TMapLibOfflineRegionManager) then
    TMapLibOfflineRegionManager(FOfflineRegionManager).StorageBasePath := FOfflineStoragePath;
end;

procedure TOSMMap.HandleOfflineDownloadProgress(Sender: TObject; const AJobId: string;
  APercent: Double; ABytesDone, ABytesTotal: Int64);
begin
  if Assigned(FOnOfflineDownloadProgress) then
    FOnOfflineDownloadProgress(Self, AJobId, APercent, ABytesDone, ABytesTotal);
end;

procedure TOSMMap.HandleOfflineRegionReady(Sender: TObject; const ARegionId: TMapLibOfflineRegionId);
begin
  if Assigned(FOnOfflineRegionReady) then
    FOnOfflineRegionReady(Self, ARegionId);
end;

procedure TOSMMap.HandleOfflineError(Sender: TObject; AErrorCode: Integer;
  const AUserMessage, ATechnicalMessage: string);
begin
  if Assigned(FOnOfflineError) then
    FOnOfflineError(Self, AErrorCode, AUserMessage, ATechnicalMessage);
end;

procedure TOSMMap.SetMapLibreCssUrl(const Value: string);
begin
  if FMapLibreCssUrl = Value then
    Exit;
  FMapLibreCssUrl := Value;
end;

procedure TOSMMap.SetMapLibreJsUrl(const Value: string);
begin
  if FMapLibreJsUrl = Value then
    Exit;
  FMapLibreJsUrl := Value;
end;

procedure TOSMMap.SetZoom(const Value: Double);
begin
  if FZoom = Value then
    Exit;
  FZoom := Value;
  SyncViewToBridge;
end;

procedure TOSMMap.SyncViewToBridge;
begin
  if not FActive or not Assigned(FBridge) then
    Exit;
  FBridge.PostCommand(CreateEnvelope('map.set_view', BuildSetViewPayload));
end;

function TOSMMap.BuildSetViewPayload: string;
begin
  Result := Format(
    '{"center":{"lat":%.15g,"lng":%.15g},"zoom":%.15g}',
    [FCenterLat, FCenterLng, FZoom],
    GMLibInvariantFormatSettings
  );
end;

function TOSMMap.BuildSetStylePayload: string;
begin
  Result := Format(
    '{"styleUrl":"%s"}',
    [StringReplace(ResolveStyleUrl, '"', '\"', [rfReplaceAll])]
  );
end;

function TOSMMap.BuildMarkerAddEnvelope(AMarker: TOSMMarkerItem): TMapLibMessageEnvelope;
begin
  Result := CreateEnvelope('marker.add', AMarker.BuildAddPayload);
end;

function TOSMMap.CreateEnvelope(const AMessageType, APayload: string): TMapLibMessageEnvelope;
begin
{$IFDEF FPC}
  Result := MapLibMessageEnvelopeCreate(AMessageType, FMapId, APayload);
{$ELSE}
  Result := TMapLibMessageEnvelope.Create(AMessageType, FMapId, APayload);
{$ENDIF}
end;

procedure TOSMMap.BridgeMessageReceived(Sender: TObject; const AEnvelope: TMapLibMessageEnvelope);
begin
  try
    if (AEnvelope.TargetId <> '') and (AEnvelope.TargetId <> FMapId) then
      Exit;

    if SameText(AEnvelope.MessageType, 'map.ready') then
    begin
      if Assigned(FOnMapReady) then
        FOnMapReady(Self);
      SyncViewToBridge;
      Exit;
    end;

    if Pos('map.event.', AEnvelope.MessageType) = 1 then
      DispatchMapEvent(Copy(AEnvelope.MessageType, Length('map.event.') + 1, MaxInt), AEnvelope.Payload);
    if Pos('marker.event.', AEnvelope.MessageType) = 1 then
      DispatchMarkerEvent(Copy(AEnvelope.MessageType, Length('marker.event.') + 1, MaxInt), AEnvelope.Payload);
  except
    on E: Exception do
      NotifyProtocolError('BridgeMessageReceived', E);
  end;
end;

procedure TOSMMap.DispatchMarkerEvent(const AEventName, APayload: string);
var
  MarkerId: TGMObjectId;
  LatLng: TMapLibLatLng;
  Marker: TOSMMarkerItem;
begin
  if not TryGetMarkerClickFromPayload(APayload, MarkerId, LatLng) then
    Exit;
  try
    Marker := FMarkers.FindByObjectId(MarkerId);
    if Assigned(Marker) then
    begin
      if SameText(AEventName, 'click') and Assigned(Marker.OnClick) then
        Marker.OnClick(Marker, LatLng)
      else if SameText(AEventName, 'dragstart') and Assigned(Marker.OnDragStart) then
        Marker.OnDragStart(Marker, LatLng)
      else if SameText(AEventName, 'drag') and Assigned(Marker.OnDrag) then
        Marker.OnDrag(Marker, LatLng)
      else if SameText(AEventName, 'dragend') and Assigned(Marker.OnDragEnd) then
        Marker.OnDragEnd(Marker, LatLng);
    end;

  finally
    LatLng.Free;
  end;
end;

procedure TOSMMap.DispatchMapEvent(const AEventName, APayload: string);
var
  LatLng: TMapLibLatLng;
  Center: TMapLibLatLng;
  ZoomValue: Double;
  BearingValue: Double;
  PitchValue: Double;
  North, South, East, West: Double;
  ErrorMessage: string;
  procedure DispatchCoordinate(const AHandler: TOSMMapCoordinateEvent);
  begin
    if not Assigned(AHandler) then
      Exit;
    if not TryGetLatLngFromPayload(APayload, LatLng) then
      Exit;
    try
      AHandler(Self, LatLng);
    finally
      LatLng.Free;
    end;
  end;
  procedure DispatchView(const AHandler: TOSMMapViewChangedEvent);
  begin
    if not Assigned(AHandler) then
      Exit;
    if not TryGetViewFromPayload(APayload, Center, ZoomValue, BearingValue, PitchValue) then
      Exit;
    try
      FBearing := BearingValue;
      FPitch := PitchValue;
      AHandler(Self, Center, ZoomValue, BearingValue, PitchValue);
    finally
      Center.Free;
    end;
  end;
begin
  if SameText(AEventName, 'click') then
    DispatchCoordinate(FOnClick)
  else if SameText(AEventName, 'contextmenu') then
    DispatchCoordinate(FOnContextMenu)
  else if SameText(AEventName, 'dblclick') then
    DispatchCoordinate(FOnDblClick)
  else if SameText(AEventName, 'mousedown') then
    DispatchCoordinate(FOnMouseDown)
  else if SameText(AEventName, 'mousemove') then
    DispatchCoordinate(FOnMouseMove)
  else if SameText(AEventName, 'mouseout') then
    DispatchCoordinate(FOnMouseOut)
  else if SameText(AEventName, 'mouseover') then
    DispatchCoordinate(FOnMouseOver)
  else if SameText(AEventName, 'mouseup') then
    DispatchCoordinate(FOnMouseUp)
  else if SameText(AEventName, 'touchcancel') and Assigned(FOnTouchCancel) then
    FOnTouchCancel(Self)
  else if SameText(AEventName, 'touchend') and Assigned(FOnTouchEnd) then
    FOnTouchEnd(Self)
  else if SameText(AEventName, 'touchmove') and Assigned(FOnTouchMove) then
    FOnTouchMove(Self)
  else if SameText(AEventName, 'touchstart') and Assigned(FOnTouchStart) then
    FOnTouchStart(Self)
  else if SameText(AEventName, 'movestart') then
    DispatchView(FOnMoveStart)
  else if SameText(AEventName, 'move') then
    DispatchView(FOnMove)
  else if SameText(AEventName, 'moveend') then
    DispatchView(FOnMoveEnd)
  else if SameText(AEventName, 'dragstart') then
    DispatchView(FOnDragStart)
  else if SameText(AEventName, 'drag') then
    DispatchView(FOnDrag)
  else if SameText(AEventName, 'dragend') then
    DispatchView(FOnDragEnd)
  else if SameText(AEventName, 'zoomstart') then
    DispatchView(FOnZoomStart)
  else if SameText(AEventName, 'zoom') then
    DispatchView(FOnZoom)
  else if SameText(AEventName, 'zoomend') then
    DispatchView(FOnZoomEnd)
  else if SameText(AEventName, 'rotatestart') then
    DispatchView(FOnRotateStart)
  else if SameText(AEventName, 'rotate') then
    DispatchView(FOnRotate)
  else if SameText(AEventName, 'rotateend') then
    DispatchView(FOnRotateEnd)
  else if SameText(AEventName, 'pitchstart') then
    DispatchView(FOnPitchStart)
  else if SameText(AEventName, 'pitch') then
    DispatchView(FOnPitch)
  else if SameText(AEventName, 'pitchend') then
    DispatchView(FOnPitchEnd)
  else if SameText(AEventName, 'boxzoomstart') and Assigned(FOnBoxZoomStart) then
    FOnBoxZoomStart(Self)
  else if SameText(AEventName, 'boxzoomend') and Assigned(FOnBoxZoomEnd) then
    FOnBoxZoomEnd(Self)
  else if SameText(AEventName, 'boxzoomcancel') and Assigned(FOnBoxZoomCancel) then
    FOnBoxZoomCancel(Self)
  else if SameText(AEventName, 'resize') and Assigned(FOnResize) then
    FOnResize(Self)
  else if SameText(AEventName, 'render') and Assigned(FOnRender) then
    FOnRender(Self)
  else if SameText(AEventName, 'idle') and Assigned(FOnIdle) then
    FOnIdle(Self)
  else if SameText(AEventName, 'load') and Assigned(FOnLoad) then
    FOnLoad(Self)
  else if SameText(AEventName, 'data') and Assigned(FOnData) then
    FOnData(Self)
  else if SameText(AEventName, 'dataloading') and Assigned(FOnDataLoading) then
    FOnDataLoading(Self)
  else if SameText(AEventName, 'dataabort') and Assigned(FOnDataAbort) then
    FOnDataAbort(Self)
  else if SameText(AEventName, 'sourcedata') and Assigned(FOnSourceData) then
    FOnSourceData(Self)
  else if SameText(AEventName, 'sourcedataloading') and Assigned(FOnSourceDataLoading) then
    FOnSourceDataLoading(Self)
  else if SameText(AEventName, 'sourcedataabort') and Assigned(FOnSourceDataAbort) then
    FOnSourceDataAbort(Self)
  else if SameText(AEventName, 'styledata') and Assigned(FOnStyleData) then
    FOnStyleData(Self)
  else if SameText(AEventName, 'styledataloading') and Assigned(FOnStyleDataLoading) then
    FOnStyleDataLoading(Self)
  else if SameText(AEventName, 'styleimagemissing') and Assigned(FOnStyleImageMissing) then
    FOnStyleImageMissing(Self)
  else if SameText(AEventName, 'terrain') and Assigned(FOnTerrain) then
    FOnTerrain(Self)
  else if SameText(AEventName, 'projectiontransition') and Assigned(FOnProjectionTransition) then
    FOnProjectionTransition(Self)
  else if SameText(AEventName, 'webglcontextlost') and Assigned(FOnWebGLContextLost) then
    FOnWebGLContextLost(Self)
  else if SameText(AEventName, 'webglcontextrestored') and Assigned(FOnWebGLContextRestored) then
    FOnWebGLContextRestored(Self)
  else if SameText(AEventName, 'wheel') and Assigned(FOnWheel) then
    FOnWheel(Self)
  else if SameText(AEventName, 'boundschanged') and Assigned(FOnBoundsChanged) and
    TryGetBoundsFromPayload(APayload, North, South, East, West) then
    FOnBoundsChanged(Self, North, South, East, West)
  else if SameText(AEventName, 'error') and Assigned(FOnError) then
  begin
    ErrorMessage := GetErrorMessageFromPayload(APayload);
    FOnError(Self, ErrorMessage);
  end;
end;

function TOSMMap.TryGetLatLngFromPayload(const APayload: string; out ALatLng: TMapLibLatLng): Boolean;
{$IFNDEF FPC}
var
  JsonObject: TJSONObject;
  LatLngValue: TJSONValue;
  LatLngObject: TJSONObject;
  LatValue: Double;
  LngValue: Double;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := False;
  ALatLng := nil;
{$ELSE}
  Result := False;
  ALatLng := nil;
  JsonObject := nil;
  if not TryParsePayloadObject(APayload, JsonObject) then
    Exit;
  try
    LatLngValue := JsonObject.GetValue('latLng');
    if not (LatLngValue is TJSONObject) then
      Exit;
    LatLngObject := TJSONObject(LatLngValue);
    if not TryStrToFloat(LatLngObject.GetValue<string>('lat', '0'), LatValue, GMLibInvariantFormatSettings) then
      Exit;
    if not TryStrToFloat(LatLngObject.GetValue<string>('lng', '0'), LngValue, GMLibInvariantFormatSettings) then
      Exit;
    ALatLng := TMapLibLatLng.Create(LatValue, LngValue);
    Result := True;
  finally
    JsonObject.Free;
  end;
{$ENDIF}
end;

function TOSMMap.TryGetMarkerClickFromPayload(const APayload: string; out AMarkerId: TGMObjectId;
  out ALatLng: TMapLibLatLng): Boolean;
{$IFNDEF FPC}
var
  JsonObject: TJSONObject;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := False;
  AMarkerId := '';
  ALatLng := nil;
{$ELSE}
  Result := False;
  AMarkerId := '';
  ALatLng := nil;
  JsonObject := nil;
  if not TryParsePayloadObject(APayload, JsonObject) then
    Exit;
  try
    AMarkerId := JsonObject.GetValue<string>('objectId', '');
  finally
    JsonObject.Free;
  end;

  if AMarkerId = '' then
    Exit;

  Result := TryGetLatLngFromPayload(APayload, ALatLng);
{$ENDIF}
end;

function TOSMMap.TryGetViewFromPayload(const APayload: string; out ACenter: TMapLibLatLng;
  out AZoom, ABearing, APitch: Double): Boolean;
{$IFNDEF FPC}
var
  JsonObject: TJSONObject;
  CenterValue: TJSONValue;
  CenterObject: TJSONObject;
  LatValue: Double;
  LngValue: Double;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := False;
  ACenter := nil;
  AZoom := 0;
  ABearing := 0;
  APitch := 0;
{$ELSE}
  Result := False;
  ACenter := nil;
  AZoom := 0;
  ABearing := 0;
  APitch := 0;
  JsonObject := nil;
  if not TryParsePayloadObject(APayload, JsonObject) then
    Exit;
  try
    CenterValue := JsonObject.GetValue('center');
    if not (CenterValue is TJSONObject) then
      Exit;
    CenterObject := TJSONObject(CenterValue);
    if not TryStrToFloat(CenterObject.GetValue<string>('lat', '0'), LatValue, GMLibInvariantFormatSettings) then
      Exit;
    if not TryStrToFloat(CenterObject.GetValue<string>('lng', '0'), LngValue, GMLibInvariantFormatSettings) then
      Exit;
    if not TryStrToFloat(JsonObject.GetValue<string>('zoom', '0'), AZoom, GMLibInvariantFormatSettings) then
      Exit;
    TryStrToFloat(JsonObject.GetValue<string>('bearing', '0'), ABearing, GMLibInvariantFormatSettings);
    TryStrToFloat(JsonObject.GetValue<string>('pitch', '0'), APitch, GMLibInvariantFormatSettings);
    ACenter := TMapLibLatLng.Create(LatValue, LngValue);
    Result := True;
  finally
    JsonObject.Free;
  end;
{$ENDIF}
end;

function TOSMMap.TryGetBoundsFromPayload(const APayload: string; out ANorth, ASouth, AEast, AWest: Double): Boolean;
{$IFNDEF FPC}
var
  JsonObject: TJSONObject;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;
{$ELSE}
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;
  JsonObject := nil;
  if not TryParsePayloadObject(APayload, JsonObject) then
    Exit;
  try
    Result :=
      TryStrToFloat(JsonObject.GetValue<string>('north', '0'), ANorth, GMLibInvariantFormatSettings) and
      TryStrToFloat(JsonObject.GetValue<string>('south', '0'), ASouth, GMLibInvariantFormatSettings) and
      TryStrToFloat(JsonObject.GetValue<string>('east', '0'), AEast, GMLibInvariantFormatSettings) and
      TryStrToFloat(JsonObject.GetValue<string>('west', '0'), AWest, GMLibInvariantFormatSettings);
  finally
    JsonObject.Free;
  end;
{$ENDIF}
end;

function TOSMMap.GetErrorMessageFromPayload(const APayload: string): string;
{$IFNDEF FPC}
var
  JsonObject: TJSONObject;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := '';
{$ELSE}
  Result := '';
  JsonObject := nil;
  if not TryParsePayloadObject(APayload, JsonObject) then
    Exit;
  try
    Result := JsonObject.GetValue<string>('message', '');
  finally
    JsonObject.Free;
  end;
{$ENDIF}
end;

procedure TOSMMap.NotifyProtocolError(const AContext: string; const E: Exception);
begin
  if Assigned(FOnError) then
    FOnError(Self, Format('%s: %s', [AContext, E.Message]));
end;

procedure TOSMMap.Activate;
begin
  FActive := True;
  SyncMarkersToBridge;
end;

procedure TOSMMap.Deactivate;
begin
  FActive := False;
  // StopOfflineTileServer;
end;

procedure TOSMMap.SyncMarkersToBridge;
var
  I: Integer;
begin
  if not FActive or not Assigned(FBridge) then
    Exit;

  FBridge.PostCommand(CreateEnvelope('marker.clear', '{}'));
  for I := 0 to FMarkers.Count - 1 do
    FBridge.PostCommand(BuildMarkerAddEnvelope(FMarkers[I]));
end;

procedure TOSMMap.MarkersChanged(Sender: TObject);
begin
  SyncMarkersToBridge;
end;

procedure TOSMMap.ApplyStyle;
begin
  if not FActive or not Assigned(FBridge) then
    Exit;

  // StopOfflineTileServer;
  // EnsureOfflineTileSourceReady;
  FBridge.PostCommand(CreateEnvelope('map.set_style', BuildSetStylePayload));
end;

function TOSMMap.BuildJsBootstrapConfig: string;
var
  Config: TJSONObject;
  Center: TJSONObject;
begin
{$IFDEF FPC}
  Result := '{}';
  Exit;
{$ENDIF}

  Config := TJSONObject.Create;
  try
    Center := TJSONObject.Create;
    Center.AddPair('lat', TJSONNumber.Create(FCenterLat));
    Center.AddPair('lng', TJSONNumber.Create(FCenterLng));

    Config.AddPair('mapId', string(FMapId));
    Config.AddPair('center', Center);
    Config.AddPair('zoom', TJSONNumber.Create(FZoom));
    Config.AddPair('styleUrl', ResolveStyleUrl);

    Result := Config.ToJSON;
  finally
    Config.Free;
  end;
end;

end.
