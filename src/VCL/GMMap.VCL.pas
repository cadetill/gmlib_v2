{
  @abstract(@code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Septembre 30, 2015)
  @lastmod(October 1, 2015)

  The GMMapVCL contains the implementation of TGMMap class that encapsulate the @code(google.maps.Map) class from Google Maps API and other related classes.
}
unit GMMap.VCL;

{$I ..\..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  Vcl.Graphics, System.Classes, SHDocVw, Vcl.ExtCtrls,
  {$ELSE}
  Graphics, Classes, SHDocVw, ExtCtrls,
  {$ENDIF}

  GMMap, GMClasses;

type
  {
    @abstract(@code(google.maps.MapTypeStyler) object from Google Maps API.)
    A styler affects how a map's elements will be styled. Each MapTypeStyler should contain one and only one key. If more than one key is specified in a single MapTypeStyler, all but one will be ignored.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyler
  }
  TGMMapTypeStyler = class(TGMCustomMapTypeStyler)
  private
    FColor: TColor;
    FHue: TColor;
    procedure SetColor(const Value: TColor);
    procedure SetHue(const Value: TColor);
  protected
    // Converts all class properties values to a string separated by semicolon.
    // @return string with all properties.
    function PropToString: string; override;
  published
    // Sets the color of the feature.
    property Color: TColor read FColor write SetColor default clBlack;
    // Sets the hue of the feature to match the hue of the color supplied. Note that the saturation and lightness of the feature is conserved, which means that the feature will not match the color supplied exactly.
    property Hue: TColor read FHue write SetHue default clBlack;
    // Modifies the gamma by raising the lightness to the given power.@br Valid values: Floating point numbers, [0.01, 10], with 1.0 representing no change.
    property Gamma;
    // A value of true will invert the lightness of the feature while preserving the hue and saturation.
    property InvertLightness;
    // Shifts lightness of colors by a percentage of the original value if decreasing and a percentage of the remaining value if increasing.@br Valid values: [-100, 100].
    property Lightness;
    // Shifts the saturation of colors by a percentage of the original value if decreasing and a percentage of the remaining value if increasing.@br Valid values: [-100, 100].
    property Saturation;
    // Sets the visibility of the feature.
    property Visibility;
    // Sets the weight of the feature, in pixels.@br Valid values: Integers greater than or equal to zero.
    property Weight;
  end;

  {
    @abstract(@code(google.maps.MapTypeStyler) list objects from Google Maps API.)
    The TGMMapTypeStylers is a collection of TGMMapTypeStyler.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyler
  }
  TGMMapTypeStylers = class(TGMInterfacedCollection)
  private
    function GetItems(I: Integer): TGMMapTypeStyler;
    procedure SetItems(I: Integer; const Value: TGMMapTypeStyler);
  public
    function Add: TGMMapTypeStyler;
    function Insert(Index: Integer): TGMMapTypeStyler;

    property Items[I: Integer]: TGMMapTypeStyler read GetItems write SetItems; default;
  end;

  {
    @abstract(@code(google.maps.MapTypeStyle) object from Google Maps API.)
    The TGMMapTypeStyle is an individual object of collection of selectors and stylers that define how the map should be styled. Selectors specify what map elements should be affected and stylers specify how those elements should be modified.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyle
  }
  TGMMapTypeStyle = class(TGMCustomMapTypeStyle)
  private
    FStylers: TGMMapTypeStylers;
  public
    // @abstract(Constructor class.)
    // @param AOwner Object owner.
    // @param ItemClass Identifies the TCollectionItem descendants that must be used to represent the items in the collection.
    constructor Create(Collection: TCollection); override;
    // @abstract(Destructor class.)
    destructor Destroy; override;
  published
    // Selects the element type to which a styler should be applied. An element type distinguishes between the different representations of a feature.
    property ElementType;
    // Selects the feature, or group of features, to which a styler should be applied.
    property FeatureType;
    property Stylers: TGMMapTypeStylers read FStylers write FStylers;
  end;

  {
    @abstract(@code(google.maps.MapTypeStyle) list objects from Google Maps API.)
    The TGMMapTypeStyles is a collection of selectors and stylers that define how the map should be styled. Selectors specify what map elements should be affected and stylers specify how those elements should be modified.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyle
  }
  TGMMapTypeStyles = class(TGMInterfacedCollection)
  private
    function GetItems(I: Integer): TGMMapTypeStyle;
    procedure SetItems(I: Integer; const Value: TGMMapTypeStyle);
  public
    function Add: TGMMapTypeStyle;
    function Insert(Index: Integer): TGMMapTypeStyle;

    property Items[I: Integer]: TGMMapTypeStyle read GetItems write SetItems; default;
  end;

  {
    @abstract(Class for @code(google.maps.MapOptions) object from Google Maps API.)
    More information at https://developers.google.com/maps/documentation/javascript/reference#MapOptions
  }
  TGMMapOptions = class(TGMCustomMapOptions)
  private
    FBackgroundColor: TColor;
    FStyles: TGMMapTypeStyles;
    procedure SetBackgroundColor(const Value: TColor);
    function GetCountStyles: Integer;
  public
    // @abstract(Constructor class.)
    // Creates a TGMCustomMapOptions object.
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TPersistent); override;
    // @abstract(Destructor class.)
    destructor Destroy; override;

    property CountStyles: Integer read GetCountStyles;
  published
    // Color used for the background of the Map div. This color will be visible when tiles have not yet loaded as the user pans.
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clBlack;

    // Contains the lat/lng coordinates with the center of the map.
    property Center;
    // Enables/disables all default UI. May be overridden individually.
    property DisableDefaultUI;
    // Enables/disables zoom and center on double click.
    property DisableDoubleClickZoom;
    // If false, prevents the map from being dragged.
    property Draggable;
    // The name or url of the cursor to display when mousing over a draggable map. This property uses the css cursor attribute to change the icon. As with the css property, you must specify at least one fallback cursor that is not a URL. For example: draggableCursor: 'url(http://www.example.com/icon.png), auto;'.
    property DraggableCursor;
    // The name or url of the cursor to display when the map is being dragged. This property uses the css cursor attribute to change the icon. As with the css property, you must specify at least one fallback cursor that is not a URL. For example: draggingCursor: 'url(http://www.example.com/icon.png), auto;'.
    property DraggingCursor;
    // The heading for aerial imagery in degrees measured clockwise from cardinal direction North. Headings are snapped to the nearest available angle for which imagery is available.
    property Heading;
    // If false, prevents the map from being controlled by the keyboard.
    property KeyboardShortcuts;
    // True if Map Maker tiles should be used instead of regular tiles.
    property MapMaker;
    // The initial enabled/disabled state of the Map type control.
    property MapTypeControl;
    // The initial display options for the Map type control.
    property MapTypeControlOptions;
    // The initial Map mapTypeId.
    property MapTypeId;
    // The maximum zoom level which will be displayed on the map.
    property MaxZoom;
    // The minimum zoom level which will be displayed on the map.
    property MinZoom;
    // If true, do not clear the contents of the Map div.
    property NoClear;
    // The enabled/disabled state of the Overview Map control.@br Note: The Overview Map control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Overview Map control available as part of the old control set.
    property OverviewMapControl;
    // The display options for the Overview Map control.@br Note: The Overview Map control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Overview Map control available as part of the old control set.
    property OverviewMapControlOptions;
    // The enabled/disabled state of the Pan control.@br Note: The Pan control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Pan control available as part of the old control set.
    property PanControl;
    // The display options for the Pan control.@br Note: The Pan control is not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the Pan control available as part of the old control set.
    property PanControlOptions;
    // The enabled/disabled state of the Rotate control.
    property RotateControl;
    // The display options for the Rotate control.
    property RotateControlOptions;
    // The initial enabled/disabled state of the Scale control.
    property ScaleControl;
    // The initial display options for the Scale control.
    property ScaleControlOptions;
    // If false, disables scrollwheel zooming on the map.
    property Scrollwheel;
    // A StreetViewPanorama to display when the Street View pegman is dropped on the map.
    property StreetView;
    // The initial enabled/disabled state of the Street View Pegman control. This control is part of the default UI, and should be set to false when displaying a map type on which the Street View road overlay should not appear (e.g. a non-Earth map type).
    property StreetViewControl;
    // The initial display options for the Street View Pegman control.
    property StreetViewControlOptions;
    // Styles to apply to each of the default map types. Note that for mtSatellite/mtHybrid and mtTerrain modes, these styles will only apply to labels and geometry.
    property Styles: TGMMapTypeStyles read FStyles write FStyles;
    // Controls the automatic switching behavior for the angle of incidence of the map. The only allowed values are 0 and 45. The value 0 causes the map to always use a 0° overhead view regardless of the zoom level and viewport. The value 45 causes the tilt angle to automatically switch to 45 whenever 45° imagery is available for the current zoom level and viewport, and switch back to 0 whenever 45° imagery is not available (this is the default behavior). 45° imagery is only available for SATELLITE and HYBRID map types, within some locations, and at some zoom levels. Note: getTilt returns the current tilt angle, not the value specified by this option. Because getTilt and this option refer to different things, do not bind() the tilt property; doing so may yield unpredictable effects.
    property Tilt;
    // The initial Map zoom level.
    property Zoom;
    // The enabled/disabled state of the Zoom control.
    property ZoomControl;
    // The display options for the Zoom control.
    property ZoomControlOptions;
  end;

  {
    @abstract(@code(google.maps.Map) class)
    @image(tgmmap.png) @br
    More information at https://developers.google.com/maps/documentation/javascript/reference#Map
  }
  TGMMap = class(TGMCustomGMMap)
  private
    FMapOptions: TGMMapOptions;
    FTimer: TTimer;    // TTimer for map events control

    function GetWebBrowser: TWebBrowser;
    procedure SetWebBrowser(const Value: TWebBrowser); (*1 *)
  protected
    // Set the interval of Timer that control de map events. Internal use only.
    // @param Interval Interval in miliseconds
    procedure SetIntervalTimer(Interval: Integer); override;
    // LoadMap method loads and shows the map.html to use Google Maps API.
    procedure LoadMap; override; (*1 *)
    // LoadHTMLCodeAndWait method load the map.html and wait until it is loaded
    procedure LoadHTMLCodeAndWait;
  public
    // @abstract(Constructor class.)
    // Creates a TGMCustomGMMap object.
    // @param AOwner Owner of the object.
    constructor Create(AOwner: TComponent); override;
    // @abstract(Destructor class.)
    destructor Destroy; override;

    // URL to Google Maps API class.
    function GetAPIUrl: string; override;
  published
    // @code(google.maps.MapOptions) object specification
    property MapOptions: TGMMapOptions read FMapOptions write FMapOptions;
    // Activate or deactivate access to the map.
    property Active;
    // Version of the Google Maps API to use
    property GoogleAPIVer;
    // Language property specifies the language in which messages are displayed the exceptions shown by the class/component.
    property Language;
    // This property shows an “About” form with info of the GMLib.
    property AboutGMLib;
    // URL to Google Maps API class
    property APIUrl;
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
    property GoogleAPIKey;
    // Interval of time to check the events of map.
    property IntervalEvents;
    // Browser where display the Google Maps map.
    property WebBrowser: TWebBrowser read GetWebBrowser write SetWebBrowser;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  GMClasses.VCL;

{ TGMMapOptions }

constructor TGMMapOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FBackgroundColor := clBlack;
  FStyles := TGMMapTypeStyles.Create(Self, TGMMapTypeStyle);
end;

destructor TGMMapOptions.Destroy;
begin
  if Assigned(FStyles) then FreeAndNil(FStyles);

  inherited;
end;

function TGMMapOptions.GetCountStyles: Integer;
begin
  Result := FStyles.Count;
end;

procedure TGMMapOptions.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor = Value then Exit;

  FBackgroundColor := Value;
  ControlChanges;
end;

{ TGMMapTypeStyler }

function TGMMapTypeStyler.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [QuotedStr(TGMTransformVCL.TColorToStr(FColor)),
                         QuotedStr(TGMTransformVCL.TColorToStr(FHue))
                         ]);
end;

procedure TGMMapTypeStyler.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit;

  FColor := Value;
  ControlChanges;
end;

procedure TGMMapTypeStyler.SetHue(const Value: TColor);
begin
  if FHue = Value then Exit;

  FHue := Value;
  ControlChanges;
end;

{ TGMMap }

constructor TGMMap.Create(AOwner: TComponent);
begin
  inherited;

  FMapOptions := TGMMapOptions.Create(Self);

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 200;
  FTimer.OnTimer := OnTimer;
end;

destructor TGMMap.Destroy;
begin
  if Assigned(FMapOptions) then FreeAndNil(FMapOptions);
  if Assigned(FTimer) then FreeAndNil(FTimer);

  inherited;
end;

function TGMMap.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#Map';
end;

function TGMMap.GetWebBrowser: TWebBrowser;
begin
  Result := nil;
  if FWebBrowser is TWebBrowser then
    Result := TWebBrowser(FWebBrowser);
end;

procedure TGMMap.LoadHTMLCodeAndWait;
var
  StringStream: TStringStream;
  PersistStreamInit: IPersistStreamInit;
  StreamAdapter: IStream;
begin
  if not Assigned(FWebBrowser) then Exit;
  if not (FWebBrowser is TWebBrowser) then Exit;

  // creación del TStringStream con el string que contiene la página web
  StringStream := TStringStream.Create(GetBaseHTMLCode);
  try
    // nos aseguramos de tener algún contenido en Document
    if not Assigned(TWebBrowser(FWebBrowser).Document) then LoadBlankPage;

    // acceder a la interfaz IPersistStreamInit de Document
    if TWebBrowser(FWebBrowser).Document.QueryInterface(IPersistStreamInit, PersistStreamInit) = S_OK then
    begin
      // borrar datos actuales
      if PersistStreamInit.InitNew = S_OK then
      begin
        // creación y inicialización del IStream
        StreamAdapter:= TStreamAdapter.Create(StringStream);
        // carga de la página web mediante IPersistStreamInit
        PersistStreamInit.Load(StreamAdapter);
      end;
    end;
  finally
    StringStream.Free;
  end;
end;

procedure TGMMap.LoadMap;
begin
  inherited;

  LoadHTMLCodeAndWait;
end;

procedure TGMMap.SetIntervalTimer(Interval: Integer);
begin
  inherited;

  if Assigned(FTimer) then FTimer.Interval := Interval;
end;

procedure TGMMap.SetWebBrowser(const Value: TWebBrowser);
begin
  if FWebBrowser = Value then Exit;

{
  if (Value <> FWebBrowser) and Assigned(FWebBrowser) then
  begin
    TWebBrowser(FWebBrowser).OnBeforeNavigate2 := OldBeforeNavigate2;
    TWebBrowser(FWebBrowser).OnDocumentComplete := OldDocumentComplete;
    TWebBrowser(FWebBrowser).OnNavigateComplete2 := OldNavigateComplete2;
  end;
}

  FWebBrowser := Value;
{
  TWebControl(FWC).SetBrowser(TWebBrowser(FWebBrowser));

  if csDesigning in ComponentState then Exit;

  if Assigned(FWebBrowser) then
  begin
    OldBeforeNavigate2 := TWebBrowser(FWebBrowser).OnBeforeNavigate2;
    OldDocumentComplete := TWebBrowser(FWebBrowser).OnDocumentComplete;
    OldNavigateComplete2 := TWebBrowser(FWebBrowser).OnNavigateComplete2;

    TWebBrowser(FWebBrowser).OnBeforeNavigate2 := BeforeNavigate2;
    TWebBrowser(FWebBrowser).OnDocumentComplete := DocumentComplete;
    TWebBrowser(FWebBrowser).OnNavigateComplete2 := NavigateComplete2;

    if Active then LoadBaseWeb;
  end;
}
end;

{ TGMMapTypeStyles }

function TGMMapTypeStyles.Add: TGMMapTypeStyle;
begin
  Result := TGMMapTypeStyle(inherited Add);
end;

function TGMMapTypeStyles.GetItems(I: Integer): TGMMapTypeStyle;
begin
  Result := TGMMapTypeStyle(inherited Items[I]);
end;

function TGMMapTypeStyles.Insert(Index: Integer): TGMMapTypeStyle;
begin
  Result := TGMMapTypeStyle(inherited Insert(Index));
end;

procedure TGMMapTypeStyles.SetItems(I: Integer; const Value: TGMMapTypeStyle);
begin
  inherited SetItem(I, Value);
end;

{ TGMMapTypeStylers }

function TGMMapTypeStylers.Add: TGMMapTypeStyler;
begin
  Result := TGMMapTypeStyler(inherited Add);
end;

function TGMMapTypeStylers.GetItems(I: Integer): TGMMapTypeStyler;
begin
  Result := TGMMapTypeStyler(inherited Items[I]);
end;

function TGMMapTypeStylers.Insert(Index: Integer): TGMMapTypeStyler;
begin
  Result := TGMMapTypeStyler(inherited Insert(Index));
end;

procedure TGMMapTypeStylers.SetItems(I: Integer; const Value: TGMMapTypeStyler);
begin
  inherited SetItem(I, Value);
end;

{ TGMMapTypeStyle }

constructor TGMMapTypeStyle.Create(Collection: TCollection);
begin
  inherited;

  FStylers := TGMMapTypeStylers.Create(Self, TGMMapTypeStyler);
end;

destructor TGMMapTypeStyle.Destroy;
begin
  if Assigned(FStylers) then FreeAndNil(FStylers);

  inherited;
end;

end.
