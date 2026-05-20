{**
  @abstract(Opciones neutrales del mapa compartidas entre frameworks.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define el bloque de opciones común del mapa con tipos agnósticos
  de framework, listo para serializarse hacia JavaScript.
}
unit uGMLib.MapOptions;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  Math,
  SysUtils,
{$ELSE}
  System.Classes,
  System.Math,
  System.SysUtils,
{$ENDIF}
  uMapLib.Core.ApiObject,
  uGMLib.Core.Types,
  uGMLib.Google.Types,
  uGMLib.Platform.Format;

type
  {** @abstract(Base para opciones de controles que solo exponen posición.) }
  TGMCustomPositionControlOptions = class(TMapLibApiObject)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    function BuildPositionValue: string;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    {** @abstract(Serializa la opción a literal JavaScript.) }
    function ToJavaScriptLiteral: string; virtual;
  published
    {** @abstract(Posición del control dentro del mapa.) }
    property Position: TGMControlPosition read FPosition write SetPosition default cpTopRight;
  end;

  {** @abstract(Opciones neutrales del control de tipo de mapa.) }
  TGMMapTypeControlOptions = class(TMapLibApiObject)
  private
    FMapTypeIds: TGMMapTypeIds;
    FPosition: TGMControlPosition;
    FStyle: TGMMapTypeControlStyle;
    function BuildMapTypeIdsValue: string;
    procedure SetMapTypeIds(const Value: TGMMapTypeIds);
    procedure SetPosition(const Value: TGMControlPosition);
    procedure SetStyle(const Value: TGMMapTypeControlStyle);
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    function BuildPositionValue: string;
    function BuildStyleValue: string;
    {** @abstract(Serializa la opción a literal JavaScript.) }
    function ToJavaScriptLiteral: string;
  published
    {** @abstract(Conjunto de tipos de mapa mostrados por el control.) }
    property MapTypeIds: TGMMapTypeIds read FMapTypeIds write SetMapTypeIds default [mtRoadmap, mtSatellite, mtHybrid, mtTerrain];
    {** @abstract(Posición del control dentro del mapa.) }
    property Position: TGMControlPosition read FPosition write SetPosition default cpTopRight;
    {** @abstract(Estilo visual del selector de tipo de mapa.) }
    property Style: TGMMapTypeControlStyle read FStyle write SetStyle default mtcsDefault;
  end;

  {** @abstract(Opciones neutrales del control fullscreen.) }
  TGMFullscreenControlOptions = class(TGMCustomPositionControlOptions)
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
  published
    property Position default cpRightTop;
  end;

  {** @abstract(Opciones neutrales del control de cámara.) }
  TGMCameraControlOptions = class(TGMCustomPositionControlOptions)
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
  published
    property Position default cpInlineStartBlockEnd;
  end;

  {** @abstract(Opciones neutrales del control de rotación.) }
  TGMRotateControlOptions = class(TGMCustomPositionControlOptions)
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
  published
    property Position default cpTopLeft;
  end;

  {** @abstract(Opciones neutrales del control de Street View.) }
  TGMStreetViewControlOptions = class(TGMCustomPositionControlOptions)
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
  published
    property Position default cpTopLeft;
  end;

  {** @abstract(Opciones neutrales del control de zoom.) }
  TGMZoomControlOptions = class(TGMCustomPositionControlOptions)
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
  published
    property Position default cpTopLeft;
  end;

  {** @abstract(Opciones neutrales del control de escala.) }
  TGMScaleControlOptions = class(TMapLibApiObject)
  private
    FStyle: TGMScaleControlStyle;
    procedure SetStyle(const Value: TGMScaleControlStyle);
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    {** @abstract(Serializa la opción a literal JavaScript.) }
    function ToJavaScriptLiteral: string;
  published
    {** @abstract(Estilo visual del control de escala.) }
    property Style: TGMScaleControlStyle read FStyle write SetStyle default scsDefault;
  end;

  {** @abstract(Límites geográficos simples usados por restricciones del mapa.) }
  TGMLatLngBounds = class(TMapLibApiObject)
  private
    FEast: Double;
    FHasEast: Boolean;
    FHasNorth: Boolean;
    FHasSouth: Boolean;
    FHasWest: Boolean;
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FNorth: Double;
    FSouth: Double;
    FWest: Double;
    procedure SetEast(const Value: Double);
    procedure SetNorth(const Value: Double);
    procedure SetSouth(const Value: Double);
    procedure SetWest(const Value: Double);
  protected
    procedure Changed; override;
    function IsEastStored: Boolean;
    function IsNorthStored: Boolean;
    function IsSouthStored: Boolean;
    function IsWestStored: Boolean;
  public
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    function IsComplete: Boolean;
    procedure EndUpdate;
    function ToJavaScriptLiteral: string;
  published
    property East: Double read FEast write SetEast stored IsEastStored;
    property North: Double read FNorth write SetNorth stored IsNorthStored;
    property South: Double read FSouth write SetSouth stored IsSouthStored;
    property West: Double read FWest write SetWest stored IsWestStored;
  end;

  {** @abstract(Restricción geográfica del mapa según la API de Google Maps.) }
  TGMMapRestriction = class(TMapLibApiObject)
  private
    FLatLngBounds: TGMLatLngBounds;
    FHasStrictBounds: Boolean;
    FStrictBounds: Boolean;
    procedure BoundsChanged(Sender: TObject);
    procedure SetLatLngBounds(const Value: TGMLatLngBounds);
    procedure SetStrictBounds(const Value: Boolean);
  protected
    function IsStrictBoundsStored: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function IsConfigured: Boolean;
    function ToJavaScriptLiteral: string;
  published
    property LatLngBounds: TGMLatLngBounds read FLatLngBounds write SetLatLngBounds;
    property StrictBounds: Boolean read FStrictBounds write SetStrictBounds stored IsStrictBoundsStored;
  end;

  {** @abstract(Bloque de opciones iniciales del mapa.) }
  TGMMapOptions = class(TMapLibApiObject)
  private
    FBackgroundColorCss: string;
    FCameraControl: Boolean;
    FCameraControlOptions: TGMCameraControlOptions;
    FCenter: TMapLibLatLng;
    FClickableIcons: Boolean;
    FColorScheme: TGMColorScheme;
    FControlSize: Integer;
    FDisableDefaultUI: Boolean;
    FDisableDoubleClickZoom: Boolean;
    FDraggingCursor: string;
    FDraggableCursor: string;
    FFullscreenControl: Boolean;
    FFullscreenControlOptions: TGMFullscreenControlOptions;
    FGestureHandling: TGMGestureHandling;
    FHasCameraControl: Boolean;
    FHasColorScheme: Boolean;
    FHasControlSize: Boolean;
    FHasHeading: Boolean;
    FHasHeadingInteractionEnabled: Boolean;
    FHasIsFractionalZoomEnabled: Boolean;
    FHasMaxZoom: Boolean;
    FHasMinZoom: Boolean;
    FHasNoClear: Boolean;
    FHasRenderingType: Boolean;
    FHasScrollwheel: Boolean;
    FHasTilt: Boolean;
    FHasTiltInteractionEnabled: Boolean;
    FHeading: Double;
    FHeadingInteractionEnabled: Boolean;
    FIsFractionalZoomEnabled: Boolean;
    FKeyboardShortcuts: Boolean;
    FMapId: TGMMapId;
    FMapTypeControl: Boolean;
    FMapTypeControlOptions: TGMMapTypeControlOptions;
    FMapTypeId: TGMMapTypeId;
    FMaxZoom: Integer;
    FMinZoom: Integer;
    FNoClear: Boolean;
    FRenderingType: TGMRenderingType;
    FRestriction: TGMMapRestriction;
    FRotateControl: Boolean;
    FRotateControlOptions: TGMRotateControlOptions;
    FScaleControl: Boolean;
    FScaleControlOptions: TGMScaleControlOptions;
    FScrollwheel: Boolean;
    FStreetViewControl: Boolean;
    FStreetViewControlOptions: TGMStreetViewControlOptions;
    FTilt: Integer;
    FTiltInteractionEnabled: Boolean;
    FZoom: Integer;
    FZoomControl: Boolean;
    FZoomControlOptions: TGMZoomControlOptions;
    procedure CameraControlOptionsChanged(Sender: TObject);
    procedure CenterChanged(Sender: TObject);
    procedure FullscreenControlOptionsChanged(Sender: TObject);
    procedure MapTypeControlOptionsChanged(Sender: TObject);
    procedure RotateControlOptionsChanged(Sender: TObject);
    procedure RestrictionChanged(Sender: TObject);
    procedure ScaleControlOptionsChanged(Sender: TObject);
    procedure StreetViewControlOptionsChanged(Sender: TObject);
    procedure ZoomControlOptionsChanged(Sender: TObject);
    procedure SetBackgroundColorCss(const Value: string);
    procedure SetCameraControl(const Value: Boolean);
    procedure SetCameraControlOptions(const Value: TGMCameraControlOptions);
    procedure SetCenter(const Value: TMapLibLatLng);
    procedure SetClickableIcons(const Value: Boolean);
    procedure SetColorScheme(const Value: TGMColorScheme);
    procedure SetControlSize(const Value: Integer);
    procedure SetDisableDefaultUI(const Value: Boolean);
    procedure SetDisableDoubleClickZoom(const Value: Boolean);
    procedure SetDraggingCursor(const Value: string);
    procedure SetDraggableCursor(const Value: string);
    procedure SetFullscreenControl(const Value: Boolean);
    procedure SetFullscreenControlOptions(const Value: TGMFullscreenControlOptions);
    procedure SetGestureHandling(const Value: TGMGestureHandling);
    procedure SetHeading(const Value: Double);
    procedure SetHeadingInteractionEnabled(const Value: Boolean);
    procedure SetIsFractionalZoomEnabled(const Value: Boolean);
    procedure SetKeyboardShortcuts(const Value: Boolean);
    procedure SetMapTypeControl(const Value: Boolean);
    procedure SetMapTypeControlOptions(const Value: TGMMapTypeControlOptions);
    procedure SetMapTypeId(const Value: TGMMapTypeId);
    procedure SetMaxZoom(const Value: Integer);
    procedure SetMinZoom(const Value: Integer);
    procedure SetMapId(const Value: TGMMapId);
    procedure SetNoClear(const Value: Boolean);
    procedure SetRenderingType(const Value: TGMRenderingType);
    procedure SetRestriction(const Value: TGMMapRestriction);
    procedure SetRotateControl(const Value: Boolean);
    procedure SetRotateControlOptions(const Value: TGMRotateControlOptions);
    procedure SetScaleControl(const Value: Boolean);
    procedure SetScaleControlOptions(const Value: TGMScaleControlOptions);
    procedure SetScrollwheel(const Value: Boolean);
    procedure SetStreetViewControl(const Value: Boolean);
    procedure SetStreetViewControlOptions(const Value: TGMStreetViewControlOptions);
    procedure SetTilt(const Value: Integer);
    procedure SetTiltInteractionEnabled(const Value: Boolean);
    procedure SetZoom(const Value: Integer);
    procedure SetZoomControl(const Value: Boolean);
    procedure SetZoomControlOptions(const Value: TGMZoomControlOptions);
  protected
    function BuildColorSchemeValue: string;
    function BuildInitializationOptionsSignature: string;
    function GetAPIUrl: string; override;
    function IsCameraControlStored: Boolean;
    function IsColorSchemeStored: Boolean;
    function IsControlSizeStored: Boolean;
    function IsFractionalZoomEnabledStored: Boolean;
    function IsHeadingInteractionEnabledStored: Boolean;
    function IsHeadingStored: Boolean;
    function IsMapIdStored: Boolean;
    function IsMaxZoomStored: Boolean;
    function IsMinZoomStored: Boolean;
    function IsNoClearStored: Boolean;
    function IsRenderingTypeStored: Boolean;
    function IsRestrictionStored: Boolean;
    function IsScrollwheelStored: Boolean;
    function IsTiltInteractionEnabledStored: Boolean;
    function IsTiltStored: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    { This serializes only the options explicitly set by the caller. The
      FHas* flags prevent default values from leaking into the generated JS. }
    function BuildInitializationOptionsLiteral: string;
    function BuildMapTypeIdValue: string;
    function BuildRenderingTypeValue: string;
    {** @abstract(Serializa el bloque completo de opciones a literal JavaScript.) }
    function ToJavaScriptLiteral: string;
    property BackgroundColorCss: string read FBackgroundColorCss write SetBackgroundColorCss;
  published
    property Center: TMapLibLatLng read FCenter write SetCenter;
    property CameraControl: Boolean read FCameraControl write SetCameraControl stored IsCameraControlStored;
    property CameraControlOptions: TGMCameraControlOptions read FCameraControlOptions write SetCameraControlOptions;
    property ClickableIcons: Boolean read FClickableIcons write SetClickableIcons default True;
    property ColorScheme: TGMColorScheme read FColorScheme write SetColorScheme stored IsColorSchemeStored;
    property ControlSize: Integer read FControlSize write SetControlSize stored IsControlSizeStored;
    property DisableDefaultUI: Boolean read FDisableDefaultUI write SetDisableDefaultUI default False;
    property DisableDoubleClickZoom: Boolean read FDisableDoubleClickZoom write SetDisableDoubleClickZoom default False;
    property DraggableCursor: string read FDraggableCursor write SetDraggableCursor;
    property DraggingCursor: string read FDraggingCursor write SetDraggingCursor;
    property FullscreenControl: Boolean read FFullscreenControl write SetFullscreenControl default True;
    property FullscreenControlOptions: TGMFullscreenControlOptions read FFullscreenControlOptions write SetFullscreenControlOptions;
    property GestureHandling: TGMGestureHandling read FGestureHandling write SetGestureHandling default ghAuto;
    property Heading: Double read FHeading write SetHeading stored IsHeadingStored;
    property HeadingInteractionEnabled: Boolean read FHeadingInteractionEnabled write SetHeadingInteractionEnabled stored IsHeadingInteractionEnabledStored;
    property IsFractionalZoomEnabled: Boolean read FIsFractionalZoomEnabled write SetIsFractionalZoomEnabled stored IsFractionalZoomEnabledStored;
    property KeyboardShortcuts: Boolean read FKeyboardShortcuts write SetKeyboardShortcuts default True;
    property MapId: TGMMapId read FMapId write SetMapId stored IsMapIdStored;
    property MapTypeControl: Boolean read FMapTypeControl write SetMapTypeControl default True;
    property MapTypeControlOptions: TGMMapTypeControlOptions read FMapTypeControlOptions write SetMapTypeControlOptions;
    property MapTypeId: TGMMapTypeId read FMapTypeId write SetMapTypeId default mtRoadmap;
    property MaxZoom: Integer read FMaxZoom write SetMaxZoom stored IsMaxZoomStored;
    property MinZoom: Integer read FMinZoom write SetMinZoom stored IsMinZoomStored;
    property NoClear: Boolean read FNoClear write SetNoClear stored IsNoClearStored;
    property RenderingType: TGMRenderingType read FRenderingType write SetRenderingType stored IsRenderingTypeStored;
    property Restriction: TGMMapRestriction read FRestriction write SetRestriction stored IsRestrictionStored;
    property RotateControl: Boolean read FRotateControl write SetRotateControl default False;
    property RotateControlOptions: TGMRotateControlOptions read FRotateControlOptions write SetRotateControlOptions;
    property ScaleControl: Boolean read FScaleControl write SetScaleControl default False;
    property ScaleControlOptions: TGMScaleControlOptions read FScaleControlOptions write SetScaleControlOptions;
    property Scrollwheel: Boolean read FScrollwheel write SetScrollwheel stored IsScrollwheelStored;
    property StreetViewControl: Boolean read FStreetViewControl write SetStreetViewControl default True;
    property StreetViewControlOptions: TGMStreetViewControlOptions read FStreetViewControlOptions write SetStreetViewControlOptions;
    property Tilt: Integer read FTilt write SetTilt stored IsTiltStored;
    property TiltInteractionEnabled: Boolean read FTiltInteractionEnabled write SetTiltInteractionEnabled stored IsTiltInteractionEnabledStored;
    property Zoom: Integer read FZoom write SetZoom default 8;
    property ZoomControl: Boolean read FZoomControl write SetZoomControl default True;
    property ZoomControlOptions: TGMZoomControlOptions read FZoomControlOptions write SetZoomControlOptions;
  end;

implementation

{ TGMCustomPositionControlOptions }

procedure TGMCustomPositionControlOptions.Assign(Source: TPersistent);
begin
  if Source is TGMCustomPositionControlOptions then
  begin
    Position := TGMCustomPositionControlOptions(Source).Position;
    Exit;
  end;

  inherited;
end;

function TGMCustomPositionControlOptions.BuildPositionValue: string;
begin
  case FPosition of
    cpBlockEndInlineCenter: Result := 'BLOCK_END_INLINE_CENTER';
    cpBlockEndInlineEnd: Result := 'BLOCK_END_INLINE_END';
    cpBlockEndInlineStart: Result := 'BLOCK_END_INLINE_START';
    cpBlockStartInlineCenter: Result := 'BLOCK_START_INLINE_CENTER';
    cpBlockStartInlineEnd: Result := 'BLOCK_START_INLINE_END';
    cpBlockStartInlineStart: Result := 'BLOCK_START_INLINE_START';
    cpBottomCenter: Result := 'BOTTOM_CENTER';
    cpBottomLeft: Result := 'BOTTOM_LEFT';
    cpBottomRight: Result := 'BOTTOM_RIGHT';
    cpInlineEndBlockCenter: Result := 'INLINE_END_BLOCK_CENTER';
    cpInlineEndBlockEnd: Result := 'INLINE_END_BLOCK_END';
    cpInlineEndBlockStart: Result := 'INLINE_END_BLOCK_START';
    cpInlineStartBlockCenter: Result := 'INLINE_START_BLOCK_CENTER';
    cpInlineStartBlockEnd: Result := 'INLINE_START_BLOCK_END';
    cpInlineStartBlockStart: Result := 'INLINE_START_BLOCK_START';
    cpLeftBottom: Result := 'LEFT_BOTTOM';
    cpLeftCenter: Result := 'LEFT_CENTER';
    cpLeftTop: Result := 'LEFT_TOP';
    cpRightBottom: Result := 'RIGHT_BOTTOM';
    cpRightCenter: Result := 'RIGHT_CENTER';
    cpRightTop: Result := 'RIGHT_TOP';
    cpTopCenter: Result := 'TOP_CENTER';
    cpTopLeft: Result := 'TOP_LEFT';
  else
    Result := 'TOP_RIGHT';
  end;
end;

constructor TGMCustomPositionControlOptions.Create;
begin
  inherited;
  FPosition := cpTopRight;
end;

procedure TGMCustomPositionControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then
    Exit;

  FPosition := Value;
  Changed;
end;

function TGMCustomPositionControlOptions.ToJavaScriptLiteral: string;
begin
  Result := Format('{ position: google.maps.ControlPosition.%s }', [BuildPositionValue]);
end;

{ TGMMapTypeControlOptions }

constructor TGMMapTypeControlOptions.Create;
begin
  inherited;
  FMapTypeIds := [mtRoadmap, mtSatellite, mtHybrid, mtTerrain];
  FPosition := cpTopRight;
  FStyle := mtcsDefault;
end;

procedure TGMMapTypeControlOptions.Assign(Source: TPersistent);
begin
  if Source is TGMMapTypeControlOptions then
  begin
    MapTypeIds := TGMMapTypeControlOptions(Source).MapTypeIds;
    Position := TGMMapTypeControlOptions(Source).Position;
    Style := TGMMapTypeControlOptions(Source).Style;
    Exit;
  end;

  inherited;
end;

function TGMMapTypeControlOptions.BuildMapTypeIdsValue: string;
begin
  Result := '';

  if mtRoadmap in FMapTypeIds then
    Result := Result + QuotedStr('roadmap');

  if mtSatellite in FMapTypeIds then
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + QuotedStr('satellite');
  end;

  if mtHybrid in FMapTypeIds then
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + QuotedStr('hybrid');
  end;

  if mtTerrain in FMapTypeIds then
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + QuotedStr('terrain');
  end;

  Result := '[' + Result + ']';
end;

function TGMMapTypeControlOptions.BuildPositionValue: string;
begin
  case FPosition of
    cpBlockEndInlineCenter: Result := 'BLOCK_END_INLINE_CENTER';
    cpBlockEndInlineEnd: Result := 'BLOCK_END_INLINE_END';
    cpBlockEndInlineStart: Result := 'BLOCK_END_INLINE_START';
    cpBlockStartInlineCenter: Result := 'BLOCK_START_INLINE_CENTER';
    cpBlockStartInlineEnd: Result := 'BLOCK_START_INLINE_END';
    cpBlockStartInlineStart: Result := 'BLOCK_START_INLINE_START';
    cpBottomCenter: Result := 'BOTTOM_CENTER';
    cpBottomLeft: Result := 'BOTTOM_LEFT';
    cpBottomRight: Result := 'BOTTOM_RIGHT';
    cpInlineEndBlockCenter: Result := 'INLINE_END_BLOCK_CENTER';
    cpInlineEndBlockEnd: Result := 'INLINE_END_BLOCK_END';
    cpInlineEndBlockStart: Result := 'INLINE_END_BLOCK_START';
    cpInlineStartBlockCenter: Result := 'INLINE_START_BLOCK_CENTER';
    cpInlineStartBlockEnd: Result := 'INLINE_START_BLOCK_END';
    cpInlineStartBlockStart: Result := 'INLINE_START_BLOCK_START';
    cpLeftBottom: Result := 'LEFT_BOTTOM';
    cpLeftCenter: Result := 'LEFT_CENTER';
    cpLeftTop: Result := 'LEFT_TOP';
    cpRightBottom: Result := 'RIGHT_BOTTOM';
    cpRightCenter: Result := 'RIGHT_CENTER';
    cpRightTop: Result := 'RIGHT_TOP';
    cpTopCenter: Result := 'TOP_CENTER';
    cpTopLeft: Result := 'TOP_LEFT';
  else
    Result := 'TOP_RIGHT';
  end;
end;

function TGMMapTypeControlOptions.BuildStyleValue: string;
begin
  case FStyle of
    mtcsDropdownMenu: Result := 'DROPDOWN_MENU';
    mtcsHorizontalBar: Result := 'HORIZONTAL_BAR';
  else
    Result := 'DEFAULT';
  end;
end;

function TGMMapTypeControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#MapTypeControlOptions';
end;

procedure TGMMapTypeControlOptions.SetMapTypeIds(const Value: TGMMapTypeIds);
begin
  if FMapTypeIds = Value then
    Exit;

  FMapTypeIds := Value;
  Changed;
end;

procedure TGMMapTypeControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then
    Exit;

  FPosition := Value;
  Changed;
end;

procedure TGMMapTypeControlOptions.SetStyle(const Value: TGMMapTypeControlStyle);
begin
  if FStyle = Value then
    Exit;

  FStyle := Value;
  Changed;
end;

function TGMMapTypeControlOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{ position: google.maps.ControlPosition.%s, style: google.maps.MapTypeControlStyle.%s',
    [BuildPositionValue, BuildStyleValue]
  );

  if FMapTypeIds <> [] then
    Result := Result + Format(', mapTypeIds: %s', [BuildMapTypeIdsValue]);

  Result := Result + ' }';
end;

{ TGMFullscreenControlOptions }

constructor TGMFullscreenControlOptions.Create;
begin
  inherited;
  Position := cpRightTop;
end;

function TGMFullscreenControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#FullscreenControlOptions';
end;

{ TGMCameraControlOptions }

constructor TGMCameraControlOptions.Create;
begin
  inherited;
  Position := cpInlineStartBlockEnd;
end;

function TGMCameraControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#CameraControlOptions';
end;

{ TGMRotateControlOptions }

constructor TGMRotateControlOptions.Create;
begin
  inherited;
  Position := cpTopLeft;
end;

function TGMRotateControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#RotateControlOptions';
end;

{ TGMStreetViewControlOptions }

constructor TGMStreetViewControlOptions.Create;
begin
  inherited;
  Position := cpTopLeft;
end;

function TGMStreetViewControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#StreetViewControlOptions';
end;

{ TGMZoomControlOptions }

constructor TGMZoomControlOptions.Create;
begin
  inherited;
  Position := cpTopLeft;
end;

function TGMZoomControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#ZoomControlOptions';
end;

{ TGMScaleControlOptions }

procedure TGMScaleControlOptions.Assign(Source: TPersistent);
begin
  if Source is TGMScaleControlOptions then
  begin
    Style := TGMScaleControlOptions(Source).Style;
    Exit;
  end;

  inherited;
end;

constructor TGMScaleControlOptions.Create;
begin
  inherited;
  FStyle := scsDefault;
end;

function TGMScaleControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#ScaleControlOptions';
end;

procedure TGMScaleControlOptions.SetStyle(const Value: TGMScaleControlStyle);
begin
  if FStyle = Value then
    Exit;

  FStyle := Value;
  Changed;
end;

function TGMScaleControlOptions.ToJavaScriptLiteral: string;
begin
  Result := '{ style: google.maps.ScaleControlStyle.DEFAULT }';
end;

{ TGMLatLngBounds }

procedure TGMLatLngBounds.Assign(Source: TPersistent);
begin
  if Source is TGMLatLngBounds then
  begin
    BeginUpdate;
    try
    if TGMLatLngBounds(Source).FHasEast then
      East := TGMLatLngBounds(Source).East;
    if TGMLatLngBounds(Source).FHasNorth then
      North := TGMLatLngBounds(Source).North;
    if TGMLatLngBounds(Source).FHasSouth then
      South := TGMLatLngBounds(Source).South;
    if TGMLatLngBounds(Source).FHasWest then
      West := TGMLatLngBounds(Source).West;
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited;
end;

procedure TGMLatLngBounds.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGMLatLngBounds.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

procedure TGMLatLngBounds.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FUpdatePending then
  begin
    FUpdatePending := False;
    inherited Changed;
  end;
end;

function TGMLatLngBounds.IsComplete: Boolean;
begin
  Result := FHasEast and FHasNorth and FHasSouth and FHasWest;
end;

function TGMLatLngBounds.IsEastStored: Boolean;
begin
  Result := FHasEast;
end;

function TGMLatLngBounds.IsNorthStored: Boolean;
begin
  Result := FHasNorth;
end;

function TGMLatLngBounds.IsSouthStored: Boolean;
begin
  Result := FHasSouth;
end;

function TGMLatLngBounds.IsWestStored: Boolean;
begin
  Result := FHasWest;
end;

procedure TGMLatLngBounds.SetEast(const Value: Double);
begin
  FHasEast := True;
  if SameValue(FEast, Value) then
    Exit;

  FEast := Value;
  Changed;
end;

procedure TGMLatLngBounds.SetNorth(const Value: Double);
begin
  FHasNorth := True;
  if SameValue(FNorth, Value) then
    Exit;

  FNorth := Value;
  Changed;
end;

procedure TGMLatLngBounds.SetSouth(const Value: Double);
begin
  FHasSouth := True;
  if SameValue(FSouth, Value) then
    Exit;

  FSouth := Value;
  Changed;
end;

procedure TGMLatLngBounds.SetWest(const Value: Double);
begin
  FHasWest := True;
  if SameValue(FWest, Value) then
    Exit;

  FWest := Value;
  Changed;
end;

function TGMLatLngBounds.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{ north: %s, south: %s, east: %s, west: %s }',
    [
      FloatToStr(FNorth, GMLibInvariantFormatSettings),
      FloatToStr(FSouth, GMLibInvariantFormatSettings),
      FloatToStr(FEast, GMLibInvariantFormatSettings),
      FloatToStr(FWest, GMLibInvariantFormatSettings)
    ]
  );
end;

{ TGMMapRestriction }

procedure TGMMapRestriction.Assign(Source: TPersistent);
begin
  if Source is TGMMapRestriction then
  begin
    LatLngBounds.Assign(TGMMapRestriction(Source).LatLngBounds);
    FHasStrictBounds := TGMMapRestriction(Source).FHasStrictBounds;
    if FHasStrictBounds then
      StrictBounds := TGMMapRestriction(Source).StrictBounds;
    Exit;
  end;

  inherited;
end;

procedure TGMMapRestriction.BoundsChanged(Sender: TObject);
begin
  Changed;
end;

constructor TGMMapRestriction.Create;
begin
  inherited;
  FLatLngBounds := TGMLatLngBounds.Create;
{$IFDEF FPC}
  FLatLngBounds.OnChange := @BoundsChanged;
{$ELSE}
  FLatLngBounds.OnChange := BoundsChanged;
{$ENDIF}
end;

destructor TGMMapRestriction.Destroy;
begin
  FLatLngBounds.Free;
  inherited;
end;

function TGMMapRestriction.IsConfigured: Boolean;
begin
  Result := FLatLngBounds.IsComplete;
end;

function TGMMapRestriction.IsStrictBoundsStored: Boolean;
begin
  Result := FHasStrictBounds;
end;

procedure TGMMapRestriction.SetLatLngBounds(const Value: TGMLatLngBounds);
begin
  if not Assigned(Value) then
    Exit;

  FLatLngBounds.Assign(Value);
  Changed;
end;

procedure TGMMapRestriction.SetStrictBounds(const Value: Boolean);
begin
  FHasStrictBounds := True;
  if FStrictBounds = Value then
    Exit;

  FStrictBounds := Value;
  Changed;
end;

function TGMMapRestriction.ToJavaScriptLiteral: string;
begin
  Result := Format('{ latLngBounds: %s', [LatLngBounds.ToJavaScriptLiteral]);

  if FHasStrictBounds then
    Result := Result + Format(', strictBounds: %s', [LowerCase(BoolToStr(StrictBounds, True))]);

  Result := Result + ' }';
end;

{ TGMMapOptions }

procedure TGMMapOptions.Assign(Source: TPersistent);
begin
  if Source is TGMMapOptions then
  begin
    BackgroundColorCss := TGMMapOptions(Source).BackgroundColorCss;
    FHasCameraControl := TGMMapOptions(Source).FHasCameraControl;
    if FHasCameraControl then
      CameraControl := TGMMapOptions(Source).CameraControl;
    CameraControlOptions.Assign(TGMMapOptions(Source).CameraControlOptions);
    Center.Assign(TGMMapOptions(Source).Center);
    ClickableIcons := TGMMapOptions(Source).ClickableIcons;
    FHasColorScheme := TGMMapOptions(Source).FHasColorScheme;
    if FHasColorScheme then
      ColorScheme := TGMMapOptions(Source).ColorScheme;
    FHasControlSize := TGMMapOptions(Source).FHasControlSize;
    if FHasControlSize then
      ControlSize := TGMMapOptions(Source).ControlSize;
    DisableDefaultUI := TGMMapOptions(Source).DisableDefaultUI;
    DisableDoubleClickZoom := TGMMapOptions(Source).DisableDoubleClickZoom;
    DraggableCursor := TGMMapOptions(Source).DraggableCursor;
    DraggingCursor := TGMMapOptions(Source).DraggingCursor;
    FullscreenControl := TGMMapOptions(Source).FullscreenControl;
    FullscreenControlOptions.Assign(TGMMapOptions(Source).FullscreenControlOptions);
    GestureHandling := TGMMapOptions(Source).GestureHandling;
    FHasHeading := TGMMapOptions(Source).FHasHeading;
    if FHasHeading then
      Heading := TGMMapOptions(Source).Heading;
    FHasHeadingInteractionEnabled := TGMMapOptions(Source).FHasHeadingInteractionEnabled;
    if FHasHeadingInteractionEnabled then
      HeadingInteractionEnabled := TGMMapOptions(Source).HeadingInteractionEnabled;
    FHasIsFractionalZoomEnabled := TGMMapOptions(Source).FHasIsFractionalZoomEnabled;
    if FHasIsFractionalZoomEnabled then
      IsFractionalZoomEnabled := TGMMapOptions(Source).IsFractionalZoomEnabled;
    KeyboardShortcuts := TGMMapOptions(Source).KeyboardShortcuts;
    MapId := TGMMapOptions(Source).MapId;
    MapTypeControl := TGMMapOptions(Source).MapTypeControl;
    MapTypeControlOptions.Assign(TGMMapOptions(Source).MapTypeControlOptions);
    MapTypeId := TGMMapOptions(Source).MapTypeId;
    FHasMaxZoom := TGMMapOptions(Source).FHasMaxZoom;
    if FHasMaxZoom then
      MaxZoom := TGMMapOptions(Source).MaxZoom;
    FHasMinZoom := TGMMapOptions(Source).FHasMinZoom;
    if FHasMinZoom then
      MinZoom := TGMMapOptions(Source).MinZoom;
    FHasNoClear := TGMMapOptions(Source).FHasNoClear;
    if FHasNoClear then
      NoClear := TGMMapOptions(Source).NoClear;
    FHasRenderingType := TGMMapOptions(Source).FHasRenderingType;
    if FHasRenderingType then
      RenderingType := TGMMapOptions(Source).RenderingType;
    Restriction.Assign(TGMMapOptions(Source).Restriction);
    RotateControl := TGMMapOptions(Source).RotateControl;
    RotateControlOptions.Assign(TGMMapOptions(Source).RotateControlOptions);
    ScaleControl := TGMMapOptions(Source).ScaleControl;
    ScaleControlOptions.Assign(TGMMapOptions(Source).ScaleControlOptions);
    FHasScrollwheel := TGMMapOptions(Source).FHasScrollwheel;
    if FHasScrollwheel then
      Scrollwheel := TGMMapOptions(Source).Scrollwheel;
    StreetViewControl := TGMMapOptions(Source).StreetViewControl;
    StreetViewControlOptions.Assign(TGMMapOptions(Source).StreetViewControlOptions);
    FHasTilt := TGMMapOptions(Source).FHasTilt;
    if FHasTilt then
      Tilt := TGMMapOptions(Source).Tilt;
    FHasTiltInteractionEnabled := TGMMapOptions(Source).FHasTiltInteractionEnabled;
    if FHasTiltInteractionEnabled then
      TiltInteractionEnabled := TGMMapOptions(Source).TiltInteractionEnabled;
    Zoom := TGMMapOptions(Source).Zoom;
    ZoomControl := TGMMapOptions(Source).ZoomControl;
    ZoomControlOptions.Assign(TGMMapOptions(Source).ZoomControlOptions);
    Exit;
  end;

  inherited;
end;

function TGMMapOptions.BuildColorSchemeValue: string;
begin
  case FColorScheme of
    csDark: Result := 'google.maps.ColorScheme.DARK';
    csFollowSystem: Result := 'google.maps.ColorScheme.FOLLOW_SYSTEM';
  else
    Result := 'google.maps.ColorScheme.LIGHT';
  end;
end;

function TGMMapOptions.BuildInitializationOptionsLiteral: string;
begin
  Result := '';

  if FHasColorScheme then
    Result := Result + Format('colorScheme=%s;', [BuildColorSchemeValue]);

  if FHasControlSize then
    Result := Result + Format('controlSize=%d;', [ControlSize]);

  if MapId <> '' then
    Result := Result + Format('mapId=%s;', [MapId]);

  if FHasRenderingType then
    Result := Result + Format('renderingType=%s;', [BuildRenderingTypeValue]);
end;

function TGMMapOptions.BuildInitializationOptionsSignature: string;
begin
  Result := BuildInitializationOptionsLiteral;
end;

function TGMMapOptions.BuildMapTypeIdValue: string;
begin
  case FMapTypeId of
    mtSatellite: Result := 'google.maps.MapTypeId.SATELLITE';
    mtHybrid: Result := 'google.maps.MapTypeId.HYBRID';
    mtTerrain: Result := 'google.maps.MapTypeId.TERRAIN';
  else
    Result := 'google.maps.MapTypeId.ROADMAP';
  end;
end;

function TGMMapOptions.BuildRenderingTypeValue: string;
begin
  case FRenderingType of
    rtVector: Result := 'google.maps.RenderingType.VECTOR';
  else
    Result := 'google.maps.RenderingType.RASTER';
  end;
end;

procedure TGMMapOptions.CenterChanged(Sender: TObject);
begin
  Changed;
end;

constructor TGMMapOptions.Create;
begin
  inherited;

  FCenter := TMapLibLatLng.Create(0, 0);
{$IFDEF FPC}
  FCenter.OnChange := @CenterChanged;
{$ELSE}
  FCenter.OnChange := CenterChanged;
{$ENDIF}
  FCameraControlOptions := TGMCameraControlOptions.Create;
{$IFDEF FPC}
  FCameraControlOptions.OnChange := @CameraControlOptionsChanged;
{$ELSE}
  FCameraControlOptions.OnChange := CameraControlOptionsChanged;
{$ENDIF}
  FClickableIcons := True;
  FColorScheme := csLight;
  FControlSize := 0;
  FDisableDefaultUI := False;
  FDisableDoubleClickZoom := False;
  FFullscreenControl := True;
  FFullscreenControlOptions := TGMFullscreenControlOptions.Create;
{$IFDEF FPC}
  FFullscreenControlOptions.OnChange := @FullscreenControlOptionsChanged;
{$ELSE}
  FFullscreenControlOptions.OnChange := FullscreenControlOptionsChanged;
{$ENDIF}
  FGestureHandling := ghAuto;
  FKeyboardShortcuts := True;
  FMapId := '';
  FMapTypeControl := True;
  FMapTypeControlOptions := TGMMapTypeControlOptions.Create;
{$IFDEF FPC}
  FMapTypeControlOptions.OnChange := @MapTypeControlOptionsChanged;
{$ELSE}
  FMapTypeControlOptions.OnChange := MapTypeControlOptionsChanged;
{$ENDIF}
  FMapTypeId := mtRoadmap;
  FRenderingType := rtRaster;
  FRestriction := TGMMapRestriction.Create;
{$IFDEF FPC}
  FRestriction.OnChange := @RestrictionChanged;
{$ELSE}
  FRestriction.OnChange := RestrictionChanged;
{$ENDIF}
  FRotateControl := False;
  FRotateControlOptions := TGMRotateControlOptions.Create;
{$IFDEF FPC}
  FRotateControlOptions.OnChange := @RotateControlOptionsChanged;
{$ELSE}
  FRotateControlOptions.OnChange := RotateControlOptionsChanged;
{$ENDIF}
  FScaleControl := False;
  FScaleControlOptions := TGMScaleControlOptions.Create;
{$IFDEF FPC}
  FScaleControlOptions.OnChange := @ScaleControlOptionsChanged;
{$ELSE}
  FScaleControlOptions.OnChange := ScaleControlOptionsChanged;
{$ENDIF}
  FStreetViewControl := True;
  FStreetViewControlOptions := TGMStreetViewControlOptions.Create;
{$IFDEF FPC}
  FStreetViewControlOptions.OnChange := @StreetViewControlOptionsChanged;
{$ELSE}
  FStreetViewControlOptions.OnChange := StreetViewControlOptionsChanged;
{$ENDIF}
  FZoom := 8;
  FZoomControl := True;
  FZoomControlOptions := TGMZoomControlOptions.Create;
{$IFDEF FPC}
  FZoomControlOptions.OnChange := @ZoomControlOptionsChanged;
{$ELSE}
  FZoomControlOptions.OnChange := ZoomControlOptionsChanged;
{$ENDIF}
end;

destructor TGMMapOptions.Destroy;
begin
  FZoomControlOptions.Free;
  FStreetViewControlOptions.Free;
  FScaleControlOptions.Free;
  FRotateControlOptions.Free;
  FRestriction.Free;
  FMapTypeControlOptions.Free;
  FFullscreenControlOptions.Free;
  FCameraControlOptions.Free;
  FCenter.Free;
  inherited;
end;

procedure TGMMapOptions.CameraControlOptionsChanged(Sender: TObject);
begin
  FHasCameraControl := True;
  Changed;
end;

procedure TGMMapOptions.FullscreenControlOptionsChanged(Sender: TObject);
begin
  Changed;
end;

function TGMMapOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#MapOptions';
end;

function TGMMapOptions.IsCameraControlStored: Boolean;
begin
  Result := FHasCameraControl;
end;

function TGMMapOptions.IsColorSchemeStored: Boolean;
begin
  Result := FHasColorScheme;
end;

function TGMMapOptions.IsControlSizeStored: Boolean;
begin
  Result := FHasControlSize;
end;

function TGMMapOptions.IsFractionalZoomEnabledStored: Boolean;
begin
  Result := FHasIsFractionalZoomEnabled;
end;

function TGMMapOptions.IsHeadingInteractionEnabledStored: Boolean;
begin
  Result := FHasHeadingInteractionEnabled;
end;

function TGMMapOptions.IsHeadingStored: Boolean;
begin
  Result := FHasHeading;
end;

function TGMMapOptions.IsMapIdStored: Boolean;
begin
  Result := FMapId <> '';
end;

function TGMMapOptions.IsMaxZoomStored: Boolean;
begin
  Result := FHasMaxZoom;
end;

function TGMMapOptions.IsMinZoomStored: Boolean;
begin
  Result := FHasMinZoom;
end;

function TGMMapOptions.IsNoClearStored: Boolean;
begin
  Result := FHasNoClear;
end;

function TGMMapOptions.IsRenderingTypeStored: Boolean;
begin
  Result := FHasRenderingType;
end;

function TGMMapOptions.IsRestrictionStored: Boolean;
begin
  Result := FRestriction.IsConfigured;
end;

function TGMMapOptions.IsScrollwheelStored: Boolean;
begin
  Result := FHasScrollwheel;
end;

function TGMMapOptions.IsTiltInteractionEnabledStored: Boolean;
begin
  Result := FHasTiltInteractionEnabled;
end;

function TGMMapOptions.IsTiltStored: Boolean;
begin
  Result := FHasTilt;
end;

procedure TGMMapOptions.MapTypeControlOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMapOptions.RestrictionChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMapOptions.RotateControlOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMapOptions.ScaleControlOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMapOptions.SetBackgroundColorCss(const Value: string);
begin
  if SameText(FBackgroundColorCss, Value) then
    Exit;

  FBackgroundColorCss := Value;
  Changed;
end;

procedure TGMMapOptions.SetCameraControl(const Value: Boolean);
begin
  FHasCameraControl := True;
  if FCameraControl = Value then
    Exit;

  FCameraControl := Value;
  Changed;
end;

procedure TGMMapOptions.SetCameraControlOptions(const Value: TGMCameraControlOptions);
begin
  if not Assigned(Value) then
    Exit;

  FHasCameraControl := True;
  FCameraControlOptions.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetCenter(const Value: TMapLibLatLng);
begin
  if not Assigned(Value) then
    Exit;

  if FCenter.Equals(Value) then
    Exit;

  FCenter.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetClickableIcons(const Value: Boolean);
begin
  if FClickableIcons = Value then
    Exit;

  FClickableIcons := Value;
  Changed;
end;

procedure TGMMapOptions.SetColorScheme(const Value: TGMColorScheme);
begin
  FHasColorScheme := True;
  if FColorScheme = Value then
    Exit;

  FColorScheme := Value;
  Changed;
end;

procedure TGMMapOptions.SetControlSize(const Value: Integer);
begin
  FHasControlSize := True;
  if FControlSize = Value then
    Exit;

  FControlSize := Value;
  Changed;
end;

procedure TGMMapOptions.SetDisableDefaultUI(const Value: Boolean);
begin
  if FDisableDefaultUI = Value then
    Exit;

  FDisableDefaultUI := Value;
  Changed;
end;

procedure TGMMapOptions.SetDisableDoubleClickZoom(const Value: Boolean);
begin
  if FDisableDoubleClickZoom = Value then
    Exit;

  FDisableDoubleClickZoom := Value;
  Changed;
end;

procedure TGMMapOptions.SetDraggingCursor(const Value: string);
begin
  if SameText(FDraggingCursor, Value) then
    Exit;

  FDraggingCursor := Value;
  Changed;
end;

procedure TGMMapOptions.SetDraggableCursor(const Value: string);
begin
  if SameText(FDraggableCursor, Value) then
    Exit;

  FDraggableCursor := Value;
  Changed;
end;

procedure TGMMapOptions.SetFullscreenControl(const Value: Boolean);
begin
  if FFullscreenControl = Value then
    Exit;

  FFullscreenControl := Value;
  Changed;
end;

procedure TGMMapOptions.SetFullscreenControlOptions(const Value: TGMFullscreenControlOptions);
begin
  if not Assigned(Value) then
    Exit;

  FFullscreenControlOptions.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetGestureHandling(const Value: TGMGestureHandling);
begin
  if FGestureHandling = Value then
    Exit;

  FGestureHandling := Value;
  Changed;
end;

procedure TGMMapOptions.SetHeading(const Value: Double);
begin
  FHasHeading := True;
  if SameValue(FHeading, Value) then
    Exit;

  FHeading := Value;
  Changed;
end;

procedure TGMMapOptions.SetHeadingInteractionEnabled(const Value: Boolean);
begin
  FHasHeadingInteractionEnabled := True;
  if FHeadingInteractionEnabled = Value then
    Exit;

  FHeadingInteractionEnabled := Value;
  Changed;
end;

procedure TGMMapOptions.SetIsFractionalZoomEnabled(const Value: Boolean);
begin
  FHasIsFractionalZoomEnabled := True;
  if FIsFractionalZoomEnabled = Value then
    Exit;

  FIsFractionalZoomEnabled := Value;
  Changed;
end;

procedure TGMMapOptions.SetKeyboardShortcuts(const Value: Boolean);
begin
  if FKeyboardShortcuts = Value then
    Exit;

  FKeyboardShortcuts := Value;
  Changed;
end;

procedure TGMMapOptions.SetMapTypeControl(const Value: Boolean);
begin
  if FMapTypeControl = Value then
    Exit;

  FMapTypeControl := Value;
  Changed;
end;

procedure TGMMapOptions.SetMapTypeControlOptions(const Value: TGMMapTypeControlOptions);
begin
  if not Assigned(Value) then
    Exit;

  FMapTypeControlOptions.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetMapTypeId(const Value: TGMMapTypeId);
begin
  if FMapTypeId = Value then
    Exit;

  FMapTypeId := Value;
  Changed;
end;

procedure TGMMapOptions.SetMaxZoom(const Value: Integer);
begin
  FHasMaxZoom := True;
  if FMaxZoom = Value then
    Exit;

  FMaxZoom := Value;
  Changed;
end;

procedure TGMMapOptions.SetMinZoom(const Value: Integer);
begin
  FHasMinZoom := True;
  if FMinZoom = Value then
    Exit;

  FMinZoom := Value;
  Changed;
end;

procedure TGMMapOptions.SetMapId(const Value: TGMMapId);
begin
  if FMapId = Value then
    Exit;

  FMapId := Value;
  Changed;
end;

procedure TGMMapOptions.SetNoClear(const Value: Boolean);
begin
  FHasNoClear := True;
  if FNoClear = Value then
    Exit;

  FNoClear := Value;
  Changed;
end;

procedure TGMMapOptions.SetRenderingType(const Value: TGMRenderingType);
begin
  FHasRenderingType := True;
  if FRenderingType = Value then
    Exit;

  FRenderingType := Value;
  Changed;
end;

procedure TGMMapOptions.SetRestriction(const Value: TGMMapRestriction);
begin
  if not Assigned(Value) then
    Exit;

  FRestriction.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetRotateControl(const Value: Boolean);
begin
  if FRotateControl = Value then
    Exit;

  FRotateControl := Value;
  Changed;
end;

procedure TGMMapOptions.SetRotateControlOptions(const Value: TGMRotateControlOptions);
begin
  if not Assigned(Value) then
    Exit;

  FRotateControlOptions.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetScaleControl(const Value: Boolean);
begin
  if FScaleControl = Value then
    Exit;

  FScaleControl := Value;
  Changed;
end;

procedure TGMMapOptions.SetScaleControlOptions(const Value: TGMScaleControlOptions);
begin
  if not Assigned(Value) then
    Exit;

  FScaleControlOptions.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetScrollwheel(const Value: Boolean);
begin
  FHasScrollwheel := True;
  if FScrollwheel = Value then
    Exit;

  FScrollwheel := Value;
  Changed;
end;

procedure TGMMapOptions.SetStreetViewControl(const Value: Boolean);
begin
  if FStreetViewControl = Value then
    Exit;

  FStreetViewControl := Value;
  Changed;
end;

procedure TGMMapOptions.SetStreetViewControlOptions(const Value: TGMStreetViewControlOptions);
begin
  if not Assigned(Value) then
    Exit;

  FStreetViewControlOptions.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.SetTilt(const Value: Integer);
begin
  FHasTilt := True;
  if FTilt = Value then
    Exit;

  FTilt := Value;
  Changed;
end;

procedure TGMMapOptions.SetTiltInteractionEnabled(const Value: Boolean);
begin
  FHasTiltInteractionEnabled := True;
  if FTiltInteractionEnabled = Value then
    Exit;

  FTiltInteractionEnabled := Value;
  Changed;
end;

procedure TGMMapOptions.SetZoom(const Value: Integer);
begin
  if FZoom = Value then
    Exit;

  FZoom := Value;
  Changed;
end;

procedure TGMMapOptions.SetZoomControl(const Value: Boolean);
begin
  if FZoomControl = Value then
    Exit;

  FZoomControl := Value;
  Changed;
end;

procedure TGMMapOptions.SetZoomControlOptions(const Value: TGMZoomControlOptions);
begin
  if not Assigned(Value) then
    Exit;

  FZoomControlOptions.Assign(Value);
  Changed;
end;

procedure TGMMapOptions.StreetViewControlOptionsChanged(Sender: TObject);
begin
  Changed;
end;

function TGMMapOptions.ToJavaScriptLiteral: string;
const
  GestureHandlingValues: array[TGMGestureHandling] of string = ('auto', 'cooperative', 'greedy', 'none');
begin
  Result := Format(
    '{ center: %s, zoom: %d, clickableIcons: %s, disableDefaultUI: %s, disableDoubleClickZoom: %s, fullscreenControl: %s, ' +
    'fullscreenControlOptions: %s, gestureHandling: %s, keyboardShortcuts: %s, mapTypeControl: %s, mapTypeControlOptions: %s, ' +
    'mapTypeId: %s, rotateControl: %s, rotateControlOptions: %s, scaleControl: %s, scaleControlOptions: %s, streetViewControl: %s, ' +
    'streetViewControlOptions: %s, zoomControl: %s, zoomControlOptions: %s',
    [
      Center.ToJavaScriptLiteral,
      Zoom,
      LowerCase(BoolToStr(ClickableIcons, True)),
      LowerCase(BoolToStr(DisableDefaultUI, True)),
      LowerCase(BoolToStr(DisableDoubleClickZoom, True)),
      LowerCase(BoolToStr(FullscreenControl, True)),
      FullscreenControlOptions.ToJavaScriptLiteral,
      QuotedStr(GestureHandlingValues[GestureHandling]),
      LowerCase(BoolToStr(KeyboardShortcuts, True)),
      LowerCase(BoolToStr(MapTypeControl, True)),
      MapTypeControlOptions.ToJavaScriptLiteral,
      BuildMapTypeIdValue,
      LowerCase(BoolToStr(RotateControl, True)),
      RotateControlOptions.ToJavaScriptLiteral,
      LowerCase(BoolToStr(ScaleControl, True)),
      ScaleControlOptions.ToJavaScriptLiteral,
      LowerCase(BoolToStr(StreetViewControl, True)),
      StreetViewControlOptions.ToJavaScriptLiteral,
      LowerCase(BoolToStr(ZoomControl, True)),
      ZoomControlOptions.ToJavaScriptLiteral
    ]
  );

  if BackgroundColorCss <> '' then
    Result := Result + Format(', backgroundColor: %s', [QuotedStr(BackgroundColorCss)]);

  if FHasColorScheme then
    Result := Result + Format(', colorScheme: %s', [BuildColorSchemeValue]);

  if FHasControlSize then
    Result := Result + Format(', controlSize: %d', [ControlSize]);

  if FHasCameraControl then
    Result := Result + Format(', cameraControl: %s, cameraControlOptions: %s', [
      LowerCase(BoolToStr(CameraControl, True)),
      CameraControlOptions.ToJavaScriptLiteral
    ]);

  if DraggableCursor <> '' then
    Result := Result + Format(', draggableCursor: %s', [QuotedStr(DraggableCursor)]);

  if DraggingCursor <> '' then
    Result := Result + Format(', draggingCursor: %s', [QuotedStr(DraggingCursor)]);

  if FHasHeading then
    Result := Result + Format(', heading: %s', [FloatToStr(FHeading, GMLibInvariantFormatSettings)]);

  if FHasHeadingInteractionEnabled then
    Result := Result + Format(', headingInteractionEnabled: %s', [LowerCase(BoolToStr(HeadingInteractionEnabled, True))]);

  if FHasIsFractionalZoomEnabled then
    Result := Result + Format(', isFractionalZoomEnabled: %s', [LowerCase(BoolToStr(IsFractionalZoomEnabled, True))]);

  if FHasMaxZoom then
    Result := Result + Format(', maxZoom: %d', [MaxZoom]);

  if FHasMinZoom then
    Result := Result + Format(', minZoom: %d', [MinZoom]);

  if FHasNoClear then
    Result := Result + Format(', noClear: %s', [LowerCase(BoolToStr(NoClear, True))]);

  if MapId <> '' then
    Result := Result + Format(', mapId: %s', [QuotedStr(MapId)]);

  if FHasRenderingType then
    Result := Result + Format(', renderingType: %s', [BuildRenderingTypeValue]);

  if Restriction.IsConfigured then
    Result := Result + Format(', restriction: %s', [Restriction.ToJavaScriptLiteral]);

  if FHasScrollwheel then
    Result := Result + Format(', scrollwheel: %s', [LowerCase(BoolToStr(Scrollwheel, True))]);

  if FHasTilt then
    Result := Result + Format(', tilt: %d', [Tilt]);

  if FHasTiltInteractionEnabled then
    Result := Result + Format(', tiltInteractionEnabled: %s', [LowerCase(BoolToStr(TiltInteractionEnabled, True))]);

  Result := Result + ' }';
end;

procedure TGMMapOptions.ZoomControlOptionsChanged(Sender: TObject);
begin
  Changed;
end;

end.






