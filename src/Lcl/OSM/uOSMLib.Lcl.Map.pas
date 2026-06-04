{**
  @abstract(LCL wrapper for OSM/MapLibre map component.)
}
unit uOSMLib.Lcl.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes{$ELSE}System.Classes{$ENDIF},
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uOSMLib.Map,
  uOSMLib.Lcl.MapBootstrap;

type
  TOSMLibLclMap = class(TOSMMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    FBridgeInterval: Integer;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    procedure SetBrowser(const Value: TComponent);
    procedure SetBridgeInterval(const Value: Integer);
  protected
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
    property MapId;
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
    property OnBoundsChanged;
    property OnError;
    property OnOfflineDownloadProgress;
    property OnOfflineRegionReady;
    property OnOfflineError;
    property Markers;
    property StyleUrl;
    property MapLibreCssUrl;
    property MapLibreJsUrl;
    property Zoom;
    property Browser: TComponent read FBrowser write SetBrowser;
    property BridgeInterval: Integer read FBridgeInterval write SetBridgeInterval default 100;
  end;

  TOSMLibMap = TOSMLibLclMap;

implementation

uses
  SysUtils;

constructor TOSMLibLclMap.Create(AOwner: TComponent);
begin
  inherited;
  FBridgeInterval := 100;
end;

procedure TOSMLibLclMap.Activate;
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
  FBridgeImpl.LoadHtml(TOSMLibLclMapBootstrap.BuildHtml(Self));
  inherited;
end;

function TOSMLibLclMap.CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
begin
  Result := CreateRegisteredBridgeForBrowser(ABrowser, FBridgeImpl);
  if Assigned(Result) then
  begin
    FBridgeImpl := Result;
    Exit;
  end;

  raise Exception.Create(
    'No bridge factory registered for the configured LCL browser component. ' +
    'Include the corresponding bridge unit/package (for example CEF4Delphi) before activating the OSM map.'
  );
end;

destructor TOSMLibLclMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

procedure TOSMLibLclMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TOSMLibLclMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);

  FBrowser := Value;

  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

procedure TOSMLibLclMap.SetBridgeInterval(const Value: Integer);
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
