{**
  @abstract(Esqueleto LCL del componente de mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define la especializaciÃ³n LCL de `TGMCustomMap`.
}
unit uGMLib.Lcl.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes{$ELSE}System.Classes{$ENDIF},
  uGMLib.Circle,
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uGMLib.GeoCode,
  uGMLib.InfoWindow,
  uGMLib.Map,
  uGMLib.MapOptions,
  uGMLib.Marker,
  uGMLib.Polygon,
  uGMLib.Polyline,
  uGMLib.Rectangle,
  uGMLib.Lcl.Circle,
  uGMLib.Lcl.Polygon,
  uGMLib.Lcl.Rectangle,
  uGMLib.Lcl.MapBootstrap,
  uGMLib.Lcl.MapOptions;

type
  {** @abstract(Componente LCL del mapa de Google Maps.) }
  TGMLibLclMap = class(TGMCustomMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    function GetCircles: TGMLclCircles;
    function GetInfoWindows: TGMInfoWindows;
    function GetMarkers: TGMMarkers;
    function GetPolygons: TGMLclPolygons;
    function GetPolylines: TGMPolylines;
    function GetRectangles: TGMLclRectangles;
    function GetOptions: TGMLclMapOptions;
    procedure SetBrowser(const Value: TComponent);
    procedure SetCircles(const Value: TGMLclCircles);
    procedure SetInfoWindows(const Value: TGMInfoWindows);
    procedure SetMarkers(const Value: TGMMarkers);
    procedure SetPolygons(const Value: TGMLclPolygons);
    procedure SetPolylines(const Value: TGMPolylines);
    procedure SetRectangles(const Value: TGMLclRectangles);
    procedure SetOptions(const Value: TGMLclMapOptions);
  protected
    function BuildBootstrapHtml: string; virtual;
    function CreateInfoWindows: TGMInfoWindows; override;
    function CreateMarkers: TGMMarkers; override;
    function CreatePolygons: TGMPolygons; override;
    function CreatePolylines: TGMPolylines; override;
    function CreateRectangles: TGMRectangles; override;
    function CreateCircles: TGMCircles; override;
    function CreateMapOptions: TGMMapOptions; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    destructor Destroy; override;
    procedure Activate; override;
  published
    property Active;
    property APIUrl;
    property Browser: TComponent read FBrowser write SetBrowser;
    property APIKey;
    property Circles: TGMLclCircles read GetCircles write SetCircles;
    property InfoWindows: TGMInfoWindows read GetInfoWindows write SetInfoWindows;
    property Markers: TGMMarkers read GetMarkers write SetMarkers;
    property Polygons: TGMLclPolygons read GetPolygons write SetPolygons;
    property Polylines: TGMPolylines read GetPolylines write SetPolylines;
    property Rectangles: TGMLclRectangles read GetRectangles write SetRectangles;
    property Options: TGMLclMapOptions read GetOptions write SetOptions;

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

  TGMLibMap = TGMLibLclMap;

implementation

uses
  SysUtils;

procedure TGMLibLclMap.Activate;
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

function TGMLibLclMap.BuildBootstrapHtml: string;
begin
  Result := TGMLibLclMapBootstrap.BuildHtml(Self);
end;

function TGMLibLclMap.CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
begin
  Result := CreateRegisteredBridgeForBrowser(ABrowser, FBridgeImpl);
  if Assigned(Result) then
  begin
    FBridgeImpl := Result;
    Exit;
  end;

  raise Exception.Create(
    'No bridge factory registered for the configured LCL browser component. ' +
    'Include the corresponding bridge unit/package (for example CEF4Delphi) before activating the map.'
  );
end;

function TGMLibLclMap.GetOptions: TGMLclMapOptions;
begin
  Result := TGMLclMapOptions(inherited Options);
end;

function TGMLibLclMap.CreateCircles: TGMCircles;
begin
  Result := TGMLclCircles.Create(Self);
end;

function TGMLibLclMap.CreateInfoWindows: TGMInfoWindows;
begin
  Result := TGMInfoWindows.Create(Self);
end;

function TGMLibLclMap.CreateMarkers: TGMMarkers;
begin
  Result := TGMMarkers.Create(Self);
end;

function TGMLibLclMap.CreateMapOptions: TGMMapOptions;
begin
  Result := TGMLclMapOptions.Create;
end;

function TGMLibLclMap.CreatePolygons: TGMPolygons;
begin
  Result := TGMLclPolygons.Create(Self);
end;

function TGMLibLclMap.CreatePolylines: TGMPolylines;
begin
  Result := TGMPolylines.Create(Self);
end;

function TGMLibLclMap.CreateRectangles: TGMRectangles;
begin
  Result := TGMLclRectangles.Create(Self);
end;

destructor TGMLibLclMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

function TGMLibLclMap.GetCircles: TGMLclCircles;
begin
  Result := TGMLclCircles(inherited Circles);
end;

function TGMLibLclMap.GetInfoWindows: TGMInfoWindows;
begin
  Result := TGMInfoWindows(inherited InfoWindows);
end;

function TGMLibLclMap.GetMarkers: TGMMarkers;
begin
  Result := TGMMarkers(inherited Markers);
end;

function TGMLibLclMap.GetPolygons: TGMLclPolygons;
begin
  Result := TGMLclPolygons(inherited Polygons);
end;

function TGMLibLclMap.GetPolylines: TGMPolylines;
begin
  Result := TGMPolylines(inherited Polylines);
end;

function TGMLibLclMap.GetRectangles: TGMLclRectangles;
begin
  Result := TGMLclRectangles(inherited Rectangles);
end;

procedure TGMLibLclMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);

  FBrowser := Value;

  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

procedure TGMLibLclMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TGMLibLclMap.SetCircles(const Value: TGMLclCircles);
begin
  inherited Circles := Value;
end;

procedure TGMLibLclMap.SetInfoWindows(const Value: TGMInfoWindows);
begin
  inherited InfoWindows := Value;
end;

procedure TGMLibLclMap.SetMarkers(const Value: TGMMarkers);
begin
  inherited Markers := Value;
end;

procedure TGMLibLclMap.SetPolygons(const Value: TGMLclPolygons);
begin
  inherited Polygons := Value;
end;

procedure TGMLibLclMap.SetPolylines(const Value: TGMPolylines);
begin
  inherited Polylines := Value;
end;

procedure TGMLibLclMap.SetRectangles(const Value: TGMLclRectangles);
begin
  inherited Rectangles := Value;
end;

procedure TGMLibLclMap.SetOptions(const Value: TGMLclMapOptions);
begin
  inherited Options := Value;
end;

end.



