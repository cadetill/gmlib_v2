{
  @abstract(@code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Septembre 30, 2015)
  @lastmod(October 1, 2015)

  The GMMap contains the implementation of TCustomGMMap class that encapsulate the @code(google.maps.Map) class from Google Maps API and other related classes.
}
unit GMMap;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils, System.Classes,
  {$ELSE}
  SysUtils, Classes,
  {$ENDIF}

  GMClasses, GMLatLng, GMLatLngBounds, GMSets;

type
  {
    @abstract(@code(google.maps.MapTypeControlOptions) object from Google Maps API.)
    Options for the rendering of the map type control.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapTypeControlOptions
  }
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
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // IDs of map types to show in the control.
    property MapTypeIds: TGMMapTypeIds read FMapTypeIds write SetMapTypeIds default [mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN, mtOSM];
    // Position id. Used to specify the position of the control on the map.
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_RIGHT;
    // Style id. Used to select what style of map type control to display.
    property Style: TGMMapTypeControlStyle read FStyle write SetStyle default mtcDEFAULT;
  end;

  {
    @abstract(@code(google.maps.OverviewMapControlOptions) object from Google Maps API.)
    Options for the rendering of the Overview Map control.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#OverviewMapControlOptions
  }
  TGMOverviewMapControlOptions = class(TGMPersistentStr)
  private
    FOpened: Boolean;
    procedure SetOpened(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // Whether the control should display in opened mode or collapsed (minimized) mode.
    property Opened: Boolean read FOpened write SetOpened default False;
  end;

  {
    @abstract(@code(google.maps.PanControlOptions) object from Google Maps API.)
    Options for the rendering of the pan control.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#PanControlOptions
  }
  TGMPanControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // Position id. Used to specify the position of the control on the map.
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  {
    @abstract(@code(google.maps.RotateControlOptions) object from Google Maps API.)
    Options for the rendering of the rotate control.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#RotateControlOptions
  }
  TGMRotateControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // Position id. Used to specify the position of the control on the map.
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  {
    @abstract(@code(google.maps.ScaleControlOptions) object from Google Maps API.)
    Options for the rendering of the scale control.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#ScaleControlOptions
  }
  TGMScaleControlOptions = class(TGMPersistentStr)
  private
    FStyle: TGMScaleControlStyle;
    procedure SetStyle(const Value: TGMScaleControlStyle);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // Style id. Used to select what style of scale control to display.
    property Style: TGMScaleControlStyle read FStyle write SetStyle default scDEFAULT;
  end;

  {
    @abstract(@code(google.maps.ZoomControlOptions) object from Google Maps API.)
    Options for the rendering of the zoom control.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#ZoomControlOptions
  }
  TGMZoomControlOptions = class(TGMPersistentStr)
  private
    FStyle: TGMZoomControlStyle;
    FPosition: TGMControlPosition;
    procedure SetStyle(const Value: TGMZoomControlStyle);
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // Position id. Used to specify the position of the control on the map.
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
    // Style id. Used to select what style of scale control to display.
    property Style: TGMZoomControlStyle read FStyle write SetStyle default zcDEFAULT;
  end;

  {
    @abstract(@code(google.maps.StreetViewControlOptions) object from Google Maps API.)
    Options for the rendering of the Street View pegman control on the map.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#StreetViewControlOptions
  }
  TGMStreetViewControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // Position id. Used to specify the position of the control on the map. The default position is embedded within the navigation (zoom and pan) controls. If this position is the same as that specified in the ZoomControlOptions or PanControlOptions, the Street View control will be displayed as part of the navigation controls. Otherwise, it will be displayed separately.
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  {
    @abstract(Base class for @code(google.maps.MapTypeStyler) object from Google Maps API.)
    A styler affects how a map's elements will be styled. Each MapTypeStyler should contain one and only one key. If more than one key is specified in a single MapTypeStyler, all but one will be ignored.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyler
  }
  TGMCustomMapTypeStyler = class(TGMInterfacedCollectionItem)
  private
    FSaturation: Integer;
    FGamma: Real;
    FLightness: Integer;
    FInvertLightness: Boolean;
    FVisibility: TGMVisibility;
    FWeight: Integer;
    procedure SetGamma(const Value: Real);
    procedure SetInvertLightness(const Value: Boolean);
    procedure SetLightness(const Value: Integer);
    procedure SetSaturation(const Value: Integer);
    procedure SetVisibility(const Value: TGMVisibility);
    procedure SetWeight(const Value: Integer);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // Converts all class properties values to a string separated by semicolon.
    // @return string with all properties.
    function PropToString: string; override;

    // Modifies the gamma by raising the lightness to the given power.@br Valid values: Floating point numbers, [0.01, 10], with 1.0 representing no change.
    property Gamma: Real read FGamma write SetGamma;
    // A value of true will invert the lightness of the feature while preserving the hue and saturation.
    property InvertLightness: Boolean read FInvertLightness write SetInvertLightness default True;
    // Shifts lightness of colors by a percentage of the original value if decreasing and a percentage of the remaining value if increasing.@br Valid values: [-100, 100].
    property Lightness: Integer read FLightness write SetLightness default 0;
    // Shifts the saturation of colors by a percentage of the original value if decreasing and a percentage of the remaining value if increasing.@br Valid values: [-100, 100].
    property Saturation: Integer read FSaturation write SetSaturation default 0;
    // Sets the visibility of the feature.
    property Visibility: TGMVisibility read FVisibility write SetVisibility default vOn;
    // Sets the weight of the feature, in pixels.@br Valid values: Integers greater than or equal to zero.
    property Weight: Integer read FWeight write SetWeight default 0;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(Collection: TCollection); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;
  end;

  {
    @abstract(Base class for @code(google.maps.MapTypeStyle) object from Google Maps API.)
    The TMapTypeStyle is a collection of selectors and stylers that define how the map should be styled. Selectors specify what map elements should be affected and stylers specify how those elements should be modified.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyle
  }
  TGMCustomMapTypeStyle = class(TGMInterfacedCollectionItem)
  private
    FElementType: TGMMapTypeStyleElementType;
    FFeatureType: TGMMapTypeStyleFeatureType;
    procedure SetElementType(const Value: TGMMapTypeStyleElementType);
    procedure SetFeatureType(const Value: TGMMapTypeStyleFeatureType);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // Converts all class properties values to a string separated by semicolon.
    // @return string with all properties.
    function PropToString: string; override;

    // Selects the element type to which a styler should be applied. An element type distinguishes between the different representations of a feature.
    property ElementType: TGMMapTypeStyleElementType read FElementType write SetElementType default setALL;
    // Selects the feature, or group of features, to which a styler should be applied.
    property FeatureType: TGMMapTypeStyleFeatureType read FFeatureType write SetFeatureType default sftALL;
  public
    // @abstract(Constructor class.)
    // @param AOwner Object owner.
    // @param ItemClass Identifies the TCollectionItem descendants that must be used to represent the items in the collection.
    constructor Create(Collection: TCollection); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;
  end;

  {
    @abstract(@code(google.maps.StreetViewAddressControlOptions) object from Google Maps API.)
    Options for the rendering of the Street View address control.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#StreetViewAddressControlOptions
  }
  TGMStreetViewAddressControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // Position id. This id is used to specify the position of the control on the map.
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  {
    @abstract(@code(google.maps.StreetViewPov) object from Google Maps API.)
    A point of view object which specifies the camera's orientation at the Street View panorama's position. The point of view is defined as heading and pitch.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#StreetViewPov
  }
  TGMStreetViewPov = class(TGMPersistentStr)
  private
    FPitch: Integer;
    FHeading: Integer;
    procedure SetHeading(const Value: Integer);
    procedure SetPitch(const Value: Integer);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // The camera heading in degrees relative to true north. True north is 0°, east is 90°, south is 180°, west is 270°.
    property Heading: Integer read FHeading write SetHeading default 0;
    // The camera pitch in degrees, relative to the street view vehicle. Ranges from 90° (directly upwards) to -90° (directly downwards).
    property Pitch: Integer read FPitch write SetPitch default 0;
  end;

  {
    @abstract(@code(google.maps.StreetViewPanoramaOptions) object from Google Maps API.)
    Options defining the properties of a @code(StreetViewPanorama) object.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#StreetViewPanoramaOptions
  }
  TGMStreetViewPanoramaOptions = class(TGMPersistentStr)
  private
    FAddressControlOptions: TGMStreetViewAddressControlOptions;
    FScrollwheel: Boolean;
    FZoomControlOptions: TGMZoomControlOptions;
    FAddressControl: Boolean;
    FDisableDoubleClickZoom: Boolean;
    FClickToGo: Boolean;
    FZoomControl: Boolean;
    FPanControlOptions: TGMPanControlOptions;
    FLinksControl: Boolean;
    FVisible: Boolean;
    FPanControl: Boolean;
    FEnableCloseButton: Boolean;
    FPov: TGMStreetViewPov;
    FImageDateControl: Boolean;
    FDisableDefaultUI: Boolean;
    procedure SetAddressControl(const Value: Boolean);
    procedure SetClickToGo(const Value: Boolean);
    procedure SetDisableDefaultUI(const Value: Boolean);
    procedure SetDisableDoubleClickZoom(const Value: Boolean);
    procedure SetEnableCloseButton(const Value: Boolean);
    procedure SetImageDateControl(const Value: Boolean);
    procedure SetLinksControl(const Value: Boolean);
    procedure SetPanControl(const Value: Boolean);
    procedure SetScrollwheel(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetZoomControl(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;
    // @abstract(Destructor class.)
    destructor Destroy; override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;
  published
    // The enabled/disabled state of the address control.
    property AddressControl: Boolean read FAddressControl write SetAddressControl default True;
    // The display options for the address control.
    property AddressControlOptions: TGMStreetViewAddressControlOptions read FAddressControlOptions write FAddressControlOptions;
    // The enabled/disabled state of click-to-go.
    property ClickToGo: Boolean read FClickToGo write SetClickToGo default True;
    // Enables/disables all default UI. May be overridden individually.
    property DisableDefaultUI: Boolean read FDisableDefaultUI write SetDisableDefaultUI default False;
    // Enables/disables zoom on double click.
    property DisableDoubleClickZoom: Boolean read FDisableDoubleClickZoom write SetDisableDoubleClickZoom default False;
    // If true, the close button is displayed.
    property EnableCloseButton: Boolean read FEnableCloseButton write SetEnableCloseButton default True;
    // The enabled/disabled state of the imagery acquisition date control.
    property ImageDateControl: Boolean read FImageDateControl write SetImageDateControl default False;
    // The enabled/disabled state of the links control.
    property LinksControl: Boolean read FLinksControl write SetLinksControl default False;
    // The enabled/disabled state of the pan control.
    property PanControl: Boolean read FPanControl write SetPanControl default True;
    // The display options for the pan control.
    property PanControlOptions: TGMPanControlOptions read FPanControlOptions write FPanControlOptions;
    // The camera orientation, specified as heading and pitch, for the panorama.
    property Pov: TGMStreetViewPov read FPov write FPov;
    // If false, disables scrollwheel zooming in Street View.
    property Scrollwheel: Boolean read FScrollwheel write SetScrollwheel default True;
    // If true, the Street View panorama is visible on load.
    property Visible: Boolean read FVisible write SetVisible default False;
    // The enabled/disabled state of the zoom control.
    property ZoomControl: Boolean read FZoomControl write SetZoomControl default True;
    // The display options for the zoom control.
    property ZoomControlOptions: TGMZoomControlOptions read FZoomControlOptions write FZoomControlOptions;
  end;

  {
    @abstract(Base class for @code(google.maps.MapOptions) object from Google Maps API.)
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapOptions
  }
  TGMCustomMapOptions = class(TGMPersistentStr)
  private
    FTilt: Integer;
    FScrollwheel: Boolean;
    FNoClear: Boolean;
    FKeyboardShortcuts: Boolean;
    FDraggingCursor: string;
    FMinZoom: Integer;
    FDisableDoubleClickZoom: Boolean;
    FDraggable: Boolean;
    FMapTypeId: TGMMapTypeId;
    FHeading: Integer;
    FDraggableCursor: string;
    FDisableDefaultUI: Boolean;
    FCenter: TGMLatLng;
    FZoom: Integer;
    FMaxZoom: Integer;
    FMapMaker: Boolean;
    FMapTypeControl: Boolean;
    FMapTypeControlOptions: TGMMapTypeControlOptions;
    FOverviewMapControl: Boolean;
    FOverviewMapControlOptions: TGMOverviewMapControlOptions;
    FPanControlOptions: TGMPanControlOptions;
    FPanControl: Boolean;
    FRotateControl: Boolean;
    FRotateControlOptions: TGMRotateControlOptions;
    FScaleControlOptions: TGMScaleControlOptions;
    FScaleControl: Boolean;
    FStreetViewControlOptions: TGMStreetViewControlOptions;
    FStreetViewControl: Boolean;
    FZoomControl: Boolean;
    FZoomControlOptions: TGMZoomControlOptions;
    FStreetView: TGMStreetViewPanoramaOptions;
    procedure SetDisableDefaultUI(const Value: Boolean);
    procedure SetDisableDoubleClickZoom(const Value: Boolean);
    procedure SetDraggable(const Value: Boolean);
    procedure SetDraggableCursor(const Value: string);
    procedure SetDraggingCursor(const Value: string);
    procedure SetHeading(const Value: Integer);
    procedure SetKeyboardShortcuts(const Value: Boolean);
    procedure SetMapMaker(const Value: Boolean);
    procedure SetMapTypeId(const Value: TGMMapTypeId);
    procedure SetMaxZoom(const Value: Integer);
    procedure SetMinZoom(const Value: Integer);
    procedure SetNoClear(const Value: Boolean);
    procedure SetScrollwheel(const Value: Boolean);
    procedure SetTilt(const Value: Integer);
    procedure SetZoom(const Value: Integer);
    procedure SetMapTypeControl(const Value: Boolean);
    procedure SetOverviewMapControl(const Value: Boolean);
    procedure SetPanControl(const Value: Boolean);
    procedure SetRotateControl(const Value: Boolean);
    procedure SetScaleControl(const Value: Boolean);
    procedure SetStreetViewControl(const Value: Boolean);
    procedure SetZoomControl(const Value: Boolean);
  protected
    // Converts all class properties values to a string separated by semicolon.
    // @return string with all properties.
    function PropToString: string; override;

    // Contains the lat/lng coordinates with the center of the map.
    property Center: TGMLatLng read FCenter write FCenter;
    // Enables/disables all default UI. May be overridden individually.
    property DisableDefaultUI: Boolean read FDisableDefaultUI write SetDisableDefaultUI default False;
    // Enables/disables zoom and center on double click.
    property DisableDoubleClickZoom: Boolean read FDisableDoubleClickZoom write SetDisableDoubleClickZoom default True;
    // If false, prevents the map from being dragged.
    property Draggable: Boolean read FDraggable write SetDraggable default True;
    // The name or url of the cursor to display when mousing over a draggable map. This property uses the css cursor attribute to change the icon. As with the css property, you must specify at least one fallback cursor that is not a URL. For example: draggableCursor: 'url(http://www.example.com/icon.png), auto;'.
    property DraggableCursor: string read FDraggableCursor write SetDraggableCursor;
    // The name or url of the cursor to display when the map is being dragged. This property uses the css cursor attribute to change the icon. As with the css property, you must specify at least one fallback cursor that is not a URL. For example: draggingCursor: 'url(http://www.example.com/icon.png), auto;'.
    property DraggingCursor: string read FDraggingCursor write SetDraggingCursor;
    // The heading for aerial imagery in degrees measured clockwise from cardinal direction North. Headings are snapped to the nearest available angle for which imagery is available.
    property Heading: Integer read FHeading write SetHeading default 0;
    // If false, prevents the map from being controlled by the keyboard.
    property KeyboardShortcuts: Boolean read FKeyboardShortcuts write SetKeyboardShortcuts default True;
    // True if Map Maker tiles should be used instead of regular tiles.
    property MapMaker: Boolean read FMapMaker write SetMapMaker default False;
    // The initial enabled/disabled state of the Map type control.
    property MapTypeControl: Boolean read FMapTypeControl write SetMapTypeControl default True;
    // The initial display options for the Map type control.
    property MapTypeControlOptions: TGMMapTypeControlOptions read FMapTypeControlOptions write FMapTypeControlOptions;
    // The initial Map mapTypeId.
    property MapTypeId: TGMMapTypeId read FMapTypeId write SetMapTypeId default mtROADMAP;
    // The maximum zoom level which will be displayed on the map.
    property MaxZoom: Integer read FMaxZoom write SetMaxZoom default 0;
    // The minimum zoom level which will be displayed on the map.
    property MinZoom: Integer read FMinZoom write SetMinZoom default 0;
    // If true, do not clear the contents of the Map div.
    property NoClear: Boolean read FNoClear write SetNoClear default False;
    // The enabled/disabled state of the Overview Map control.@br Note: The Overview Map control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Overview Map control available as part of the old control set.
    property OverviewMapControl: Boolean read FOverviewMapControl write SetOverviewMapControl default True;
    // The display options for the Overview Map control.@br Note: The Overview Map control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Overview Map control available as part of the old control set.
    property OverviewMapControlOptions: TGMOverviewMapControlOptions read FOverviewMapControlOptions write FOverviewMapControlOptions;
    // The enabled/disabled state of the Pan control.@br Note: The Pan control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Pan control available as part of the old control set.
    property PanControl: Boolean read FPanControl write SetPanControl default True;
    // The display options for the Pan control.@br Note: The Pan control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Pan control available as part of the old control set.
    property PanControlOptions: TGMPanControlOptions read FPanControlOptions write FPanControlOptions;
    // The enabled/disabled state of the Rotate control.
    property RotateControl: Boolean read FRotateControl write SetRotateControl default True;
    // The display options for the Rotate control.
    property RotateControlOptions: TGMRotateControlOptions read FRotateControlOptions write FRotateControlOptions;
    // The initial enabled/disabled state of the Scale control.
    property ScaleControl: Boolean read FScaleControl write SetScaleControl default True;
    // The initial display options for the Scale control.
    property ScaleControlOptions: TGMScaleControlOptions read FScaleControlOptions write FScaleControlOptions;
    // If false, disables scrollwheel zooming on the map.
    property Scrollwheel: Boolean read FScrollwheel write SetScrollwheel default True;
    // A StreetViewPanorama to display when the Street View pegman is dropped on the map.
    property StreetView: TGMStreetViewPanoramaOptions read FStreetView write FStreetView;
    // The initial enabled/disabled state of the Street View Pegman control. This control is part of the default UI, and should be set to false when displaying a map type on which the Street View road overlay should not appear (e.g. a non-Earth map type).
    property StreetViewControl: Boolean read FStreetViewControl write SetStreetViewControl default True;
    // The initial display options for the Street View Pegman control.
    property StreetViewControlOptions: TGMStreetViewControlOptions read FStreetViewControlOptions write FStreetViewControlOptions;
    // Controls the automatic switching behavior for the angle of incidence of the map. The only allowed values are 0 and 45. The value 0 causes the map to always use a 0° overhead view regardless of the zoom level and viewport. The value 45 causes the tilt angle to automatically switch to 45 whenever 45° imagery is available for the current zoom level and viewport, and switch back to 0 whenever 45° imagery is not available (this is the default behavior). 45° imagery is only available for SATELLITE and HYBRID map types, within some locations, and at some zoom levels. Note: getTilt returns the current tilt angle, not the value specified by this option. Because getTilt and this option refer to different things, do not bind() the tilt property; doing so may yield unpredictable effects.
    property Tilt: Integer read FTilt write SetTilt default 0;
    // The initial Map zoom level.
    property Zoom: Integer read FZoom write SetZoom default 8;
    // The enabled/disabled state of the Zoom control.
    property ZoomControl: Boolean read FZoomControl write SetZoomControl default True;
    // The display options for the Zoom control.
    property ZoomControlOptions: TGMZoomControlOptions read FZoomControlOptions write FZoomControlOptions;
  public
    // @abstract(Constructor class.)
    // Creates a TGMCustomMapOptions object.
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;
    // @abstract(Destructor class.)
    destructor Destroy; override;

    // URL to Google Maps API class.
    function GetAPIUrl: string; override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;
  end;

  {
    @abstract(Base class for @code(google.maps.Map) class)
    More information at https://developers.google.com/maps/documentation/javascript/reference#Map
  }
  TGMCustomGMMap = class(TGMComponent)
  private
    FIsDoMap: Boolean;  // indicates if the map.html is loaded.

    FGoogleAPIVer: TGoogleAPIVer;
    FActive: Boolean;
    FGoogleAPIKey: string;
    FIntervalEvents: Integer;
    FOnActiveChange: TNotifyEvent;
    FOnIntervalEventsChange: TNotifyEvent;
    procedure SetGoogleAPIVer(const Value: TGoogleAPIVer);
    procedure SetActive(const Value: Boolean);
    procedure SetGoogleAPIKey(const Value: string);
    procedure SetIntervalEvents(const Value: Integer);
  protected
    // Browser where display the Google Maps map.
    FWebBrowser: TComponent;

    // Set the interval of Timer that control de map events. Internal use only.
    // @param Interval Interval in miliseconds
    procedure SetIntervalTimer(Interval: Integer); virtual; abstract;
    // LoadMap method loads and shows the map.html to use Google Maps API.
    procedure LoadMap; virtual; abstract;
    // LoadBlankPage method load the about:blank page.
    procedure LoadBlankPage; virtual; abstract;
    // Returns the HTML code of base map (map.html on gmmapres.res). Internal use only.
    // @return String with the HTML code
    function GetBaseHTMLCode: string;
    // OnTimer control event of Timer that check events from map. Internal use only.
    // @param Sender Object that fire event
    procedure OnTimer(Sender: TObject); virtual; (*1 *)

{
    procedure FitBounds(Bounds: TGMLatLngBounds);
    function GetBounds: TGMLatLngBounds;
    function GetCenter: TGMLatLng;
    function GetHeading: Real;
    function GetMapTypeId: TGMMapTypeId;
    function GetTilt: Real;
    function GetZoom: Integer;
    procedure PanBy(x, y: Integer);
    procedure PanTo(LatLng: TGMLatLng);
    procedure PanToBounds(LatLngBounds: TGMLatLngBounds);
    procedure SetCenter(Latlng: TGMLatLng);
    procedure SetHeading(Heading: Real);
    procedure SetMapTypeId(MapTypeId: TGMMapTypeId);
    procedure SetTilt(Tilt: Real);
    procedure SetZoom(Zoom: Integer);
}

    // Activate or deactivate access to the map.
    property Active: Boolean read FActive write SetActive default False;
    // @abstract(Version of the Google Maps API to use.)
    // raises EGMMapIsActive This exception is raised when @code(Active) property is @code(True).
    property GoogleAPIVer: TGoogleAPIVer read FGoogleAPIVer write SetGoogleAPIVer default api323;
    // @abstract(APIKey is the Key to use on Google Maps.)
    // To obtaining Api Key please check: https://developers.google.com/maps/documentation/javascript/get-api-key @br@br
    // Google Maps limits:
    // @unorderedList(
    //      @item(General info: https://developers.google.com/maps/documentation/javascript/usage)
    //      @item(Directions: https://developers.google.com/maps/documentation/directions/usage-limits)
    //      @item(Geocoding limits usage: https://developers.google.com/maps/documentation/geocoding/usage-limits)
    //      @item(Elevation limits usage: https://developers.google.com/maps/documentation/elevation/usage-limits)
    //      @item(Distance-Matrix limits usage: https://developers.google.com/maps/documentation/distance-matrix/usage-limits)
    //      @item(Geolocation limits usage: https://developers.google.com/maps/documentation/geolocation/usage-limits)
    //      @item(Roads limits usage: https://developers.google.com/maps/documentation/roads/usage-limits)
    //      @item(Time Zone limits usage: https://developers.google.com/maps/documentation/timezone/usage-limits)
    //    )
    // @code(EGMMapIsActive) exception is raised when @code(Active) property is @code(True).
    property GoogleAPIKey: string read FGoogleAPIKey write SetGoogleAPIKey;
    // Interval of time to check the events of map.
    property IntervalEvents: Integer read FIntervalEvents write SetIntervalEvents default 200;

    // OnActiveChange event is fired when Active property change.
    property OnActiveChange: TNotifyEvent read FOnActiveChange write FOnActiveChange;
    // OnIntervalEventsChange event is fired when IntervalEvents property change.
    property OnIntervalEventsChange: TNotifyEvent read FOnIntervalEventsChange write FOnIntervalEventsChange;
  public
    // @abstract(Constructor class.)
    // Creates a TGMCustomGMMap object.
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TGMCustomMapOptions }

procedure TGMCustomMapOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomMapOptions then
  begin
    Center.Assign(TGMCustomMapOptions(Source).Center);
    DisableDefaultUI := TGMCustomMapOptions(Source).DisableDefaultUI;
    DisableDoubleClickZoom := TGMCustomMapOptions(Source).DisableDoubleClickZoom;
    Draggable := TGMCustomMapOptions(Source).Draggable;
    DraggableCursor := TGMCustomMapOptions(Source).DraggableCursor;
    DraggingCursor := TGMCustomMapOptions(Source).DraggingCursor;
    Heading := TGMCustomMapOptions(Source).Heading;
    KeyboardShortcuts := TGMCustomMapOptions(Source).KeyboardShortcuts;
    MapMaker := TGMCustomMapOptions(Source).MapMaker;
    MapTypeControl := TGMCustomMapOptions(Source).MapTypeControl;
    MapTypeControlOptions.Assign(TGMCustomMapOptions(Source).MapTypeControlOptions);
    MapTypeId := TGMCustomMapOptions(Source).MapTypeId;
    MaxZoom := TGMCustomMapOptions(Source).MaxZoom;
    MinZoom := TGMCustomMapOptions(Source).MinZoom;
    NoClear := TGMCustomMapOptions(Source).NoClear;
    OverviewMapControl := TGMCustomMapOptions(Source).OverviewMapControl;
    OverviewMapControlOptions.Assign(TGMCustomMapOptions(Source).OverviewMapControlOptions);
    PanControl := TGMCustomMapOptions(Source).PanControl;
    PanControlOptions.Assign(TGMCustomMapOptions(Source).PanControlOptions);
    RotateControl := TGMCustomMapOptions(Source).RotateControl;
    RotateControlOptions.Assign(TGMCustomMapOptions(Source).RotateControlOptions);
    ScaleControl := TGMCustomMapOptions(Source).ScaleControl;
    ScaleControlOptions.Assign(TGMCustomMapOptions(Source).ScaleControlOptions);
    Scrollwheel := TGMCustomMapOptions(Source).Scrollwheel;
    StreetView.Assign(TGMCustomMapOptions(Source).StreetView);
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

  FCenter := TGMLatLng.Create(0, 0, False, GetOwnerLang);
  FDisableDefaultUI := False;
  FDisableDoubleClickZoom := True;
  FDraggable := True;
  FDraggableCursor := '';
  FDraggingCursor := '';
  FHeading := 0;
  FKeyboardShortcuts := True;
  FMapMaker := False;
  FMapTypeControl := True;
  FMapTypeControlOptions := TGMMapTypeControlOptions.Create(Self);
  FMapTypeId := mtROADMAP;
  FMaxZoom := 0;
  FMinZoom := 0;
  FNoClear := False;
  FOverviewMapControl := True;
  FOverviewMapControlOptions := TGMOverviewMapControlOptions.Create(Self);
  FPanControl := True;
  FPanControlOptions := TGMPanControlOptions.Create(Self);
  FRotateControl := True;
  FRotateControlOptions := TGMRotateControlOptions.Create(Self);
  FScaleControl := True;
  FScaleControlOptions := TGMScaleControlOptions.Create(Self);
  FScrollwheel := True;
  FStreetView := TGMStreetViewPanoramaOptions.Create(Self);
  FStreetViewControl := True;
  FStreetViewControlOptions := TGMStreetViewControlOptions.Create(Self);
  FTilt := 0;
  FZoom := 8;
  FZoomControl := True;
  FZoomControlOptions := TGMZoomControlOptions.Create(Self);
end;

destructor TGMCustomMapOptions.Destroy;
begin
  if Assigned(FCenter) then FreeAndNil(FCenter);
  if Assigned(FMapTypeControlOptions) then FreeAndNil(FMapTypeControlOptions);
  if Assigned(FOverviewMapControlOptions) then FreeAndNil(FOverviewMapControlOptions);
  if Assigned(FPanControlOptions) then FreeAndNil(FPanControlOptions);
  if Assigned(FScaleControlOptions) then FreeAndNil(FScaleControlOptions);
  if Assigned(FStreetView) then FreeAndNil(FStreetView);
  if Assigned(FStreetViewControlOptions) then FreeAndNil(FStreetViewControlOptions);
  if Assigned(FZoomControlOptions) then FreeAndNil(FZoomControlOptions);

  inherited;
end;

function TGMCustomMapOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#MapOptions';
end;

function TGMCustomMapOptions.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         FCenter.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FDisableDefaultUI, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FDisableDoubleClickZoom, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FDraggable, True)),
                         QuotedStr(FDraggableCursor),
                         QuotedStr(FDraggingCursor),
                         IntToStr(FHeading),
                         LowerCase(TGMTransform.GMBoolToStr(FKeyboardShortcuts, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FMapMaker, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FMapTypeControl, True)),
                         FMapTypeControlOptions.PropToString,
                         QuotedStr(TGMTransform.MapTypeIdToStr(FMapTypeId)),
                         IntToStr(FMaxZoom),
                         IntToStr(FMinZoom),
                         LowerCase(TGMTransform.GMBoolToStr(FNoClear, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FOverviewMapControl, True)),
                         FOverviewMapControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FPanControl, True)),
                         FPanControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FRotateControl, True)),
                         FRotateControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FScaleControl, True)),
                         FScaleControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FScrollwheel, True)),
                         //FStreetView.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FStreetViewControl, True)),
                         FStreetViewControlOptions.PropToString,
                         IntToStr(FTilt),
                         IntToStr(FZoom),
                         LowerCase(TGMTransform.GMBoolToStr(FZoomControl, True)),
                         FZoomControlOptions.PropToString
                         ]);
end;

procedure TGMCustomMapOptions.SetDisableDefaultUI(const Value: Boolean);
begin
  if FDisableDefaultUI = Value then Exit;

  FDisableDefaultUI := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetDisableDoubleClickZoom(const Value: Boolean);
begin
  if FDisableDoubleClickZoom = Value then Exit;

  FDisableDoubleClickZoom := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetDraggable(const Value: Boolean);
begin
  if FDraggable = Value then Exit;

  FDraggable := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetDraggableCursor(const Value: string);
begin
  if FDraggableCursor = Value then Exit;

  FDraggableCursor := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetDraggingCursor(const Value: string);
begin
  if FDraggingCursor = Value then Exit;

  FDraggingCursor := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetHeading(const Value: Integer);
begin
  if FHeading = Value then Exit;

  FHeading := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetKeyboardShortcuts(const Value: Boolean);
begin
  if FKeyboardShortcuts = Value then Exit;

  FKeyboardShortcuts := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetMapMaker(const Value: Boolean);
begin
  if FMapMaker = Value then Exit;

  FMapMaker := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetMapTypeControl(const Value: Boolean);
begin
  if FMapTypeControl = Value then Exit;

  FMapTypeControl := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetMapTypeId(const Value: TGMMapTypeId);
begin
  if FMapTypeId = Value then Exit;

  FMapTypeId := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetMaxZoom(const Value: Integer);
begin
  if FMaxZoom = Value then Exit;

  FMaxZoom := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetMinZoom(const Value: Integer);
begin
  if FMinZoom = Value then Exit;

  FMinZoom := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetNoClear(const Value: Boolean);
begin
  if FNoClear = Value then Exit;

  FNoClear := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetOverviewMapControl(const Value: Boolean);
begin
  if FOverviewMapControl = Value then Exit;

  FOverviewMapControl := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetPanControl(const Value: Boolean);
begin
  if FPanControl = Value then Exit;

  FPanControl := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetRotateControl(const Value: Boolean);
begin
  if FRotateControl = Value then Exit;

  FRotateControl := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetScaleControl(const Value: Boolean);
begin
  if FScaleControl = Value then Exit;

  FScaleControl := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetScrollwheel(const Value: Boolean);
begin
  if FScrollwheel = Value then Exit;

  FScrollwheel := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetStreetViewControl(const Value: Boolean);
begin
  if FStreetViewControl = Value then Exit;

  FStreetViewControl := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetTilt(const Value: Integer);
begin
  if FTilt = Value then Exit;

  FTilt := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetZoom(const Value: Integer);
begin
  if FZoom = Value then Exit;

  FZoom := Value;
  ControlChanges;
end;

procedure TGMCustomMapOptions.SetZoomControl(const Value: Boolean);
begin
  if ZoomControl = Value then Exit;

  ZoomControl := Value;
  ControlChanges;
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
  FMapTypeIds := [mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN, mtOSM];
end;

function TGMMapTypeControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#MapTypeControlOptions';
end;

function TGMMapTypeControlOptions.PropToString: string;
const
  Str = '%s,%s,%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.MapTypeIdsToStr(MapTypeIds, ';')),
                         QuotedStr(TGMTransform.PositionToStr(Position)),
                         QuotedStr(TGMTransform.MapTypeControlStyleToStr(Style))
                        ]);
end;

procedure TGMMapTypeControlOptions.SetMapTypeIds(const Value: TGMMapTypeIds);
begin
  if FMapTypeIds = Value then Exit;

  FMapTypeIds := Value;
  ControlChanges;
end;

procedure TGMMapTypeControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges;
end;

procedure TGMMapTypeControlOptions.SetStyle(const Value: TGMMapTypeControlStyle);
begin
  if FStyle = Value then Exit;

  FStyle := Value;
  ControlChanges;
end;

{ TGMOverviewMapControlOptions }

procedure TGMOverviewMapControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMOverviewMapControlOptions then
  begin
    Opened := TGMOverviewMapControlOptions(Source).Opened;
  end;
end;

constructor TGMOverviewMapControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FOpened := False;
end;

function TGMOverviewMapControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#OverviewMapControlOptions';
end;

function TGMOverviewMapControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(Opened, True))
                        ]);
end;

procedure TGMOverviewMapControlOptions.SetOpened(const Value: Boolean);
begin
  if FOpened = Value then Exit;

  FOpened := Value;
  ControlChanges;
end;

{ TGMPanControlOptions }

procedure TGMPanControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMPanControlOptions then
  begin
    Position := TGMPanControlOptions(Source).Position;
  end;
end;

constructor TGMPanControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpTOP_LEFT;
end;

function TGMPanControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#PanControlOptions';
end;

function TGMPanControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(Position))
                        ]);
end;

procedure TGMPanControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges;
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
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#RotateControlOptions';
end;

function TGMRotateControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(Position))
                        ]);
end;

procedure TGMRotateControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges;
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

  FStyle := scDEFAULT;
end;

function TGMScaleControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#ScaleControlOptions';
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
  ControlChanges;
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
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#StreetViewControlOptions';
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
  ControlChanges;
end;

{ TGMCustomMapTypeStyle }

procedure TGMCustomMapTypeStyle.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomMapTypeStyle then
  begin
    ElementType := TGMCustomMapTypeStyle(Source).ElementType;
    FeatureType := TGMCustomMapTypeStyle(Source).FeatureType;
  end;
end;

constructor TGMCustomMapTypeStyle.Create(Collection: TCollection);
begin
  inherited;

  FElementType := setALL;
  FFeatureType := sftALL;
end;

function TGMCustomMapTypeStyle.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyle';
end;

function TGMCustomMapTypeStyle.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(TGMTransform.MapTypeStyleElementTypeToStr(FElementType)),
                         QuotedStr(TGMTransform.MapTypeStyleFeatureTypeToStr(FeatureType))
                         ]);
end;

procedure TGMCustomMapTypeStyle.SetElementType(const Value: TGMMapTypeStyleElementType);
begin
  if FElementType = Value then Exit;

  FElementType := Value;
  ControlChanges;
end;

procedure TGMCustomMapTypeStyle.SetFeatureType(const Value: TGMMapTypeStyleFeatureType);
begin
  if FFeatureType = Value then Exit;

  FFeatureType := Value;
  ControlChanges;
end;

{ TGMCustomMapTypeStyler }

procedure TGMCustomMapTypeStyler.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomMapTypeStyler then
  begin
    Gamma := TGMCustomMapTypeStyler(Source).Gamma;
    InvertLightness := TGMCustomMapTypeStyler(Source).InvertLightness;
    Lightness := TGMCustomMapTypeStyler(Source).Lightness;
    Saturation := TGMCustomMapTypeStyler(Source).Saturation;
    Visibility := TGMCustomMapTypeStyler(Source).Visibility;
    Weight := TGMCustomMapTypeStyler(Source).Weight;
  end;
end;

constructor TGMCustomMapTypeStyler.Create(Collection: TCollection);
begin
  inherited;

  FGamma := 1;
  FInvertLightness := True;
  FLightness := 0;
  FSaturation := 0;
  FVisibility := vOn;
  FWeight := 0;
end;

function TGMCustomMapTypeStyler.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyler';
end;

function TGMCustomMapTypeStyler.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [StringReplace(FloatToStr(FGamma), ',', '.', [rfReplaceAll]),
                         LowerCase(TGMTransform.GMBoolToStr(FInvertLightness, True)),
                         IntToStr(FLightness),
                         IntToStr(FSaturation),
                         QuotedStr(TGMTransform.VisibilityToStr(FVisibility)),
                         IntToStr(FWeight)
                         ]);
end;

procedure TGMCustomMapTypeStyler.SetGamma(const Value: Real);
begin
  if FGamma = Value then Exit;

  FGamma := Value;
  if FGamma < 0.01 then FGamma := 0.01;
  if FGamma > 10 then FGamma := 10;

  ControlChanges;
end;

procedure TGMCustomMapTypeStyler.SetInvertLightness(const Value: Boolean);
begin
  if FInvertLightness = Value then Exit;

  FInvertLightness := Value;
  ControlChanges;
end;

procedure TGMCustomMapTypeStyler.SetLightness(const Value: Integer);
begin
  if FLightness = Value then Exit;

  FLightness := Value;
  if FLightness < -100 then FGamma := -100;
  if FLightness > 100 then FGamma := 100;

  ControlChanges;
end;

procedure TGMCustomMapTypeStyler.SetSaturation(const Value: Integer);
begin
  if FSaturation = Value then Exit;

  FSaturation := Value;
  if FSaturation < -100 then FGamma := -100;
  if FSaturation > 100 then FGamma := 100;

  ControlChanges;
end;

procedure TGMCustomMapTypeStyler.SetVisibility(const Value: TGMVisibility);
begin
  if FVisibility = Value then Exit;

  FVisibility := Value;
  ControlChanges;
end;

procedure TGMCustomMapTypeStyler.SetWeight(const Value: Integer);
begin
  if FWeight = Value then Exit;

  FWeight := Value;
  if FWeight < 0 then FWeight := 0;

  ControlChanges;
end;

{ TGMCustomGMMap }

constructor TGMCustomGMMap.Create(AOwner: TComponent);
begin
  inherited;

  FGoogleAPIVer := api323;
  FIntervalEvents := 200;
end;

function TGMCustomGMMap.GetBaseHTMLCode: string;
var
  List: TStringList;
  Stream: TResourceStream;
begin
  Result := '';

  List := TStringList.Create;
  try
    try
      Stream := TResourceStream.Create(HInstance, RES_MAPA_CODE, RT_RCDATA);
      List.LoadFromStream(Stream);
      Result := List.Text;
      Result := StringReplace(Result, C_API_KEY, FApiKey, []);
    finally
      if Assigned(Stream) then FreeAndNil(Stream);
      if Assigned(List) then FreeAndNil(List);
    end;
  except
    raise Exception.Create(GetTranslateText('No se ha podido cargar el recurso', Language));
  end;
end;

procedure TGMCustomGMMap.OnTimer(Sender: TObject);
begin

end;

procedure TGMCustomGMMap.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;

  FActive := Value;

  if csDesigning in ComponentState then Exit;
  if not Assigned(FWebBrowser) then Exit;

  if FActive then
    LoadMap
  else
  begin
    FIsDoMap := False;
    LoadBlankPage;
  end;

  //SetEnableTimer(FActive);

  if Assigned(FOnActiveChange) then FOnActiveChange(Self);
end;

procedure TGMCustomGMMap.SetGoogleAPIKey(const Value: string);
begin
  if FGoogleAPIKey = Value then Exit;

  if FActive then
    raise EGMMapIsActive.Create(6, [], Language);

  FGoogleAPIKey := Value;
end;

procedure TGMCustomGMMap.SetGoogleAPIVer(const Value: TGoogleAPIVer);
begin
  if FGoogleAPIVer = Value then Exit;

  if FActive then
    raise EGMMapIsActive.Create(6, [], Language);

  FGoogleAPIVer := Value;
end;

procedure TGMCustomGMMap.SetIntervalEvents(const Value: Integer);
begin
  if FIntervalEvents = Value then Exit;

  FIntervalEvents := Value;
  SetIntervalTimer(FIntervalEvents);

  if Assigned(FOnIntervalEventsChange) then FOnIntervalEventsChange(Self);
end;

{ TGMZoomControlOptions }

procedure TGMZoomControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMZoomControlOptions then
  begin
    Position := TGMZoomControlOptions(Source).Position;
    Style := TGMZoomControlOptions(Source).Style;
  end;
end;

constructor TGMZoomControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpTOP_LEFT;
  FStyle := zcDEFAULT;
end;

function TGMZoomControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#ZoomControlOptions';
end;

function TGMZoomControlOptions.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(Position)),
                         QuotedStr(TGMTransform.ZoomControlStyleToStr(Style))
                        ]);
end;

procedure TGMZoomControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges;
end;

procedure TGMZoomControlOptions.SetStyle(const Value: TGMZoomControlStyle);
begin
  if FStyle = Value then Exit;

  FStyle := Value;
  ControlChanges;
end;

{ TGMStreetViewPanoramaOptions }

procedure TGMStreetViewPanoramaOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMStreetViewPanoramaOptions then
  begin
    AddressControl := TGMStreetViewPanoramaOptions(Source).AddressControl;
    AddressControlOptions.Assign(TGMStreetViewPanoramaOptions(Source).AddressControlOptions);
    ClickToGo := TGMStreetViewPanoramaOptions(Source).ClickToGo;
    DisableDefaultUI := TGMStreetViewPanoramaOptions(Source).DisableDefaultUI;
    DisableDoubleClickZoom := TGMStreetViewPanoramaOptions(Source).DisableDoubleClickZoom;
    EnableCloseButton := TGMStreetViewPanoramaOptions(Source).EnableCloseButton;
    ImageDateControl := TGMStreetViewPanoramaOptions(Source).ImageDateControl;
    LinksControl := TGMStreetViewPanoramaOptions(Source).LinksControl;
    PanControl := TGMStreetViewPanoramaOptions(Source).PanControl;
    PanControlOptions.Assign(TGMStreetViewPanoramaOptions(Source).PanControlOptions);
    Pov.Assign(TGMStreetViewPanoramaOptions(Source).Pov);
    Scrollwheel := TGMStreetViewPanoramaOptions(Source).Scrollwheel;
    Visible := TGMStreetViewPanoramaOptions(Source).Visible;
    ZoomControl := TGMStreetViewPanoramaOptions(Source).ZoomControl;
    ZoomControlOptions.Assign(TGMStreetViewPanoramaOptions(Source).ZoomControlOptions);
  end;
end;

constructor TGMStreetViewPanoramaOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FAddressControl := True;
  FAddressControlOptions := TGMStreetViewAddressControlOptions.Create(Self);
  FClickToGo := True;
  FDisableDefaultUI := False;
  FDisableDoubleClickZoom := False;
  FEnableCloseButton := True;
  FImageDateControl := False;
  FLinksControl := False;
  FPanControl := True;
  FPanControlOptions := TGMPanControlOptions.Create(Self);
  FPov := TGMStreetViewPov.Create(Self);
  FScrollwheel := True;
  FVisible := False;
  FZoomControl := True;
  FZoomControlOptions := TGMZoomControlOptions.Create(Self);
end;

destructor TGMStreetViewPanoramaOptions.Destroy;
begin
  if Assigned(FAddressControlOptions) then FreeAndNil(FAddressControlOptions);
  if Assigned(FPanControlOptions) then FreeAndNil(FPanControlOptions);
  if Assigned(FPov) then FreeAndNil(FPov);
  if Assigned(FZoomControlOptions) then FreeAndNil(FZoomControlOptions);

  inherited;
end;

function TGMStreetViewPanoramaOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#StreetViewPanoramaOptions';
end;

function TGMStreetViewPanoramaOptions.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FAddressControl, True)),
                         FAddressControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FClickToGo, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FDisableDefaultUI, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FDisableDoubleClickZoom, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FEnableCloseButton, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FImageDateControl, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FLinksControl, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FPanControl, True)),
                         FPanControlOptions.PropToString,
                         FPov.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FScrollwheel, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FVisible, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FZoomControl, True)),
                         FZoomControlOptions.PropToString
                         ]);
end;

procedure TGMStreetViewPanoramaOptions.SetAddressControl(const Value: Boolean);
begin
  if FAddressControl = Value then Exit;

  FAddressControl := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetClickToGo(const Value: Boolean);
begin
  if FClickToGo = Value then Exit;

  FClickToGo := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetDisableDefaultUI(
  const Value: Boolean);
begin
  if FDisableDefaultUI = Value then Exit;

  FDisableDefaultUI := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetDisableDoubleClickZoom(
  const Value: Boolean);
begin
  if FDisableDoubleClickZoom = Value then Exit;

  FDisableDoubleClickZoom := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetEnableCloseButton(
  const Value: Boolean);
begin
  if FEnableCloseButton = Value then Exit;

  FEnableCloseButton := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetImageDateControl(
  const Value: Boolean);
begin
  if FImageDateControl = Value then Exit;

  FImageDateControl := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetLinksControl(const Value: Boolean);
begin
  if FLinksControl = Value then Exit;

  FLinksControl := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetPanControl(const Value: Boolean);
begin
  if FPanControl = Value then Exit;

  FPanControl := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetScrollwheel(const Value: Boolean);
begin
  if FScrollwheel = Value then Exit;

  FScrollwheel := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit;

  FVisible := Value;
  ControlChanges;
end;

procedure TGMStreetViewPanoramaOptions.SetZoomControl(const Value: Boolean);
begin
  if FZoomControl = Value then Exit;

  FZoomControl := Value;
  ControlChanges;
end;

{ TGMStreetViewAddressControlOptions }

procedure TGMStreetViewAddressControlOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMStreetViewAddressControlOptions then
  begin
    Position := TGMStreetViewAddressControlOptions(Source).Position;
  end;
end;

constructor TGMStreetViewAddressControlOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPosition := cpTOP_LEFT;
end;

function TGMStreetViewAddressControlOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#StreetViewAddressControlOptions';
end;

function TGMStreetViewAddressControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(FPosition))
                        ]);
end;

procedure TGMStreetViewAddressControlOptions.SetPosition(
  const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges;
end;

{ TGMStreetViewPov }

procedure TGMStreetViewPov.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMStreetViewPov then
  begin
    Heading := TGMStreetViewPov(Source).Heading;
    Pitch := TGMStreetViewPov(Source).Pitch;
  end;
end;

constructor TGMStreetViewPov.Create(AOwner: TPersistent);
begin
  inherited;

  FHeading := 0;
  FPitch := 0;
end;

function TGMStreetViewPov.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#StreetViewPov';
end;

function TGMStreetViewPov.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := Format(Str, [
                         IntToStr(FHeading),
                         IntToStr(FPitch)
                        ]);
end;

procedure TGMStreetViewPov.SetHeading(const Value: Integer);
begin
  if FHeading = Value then Exit;

  FHeading := Value;
  if FHeading < 0 then FHeading := 0;
  if FHeading > 270 then FHeading := 270;

  ControlChanges;
end;

procedure TGMStreetViewPov.SetPitch(const Value: Integer);
begin
  if FPitch = Value then Exit;

  FPitch := Value;
  if FPitch < -90 then FPitch := -90;
  if FPitch > 90 then FPitch := 90;

  ControlChanges;
end;

end.
