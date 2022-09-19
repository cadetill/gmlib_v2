{
  @abstract(@code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 12, 2022)
  @lastmod(August 14, 2022)

  The GMLib.Map contains the implementation of TGMCustomMap class that encapsulate the @code(google.maps.Map) class from Google Maps API and others related classes.
}
unit GMLib.Map;

{$I ..\gmlib.inc}
{$R ..\Resources\gmmapres.RES}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}

  GMLib.Classes, GMLib.Sets, GMLib.LatLng, GMLib.LatLngBounds, GMLib.Events,
  GMLib.HTMLForms;

type
  // @include(..\Help\docs\GMLib.Map.TGMEventsFired.txt)
  TGMEventsFired = record
    // @include(..\Help\docs\GMLib.Map.TGMEventsFired.Map.txt)
    Map: Boolean;
  end;

  TGMEventsMapForm = record
    Lat: string;
    Lng: string;
    X: string;
    Y: string;
    CenterChange: string;
    Click: string;
    Dblclick: string;
    MouseMove: string;
    MouseOut: string;
    MouseOver: string;
    Contextmenu: string;
    MapDrag: string;
    DragEnd: string;
    DragStart: string;
    MapTypeId: string;
    MapTypeId_changed: string;
    TilesLoaded: string;
    SwLat: string;
    SwLng: string;
    NeLat: string;
    NeLng: string;
    BoundsChange: string;
    MapZoom: string;
    ZoomChanged: string;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMFullScreenControlOptions.txt)
  TGMFullScreenControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedOwnedPersistent.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMFullScreenControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpRIGHT_TOP;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMMapTypeControlOptions.txt)
  TGMMapTypeControlOptions = class(TGMPersistentStr)
  private
    FMapTypeIds: TGMMapTypeIds;
    FStyle: TGMMapTypeControlStyle;
    FPosition: TGMControlPosition;
    procedure SetMapTypeIds(const Value: TGMMapTypeIds);
    procedure SetPosition(const Value: TGMControlPosition);
    procedure SetStyle(const Value: TGMMapTypeControlStyle);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMMapTypeControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMMapTypeControlOptions.MapTypeIds.txt)
    property MapTypeIds: TGMMapTypeIds read FMapTypeIds write SetMapTypeIds default [mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN];
    // @include(..\Help\docs\GMLib.Map.TGMMapTypeControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_RIGHT;
    // @include(..\Help\docs\GMLib.Map.TGMMapTypeControlOptions.Style.txt)
    property Style: TGMMapTypeControlStyle read FStyle write SetStyle default mtcDEFAULT;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMRestriction.txt)
  TGMRestriction = class(TGMPersistentStr)
  private
    FEnabled: Boolean;
    FStrictBounds: Boolean;
    FLatLngBounds: TGMLatLngBounds;
    procedure SetEnabled(const Value: Boolean);
    procedure SetStrictBounds(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMRestriction.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Map.TGMRestriction.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMRestriction.LatLngBounds.txt)
    property LatLngBounds: TGMLatLngBounds read FLatLngBounds write FLatLngBounds;
    // @include(..\Help\docs\GMLib.Map.TGMRestriction.StrictBounds.txt)
    property StrictBounds: Boolean read FStrictBounds write SetStrictBounds;
    // @include(..\Help\docs\GMLib.Map.TGMRestriction.Enabled.txt)
    property Enabled: Boolean read FEnabled write SetEnabled;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMRotateControlOptions.txt)
  TGMRotateControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMRotateControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMRotateControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;   // position
  end;

  // @include(..\Help\docs\GMLib.Map.TGMScaleControlOptions.txt)
  TGMScaleControlOptions = class(TGMPersistentStr)
  private
    FStyle: TGMScaleControlStyle;
    procedure SetStyle(const Value: TGMScaleControlStyle);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMScaleControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMScaleControlOptions.Style.txt)
    property Style: TGMScaleControlStyle read FStyle write SetStyle default scsDEFAULT;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMStreetViewControlOptions.txt)
  TGMStreetViewControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMStreetViewControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMStreetViewControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMZoomControlOptions.txt)
  TGMZoomControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMZoomControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMZoomControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.txt)
  TGMCustomMapOptions = class(TGMPersistentStr, IGMControlChanges)
  private
    FTilt: Integer;
    FRestriction: TGMRestriction;
    FIsFractionalZoomEnabled: Boolean;
    FNoClear: Boolean;
    FGestureHandling: TGMGestureHandling;
    FZoomControlOptions: TGMZoomControlOptions;
    FScaleControlOptions: TGMScaleControlOptions;
    FClickableIcons: Boolean;
    FKeyboardShortcuts: Boolean;
    FMapTypeControlOptions: TGMMapTypeControlOptions;
    FDraggingCursor: string;
    FMinZoom: Integer;
    FDisableDoubleClickZoom: Boolean;
    FZoomControl: Boolean;
    FScaleControl: Boolean;
    FMapTypeControl: Boolean;
    FMapTypeId: TGMMapTypeId;
    FFullScreenControlOptions: TGMFullScreenControlOptions;
    FStreetViewControlOptions: TGMStreetViewControlOptions;
    FRotateControlOptions: TGMRotateControlOptions;
    FFullScreenControl: Boolean;
    FHeading: Integer;
    FStreetViewControl: Boolean;
    FRotateControl: Boolean;
    FDraggableCursor: string;
    FCenter: TGMLatLng;
    FZoom: Integer;
    FMaxZoom: Integer;
    procedure SetClickableIcons(const Value: Boolean);
    procedure SetDisableDoubleClickZoom(const Value: Boolean);
    procedure SetDraggableCursor(const Value: string);
    procedure SetDraggingCursor(const Value: string);
    procedure SetFullScreenControl(const Value: Boolean);
    procedure SetGestureHandling(const Value: TGMGestureHandling);
    procedure SetHeading(const Value: Integer);
    procedure SetIsFractionalZoomEnabled(const Value: Boolean);
    procedure SetKeyboardShortcuts(const Value: Boolean);
    procedure SetMapTypeControl(const Value: Boolean);
    procedure SetMapTypeId(const Value: TGMMapTypeId);
    procedure SetMaxZoom(const Value: Integer);
    procedure SetMinZoom(const Value: Integer);
    procedure SetNoClear(const Value: Boolean);
    procedure SetRotateControl(const Value: Boolean);
    procedure SetScaleControl(const Value: Boolean);
    procedure SetStreetViewControl(const Value: Boolean);
    procedure SetTilt(const Value: Integer);
    procedure SetZoom(const Value: Integer);
    procedure SetZoomControl(const Value: Boolean);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Center.txt)
    property Center: TGMLatLng read FCenter write FCenter;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ClickableIcons.txt)
    property ClickableIcons: Boolean read FClickableIcons write SetClickableIcons;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.DisableDoubleClickZoom.txt)
    property DisableDoubleClickZoom: Boolean read FDisableDoubleClickZoom write SetDisableDoubleClickZoom default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.DraggableCursor.txt)
    property DraggableCursor: string read FDraggableCursor write SetDraggableCursor;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.DraggingCursor.txt)
    property DraggingCursor: string read FDraggingCursor write SetDraggingCursor;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.FullScreenControl.txt)
    property FullScreenControl: Boolean read FFullScreenControl write SetFullScreenControl default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.FullScreenControlOptions.txt)
    property FullScreenControlOptions: TGMFullScreenControlOptions read FFullScreenControlOptions write FFullScreenControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.GestureHandling.txt)
    property GestureHandling: TGMGestureHandling read FGestureHandling write SetGestureHandling;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Heading.txt)
    property Heading: Integer read FHeading write SetHeading default 0;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.IsFractionalZoomEnabled.txt)
    property IsFractionalZoomEnabled: Boolean read FIsFractionalZoomEnabled write SetIsFractionalZoomEnabled;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.KeyboardShortcuts.txt)
    property KeyboardShortcuts: Boolean read FKeyboardShortcuts write SetKeyboardShortcuts default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MapTypeControl.txt)
    property MapTypeControl: Boolean read FMapTypeControl write SetMapTypeControl default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MapTypeControlOptions.txt)
    property MapTypeControlOptions: TGMMapTypeControlOptions read FMapTypeControlOptions write FMapTypeControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MapTypeId.txt)
    property MapTypeId: TGMMapTypeId read FMapTypeId write SetMapTypeId default mtROADMAP;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MaxZoom.txt)
    property MaxZoom: Integer read FMaxZoom write SetMaxZoom default 0;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MinZoom.txt)
    property MinZoom: Integer read FMinZoom write SetMinZoom default 0;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.NoClear.txt)
    property NoClear: Boolean read FNoClear write SetNoClear default False;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Restriction.txt)
    property Restriction: TGMRestriction read FRestriction write FRestriction;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.RotateControl.txt)
    property RotateControl: Boolean read FRotateControl write SetRotateControl default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.RotateControlOptions.txt)
    property RotateControlOptions: TGMRotateControlOptions read FRotateControlOptions write FRotateControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ScaleControl.txt)
    property ScaleControl: Boolean read FScaleControl write SetScaleControl default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ScaleControlOptions.txt)
    property ScaleControlOptions: TGMScaleControlOptions read FScaleControlOptions write FScaleControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.StreetViewControl.txt)
    property StreetViewControl: Boolean read FStreetViewControl write SetStreetViewControl default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.StreetViewControlOptions.txt)
    property StreetViewControlOptions: TGMStreetViewControlOptions read FStreetViewControlOptions write FStreetViewControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Tilt.txt)
    property Tilt: Integer read FTilt write SetTilt default 0;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Zoom.txt)
    property Zoom: Integer read FZoom write SetZoom default 8;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ZoomControl.txt)
    property ZoomControl: Boolean read FZoomControl write SetZoomControl default True;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ZoomControlOptions.txt)
    property ZoomControlOptions: TGMZoomControlOptions read FZoomControlOptions write FZoomControlOptions;
  public
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Destroy.txt)
    destructor Destroy; override;

    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMTrafficLayer.txt)
  TGMTrafficLayer = class(TGMPersistentStr)
  private
    FTrafficLayerOptions: TGMTrafficLayerOptions;
    FShow: Boolean;
    procedure SetShow(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMTrafficLayer.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Map.TGMTrafficLayer.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Map.TGMTrafficLayer.Show.txt)
    property Show: Boolean read FShow write SetShow;
    // @include(..\Help\docs\GMLib.Map.TGMTrafficLayer.AutoRefresh.txt)
    property TrafficLayerOptions: TGMTrafficLayerOptions read FTrafficLayerOptions write FTrafficLayerOptions;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMCustomMap.txt)
  TGMCustomMap = class(TGMComponent, IGMExecJS, IGMControlChanges)
  private
    FIntervalEvents: Integer;
    FAPILang: TGMAPILang;
    FPrecision: Integer;
    FAPIKey: string;
    FAPIVer: TGMAPIVer;
    FActive: Boolean;
    FAPIRegion: TGMAPIRegion;
    FOnPrecisionChange: TNotifyEvent;
    FOnPropertyChanges: TGMPropertyChangesEvent;
    FOnActiveChange: TNotifyEvent;
    FOnIntervalEventsChange: TNotifyEvent;
    FOnBoundsChanged: TGMBoundsChangedEvent;
    FOnCenterChanged: TGMLatLngEvent;
    FOnContextmenu: TGMLatLngEvent;
    FOnMouseMove: TGMLatLngEvent;
    FOnMouseOut: TGMLatLngEvent;
    FOnDblClick: TGMLatLngEvent;
    FOnMouseOver: TGMLatLngEvent;
    FOnClick: TGMLatLngEvent;
    FOnDrag: TNotifyEvent;
    FOnDragStart: TNotifyEvent;
    FOnDragEnd: TNotifyEvent;
    FOnMapTypeIdChanged: TGMMapTypeIdChangedEvent;
    FOnZoomChanged: TGMZoomChangedEvent;
    FAfterPageLoaded: TGMAfterPageLoaded;
    procedure SetActive(const Value: Boolean);
    procedure SetAPILang(const Value: TGMAPILang);
    procedure SetAPIKey(const Value: string);
    procedure SetAPIVer(const Value: TGMAPIVer);
    procedure SetAPIRegion(const Value: TGMAPIRegion);
    procedure SetIntervalEvents(const Value: Integer);
    procedure SetPrecision(const Value: Integer);

    function GetEventsFired(Val: THTMLForms; var EF: TGMEventsFired): Boolean;
    procedure GetMapEvent(Val: THTMLForms);
  protected
    // @exclude Indicates if the map is being updated.
    FIsUpdating: Boolean;
    // @exclude Indicates if the Web page is fully loaded.
    FDocLoaded: Boolean;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.FBrowser.txt)
    FBrowser: TComponent;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(FunctName, Params: string); virtual; abstract;
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.GetJsonFromHTMLForms.txt)
    function GetJsonFromHTMLForms: string; virtual; abstract;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetCenterProperty.txt)
    procedure SetCenterProperty(LatLng: TGMLatLng); virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetMapTypeIdProperty.txt)
    procedure SetMapTypeIdProperty(MapTypeId: TGMMapTypeId); virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetZoomProperty.txt)
    procedure SetZoomProperty(Zoom: Integer); virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.DoOpenMap.txt)
    procedure DoOpenMap; virtual;

    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadMap.txt)
    procedure LoadMap; virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadBlankPage.txt)
    procedure LoadBlankPage; virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetEnableTimer.txt)
    procedure SetEnableTimer(State: Boolean); virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetIntervalTimer.txt)
    procedure SetIntervalTimer(Interval: Integer); virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.GetHTMLCode.txt)
    function GetHTMLCode: string;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnTimer.txt)
    procedure OnTimer(Sender: TObject); virtual;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Active.txt)
    property Active: Boolean read FActive write SetActive default False;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIVer.txt)
    property APIVer: TGMAPIVer read FAPIVer write SetAPIVer default avWeekly;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIKey.txt)
    property APIKey: string read FAPIKey write SetAPIKey;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APILang.txt)
    property APILang: TGMAPILang read FAPILang write SetAPILang default lEnglish;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIRegion.txt)
    property APIRegion: TGMAPIRegion read FAPIRegion write SetAPIRegion default rUndefined;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.IntervalEvents.txt)
    property IntervalEvents: Integer read FIntervalEvents write SetIntervalEvents default 50;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnActiveChange.txt)
    property OnActiveChange: TNotifyEvent read FOnActiveChange write FOnActiveChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange: TNotifyEvent read FOnIntervalEventsChange write FOnIntervalEventsChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnPrecisionChange.txt)
    property OnPrecisionChange: TNotifyEvent read FOnPrecisionChange write FOnPrecisionChange;
    // @include(..\Help\docs\GMLib.Events.TGMPropertyChangesEvent.txt)
    property OnPropertyChanges: TGMPropertyChangesEvent read FOnPropertyChanges write FOnPropertyChanges;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnBoundsChanged.txt)
    property OnBoundsChanged: TGMBoundsChangedEvent read FOnBoundsChanged write FOnBoundsChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnCenterChanged.txt)
    property OnCenterChanged: TGMLatLngEvent read FOnCenterChanged write FOnCenterChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnClick.txt)
    property OnClick: TGMLatLngEvent read FOnClick write FOnClick;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDblClick.txt)
    property OnDblClick: TGMLatLngEvent read FOnDblClick write FOnDblClick;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseMove.txt)
    property OnMouseMove: TGMLatLngEvent read FOnMouseMove write FOnMouseMove;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseOut.txt)
    property OnMouseOut: TGMLatLngEvent read FOnMouseOut write FOnMouseOut;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseOver.txt)
    property OnMouseOver: TGMLatLngEvent read FOnMouseOver write FOnMouseOver;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnContextmenu.txt)
    property OnContextmenu: TGMLatLngEvent read FOnContextmenu write FOnContextmenu;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDrag.txt)
    property OnDrag: TNotifyEvent read FOnDrag write FOnDrag;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDragEnd.txt)
    property OnDragEnd: TNotifyEvent read FOnDragEnd write FOnDragEnd;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDragStart.txt)
    property OnDragStart: TNotifyEvent read FOnDragStart write FOnDragStart;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMapTypeIdChanged.txt)
    property OnMapTypeIdChanged: TGMMapTypeIdChangedEvent read FOnMapTypeIdChanged write FOnMapTypeIdChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnZoomChanged.txt)
    property OnZoomChanged: TGMZoomChangedEvent read FOnZoomChanged write FOnZoomChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.AfterPageLoaded.txt)
    property AfterPageLoaded: TGMAfterPageLoaded read FAfterPageLoaded write FAfterPageLoaded;
  public
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Create.txt)
    constructor Create(AOwner: TComponent); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Precision.txt)
    property Precision: Integer read FPrecision write SetPrecision default 0;
  end;

implementation

uses
  {$IFDEF DELPHI2010}
  System.IOUtils,
  {$ENDIF}
  {$IFDEF DELPHIXE2}
  System.Types, System.SysUtils,
  {$ELSE}
  Windows, SysUtils,
  {$ENDIF}

  GMLib.Exceptions, GMLib.Constants, GMLib.Transform;

{ TGMCustomMap }

procedure TGMCustomMap.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomMap then
  begin
    Active := TGMCustomMap(Source).Active;
    APIVer := TGMCustomMap(Source).APIVer;
    APIKey := TGMCustomMap(Source).APIKey;
    APILang := TGMCustomMap(Source).APILang;
    APIRegion := TGMCustomMap(Source).APIRegion;
    IntervalEvents := TGMCustomMap(Source).IntervalEvents;
    Precision := TGMCustomMap(Source).Precision;
  end;
end;

constructor TGMCustomMap.Create(AOwner: TComponent);
begin
  inherited;

  FActive := False;
  FAPIKey := '';
  FAPIVer := avWeekly;
  FAPILang := lEnglish;
  FAPIRegion := rUnited_States;
  FIntervalEvents := 50;
  FPrecision := 6;
  FBrowser := nil;

  FIsUpdating := False;
  FDocLoaded := False;
end;

destructor TGMCustomMap.Destroy;
begin
  SetActive(False);

  inherited;
end;

procedure TGMCustomMap.DoOpenMap;
var
  Params: string;
begin
  Params := PropToString;
  ExecuteJavaScript('setMapOptions', Params);
  ExecuteJavaScript('doMap', '');
end;

function TGMCustomMap.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#Map';
end;

function TGMCustomMap.GetEventsFired(Val: THTMLForms; var EF: TGMEventsFired): Boolean;
begin
  EF.Map := Val.EventsMap.EventsMapEventFired = '1';

  Result := EF.Map;
end;

function TGMCustomMap.GetHTMLCode: string;
var
  List: TStringList;
  Stream: TResourceStream;
  StrTmp: string;
begin
  if not Assigned(FBrowser) then
    raise EGMUnassignedObject.Create(['Browser'], Language);                    // Object %s unassigned.

  Result := '';

  Stream := nil;
  List := nil;
  try
    List := TStringList.Create;
    try
      Stream := TResourceStream.Create(HInstance, ct_RES_MAPA_CODE, RT_RCDATA);
    except
      raise EGMCanLoadResource.Create(Language);                                // Can't load map resource.
    end;

    List.LoadFromStream(Stream);

    // replaces API_KEY variable
    List.Text := StringReplace(List.Text, ct_API_KEY, FAPIKey, []);

    // replaces API_VER variable
    StrTmp := TGMTransform.APIVerToStr(FAPIVer);
    List.Text := StringReplace(List.Text, ct_API_VER, StrTmp, []);

    // replaces API_REGION variable
    StrTmp := LowerCase(TGMTransform.APIRegionToStr(FAPIRegion));
    List.Text := StringReplace(List.Text, ct_API_REGION, StrTmp, []);

    // replaces API_LAN variable
    StrTmp := LowerCase(TGMTransform.APILangToStr(FAPILang));
    List.Text := StringReplace(List.Text, ct_API_LAN, StrTmp, []);

    {$IFDEF DELPHI2010}
    StrTmp := TPath.GetTempPath + TPath.DirectorySeparatorChar + ct_FILE_NAME;
    {$ELSE}
    StrTmp := IncludeTrailingPathDelimiter(GetTempPath) + ct_FILE_NAME;
    {$ENDIF}
    List.SaveToFile(StrTmp);

    Result := StrTmp;
  finally
    if Assigned(Stream) then Stream.Free;
    if Assigned(List) then List.Free;
  end;
end;

procedure TGMCustomMap.GetMapEvent(Val: THTMLForms);
var
  LLB: TGMLatLngBounds;
  LL: TGMLatLng;
  MTId: TGMMapTypeId;
  TmpInt: Integer;
  TmpLat: Double;
  TmpLng: Double;
begin
  // Map bounds_changed
  if Assigned(FOnBoundsChanged) and (Val.EventsMap.EventsMapBoundsChange = '1') then
  begin
    LLB := TGMLatLngBounds.Create(
                                  TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapSwLat),
                                  TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapSwLng),
                                  TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapNeLat),
                                  TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapNeLng),
                                  Language
                                 );
    try
      FOnBoundsChanged(Self, LLB);
    finally
      FreeAndNil(LLB);
    end;
  end;

  // Map center_changed, click, dblclick, mousemove, mouseout, mouseover, rightclick
  if (Val.EventsMap.EventsMapCenterChange = '1') or (Val.EventsMap.EventsMapClick = '1') or
     (Val.EventsMap.EventsMapDblclick = '1') or (Val.EventsMap.EventsMapMouseMove = '1') or
     (Val.EventsMap.EventsMapMouseOut = '1') or (Val.EventsMap.EventsMapMouseOver = '1') or
     (Val.EventsMap.EventsMapContextmenu = '1')
  then
  begin
    TmpLat := TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapLat);
    TmpLng := TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapLng);
    LL := TGMLatLng.Create(
                           TmpLat,
                           TmpLng,
                           False,
                           Language
                          );
    try
      if Val.EventsMap.EventsMapCenterChange = '1' then
      begin
        if not FIsUpdating then
        begin
          FIsUpdating := True;
          SetCenterProperty(LL);
        end;
        FIsUpdating := False;
        if Assigned(FOnCenterChanged) then
          FOnCenterChanged(Self,
                           LL,
                           TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapX),
                           TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapY)
                          );
      end;
      if (Val.EventsMap.EventsMapClick = '1') and Assigned(FOnClick) then
        FOnClick(Self, LL, TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapX), TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapY));
      if (Val.EventsMap.EventsMapDblclick = '1') and Assigned(FOnDblClick) then
        FOnDblClick(Self, LL, TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapX), TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapY));
      if (Val.EventsMap.EventsMapMouseMove = '1') and Assigned(FOnMouseMove) then
        FOnMouseMove(Self, LL, TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapX), TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapY));
      if (Val.EventsMap.EventsMapMouseOut = '1') and Assigned(FOnMouseOut) then
        FOnMouseOut(Self, LL, TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapX), TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapY));
      if (Val.EventsMap.EventsMapMouseOver = '1') and Assigned(FOnMouseOver) then
        FOnMouseOver(Self, LL, TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapX), TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapY));
      if (Val.EventsMap.EventsMapContextmenu = '1') and Assigned(FOnContextmenu) then
        FOnContextmenu(Self, LL, TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapX), TGMTransform.GetStrToDouble(Val.EventsMap.EventsMapY));
    finally
      FreeAndNil(LL);
    end;
  end;

  // Map drag, dargend, dragstart
  if (Val.EventsMap.EventsMapDrag = '1') and Assigned(FOnDrag) then
    FOnDrag(Self);
  if (Val.EventsMap.EventsMapDragEnd = '1') and Assigned(FOnDragEnd) then
  begin
    if Assigned(FOnDragEnd) then
      FOnDragEnd(Self);
  end;
  if (Val.EventsMap.EventsMapDragStart = '1') and Assigned(FOnDragStart) then
    FOnDragStart(Self);

  // Map MapTypeIdChanged
  if Val.EventsMap.EventsMapMapTypeId_changed = '1' then
  begin
    if not FIsUpdating then
    begin
      FIsUpdating := True;
      MTId := TGMTransform.StrToMapTypeId(Val.EventsMap.EventsMapMapTypeId);
      SetMapTypeIdProperty(MTId);
      if Assigned(FOnMapTypeIdChanged) then
        FOnMapTypeIdChanged(Self, MTId);
    end;
    FIsUpdating := False;
  end;

  // Map TilesLoaded
  if (Val.EventsMap.EventsMapTilesLoaded = '1') and Assigned(FAfterPageLoaded) then
    FAfterPageLoaded(Self, False);

  // Map ZoomChanged
  if Val.EventsMap.EventsMapZoomChanged = '1' then
  begin
    if not FIsUpdating then
    begin
      FIsUpdating := True;
      TmpInt := TGMTransform.GetStrToInteger(Val.EventsMap.EventsMapZoom, 8);
      SetZoomProperty(TmpInt);
      if Assigned(FOnZoomChanged) then
        FOnZoomChanged(Self, TmpInt);
    end;
    FIsUpdating := False;
  end;
end;

procedure TGMCustomMap.OnTimer(Sender: TObject);
var
  EventFired: TGMEventsFired;
  Val: THTMLForms;
begin
  SetEnableTimer(False);
  try
    if csDesigning in ComponentState then Exit;
    if not Assigned(FBrowser) or not FDocLoaded then Exit;
    Val := THTMLForms.GetData(Self);    // read HTML forms
    THTMLForms.IniData(Self);           // initialize HTML forms (after read)
    if not GetEventsFired(Val, EventFired) then Exit;

    if EventFired.Map then
      GetMapEvent(Val);
  finally
    SetEnableTimer(True);
  end;
end;

procedure TGMCustomMap.PropertyChanged(Prop: TPersistent; PropName: string);
(*
const
  Str1 = '%s';
  Str2 = '%s,%s';
*)
var
  Params: string;
begin
  if not FActive then Exit;
  if csDesigning in ComponentState then Exit;

  if FIsUpdating then
    Exit;

  Params := PropToString;
  ExecuteJavaScript('setMapOptions', Params);

(*
  if (Prop is TGMCustomMapOptions) and SameText(PropName, 'Zoom') then
    ExecuteJavaScript('MapChangeProperty', Format(Str2, [
                                                         QuotedStr(PropName),
                                                         IntToStr(TGMCustomMapOptions(Prop).Zoom)
                                                        ]));
  if (Prop is TGMLatLng) then
    ExecuteJavaScript('MapChangeCenter', Format(Str1, [
                                                       TGMLatLng(Prop).PropToString
                                                      ]));
*)

  if Assigned(FOnPropertyChanges) then FOnPropertyChanges(Prop, PropName);
end;

procedure TGMCustomMap.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;

  FActive := Value;

  if csDesigning in ComponentState then Exit;

  if not Assigned(FBrowser) then Exit;

  if FActive then
    LoadMap
  else
    LoadBlankPage;

  SetEnableTimer(FActive);

  if Assigned(FOnActiveChange) then
    FOnActiveChange(Self);
end;

procedure TGMCustomMap.SetAPILang(const Value: TGMAPILang);
begin
  if FAPILang = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPILang := Value;

  if Assigned(FOnPropertyChanges) then
    FOnPropertyChanges(Self, 'APILang');
end;

procedure TGMCustomMap.SetAPIRegion(const Value: TGMAPIRegion);
begin
  if FAPIRegion = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPIRegion := Value;

  if Assigned(FOnPropertyChanges) then
    FOnPropertyChanges(Self, 'APIRegion');
end;

procedure TGMCustomMap.SetAPIKey(const Value: string);
begin
  if FAPIKey = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPIKey := Value;

  if Assigned(FOnPropertyChanges) then
    FOnPropertyChanges(Self, 'APIKey');
end;

procedure TGMCustomMap.SetAPIVer(const Value: TGMAPIVer);
begin
  if FAPIVer = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPIVer := Value;

  if Assigned(FOnPropertyChanges) then
    FOnPropertyChanges(Self, 'APIVer');
end;

procedure TGMCustomMap.SetIntervalEvents(const Value: Integer);
begin
  if FIntervalEvents = Value then Exit;

  FIntervalEvents := Value;
  SetIntervalTimer(FIntervalEvents);

  if csDesigning in ComponentState then Exit;

  if Assigned(FOnIntervalEventsChange) then
    FOnIntervalEventsChange(Self);
end;

procedure TGMCustomMap.SetPrecision(const Value: Integer);
begin
  if FPrecision = Value then Exit;

  FPrecision := Value;

  if FPrecision < 0 then FPrecision := 0;
  if FPrecision > 17 then FPrecision := 17;

  if csDesigning in ComponentState then Exit;

  if Assigned(FOnPrecisionChange) then
    FOnPrecisionChange(Self);
end;

{ TGMCustomMapOptions }

procedure TGMCustomMapOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomMapOptions then
  begin
    Center.Assign(TGMCustomMapOptions(Source).Center);
    ClickableIcons := TGMCustomMapOptions(Source).ClickableIcons;
    DisableDoubleClickZoom := TGMCustomMapOptions(Source).DisableDoubleClickZoom;
    DraggableCursor := TGMCustomMapOptions(Source).DraggableCursor;
    DraggingCursor := TGMCustomMapOptions(Source).DraggingCursor;
    FullScreenControl := TGMCustomMapOptions(Source).FullScreenControl;
    FullScreenControlOptions.Assign(TGMCustomMapOptions(Source).FullScreenControlOptions);
    GestureHandling := TGMCustomMapOptions(Source).GestureHandling;
    Heading := TGMCustomMapOptions(Source).Heading;
    IsFractionalZoomEnabled := TGMCustomMapOptions(Source).IsFractionalZoomEnabled;
    KeyboardShortcuts := TGMCustomMapOptions(Source).KeyboardShortcuts;
    MapTypeControl := TGMCustomMapOptions(Source).MapTypeControl;
    MapTypeControlOptions.Assign(TGMCustomMapOptions(Source).MapTypeControlOptions);
    MapTypeId := TGMCustomMapOptions(Source).MapTypeId;
    MaxZoom := TGMCustomMapOptions(Source).MaxZoom;
    MinZoom := TGMCustomMapOptions(Source).MinZoom;
    NoClear := TGMCustomMapOptions(Source).NoClear;
    Restriction.Assign(TGMCustomMapOptions(Source).Restriction);
    RotateControl := TGMCustomMapOptions(Source).RotateControl;
    RotateControlOptions.Assign(TGMCustomMapOptions(Source).RotateControlOptions);
    ScaleControl := TGMCustomMapOptions(Source).ScaleControl;
    ScaleControlOptions.Assign(TGMCustomMapOptions(Source).ScaleControlOptions);
    StreetViewControl := TGMCustomMapOptions(Source).StreetViewControl;
    StreetViewControlOptions.Assign(TGMCustomMapOptions(Source).StreetViewControlOptions);
    Tilt := TGMCustomMapOptions(Source).Tilt;
    Zoom := TGMCustomMapOptions(Source).Zoom;
    ZoomControl := TGMCustomMapOptions(Source).ZoomControl;
    ZoomControlOptions.Assign(TGMCustomMapOptions(Source).ZoomControlOptions);
  end;
end;

constructor TGMCustomMapOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FCenter := TGMLatLng.Create(Self, 0, 0, False);
  FClickableIcons := True;
  FDisableDoubleClickZoom := True;
  FDraggableCursor := '';
  FDraggingCursor := '';
  FFullScreenControl := True;
  FFullScreenControlOptions := TGMFullScreenControlOptions.Create(Self);
  FGestureHandling := ghAuto;
  FHeading := 0;
  FIsFractionalZoomEnabled := True;
  FKeyboardShortcuts := True;
  FMapTypeControl := True;
  FMapTypeControlOptions := TGMMapTypeControlOptions.Create(Self);
  FMapTypeId := mtROADMAP;
  FMaxZoom := 0;
  FMinZoom := 0;
  FNoClear := False;
  FRestriction := TGMRestriction.Create(Self);
  FRotateControl := True;
  FRotateControlOptions := TGMRotateControlOptions.Create(Self);
  FScaleControl := True;
  FScaleControlOptions := TGMScaleControlOptions.Create(Self);
  FStreetViewControl := True;
  FStreetViewControlOptions := TGMStreetViewControlOptions.Create(Self);
  FTilt := 0;
  FZoom := 8;
  FZoomControl := True;
  FZoomControlOptions := TGMZoomControlOptions.Create(Self);
end;

destructor TGMCustomMapOptions.Destroy;
begin
  if Assigned(FCenter) then FCenter.Free;
  if Assigned(FFullScreenControlOptions) then FFullScreenControlOptions.Free;
  if Assigned(FMapTypeControlOptions) then FMapTypeControlOptions.Free;
  if Assigned(FRestriction) then FRestriction.Free;
  if Assigned(FRotateControlOptions) then FRotateControlOptions.Free;
  if Assigned(FScaleControlOptions) then FScaleControlOptions.Free;
  if Assigned(FStreetViewControlOptions) then FStreetViewControlOptions.Free;
  if Assigned(FZoomControlOptions) then FZoomControlOptions.Free;

  inherited;
end;

function TGMCustomMapOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#MapOptions';
end;

procedure TGMCustomMapOptions.PropertyChanged(Prop: TPersistent;
  PropName: string);
var
  Intf: IGMControlChanges;
begin
  if (GetOwner <> nil) and Supports(GetOwner, IGMControlChanges, Intf) then
  begin
    if Assigned(Prop) then
      Intf.PropertyChanged(Prop, PropName)
    else
      Intf.PropertyChanged(Self, PropName);
  end
  else
    if Assigned(OnChange) then OnChange(Self);
end;

function TGMCustomMapOptions.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         FCenter.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FClickableIcons, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FDisableDoubleClickZoom, True)),
                         QuotedStr(FDraggableCursor),
                         QuotedStr(FDraggingCursor),
                         LowerCase(TGMTransform.GMBoolToStr(FFullScreenControl, True)),
                         FFullScreenControlOptions.PropToString,
                         QuotedStr(TGMTransform.GestureHandlingToStr(FGestureHandling)),
                         IntToStr(FHeading),
                         LowerCase(TGMTransform.GMBoolToStr(FIsFractionalZoomEnabled, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FKeyboardShortcuts, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FMapTypeControl, True)),
                         FMapTypeControlOptions.PropToString,
                         QuotedStr(TGMTransform.MapTypeIdToStr(FMapTypeId)),
                         IntToStr(FMaxZoom),
                         IntToStr(FMinZoom),
                         LowerCase(TGMTransform.GMBoolToStr(FNoClear, True)),
                         FRestriction.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FRotateControl, True)),
                         FRotateControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FScaleControl, True)),
                         FScaleControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FStreetViewControl, True)),
                         FStreetViewControlOptions.PropToString,
                         IntToStr(FTilt),
                         IntToStr(FZoom),
                         LowerCase(TGMTransform.GMBoolToStr(FZoomControl, True)),
                         FZoomControlOptions.PropToString
                         ]);
end;

procedure TGMCustomMapOptions.SetClickableIcons(const Value: Boolean);
begin
  if FClickableIcons = Value then Exit;

  FClickableIcons := Value;
  ControlChanges('ClickableIcons');
end;

procedure TGMCustomMapOptions.SetDisableDoubleClickZoom(const Value: Boolean);
begin
  if FDisableDoubleClickZoom = Value then Exit;

  FDisableDoubleClickZoom := Value;
  ControlChanges('DisableDoubleClickZoom');
end;

procedure TGMCustomMapOptions.SetDraggableCursor(const Value: string);
begin
  if FDraggableCursor = Value then Exit;

  FDraggableCursor := Value;
  ControlChanges('DraggableCursor');
end;

procedure TGMCustomMapOptions.SetDraggingCursor(const Value: string);
begin
  if FDraggingCursor = Value then Exit;

  FDraggingCursor := Value;
  ControlChanges('DraggingCursor');
end;

procedure TGMCustomMapOptions.SetFullScreenControl(const Value: Boolean);
begin
  if FFullScreenControl = Value then Exit;

  FFullScreenControl := Value;
  ControlChanges('FullScreenControl');
end;

procedure TGMCustomMapOptions.SetGestureHandling(
  const Value: TGMGestureHandling);
begin
  if FGestureHandling = Value then Exit;

  FGestureHandling := Value;
  ControlChanges('GestureHandling');
end;

procedure TGMCustomMapOptions.SetHeading(const Value: Integer);
begin
  if FHeading = Value then Exit;

  FHeading := Value;
  ControlChanges('Heading');
end;

procedure TGMCustomMapOptions.SetIsFractionalZoomEnabled(const Value: Boolean);
begin
  if FIsFractionalZoomEnabled = Value then Exit;

  FIsFractionalZoomEnabled := Value;
  ControlChanges('IsFractionalZoomEnabled');
end;

procedure TGMCustomMapOptions.SetKeyboardShortcuts(const Value: Boolean);
begin
  if FKeyboardShortcuts = Value then Exit;

  FKeyboardShortcuts := Value;
  ControlChanges('KeyboardShortcuts');
end;

procedure TGMCustomMapOptions.SetMapTypeControl(const Value: Boolean);
begin
  if FMapTypeControl = Value then Exit;

  FMapTypeControl := Value;
  ControlChanges('MapTypeControl');
end;

procedure TGMCustomMapOptions.SetMapTypeId(const Value: TGMMapTypeId);
begin
  if FMapTypeId = Value then Exit;

  FMapTypeId := Value;
  ControlChanges('MapTypeId');
end;

procedure TGMCustomMapOptions.SetMaxZoom(const Value: Integer);
begin
  if FMaxZoom = Value then Exit;

  FMaxZoom := Value;
  ControlChanges('MaxZoom');
end;

procedure TGMCustomMapOptions.SetMinZoom(const Value: Integer);
begin
  if FMinZoom = Value then Exit;

  FMinZoom := Value;
  ControlChanges('MinZoom');
end;

procedure TGMCustomMapOptions.SetNoClear(const Value: Boolean);
begin
  if FNoClear = Value then Exit;

  FNoClear := Value;
  ControlChanges('NoClear');
end;

procedure TGMCustomMapOptions.SetRotateControl(const Value: Boolean);
begin
  if FRotateControl = Value then Exit;

  FRotateControl := Value;
  ControlChanges('RotateControl');
end;

procedure TGMCustomMapOptions.SetScaleControl(const Value: Boolean);
begin
  if FScaleControl = Value then Exit;

  FScaleControl := Value;
  ControlChanges('ScaleControl');
end;

procedure TGMCustomMapOptions.SetStreetViewControl(const Value: Boolean);
begin
  if FStreetViewControl = Value then Exit;

  FStreetViewControl := Value;
  ControlChanges('StreetViewControl');
end;

procedure TGMCustomMapOptions.SetTilt(const Value: Integer);
begin
  if FTilt = Value then Exit;

  FTilt := Value;
  ControlChanges('Tilt');
end;

procedure TGMCustomMapOptions.SetZoom(const Value: Integer);
begin
  if FZoom = Value then Exit;

  FZoom := Value;
  ControlChanges('Zoom');
end;

procedure TGMCustomMapOptions.SetZoomControl(const Value: Boolean);
begin
  if FZoomControl = Value then Exit;

  FZoomControl := Value;
  ControlChanges('ZoomControl');
end;

{ TGMFullScreenControlOptions }

procedure TGMFullScreenControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMFullScreenControlOptions then
  begin
    Position := TGMFullScreenControlOptions(Source).Position;
  end;
end;

constructor TGMFullScreenControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpRIGHT_TOP;
end;

function TGMFullScreenControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#FullscreenControlOptions';
end;

function TGMFullScreenControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(FPosition))
                        ]);
end;

procedure TGMFullScreenControlOptions.SetPosition(
  const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges('Position');
end;

{ TGMMapTypeControlOptions }

procedure TGMMapTypeControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMMapTypeControlOptions then
  begin
    MapTypeIds := TGMMapTypeControlOptions(Source).MapTypeIds;
    Position := TGMMapTypeControlOptions(Source).Position;
    Style := TGMMapTypeControlOptions(Source).Style;
  end;
end;

constructor TGMMapTypeControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpTOP_RIGHT;
  FStyle := mtcDEFAULT;
  FMapTypeIds := [mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN];
end;

function TGMMapTypeControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#MapTypeControlOptions';
end;

function TGMMapTypeControlOptions.PropToString: string;
const
  Str = '%s,%s,%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.MapTypeIdsToStr(FMapTypeIds, ';')),
                         QuotedStr(TGMTransform.PositionToStr(FPosition)),
                         QuotedStr(TGMTransform.MapTypeControlStyleToStr(FStyle))
                        ]);
end;

procedure TGMMapTypeControlOptions.SetMapTypeIds(const Value: TGMMapTypeIds);
begin
  if FMapTypeIds = Value then Exit;

  FMapTypeIds := Value;
  ControlChanges('MapTypeIds');
end;

procedure TGMMapTypeControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges('Position');
end;

procedure TGMMapTypeControlOptions.SetStyle(const Value: TGMMapTypeControlStyle);
begin
  if FStyle = Value then Exit;

  FStyle := Value;
  ControlChanges('Style');
end;

{ TGMRestriction }

procedure TGMRestriction.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMRestriction then
  begin
    LatLngBounds.Assign(TGMRestriction(Source).LatLngBounds);
    StrictBounds := TGMRestriction(Source).StrictBounds;
    Enabled := TGMRestriction(Source).Enabled;
  end;
end;

constructor TGMRestriction.Create(AOwner: TPersistent);
begin
  inherited;

  FLatLngBounds := TGMLatLngBounds.Create(Self);
  FStrictBounds := False;
  FEnabled := False;
end;

destructor TGMRestriction.Destroy;
begin
  if Assigned(FLatLngBounds) then FLatLngBounds.Free;

  inherited;
end;

function TGMRestriction.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#MapRestriction';
end;

function TGMRestriction.PropToString: string;
const
  Str = '%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         FLatLngBounds.ToUrlValue,
                         LowerCase(TGMTransform.GMBoolToStr(FStrictBounds, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FEnabled, True))
                        ]);
end;

procedure TGMRestriction.SetEnabled(const Value: Boolean);
begin
  if FEnabled = Value then Exit;

  FEnabled := Value;
  ControlChanges('Enabled');
end;

procedure TGMRestriction.SetStrictBounds(const Value: Boolean);
begin
  if FStrictBounds = Value then Exit;

  FStrictBounds := Value;
  ControlChanges('StrictBounds');
end;

{ TGMRotateControlOptions }

procedure TGMRotateControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMRotateControlOptions then
  begin
    Position := TGMRotateControlOptions(Source).Position;
  end;
end;

constructor TGMRotateControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpTOP_LEFT;
end;

function TGMRotateControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#RotateControlOptions';
end;

function TGMRotateControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(FPosition))
                        ]);
end;

procedure TGMRotateControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges('Position');
end;

{ TGMScaleControlOptions }

procedure TGMScaleControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMScaleControlOptions then
  begin
    Style := TGMScaleControlOptions(Source).Style;
  end;
end;

constructor TGMScaleControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FStyle := scsDEFAULT;
end;

function TGMScaleControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#ScaleControlOptions';
end;

function TGMScaleControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.ScaleControlStyleToStr(Style))
                        ]);
end;

procedure TGMScaleControlOptions.SetStyle(const Value: TGMScaleControlStyle);
begin
  if FStyle = Value then Exit;

  FStyle := Value;
  ControlChanges('Style');
end;

{ TGMStreetViewControlOptions }

procedure TGMStreetViewControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMStreetViewControlOptions then
  begin
    Position := TGMStreetViewControlOptions(Source).Position;
  end;
end;

constructor TGMStreetViewControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpTOP_LEFT;
end;

function TGMStreetViewControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#StreetViewControlOptions';
end;

function TGMStreetViewControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(FPosition))
                        ]);
end;

procedure TGMStreetViewControlOptions.SetPosition(
  const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges('Position');
end;

{ TGMZoomControlOptions }

procedure TGMZoomControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMZoomControlOptions then
  begin
    Position := TGMZoomControlOptions(Source).Position;
  end;
end;

constructor TGMZoomControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpTOP_LEFT;
end;

function TGMZoomControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/control#ZoomControlOptions';
end;

function TGMZoomControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(FPosition))
                        ]);
end;

procedure TGMZoomControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges('Position');
end;

{ TGMTrafficLayer }

procedure TGMTrafficLayer.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TGMTrafficLayer.Create(AOwner: TPersistent);
begin
  inherited;

end;

destructor TGMTrafficLayer.Destroy;
begin

  inherited;
end;

function TGMTrafficLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#TrafficLayer';
end;

function TGMTrafficLayer.PropToString: string;
begin

end;

procedure TGMTrafficLayer.SetShow(const Value: Boolean);
begin
  if FShow = Value then Exit;

  FShow := Value;
  ControlChanges('Show');
end;

end.
