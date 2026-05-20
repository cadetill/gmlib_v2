{**
  @abstract(VCL wrapper for OSM/MapLibre map component.)
}
unit uOSMLib.Vcl.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
  System.Classes,
  Vcl.Edge,
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uGMLib.Vcl.Bridge.WebView2,
  uOSMLib.Map,
  uOSMLib.Vcl.MapBootstrap;

type
  TOSMLibVclMap = class(TOSMMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    procedure SetBrowser(const Value: TComponent);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    destructor Destroy; override;
    procedure Activate; override;
  published
    property Active;
    property CenterLat;
    property CenterLng;
    property MapId;
    property Zoom;
    property Browser: TComponent read FBrowser write SetBrowser;

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
    property Markers;
    property StyleUrl;
    property MapLibreCssUrl;
    property MapLibreJsUrl;
  end;

  TOSMLibMap = TOSMLibVclMap;

implementation

uses
  System.SysUtils;

{ TOSMLibVclMap }

procedure TOSMLibVclMap.Activate;
var
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

  FBridgeImpl.LoadHtml(TOSMLibMapBootstrap.BuildHtml(Self));
  inherited;
end;

function TOSMLibVclMap.CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
begin
  Result := CreateRegisteredBridgeForBrowser(ABrowser, FBridgeImpl);
  if Assigned(Result) then
  begin
    FBridgeImpl := Result;
    Exit;
  end;

  if ABrowser is TEdgeBrowser then
  begin
    if not Assigned(FBridgeImpl) then
      FBridgeImpl := TGMLibWebView2Bridge.Create(TEdgeBrowser(ABrowser))
    else
      FBridgeImpl.AttachBrowser(TEdgeBrowser(ABrowser));
    Result := FBridgeImpl;
    Exit;
  end;

  raise Exception.Create(
    'No bridge factory registered for the configured VCL browser component. ' +
    'Include the corresponding bridge unit before activating the OSM map.'
  );
end;

destructor TOSMLibVclMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

procedure TOSMLibVclMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TOSMLibVclMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);

  FBrowser := Value;

  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

end.
