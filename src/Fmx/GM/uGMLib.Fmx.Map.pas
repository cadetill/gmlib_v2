{**
  @abstract(Esqueleto FMX del nuevo componente de mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define la primera especializaciÃƒÂ³n `FMX` de `TGMCustomMap`.
}
unit uGMLib.Fmx.Map;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  FMX.WebBrowser,
  uGMLib.Circle,
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uGMLib.GeoCode,
  uGMLib.InfoWindow,
  uGMLib.Map,
  uGMLib.Marker,
  uGMLib.Polygon,
  uGMLib.Polyline,
  uGMLib.Rectangle,
  uGMLib.Fmx.Circle,
  uGMLib.Fmx.InfoWindow,
  uGMLib.Fmx.Marker,
  uGMLib.Fmx.Polygon,
  uGMLib.Fmx.Polyline,
  uGMLib.Fmx.Rectangle,
  uGMLib.MapOptions,
  uGMLib.Fmx.MapOptions,
  uGMLib.Fmx.MapBootstrap,
  uGMLib.Fmx.Bridge.WebBrowser;

type
  {** @abstract(Componente FMX del mapa de Google Maps.) }
  TGMLibFmxMap = class(TGMCustomMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    FBridgeInterval: Integer;
    function GetCircles: TGMFmxCircles;
    function GetInfoWindows: TGMFmxInfoWindows;
    function GetMarkers: TGMFmxMarkers;
    function GetPolygons: TGMFmxPolygons;
    function GetOptions: TGMFmxMapOptions;
    function GetPolylines: TGMFmxPolylines;
    function GetRectangles: TGMFmxRectangles;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    procedure SetBrowser(const Value: TComponent);
    procedure SetCircles(const Value: TGMFmxCircles);
    procedure SetInfoWindows(const Value: TGMFmxInfoWindows);
    procedure SetMarkers(const Value: TGMFmxMarkers);
    procedure SetPolygons(const Value: TGMFmxPolygons);
    procedure SetOptions(const Value: TGMFmxMapOptions);
    procedure SetPolylines(const Value: TGMFmxPolylines);
    procedure SetRectangles(const Value: TGMFmxRectangles);
    procedure SetBridgeInterval(const Value: Integer);
  protected
    {** @abstract(Genera el HTML de bootstrap que inicializa el runtime JS del mapa.) }
    function BuildBootstrapHtml: string; virtual;
    function CreateInfoWindows: TGMInfoWindows; override;
    function CreateMarkers: TGMMarkers; override;
    function CreatePolygons: TGMPolygons; override;
    function CreatePolylines: TGMPolylines; override;
    function CreateRectangles: TGMRectangles; override;
    function CreateCircles: TGMCircles; override;
    {** @abstract(Crea la variante FMX de `TGMMapOptions`.) }
    function CreateMapOptions: TGMMapOptions; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    {** @abstract(Libera el bridge asociado al navegador FMX.) }
    destructor Destroy; override;
    {** @abstract(Activa el mapa asegurando que `Browser` y bridge estÃƒÂ©n preparados.) }
    procedure Activate; override;
  published
    property Active;
    property APIUrl;
    {** @abstract(Control host usado para el mapa.) }
    property Browser: TComponent read FBrowser write SetBrowser;

    property APIKey;
    property Circles: TGMFmxCircles read GetCircles write SetCircles;
    property InfoWindows: TGMFmxInfoWindows read GetInfoWindows write SetInfoWindows;
    property Markers: TGMFmxMarkers read GetMarkers write SetMarkers;
    property Polygons: TGMFmxPolygons read GetPolygons write SetPolygons;
    property Polylines: TGMFmxPolylines read GetPolylines write SetPolylines;
    property Rectangles: TGMFmxRectangles read GetRectangles write SetRectangles;
    {** @abstract(Acceso tipado a las opciones FMX del mapa.) }
    property Options: TGMFmxMapOptions read GetOptions write SetOptions;

    property OnBoundsChanged;
    property OnCenterChanged;
    property OnContextMenu;
    property OnDblClick;
    property OnDrag;
    property OnDragEnd;
    property OnDragStart;
    property OnHeadingChanged;
    property OnIdle;
    property OnMapClick;
    property OnMapTypeIdChanged;
    property OnMapReady;
    property OnMouseOut;
    property OnMouseOver;
    property OnMouseMove;
    property OnProjectionChanged;
    property OnRenderingTypeChanged;
    property OnTilesLoaded;
    property OnTiltChanged;
    property OnZoomChanged;
    {** @abstract(Intervalo del polling del bridge FMX, en milisegundos.) }
    property BridgeInterval: Integer read FBridgeInterval write SetBridgeInterval default 100;
  end;

  TGMLibMap = TGMLibFmxMap;

implementation

uses
  System.SysUtils;

{ TGMLibFmxMap }

constructor TGMLibFmxMap.Create(AOwner: TComponent);
begin
  inherited;
  FBridgeInterval := 100;
end;

procedure TGMLibFmxMap.Activate;
begin
  if Active then
    Exit;

  if not Assigned(FBrowser) then
    raise Exception.Create('Browser is not assigned.');
  FBridgeImpl := CreateBridgeForBrowser(FBrowser);
  Bridge := FBridgeImpl;
  if FBridgeImpl is TGMLibFmxWebBrowserBridge then
    TGMLibFmxWebBrowserBridge(FBridgeImpl).PollInterval := FBridgeInterval;
  FBridgeImpl.LoadHtml(BuildBootstrapHtml);
  inherited;
end;

function TGMLibFmxMap.BuildBootstrapHtml: string;
begin
  Result := TGMLibFmxMapBootstrap.BuildHtml(Self);
end;

function TGMLibFmxMap.CreateInfoWindows: TGMInfoWindows;
begin
  Result := TGMFmxInfoWindows.Create(Self);
end;

function TGMLibFmxMap.CreateMarkers: TGMMarkers;
begin
  Result := TGMFmxMarkers.Create(Self);
end;

function TGMLibFmxMap.CreatePolygons: TGMPolygons;
begin
  Result := TGMFmxPolygons.Create(Self);
end;

function TGMLibFmxMap.CreatePolylines: TGMPolylines;
begin
  Result := TGMFmxPolylines.Create(Self);
end;

function TGMLibFmxMap.CreateRectangles: TGMRectangles;
begin
  Result := TGMFmxRectangles.Create(Self);
end;

function TGMLibFmxMap.CreateCircles: TGMCircles;
begin
  Result := TGMFmxCircles.Create(Self);
end;

function TGMLibFmxMap.CreateBridgeForBrowser(
  const ABrowser: TComponent): IMapBridgeTransport;
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

  raise Exception.Create('Unsupported browser component for FMX map.');
end;

function TGMLibFmxMap.CreateMapOptions: TGMMapOptions;
begin
  Result := TGMFmxMapOptions.Create;
end;

destructor TGMLibFmxMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

function TGMLibFmxMap.GetInfoWindows: TGMFmxInfoWindows;
begin
  Result := TGMFmxInfoWindows(inherited InfoWindows);
end;

function TGMLibFmxMap.GetMarkers: TGMFmxMarkers;
begin
  Result := TGMFmxMarkers(inherited Markers);
end;

function TGMLibFmxMap.GetPolygons: TGMFmxPolygons;
begin
  Result := TGMFmxPolygons(inherited Polygons);
end;

function TGMLibFmxMap.GetOptions: TGMFmxMapOptions;
begin
  Result := TGMFmxMapOptions(inherited Options);
end;

function TGMLibFmxMap.GetPolylines: TGMFmxPolylines;
begin
  Result := TGMFmxPolylines(inherited Polylines);
end;

procedure TGMLibFmxMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);

  FBrowser := Value;

  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

procedure TGMLibFmxMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TGMLibFmxMap.SetBridgeInterval(const Value: Integer);
begin
  if Value < 20 then
    FBridgeInterval := 20
  else if Value > 1000 then
    FBridgeInterval := 1000
  else
    FBridgeInterval := Value;

  if FBridgeImpl is TGMLibFmxWebBrowserBridge then
    TGMLibFmxWebBrowserBridge(FBridgeImpl).PollInterval := FBridgeInterval;
end;

procedure TGMLibFmxMap.SetInfoWindows(const Value: TGMFmxInfoWindows);
begin
  inherited InfoWindows := Value;
end;

procedure TGMLibFmxMap.SetMarkers(const Value: TGMFmxMarkers);
begin
  inherited Markers := Value;
end;

procedure TGMLibFmxMap.SetPolygons(const Value: TGMFmxPolygons);
begin
  inherited Polygons := Value;
end;

procedure TGMLibFmxMap.SetOptions(const Value: TGMFmxMapOptions);
begin
  inherited Options := Value;
end;

procedure TGMLibFmxMap.SetPolylines(const Value: TGMFmxPolylines);
begin
  inherited Polylines := Value;
end;

function TGMLibFmxMap.GetRectangles: TGMFmxRectangles;
begin
  Result := TGMFmxRectangles(inherited Rectangles);
end;

procedure TGMLibFmxMap.SetRectangles(const Value: TGMFmxRectangles);
begin
  inherited Rectangles := Value;
end;

function TGMLibFmxMap.GetCircles: TGMFmxCircles;
begin
  Result := TGMFmxCircles(inherited Circles);
end;

procedure TGMLibFmxMap.SetCircles(const Value: TGMFmxCircles);
begin
  inherited Circles := Value;
end;

end.






