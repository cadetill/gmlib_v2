{**
  @abstract(Núcleo común del componente de mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define el estado compartido y la lógica base de `TGMMap` antes
  de conectar un backend concreto de navegador o framework.
}
unit uGMLib.Map;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, fpjson, jsonparser, Math, SysUtils, Generics.Collections,
{$ELSE}
  System.Classes, System.JSON, System.Math, System.SysUtils, System.Generics.Collections,
{$ENDIF}
  uGMLib.GeoCode,
  uGMLib.Circle,
  uGMLib.GroundOverlay,
  uGMLib.Core.Bridge,
  uGMLib.Core.Component,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.Elevation,
  uGMLib.InfoWindow,
  uGMLib.Layers,
  uGMLib.Marker,
  uGMLib.Polygon,
  uGMLib.Polyline,
  uGMLib.Rectangle,
  uGMLib.Routes,
  uGMLib.MapOptions,
  uGMLib.Platform.Format;

type
  TGMCustomMap = class;

  {** @abstract(Evento emitido cuando cambian los límites visibles del mapa.) }
  TGMMapBoundsEvent = procedure(Sender: TObject; ABounds: TGMLatLngBounds) of object;
  {** @abstract(Evento emitido con una coordenada del mapa.) }
  TGMMapCoordinateEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng) of object;
  {** @abstract(Evento emitido con coordenada y `placeId` opcional de click.) }
  TGMMapClickEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng;
    const APlaceId: string) of object;
  {** @abstract(Evento emitido cuando cambia la orientación horizontal del mapa.) }
  TGMMapHeadingChangedEvent = procedure(Sender: TObject; AHeading: Double) of object;
  {** @abstract(Evento emitido cuando cambia el tipo de mapa activo.) }
  TGMMapTypeIdChangedEvent = procedure(Sender: TObject; AMapTypeId: TGMMapTypeId) of object;
  {** @abstract(Evento emitido cuando cambia la inclinación activa del mapa.) }
  TGMMapTiltChangedEvent = procedure(Sender: TObject; ATilt: Integer) of object;
  {** @abstract(Evento emitido cuando cambia el `RenderingType` activo.) }
  TGMMapRenderingTypeChangedEvent = procedure(Sender: TObject;
    ARenderingType: TGMRenderingType) of object;
  {** @abstract(Evento emitido cuando cambia el nivel de zoom.) }
  TGMMapZoomChangedEvent = procedure(Sender: TObject; AZoom: Integer) of object;

  {** @abstract(Base para componentes públicos vinculados a un `TGMCustomMap`.) }
  TGMCustomMapLinkedComponent = class(TGMLibComponent)
  private
    class var FNextObjectId: Integer;
  private
    FMap: TGMCustomMap;
    FObjectId: TGMObjectId;
    procedure SetMap(const Value: TGMCustomMap);
  protected
    {** @abstract(Emite al mapa los comandos necesarios para materializar el estado actual.) }
    procedure ApplyStateToMap; virtual;
    {** @abstract(Genera el identificador estable usado para routing con `targetId`.) }
    function BuildObjectId: TGMObjectId; virtual;
    function GetAPIUrl: string; override;
    {** @abstract(Se ejecuta cuando cambia la referencia al mapa propietario.) }
    procedure MapChanged; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    {** @abstract(Procesa un mensaje dirigido a este componente desde el mapa.) }
    procedure ProcessMapMessage(const AEnvelope: TGMMessageEnvelope); virtual;
    {** @abstract(Envía JavaScript a través del mapa enlazado.) }
    procedure SendCommand(const ACommand: string); virtual;
    {** @abstract(Notifica al mapa que el estado Delphi del componente ha cambiado.) }
    procedure StateChanged; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    {** @abstract(Identificador lógico del componente dentro del mapa.) }
    property ObjectId: TGMObjectId read FObjectId;
  published
    property AboutGMLib;
    {** @abstract(Mapa al que queda enlazado el componente.) }
    property Map: TGMCustomMap read FMap write SetMap;
  end;

  {** @abstract(Clase base común del mapa de Google Maps.) }
  TGMCustomMap = class(TGMLibComponent, IGMMapViewportHost)
  private
    FActive: Boolean;
    FAPIKey: string;
    FBridge: IGMBridgeTransport;
{$IFDEF FPC}
    FCommandQueue: specialize TList<string>;
    FLinkedComponents: specialize TObjectDictionary<TGMObjectId, TGMCustomMapLinkedComponent>;
    FPendingGeocodeRequests: specialize TObjectList<TGMGeocodePendingRequest>;
    FPendingElevationRequests: specialize TObjectList<TGMElevationPendingRequest>;
    FPendingRouteRequests: specialize TObjectList<TGMRoutePendingRequest>;
{$ELSE}
    FCommandQueue: TList<string>;
    FLinkedComponents: TObjectDictionary<TGMObjectId, TGMCustomMapLinkedComponent>;
    FPendingGeocodeRequests: TObjectList<TGMGeocodePendingRequest>;
    FPendingElevationRequests: TObjectList<TGMElevationPendingRequest>;
    FPendingRouteRequests: TObjectList<TGMRoutePendingRequest>;
{$ENDIF}
    FIsReady: Boolean;
    {** @abstract(Indica que ya recibimos el primer `map.idle` estable del mapa.) }
    FMapIdleReceived: Boolean;
    FInitializationOptionsSignature: string;
    FMapId: TGMMapId;
    FOnBoundsChanged: TGMMapBoundsEvent;
    FOnDblClick: TGMMapCoordinateEvent;
    FOnDrag: TNotifyEvent;
    FOnDragEnd: TNotifyEvent;
    FOnDragStart: TNotifyEvent;
    FOnCenterChanged: TGMMapCoordinateEvent;
    FOnContextMenu: TGMMapClickEvent;
    FOnHeadingChanged: TGMMapHeadingChangedEvent;
    FOnIdle: TNotifyEvent;
    FOnMapClick: TGMMapClickEvent;
    FOnMapTypeIdChanged: TGMMapTypeIdChangedEvent;
    FOnMouseOut: TGMMapCoordinateEvent;
    FOnMouseOver: TGMMapCoordinateEvent;
    FOnMouseMove: TGMMapCoordinateEvent;
    FOnMapReady: TNotifyEvent;
    FOnProjectionChanged: TNotifyEvent;
    FOnRenderingTypeChanged: TGMMapRenderingTypeChangedEvent;
    FOnTilesLoaded: TNotifyEvent;
    FOnTiltChanged: TGMMapTiltChangedEvent;
    FOnZoomChanged: TGMMapZoomChangedEvent;
    FCircles: TGMCircles;
    FInfoWindows: TGMInfoWindows;
    FMarkers: TGMMarkers;
    FGroundOverlays: TGMGroundOverlays;
    FLayers: TGMLayers;
    FPolygons: TGMPolygons;
    FPolylines: TGMPolylines;
    FRectangles: TGMRectangles;
    FOptions: TGMMapOptions;
    FGeoCode: TGMGeoCode;
    FElevations: TGMElevations;
    FRoutes: TGMRoutes;
    FUpdatingFromJS: Boolean;
    FUpdatingOptions: Boolean;
    class var FNextGeocodeRequestId: Integer;
    class var FNextElevationRequestId: Integer;
    class var FNextRouteRequestId: Integer;
    procedure CirclesChanged(Sender: TObject);
    procedure CompleteGeocodeRequest(const AResponse: TGMGeocodeResponse);
    procedure CompleteElevationRequest(const AResponse: TGMElevationResponse);
    procedure CompleteRouteRequest(const AResponse: TGMRouteResponse);
    procedure CompleteKmlClick(const APayload: string);
    procedure InfoWindowsChanged(Sender: TObject);
    procedure HandleBridgeMessage(Sender: TObject; const AEnvelope: TGMMessageEnvelope);
    procedure EnsureInitializationOptionsUnchanged;
    function FindLinkedComponent(const AObjectId: TGMObjectId): TGMCustomMapLinkedComponent;
    function IsStateCommand(const ACommand, APrefix: string): Boolean;
    procedure GroundOverlaysChanged(Sender: TObject);
    procedure LayersChanged(Sender: TObject);
    procedure MarkersChanged(Sender: TObject);
    procedure PolygonsChanged(Sender: TObject);
    procedure PolylinesChanged(Sender: TObject);
    procedure RectanglesChanged(Sender: TObject);
    procedure OptionsChanged(Sender: TObject);
    procedure RemoveQueuedCommandsByPrefix(const APrefix: string);
    function BuildGeocodeCommand(const AMethod, ARequestId, ARequestLiteral: string): string;
    function BuildGeocodeRequestId: string;
    function BuildGeocodeAddressRequestLiteral(const AAddress: string): string;
    function BuildGeocodeRequestLiteral(const ALatLng: TGMLibLatLng): string; overload;
    function BuildGeocodePlaceIdRequestLiteral(const APlaceId: string): string;
    procedure AppendGeocodeRequestOptions(const AJsonObject: TJSONObject);
    function BuildElevationRequestId: string;
    function BuildElevationCommand(const AMethod, ARequestId, ARequestLiteral: string): string;
    function BuildElevationAlongPathRequestLiteral(const APath: TGMPolylinePath; const ASamples: Integer): string;
    function BuildElevationForLocationsRequestLiteral(const ALocations: TGMPolylinePath): string;
    function BuildRouteRequestId: string;
    function BuildRoutesCommand(const ARequestId, ARequestLiteral: string): string;
    function TryGetBoundsFromPayload(const APayload: string; out ABounds: TGMLatLngBounds): Boolean;
    function TryGetCoordinateExFromPayload(const APayload: string; out ALatLng: TGMLibLatLng;
      out APlaceId: string): Boolean;
    function TryParseRenderingType(const AValue: string;
      out ARenderingType: TGMRenderingType): Boolean;
    function TryParseMapTypeId(const AValue: string; out AMapTypeId: TGMMapTypeId): Boolean;
    function TryGetCoordinateFromPayload(const APayload: string; out ALatLng: TGMLibLatLng): Boolean;
    procedure SetAPIKey(const Value: string);
    procedure SetActive(const Value: Boolean);
    procedure SetBridge(const Value: IGMBridgeTransport);
    procedure SetCircles(const Value: TGMCircles);
    procedure SetInfoWindows(const Value: TGMInfoWindows);
    procedure SetMarkers(const Value: TGMMarkers);
    procedure SetGroundOverlays(const Value: TGMGroundOverlays);
    procedure SetLayers(const Value: TGMLayers);
    procedure SetPolygons(const Value: TGMPolygons);
    procedure SetPolylines(const Value: TGMPolylines);
    procedure SetRectangles(const Value: TGMRectangles);
    procedure SetOptions(const Value: TGMMapOptions);
  protected
    {** @abstract(Marca el bridge como listo y vacía los comandos pendientes.) }
    procedure BridgeReady; virtual;
    function CreateCircles: TGMCircles; virtual;
    function CreateInfoWindows: TGMInfoWindows; virtual;
    function CreateMarkers: TGMMarkers; virtual;
    function CreateGroundOverlays: TGMGroundOverlays; virtual;
    function CreateLayers: TGMLayers; virtual;
    function CreatePolygons: TGMPolygons; virtual;
    function CreatePolylines: TGMPolylines; virtual;
    function CreateRectangles: TGMRectangles; virtual;
    function CreateGeoCode: TGMGeoCode; virtual;
    function CreateElevations: TGMElevations; virtual;
    function CreateRoutes: TGMRoutes; virtual;
    function GetGeoCode: TGMGeoCode; virtual;
    function GetElevations: TGMElevations; virtual;
    function GetRoutes: TGMRoutes; virtual;
    function GetGroundOverlays: TGMGroundOverlays; virtual;
    function GetLayers: TGMLayers; virtual;
    {** @abstract(Limpia las instancias JavaScript antes de desactivar el mapa.) }
    procedure ClearRuntimeState; virtual;
    {** @abstract(Crea el bloque de opciones concreto usado por este mapa.) }
    function CreateMapOptions: TGMMapOptions; virtual;
    {** @abstract(Encola un comando mientras el bridge aún no está listo.) }
    procedure EnqueueCommand(const ACommand: string); virtual;
    function GetAPIUrl: string; override;
    {** @abstract(Serializa el estado actual del mapa hacia JavaScript.) }
    procedure MapStateChanged; virtual;
    {** @abstract(Recibe notificaciones de cambio desde componentes enlazados.) }
    procedure NotifyLinkedComponentChanged(AComponent: TGMCustomMapLinkedComponent); virtual;
    {** @abstract(Rutea un mensaje entrante hacia el mapa o hacia un objeto enlazado.) }
    procedure ProcessIncomingMessage(const AEnvelope: TGMMessageEnvelope); virtual;
    {** @abstract(Registra un componente enlazado para routing por `ObjectId`.) }
    procedure RegisterLinkedComponent(AComponent: TGMCustomMapLinkedComponent); virtual;
    {** @abstract(Envía un comando a JavaScript o lo encola si aún no procede.) }
    procedure SendCommand(const ACommand: string); virtual;
    {** @abstract(Sincroniza el centro lógico del mapa.) }
    procedure SyncCenter(const Value: TGMLibLatLng; AOrigin: TGMChangeOrigin); virtual;
    {** @abstract(Sincroniza el heading lógico del mapa.) }
    procedure SyncHeading(Value: Double; AOrigin: TGMChangeOrigin); virtual;
    {** @abstract(Sincroniza el tipo de mapa activo.) }
    procedure SyncMapTypeId(Value: TGMMapTypeId; AOrigin: TGMChangeOrigin); virtual;
    {** @abstract(Sincroniza el tilt lógico del mapa.) }
    procedure SyncTilt(Value: Integer; AOrigin: TGMChangeOrigin); virtual;
    {** @abstract(Sincroniza el nivel de zoom lógico.) }
    procedure SyncZoom(Value: Integer; AOrigin: TGMChangeOrigin); virtual;
    {** @abstract(Elimina un componente enlazado del registro interno del mapa.) }
    procedure UnregisterLinkedComponent(AComponent: TGMCustomMapLinkedComponent); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    {** @abstract(Activa el mapa y congela las opciones de solo inicialización.) }
    procedure Activate; virtual;
    procedure CenterMapTo(const ALatLng: TGMLibLatLng); virtual;
    {** @abstract(Desactiva el mapa y limpia el estado transitorio del bridge.) }
    procedure Deactivate; virtual;
    procedure FitBounds(ANorth, ASouth, AEast, AWest: Double); virtual;
    function GeocodeAddress(const AAddress: string; const AOnCompleted: TGMGeocodeCompletedEvent): string; virtual;
    function GeocodePlaceId(const APlaceId: string; const AOnCompleted: TGMGeocodeCompletedEvent): string; virtual;
    function ReverseGeocode(const ALatLng: TGMLibLatLng; const AOnCompleted: TGMGeocodeCompletedEvent): string; virtual;
    function ElevationAlongPath(const APath: TGMPolylinePath; const ASamples: Integer;
      const AOnCompleted: TGMElevationCompletedEvent): string; virtual;
    function ElevationForLocations(const ALocations: TGMPolylinePath;
      const AOnCompleted: TGMElevationCompletedEvent): string; virtual;
    function RoutesCompute(const ARequestLiteral: string; const AOnCompleted: TGMRouteCompletedEvent): string; virtual;

    {** @abstract(Transporte actual del bridge hacia el runtime JS.) }
    property Bridge: IGMBridgeTransport read FBridge write SetBridge;
    {** @abstract(Indica si el mapa ya recibió `map.ready` desde JavaScript.) }
    property IsReady: Boolean read FIsReady;
    {** @abstract(Indica si ya se recibió el primer `map.idle` estable del mapa.) }
    property HasMapIdle: Boolean read FMapIdleReceived;
    {** @abstract(Identificador lógico del mapa usado en `targetId`.) }
    property MapId: TGMMapId read FMapId;
  published
    property AboutGMLib;
    {** @abstract(Activa o desactiva la sesión lógica del mapa.) 
        @longcode(
          Al pasar a `True`, el mapa fija la firma de opciones de arranque
          (`ColorScheme`, `ControlSize`, `MapId`, `RenderingType`) y espera a
          que el bridge entregue `map.ready`.
        )
    }
    property Active: Boolean read FActive write SetActive default False;
    {** @abstract(API key de Google Maps usada durante el bootstrap del mapa.) }
    property APIKey: string read FAPIKey write SetAPIKey;
    property Circles: TGMCircles read FCircles write SetCircles;
    property InfoWindows: TGMInfoWindows read FInfoWindows write SetInfoWindows;
    {** @abstract(Colección de marcadores gestionada por el mapa.) }
    property Markers: TGMMarkers read FMarkers write SetMarkers;
    {** @abstract(Colección de ground overlays gestionada por el mapa.) }
    property GroundOverlays: TGMGroundOverlays read FGroundOverlays write SetGroundOverlays;
    property Layers: TGMLayers read FLayers write SetLayers;
    {** @abstract(Colección de polígonos gestionada por el mapa.) }
    property Polygons: TGMPolygons read FPolygons write SetPolygons;
    property Polylines: TGMPolylines read FPolylines write SetPolylines;
    property Rectangles: TGMRectangles read FRectangles write SetRectangles;
    {** @abstract(Bloque principal de `MapOptions` mantenido como estado canónico en Delphi.) }
    property Options: TGMMapOptions read FOptions write SetOptions;

    {** @abstract(Se dispara cuando cambian los límites visibles del viewport.) }
    property OnBoundsChanged: TGMMapBoundsEvent read FOnBoundsChanged write FOnBoundsChanged;
    {** @abstract(Se dispara cuando cambia el centro visible del mapa.) }
    property OnCenterChanged: TGMMapCoordinateEvent read FOnCenterChanged write FOnCenterChanged;
    {** @abstract(Se dispara al abrir el menú contextual del mapa con `placeId` opcional.) }
    property OnContextMenu: TGMMapClickEvent read FOnContextMenu write FOnContextMenu;
    {** @abstract(Se dispara al hacer doble click en el mapa.) }
    property OnDblClick: TGMMapCoordinateEvent read FOnDblClick write FOnDblClick;
    {** @abstract(Se dispara mientras el usuario arrastra el mapa.) }
    property OnDrag: TNotifyEvent read FOnDrag write FOnDrag;
    {** @abstract(Se dispara al finalizar un arrastre del mapa.) }
    property OnDragEnd: TNotifyEvent read FOnDragEnd write FOnDragEnd;
    {** @abstract(Se dispara al iniciar un arrastre del mapa.) }
    property OnDragStart: TNotifyEvent read FOnDragStart write FOnDragStart;
    {** @abstract(Se dispara cuando la API JS informa de un nuevo `heading`.) }
    property OnHeadingChanged: TGMMapHeadingChangedEvent read FOnHeadingChanged write FOnHeadingChanged;
    {** @abstract(Se dispara cuando el mapa entra en estado `idle`.) }
    property OnIdle: TNotifyEvent read FOnIdle write FOnIdle;
    {** @abstract(Se dispara al hacer click en el mapa con `placeId` opcional.) 
        @longcode(
          `APlaceId` llega vacío cuando Google Maps no adjunta información de
          POI al evento.
        )
    }
    property OnMapClick: TGMMapClickEvent read FOnMapClick write FOnMapClick;
    {** @abstract(Se dispara cuando cambia el `MapTypeId` activo.) }
    property OnMapTypeIdChanged: TGMMapTypeIdChangedEvent read FOnMapTypeIdChanged write FOnMapTypeIdChanged;
    {** @abstract(Se dispara cuando el runtime JS confirma que el mapa está listo.) }
    property OnMapReady: TNotifyEvent read FOnMapReady write FOnMapReady;
    {** @abstract(Se dispara cuando el cursor entra sobre una geometría interactiva del mapa.) }
    property OnMouseOut: TGMMapCoordinateEvent read FOnMouseOut write FOnMouseOut;
    {** @abstract(Se dispara cuando el cursor sale de una geometría interactiva del mapa.) }
    property OnMouseOver: TGMMapCoordinateEvent read FOnMouseOver write FOnMouseOver;
    {** @abstract(Se dispara al mover el cursor sobre el mapa.) }
    property OnMouseMove: TGMMapCoordinateEvent read FOnMouseMove write FOnMouseMove;
    {** @abstract(Se dispara cuando la proyección del mapa pasa a estar disponible o cambia.) }
    property OnProjectionChanged: TNotifyEvent read FOnProjectionChanged write FOnProjectionChanged;
    {** @abstract(Se dispara cuando la API JS informa de un nuevo `RenderingType`.) }
    property OnRenderingTypeChanged: TGMMapRenderingTypeChangedEvent read FOnRenderingTypeChanged write FOnRenderingTypeChanged;
    {** @abstract(Se dispara cuando Google Maps termina de cargar teselas visibles.) }
    property OnTilesLoaded: TNotifyEvent read FOnTilesLoaded write FOnTilesLoaded;
    {** @abstract(Se dispara cuando la API JS informa de un nuevo `tilt`.) }
    property OnTiltChanged: TGMMapTiltChangedEvent read FOnTiltChanged write FOnTiltChanged;
    {** @abstract(Se dispara cuando cambia el nivel de zoom activo.) }
    property OnZoomChanged: TGMMapZoomChangedEvent read FOnZoomChanged write FOnZoomChanged;
    {** @abstract(Servicio de geocodificación asociado al mapa.) }
    property GeoCode: TGMGeoCode read GetGeoCode;
    {** @abstract(Servicio de elevación asociado al mapa.) }
    property Elevations: TGMElevations read GetElevations;
    {** @abstract(Servicio de rutas asociado al mapa.) }
    property Routes: TGMRoutes read GetRoutes;
  end;

implementation

{ TGMCustomMapLinkedComponent }

function TGMCustomMapLinkedComponent.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('obj_%d', [FNextObjectId]));
end;

constructor TGMCustomMapLinkedComponent.Create(AOwner: TComponent);
begin
  inherited;
  FObjectId := BuildObjectId;
end;

destructor TGMCustomMapLinkedComponent.Destroy;
begin
  Map := nil;
  inherited;
end;

function TGMCustomMapLinkedComponent.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

procedure TGMCustomMapLinkedComponent.MapChanged;
begin
end;

procedure TGMCustomMapLinkedComponent.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FMap) then
    FMap := nil;
end;

procedure TGMCustomMapLinkedComponent.ProcessMapMessage(
  const AEnvelope: TGMMessageEnvelope);
begin
end;

procedure TGMCustomMapLinkedComponent.SendCommand(const ACommand: string);
begin
  if Assigned(FMap) then
    FMap.SendCommand(ACommand);
end;

procedure TGMCustomMapLinkedComponent.SetMap(const Value: TGMCustomMap);
begin
  if FMap = Value then
    Exit;

  if Assigned(FMap) then
  begin
    FMap.RemoveFreeNotification(Self);
    FMap.UnregisterLinkedComponent(Self);
  end;

  FMap := Value;

  if Assigned(FMap) then
  begin
    FMap.FreeNotification(Self);
    FMap.RegisterLinkedComponent(Self);
  end;

  MapChanged;
end;

procedure TGMCustomMapLinkedComponent.StateChanged;
begin
  if Assigned(FMap) then
    FMap.NotifyLinkedComponentChanged(Self);
end;

procedure TGMCustomMapLinkedComponent.ApplyStateToMap;
begin
end;

{ TGMCustomMap }

procedure TGMCustomMap.Activate;
begin
  if FActive then
    Exit;

  if FOptions.MapId <> '' then
    FMapId := FOptions.MapId
  else
    FMapId := TGMMapId('map_1');

  FInitializationOptionsSignature := FOptions.BuildInitializationOptionsLiteral;
  FMapIdleReceived := False;
  FActive := True;
end;

procedure TGMCustomMap.BridgeReady;
var
  Command: string;
begin
  FIsReady := True;

  if Assigned(FOnMapReady) then
    FOnMapReady(Self);

  for Command in FCommandQueue do
    SendCommand(Command);

  FCommandQueue.Clear;
end;

procedure TGMCustomMap.CompleteGeocodeRequest(const AResponse: TGMGeocodeResponse);
var
  i: Integer;
  Pending: TGMGeocodePendingRequest;
begin
  for i := FPendingGeocodeRequests.Count - 1 downto 0 do
  begin
    Pending := FPendingGeocodeRequests[i];
    if not SameText(Pending.RequestId, AResponse.RequestId) then
      Continue;

    FPendingGeocodeRequests.Delete(i);
    if Assigned(Pending.OnCompleted) then
      Pending.OnCompleted(Self, AResponse);
    Exit;
  end;
end;

procedure TGMCustomMap.CompleteElevationRequest(const AResponse: TGMElevationResponse);
var
  i: Integer;
  Pending: TGMElevationPendingRequest;
begin
  for i := FPendingElevationRequests.Count - 1 downto 0 do
  begin
    Pending := FPendingElevationRequests[i];
    if not SameText(Pending.RequestId, AResponse.RequestId) then
      Continue;

    FPendingElevationRequests.Delete(i);
    if Assigned(Pending.OnCompleted) then
      Pending.OnCompleted(Self, AResponse);
    Exit;
  end;
end;

procedure TGMCustomMap.CompleteRouteRequest(const AResponse: TGMRouteResponse);
var
  i: Integer;
  Pending: TGMRoutePendingRequest;
begin
  for i := FPendingRouteRequests.Count - 1 downto 0 do
  begin
    Pending := FPendingRouteRequests[i];
    if not SameText(Pending.RequestId, AResponse.RequestId) then
      Continue;

    FPendingRouteRequests.Delete(i);
    if Assigned(Pending.OnCompleted) then
      Pending.OnCompleted(Self, AResponse);
    Exit;
  end;
end;

procedure TGMCustomMap.CompleteKmlClick(const APayload: string);
var
  ClickLatLng: TGMLibLatLng;
begin
  if not Assigned(FLayers) then
    Exit;

  { KML clicks only make sense while the layer is visible; hidden layers do
    not forward interaction back to Delphi. }
  if not FLayers.Kml.Visible then
    Exit;

  ClickLatLng := nil;
  if TryGetCoordinateFromPayload(APayload, ClickLatLng) then
  begin
    try
      if Assigned(FLayers.Kml.OnClick) then
        FLayers.Kml.OnClick(FLayers.Kml, ClickLatLng);
    finally
      ClickLatLng.Free;
    end;
  end;
end;

function TGMCustomMap.BuildGeocodeCommand(const AMethod, ARequestId,
  ARequestLiteral: string): string;
begin
  Result := Format('gmlib.geocode.%s(%s, %s, %s);', [
    AMethod,
    QuotedStr(string(MapId)),
    QuotedStr(ARequestId),
    ARequestLiteral
  ]);
end;

function TGMCustomMap.BuildGeocodeRequestId: string;
begin
  Inc(FNextGeocodeRequestId);
  Result := Format('geocode_%d', [FNextGeocodeRequestId]);
end;

function TGMCustomMap.BuildGeocodeAddressRequestLiteral(const AAddress: string): string;
var
  JsonObject: TJSONObject;
begin
  JsonObject := TJSONObject.Create;
  try
{$IFDEF FPC}
    JsonObject.Add('address', AAddress);
{$ELSE}
    JsonObject.AddPair('address', AAddress);
{$ENDIF}
    AppendGeocodeRequestOptions(JsonObject);
{$IFDEF FPC}
    Result := JsonObject.AsJSON;
{$ELSE}
    Result := JsonObject.ToJSON;
{$ENDIF}
  finally
    JsonObject.Free;
  end;
end;

function TGMCustomMap.BuildGeocodeRequestLiteral(const ALatLng: TGMLibLatLng): string;
var
  JsonObject: TJSONObject;
  LocationObject: TJSONObject;
begin
  if not Assigned(ALatLng) then
    Exit('{}');

  JsonObject := TJSONObject.Create;
  try
    LocationObject := TJSONObject.Create;
{$IFDEF FPC}
    LocationObject.Add('lat', GetJSON(FloatToStr(ALatLng.Lat, GMLibInvariantFormatSettings)));
    LocationObject.Add('lng', GetJSON(FloatToStr(ALatLng.Lng, GMLibInvariantFormatSettings)));
    JsonObject.Add('location', LocationObject);
    AppendGeocodeRequestOptions(JsonObject);
    Result := JsonObject.AsJSON;
{$ELSE}
    LocationObject.AddPair('lat', TJSONNumber.Create(ALatLng.Lat));
    LocationObject.AddPair('lng', TJSONNumber.Create(ALatLng.Lng));
    JsonObject.AddPair('location', LocationObject);
    AppendGeocodeRequestOptions(JsonObject);
    Result := JsonObject.ToJSON;
{$ENDIF}
  finally
    JsonObject.Free;
  end;
end;

function TGMCustomMap.BuildGeocodePlaceIdRequestLiteral(const APlaceId: string): string;
var
  JsonObject: TJSONObject;
begin
  JsonObject := TJSONObject.Create;
  try
{$IFDEF FPC}
    JsonObject.Add('placeId', APlaceId);
    AppendGeocodeRequestOptions(JsonObject);
    Result := JsonObject.AsJSON;
{$ELSE}
    JsonObject.AddPair('placeId', APlaceId);
    AppendGeocodeRequestOptions(JsonObject);
    Result := JsonObject.ToJSON;
{$ENDIF}
  finally
    JsonObject.Free;
  end;
end;

function TGMCustomMap.BuildElevationAlongPathRequestLiteral(const APath: TGMPolylinePath;
  const ASamples: Integer): string;
begin
  if not Assigned(APath) then
    Exit('{ path: [], samples: 2 }');

  Result := Format('{ path: %s, samples: %d }', [
    APath.ToJavaScriptLiteral,
    EnsureRange(ASamples, 2, 512)
  ]);
end;

function TGMCustomMap.BuildElevationCommand(const AMethod, ARequestId,
  ARequestLiteral: string): string;
begin
  Result := Format('gmlib.elevation.%s(%s, %s, %s);', [
    AMethod,
    QuotedStr(string(MapId)),
    QuotedStr(ARequestId),
    ARequestLiteral
  ]);
end;

function TGMCustomMap.BuildElevationForLocationsRequestLiteral(
  const ALocations: TGMPolylinePath): string;
begin
  if not Assigned(ALocations) then
    Exit('{ locations: [] }');

  Result := Format('{ locations: %s }', [ALocations.ToJavaScriptLiteral]);
end;

function TGMCustomMap.BuildElevationRequestId: string;
begin
  Inc(FNextElevationRequestId);
  Result := Format('elevation_%d', [FNextElevationRequestId]);
end;

function TGMCustomMap.BuildRouteRequestId: string;
begin
  Inc(FNextRouteRequestId);
  Result := Format('route_%d', [FNextRouteRequestId]);
end;

function TGMCustomMap.BuildRoutesCommand(const ARequestId, ARequestLiteral: string): string;
begin
  Result := Format('gmlib.routes.compute(%s, %s, %s);', [
    QuotedStr(string(MapId)),
    QuotedStr(ARequestId),
    ARequestLiteral
  ]);
end;

procedure TGMCustomMap.AppendGeocodeRequestOptions(const AJsonObject: TJSONObject);
var
  BoundsObject: TJSONObject;
begin
  if not Assigned(AJsonObject) or not Assigned(FGeoCode) then
    Exit;

  if FGeoCode.Bounds.IsComplete then
  begin
    BoundsObject := TJSONObject.Create;
{$IFDEF FPC}
    BoundsObject.Add('north', GetJSON(FloatToStr(FGeoCode.Bounds.North, GMLibInvariantFormatSettings)));
    BoundsObject.Add('south', GetJSON(FloatToStr(FGeoCode.Bounds.South, GMLibInvariantFormatSettings)));
    BoundsObject.Add('east', GetJSON(FloatToStr(FGeoCode.Bounds.East, GMLibInvariantFormatSettings)));
    BoundsObject.Add('west', GetJSON(FloatToStr(FGeoCode.Bounds.West, GMLibInvariantFormatSettings)));
    AJsonObject.Add('bounds', BoundsObject);
{$ELSE}
    BoundsObject.AddPair('north', TJSONNumber.Create(FGeoCode.Bounds.North));
    BoundsObject.AddPair('south', TJSONNumber.Create(FGeoCode.Bounds.South));
    BoundsObject.AddPair('east', TJSONNumber.Create(FGeoCode.Bounds.East));
    BoundsObject.AddPair('west', TJSONNumber.Create(FGeoCode.Bounds.West));
    AJsonObject.AddPair('bounds', BoundsObject);
{$ENDIF}
  end;

  if FGeoCode.Region <> '' then
{$IFDEF FPC}
    AJsonObject.Add('region', FGeoCode.Region)
{$ELSE}
    AJsonObject.AddPair('region', FGeoCode.Region)
{$ENDIF}
  ;

  if FGeoCode.Language <> '' then
{$IFDEF FPC}
    AJsonObject.Add('language', FGeoCode.Language)
{$ELSE}
    AJsonObject.AddPair('language', FGeoCode.Language)
{$ENDIF}
  ;
end;

procedure TGMCustomMap.CenterMapTo(const ALatLng: TGMLibLatLng);
begin
  if not Assigned(ALatLng) then
    Exit;

  FOptions.Center.Assign(ALatLng);
  SendCommand(Format('gmlib.map.setCenter(%s, %s);', [
    FloatToStr(ALatLng.Lat, GMLibInvariantFormatSettings),
    FloatToStr(ALatLng.Lng, GMLibInvariantFormatSettings)
  ]));
end;

constructor TGMCustomMap.Create(AOwner: TComponent);
begin
  inherited;

  FActive := False;
{$IFDEF FPC}
  FCommandQueue := specialize TList<string>.Create;
  FLinkedComponents := specialize TObjectDictionary<TGMObjectId, TGMCustomMapLinkedComponent>.Create([]);
  FPendingGeocodeRequests := specialize TObjectList<TGMGeocodePendingRequest>.Create(True);
  FPendingElevationRequests := specialize TObjectList<TGMElevationPendingRequest>.Create(True);
  FPendingRouteRequests := specialize TObjectList<TGMRoutePendingRequest>.Create(True);
{$ELSE}
  FCommandQueue := TList<string>.Create;
  FLinkedComponents := TObjectDictionary<TGMObjectId, TGMCustomMapLinkedComponent>.Create([]);
  FPendingGeocodeRequests := TObjectList<TGMGeocodePendingRequest>.Create(True);
  FPendingElevationRequests := TObjectList<TGMElevationPendingRequest>.Create(True);
  FPendingRouteRequests := TObjectList<TGMRoutePendingRequest>.Create(True);
{$ENDIF}
  FCircles := CreateCircles;
  FInfoWindows := CreateInfoWindows;
  FMarkers := CreateMarkers;
  FGroundOverlays := CreateGroundOverlays;
  FLayers := CreateLayers;
  FPolygons := CreatePolygons;
  FPolylines := CreatePolylines;
  FRectangles := CreateRectangles;
  FGeoCode := CreateGeoCode;
  FGeoCode.Map := Self;
  FElevations := CreateElevations;
  FElevations.Map := Self;
  FRoutes := CreateRoutes;
  FRoutes.Map := Self;
  FOptions := CreateMapOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FCircles.OnChange := @CirclesChanged;
  FInfoWindows.OnChange := @InfoWindowsChanged;
  FMarkers.OnChange := @MarkersChanged;
  FGroundOverlays.OnChange := @GroundOverlaysChanged;
  FLayers.OnChange := @LayersChanged;
  FPolygons.OnChange := @PolygonsChanged;
  FPolylines.OnChange := @PolylinesChanged;
  FRectangles.OnChange := @RectanglesChanged;
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FCircles.OnChange := CirclesChanged;
  FInfoWindows.OnChange := InfoWindowsChanged;
  FMarkers.OnChange := MarkersChanged;
  FGroundOverlays.OnChange := GroundOverlaysChanged;
  FLayers.OnChange := LayersChanged;
  FPolygons.OnChange := PolygonsChanged;
  FPolylines.OnChange := PolylinesChanged;
  FRectangles.OnChange := RectanglesChanged;
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
  FMapId := TGMMapId('map_1');
end;

function TGMCustomMap.CreateInfoWindows: TGMInfoWindows;
begin
  Result := TGMInfoWindows.Create(Self);
end;

function TGMCustomMap.CreateMarkers: TGMMarkers;
begin
  Result := TGMMarkers.Create(Self);
end;

function TGMCustomMap.CreateGroundOverlays: TGMGroundOverlays;
begin
  Result := TGMGroundOverlays.Create(Self);
end;

function TGMCustomMap.CreateLayers: TGMLayers;
begin
  Result := TGMLayers.Create;
  Result.Owner := Self;
end;

function TGMCustomMap.CreatePolygons: TGMPolygons;
begin
  Result := TGMPolygons.Create(Self);
end;

function TGMCustomMap.CreatePolylines: TGMPolylines;
begin
  Result := TGMPolylines.Create(Self);
end;

function TGMCustomMap.CreateRectangles: TGMRectangles;
begin
  Result := TGMRectangles.Create(Self);
end;

function TGMCustomMap.CreateGeoCode: TGMGeoCode;
begin
  Result := TGMGeoCode.Create(Self);
end;

function TGMCustomMap.CreateElevations: TGMElevations;
begin
  Result := TGMElevations.Create(Self);
end;

function TGMCustomMap.CreateRoutes: TGMRoutes;
begin
  Result := TGMRoutes.Create(Self);
end;

function TGMCustomMap.GetGeoCode: TGMGeoCode;
begin
  if not Assigned(FGeoCode) then
  begin
    FGeoCode := CreateGeoCode;
    FGeoCode.Map := Self;
  end;

  Result := FGeoCode;
end;

function TGMCustomMap.GetGroundOverlays: TGMGroundOverlays;
begin
  if not Assigned(FGroundOverlays) then
    FGroundOverlays := CreateGroundOverlays;

  Result := FGroundOverlays;
end;

function TGMCustomMap.GetLayers: TGMLayers;
begin
  if not Assigned(FLayers) then
    FLayers := CreateLayers;

  Result := FLayers;
end;

function TGMCustomMap.GetElevations: TGMElevations;
begin
  if not Assigned(FElevations) then
  begin
    FElevations := CreateElevations;
    FElevations.Map := Self;
  end;

  Result := FElevations;
end;

function TGMCustomMap.GetRoutes: TGMRoutes;
begin
  if not Assigned(FRoutes) then
  begin
    FRoutes := CreateRoutes;
    FRoutes.Map := Self;
  end;

  Result := FRoutes;
end;

function TGMCustomMap.CreateCircles: TGMCircles;
begin
  Result := TGMCircles.Create(Self);
end;

function TGMCustomMap.CreateMapOptions: TGMMapOptions;
begin
  Result := TGMMapOptions.Create;
end;

procedure TGMCustomMap.ClearRuntimeState;
begin
  if not IsReady then
    Exit;

  if Assigned(FLayers) then
    SendCommand('gmlib.layers.remove();');
end;

procedure TGMCustomMap.Deactivate;
begin
  if not FActive then
    Exit;

  ClearRuntimeState;
  FActive := False;
  FInitializationOptionsSignature := '';
  FIsReady := False;
end;

procedure TGMCustomMap.FitBounds(ANorth, ASouth, AEast, AWest: Double);
begin
  SendCommand(Format('gmlib.map.fitBounds(%s, %s, %s, %s);', [
    FloatToStr(ANorth, GMLibInvariantFormatSettings),
    FloatToStr(ASouth, GMLibInvariantFormatSettings),
    FloatToStr(AEast, GMLibInvariantFormatSettings),
    FloatToStr(AWest, GMLibInvariantFormatSettings)
  ]));
end;

function TGMCustomMap.GeocodeAddress(const AAddress: string;
  const AOnCompleted: TGMGeocodeCompletedEvent): string;
var
  Pending: TGMGeocodePendingRequest;
begin
  Result := BuildGeocodeRequestId;
  Pending := TGMGeocodePendingRequest.Create;
  Pending.RequestId := Result;
  Pending.OnCompleted := AOnCompleted;
  FPendingGeocodeRequests.Add(Pending);
  SendCommand(BuildGeocodeCommand('geocodeAddress', Result, BuildGeocodeAddressRequestLiteral(AAddress)));
end;

function TGMCustomMap.GeocodePlaceId(const APlaceId: string;
  const AOnCompleted: TGMGeocodeCompletedEvent): string;
var
  Pending: TGMGeocodePendingRequest;
begin
  Result := BuildGeocodeRequestId;
  Pending := TGMGeocodePendingRequest.Create;
  Pending.RequestId := Result;
  Pending.OnCompleted := AOnCompleted;
  FPendingGeocodeRequests.Add(Pending);
  SendCommand(BuildGeocodeCommand('geocodePlaceId', Result, BuildGeocodePlaceIdRequestLiteral(APlaceId)));
end;

function TGMCustomMap.ReverseGeocode(const ALatLng: TGMLibLatLng;
  const AOnCompleted: TGMGeocodeCompletedEvent): string;
var
  Pending: TGMGeocodePendingRequest;
begin
  Result := BuildGeocodeRequestId;
  Pending := TGMGeocodePendingRequest.Create;
  Pending.RequestId := Result;
  Pending.OnCompleted := AOnCompleted;
  FPendingGeocodeRequests.Add(Pending);
  SendCommand(BuildGeocodeCommand('reverseGeocode', Result, BuildGeocodeRequestLiteral(ALatLng)));
end;

function TGMCustomMap.ElevationAlongPath(const APath: TGMPolylinePath;
  const ASamples: Integer; const AOnCompleted: TGMElevationCompletedEvent): string;
var
  Pending: TGMElevationPendingRequest;
begin
  Result := BuildElevationRequestId;
  Pending := TGMElevationPendingRequest.Create;
  Pending.RequestId := Result;
  Pending.OnCompleted := AOnCompleted;
  FPendingElevationRequests.Add(Pending);
  SendCommand(BuildElevationCommand('getElevationsAlongPath', Result,
    BuildElevationAlongPathRequestLiteral(APath, ASamples)));
end;

function TGMCustomMap.ElevationForLocations(const ALocations: TGMPolylinePath;
  const AOnCompleted: TGMElevationCompletedEvent): string;
var
  Pending: TGMElevationPendingRequest;
begin
  Result := BuildElevationRequestId;
  Pending := TGMElevationPendingRequest.Create;
  Pending.RequestId := Result;
  Pending.OnCompleted := AOnCompleted;
  FPendingElevationRequests.Add(Pending);
  SendCommand(BuildElevationCommand('getElevationsForLocations', Result,
    BuildElevationForLocationsRequestLiteral(ALocations)));
end;

function TGMCustomMap.RoutesCompute(const ARequestLiteral: string;
  const AOnCompleted: TGMRouteCompletedEvent): string;
var
  Pending: TGMRoutePendingRequest;
begin
  Result := BuildRouteRequestId;
  Pending := TGMRoutePendingRequest.Create;
  Pending.RequestId := Result;
  Pending.OnCompleted := AOnCompleted;
  FPendingRouteRequests.Add(Pending);
  SendCommand(BuildRoutesCommand(Result, ARequestLiteral));
end;

destructor TGMCustomMap.Destroy;
begin
  FIsReady := False;
  FBridge := nil;

  if Assigned(FInfoWindows) then
    FInfoWindows.OnChange := nil;

  if Assigned(FMarkers) then
    FMarkers.OnChange := nil;

  if Assigned(FGroundOverlays) then
    FGroundOverlays.OnChange := nil;

  if Assigned(FLayers) then
    FLayers.OnChange := nil;

  if Assigned(FPolygons) then
    FPolygons.OnChange := nil;

  if Assigned(FPolylines) then
    FPolylines.OnChange := nil;

  if Assigned(FRectangles) then
    FRectangles.OnChange := nil;

  if Assigned(FCircles) then
    FCircles.OnChange := nil;

  if Assigned(FOptions) then
    FOptions.OnChange := nil;

  if Assigned(FGeoCode) then
    FGeoCode.Map := nil;

  if Assigned(FElevations) then
    FElevations.Map := nil;

  if Assigned(FRoutes) then
    FRoutes.Map := nil;

  FLinkedComponents.Free;
  FPendingGeocodeRequests.Free;
  FPendingElevationRequests.Free;
  FPendingRouteRequests.Free;
  FInfoWindows.Free;
  FMarkers.Free;
  FGroundOverlays.Free;
  FLayers.Free;
  FPolygons.Free;
  FPolylines.Free;
  FRectangles.Free;
  FCircles.Free;
  FOptions.Free;
  FCommandQueue.Free;

  inherited;
end;

function TGMCustomMap.FindLinkedComponent(
  const AObjectId: TGMObjectId): TGMCustomMapLinkedComponent;
begin
  if not FLinkedComponents.TryGetValue(AObjectId, Result) then
    Result := nil;
end;

procedure TGMCustomMap.EnqueueCommand(const ACommand: string);
begin
  if ACommand = '' then
    Exit;

  if (FCommandQueue.Count > 0) and SameText(FCommandQueue.Last, ACommand) then
    Exit;

  if IsStateCommand(ACommand, 'gmlib.map.setCenter(') then
    RemoveQueuedCommandsByPrefix('gmlib.map.setCenter(')
  else if IsStateCommand(ACommand, 'gmlib.map.setZoom(') then
    RemoveQueuedCommandsByPrefix('gmlib.map.setZoom(')
  else if IsStateCommand(ACommand, 'gmlib.map.setMapTypeId(') then
    RemoveQueuedCommandsByPrefix('gmlib.map.setMapTypeId(')
  else if IsStateCommand(ACommand, 'gmlib.map.setOptions(') then
    RemoveQueuedCommandsByPrefix('gmlib.map.setOptions(');

  FCommandQueue.Add(ACommand);
end;

procedure TGMCustomMap.EnsureInitializationOptionsUnchanged;
begin
  if not FActive then
    Exit;

  if FInitializationOptionsSignature = FOptions.BuildInitializationOptionsLiteral then
    Exit;

  raise EInvalidOperation.Create(
    'ColorScheme, ControlSize, MapId and RenderingType can only be changed before activating the map.'
  );
end;

function TGMCustomMap.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#Map';
end;

function TGMCustomMap.IsStateCommand(const ACommand, APrefix: string): Boolean;
begin
  Result := SameText(Copy(ACommand, 1, Length(APrefix)), APrefix);
end;

procedure TGMCustomMap.HandleBridgeMessage(Sender: TObject;
  const AEnvelope: TGMMessageEnvelope);
begin
  ProcessIncomingMessage(AEnvelope);
end;

procedure TGMCustomMap.MapStateChanged;
begin
  if not FIsReady then
    Exit;

  if FUpdatingFromJS or FUpdatingOptions then
    Exit;

  SendCommand(Format('gmlib.map.setOptions(%s);', [FOptions.ToJavaScriptLiteral]));
end;

procedure TGMCustomMap.InfoWindowsChanged(Sender: TObject);
var
  i: Integer;
begin
  if not IsReady then
    Exit;

  for i := 0 to FInfoWindows.PendingRemovals.Count - 1 do
    SendCommand(Format('gmlib.infoWindow.remove(%s);', [QuotedStr(string(FInfoWindows.PendingRemovals[i]))]));

  FInfoWindows.ClearPendingRemovals;

  for i := 0 to FInfoWindows.Count - 1 do
    SendCommand(FInfoWindows[i].BuildApplyCommand);
end;

procedure TGMCustomMap.GroundOverlaysChanged(Sender: TObject);
var
  i: Integer;
begin
  if not IsReady then
    Exit;

  for i := 0 to FGroundOverlays.PendingRemovals.Count - 1 do
    SendCommand(Format('gmlib.groundOverlay.remove(%s);', [QuotedStr(string(FGroundOverlays.PendingRemovals[i]))]));

  FGroundOverlays.ClearPendingRemovals;

  for i := 0 to FGroundOverlays.Count - 1 do
    SendCommand(FGroundOverlays[i].BuildApplyCommand);
end;

procedure TGMCustomMap.LayersChanged(Sender: TObject);
begin
  if FUpdatingFromJS then
    Exit;

  if not IsReady then
    Exit;

  { Layer toggles are pushed as a single JS command block so the map does not
    bounce through partial states while the user edits the UI. }
  if Assigned(FLayers) then
    SendCommand(FLayers.BuildApplyCommand);
end;

procedure TGMCustomMap.MarkersChanged(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FMarkers.PendingRemovals.Count - 1 do
    FInfoWindows.DetachAnchorFromMarker(FMarkers.PendingRemovals[i]);

  if not IsReady or not FMapIdleReceived then
    Exit;

  for i := 0 to FMarkers.PendingRemovals.Count - 1 do
    SendCommand(Format('gmlib.marker.remove(%s);', [QuotedStr(string(FMarkers.PendingRemovals[i]))]));

  FMarkers.ClearPendingRemovals;

  for i := 0 to FMarkers.Count - 1 do
    if FMarkers[i].NeedsSync then
      SendCommand(FMarkers[i].BuildApplyCommand);
end;

procedure TGMCustomMap.PolygonsChanged(Sender: TObject);
var
  i: Integer;
begin
  if not IsReady then
    Exit;

  for i := 0 to FPolygons.PendingRemovals.Count - 1 do
    SendCommand(Format('gmlib.polygon.remove(%s);', [QuotedStr(string(FPolygons.PendingRemovals[i]))]));

  FPolygons.ClearPendingRemovals;

  for i := 0 to FPolygons.Count - 1 do
    SendCommand(FPolygons[i].BuildApplyCommand);
end;

procedure TGMCustomMap.PolylinesChanged(Sender: TObject);
var
  i: Integer;
begin
  if not IsReady then
    Exit;

  for i := 0 to FPolylines.PendingRemovals.Count - 1 do
    SendCommand(Format('gmlib.polyline.remove(%s);', [QuotedStr(string(FPolylines.PendingRemovals[i]))]));

  FPolylines.ClearPendingRemovals;

  for i := 0 to FPolylines.Count - 1 do
    SendCommand(FPolylines[i].BuildApplyCommand);
end;

procedure TGMCustomMap.NotifyLinkedComponentChanged(
  AComponent: TGMCustomMapLinkedComponent);
begin
  if not Assigned(AComponent) then
    Exit;

  AComponent.ApplyStateToMap;
end;

procedure TGMCustomMap.OptionsChanged(Sender: TObject);
begin
  EnsureInitializationOptionsUnchanged;
  MapStateChanged;
end;

procedure TGMCustomMap.RemoveQueuedCommandsByPrefix(const APrefix: string);
var
  i: Integer;
begin
  for i := FCommandQueue.Count - 1 downto 0 do
  begin
    if SameText(Copy(FCommandQueue[i], 1, Length(APrefix)), APrefix) then
      FCommandQueue.Delete(i);
  end;
end;

procedure TGMCustomMap.ProcessIncomingMessage(const AEnvelope: TGMMessageEnvelope);
var
  Bounds: TGMLatLngBounds;
  CircleItem: TGMCircleItem;
  ClickLatLng: TGMLibLatLng;
  GroundOverlayItem: TGMGroundOverlayItem;
  LinkedComponent: TGMCustomMapLinkedComponent;
  MarkerItem: TGMMarkerItem;
  PolygonItem: TGMPolygonItem;
  PolylineItem: TGMPolylineItem;
  RectangleItem: TGMRectangleItem;
  InfoWindowItem: TGMInfoWindowItem;
  PlaceId: string;
  NewHeading: Double;
  NewMapTypeId: TGMMapTypeId;
  NewRenderingType: TGMRenderingType;
  NewTilt: Integer;
  NewZoom: Integer;
begin
  if SameText(AEnvelope.MessageType, 'map.ready') then
  begin
    BridgeReady;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'geocode.result') or
     SameText(AEnvelope.MessageType, 'geocode.error') then
  begin
    { Response payloads are normalized in the service units so the map only
      has to route the message to the matching async request. }
{$IFDEF FPC}
    CompleteGeocodeRequest(GMLibGeocodeResponseFromJson(AEnvelope.Payload));
{$ELSE}
    CompleteGeocodeRequest(TGMGeocodeResponse.FromJson(AEnvelope.Payload));
{$ENDIF}
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'elevation.result') or
     SameText(AEnvelope.MessageType, 'elevation.error') then
  begin
{$IFDEF FPC}
    CompleteElevationRequest(GMLibElevationResponseFromJson(AEnvelope.Payload));
{$ELSE}
    CompleteElevationRequest(TGMElevationResponse.FromJson(AEnvelope.Payload));
{$ENDIF}
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'routes.result') or
     SameText(AEnvelope.MessageType, 'routes.error') then
  begin
    { Routes can fan out into multiple concurrent queries, so the envelope is
      matched later by request id in TGMRoutes.HandleCompleted. }
{$IFDEF FPC}
    CompleteRouteRequest(GMLibRouteResponseFromJson(AEnvelope.Payload));
{$ELSE}
    CompleteRouteRequest(TGMRouteResponse.FromJson(AEnvelope.Payload));
{$ENDIF}
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'kml.click') then
  begin
    CompleteKmlClick(AEnvelope.Payload);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'kml.status_changed') then
  begin
    if Assigned(FLayers) then
      FLayers.Kml.SetStatus(AEnvelope.PayloadAsString);
    Exit;
  end;

  if (AEnvelope.TargetId <> '') and
     (not SameText(string(AEnvelope.TargetId), string(MapId))) then
  begin
    MarkerItem := FMarkers.FindByObjectId(AEnvelope.TargetId);
    if Assigned(MarkerItem) then
    begin
      MarkerItem.ProcessMapMessage(AEnvelope);
      Exit;
    end;

    PolygonItem := FPolygons.FindByObjectId(AEnvelope.TargetId);
    if Assigned(PolygonItem) then
    begin
      PolygonItem.ProcessMapMessage(AEnvelope);
      Exit;
    end;

    InfoWindowItem := FInfoWindows.FindByObjectId(AEnvelope.TargetId);
    if Assigned(InfoWindowItem) then
    begin
      InfoWindowItem.ProcessMapMessage(AEnvelope);
      Exit;
    end;

    PolylineItem := FPolylines.FindByObjectId(AEnvelope.TargetId);
    if Assigned(PolylineItem) then
    begin
      PolylineItem.ProcessMapMessage(AEnvelope);
      Exit;
    end;

    RectangleItem := FRectangles.FindByObjectId(AEnvelope.TargetId);
    if Assigned(RectangleItem) then
    begin
      RectangleItem.ProcessMapMessage(AEnvelope);
      Exit;
    end;

    CircleItem := FCircles.FindByObjectId(AEnvelope.TargetId);
    if Assigned(CircleItem) then
    begin
      CircleItem.ProcessMapMessage(AEnvelope);
      Exit;
    end;

    GroundOverlayItem := FGroundOverlays.FindByObjectId(AEnvelope.TargetId);
    if Assigned(GroundOverlayItem) then
    begin
      GroundOverlayItem.ProcessMapMessage(AEnvelope);
      Exit;
    end;

    LinkedComponent := FindLinkedComponent(AEnvelope.TargetId);
    if Assigned(LinkedComponent) then
      LinkedComponent.ProcessMapMessage(AEnvelope);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.zoom_changed') then
  begin
{$IFDEF FPC}
    NewZoom := StrToIntDef(GMLibMessageEnvelopePayloadAsString(AEnvelope), FOptions.Zoom);
{$ELSE}
    NewZoom := StrToIntDef(AEnvelope.PayloadAsString, FOptions.Zoom);
{$ENDIF}
    FUpdatingFromJS := True;
    try
      SyncZoom(NewZoom, coJavaScript);
    finally
      FUpdatingFromJS := False;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.center_changed') then
  begin
    ClickLatLng := nil;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, ClickLatLng) then
    begin
      FUpdatingFromJS := True;
      try
        SyncCenter(ClickLatLng, coJavaScript);
      finally
        FUpdatingFromJS := False;
        ClickLatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.maptypeid_changed') then
  begin
{$IFDEF FPC}
    if TryParseMapTypeId(GMLibMessageEnvelopePayloadAsString(AEnvelope), NewMapTypeId) then
{$ELSE}
    if TryParseMapTypeId(AEnvelope.PayloadAsString, NewMapTypeId) then
{$ENDIF}
    begin
      FUpdatingFromJS := True;
      try
        SyncMapTypeId(NewMapTypeId, coJavaScript);
      finally
        FUpdatingFromJS := False;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.heading_changed') then
  begin
{$IFDEF FPC}
    NewHeading := StrToFloatDef(GMLibMessageEnvelopePayloadAsString(AEnvelope), FOptions.Heading, GMLibInvariantFormatSettings);
{$ELSE}
    NewHeading := StrToFloatDef(AEnvelope.PayloadAsString, FOptions.Heading, GMLibInvariantFormatSettings);
{$ENDIF}
    FUpdatingFromJS := True;
    try
      SyncHeading(NewHeading, coJavaScript);
    finally
      FUpdatingFromJS := False;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.tilt_changed') then
  begin
{$IFDEF FPC}
    NewTilt := StrToIntDef(GMLibMessageEnvelopePayloadAsString(AEnvelope), FOptions.Tilt);
{$ELSE}
    NewTilt := StrToIntDef(AEnvelope.PayloadAsString, FOptions.Tilt);
{$ENDIF}
    FUpdatingFromJS := True;
    try
      SyncTilt(NewTilt, coJavaScript);
    finally
      FUpdatingFromJS := False;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.renderingtype_changed') then
  begin
{$IFDEF FPC}
    if TryParseRenderingType(GMLibMessageEnvelopePayloadAsString(AEnvelope), NewRenderingType) then
{$ELSE}
    if TryParseRenderingType(AEnvelope.PayloadAsString, NewRenderingType) then
{$ENDIF}
    begin
      if Assigned(FOnRenderingTypeChanged) then
        FOnRenderingTypeChanged(Self, NewRenderingType);
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.click') then
  begin
    ClickLatLng := nil;
    PlaceId := '';
    if TryGetCoordinateExFromPayload(AEnvelope.Payload, ClickLatLng, PlaceId) then
    begin
      try
        if Assigned(FOnMapClick) then
          FOnMapClick(Self, ClickLatLng, PlaceId);
      finally
        ClickLatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.contextmenu') then
  begin
    ClickLatLng := nil;
    PlaceId := '';
    if TryGetCoordinateExFromPayload(AEnvelope.Payload, ClickLatLng, PlaceId) then
    begin
      try
        if Assigned(FOnContextMenu) then
          FOnContextMenu(Self, ClickLatLng, PlaceId);
      finally
        ClickLatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.dblclick') then
  begin
    ClickLatLng := nil;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, ClickLatLng) then
    begin
      try
        if Assigned(FOnDblClick) then
          FOnDblClick(Self, ClickLatLng);
      finally
        ClickLatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.mousemove') then
  begin
    ClickLatLng := nil;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, ClickLatLng) then
    begin
      try
        if Assigned(FOnMouseMove) then
          FOnMouseMove(Self, ClickLatLng);
      finally
        ClickLatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.mouseover') then
  begin
    ClickLatLng := nil;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, ClickLatLng) then
    begin
      try
        if Assigned(FOnMouseOver) then
          FOnMouseOver(Self, ClickLatLng);
      finally
        ClickLatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.mouseout') then
  begin
    ClickLatLng := nil;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, ClickLatLng) then
    begin
      try
        if Assigned(FOnMouseOut) then
          FOnMouseOut(Self, ClickLatLng);
      finally
        ClickLatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.bounds_changed') then
  begin
    Bounds := nil;
    if TryGetBoundsFromPayload(AEnvelope.Payload, Bounds) then
    begin
      try
        if Assigned(FOnBoundsChanged) then
          FOnBoundsChanged(Self, Bounds);
      finally
        Bounds.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.dragstart') then
  begin
    if Assigned(FOnDragStart) then
      FOnDragStart(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.drag') then
  begin
    if Assigned(FOnDrag) then
      FOnDrag(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.dragend') then
  begin
    if Assigned(FOnDragEnd) then
      FOnDragEnd(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.idle') then
  begin
    FMapIdleReceived := True;
    if Assigned(FOnIdle) then
      FOnIdle(Self);
    { The first idle confirms that the map finished its initial paint, so we can
      flush overlays and layer state that depend on a stable runtime. }
    MarkersChanged(Self);
    GroundOverlaysChanged(Self);
    LayersChanged(Self);
    CirclesChanged(Self);
    PolylinesChanged(Self);
    PolygonsChanged(Self);
    RectanglesChanged(Self);
    if Assigned(FElevations) then
      FElevations.FlushPendingExecute;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.tilesloaded') then
  begin
    if Assigned(FOnTilesLoaded) then
      FOnTilesLoaded(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'map.projection_changed') then
  begin
    if Assigned(FOnProjectionChanged) then
      FOnProjectionChanged(Self);
    Exit;
  end;
end;

procedure TGMCustomMap.SendCommand(const ACommand: string);
begin
  if Assigned(FBridge) and FBridge.IsReady then
    FBridge.ExecuteJavaScript(ACommand)
  else
    EnqueueCommand(ACommand);
end;

procedure TGMCustomMap.RegisterLinkedComponent(
  AComponent: TGMCustomMapLinkedComponent);
begin
  if not Assigned(AComponent) then
    Exit;

  if FLinkedComponents.ContainsKey(AComponent.ObjectId) then
    raise EInvalidOperation.CreateFmt(
      'A linked component with ObjectId "%s" is already registered in this map.',
      [string(AComponent.ObjectId)]
    );

  FLinkedComponents.Add(AComponent.ObjectId, AComponent);

  if IsReady then
    AComponent.ApplyStateToMap;
end;

procedure TGMCustomMap.SetAPIKey(const Value: string);
begin
  if FAPIKey = Value then
    Exit;

  FAPIKey := Value;
  MapStateChanged;
end;

procedure TGMCustomMap.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;

  if Value then
    Activate
  else
    Deactivate;
end;

procedure TGMCustomMap.SetBridge(const Value: IGMBridgeTransport);
begin
  if FBridge = Value then
    Exit;

  // Detach the previous bridge first so a browser replacement cannot leave a
  // stale callback pointing back into this map instance.
  if Assigned(FBridge) then
    FBridge.SetOnMessageReceived(nil);

  FBridge := Value;
  FIsReady := False;

  if Assigned(FBridge) then
{$IFDEF FPC}
    FBridge.SetOnMessageReceived(@HandleBridgeMessage);
{$ELSE}
    FBridge.SetOnMessageReceived(HandleBridgeMessage);
{$ENDIF}
end;

procedure TGMCustomMap.SetInfoWindows(const Value: TGMInfoWindows);
begin
  if not Assigned(Value) then
    Exit;

  FInfoWindows.Assign(Value);
end;

procedure TGMCustomMap.SetMarkers(const Value: TGMMarkers);
begin
  if not Assigned(Value) then
    Exit;

  FMarkers.Assign(Value);
end;

procedure TGMCustomMap.SetGroundOverlays(const Value: TGMGroundOverlays);
begin
  if not Assigned(Value) then
    Exit;

  FGroundOverlays.Assign(Value);
end;

procedure TGMCustomMap.SetLayers(const Value: TGMLayers);
begin
  if not Assigned(Value) then
    Exit;

  FLayers.Assign(Value);
end;

procedure TGMCustomMap.SetPolygons(const Value: TGMPolygons);
begin
  if not Assigned(Value) then
    Exit;

  FPolygons.Assign(Value);
end;

procedure TGMCustomMap.SetPolylines(const Value: TGMPolylines);
begin
  if not Assigned(Value) then
    Exit;

  FPolylines.Assign(Value);
end;

procedure TGMCustomMap.SetCircles(const Value: TGMCircles);
begin
  if not Assigned(Value) then
    Exit;

  FCircles.Assign(Value);
end;

procedure TGMCustomMap.SetRectangles(const Value: TGMRectangles);
begin
  if not Assigned(Value) then
    Exit;

  FRectangles.Assign(Value);
end;

procedure TGMCustomMap.RectanglesChanged(Sender: TObject);
var
  i: Integer;
begin
  if FUpdatingFromJS then
    Exit;

  if not IsReady then
    Exit;

  for i := 0 to FRectangles.PendingRemovals.Count - 1 do
    SendCommand(Format('gmlib.rectangle.remove(%s);', [QuotedStr(string(FRectangles.PendingRemovals[i]))]));

  FRectangles.ClearPendingRemovals;

  for i := 0 to FRectangles.Count - 1 do
    SendCommand(FRectangles[i].BuildApplyCommand);
end;

procedure TGMCustomMap.CirclesChanged(Sender: TObject);
var
  i: Integer;
begin
  if FUpdatingFromJS then
    Exit;

  if not IsReady or not FMapIdleReceived then
    Exit;

  for i := 0 to FCircles.PendingRemovals.Count - 1 do
    FBridge.ExecuteJavaScript(Format('gmlib.circle.remove(%s);', [QuotedStr(string(FCircles.PendingRemovals[i]))]));

  FCircles.ClearPendingRemovals;

  for i := 0 to FCircles.Count - 1 do
    FBridge.ExecuteJavaScript(FCircles[i].BuildApplyCommand);
end;

procedure TGMCustomMap.SetOptions(const Value: TGMMapOptions);
begin
  if not Assigned(Value) then
    Exit;

  FUpdatingOptions := True;
  try
    FOptions.Assign(Value);
  finally
    FUpdatingOptions := False;
  end;

  EnsureInitializationOptionsUnchanged;
  MapStateChanged;
end;

procedure TGMCustomMap.SyncCenter(const Value: TGMLibLatLng; AOrigin: TGMChangeOrigin);
begin
  if not Assigned(Value) then
    Exit;

  if FOptions.Center.Equals(Value) then
    Exit;

  FOptions.Center.Assign(Value);

  if Assigned(FOnCenterChanged) then
    FOnCenterChanged(Self, FOptions.Center);
end;

procedure TGMCustomMap.SyncHeading(Value: Double; AOrigin: TGMChangeOrigin);
begin
  if SameValue(FOptions.Heading, Value) then
    Exit;

  FOptions.Heading := Value;

  if Assigned(FOnHeadingChanged) then
    FOnHeadingChanged(Self, FOptions.Heading);
end;

procedure TGMCustomMap.SyncMapTypeId(Value: TGMMapTypeId; AOrigin: TGMChangeOrigin);
begin
  if FOptions.MapTypeId = Value then
    Exit;

  FOptions.MapTypeId := Value;

  if Assigned(FOnMapTypeIdChanged) then
    FOnMapTypeIdChanged(Self, FOptions.MapTypeId);
end;

procedure TGMCustomMap.SyncTilt(Value: Integer; AOrigin: TGMChangeOrigin);
begin
  if FOptions.Tilt = Value then
    Exit;

  FOptions.Tilt := Value;

  if Assigned(FOnTiltChanged) then
    FOnTiltChanged(Self, FOptions.Tilt);
end;

procedure TGMCustomMap.SyncZoom(Value: Integer; AOrigin: TGMChangeOrigin);
begin
  if FOptions.Zoom = Value then
    Exit;

  FOptions.Zoom := Value;

  if Assigned(FOnZoomChanged) then
    FOnZoomChanged(Self, FOptions.Zoom);
end;

function TGMCustomMap.TryParseMapTypeId(const AValue: string;
  out AMapTypeId: TGMMapTypeId): Boolean;
begin
  Result := True;

  if SameText(AValue, 'satellite') then
    AMapTypeId := mtSatellite
  else if SameText(AValue, 'hybrid') then
    AMapTypeId := mtHybrid
  else if SameText(AValue, 'terrain') then
    AMapTypeId := mtTerrain
  else if SameText(AValue, 'roadmap') then
    AMapTypeId := mtRoadmap
  else
    Result := False;
end;

function TGMCustomMap.TryParseRenderingType(const AValue: string;
  out ARenderingType: TGMRenderingType): Boolean;
begin
  Result := True;

  if SameText(AValue, 'vector') then
    ARenderingType := rtVector
  else if SameText(AValue, 'raster') then
    ARenderingType := rtRaster
  else
    Result := False;
end;

function TGMCustomMap.TryGetCoordinateFromPayload(const APayload: string;
  out ALatLng: TGMLibLatLng): Boolean;
var
  PlaceId: string;
begin
  Result := TryGetCoordinateExFromPayload(APayload, ALatLng, PlaceId);
end;

function TGMCustomMap.TryGetCoordinateExFromPayload(const APayload: string;
  out ALatLng: TGMLibLatLng; out APlaceId: string): Boolean;
var
  JsonObject: TJSONObject;
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
begin
  Result := False;
  ALatLng := nil;
  APlaceId := '';

{$IFDEF FPC}
  JsonValue := GetJSON(APayload);
{$ELSE}
  JsonValue := TJSONObject.ParseJSONValue(APayload);
{$ENDIF}
  try
    if not (JsonValue is TJSONObject) then
      Exit;

    JsonObject := TJSONObject(JsonValue);
{$IFDEF FPC}
    ALatLng := TGMLibLatLng.Create(0, 0);
    if Assigned(JsonObject.Find('lat')) then
      ALatLng.Lat := JsonObject.Find('lat').AsFloat;
    if Assigned(JsonObject.Find('lng')) then
      ALatLng.Lng := JsonObject.Find('lng').AsFloat;
    if Assigned(JsonObject.Find('placeId')) then
      APlaceId := JsonObject.Find('placeId').AsString;
{$ELSE}
    ALatLng := TGMLibLatLng.Create(
      JsonObject.GetValue<Double>('lat', 0),
      JsonObject.GetValue<Double>('lng', 0)
    );
    APlaceId := JsonObject.GetValue<string>('placeId', '');
{$ENDIF}
    Result := True;
  finally
    JsonValue.Free;
  end;
end;

function TGMCustomMap.TryGetBoundsFromPayload(const APayload: string;
  out ABounds: TGMLatLngBounds): Boolean;
var
  JsonObject: TJSONObject;
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
begin
  Result := False;
  ABounds := nil;

{$IFDEF FPC}
  JsonValue := GetJSON(APayload);
{$ELSE}
  JsonValue := TJSONObject.ParseJSONValue(APayload);
{$ENDIF}
  try
    if not (JsonValue is TJSONObject) then
      Exit;

    JsonObject := TJSONObject(JsonValue);
    ABounds := TGMLatLngBounds.Create;
{$IFDEF FPC}
    if Assigned(JsonObject.Find('north')) then
      ABounds.North := JsonObject.Find('north').AsFloat;
    if Assigned(JsonObject.Find('south')) then
      ABounds.South := JsonObject.Find('south').AsFloat;
    if Assigned(JsonObject.Find('east')) then
      ABounds.East := JsonObject.Find('east').AsFloat;
    if Assigned(JsonObject.Find('west')) then
      ABounds.West := JsonObject.Find('west').AsFloat;
{$ELSE}
    ABounds.North := JsonObject.GetValue<Double>('north', 0);
    ABounds.South := JsonObject.GetValue<Double>('south', 0);
    ABounds.East := JsonObject.GetValue<Double>('east', 0);
    ABounds.West := JsonObject.GetValue<Double>('west', 0);
{$ENDIF}
    Result := True;
  finally
    JsonValue.Free;
  end;
end;

procedure TGMCustomMap.UnregisterLinkedComponent(
  AComponent: TGMCustomMapLinkedComponent);
begin
  if not Assigned(AComponent) then
    Exit;

  FLinkedComponents.Remove(AComponent.ObjectId);
end;

end.
