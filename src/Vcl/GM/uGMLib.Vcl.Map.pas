{**
  @abstract(Esqueleto VCL del nuevo componente de mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define la primera especializaciÃ³n VCL de `TGMCustomMap`.
}
unit uGMLib.Vcl.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
  System.Classes, Vcl.Edge, uGMLib.Circle, uMapLib.Core.Bridge, uGMLib.GeoCode,
  uGMLib.InfoWindow, uGMLib.Map, uGMLib.Marker, uGMLib.Polygon, uGMLib.Polyline, uGMLib.Rectangle,
  uGMLib.Vcl.Circle, uGMLib.Vcl.InfoWindow, uGMLib.Vcl.Marker,
  uGMLib.Vcl.Polygon, uGMLib.Vcl.Polyline, uGMLib.Vcl.Rectangle,
  uGMLib.MapOptions, uGMLib.Vcl.MapOptions, uGMLib.Vcl.MapBootstrap,
  uMapLib.Core.BridgeRegistry, uGMLib.Vcl.Bridge.WebView2;

type
  {** @abstract(Componente VCL del mapa de Google Maps.) }
  TGMLibVclMap = class(TGMCustomMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    function GetCircles: TGMVclCircles;
    function GetInfoWindows: TGMVclInfoWindows;
    function GetMarkers: TGMVclMarkers;
    function GetPolygons: TGMVclPolygons;
    function GetOptions: TGMVclMapOptions;
    function GetPolylines: TGMVclPolylines;
    function GetRectangles: TGMVclRectangles;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    procedure SetBrowser(const Value: TComponent);
    procedure SetCircles(const Value: TGMVclCircles);
    procedure SetInfoWindows(const Value: TGMVclInfoWindows);
    procedure SetMarkers(const Value: TGMVclMarkers);
    procedure SetPolygons(const Value: TGMVclPolygons);
    procedure SetOptions(const Value: TGMVclMapOptions);
    procedure SetPolylines(const Value: TGMVclPolylines);
    procedure SetRectangles(const Value: TGMVclRectangles);
  protected
    {** @abstract(Genera el HTML de bootstrap que inicializa el runtime JS del mapa.) }
    function BuildBootstrapHtml: string; virtual;
    function CreateInfoWindows: TGMInfoWindows; override;
    function CreateMarkers: TGMMarkers; override;
    function CreatePolygons: TGMPolygons; override;
    function CreatePolylines: TGMPolylines; override;
    function CreateRectangles: TGMRectangles; override;
    function CreateCircles: TGMCircles; override;
    {** @abstract(Crea la variante VCL de `TGMMapOptions`.) }
    function CreateMapOptions: TGMMapOptions; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    {** @abstract(Libera el bridge asociado al navegador WebView2.) }
    destructor Destroy; override;
    {** @abstract(Activa el mapa asegurando que `Browser` y bridge estén preparados.) }
    procedure Activate; override;
  published
    property Active;
    property APIUrl;
    {** @abstract(Control host usado para el mapa.) }
    property Browser: TComponent read FBrowser write SetBrowser;

    property APIKey;
    property Circles: TGMVclCircles read GetCircles write SetCircles;
    property InfoWindows: TGMVclInfoWindows read GetInfoWindows write SetInfoWindows;
    property Markers: TGMVclMarkers read GetMarkers write SetMarkers;
    property Polygons: TGMVclPolygons read GetPolygons write SetPolygons;
    property Polylines: TGMVclPolylines read GetPolylines write SetPolylines;
    property Rectangles: TGMVclRectangles read GetRectangles write SetRectangles;
    {** @abstract(Acceso tipado a las opciones VCL del mapa.) }
    property Options: TGMVclMapOptions read GetOptions write SetOptions;

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
  end;

  TGMLibMap = TGMLibVclMap;

implementation

uses
  System.SysUtils;

{ TGMLibVclMap }

procedure TGMLibVclMap.Activate;
begin
  if Active then
    Exit;

  if not Assigned(FBrowser) then
    raise Exception.Create('Browser is not assigned.');
  FBridgeImpl := CreateBridgeForBrowser(FBrowser);
  Bridge := FBridgeImpl;
  FBridgeImpl.LoadHtml(BuildBootstrapHtml);
  inherited;
end;

function TGMLibVclMap.BuildBootstrapHtml: string;
begin
  Result := TGMLibMapBootstrap.BuildHtml(Self);
end;

function TGMLibVclMap.CreateInfoWindows: TGMInfoWindows;
begin
  Result := TGMVclInfoWindows.Create(Self);
end;

function TGMLibVclMap.CreateMarkers: TGMMarkers;
begin
  Result := TGMVclMarkers.Create(Self);
end;

function TGMLibVclMap.CreatePolygons: TGMPolygons;
begin
  Result := TGMVclPolygons.Create(Self);
end;

function TGMLibVclMap.CreatePolylines: TGMPolylines;
begin
  Result := TGMVclPolylines.Create(Self);
end;

function TGMLibVclMap.CreateRectangles: TGMRectangles;
begin
  Result := TGMVclRectangles.Create(Self);
end;

function TGMLibVclMap.CreateCircles: TGMCircles;
begin
  Result := TGMVclCircles.Create(Self);
end;

function TGMLibVclMap.CreateBridgeForBrowser(
  const ABrowser: TComponent): IMapBridgeTransport;
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

  raise Exception.Create('Unsupported browser component for VCL map.');
end;

function TGMLibVclMap.CreateMapOptions: TGMMapOptions;
begin
  Result := TGMVclMapOptions.Create;
end;

destructor TGMLibVclMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

function TGMLibVclMap.GetInfoWindows: TGMVclInfoWindows;
begin
  Result := TGMVclInfoWindows(inherited InfoWindows);
end;

function TGMLibVclMap.GetMarkers: TGMVclMarkers;
begin
  Result := TGMVclMarkers(inherited Markers);
end;

function TGMLibVclMap.GetPolygons: TGMVclPolygons;
begin
  Result := TGMVclPolygons(inherited Polygons);
end;

function TGMLibVclMap.GetOptions: TGMVclMapOptions;
begin
  Result := TGMVclMapOptions(inherited Options);
end;

function TGMLibVclMap.GetPolylines: TGMVclPolylines;
begin
  Result := TGMVclPolylines(inherited Polylines);
end;

procedure TGMLibVclMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);

  FBrowser := Value;

  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

procedure TGMLibVclMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TGMLibVclMap.SetInfoWindows(const Value: TGMVclInfoWindows);
begin
  inherited InfoWindows := Value;
end;

procedure TGMLibVclMap.SetMarkers(const Value: TGMVclMarkers);
begin
  inherited Markers := Value;
end;

procedure TGMLibVclMap.SetPolygons(const Value: TGMVclPolygons);
begin
  inherited Polygons := Value;
end;

procedure TGMLibVclMap.SetOptions(const Value: TGMVclMapOptions);
begin
  inherited Options := Value;
end;

procedure TGMLibVclMap.SetPolylines(const Value: TGMVclPolylines);
begin
  inherited Polylines := Value;
end;

function TGMLibVclMap.GetRectangles: TGMVclRectangles;
begin
  Result := TGMVclRectangles(inherited Rectangles);
end;

procedure TGMLibVclMap.SetRectangles(const Value: TGMVclRectangles);
begin
  inherited Rectangles := Value;
end;

function TGMLibVclMap.GetCircles: TGMVclCircles;
begin
  Result := TGMVclCircles(inherited Circles);
end;

procedure TGMLibVclMap.SetCircles(const Value: TGMVclCircles);
begin
  inherited Circles := Value;
end;

end.




