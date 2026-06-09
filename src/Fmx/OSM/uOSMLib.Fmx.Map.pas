{**
  @abstract(FMX wrapper for OSM/MapLibre map component.)
}
unit uOSMLib.Fmx.Map;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  FMX.WebBrowser,
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uGMLib.Fmx.Bridge.WebBrowser,
  uOSMLib.Map,
  uOSMLib.Fmx.Marker,
  uOSMLib.Fmx.MapBootstrap;

type
  TOSMLibFmxMap = class(TOSMMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    FBridgeInterval: Integer;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    function GetMarkers: TOSMFmxMarkers;
    procedure SetBrowser(const Value: TComponent);
    procedure SetBridgeInterval(const Value: Integer);
    procedure SetMarkers(const Value: TOSMFmxMarkers);
  protected
    function CreateMarkers: TOSMMarkers; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Activate; override;
  published
    property Active;
    property OfflineStoragePath;
    property MapMode;
    property OfflinePolicy;
    property RemoteTileTemplate;
    property StyleTemplateFileName;
    property GlyphsRootPath;
    property CenterLat;
    property CenterLng;
    property MinZoom;
    property MaxZoom;
    property MinPitch;
    property MaxPitch;
    property MaxBounds;
    property MapId;
    property Zoom;
    property Bearing;
    property Pitch;
    property RenderWorldCopies;
    property DragPanEnabled;
    property DragRotateEnabled;
    property DoubleClickZoomEnabled;
    property ScrollZoomEnabled;
    property KeyboardEnabled;
    property TouchZoomRotateEnabled;
    property TouchPitchEnabled;
    property CooperativeGesturesEnabled;
    property OnMapReady;
    property OnClick;
    property OnContextMenu;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseOut;
    property OnMouseOver;
    property OnMouseUp;
    property OnTouchCancel;
    property OnTouchEnd;
    property OnTouchMove;
    property OnTouchStart;
    property OnMoveStart;
    property OnMove;
    property OnMoveEnd;
    property OnDragStart;
    property OnDrag;
    property OnDragEnd;
    property OnZoomStart;
    property OnZoom;
    property OnZoomEnd;
    property OnRotateStart;
    property OnRotate;
    property OnRotateEnd;
    property OnPitchStart;
    property OnPitch;
    property OnPitchEnd;
    property OnBoxZoomStart;
    property OnBoxZoomEnd;
    property OnBoxZoomCancel;
    property OnResize;
    property OnRender;
    property OnIdle;
    property OnLoad;
    property OnData;
    property OnDataLoading;
    property OnDataAbort;
    property OnSourceData;
    property OnSourceDataLoading;
    property OnSourceDataAbort;
    property OnStyleData;
    property OnStyleDataLoading;
    property OnStyleImageMissing;
    property OnTerrain;
    property OnProjectionTransition;
    property OnWebGLContextLost;
    property OnWebGLContextRestored;
    property OnWheel;
    property OnCooperativeGesturePrevented;
    property OnBoundsChanged;
    property OnError;
    property OnOfflineDownloadProgress;
    property OnOfflineRegionReady;
    property OnOfflineError;
    property Markers: TOSMFmxMarkers read GetMarkers write SetMarkers;
    property StyleUrl;
    property MapLibreCssUrl;
    property MapLibreJsUrl;
    property Browser: TComponent read FBrowser write SetBrowser;
    property BridgeInterval: Integer read FBridgeInterval write SetBridgeInterval default 100;
  end;

  TOSMLibMap = TOSMLibFmxMap;

implementation

uses
  System.SysUtils;

constructor TOSMLibFmxMap.Create(AOwner: TComponent);
begin
  inherited;
  FBridgeInterval := 100;
end;

procedure TOSMLibFmxMap.Activate;
var
  IntervalBridge: IMapBridgeInterval;
  NamespacedBridge: IMapBridgeJavaScriptNamespace;
begin
  if Active then
    Exit;
  if not Assigned(FBrowser) then
    raise Exception.Create('Browser is not assigned.');

  FBridgeImpl := CreateBridgeForBrowser(FBrowser);
  if Supports(FBridgeImpl, IMapBridgeJavaScriptNamespace, NamespacedBridge) then
    NamespacedBridge.JavaScriptNamespace := 'maplib';
  Bridge := FBridgeImpl;
  if Supports(FBridgeImpl, IMapBridgeInterval, IntervalBridge) then
    IntervalBridge.BridgeInterval := FBridgeInterval;
  // EnsureOfflineTileSourceReady;
  FBridgeImpl.LoadHtml(TOSMLibFmxMapBootstrap.BuildHtml(Self));
  inherited;
end;

function TOSMLibFmxMap.CreateMarkers: TOSMMarkers;
begin
  Result := TOSMFmxMarkers.Create(Self);
end;

function TOSMLibFmxMap.CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
begin
  Result := CreateRegisteredBridgeForBrowser(ABrowser, FBridgeImpl);
  if Assigned(Result) then
  begin
    FBridgeImpl := Result;
    Exit;
  end;

  if ABrowser is TWebBrowser then
  begin
    if not Assigned(FBridgeImpl) then
      FBridgeImpl := TGMLibFmxWebBrowserBridge.Create(TWebBrowser(ABrowser))
    else
      FBridgeImpl.AttachBrowser(TWebBrowser(ABrowser));
    Result := FBridgeImpl;
    Exit;
  end;

  raise Exception.Create('Unsupported browser component for FMX OSM map.');
end;

destructor TOSMLibFmxMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

function TOSMLibFmxMap.GetMarkers: TOSMFmxMarkers;
begin
  Result := TOSMFmxMarkers(inherited Markers);
end;

procedure TOSMLibFmxMap.SetMarkers(const Value: TOSMFmxMarkers);
begin
  inherited Markers := Value;
end;

procedure TOSMLibFmxMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TOSMLibFmxMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);
  FBrowser := Value;
  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

procedure TOSMLibFmxMap.SetBridgeInterval(const Value: Integer);
var
  IntervalBridge: IMapBridgeInterval;
begin
  if Value < 10 then
    FBridgeInterval := 10
  else
    FBridgeInterval := Value;

  if Supports(FBridgeImpl, IMapBridgeInterval, IntervalBridge) then
    IntervalBridge.BridgeInterval := FBridgeInterval;
end;

end.
