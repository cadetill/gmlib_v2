{**
  @abstract(Initial OSM/MapLibre map component skeleton.)
}
unit uOSMLib.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  DB,
  SysUtils,
  StrUtils,
  fpjson,
  jsonparser,
{$ELSE}
  System.Classes,
  Data.DB,
  System.SysUtils,
  System.StrUtils,
  System.JSON,
{$ENDIF}
  uMapLib.Core.ApiObject,
  uMapLib.Core.Bridge,
  uMapLib.Core.Component,
  uMapLib.Core.LatLng,
  uMapLib.Core.Messages,
  uMapLib.Offline.RegionManager,
  uMapLib.Offline.Types,
  uMapLib.Offline.VectorRuntime,
  uMapLib.Core.Offline,
  uMapLib.Core.Types,
  uGMLib.Platform.Format,
  uGMLib.BootstrapAssets;

type
  TOSMMarkerKind = (mkStandard, mkPin, mkDot);
  TOSMMarkerPinCornerStyle = (mcsDefault, mcsSquare, mcsPill);
  {**
    @abstract(Variantes visuales de la familia de marker @code(Pin).)

    Define la silueta base del cuerpo del pin sin cambiar la familia de marker.
    El significado publico que se fija para v1 es:
    @unorderedList(
      @item(@code(msvDefault) - alias del aspecto @italic(classic) por defecto)
      @item(@code(msvClassic) - pin clasico con cuerpo redondeado y punta visible)
      @item(@code(msvPill) - cuerpo tipo capsula con punta mas compacta)
      @item(@code(msvTag) - cuerpo asimetrico estilo etiqueta con punta visible)
      @item(@code(msvBubble) - burbuja redondeada sin punta inferior)
    )
  }
  TOSMMarkerPinShapeVariant = (msvDefault, msvClassic, msvPill, msvTag, msvBubble);
  TOSMPopupContentType = (pctHtml, pctText);
  TOSMPopupPresetStyle = (ppsDefault, ppsNote, ppsWarning, ppsDark, ppsSuccess);
  TOSMMarkerStandardOptions = class;
  TOSMMarkerPinOptions = class;
  TOSMMarkerDotOptions = class;
  TOSMMarkerItem = class;
  TOSMMarkerItemClass = class of TOSMMarkerItem;
  TOSMPopupOptions = class;
  TOSMPopupItem = class;
  TOSMPopupItemClass = class of TOSMPopupItem;

  TOSMMarkerSeed = record
    Latitude: Double;
    Longitude: Double;
    Title: string;
    Visible: Boolean;
  end;

  TOSMMapReadyEvent = procedure(Sender: TObject) of object;
  TOSMMapSimpleEvent = procedure(Sender: TObject) of object;
  TOSMMapCoordinateEvent = procedure(Sender: TObject; ALatLng: TMapLibLatLng) of object;
  TOSMMarkerCoordinateEvent = procedure(Sender: TObject; ALatLng: TMapLibLatLng) of object;
  TOSMMapViewChangedEvent = procedure(Sender: TObject; ACenter: TMapLibLatLng; AZoom, ABearing, APitch: Double) of object;
  TOSMMapBoundsChangedEvent = procedure(Sender: TObject; ANorth, ASouth, AEast, AWest: Double) of object;
  TOSMMapErrorEvent = procedure(Sender: TObject; const AMessage: string) of object;
  TOSMMarkerItemChangedEvent = procedure(Sender: TObject; AMarker: TCollectionItem) of object;
  TOSMPopupItemChangedEvent = procedure(Sender: TObject; APopup: TCollectionItem) of object;

  {** @abstract(Opciones visuales base compartidas por los tipos de marker OSM.) }
  TOSMMarkerVisualOptions = class(TMapLibApiObject)
  private
    FAnchorX: Double;
    FAnchorY: Double;
    FScale: Double;
    FGlyphText: string;
    FGlyphTextColorCss: string;
    FOpacity: Double;
    FPopupEnabled: Boolean;
    FPopupText: string;
    FRotation: Double;
    FZIndex: Integer;
    procedure SetAnchorX(const Value: Double);
    procedure SetAnchorY(const Value: Double);
    procedure SetGlyphText(const Value: string);
    procedure SetGlyphTextColorCss(const Value: string);
    procedure SetOpacity(const Value: Double);
    procedure SetPopupEnabled(const Value: Boolean);
    procedure SetPopupText(const Value: string);
    procedure SetRotation(const Value: Double);
    procedure SetScale(const Value: Double);
    procedure SetZIndex(const Value: Integer);
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    property GlyphTextColorCss: string read FGlyphTextColorCss write SetGlyphTextColorCss;
  published
    {**
      @abstract(Ajuste fino horizontal del anclaje visual del marker.)

      No redefine el tipo de anchor del marker. Debe tratarse como un offset
      fino para corregir alineacion visual en casos concretos.
    }
    property AnchorX: Double read FAnchorX write SetAnchorX;
    {**
      @abstract(Ajuste fino vertical del anclaje visual del marker.)

      No redefine el tipo de anchor del marker. Debe tratarse como un offset
      fino para corregir alineacion visual en casos concretos.
    }
    property AnchorY: Double read FAnchorY write SetAnchorY;
    property GlyphText: string read FGlyphText write SetGlyphText;
    property Opacity: Double read FOpacity write SetOpacity;
    property PopupEnabled: Boolean read FPopupEnabled write SetPopupEnabled default True;
    {**
      @abstract(Texto legacy de conveniencia para popup simple del marker.)

      Se mantiene por compatibilidad y como atajo tecnico, pero la superficie
      popup recomendada para OSM es el slice dedicado @code(TOSMMap.Popups).
    }
    property PopupText: string read FPopupText write SetPopupText;
    property Rotation: Double read FRotation write SetRotation;
    property Scale: Double read FScale write SetScale;
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
  end;

  {** @abstract(Opciones específicas del marker estándar de MapLibre.) }
  TOSMMarkerStandardOptions = class(TOSMMarkerVisualOptions)
  private
    FBorderColorCss: string;
    FBorderWidth: Double;
    FColorCss: string;
    FGlyphFontSize: Integer;
    FGlyphOffsetX: Double;
    FGlyphOffsetY: Double;
    FHideDefaultCenterDot: Boolean;
    FShadowEnabled: Boolean;
    FUseDefaultMapLibreShape: Boolean;
    FUseGlyph: Boolean;
    procedure SetBorderColorCss(const Value: string);
    procedure SetBorderWidth(const Value: Double);
    procedure SetColorCss(const Value: string);
    procedure SetGlyphFontSize(const Value: Integer);
    procedure SetGlyphOffsetX(const Value: Double);
    procedure SetGlyphOffsetY(const Value: Double);
    procedure SetHideDefaultCenterDot(const Value: Boolean);
    procedure SetShadowEnabled(const Value: Boolean);
    procedure SetUseDefaultMapLibreShape(const Value: Boolean);
    procedure SetUseGlyph(const Value: Boolean);
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    property BorderColorCss: string read FBorderColorCss write SetBorderColorCss;
    property BorderWidth: Double read FBorderWidth write SetBorderWidth;
    property ColorCss: string read FColorCss write SetColorCss;
  published
    property GlyphFontSize: Integer read FGlyphFontSize write SetGlyphFontSize default 0;
    property GlyphOffsetX: Double read FGlyphOffsetX write SetGlyphOffsetX;
    property GlyphOffsetY: Double read FGlyphOffsetY write SetGlyphOffsetY;
    property HideDefaultCenterDot: Boolean read FHideDefaultCenterDot write SetHideDefaultCenterDot default False;
    {**
      @abstract(Toggle simple de sombra para el marker Standard.)

      La superficie avanzada de sombras se considera propia de @code(Pin) y
      @code(Dot). En @code(Standard) este flag se mantiene como compatibilidad
      ligera, no como familia avanzada de opciones visuales.
    }
    property ShadowEnabled: Boolean read FShadowEnabled write SetShadowEnabled default False;
    property UseDefaultMapLibreShape: Boolean read FUseDefaultMapLibreShape write SetUseDefaultMapLibreShape default True;
    property UseGlyph: Boolean read FUseGlyph write SetUseGlyph default True;
  end;

  {** @abstract(Opciones específicas del marker tipo pin de OSM.) }
  TOSMMarkerPinOptions = class(TOSMMarkerVisualOptions)
  private
    FBackgroundColorCss: string;
    FBorderColorCss: string;
    FBorderWidth: Double;
    FCornerStyle: TOSMMarkerPinCornerStyle;
    FGlyphFontSize: Integer;
    FMinHeight: Integer;
    FMinWidth: Integer;
    FPadding: Integer;
    FPointerLength: Integer;
    FPointerWidth: Integer;
    FShadowBlur: Double;
    FShadowColorCss: string;
    FShadowEnabled: Boolean;
    FShapeVariant: TOSMMarkerPinShapeVariant;
    procedure SetBackgroundColorCss(const Value: string);
    procedure SetBorderColorCss(const Value: string);
    procedure SetBorderWidth(const Value: Double);
    procedure SetCornerStyle(const Value: TOSMMarkerPinCornerStyle);
    procedure SetGlyphFontSize(const Value: Integer);
    procedure SetMinHeight(const Value: Integer);
    procedure SetMinWidth(const Value: Integer);
    procedure SetPadding(const Value: Integer);
    procedure SetPointerLength(const Value: Integer);
    procedure SetPointerWidth(const Value: Integer);
    procedure SetShadowBlur(const Value: Double);
    procedure SetShadowColorCss(const Value: string);
    procedure SetShadowEnabled(const Value: Boolean);
    procedure SetShapeVariant(const Value: TOSMMarkerPinShapeVariant);
  public
    procedure Assign(Source: TPersistent); override;
    class function CornerStyleToString(AValue: TOSMMarkerPinCornerStyle): string;
    class function ShapeVariantToString(AValue: TOSMMarkerPinShapeVariant): string;
    property BackgroundColorCss: string read FBackgroundColorCss write SetBackgroundColorCss;
    property BorderColorCss: string read FBorderColorCss write SetBorderColorCss;
    property ShadowColorCss: string read FShadowColorCss write SetShadowColorCss;
  published
    property BorderWidth: Double read FBorderWidth write SetBorderWidth;
    property CornerStyle: TOSMMarkerPinCornerStyle read FCornerStyle write SetCornerStyle default mcsDefault;
    property GlyphFontSize: Integer read FGlyphFontSize write SetGlyphFontSize default 0;
    property MinHeight: Integer read FMinHeight write SetMinHeight default 0;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property Padding: Integer read FPadding write SetPadding default 0;
    property PointerLength: Integer read FPointerLength write SetPointerLength default 0;
    property PointerWidth: Integer read FPointerWidth write SetPointerWidth default 0;
    property ShadowBlur: Double read FShadowBlur write SetShadowBlur;
    property ShadowEnabled: Boolean read FShadowEnabled write SetShadowEnabled default False;
    {**
      @abstract(Variante visual de la familia @code(Pin).)

      No cambia el tipo de marker, solo la silueta renderizada dentro de la
      familia @code(Pin). Para semantica publica estable:
      @unorderedList(
        @item(@code(msvDefault)/@code(msvClassic) - pin clasico)
        @item(@code(msvPill) - capsula con punta)
        @item(@code(msvTag) - etiqueta asimetrica)
        @item(@code(msvBubble) - burbuja sin punta)
      )
    }
    property ShapeVariant: TOSMMarkerPinShapeVariant read FShapeVariant write SetShapeVariant default msvDefault;
  end;

  {** @abstract(Opciones específicas del marker tipo dot de OSM.) }
  TOSMMarkerDotOptions = class(TOSMMarkerVisualOptions)
  private
    FBorderColorCss: string;
    FBorderWidth: Double;
    FColorCss: string;
    FDiameter: Double;
    FGlyphFontSize: Integer;
    FPulseColorCss: string;
    FPulseDuration: Double;
    FPulseEnabled: Boolean;
    FPulseRadius: Double;
    FRadius: Double;
    FShadowBlur: Double;
    FShadowColorCss: string;
    FShadowEnabled: Boolean;
    procedure SetBorderColorCss(const Value: string);
    procedure SetBorderWidth(const Value: Double);
    procedure SetColorCss(const Value: string);
    procedure SetDiameter(const Value: Double);
    procedure SetGlyphFontSize(const Value: Integer);
    procedure SetPulseColorCss(const Value: string);
    procedure SetPulseDuration(const Value: Double);
    procedure SetPulseEnabled(const Value: Boolean);
    procedure SetPulseRadius(const Value: Double);
    procedure SetRadius(const Value: Double);
    procedure SetShadowBlur(const Value: Double);
    procedure SetShadowColorCss(const Value: string);
    procedure SetShadowEnabled(const Value: Boolean);
  public
    procedure Assign(Source: TPersistent); override;
    property BorderColorCss: string read FBorderColorCss write SetBorderColorCss;
    property ColorCss: string read FColorCss write SetColorCss;
    property PulseColorCss: string read FPulseColorCss write SetPulseColorCss;
    property ShadowColorCss: string read FShadowColorCss write SetShadowColorCss;
  published
    property BorderWidth: Double read FBorderWidth write SetBorderWidth;
    property Diameter: Double read FDiameter write SetDiameter;
    property GlyphFontSize: Integer read FGlyphFontSize write SetGlyphFontSize default 0;
    property PulseDuration: Double read FPulseDuration write SetPulseDuration;
    property PulseEnabled: Boolean read FPulseEnabled write SetPulseEnabled default False;
    property PulseRadius: Double read FPulseRadius write SetPulseRadius;
    property Radius: Double read FRadius write SetRadius;
    property ShadowBlur: Double read FShadowBlur write SetShadowBlur;
    property ShadowEnabled: Boolean read FShadowEnabled write SetShadowEnabled default False;
  end;

  {** @abstract(Bounds geográficos simples usados por restricciones del mapa OSM.) }
  TOSMMapBounds = class(TMapLibApiObject)
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
    procedure Clear;
    procedure EndUpdate;
    function IsComplete: Boolean;
    function ToJsonLiteral: string;
  published
    property East: Double read FEast write SetEast stored IsEastStored;
    property North: Double read FNorth write SetNorth stored IsNorthStored;
    property South: Double read FSouth write SetSouth stored IsSouthStored;
    property West: Double read FWest write SetWest stored IsWestStored;
  end;

  TOSMMarkerItem = class(TCollectionItem)
  private
    FInitializing: Boolean;
    FUpdateCount: Integer;
    FChangePending: Boolean;
    FLat: Double;
    FLng: Double;
    FObjectId: TGMObjectId;
    FTitle: string;
    FVisible: Boolean;
    FDraggable: Boolean;
    FKind: TOSMMarkerKind;
    FStandardOptions: TOSMMarkerStandardOptions;
    FPinOptions: TOSMMarkerPinOptions;
    FDotOptions: TOSMMarkerDotOptions;
    FOnClick: TOSMMarkerCoordinateEvent;
    FOnDblClick: TOSMMarkerCoordinateEvent;
    FOnMouseEnter: TOSMMarkerCoordinateEvent;
    FOnMouseLeave: TOSMMarkerCoordinateEvent;
    FOnMouseDown: TOSMMarkerCoordinateEvent;
    FOnMouseUp: TOSMMarkerCoordinateEvent;
    FOnDragStart: TOSMMarkerCoordinateEvent;
    FOnDrag: TOSMMarkerCoordinateEvent;
    FOnDragEnd: TOSMMarkerCoordinateEvent;
    procedure Changed;
    procedure DotOptionsChanged(Sender: TObject);
    procedure SetDraggable(const Value: Boolean);
    procedure SetKind(const Value: TOSMMarkerKind);
    procedure SetLat(const Value: Double);
    procedure SetLng(const Value: Double);
    procedure SetObjectId(const Value: TGMObjectId);
    procedure SetDotOptions(const Value: TOSMMarkerDotOptions);
    procedure SetPinOptions(const Value: TOSMMarkerPinOptions);
    procedure SetStandardOptions(const Value: TOSMMarkerStandardOptions);
    procedure PinOptionsChanged(Sender: TObject);
    procedure StandardOptionsChanged(Sender: TObject);
    procedure SetTitle(const Value: string);
    procedure SetVisible(const Value: Boolean);
  protected
    function CreateStandardOptions: TOSMMarkerStandardOptions; virtual;
    function CreatePinOptions: TOSMMarkerPinOptions; virtual;
    function CreateDotOptions: TOSMMarkerDotOptions; virtual;
    function OSMMarkerKindToString(AKind: TOSMMarkerKind): string;
    function BuildVisualOptionsPayload: string;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure ApplyRuntimePosition(ALat, ALng: Double);
    procedure BeginUpdate;
    procedure EndUpdate;
    function BuildAddPayload: string;
    function BuildSetOptionsPayload: string;
  published
    property ObjectId: TGMObjectId read FObjectId write SetObjectId;
    property Lat: Double read FLat write SetLat;
    property Lng: Double read FLng write SetLng;
    property Title: string read FTitle write SetTitle;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Draggable: Boolean read FDraggable write SetDraggable default False;
    property Kind: TOSMMarkerKind read FKind write SetKind default mkStandard;
    property StandardOptions: TOSMMarkerStandardOptions read FStandardOptions write SetStandardOptions;
    property PinOptions: TOSMMarkerPinOptions read FPinOptions write SetPinOptions;
    property DotOptions: TOSMMarkerDotOptions read FDotOptions write SetDotOptions;
    property OnClick: TOSMMarkerCoordinateEvent read FOnClick write FOnClick;
    property OnDblClick: TOSMMarkerCoordinateEvent read FOnDblClick write FOnDblClick;
    property OnMouseEnter: TOSMMarkerCoordinateEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TOSMMarkerCoordinateEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseDown: TOSMMarkerCoordinateEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TOSMMarkerCoordinateEvent read FOnMouseUp write FOnMouseUp;
    property OnDragStart: TOSMMarkerCoordinateEvent read FOnDragStart write FOnDragStart;
    property OnDrag: TOSMMarkerCoordinateEvent read FOnDrag write FOnDrag;
    property OnDragEnd: TOSMMarkerCoordinateEvent read FOnDragEnd write FOnDragEnd;
  end;

  TOSMMarkers = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FOnItemChanged: TOSMMarkerItemChangedEvent;
    function GetItem(Index: Integer): TOSMMarkerItem;
    procedure DoChanged;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TOSMMarkerItemClass = nil);
    function Add: TOSMMarkerItem; reintroduce; overload;
    function Add(ALat, ALng: Double; const ATitle: string = ''): TOSMMarkerItem; overload;
    procedure Clear;
    function DeleteByObjectId(const AObjectId: TGMObjectId): Boolean;
    function FindByObjectId(const AObjectId: TGMObjectId): TOSMMarkerItem;
    procedure LoadFromArray(const AItems: array of TOSMMarkerSeed; AClearBeforeLoad: Boolean = True);
    procedure LoadFromCSV(const ACSVText: string; const ALatField, ALongField: string;
      const ATitleField: string = 'title'; const AVisibleField: string = 'visible';
      ADelimiter: Char = ','; AClearBeforeLoad: Boolean = True);
    procedure LoadFromDataSet(ADataSet: TDataSet; const ALatField, ALongField: string;
      const ATitleField: string = 'title'; const AVisibleField: string = 'visible';
      AClearBeforeLoad: Boolean = True);
    function ZoomToMarkers: Boolean;
    procedure NotifyItemChanged(AItem: TCollectionItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    property Items[Index: Integer]: TOSMMarkerItem read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnItemChanged: TOSMMarkerItemChangedEvent read FOnItemChanged write FOnItemChanged;
  end;

  {** @abstract(Opciones de un popup OSM/MapLibre.) }
  TOSMPopupOptions = class(TMapLibApiObject)
  private
    FCloseButton: Boolean;
    FCloseOnClick: Boolean;
    FCloseOnMove: Boolean;
    FContent: string;
    FContentType: TOSMPopupContentType;
    FMaxWidth: Integer;
    FPresetStyle: TOSMPopupPresetStyle;
    FPosition: TMapLibLatLng;
    FVisible: Boolean;
    procedure PositionChanged(Sender: TObject);
    procedure SetCloseButton(const Value: Boolean);
    procedure SetCloseOnClick(const Value: Boolean);
    procedure SetCloseOnMove(const Value: Boolean);
    procedure SetContent(const Value: string);
    procedure SetContentType(const Value: TOSMPopupContentType);
    procedure SetMaxWidth(const Value: Integer);
    procedure SetPresetStyle(const Value: TOSMPopupPresetStyle);
    procedure SetPosition(const Value: TMapLibLatLng);
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property CloseButton: Boolean read FCloseButton write SetCloseButton default True;
    property CloseOnClick: Boolean read FCloseOnClick write SetCloseOnClick default True;
    property CloseOnMove: Boolean read FCloseOnMove write SetCloseOnMove default False;
    property Content: string read FContent write SetContent;
    property ContentType: TOSMPopupContentType read FContentType write SetContentType default pctHtml;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 0;
    property PresetStyle: TOSMPopupPresetStyle read FPresetStyle write SetPresetStyle default ppsDefault;
    property Position: TMapLibLatLng read FPosition write SetPosition;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  {** @abstract(Item de popup OSM/MapLibre.) }
  TOSMPopupItem = class(TCollectionItem)
  private
    class var FNextObjectId: Integer;
  private
    FAnchorObjectId: TGMObjectId;
    FInitializing: Boolean;
    FUpdateCount: Integer;
    FChangePending: Boolean;
    FObjectId: TGMObjectId;
    FOnClose: TNotifyEvent;
    FOnOpen: TNotifyEvent;
    FOptions: TOSMPopupOptions;
    FUpdatingFromMapMessage: Boolean;
    procedure Changed;
    procedure OptionsChanged(Sender: TObject);
    procedure SetAnchorObjectId(const Value: TGMObjectId);
    procedure SetOptions(const Value: TOSMPopupOptions);
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreatePopupOptions: TOSMPopupOptions; virtual;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    function BuildAddPayload: string;
    function BuildSetOptionsPayload: string;
    procedure EndUpdate;
    procedure Open; overload;
    procedure OpenByObjectId(const AAnchorObjectId: TGMObjectId); overload;
    procedure Close;
    procedure ProcessMapEvent(const AEventName, APayload: string);
    property ObjectId: TGMObjectId read FObjectId;
  published
    property AnchorObjectId: TGMObjectId read FAnchorObjectId write SetAnchorObjectId;
    property Options: TOSMPopupOptions read FOptions write SetOptions;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnOpen: TNotifyEvent read FOnOpen write FOnOpen;
  end;

  {** @abstract(Coleccion de popups OSM/MapLibre.) }
  TOSMPopups = class(TOwnedCollection)
  private
    FCloseOthersBeforeOpen: Boolean;
    FOnChange: TNotifyEvent;
    FOnItemChanged: TOSMPopupItemChangedEvent;
    function GetItem(Index: Integer): TOSMPopupItem;
    procedure DoChanged;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TOSMPopupItemClass = nil);
    function Add: TOSMPopupItem; reintroduce;
    procedure CloseOthers(AExcept: TOSMPopupItem);
    function FindByObjectId(const AObjectId: TGMObjectId): TOSMPopupItem;
    procedure NotifyItemChanged(AItem: TCollectionItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    property Items[Index: Integer]: TOSMPopupItem read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnItemChanged: TOSMPopupItemChangedEvent read FOnItemChanged write FOnItemChanged;
  published
    property CloseOthersBeforeOpen: Boolean read FCloseOthersBeforeOpen write FCloseOthersBeforeOpen default False;
  end;

  TOSMMap = class(TMapLibComponent)
  private
    FActive: Boolean;
    // FOfflineMode: Boolean;
    FMapMode: TMapLibMapMode;
    FOfflinePolicy: TMapLibOfflinePolicy;
    // FOfflineTileProvider: TMapLibOfflineTileProvider;
    FBridge: IMapBridgeTransport;
    FOfflineRegionManager: IMapLibOfflineRegionManager;
    FOfflineStoragePath: string;
    FVectorRuntime: TMapLibVectorRuntime;
    FRemoteTileTemplate: string;
    FStyleTemplateFileName: string;
    FGlyphsRootPath: string;
    FCenterLat: Double;
    FCenterLng: Double;
    FMinZoom: Double;
    FMaxZoom: Double;
    FMinPitch: Double;
    FMaxPitch: Double;
    FMaxBounds: TOSMMapBounds;
    FMapId: TGMObjectId;
    FLastEventName: string;
    FRenderWorldCopies: Boolean;
    FDragPanEnabled: Boolean;
    FDragRotateEnabled: Boolean;
    FDoubleClickZoomEnabled: Boolean;
    FScrollZoomEnabled: Boolean;
    FKeyboardEnabled: Boolean;
    FTouchZoomRotateEnabled: Boolean;
    FTouchPitchEnabled: Boolean;
    FCooperativeGesturesEnabled: Boolean;
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
    FOnCooperativeGesturePrevented: TOSMMapSimpleEvent;
    FOnBoundsChanged: TOSMMapBoundsChangedEvent;
    FOnError: TOSMMapErrorEvent;
    
    // Eventos offline
    FOnOfflineDownloadProgress: TMapLibOfflineDownloadProgressEvent;
    FOnOfflineRegionReady: TMapLibOfflineRegionReadyEvent;
    FOnOfflineError: TMapLibOfflineErrorEvent;

    FMarkers: TOSMMarkers;
    FPopups: TOSMPopups;
    FStyleUrl: string;
    FMapLibreCssUrl: string;
    FMapLibreJsUrl: string;
    FZoom: Double;
    FBearing: Double;
    FPitch: Double;
    procedure SetActive(const Value: Boolean);
    procedure SetBridge(const Value: IMapBridgeTransport);
    procedure SetCenterLat(const Value: Double);
    procedure SetCenterLng(const Value: Double);
    procedure SetMinZoom(const Value: Double);
    procedure SetMaxZoom(const Value: Double);
    procedure SetMinPitch(const Value: Double);
    procedure SetMaxPitch(const Value: Double);
    procedure SetMaxBounds(const Value: TOSMMapBounds);
    procedure SetMapId(const Value: TGMObjectId);
    procedure SetStyleUrl(const Value: string);
    procedure SetOfflineStoragePath(const Value: string);
    procedure SetOfflinePolicy(const Value: TMapLibOfflinePolicy);
    procedure SetMapMode(const Value: TMapLibMapMode);
    procedure SetRemoteTileTemplate(const Value: string);
    procedure SetStyleTemplateFileName(const Value: string);
    procedure SetGlyphsRootPath(const Value: string);
    // procedure SetOfflineStyleUrl(const Value: string);
    // procedure SetOfflineRasterTilesUrlTemplate(const Value: string);
    // procedure SetOfflineTileJsonUrl(const Value: string);
    // procedure SetOfflineServerExecutable(const Value: string);
    // procedure SetOfflineServerPort(const Value: Integer);
    // procedure SetOfflineServerEnabled(const Value: Boolean);
    procedure SetMapLibreCssUrl(const Value: string);
    procedure SetMapLibreJsUrl(const Value: string);
    procedure SetBearing(const Value: Double);
    procedure SetPitch(const Value: Double);
    procedure SetDragPanEnabled(const Value: Boolean);
    procedure SetDragRotateEnabled(const Value: Boolean);
    procedure SetDoubleClickZoomEnabled(const Value: Boolean);
    procedure SetScrollZoomEnabled(const Value: Boolean);
    procedure SetKeyboardEnabled(const Value: Boolean);
    procedure SetTouchZoomRotateEnabled(const Value: Boolean);
    procedure SetTouchPitchEnabled(const Value: Boolean);
    procedure SetCooperativeGesturesEnabled(const Value: Boolean);
    procedure SetRenderWorldCopies(const Value: Boolean);
    // procedure SetOfflineMode(const Value: Boolean);
    // procedure SetOfflinePolicy(const Value: TMapLibOfflinePolicy);
    // procedure SetOfflineTileProvider(const Value: TMapLibOfflineTileProvider);
    // procedure SetOfflineRegionManager(const Value: IMapLibOfflineRegionManager);
    // procedure SetMapMode(const Value: TMapLibMapMode);
    procedure SetMarkers(const Value: TOSMMarkers);
    procedure SetPopups(const Value: TOSMPopups);
    procedure SetZoom(const Value: Double);
    procedure HandleOfflineDownloadProgress(Sender: TObject; const AJobId: string; APercent: Double; ABytesDone, ABytesTotal: Int64);
    procedure HandleOfflineRegionReady(Sender: TObject; const ARegionId: TMapLibOfflineRegionId);
    procedure HandleOfflineError(Sender: TObject; AErrorCode: Integer; const AUserMessage, ATechnicalMessage: string);
    procedure BridgeMessageReceived(Sender: TObject; const AEnvelope: TMapLibMessageEnvelope);
    function BuildSetViewPayload: string;
    function BuildSetOptionsPayload: string;
    function BuildSetStylePayload: string;
    function BuildMarkerAddEnvelope(AMarker: TOSMMarkerItem): TMapLibMessageEnvelope;
    function BuildPopupAddEnvelope(APopup: TOSMPopupItem): TMapLibMessageEnvelope;
    function CreateEnvelope(const AMessageType, APayload: string): TMapLibMessageEnvelope;
    procedure SyncViewToBridge;
    procedure SyncOptionsToBridge;
    procedure SyncMarkersToBridge;
    procedure SyncMarkerOptionsToBridge(AMarker: TOSMMarkerItem);
    procedure SyncPopupsToBridge;
    procedure SyncPopupOptionsToBridge(APopup: TOSMPopupItem);
    procedure MaxBoundsChanged(Sender: TObject);
    procedure MarkersChanged(Sender: TObject);
    procedure MarkerItemChanged(Sender: TObject; AMarker: TCollectionItem);
    procedure PopupsChanged(Sender: TObject);
    procedure PopupItemChanged(Sender: TObject; APopup: TCollectionItem);
    procedure DispatchMapEvent(const AEventName, APayload: string);
    procedure DispatchMarkerEvent(const AEventName, APayload: string);
    procedure DispatchPopupEvent(const AEventName, APayload: string);
    function TryGetLatLngFromPayload(const APayload: string; out ALatLng: TMapLibLatLng): Boolean;
    function TryGetMarkerClickFromPayload(const APayload: string; out AMarkerId: TGMObjectId;
      out ALatLng: TMapLibLatLng): Boolean;
    function TryGetPopupObjectIdFromPayload(const APayload: string; out APopupId: TGMObjectId): Boolean;
    function TryGetViewFromPayload(const APayload: string; out ACenter: TMapLibLatLng; out AZoom, ABearing, APitch: Double): Boolean;
    function TryGetBoundsFromPayload(const APayload: string; out ANorth, ASouth, AEast, AWest: Double): Boolean;
    function GetErrorMessageFromPayload(const APayload: string): string;
    procedure NotifyProtocolError(const AContext: string; const E: Exception);
  protected
    function CreateMarkers: TOSMMarkers; virtual;
    function CreatePopups: TOSMPopups; virtual;
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
    function GetRuntimeBaseUrl: string;
    // function ResolveOfflineStyleUrl: string;
    function ResolveMapLibreCssUrl: string;
    function ResolveMapLibreJsUrl: string;
    function ResolveActiveRegionFileName: string;
    function ResolveOfflineGlyphsRootPath: string;
    function ResolveOfflineStyleTemplateFileName(const AGlyphsRootPath: string): string;
    // function ResolveMapModeName: string;
    procedure PrepareOfflineRuntimeAssets;
    // function ResolveOfflineStyleRuntimeUrl: string;
    // function ResolveOfflineAssetsBaseUrl: string;
    // function ResolveLastOfflineSetupError: string;
    // procedure EnsureOfflineTileSourceReady;
    // procedure StopOfflineTileServer;
    property Bridge: IMapBridgeTransport read FBridge write SetBridge;
    property OfflineRegionManager: IMapLibOfflineRegionManager read FOfflineRegionManager;
    property VectorRuntime: TMapLibVectorRuntime read FVectorRuntime;
    property LastEventName: string read FLastEventName;
  published
    property Active: Boolean read FActive write SetActive default False;
    property OfflineStoragePath: string read FOfflineStoragePath write SetOfflineStoragePath;
    property MapMode: TMapLibMapMode read FMapMode write SetMapMode default omOnline;
    // property OfflineMode: Boolean read FOfflineMode write SetOfflineMode default False;
    property OfflinePolicy: TMapLibOfflinePolicy read FOfflinePolicy write SetOfflinePolicy
      default opPreferOffline;
    property RemoteTileTemplate: string read FRemoteTileTemplate write SetRemoteTileTemplate;
    property StyleTemplateFileName: string read FStyleTemplateFileName write SetStyleTemplateFileName;
    property GlyphsRootPath: string read FGlyphsRootPath write SetGlyphsRootPath;
    // property OfflineTileProvider: TMapLibOfflineTileProvider read FOfflineTileProvider
    //   write SetOfflineTileProvider default otpAuto;
    property CenterLat: Double read FCenterLat write SetCenterLat;
    property CenterLng: Double read FCenterLng write SetCenterLng;
    property MinZoom: Double read FMinZoom write SetMinZoom;
    property MaxZoom: Double read FMaxZoom write SetMaxZoom;
    property MinPitch: Double read FMinPitch write SetMinPitch;
    property MaxPitch: Double read FMaxPitch write SetMaxPitch;
    property MaxBounds: TOSMMapBounds read FMaxBounds write SetMaxBounds;
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
    property OnCooperativeGesturePrevented: TOSMMapSimpleEvent read FOnCooperativeGesturePrevented write FOnCooperativeGesturePrevented;
    property OnBoundsChanged: TOSMMapBoundsChangedEvent read FOnBoundsChanged write FOnBoundsChanged;
    property OnError: TOSMMapErrorEvent read FOnError write FOnError;
    property OnOfflineDownloadProgress: TMapLibOfflineDownloadProgressEvent read FOnOfflineDownloadProgress write FOnOfflineDownloadProgress;
    property OnOfflineRegionReady: TMapLibOfflineRegionReadyEvent read FOnOfflineRegionReady write FOnOfflineRegionReady;
    property OnOfflineError: TMapLibOfflineErrorEvent read FOnOfflineError write FOnOfflineError;
    property Markers: TOSMMarkers read FMarkers write SetMarkers;
    property Popups: TOSMPopups read FPopups write SetPopups;
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
    property RuntimeBaseUrl: string read GetRuntimeBaseUrl;
    property Bearing: Double read FBearing write SetBearing;
    property Pitch: Double read FPitch write SetPitch;
    property RenderWorldCopies: Boolean read FRenderWorldCopies write SetRenderWorldCopies default True;
    property DragPanEnabled: Boolean read FDragPanEnabled write SetDragPanEnabled default True;
    property DragRotateEnabled: Boolean read FDragRotateEnabled write SetDragRotateEnabled default True;
    property DoubleClickZoomEnabled: Boolean read FDoubleClickZoomEnabled write SetDoubleClickZoomEnabled default True;
    property ScrollZoomEnabled: Boolean read FScrollZoomEnabled write SetScrollZoomEnabled default True;
    property KeyboardEnabled: Boolean read FKeyboardEnabled write SetKeyboardEnabled default True;
    property TouchZoomRotateEnabled: Boolean read FTouchZoomRotateEnabled write SetTouchZoomRotateEnabled default True;
    property TouchPitchEnabled: Boolean read FTouchPitchEnabled write SetTouchPitchEnabled default True;
    property CooperativeGesturesEnabled: Boolean read FCooperativeGesturesEnabled write SetCooperativeGesturesEnabled default False;
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
{$IFNDEF FPC}
  System.IOUtils
{$ENDIF}
{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
  ,
{$ENDIF}
{$IFDEF FPC}
  WinInet
{$ELSE}
  Winapi.Windows,
  Winapi.WinInet
{$ENDIF}
{$ENDIF}
  ;

const
  DEFAULT_MAPLIBRE_STYLE_URL = 'https://tiles.openfreemap.org/styles/bright';
  DEFAULT_MAPLIBRE_CSS_URL = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.css';
  DEFAULT_MAPLIBRE_JS_URL = 'https://unpkg.com/maplibre-gl@5.6.2/dist/maplibre-gl.js';
  DEFAULT_MAPLIBRE_MIN_PITCH = 0.0;
  DEFAULT_MAPLIBRE_MAX_PITCH = 60.0;

function JsonEscape(const AValue: string): string;
begin
  Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
end;

procedure AppendOSMMapTrace(const AMessage: string);
{$IFDEF FPC}
var
  logLines: TStringList;
  logFileName: string;
begin
  try
    logFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'gmlib_lcl_hybrid_trace.log';
    logLines := TStringList.Create;
    try
      if FileExists(logFileName) then
        logLines.LoadFromFile(logFileName);
      logLines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' [OSMMap] ' + AMessage);
      logLines.SaveToFile(logFileName);
    finally
      logLines.Free;
    end;
  except
    // Logging must never break the runtime.
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

function SplitCsvLine(const ALine: string; ADelimiter: Char): TStrings;
begin
  Result := TStringList.Create;
  Result.StrictDelimiter := True;
  Result.Delimiter := ADelimiter;
  Result.QuoteChar := '"';
  Result.DelimitedText := ALine;
end;

function IndexOfText(const AStrings: TStrings; const AValue: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if not Assigned(AStrings) then
    Exit;

  for I := 0 to AStrings.Count - 1 do
    if SameText(Trim(AStrings[I]), AValue) then
      Exit(I);
end;

function TryParseMarkerVisible(const AValue: string; out AVisible: Boolean): Boolean;
begin
  Result := True;
  if SameText(Trim(AValue), '') then
  begin
    AVisible := True;
    Exit;
  end;

  if SameText(Trim(AValue), '1') or SameText(Trim(AValue), 'true') or
     SameText(Trim(AValue), 'yes') or SameText(Trim(AValue), 'y') then
  begin
    AVisible := True;
    Exit;
  end;

  if SameText(Trim(AValue), '0') or SameText(Trim(AValue), 'false') or
     SameText(Trim(AValue), 'no') or SameText(Trim(AValue), 'n') then
  begin
    AVisible := False;
    Exit;
  end;

  Result := False;
end;

{ TOSMMarkerVisualOptions }

constructor TOSMMarkerVisualOptions.Create;
begin
  inherited Create;
  FScale := 1;
  FOpacity := 1;
  FPopupEnabled := True;
  FGlyphTextColorCss := '#ffffff';
end;

procedure TOSMMarkerVisualOptions.Assign(Source: TPersistent);
begin
  if Source is TOSMMarkerVisualOptions then
  begin
    FAnchorX := TOSMMarkerVisualOptions(Source).AnchorX;
    FAnchorY := TOSMMarkerVisualOptions(Source).AnchorY;
    FScale := TOSMMarkerVisualOptions(Source).Scale;
    FGlyphText := TOSMMarkerVisualOptions(Source).GlyphText;
    FGlyphTextColorCss := TOSMMarkerVisualOptions(Source).GlyphTextColorCss;
    FOpacity := TOSMMarkerVisualOptions(Source).Opacity;
    FPopupEnabled := TOSMMarkerVisualOptions(Source).PopupEnabled;
    FPopupText := TOSMMarkerVisualOptions(Source).PopupText;
    FRotation := TOSMMarkerVisualOptions(Source).Rotation;
    FZIndex := TOSMMarkerVisualOptions(Source).ZIndex;
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

procedure TOSMMarkerVisualOptions.SetAnchorX(const Value: Double);
begin
  if FAnchorX = Value then
    Exit;
  FAnchorX := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetAnchorY(const Value: Double);
begin
  if FAnchorY = Value then
    Exit;
  FAnchorY := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetGlyphText(const Value: string);
begin
  if FGlyphText = Value then
    Exit;
  FGlyphText := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetGlyphTextColorCss(const Value: string);
begin
  if FGlyphTextColorCss = Value then
    Exit;
  FGlyphTextColorCss := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetOpacity(const Value: Double);
begin
  if FOpacity = Value then
    Exit;
  FOpacity := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetPopupEnabled(const Value: Boolean);
begin
  if FPopupEnabled = Value then
    Exit;
  FPopupEnabled := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetPopupText(const Value: string);
begin
  if FPopupText = Value then
    Exit;
  FPopupText := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetRotation(const Value: Double);
begin
  if FRotation = Value then
    Exit;
  FRotation := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetScale(const Value: Double);
begin
  if FScale = Value then
    Exit;
  FScale := Value;
  Changed;
end;

procedure TOSMMarkerVisualOptions.SetZIndex(const Value: Integer);
begin
  if FZIndex = Value then
    Exit;
  FZIndex := Value;
  Changed;
end;

{ TOSMMarkerStandardOptions }

constructor TOSMMarkerStandardOptions.Create;
begin
  inherited Create;
  FUseDefaultMapLibreShape := True;
  FUseGlyph := True;
end;

procedure TOSMMarkerStandardOptions.Assign(Source: TPersistent);
begin
  if Source is TOSMMarkerStandardOptions then
  begin
    inherited Assign(Source);
    FBorderColorCss := TOSMMarkerStandardOptions(Source).BorderColorCss;
    FBorderWidth := TOSMMarkerStandardOptions(Source).BorderWidth;
    FColorCss := TOSMMarkerStandardOptions(Source).ColorCss;
    FGlyphFontSize := TOSMMarkerStandardOptions(Source).GlyphFontSize;
    FGlyphOffsetX := TOSMMarkerStandardOptions(Source).GlyphOffsetX;
    FGlyphOffsetY := TOSMMarkerStandardOptions(Source).GlyphOffsetY;
    FHideDefaultCenterDot := TOSMMarkerStandardOptions(Source).HideDefaultCenterDot;
    FShadowEnabled := TOSMMarkerStandardOptions(Source).ShadowEnabled;
    FUseDefaultMapLibreShape := TOSMMarkerStandardOptions(Source).UseDefaultMapLibreShape;
    FUseGlyph := TOSMMarkerStandardOptions(Source).UseGlyph;
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

procedure TOSMMarkerStandardOptions.SetBorderColorCss(const Value: string);
begin
  if FBorderColorCss = Value then
    Exit;
  FBorderColorCss := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetBorderWidth(const Value: Double);
begin
  if FBorderWidth = Value then
    Exit;
  FBorderWidth := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetColorCss(const Value: string);
begin
  if FColorCss = Value then
    Exit;
  FColorCss := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetGlyphFontSize(const Value: Integer);
begin
  if FGlyphFontSize = Value then
    Exit;
  FGlyphFontSize := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetGlyphOffsetX(const Value: Double);
begin
  if FGlyphOffsetX = Value then
    Exit;
  FGlyphOffsetX := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetGlyphOffsetY(const Value: Double);
begin
  if FGlyphOffsetY = Value then
    Exit;
  FGlyphOffsetY := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetHideDefaultCenterDot(const Value: Boolean);
begin
  if FHideDefaultCenterDot = Value then
    Exit;
  FHideDefaultCenterDot := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetShadowEnabled(const Value: Boolean);
begin
  if FShadowEnabled = Value then
    Exit;
  FShadowEnabled := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetUseDefaultMapLibreShape(const Value: Boolean);
begin
  if FUseDefaultMapLibreShape = Value then
    Exit;
  FUseDefaultMapLibreShape := Value;
  Changed;
end;

procedure TOSMMarkerStandardOptions.SetUseGlyph(const Value: Boolean);
begin
  if FUseGlyph = Value then
    Exit;
  FUseGlyph := Value;
  Changed;
end;

{ TOSMMarkerPinOptions }

procedure TOSMMarkerPinOptions.Assign(Source: TPersistent);
begin
  if Source is TOSMMarkerPinOptions then
  begin
    inherited Assign(Source);
    FBackgroundColorCss := TOSMMarkerPinOptions(Source).BackgroundColorCss;
    FBorderColorCss := TOSMMarkerPinOptions(Source).BorderColorCss;
    FBorderWidth := TOSMMarkerPinOptions(Source).BorderWidth;
    FCornerStyle := TOSMMarkerPinOptions(Source).CornerStyle;
    FGlyphFontSize := TOSMMarkerPinOptions(Source).GlyphFontSize;
    FMinHeight := TOSMMarkerPinOptions(Source).MinHeight;
    FMinWidth := TOSMMarkerPinOptions(Source).MinWidth;
    FPadding := TOSMMarkerPinOptions(Source).Padding;
    FPointerLength := TOSMMarkerPinOptions(Source).PointerLength;
    FPointerWidth := TOSMMarkerPinOptions(Source).PointerWidth;
    FShadowBlur := TOSMMarkerPinOptions(Source).ShadowBlur;
    FShadowColorCss := TOSMMarkerPinOptions(Source).ShadowColorCss;
    FShadowEnabled := TOSMMarkerPinOptions(Source).ShadowEnabled;
    FShapeVariant := TOSMMarkerPinOptions(Source).ShapeVariant;
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

class function TOSMMarkerPinOptions.CornerStyleToString(AValue: TOSMMarkerPinCornerStyle): string;
begin
  case AValue of
    mcsSquare:
      Result := 'square';
    mcsPill:
      Result := 'pill';
  else
    Result := '';
  end;
end;

class function TOSMMarkerPinOptions.ShapeVariantToString(AValue: TOSMMarkerPinShapeVariant): string;
begin
  case AValue of
    msvClassic:
      Result := 'classic';
    msvPill:
      Result := 'pill';
    msvTag:
      Result := 'tag';
    msvBubble:
      Result := 'bubble';
  else
    Result := '';
  end;
end;

function OSMPopupPresetStyleToCssClass(AValue: TOSMPopupPresetStyle): string;
begin
  case AValue of
    ppsNote:
      Result := 'osm-popup-note';
    ppsWarning:
      Result := 'osm-popup-warning';
    ppsDark:
      Result := 'osm-popup-dark';
    ppsSuccess:
      Result := 'osm-popup-success';
  else
    Result := '';
  end;
end;

function OSMPopupContentTypeToString(AValue: TOSMPopupContentType): string;
begin
  case AValue of
    pctText:
      Result := 'text';
  else
    Result := 'html';
  end;
end;

procedure TOSMMarkerPinOptions.SetBackgroundColorCss(const Value: string);
begin
  if FBackgroundColorCss = Value then
    Exit;
  FBackgroundColorCss := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetBorderColorCss(const Value: string);
begin
  if FBorderColorCss = Value then
    Exit;
  FBorderColorCss := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetBorderWidth(const Value: Double);
begin
  if FBorderWidth = Value then
    Exit;
  FBorderWidth := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetCornerStyle(const Value: TOSMMarkerPinCornerStyle);
begin
  if FCornerStyle = Value then
    Exit;
  FCornerStyle := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetGlyphFontSize(const Value: Integer);
begin
  if FGlyphFontSize = Value then
    Exit;
  FGlyphFontSize := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetMinHeight(const Value: Integer);
begin
  if FMinHeight = Value then
    Exit;
  FMinHeight := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetMinWidth(const Value: Integer);
begin
  if FMinWidth = Value then
    Exit;
  FMinWidth := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetPadding(const Value: Integer);
begin
  if FPadding = Value then
    Exit;
  FPadding := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetPointerLength(const Value: Integer);
begin
  if FPointerLength = Value then
    Exit;
  FPointerLength := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetPointerWidth(const Value: Integer);
begin
  if FPointerWidth = Value then
    Exit;
  FPointerWidth := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetShadowBlur(const Value: Double);
begin
  if FShadowBlur = Value then
    Exit;
  FShadowBlur := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetShadowColorCss(const Value: string);
begin
  if FShadowColorCss = Value then
    Exit;
  FShadowColorCss := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetShadowEnabled(const Value: Boolean);
begin
  if FShadowEnabled = Value then
    Exit;
  FShadowEnabled := Value;
  Changed;
end;

procedure TOSMMarkerPinOptions.SetShapeVariant(const Value: TOSMMarkerPinShapeVariant);
begin
  if FShapeVariant = Value then
    Exit;
  FShapeVariant := Value;
  Changed;
end;

{ TOSMMarkerDotOptions }

procedure TOSMMarkerDotOptions.Assign(Source: TPersistent);
begin
  if Source is TOSMMarkerDotOptions then
  begin
    inherited Assign(Source);
    FBorderColorCss := TOSMMarkerDotOptions(Source).BorderColorCss;
    FBorderWidth := TOSMMarkerDotOptions(Source).BorderWidth;
    FColorCss := TOSMMarkerDotOptions(Source).ColorCss;
    FDiameter := TOSMMarkerDotOptions(Source).Diameter;
    FGlyphFontSize := TOSMMarkerDotOptions(Source).GlyphFontSize;
    FPulseColorCss := TOSMMarkerDotOptions(Source).PulseColorCss;
    FPulseDuration := TOSMMarkerDotOptions(Source).PulseDuration;
    FPulseEnabled := TOSMMarkerDotOptions(Source).PulseEnabled;
    FPulseRadius := TOSMMarkerDotOptions(Source).PulseRadius;
    FRadius := TOSMMarkerDotOptions(Source).Radius;
    FShadowBlur := TOSMMarkerDotOptions(Source).ShadowBlur;
    FShadowColorCss := TOSMMarkerDotOptions(Source).ShadowColorCss;
    FShadowEnabled := TOSMMarkerDotOptions(Source).ShadowEnabled;
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

procedure TOSMMarkerDotOptions.SetBorderColorCss(const Value: string);
begin
  if FBorderColorCss = Value then
    Exit;
  FBorderColorCss := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetBorderWidth(const Value: Double);
begin
  if FBorderWidth = Value then
    Exit;
  FBorderWidth := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetColorCss(const Value: string);
begin
  if FColorCss = Value then
    Exit;
  FColorCss := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetDiameter(const Value: Double);
begin
  if FDiameter = Value then
    Exit;
  FDiameter := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetGlyphFontSize(const Value: Integer);
begin
  if FGlyphFontSize = Value then
    Exit;
  FGlyphFontSize := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetPulseColorCss(const Value: string);
begin
  if FPulseColorCss = Value then
    Exit;
  FPulseColorCss := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetPulseDuration(const Value: Double);
begin
  if FPulseDuration = Value then
    Exit;
  FPulseDuration := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetPulseEnabled(const Value: Boolean);
begin
  if FPulseEnabled = Value then
    Exit;
  FPulseEnabled := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetPulseRadius(const Value: Double);
begin
  if FPulseRadius = Value then
    Exit;
  FPulseRadius := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetRadius(const Value: Double);
begin
  if FRadius = Value then
    Exit;
  FRadius := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetShadowBlur(const Value: Double);
begin
  if FShadowBlur = Value then
    Exit;
  FShadowBlur := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetShadowColorCss(const Value: string);
begin
  if FShadowColorCss = Value then
    Exit;
  FShadowColorCss := Value;
  Changed;
end;

procedure TOSMMarkerDotOptions.SetShadowEnabled(const Value: Boolean);
begin
  if FShadowEnabled = Value then
    Exit;
  FShadowEnabled := Value;
  Changed;
end;

{ TOSMMapBounds }

procedure TOSMMapBounds.Assign(Source: TPersistent);
begin
  if Source is TOSMMapBounds then
  begin
    BeginUpdate;
    try
      FEast := TOSMMapBounds(Source).FEast;
      FNorth := TOSMMapBounds(Source).FNorth;
      FSouth := TOSMMapBounds(Source).FSouth;
      FWest := TOSMMapBounds(Source).FWest;
      FHasEast := TOSMMapBounds(Source).FHasEast;
      FHasNorth := TOSMMapBounds(Source).FHasNorth;
      FHasSouth := TOSMMapBounds(Source).FHasSouth;
      FHasWest := TOSMMapBounds(Source).FHasWest;
      Changed;
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited;
end;

procedure TOSMMapBounds.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TOSMMapBounds.Clear;
begin
  BeginUpdate;
  try
    FEast := 0;
    FNorth := 0;
    FSouth := 0;
    FWest := 0;
    FHasEast := False;
    FHasNorth := False;
    FHasSouth := False;
    FHasWest := False;
    Changed;
  finally
    EndUpdate;
  end;
end;

procedure TOSMMapBounds.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited;
end;

procedure TOSMMapBounds.EndUpdate;
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

function TOSMMapBounds.IsComplete: Boolean;
begin
  Result := FHasNorth and FHasSouth and FHasEast and FHasWest;
end;

function TOSMMapBounds.IsEastStored: Boolean;
begin
  Result := FHasEast;
end;

function TOSMMapBounds.IsNorthStored: Boolean;
begin
  Result := FHasNorth;
end;

function TOSMMapBounds.IsSouthStored: Boolean;
begin
  Result := FHasSouth;
end;

function TOSMMapBounds.IsWestStored: Boolean;
begin
  Result := FHasWest;
end;

procedure TOSMMapBounds.SetEast(const Value: Double);
begin
  FEast := Value;
  FHasEast := True;
  Changed;
end;

procedure TOSMMapBounds.SetNorth(const Value: Double);
begin
  FNorth := Value;
  FHasNorth := True;
  Changed;
end;

procedure TOSMMapBounds.SetSouth(const Value: Double);
begin
  FSouth := Value;
  FHasSouth := True;
  Changed;
end;

procedure TOSMMapBounds.SetWest(const Value: Double);
begin
  FWest := Value;
  FHasWest := True;
  Changed;
end;

function TOSMMapBounds.ToJsonLiteral: string;
begin
  if not IsComplete then
    Exit('null');

  Result := Format(
    '{"north":%.15g,"south":%.15g,"east":%.15g,"west":%.15g}',
    [FNorth, FSouth, FEast, FWest],
    GMLibInvariantFormatSettings
  );
end;

function BuildDefaultOfflineStoragePath: string;
begin
{$IFDEF FPC}
  Result := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) + 'GMLib' + PathDelim + 'OSM';
{$ELSE}
  Result := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'GMLib'), 'OSM');
{$ENDIF}
end;

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

{ TOSMMarkerItem }

constructor TOSMMarkerItem.Create(ACollection: TCollection);
begin
  FInitializing := True;
  inherited Create(ACollection);
  FVisible := True;
  FDraggable := False;
  FKind := mkStandard;
  FStandardOptions := CreateStandardOptions;
  FStandardOptions.Owner := Self;
{$IFDEF FPC}
  FStandardOptions.OnChange := @StandardOptionsChanged;
{$ELSE}
  FStandardOptions.OnChange := StandardOptionsChanged;
{$ENDIF}
  FPinOptions := CreatePinOptions;
  FPinOptions.Owner := Self;
{$IFDEF FPC}
  FPinOptions.OnChange := @PinOptionsChanged;
{$ELSE}
  FPinOptions.OnChange := PinOptionsChanged;
{$ENDIF}
  FDotOptions := CreateDotOptions;
  FDotOptions.Owner := Self;
{$IFDEF FPC}
  FDotOptions.OnChange := @DotOptionsChanged;
{$ELSE}
  FDotOptions.OnChange := DotOptionsChanged;
{$ENDIF}
  FInitializing := False;
end;

destructor TOSMMarkerItem.Destroy;
begin
  FDotOptions.Free;
  FPinOptions.Free;
  FStandardOptions.Free;
  inherited Destroy;
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
    FDraggable := SourceMarker.Draggable;
    FKind := SourceMarker.Kind;
    FStandardOptions.Assign(SourceMarker.StandardOptions);
    FPinOptions.Assign(SourceMarker.PinOptions);
    FDotOptions.Assign(SourceMarker.DotOptions);
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

procedure TOSMMarkerItem.ApplyRuntimePosition(ALat, ALng: Double);
begin
  FLat := ALat;
  FLng := ALng;
end;

function TOSMMarkerItem.CreateStandardOptions: TOSMMarkerStandardOptions;
begin
  Result := TOSMMarkerStandardOptions.Create;
end;

function TOSMMarkerItem.CreatePinOptions: TOSMMarkerPinOptions;
begin
  Result := TOSMMarkerPinOptions.Create;
end;

function TOSMMarkerItem.CreateDotOptions: TOSMMarkerDotOptions;
begin
  Result := TOSMMarkerDotOptions.Create;
end;

function TOSMMarkerItem.OSMMarkerKindToString(AKind: TOSMMarkerKind): string;
begin
  case AKind of
    mkPin:
      Result := 'pin';
    mkDot:
      Result := 'dot';
  else
    Result := 'standard';
  end;
end;

function TOSMMarkerItem.BuildVisualOptionsPayload: string;
begin
  case FKind of
    mkPin:
      Result := Format(
        '"backgroundColor":"%s","borderColor":"%s","borderWidth":%.15g,' +
        '"shapeVariant":"%s","cornerStyle":"%s",' +
        '"scale":%.15g,"glyphText":"%s","glyphTextColor":"%s","glyphFontSize":%d,' +
        '"opacity":%.15g,"zIndex":%d,"rotation":%.15g,"anchorX":%.15g,"anchorY":%.15g,' +
        '"popupEnabled":%s,"popupText":"%s",' +
        '"padding":%d,"minWidth":%d,"minHeight":%d,' +
        '"pointerLength":%d,"pointerWidth":%d,' +
        '"shadowEnabled":%s,"shadowColor":"%s","shadowBlur":%.15g,' +
        '"hideDefaultCenterDot":false,"useDefaultMapLibreShape":false,"useGlyph":true,' +
        '"glyphOffsetX":0,"glyphOffsetY":0,' +
        '"radius":0,"diameter":0,"pulseEnabled":false,"pulseColor":"","pulseRadius":0,"pulseDuration":0',
        [
          JsonEscape(FPinOptions.BackgroundColorCss),
          JsonEscape(FPinOptions.BorderColorCss),
          FPinOptions.BorderWidth,
          JsonEscape(TOSMMarkerPinOptions.ShapeVariantToString(FPinOptions.ShapeVariant)),
          JsonEscape(TOSMMarkerPinOptions.CornerStyleToString(FPinOptions.CornerStyle)),
          FPinOptions.Scale,
          JsonEscape(FPinOptions.GlyphText),
          JsonEscape(FPinOptions.GlyphTextColorCss),
          FPinOptions.GlyphFontSize,
          FPinOptions.Opacity,
          FPinOptions.ZIndex,
          FPinOptions.Rotation,
          FPinOptions.AnchorX,
          FPinOptions.AnchorY,
          LowerCase(BoolToStr(FPinOptions.PopupEnabled, True)),
          JsonEscape(FPinOptions.PopupText),
          FPinOptions.Padding,
          FPinOptions.MinWidth,
          FPinOptions.MinHeight,
          FPinOptions.PointerLength,
          FPinOptions.PointerWidth,
          LowerCase(BoolToStr(FPinOptions.ShadowEnabled, True)),
          JsonEscape(FPinOptions.ShadowColorCss),
          FPinOptions.ShadowBlur
        ],
        GMLibInvariantFormatSettings
      );
    mkDot:
      Result := Format(
        '"color":"%s","borderColor":"%s","borderWidth":%.15g,' +
        '"scale":%.15g,"glyphText":"%s","glyphTextColor":"%s","glyphFontSize":%d,' +
        '"opacity":%.15g,"zIndex":%d,"rotation":%.15g,"anchorX":%.15g,"anchorY":%.15g,' +
        '"popupEnabled":%s,"popupText":"%s",' +
        '"shadowEnabled":%s,"shadowColor":"%s","shadowBlur":%.15g,' +
        '"hideDefaultCenterDot":false,"useDefaultMapLibreShape":false,"useGlyph":true,' +
        '"glyphOffsetX":0,"glyphOffsetY":0,' +
        '"shapeVariant":"","cornerStyle":"","padding":0,"minWidth":0,"minHeight":0,' +
        '"pointerLength":0,"pointerWidth":0,' +
        '"radius":%.15g,"diameter":%.15g,' +
        '"pulseEnabled":%s,"pulseColor":"%s","pulseRadius":%.15g,"pulseDuration":%.15g',
        [
          JsonEscape(FDotOptions.ColorCss),
          JsonEscape(FDotOptions.BorderColorCss),
          FDotOptions.BorderWidth,
          FDotOptions.Scale,
          JsonEscape(FDotOptions.GlyphText),
          JsonEscape(FDotOptions.GlyphTextColorCss),
          FDotOptions.GlyphFontSize,
          FDotOptions.Opacity,
          FDotOptions.ZIndex,
          FDotOptions.Rotation,
          FDotOptions.AnchorX,
          FDotOptions.AnchorY,
          LowerCase(BoolToStr(FDotOptions.PopupEnabled, True)),
          JsonEscape(FDotOptions.PopupText),
          LowerCase(BoolToStr(FDotOptions.ShadowEnabled, True)),
          JsonEscape(FDotOptions.ShadowColorCss),
          FDotOptions.ShadowBlur,
          FDotOptions.Radius,
          FDotOptions.Diameter,
          LowerCase(BoolToStr(FDotOptions.PulseEnabled, True)),
          JsonEscape(FDotOptions.PulseColorCss),
          FDotOptions.PulseRadius,
          FDotOptions.PulseDuration
        ],
        GMLibInvariantFormatSettings
      );
  else
    Result := Format(
      '"color":"%s","borderColor":"%s","borderWidth":%.15g,' +
      '"scale":%.15g,"glyphText":"%s","glyphTextColor":"%s","glyphFontSize":%d,' +
      '"opacity":%.15g,"zIndex":%d,"rotation":%.15g,"anchorX":%.15g,"anchorY":%.15g,' +
      '"popupEnabled":%s,"popupText":"%s",' +
      '"hideDefaultCenterDot":%s,"useDefaultMapLibreShape":%s,"useGlyph":%s,' +
      '"glyphOffsetX":%.15g,"glyphOffsetY":%.15g,' +
      '"shadowEnabled":%s,"shadowColor":"","shadowBlur":0,' +
      '"backgroundColor":"","shapeVariant":"","cornerStyle":"","padding":0,"minWidth":0,"minHeight":0,' +
      '"pointerLength":0,"pointerWidth":0,' +
      '"radius":0,"diameter":0,"pulseEnabled":false,"pulseColor":"","pulseRadius":0,"pulseDuration":0',
      [
        JsonEscape(FStandardOptions.ColorCss),
        JsonEscape(FStandardOptions.BorderColorCss),
        FStandardOptions.BorderWidth,
        FStandardOptions.Scale,
        JsonEscape(FStandardOptions.GlyphText),
        JsonEscape(FStandardOptions.GlyphTextColorCss),
        FStandardOptions.GlyphFontSize,
        FStandardOptions.Opacity,
        FStandardOptions.ZIndex,
        FStandardOptions.Rotation,
        FStandardOptions.AnchorX,
        FStandardOptions.AnchorY,
        LowerCase(BoolToStr(FStandardOptions.PopupEnabled, True)),
        JsonEscape(FStandardOptions.PopupText),
        LowerCase(BoolToStr(FStandardOptions.HideDefaultCenterDot, True))
          ,
        LowerCase(BoolToStr(FStandardOptions.UseDefaultMapLibreShape, True)),
        LowerCase(BoolToStr(FStandardOptions.UseGlyph, True)),
        FStandardOptions.GlyphOffsetX,
        FStandardOptions.GlyphOffsetY,
        LowerCase(BoolToStr(FStandardOptions.ShadowEnabled, True))
      ],
      GMLibInvariantFormatSettings
    );
  end;
end;

function TOSMMarkerItem.BuildAddPayload: string;
begin
  Result := Format(
    '{"objectId":"%s","lat":%.15g,"lng":%.15g,"title":"%s","visible":%s,' +
    '"draggable":%s,%s,"kind":"%s"}',
    [
      JsonEscape(string(FObjectId)),
      FLat,
      FLng,
      JsonEscape(FTitle),
      LowerCase(BoolToStr(FVisible, True)),
      LowerCase(BoolToStr(FDraggable, True)),
      BuildVisualOptionsPayload,
      OSMMarkerKindToString(FKind)
    ],
    GMLibInvariantFormatSettings
  );
end;

function TOSMMarkerItem.BuildSetOptionsPayload: string;
begin
  Result := Format(
    '{"objectId":"%s","lat":%.15g,"lng":%.15g,"title":"%s","visible":%s,' +
    '"draggable":%s,%s,"kind":"%s"}',
    [
      JsonEscape(string(FObjectId)),
      FLat,
      FLng,
      JsonEscape(FTitle),
      LowerCase(BoolToStr(FVisible, True)),
      LowerCase(BoolToStr(FDraggable, True)),
      BuildVisualOptionsPayload,
      OSMMarkerKindToString(FKind)
    ],
    GMLibInvariantFormatSettings
  );
end;

procedure TOSMMarkerItem.Changed;
begin
  if FInitializing or (FUpdateCount > 0) or
     not Assigned(FStandardOptions) or not Assigned(FPinOptions) or not Assigned(FDotOptions) then
  begin
    if FUpdateCount > 0 then
      FChangePending := True;
    Exit;
  end;
  if Collection is TOSMMarkers then
    TOSMMarkers(Collection).NotifyItemChanged(Self);
end;

procedure TOSMMarkerItem.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TOSMMarkerItem.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FChangePending then
  begin
    FChangePending := False;
    Changed;
  end;
end;

procedure TOSMMarkerItem.DotOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TOSMMarkerItem.SetDraggable(const Value: Boolean);
begin
  if FDraggable = Value then
    Exit;
  FDraggable := Value;
  Changed;
end;

procedure TOSMMarkerItem.SetKind(const Value: TOSMMarkerKind);
begin
  if FKind = Value then
    Exit;
  FKind := Value;
  Changed;
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

procedure TOSMMarkerItem.SetDotOptions(const Value: TOSMMarkerDotOptions);
begin
  if not Assigned(Value) then
    Exit;
  FDotOptions.Assign(Value);
end;

procedure TOSMMarkerItem.SetPinOptions(const Value: TOSMMarkerPinOptions);
begin
  if not Assigned(Value) then
    Exit;
  FPinOptions.Assign(Value);
end;

procedure TOSMMarkerItem.SetStandardOptions(const Value: TOSMMarkerStandardOptions);
begin
  if not Assigned(Value) then
    Exit;
  FStandardOptions.Assign(Value);
end;

procedure TOSMMarkerItem.PinOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TOSMMarkerItem.StandardOptionsChanged(Sender: TObject);
begin
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

constructor TOSMMarkers.Create(AOwner: TPersistent; AItemClass: TOSMMarkerItemClass);
begin
  if not Assigned(AItemClass) then
    AItemClass := TOSMMarkerItem;
  inherited Create(AOwner, AItemClass);
end;

function TOSMMarkers.Add: TOSMMarkerItem;
begin
  BeginUpdate;
  try
    Result := TOSMMarkerItem(inherited Add);
    if Result.ObjectId = '' then
      Result.FObjectId := TGMObjectId(Format('osm_marker_%d', [Result.Index + 1]));
  finally
    EndUpdate;
  end;
end;

function TOSMMarkers.Add(ALat, ALng: Double; const ATitle: string): TOSMMarkerItem;
begin
{$IFDEF FPC}
  Result := nil;
{$ENDIF}
  BeginUpdate;
  try
    Result := TOSMMarkerItem(inherited Add);
    if Assigned(Result) then
    begin
      if Result.ObjectId = '' then
        Result.FObjectId := TGMObjectId(Format('osm_marker_%d', [Result.Index + 1]));
      Result.FLat := ALat;
      Result.FLng := ALng;
      Result.FTitle := ATitle;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TOSMMarkers.LoadFromArray(const AItems: array of TOSMMarkerSeed; AClearBeforeLoad: Boolean);
var
  I: Integer;
  Marker: TOSMMarkerItem;
begin
  BeginUpdate;
  try
    if AClearBeforeLoad then
      Clear;

    for I := Low(AItems) to High(AItems) do
    begin
      Marker := Add(AItems[I].Latitude, AItems[I].Longitude, AItems[I].Title);
      Marker.Visible := AItems[I].Visible;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TOSMMarkers.LoadFromCSV(const ACSVText: string; const ALatField, ALongField: string;
  const ATitleField, AVisibleField: string; ADelimiter: Char; AClearBeforeLoad: Boolean);
var
  Lines: TStringList;
  HeaderFields: TStrings;
  RowFields: TStrings;
  HeaderLine: string;
  LatIndex: Integer;
  LngIndex: Integer;
  TitleIndex: Integer;
  VisibleIndex: Integer;
  Row: Integer;
  Lat: Double;
  Lng: Double;
  Title: string;
  Visible: Boolean;
  Marker: TOSMMarkerItem;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := ACSVText;
    if Lines.Count = 0 then
      Exit;

    HeaderLine := Trim(Lines[0]);
    if HeaderLine = '' then
      Exit;

    HeaderFields := SplitCsvLine(HeaderLine, ADelimiter);
    try
      LatIndex := IndexOfText(HeaderFields, ALatField);
      LngIndex := IndexOfText(HeaderFields, ALongField);
      TitleIndex := -1;
      VisibleIndex := -1;
      if ATitleField <> '' then
        TitleIndex := IndexOfText(HeaderFields, ATitleField);
      if AVisibleField <> '' then
        VisibleIndex := IndexOfText(HeaderFields, AVisibleField);

      if (LatIndex < 0) or (LngIndex < 0) then
        Exit;

      BeginUpdate;
      try
        if AClearBeforeLoad then
          Clear;

        for Row := 1 to Lines.Count - 1 do
        begin
          if Trim(Lines[Row]) = '' then
            Continue;

          RowFields := SplitCsvLine(Lines[Row], ADelimiter);
          try
            if (LatIndex >= RowFields.Count) or (LngIndex >= RowFields.Count) then
              Continue;

            if not TryStrToFloat(Trim(RowFields[LatIndex]), Lat, GMLibInvariantFormatSettings) then
              Continue;

            if not TryStrToFloat(Trim(RowFields[LngIndex]), Lng, GMLibInvariantFormatSettings) then
              Continue;

            Title := '';
            if (TitleIndex >= 0) and (TitleIndex < RowFields.Count) then
              Title := Trim(RowFields[TitleIndex]);

            Visible := True;
            if (VisibleIndex >= 0) and (VisibleIndex < RowFields.Count) then
              TryParseMarkerVisible(RowFields[VisibleIndex], Visible);

            Marker := Add(Lat, Lng, Title);
            Marker.Visible := Visible;
          finally
            RowFields.Free;
          end;
        end;
      finally
        EndUpdate;
      end;
    finally
      HeaderFields.Free;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TOSMMarkers.LoadFromDataSet(ADataSet: TDataSet; const ALatField, ALongField: string;
  const ATitleField, AVisibleField: string; AClearBeforeLoad: Boolean);
var
  Lat: Double;
  Lng: Double;
  Title: string;
  Visible: Boolean;
  Marker: TOSMMarkerItem;
begin
  if not Assigned(ADataSet) or (not ADataSet.Active) then
    Exit;

  BeginUpdate;
  try
    if AClearBeforeLoad then
      Clear;

    ADataSet.DisableControls;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        if not TryStrToFloat(Trim(ADataSet.FieldByName(ALatField).AsString), Lat, GMLibInvariantFormatSettings) then
        begin
          ADataSet.Next;
          Continue;
        end;

        if not TryStrToFloat(Trim(ADataSet.FieldByName(ALongField).AsString), Lng, GMLibInvariantFormatSettings) then
        begin
          ADataSet.Next;
          Continue;
        end;

        Title := '';
        if ATitleField <> '' then
          Title := Trim(ADataSet.FieldByName(ATitleField).AsString);

        Visible := True;
        if AVisibleField <> '' then
          TryParseMarkerVisible(ADataSet.FieldByName(AVisibleField).AsString, Visible);

        Marker := Add(Lat, Lng, Title);
        Marker.Visible := Visible;

        ADataSet.Next;
      end;
    finally
      ADataSet.EnableControls;
    end;
  finally
    EndUpdate;
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
  if (Item is TOSMMarkerItem) and TOSMMarkerItem(Item).FInitializing then
    Exit;
  DoChanged;
end;

procedure TOSMMarkers.NotifyItemChanged(AItem: TCollectionItem);
begin
  if Assigned(FOnItemChanged) then
    FOnItemChanged(Self, AItem)
  else
    DoChanged;
end;

{ TOSMPopupOptions }

constructor TOSMPopupOptions.Create;
begin
  inherited Create;
  FCloseButton := True;
  FCloseOnClick := True;
  FCloseOnMove := False;
  FContentType := pctHtml;
  FPresetStyle := ppsDefault;
  FPosition := TMapLibLatLng.Create(0, 0);
  FPosition.Owner := Self;
{$IFDEF FPC}
  FPosition.OnChange := @PositionChanged;
{$ELSE}
  FPosition.OnChange := PositionChanged;
{$ENDIF}
  FVisible := False;
end;

destructor TOSMPopupOptions.Destroy;
begin
  FPosition.Free;
  inherited Destroy;
end;

procedure TOSMPopupOptions.Assign(Source: TPersistent);
begin
  if Source is TOSMPopupOptions then
  begin
    FCloseButton := TOSMPopupOptions(Source).CloseButton;
    FCloseOnClick := TOSMPopupOptions(Source).CloseOnClick;
    FCloseOnMove := TOSMPopupOptions(Source).CloseOnMove;
    FContent := TOSMPopupOptions(Source).Content;
    FContentType := TOSMPopupOptions(Source).ContentType;
    FMaxWidth := TOSMPopupOptions(Source).MaxWidth;
    FPresetStyle := TOSMPopupOptions(Source).PresetStyle;
    FPosition.Assign(TOSMPopupOptions(Source).Position);
    FVisible := TOSMPopupOptions(Source).Visible;
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

procedure TOSMPopupOptions.PositionChanged(Sender: TObject);
begin
  Changed;
end;

procedure TOSMPopupOptions.SetCloseButton(const Value: Boolean);
begin
  if FCloseButton = Value then
    Exit;
  FCloseButton := Value;
  Changed;
end;

procedure TOSMPopupOptions.SetCloseOnClick(const Value: Boolean);
begin
  if FCloseOnClick = Value then
    Exit;
  FCloseOnClick := Value;
  Changed;
end;

procedure TOSMPopupOptions.SetContent(const Value: string);
begin
  if FContent = Value then
    Exit;
  FContent := Value;
  Changed;
end;

procedure TOSMPopupOptions.SetContentType(const Value: TOSMPopupContentType);
begin
  if FContentType = Value then
    Exit;
  FContentType := Value;
  Changed;
end;

procedure TOSMPopupOptions.SetMaxWidth(const Value: Integer);
begin
  if FMaxWidth = Value then
    Exit;
  FMaxWidth := Value;
  Changed;
end;

procedure TOSMPopupOptions.SetCloseOnMove(const Value: Boolean);
begin
  if FCloseOnMove = Value then
    Exit;
  FCloseOnMove := Value;
  Changed;
end;

procedure TOSMPopupOptions.SetPresetStyle(const Value: TOSMPopupPresetStyle);
begin
  if FPresetStyle = Value then
    Exit;
  FPresetStyle := Value;
  Changed;
end;

procedure TOSMPopupOptions.SetPosition(const Value: TMapLibLatLng);
begin
  if not Assigned(Value) then
    Exit;
  FPosition.Assign(Value);
end;

procedure TOSMPopupOptions.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;
  FVisible := Value;
  Changed;
end;

{ TOSMPopupItem }

constructor TOSMPopupItem.Create(ACollection: TCollection);
begin
  FInitializing := True;
  inherited Create(ACollection);
  FObjectId := BuildObjectId;
  FOptions := CreatePopupOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
  FInitializing := False;
end;

destructor TOSMPopupItem.Destroy;
begin
  FOptions.Free;
  inherited Destroy;
end;

procedure TOSMPopupItem.Assign(Source: TPersistent);
begin
  if Source is TOSMPopupItem then
  begin
    FAnchorObjectId := TOSMPopupItem(Source).AnchorObjectId;
    FOptions.Assign(TOSMPopupItem(Source).Options);
    Changed;
    Exit;
  end;

  inherited Assign(Source);
end;

function TOSMPopupItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('osm_popup_%d', [FNextObjectId]));
end;

function TOSMPopupItem.CreatePopupOptions: TOSMPopupOptions;
begin
  Result := TOSMPopupOptions.Create;
end;

function TOSMPopupItem.BuildAddPayload: string;
begin
  Result := BuildSetOptionsPayload;
end;

function TOSMPopupItem.BuildSetOptionsPayload: string;
begin
  Result := Format(
    '{"objectId":"%s","anchorObjectId":"%s","content":"%s","contentType":"%s","cssClass":"%s","closeButton":%s,' +
    '"closeOnClick":%s,"closeOnMove":%s,"maxWidth":%d,"visible":%s,"position":{"lat":%.15g,"lng":%.15g}}',
    [
      JsonEscape(string(FObjectId)),
      JsonEscape(string(FAnchorObjectId)),
      JsonEscape(FOptions.Content),
      JsonEscape(OSMPopupContentTypeToString(FOptions.ContentType)),
      JsonEscape(OSMPopupPresetStyleToCssClass(FOptions.PresetStyle)),
      LowerCase(BoolToStr(FOptions.CloseButton, True)),
      LowerCase(BoolToStr(FOptions.CloseOnClick, True)),
      LowerCase(BoolToStr(FOptions.CloseOnMove, True)),
      FOptions.MaxWidth,
      LowerCase(BoolToStr(FOptions.Visible, True)),
      FOptions.Position.Lat,
      FOptions.Position.Lng
    ],
    GMLibInvariantFormatSettings
  );
end;

procedure TOSMPopupItem.Open;
begin
  if (Collection is TOSMPopups) and TOSMPopups(Collection).CloseOthersBeforeOpen then
    TOSMPopups(Collection).CloseOthers(Self);
  Options.Visible := True;
end;

procedure TOSMPopupItem.OpenByObjectId(const AAnchorObjectId: TGMObjectId);
begin
  AnchorObjectId := AAnchorObjectId;
  Open;
end;

procedure TOSMPopupItem.Close;
begin
  Options.Visible := False;
end;

procedure TOSMPopupItem.ProcessMapEvent(const AEventName, APayload: string);
begin
  if APayload = #0 then ;
  if SameText(AEventName, 'open') then
  begin
    FUpdatingFromMapMessage := True;
    try
      FOptions.Visible := True;
    finally
      FUpdatingFromMapMessage := False;
    end;
    if Assigned(FOnOpen) then
      FOnOpen(Self);
  end
  else if SameText(AEventName, 'close') then
  begin
    FUpdatingFromMapMessage := True;
    try
      FOptions.Visible := False;
    finally
      FUpdatingFromMapMessage := False;
    end;
    if Assigned(FOnClose) then
      FOnClose(Self);
  end;
end;

procedure TOSMPopupItem.Changed;
begin
  if FInitializing or (FUpdateCount > 0) or FUpdatingFromMapMessage or
     not Assigned(FOptions) or not Assigned(FOptions.Position) then
  begin
    if FUpdateCount > 0 then
      FChangePending := True;
    Exit;
  end;
  if Collection is TOSMPopups then
    TOSMPopups(Collection).NotifyItemChanged(Self);
end;

procedure TOSMPopupItem.OptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TOSMPopupItem.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TOSMPopupItem.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FChangePending then
  begin
    FChangePending := False;
    Changed;
  end;
end;

procedure TOSMPopupItem.SetAnchorObjectId(const Value: TGMObjectId);
begin
  if FAnchorObjectId = Value then
    Exit;
  FAnchorObjectId := Value;
  Changed;
end;

procedure TOSMPopupItem.SetOptions(const Value: TOSMPopupOptions);
begin
  if not Assigned(Value) then
    Exit;
  FOptions.Assign(Value);
end;

{ TOSMPopups }

constructor TOSMPopups.Create(AOwner: TPersistent; AItemClass: TOSMPopupItemClass);
begin
  if not Assigned(AItemClass) then
    AItemClass := TOSMPopupItem;
  inherited Create(AOwner, AItemClass);
end;

function TOSMPopups.Add: TOSMPopupItem;
begin
  BeginUpdate;
  try
    Result := TOSMPopupItem(inherited Add);
  finally
    EndUpdate;
  end;
end;

procedure TOSMPopups.CloseOthers(AExcept: TOSMPopupItem);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Assigned(Items[I]) and (Items[I] <> AExcept) and Items[I].Options.Visible then
      Items[I].Options.Visible := False;
end;

procedure TOSMPopups.DoChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TOSMPopups.FindByObjectId(const AObjectId: TGMObjectId): TOSMPopupItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(string(Items[I].ObjectId), string(AObjectId)) then
      Exit(Items[I]);
end;

function TOSMPopups.GetItem(Index: Integer): TOSMPopupItem;
begin
  Result := TOSMPopupItem(inherited Items[Index]);
end;

procedure TOSMPopups.NotifyItemChanged(AItem: TCollectionItem);
begin
  if Assigned(FOnItemChanged) then
    FOnItemChanged(Self, AItem)
  else
    DoChanged;
end;

procedure TOSMPopups.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if (Item is TOSMPopupItem) and TOSMPopupItem(Item).FInitializing then
    Exit;
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

function TryReadJsonNumber(AJsonObject: TJSONObject; const AName: string; out AValue: Double): Boolean;
var
  JsonValue: TJSONValue;
  textValue: string;
begin
  Result := False;
  AValue := 0;

  if not Assigned(AJsonObject) then
    Exit;

  JsonValue := AJsonObject.GetValue(AName);
  if not Assigned(JsonValue) then
    Exit;

  if JsonValue is TJSONNumber then
  begin
    AValue := TJSONNumber(JsonValue).AsDouble;
    Exit(True);
  end;

  if JsonValue is TJSONString then
  begin
    textValue := TJSONString(JsonValue).Value;
    Exit(TryStrToFloat(textValue, AValue, GMLibInvariantFormatSettings));
  end;

  textValue := JsonValue.Value;
  Result := TryStrToFloat(textValue, AValue, GMLibInvariantFormatSettings);
end;
{$ENDIF}

constructor TOSMMap.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCenterLat := 0;
  FCenterLng := 0;
  FMinZoom := 0;
  FMaxZoom := 22;
  FMinPitch := DEFAULT_MAPLIBRE_MIN_PITCH;
  FMaxPitch := DEFAULT_MAPLIBRE_MAX_PITCH;
  FMapId := 'OSMLib_MAP';
  FLastEventName := '';
  FStyleUrl := DEFAULT_MAPLIBRE_STYLE_URL;
  FMapLibreCssUrl := DEFAULT_MAPLIBRE_CSS_URL;
  FMapLibreJsUrl := DEFAULT_MAPLIBRE_JS_URL;
  FZoom := 1;
  FBearing := 0;
  FPitch := 0;
  FRenderWorldCopies := True;
  FDragPanEnabled := True;
  FDragRotateEnabled := True;
  FDoubleClickZoomEnabled := True;
  FScrollZoomEnabled := True;
  FKeyboardEnabled := True;
  FTouchZoomRotateEnabled := True;
  FTouchPitchEnabled := True;
  FCooperativeGesturesEnabled := False;
  // FOfflineMode := False;
  FMapMode := omOnline;
  FOfflinePolicy := opPreferOffline;
  // FOfflineTileProvider := otpAuto;
  FOfflineStoragePath := BuildDefaultOfflineStoragePath;
  FRemoteTileTemplate := '';
  FStyleTemplateFileName := '';
  FGlyphsRootPath := '';
  FVectorRuntime := TMapLibVectorRuntime.Create;
  FVectorRuntime.SourceId := 'osm';
  FVectorRuntime.MapMode := FMapMode;
  FVectorRuntime.OfflinePolicy := FOfflinePolicy;
  FVectorRuntime.OfflineStoragePath := FOfflineStoragePath;
  FVectorRuntime.StyleTemplateFileName := FStyleTemplateFileName;
  FVectorRuntime.GlyphsRootPath := FGlyphsRootPath;
  FOfflineRegionManager := TMapLibOfflineRegionManager.Create(FOfflineStoragePath);
{$IFDEF FPC}
  FOfflineRegionManager.OnDownloadProgress := @HandleOfflineDownloadProgress;
  FOfflineRegionManager.OnRegionReady := @HandleOfflineRegionReady;
  FOfflineRegionManager.OnOfflineError := @HandleOfflineError;
{$ELSE}
  FOfflineRegionManager.OnDownloadProgress := HandleOfflineDownloadProgress;
  FOfflineRegionManager.OnRegionReady := HandleOfflineRegionReady;
  FOfflineRegionManager.OnOfflineError := HandleOfflineError;
{$ENDIF}
  FMaxBounds := TOSMMapBounds.Create;
  FMaxBounds.Owner := Self;
{$IFDEF FPC}
  FMaxBounds.OnChange := @MaxBoundsChanged;
{$ELSE}
  FMaxBounds.OnChange := MaxBoundsChanged;
{$ENDIF}
  FMarkers := CreateMarkers;
{$IFDEF FPC}
  FMarkers.OnChange := @MarkersChanged;
  FMarkers.OnItemChanged := @MarkerItemChanged;
{$ELSE}
  FMarkers.OnChange := MarkersChanged;
  FMarkers.OnItemChanged := MarkerItemChanged;
{$ENDIF}
  FPopups := CreatePopups;
{$IFDEF FPC}
  FPopups.OnChange := @PopupsChanged;
  FPopups.OnItemChanged := @PopupItemChanged;
{$ELSE}
  FPopups.OnChange := PopupsChanged;
  FPopups.OnItemChanged := PopupItemChanged;
{$ENDIF}
end;

destructor TOSMMap.Destroy;
begin
  // StopOfflineTileServer;
  FVectorRuntime.Free;
  FMaxBounds.Free;
  FPopups.Free;
  FMarkers.Free;
  inherited Destroy;
end;

function TOSMMap.GetDocumentationUrl: string;
begin
  Result := 'https://maplibre.org/maplibre-gl-js/docs/';
end;

function TOSMMap.CreateMarkers: TOSMMarkers;
begin
  Result := TOSMMarkers.Create(Self);
end;

function TOSMMap.CreatePopups: TOSMPopups;
begin
  Result := TOSMPopups.Create(Self);
end;

procedure TOSMMap.SetMarkers(const Value: TOSMMarkers);
begin
  FMarkers.Assign(Value);
end;

procedure TOSMMap.SetPopups(const Value: TOSMPopups);
begin
  FPopups.Assign(Value);
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
  if (FMapMode <> omOnline) and Assigned(FVectorRuntime) then
    Exit('');
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
var
  assetPath: string;
begin
  if Trim(FMapLibreCssUrl) <> '' then
    Exit(FMapLibreCssUrl);

  if FMapMode <> omOnline then
  begin
    assetPath := TGMLibBootstrapAssets.EnsureAssetFile(
      'osm\maplibre-gl.css',
      'OSMLIB_MAPLIBRE_CSS',
      'resources\js\osm\maplibre-gl.css'
    );
    if assetPath <> '' then
      Exit(assetPath);
  end;

  Result := DEFAULT_MAPLIBRE_CSS_URL;
end;

function TOSMMap.ResolveMapLibreJsUrl: string;
var
  assetPath: string;
begin
  if Trim(FMapLibreJsUrl) <> '' then
    Exit(FMapLibreJsUrl);

  if FMapMode <> omOnline then
  begin
    assetPath := TGMLibBootstrapAssets.EnsureAssetFile(
      'osm\maplibre-gl.js',
      'OSMLIB_MAPLIBRE_JS',
      'resources\js\osm\maplibre-gl.js'
    );
    if assetPath <> '' then
      Exit(assetPath);
  end;

  Result := DEFAULT_MAPLIBRE_JS_URL;
end;

function TOSMMap.ResolveActiveRegionFileName: string;
var
  activeRegionId: TMapLibOfflineRegionId;
  regionIndex: Integer;
  regions: TMapLibOfflineRegionMetadataArray;
begin
  Result := '';
  if not Assigned(FOfflineRegionManager) then
    Exit;

  activeRegionId := FOfflineRegionManager.GetActiveRegionId;
  if Trim(activeRegionId) = '' then
    Exit;

  regions := FOfflineRegionManager.ListRegions;
  for regionIndex := Low(regions) to High(regions) do
  begin
    if SameText(regions[regionIndex].RegionId, activeRegionId) then
    begin
{$IFDEF FPC}
      if (ExtractFileDrive(regions[regionIndex].StoragePath) <> '') or
        ((regions[regionIndex].StoragePath <> '') and
         (regions[regionIndex].StoragePath[1] = PathDelim)) then
        Result := regions[regionIndex].StoragePath
      else
        Result := IncludeTrailingPathDelimiter(FOfflineStoragePath) + regions[regionIndex].StoragePath;
{$ELSE}
      if TPath.IsPathRooted(regions[regionIndex].StoragePath) then
        Result := regions[regionIndex].StoragePath
      else
        Result := TPath.Combine(FOfflineStoragePath, regions[regionIndex].StoragePath);
{$ENDIF}
      Exit;
    end;
  end;
end;

function TOSMMap.ResolveOfflineGlyphsRootPath: string;
{$IFNDEF FPC}
var
  glyphsStoragePath: string;
{$ENDIF}
begin
  if Trim(FGlyphsRootPath) <> '' then
    Exit(FGlyphsRootPath);

{$IFDEF FPC}
  if DirectoryExists(TGMLibBootstrapAssets.ResolveResourceFile('resources\js\osm')) then
    Exit(TGMLibBootstrapAssets.ResolveResourceFile('resources\js\osm'));
  Result := '';
{$ELSE}
  glyphsStoragePath := TPath.Combine(FOfflineStoragePath, 'glyphs');
  Result := TGMLibBootstrapAssets.EnsureZipExpandedDirectory(
    glyphsStoragePath,
    'Noto Sans Regular',
    'osm\Noto_Sans_Regular.zip',
    'OSMLIB_GLYPHS_NOTO_SANS_REGULAR_ZIP',
    'resources\js\osm\Noto_Sans_Regular.zip'
  );
{$ENDIF}
end;

function TOSMMap.ResolveOfflineStyleTemplateFileName(
  const AGlyphsRootPath: string): string;
begin
  if Trim(FStyleTemplateFileName) <> '' then
    Exit(FStyleTemplateFileName);

  if Trim(AGlyphsRootPath) = '' then
    Exit('');

  Result := TGMLibBootstrapAssets.EnsureAssetFile(
    'osm\style.template.json',
    'OSMLIB_OFFLINE_STYLE_TEMPLATE',
    'resources\js\osm\style.template.json'
  );
end;

procedure TOSMMap.PrepareOfflineRuntimeAssets;
var
  resolvedGlyphsRootPath: string;
begin
  if (FMapMode = omOnline) or not Assigned(FVectorRuntime) then
    Exit;

  resolvedGlyphsRootPath := ResolveOfflineGlyphsRootPath;
  FVectorRuntime.MapMode := FMapMode;
  FVectorRuntime.OfflinePolicy := FOfflinePolicy;
  FVectorRuntime.OfflineStoragePath := FOfflineStoragePath;
  FVectorRuntime.ActiveRegionFileName := ResolveActiveRegionFileName;
  FVectorRuntime.StyleTemplateFileName := ResolveOfflineStyleTemplateFileName(resolvedGlyphsRootPath);
  FVectorRuntime.GlyphsRootPath := resolvedGlyphsRootPath;
end;

function TOSMMap.GetRuntimeBaseUrl: string;
begin
  if Assigned(FVectorRuntime) then
    Result := FVectorRuntime.GetBaseUrl
  else
    Result := '';
end;

function GetOSMMapLibreCssUrl(AMap: TOSMMap): string;
var
  isHttp: Boolean;
begin
  if Assigned(AMap) then
    Result := AMap.ResolveMapLibreCssUrl
  else
    Result := DEFAULT_MAPLIBRE_CSS_URL;

  isHttp := StartsText('http://', Result) or StartsText('https://', Result);
  if (Result <> '') and not isHttp and FileExists(Result) then
    Result := 'file:///' + StringReplace(ExpandFileName(Result), '\', '/', [rfReplaceAll]);
end;

function GetOSMMapLibreJsUrl(AMap: TOSMMap): string;
var
  isHttp: Boolean;
begin
  if Assigned(AMap) then
    Result := AMap.ResolveMapLibreJsUrl
  else
    Result := DEFAULT_MAPLIBRE_JS_URL;

  isHttp := StartsText('http://', Result) or StartsText('https://', Result);
  if (Result <> '') and not isHttp and FileExists(Result) then
    Result := 'file:///' + StringReplace(ExpandFileName(Result), '\', '/', [rfReplaceAll]);
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

procedure TOSMMap.SetMinZoom(const Value: Double);
begin
  if FMinZoom = Value then
    Exit;
  FMinZoom := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetMaxZoom(const Value: Double);
begin
  if FMaxZoom = Value then
    Exit;
  FMaxZoom := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetMinPitch(const Value: Double);
begin
  if FMinPitch = Value then
    Exit;
  FMinPitch := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetMaxPitch(const Value: Double);
begin
  if FMaxPitch = Value then
    Exit;
  FMaxPitch := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetMaxBounds(const Value: TOSMMapBounds);
begin
  if not Assigned(Value) then
    Exit;

  FMaxBounds.Assign(Value);
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
  if Assigned(FVectorRuntime) then
  begin
    FVectorRuntime.OfflineStoragePath := FOfflineStoragePath;
    FVectorRuntime.ActiveRegionFileName := ResolveActiveRegionFileName;
  end;
  if Assigned(FOfflineRegionManager) then
    FOfflineRegionManager.SetStorageBasePath(FOfflineStoragePath);
end;

procedure TOSMMap.SetOfflinePolicy(const Value: TMapLibOfflinePolicy);
begin
  if FOfflinePolicy = Value then
    Exit;
  FOfflinePolicy := Value;
  if Assigned(FVectorRuntime) then
    FVectorRuntime.OfflinePolicy := Value;
end;

procedure TOSMMap.SetMapMode(const Value: TMapLibMapMode);
begin
  if FMapMode = Value then
    Exit;
  FMapMode := Value;
  if Assigned(FVectorRuntime) then
  begin
    FVectorRuntime.MapMode := Value;
    FVectorRuntime.ActiveRegionFileName := ResolveActiveRegionFileName;
  end;
end;

procedure TOSMMap.SetRemoteTileTemplate(const Value: string);
begin
  if FRemoteTileTemplate = Value then
    Exit;
  FRemoteTileTemplate := Value;
  if Assigned(FVectorRuntime) and Assigned(FVectorRuntime.RemoteTileProvider) then
    FVectorRuntime.RemoteTileProvider.TileUrlTemplate := Value;
end;

procedure TOSMMap.SetStyleTemplateFileName(const Value: string);
begin
  if FStyleTemplateFileName = Value then
    Exit;
  FStyleTemplateFileName := Value;
  if Assigned(FVectorRuntime) then
    FVectorRuntime.StyleTemplateFileName := Value;
end;

procedure TOSMMap.SetGlyphsRootPath(const Value: string);
begin
  if FGlyphsRootPath = Value then
    Exit;
  FGlyphsRootPath := Value;
  if Assigned(FVectorRuntime) then
    FVectorRuntime.GlyphsRootPath := Value;
end;

procedure TOSMMap.HandleOfflineDownloadProgress(Sender: TObject; const AJobId: string;
  APercent: Double; ABytesDone, ABytesTotal: Int64);
begin
  if Assigned(FOnOfflineDownloadProgress) then
    FOnOfflineDownloadProgress(Self, AJobId, APercent, ABytesDone, ABytesTotal);
end;

procedure TOSMMap.HandleOfflineRegionReady(Sender: TObject; const ARegionId: TMapLibOfflineRegionId);
begin
  if Assigned(FOfflineRegionManager) then
    FOfflineRegionManager.SetActiveRegion(ARegionId);
  if Assigned(FVectorRuntime) then
    FVectorRuntime.ActiveRegionFileName := ResolveActiveRegionFileName;
  if FActive and (FMapMode <> omOnline) then
    ApplyStyle;
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

procedure TOSMMap.SetBearing(const Value: Double);
begin
  if FBearing = Value then
    Exit;
  FBearing := Value;
  SyncViewToBridge;
end;

procedure TOSMMap.SetPitch(const Value: Double);
begin
  if FPitch = Value then
    Exit;
  FPitch := Value;
  SyncViewToBridge;
end;

procedure TOSMMap.SetDragPanEnabled(const Value: Boolean);
begin
  if FDragPanEnabled = Value then
    Exit;
  FDragPanEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetDragRotateEnabled(const Value: Boolean);
begin
  if FDragRotateEnabled = Value then
    Exit;
  FDragRotateEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetDoubleClickZoomEnabled(const Value: Boolean);
begin
  if FDoubleClickZoomEnabled = Value then
    Exit;
  FDoubleClickZoomEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetScrollZoomEnabled(const Value: Boolean);
begin
  if FScrollZoomEnabled = Value then
    Exit;
  FScrollZoomEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetKeyboardEnabled(const Value: Boolean);
begin
  if FKeyboardEnabled = Value then
    Exit;
  FKeyboardEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetTouchZoomRotateEnabled(const Value: Boolean);
begin
  if FTouchZoomRotateEnabled = Value then
    Exit;
  FTouchZoomRotateEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetTouchPitchEnabled(const Value: Boolean);
begin
  if FTouchPitchEnabled = Value then
    Exit;
  FTouchPitchEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetCooperativeGesturesEnabled(const Value: Boolean);
begin
  if FCooperativeGesturesEnabled = Value then
    Exit;
  FCooperativeGesturesEnabled := Value;
  SyncOptionsToBridge;
end;

procedure TOSMMap.SetRenderWorldCopies(const Value: Boolean);
begin
  if FRenderWorldCopies = Value then
    Exit;
  FRenderWorldCopies := Value;
  SyncOptionsToBridge;
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

procedure TOSMMap.SyncOptionsToBridge;
begin
  if not FActive or not Assigned(FBridge) then
    Exit;
  FBridge.PostCommand(CreateEnvelope('map.set_options', BuildSetOptionsPayload));
end;

function TOSMMap.BuildSetViewPayload: string;
begin
  Result := Format(
    '{"center":{"lat":%.15g,"lng":%.15g},"zoom":%.15g,"bearing":%.15g,"pitch":%.15g}',
    [FCenterLat, FCenterLng, FZoom, FBearing, FPitch],
    GMLibInvariantFormatSettings
  );
end;

function TOSMMap.BuildSetOptionsPayload: string;
begin
  Result := Format(
    '{"minZoom":%.15g,"maxZoom":%.15g,"minPitch":%.15g,"maxPitch":%.15g,' +
    '"maxBounds":%s,"renderWorldCopies":%s,"dragPanEnabled":%s,"dragRotateEnabled":%s,' +
    '"doubleClickZoomEnabled":%s,"scrollZoomEnabled":%s,"keyboardEnabled":%s,' +
    '"touchZoomRotateEnabled":%s,"touchPitchEnabled":%s,"cooperativeGesturesEnabled":%s}',
    [FMinZoom, FMaxZoom, FMinPitch, FMaxPitch, FMaxBounds.ToJsonLiteral,
     LowerCase(BoolToStr(FRenderWorldCopies, True)),
     LowerCase(BoolToStr(FDragPanEnabled, True)),
     LowerCase(BoolToStr(FDragRotateEnabled, True)),
     LowerCase(BoolToStr(FDoubleClickZoomEnabled, True)),
     LowerCase(BoolToStr(FScrollZoomEnabled, True)),
     LowerCase(BoolToStr(FKeyboardEnabled, True)),
     LowerCase(BoolToStr(FTouchZoomRotateEnabled, True)),
     LowerCase(BoolToStr(FTouchPitchEnabled, True)),
     LowerCase(BoolToStr(FCooperativeGesturesEnabled, True))],
    GMLibInvariantFormatSettings
  );
end;

function TOSMMap.BuildSetStylePayload: string;
var
  styleJson: string;
begin
  styleJson := '';
  if (FMapMode <> omOnline) and Assigned(FVectorRuntime) then
  begin
    PrepareOfflineRuntimeAssets;
    FVectorRuntime.Start;
    styleJson := FVectorRuntime.BuildStyleJson;
  end;

  Result := Format(
    '{"styleUrl":"%s","styleJson":"%s"}',
    [JsonEscape(ResolveStyleUrl), JsonEscape(styleJson)],
    GMLibInvariantFormatSettings
  );
end;

function TOSMMap.BuildMarkerAddEnvelope(AMarker: TOSMMarkerItem): TMapLibMessageEnvelope;
begin
  Result := CreateEnvelope('marker.add', AMarker.BuildAddPayload);
end;

function TOSMMap.BuildPopupAddEnvelope(APopup: TOSMPopupItem): TMapLibMessageEnvelope;
begin
  Result := CreateEnvelope('popup.add', APopup.BuildAddPayload);
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
    AppendOSMMapTrace('BridgeMessageReceived type=' + AEnvelope.MessageType +
      ' target=' + AEnvelope.TargetId + ' payloadLength=' + IntToStr(Length(AEnvelope.Payload)));
    if (AEnvelope.TargetId <> '') and (AEnvelope.TargetId <> FMapId) then
      Exit;

    if SameText(AEnvelope.MessageType, 'map.ready') then
    begin
      if Assigned(FOnMapReady) then
        FOnMapReady(Self);
      SyncOptionsToBridge;
      SyncViewToBridge;
      SyncPopupsToBridge;
      Exit;
    end;

    if SameText(AEnvelope.MessageType, 'map.event.bootstraplog') then
    begin
      AppendOSMMapTrace('BootstrapLog raw=' + AEnvelope.Payload);
      Exit;
    end;

    if Pos('map.event.', AEnvelope.MessageType) = 1 then
      DispatchMapEvent(Copy(AEnvelope.MessageType, Length('map.event.') + 1, MaxInt), AEnvelope.Payload);
    if Pos('marker.event.', AEnvelope.MessageType) = 1 then
      DispatchMarkerEvent(Copy(AEnvelope.MessageType, Length('marker.event.') + 1, MaxInt), AEnvelope.Payload);
    if Pos('popup.event.', AEnvelope.MessageType) = 1 then
      DispatchPopupEvent(Copy(AEnvelope.MessageType, Length('popup.event.') + 1, MaxInt), AEnvelope.Payload);
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
  FLastEventName := AEventName;
  if not TryGetMarkerClickFromPayload(APayload, MarkerId, LatLng) then
    Exit;
  try
    Marker := FMarkers.FindByObjectId(MarkerId);
    if Assigned(Marker) then
    begin
      if SameText(AEventName, 'drag') or SameText(AEventName, 'dragend') then
        Marker.ApplyRuntimePosition(LatLng.Lat, LatLng.Lng);

      if SameText(AEventName, 'click') and Assigned(Marker.OnClick) then
        Marker.OnClick(Marker, LatLng)
      else if SameText(AEventName, 'dblclick') and Assigned(Marker.OnDblClick) then
        Marker.OnDblClick(Marker, LatLng)
      else if SameText(AEventName, 'mouseenter') and Assigned(Marker.OnMouseEnter) then
        Marker.OnMouseEnter(Marker, LatLng)
      else if SameText(AEventName, 'mouseleave') and Assigned(Marker.OnMouseLeave) then
        Marker.OnMouseLeave(Marker, LatLng)
      else if SameText(AEventName, 'mousedown') and Assigned(Marker.OnMouseDown) then
        Marker.OnMouseDown(Marker, LatLng)
      else if SameText(AEventName, 'mouseup') and Assigned(Marker.OnMouseUp) then
        Marker.OnMouseUp(Marker, LatLng)
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
    if not TryGetViewFromPayload(APayload, Center, ZoomValue, BearingValue, PitchValue) then
      Exit;
    try
      FCenterLat := Center.Lat;
      FCenterLng := Center.Lng;
      FZoom := ZoomValue;
      FBearing := BearingValue;
      FPitch := PitchValue;
      if Assigned(AHandler) then
        AHandler(Self, Center, ZoomValue, BearingValue, PitchValue);
    finally
      Center.Free;
    end;
  end;
begin
  FLastEventName := AEventName;
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
  else if SameText(AEventName, 'cooperativegestureprevented') and Assigned(FOnCooperativeGesturePrevented) then
    FOnCooperativeGesturePrevented(Self)
  else if SameText(AEventName, 'boundschanged') and Assigned(FOnBoundsChanged) and
    TryGetBoundsFromPayload(APayload, North, South, East, West) then
    FOnBoundsChanged(Self, North, South, East, West)
  else if SameText(AEventName, 'error') and Assigned(FOnError) then
  begin
    ErrorMessage := GetErrorMessageFromPayload(APayload);
    FOnError(Self, ErrorMessage);
  end;
end;

procedure TOSMMap.DispatchPopupEvent(const AEventName, APayload: string);
var
  PopupId: TGMObjectId;
  Popup: TOSMPopupItem;
begin
  FLastEventName := AEventName;
  if not TryGetPopupObjectIdFromPayload(APayload, PopupId) then
    Exit;

  Popup := FPopups.FindByObjectId(PopupId);
  if Assigned(Popup) then
    Popup.ProcessMapEvent(AEventName, APayload);
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
  if APayload = #0 then ;
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
    if not TryReadJsonNumber(LatLngObject, 'lat', LatValue) then
      Exit;
    if not TryReadJsonNumber(LatLngObject, 'lng', LngValue) then
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
  if APayload = #0 then ;
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

function TOSMMap.TryGetPopupObjectIdFromPayload(const APayload: string; out APopupId: TGMObjectId): Boolean;
{$IFNDEF FPC}
var
  JsonObject: TJSONObject;
{$ENDIF}
begin
  Result := False;
  APopupId := '';
{$IFDEF FPC}
  if APayload = #0 then ;
{$ELSE}
  JsonObject := nil;
  if not TryParsePayloadObject(APayload, JsonObject) then
    Exit;
  try
    APopupId := TGMObjectId(JsonObject.GetValue<string>('objectId', ''));
    Result := APopupId <> '';
  finally
    JsonObject.Free;
  end;
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
  if APayload = #0 then ;
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
    if not TryReadJsonNumber(CenterObject, 'lat', LatValue) then
      Exit;
    if not TryReadJsonNumber(CenterObject, 'lng', LngValue) then
      Exit;
    if not TryReadJsonNumber(JsonObject, 'zoom', AZoom) then
      Exit;
    TryReadJsonNumber(JsonObject, 'bearing', ABearing);
    TryReadJsonNumber(JsonObject, 'pitch', APitch);
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
  if APayload = #0 then ;
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
      TryReadJsonNumber(JsonObject, 'north', ANorth) and
      TryReadJsonNumber(JsonObject, 'south', ASouth) and
      TryReadJsonNumber(JsonObject, 'east', AEast) and
      TryReadJsonNumber(JsonObject, 'west', AWest);
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
  if APayload = #0 then ;
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
  if (FMapMode <> omOnline) and Assigned(FVectorRuntime) then
  begin
    PrepareOfflineRuntimeAssets;
    FVectorRuntime.Start;
  end;
  FActive := True;
  SyncOptionsToBridge;
  SyncMarkersToBridge;
  SyncPopupsToBridge;
end;

procedure TOSMMap.Deactivate;
begin
  FActive := False;
  if Assigned(FVectorRuntime) then
    FVectorRuntime.Stop;
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

procedure TOSMMap.SyncMarkerOptionsToBridge(AMarker: TOSMMarkerItem);
begin
  if not FActive or not Assigned(FBridge) or not Assigned(AMarker) then
    Exit;

  FBridge.PostCommand(CreateEnvelope('marker.set_options', AMarker.BuildSetOptionsPayload));
end;

procedure TOSMMap.SyncPopupsToBridge;
var
  I: Integer;
begin
  if not FActive or not Assigned(FBridge) then
    Exit;

  FBridge.PostCommand(CreateEnvelope('popup.clear', '{}'));
  for I := 0 to FPopups.Count - 1 do
    FBridge.PostCommand(BuildPopupAddEnvelope(FPopups[I]));
end;

procedure TOSMMap.SyncPopupOptionsToBridge(APopup: TOSMPopupItem);
begin
  if not FActive or not Assigned(FBridge) or not Assigned(APopup) then
    Exit;

  FBridge.PostCommand(CreateEnvelope('popup.set_options', APopup.BuildSetOptionsPayload));
end;

procedure TOSMMap.MarkersChanged(Sender: TObject);
begin
  SyncMarkersToBridge;
end;

procedure TOSMMap.MarkerItemChanged(Sender: TObject; AMarker: TCollectionItem);
begin
  if AMarker is TOSMMarkerItem then
    SyncMarkerOptionsToBridge(TOSMMarkerItem(AMarker))
  else
    SyncMarkersToBridge;
end;

procedure TOSMMap.PopupsChanged(Sender: TObject);
begin
  SyncPopupsToBridge;
end;

procedure TOSMMap.PopupItemChanged(Sender: TObject; APopup: TCollectionItem);
begin
  if APopup is TOSMPopupItem then
    SyncPopupOptionsToBridge(TOSMPopupItem(APopup))
  else
    SyncPopupsToBridge;
end;

procedure TOSMMap.MaxBoundsChanged(Sender: TObject);
begin
  SyncOptionsToBridge;
end;

procedure TOSMMap.ApplyStyle;
begin
  if not FActive or not Assigned(FBridge) then
    Exit;

  if (FMapMode <> omOnline) and Assigned(FVectorRuntime) then
  begin
    PrepareOfflineRuntimeAssets;
    FVectorRuntime.Start;
  end;
  FBridge.PostCommand(CreateEnvelope('map.set_style', BuildSetStylePayload));
end;

function TOSMMap.BuildJsBootstrapConfig: string;
var
  styleJson: string;
  maxBoundsLiteral: string;
{$IFNDEF FPC}
  Config: TJSONObject;
  Center: TJSONObject;
  Bounds: TJSONObject;
begin
  Config := TJSONObject.Create;
  try
    styleJson := '';
    if (FMapMode <> omOnline) and Assigned(FVectorRuntime) then
    begin
      PrepareOfflineRuntimeAssets;
      FVectorRuntime.Start;
      styleJson := FVectorRuntime.BuildStyleJson;
    end;

    Center := TJSONObject.Create;
    Center.AddPair('lat', TJSONNumber.Create(FCenterLat));
    Center.AddPair('lng', TJSONNumber.Create(FCenterLng));

    Config.AddPair('mapId', string(FMapId));
    Config.AddPair('center', Center);
    Config.AddPair('zoom', TJSONNumber.Create(FZoom));
    Config.AddPair('bearing', TJSONNumber.Create(FBearing));
    Config.AddPair('pitch', TJSONNumber.Create(FPitch));
    Config.AddPair('minZoom', TJSONNumber.Create(FMinZoom));
    Config.AddPair('maxZoom', TJSONNumber.Create(FMaxZoom));
    Config.AddPair('minPitch', TJSONNumber.Create(FMinPitch));
    Config.AddPair('maxPitch', TJSONNumber.Create(FMaxPitch));
    if FMaxBounds.IsComplete then
    begin
      Bounds := TJSONObject.Create;
      Bounds.AddPair('north', TJSONNumber.Create(FMaxBounds.North));
      Bounds.AddPair('south', TJSONNumber.Create(FMaxBounds.South));
      Bounds.AddPair('east', TJSONNumber.Create(FMaxBounds.East));
      Bounds.AddPair('west', TJSONNumber.Create(FMaxBounds.West));
      Config.AddPair('maxBounds', Bounds);
    end
    else
      Config.AddPair('maxBounds', TJSONNull.Create);
    Config.AddPair('renderWorldCopies', TJSONBool.Create(FRenderWorldCopies));
    Config.AddPair('dragPanEnabled', TJSONBool.Create(FDragPanEnabled));
    Config.AddPair('dragRotateEnabled', TJSONBool.Create(FDragRotateEnabled));
    Config.AddPair('doubleClickZoomEnabled', TJSONBool.Create(FDoubleClickZoomEnabled));
    Config.AddPair('scrollZoomEnabled', TJSONBool.Create(FScrollZoomEnabled));
    Config.AddPair('keyboardEnabled', TJSONBool.Create(FKeyboardEnabled));
    Config.AddPair('touchZoomRotateEnabled', TJSONBool.Create(FTouchZoomRotateEnabled));
    Config.AddPair('touchPitchEnabled', TJSONBool.Create(FTouchPitchEnabled));
    Config.AddPair('cooperativeGesturesEnabled', TJSONBool.Create(FCooperativeGesturesEnabled));
    Config.AddPair('runtimeBaseUrl', GetRuntimeBaseUrl);
    Config.AddPair('styleUrl', ResolveStyleUrl);
    Config.AddPair('styleJson', styleJson);

    Result := Config.ToJSON;
  finally
    Config.Free;
  end;
end;
{$ELSE}
begin
  styleJson := '';
  if (FMapMode <> omOnline) and Assigned(FVectorRuntime) then
  begin
    PrepareOfflineRuntimeAssets;
    FVectorRuntime.Start;
    styleJson := FVectorRuntime.BuildStyleJson;
  end;

  if FMaxBounds.IsComplete then
    maxBoundsLiteral := FMaxBounds.ToJsonLiteral
  else
    maxBoundsLiteral := 'null';

  Result := Format(
    '{"mapId":"%s","center":{"lat":%.15g,"lng":%.15g},"zoom":%.15g,"bearing":%.15g,' +
    '"pitch":%.15g,"minZoom":%.15g,"maxZoom":%.15g,"minPitch":%.15g,"maxPitch":%.15g,' +
    '"maxBounds":%s,"renderWorldCopies":%s,"dragPanEnabled":%s,"dragRotateEnabled":%s,' +
    '"doubleClickZoomEnabled":%s,"scrollZoomEnabled":%s,"keyboardEnabled":%s,' +
    '"touchZoomRotateEnabled":%s,"touchPitchEnabled":%s,"cooperativeGesturesEnabled":%s,' +
    '"runtimeBaseUrl":"%s","styleUrl":"%s","styleJson":"%s"}',
    [JsonEscape(string(FMapId)),
     FCenterLat,
     FCenterLng,
     FZoom,
     FBearing,
     FPitch,
     FMinZoom,
     FMaxZoom,
     FMinPitch,
     FMaxPitch,
     maxBoundsLiteral,
     LowerCase(BoolToStr(FRenderWorldCopies, True)),
     LowerCase(BoolToStr(FDragPanEnabled, True)),
     LowerCase(BoolToStr(FDragRotateEnabled, True)),
     LowerCase(BoolToStr(FDoubleClickZoomEnabled, True)),
     LowerCase(BoolToStr(FScrollZoomEnabled, True)),
     LowerCase(BoolToStr(FKeyboardEnabled, True)),
     LowerCase(BoolToStr(FTouchZoomRotateEnabled, True)),
     LowerCase(BoolToStr(FTouchPitchEnabled, True)),
     LowerCase(BoolToStr(FCooperativeGesturesEnabled, True)),
     JsonEscape(GetRuntimeBaseUrl),
     JsonEscape(ResolveStyleUrl),
     JsonEscape(styleJson)],
    GMLibInvariantFormatSettings
  );
end;
{$ENDIF}

end.
