{**
  @abstract(Tipos base compartidos del nuevo núcleo de GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define tipos simples y reutilizables para el arranque del núcleo
  de GMLib.
}
unit uGMLib.Core.Types;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, Math, SysUtils,
{$ELSE}
  System.Classes, System.Math, System.SysUtils,
{$ENDIF}

  uGMLib.Core.ApiObject,
  uGMLib.Platform.Format;

type
  TGMLibLatLng = class;
  TGMMapId = type string;
  TGMObjectId = type string;

  {** @abstract(Contrato mínimo para que una colección pueda hacer zoom al mapa
      sin conocer la clase concreta del host.) }
  IGMMapViewportHost = interface
    ['{2B20E9B0-10C9-49E7-950E-5D9154AA42A0}']
    procedure CenterMapTo(const ALatLng: TGMLibLatLng);
    procedure FitBounds(ANorth, ASouth, AEast, AWest: Double);
  end;

  {** @abstract(Backend lógico usado por el transporte del bridge.) }
  TGMBridgeBackend = (
    bbUnknown,
    bbWebView2,
    bbCEF,
    bbFMX
  );

  {** @abstract(Tipos base de mapa soportados por Google Maps.) }
  TGMMapTypeId = (
    mtRoadmap,
    mtSatellite,
    mtHybrid,
    mtTerrain
  );

  {** @abstract(Conjunto de tipos de mapa permitidos en controles de selección.) }
  TGMMapTypeIds = set of TGMMapTypeId;

  {** @abstract(Posiciones neutras de controles dentro del mapa.) }
  TGMControlPosition = (
    cpBlockEndInlineCenter,
    cpBlockEndInlineEnd,
    cpBlockEndInlineStart,
    cpBlockStartInlineCenter,
    cpBlockStartInlineEnd,
    cpBlockStartInlineStart,
    cpBottomCenter,
    cpBottomLeft,
    cpBottomRight,
    cpInlineEndBlockCenter,
    cpInlineEndBlockEnd,
    cpInlineEndBlockStart,
    cpInlineStartBlockCenter,
    cpInlineStartBlockEnd,
    cpInlineStartBlockStart,
    cpLeftBottom,
    cpLeftCenter,
    cpLeftTop,
    cpRightBottom,
    cpRightCenter,
    cpRightTop,
    cpTopCenter,
    cpTopLeft,
    cpTopRight
  );

  {** @abstract(Estilos visuales del control de tipo de mapa.) }
  TGMMapTypeControlStyle = (
    mtcsDefault,
    mtcsDropdownMenu,
    mtcsHorizontalBar
  );

  {** @abstract(Modos de interacción gestual admitidos por el mapa.) }
  TGMGestureHandling = (
    ghAuto,
    ghCooperative,
    ghGreedy,
    ghNone
  );

  {** @abstract(Estilos admitidos por el control de escala.) }
  TGMScaleControlStyle = (
    scsDefault
  );

  {** @abstract(Esquemas de color admitidos por el mapa.) }
  TGMColorScheme = (
    csLight,
    csDark,
    csFollowSystem
  );

  {** @abstract(Modos de renderizado configurables en la creación del mapa.) }
  TGMRenderingType = (
    rtRaster,
    rtVector
  );

  {** @abstract(Modos de colisión admitidos por `AdvancedMarkerElement`.) }
  TGMCollisionBehavior = (
    cbRequired,
    cbOptionalAndHidesLowerPriority,
    cbRequiredAndHidesOptional
  );

  {** @abstract(Modos de contenido visual admitidos por `AdvancedMarkerElement`.) }
  TGMMarkerContentMode = (
    mcmDefault,
    mcmPin,
    mcmHtml,
    mcmLabel
  );

  {** @abstract(Origen lógico de un cambio de estado en el mapa.) }
  TGMChangeOrigin = (
    coDelphi,
    coJavaScript
  );

  {** @abstract(Clase Delphi que envuelve una coordenada `google.maps.LatLng`.) }
  TGMLibLatLng = class(TGMLibApiObject)
  private
    FLat: Double;
    FLng: Double;
    procedure SetLat(const Value: Double);
    procedure SetLng(const Value: Double);
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create(ALatitude: Double = 0; ALongitude: Double = 0); reintroduce; virtual;

    procedure Assign(Source: TPersistent); override;
    function Equals(ALatLng: TGMLibLatLng): Boolean; reintroduce;
    function ToJavaScriptLiteral: string;
  published
    {** @abstract(Latitud de la coordenada.) }
    property Lat: Double read FLat write SetLat;

    {** @abstract(Longitud de la coordenada.) }
    property Lng: Double read FLng write SetLng;
  end;

implementation

{ TGMLibLatLng }

procedure TGMLibLatLng.Assign(Source: TPersistent);
begin
  if Source is TGMLibLatLng then
  begin
    Lat := TGMLibLatLng(Source).Lat;
    Lng := TGMLibLatLng(Source).Lng;
    Exit;
  end;

  inherited;
end;

constructor TGMLibLatLng.Create(ALatitude, ALongitude: Double);
begin
  inherited Create;

  FLat := ALatitude;
  FLng := ALongitude;
end;

function TGMLibLatLng.Equals(ALatLng: TGMLibLatLng): Boolean;
begin
  Result := Assigned(ALatLng) and
    SameValue(FLat, ALatLng.Lat) and
    SameValue(FLng, ALatLng.Lng);
end;

function TGMLibLatLng.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/coordinates#LatLng';
end;

procedure TGMLibLatLng.SetLat(const Value: Double);
begin
  if SameValue(FLat, Value) then
    Exit;

  FLat := Value;
  Changed;
end;

procedure TGMLibLatLng.SetLng(const Value: Double);
begin
  if SameValue(FLng, Value) then
    Exit;

  FLng := Value;
  Changed;
end;

function TGMLibLatLng.ToJavaScriptLiteral: string;
begin
  Result := Format('{ lat: %s, lng: %s }', [
    FloatToStr(FLat, GMLibInvariantFormatSettings),
    FloatToStr(FLng, GMLibInvariantFormatSettings)
  ]);
end;

end.
