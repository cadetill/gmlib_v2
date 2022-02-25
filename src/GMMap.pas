{
  @abstract(@code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Septembre 30, 2015)
  @lastmod(October 1, 2015)

  The GMMap contains the implementation of TCustomGMMap class that encapsulate the @code(google.maps.Map) class from Google Maps API and other related classes.
}
unit GMMap;

{$I ..\gmlib.inc}
{$R ..\Resources\gmmapres.RES}

interface

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils, System.Classes,
  {$ELSE}
  SysUtils, Classes,
  {$ENDIF}

  GMClasses, GMLatLng, GMLatLngBounds, GMSets;

type
  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMMapTypeControlOptions.txt)
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
    // @include(..\Help\docs\GMMap.TGMMapTypeControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMMapTypeControlOptions.MapTypeIds.txt)
    property MapTypeIds: TGMMapTypeIds read FMapTypeIds write SetMapTypeIds default [mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN, mtOSM];
    // @include(..\Help\docs\GMMap.TGMMapTypeControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_RIGHT;
    // @include(..\Help\docs\GMMap.TGMMapTypeControlOptions.Style.txt)
    property Style: TGMMapTypeControlStyle read FStyle write SetStyle default mtcDEFAULT;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMPanControlOptions.txt)
  TGMPanControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMMap.TGMPanControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMPanControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMRotateControlOptions.txt)
  TGMRotateControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMMap.TGMRotateControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMRotateControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMScaleControlOptions.txt)
  TGMScaleControlOptions = class(TGMPersistentStr)
  private
    FStyle: TGMScaleControlStyle;
    procedure SetStyle(const Value: TGMScaleControlStyle);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMMap.TGMScaleControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMScaleControlOptions.Style.txt)
    property Style: TGMScaleControlStyle read FStyle write SetStyle default scDEFAULT;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMZoomControlOptions.txt)
  TGMZoomControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMMap.TGMZoomControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMZoomControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMStreetViewControlOptions.txt)
  TGMStreetViewControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMMap.TGMStreetViewControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMStreetViewControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.txt)
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

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.Gamma.txt)
    property Gamma: Real read FGamma write SetGamma;
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.InvertLightness.txt)
    property InvertLightness: Boolean read FInvertLightness write SetInvertLightness default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.Lightness.txt)
    property Lightness: Integer read FLightness write SetLightness default 0;
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.Saturation.txt)
    property Saturation: Integer read FSaturation write SetSaturation default 0;
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.Visibility.txt)
    property Visibility: TGMVisibility read FVisibility write SetVisibility default vOn;
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.Weight.txt)
    property Weight: Integer read FWeight write SetWeight default 0;
  public
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyler.Create.txt)
    constructor Create(Collection: TCollection); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyle.txt)
  TGMCustomMapTypeStyle = class(TGMInterfacedCollectionItem)
  private
    FElementType: TGMMapTypeStyleElementType;
    FFeatureType: TGMMapTypeStyleFeatureType;
    procedure SetElementType(const Value: TGMMapTypeStyleElementType);
    procedure SetFeatureType(const Value: TGMMapTypeStyleFeatureType);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyle.ElementType.txt)
    property ElementType: TGMMapTypeStyleElementType read FElementType write SetElementType default setALL;
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyle.FeatureType.txt)
    property FeatureType: TGMMapTypeStyleFeatureType read FFeatureType write SetFeatureType default sftALL;
  public
    // @include(..\Help\docs\GMMap.TGMCustomMapTypeStyle.Create.txt)
    constructor Create(Collection: TCollection); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMStreetViewAddressControlOptions.txt)
  TGMStreetViewAddressControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMMap.TGMStreetViewAddressControlOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMStreetViewAddressControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpTOP_LEFT;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMFullScreenControlOptions.txt)
  TGMFullScreenControlOptions = class(TGMPersistentStr)
  private
    FPosition: TGMControlPosition;
    procedure SetPosition(const Value: TGMControlPosition);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMClasses.TGMInterfacedOwnedPersistent.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMFullScreenControlOptions.Position.txt)
    property Position: TGMControlPosition read FPosition write SetPosition default cpRIGHT_TOP;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMStreetViewPov.txt)
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
    // @include(..\Help\docs\GMMap.TGMStreetViewPov.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMStreetViewPov.Heading.txt)
    property Heading: Integer read FHeading write SetHeading default 0;
    // @include(..\Help\docs\GMMap.TGMStreetViewPov.Pitch.txt)
    property Pitch: Integer read FPitch write SetPitch default 0;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.txt)
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
    FFullScreenControlOptions: TGMFullScreenControlOptions;
    FFullScreenControl: Boolean;
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
    procedure SetFullScreenControl(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.AddressControl.txt)
    property AddressControl: Boolean read FAddressControl write SetAddressControl default True;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.AddressControlOptions.txt)
    property AddressControlOptions: TGMStreetViewAddressControlOptions read FAddressControlOptions write FAddressControlOptions;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.ClickToGo.txt)
    property ClickToGo: Boolean read FClickToGo write SetClickToGo default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.DisableDefaultUI.txt)
    property DisableDefaultUI: Boolean read FDisableDefaultUI write SetDisableDefaultUI default False;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.DisableDoubleClickZoom.txt)
    property DisableDoubleClickZoom: Boolean read FDisableDoubleClickZoom write SetDisableDoubleClickZoom default False;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.EnableCloseButton.txt)
    property EnableCloseButton: Boolean read FEnableCloseButton write SetEnableCloseButton default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.FullScreenControl.txt)
    property FullScreenControl: Boolean read FFullScreenControl write SetFullScreenControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.FullScreenControlOptions.txt)
    property FullScreenControlOptions: TGMFullScreenControlOptions read FFullScreenControlOptions write FFullScreenControlOptions;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.ImageDateControl.txt)
    property ImageDateControl: Boolean read FImageDateControl write SetImageDateControl default False;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.LinksControl.txt)
    property LinksControl: Boolean read FLinksControl write SetLinksControl default False;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.PanControl.txt)
    property PanControl: Boolean read FPanControl write SetPanControl default True;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.PanControlOptions.txt)
    property PanControlOptions: TGMPanControlOptions read FPanControlOptions write FPanControlOptions;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.Pov.txt)
    property Pov: TGMStreetViewPov read FPov write FPov;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.Scrollwheel.txt)
    property Scrollwheel: Boolean read FScrollwheel write SetScrollwheel default True;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.Visible.txt)
    property Visible: Boolean read FVisible write SetVisible default False;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.ZoomControl.txt)
    property ZoomControl: Boolean read FZoomControl write SetZoomControl default True;
    // @include(..\Help\docs\GMMap.TGMStreetViewPanoramaOptions.ZoomControlOptions.txt)
    property ZoomControlOptions: TGMZoomControlOptions read FZoomControlOptions write FZoomControlOptions;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMCustomMapOptions.txt)
  TGMCustomMapOptions = class(TGMPersistentStr, IGMControlChanges)
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
    FFullScreenControl: Boolean;
    FFullScreenControlOptions: TGMFullScreenControlOptions;
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
    procedure SetFullScreenControl(const Value: Boolean);
  protected
    // @include(..\Help\docs\GMClasses.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Center.txt)
    property Center: TGMLatLng read FCenter write FCenter;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.DisableDefaultUI.txt)
    property DisableDefaultUI: Boolean read FDisableDefaultUI write SetDisableDefaultUI default False;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.DisableDoubleClickZoom.txt)
    property DisableDoubleClickZoom: Boolean read FDisableDoubleClickZoom write SetDisableDoubleClickZoom default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Draggable.txt)
    property Draggable: Boolean read FDraggable write SetDraggable default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.DraggableCursor.txt)
    property DraggableCursor: string read FDraggableCursor write SetDraggableCursor;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.DraggingCursor.txt)
    property DraggingCursor: string read FDraggingCursor write SetDraggingCursor;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.FullScreenControl.txt)
    property FullScreenControl: Boolean read FFullScreenControl write SetFullScreenControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.FullScreenControlOptions.txt)
    property FullScreenControlOptions: TGMFullScreenControlOptions read FFullScreenControlOptions write FFullScreenControlOptions;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Heading.txt)
    property Heading: Integer read FHeading write SetHeading default 0;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.KeyboardShortcuts.txt)
    property KeyboardShortcuts: Boolean read FKeyboardShortcuts write SetKeyboardShortcuts default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.MapMaker.txt)
    property MapMaker: Boolean read FMapMaker write SetMapMaker default False;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.MapTypeControl.txt)
    property MapTypeControl: Boolean read FMapTypeControl write SetMapTypeControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.MapTypeControlOptions.txt)
    property MapTypeControlOptions: TGMMapTypeControlOptions read FMapTypeControlOptions write FMapTypeControlOptions;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.MapTypeId.txt)
    property MapTypeId: TGMMapTypeId read FMapTypeId write SetMapTypeId default mtROADMAP;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.MaxZoom.txt)
    property MaxZoom: Integer read FMaxZoom write SetMaxZoom default 0;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.MinZoom.txt)
    property MinZoom: Integer read FMinZoom write SetMinZoom default 0;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.NoClear.txt)
    property NoClear: Boolean read FNoClear write SetNoClear default False;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.OverviewMapControl.txt)
    property OverviewMapControl: Boolean read FOverviewMapControl write SetOverviewMapControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.PanControl.txt)
    property PanControl: Boolean read FPanControl write SetPanControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.PanControlOptions.txt)
    property PanControlOptions: TGMPanControlOptions read FPanControlOptions write FPanControlOptions;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.RotateControl.txt)
    property RotateControl: Boolean read FRotateControl write SetRotateControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.RotateControlOptions.txt)
    property RotateControlOptions: TGMRotateControlOptions read FRotateControlOptions write FRotateControlOptions;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.ScaleControl.txt)
    property ScaleControl: Boolean read FScaleControl write SetScaleControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.ScaleControlOptions.txt)
    property ScaleControlOptions: TGMScaleControlOptions read FScaleControlOptions write FScaleControlOptions;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Scrollwheel.txt)
    property Scrollwheel: Boolean read FScrollwheel write SetScrollwheel default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.StreetView.txt)
    property StreetView: TGMStreetViewPanoramaOptions read FStreetView write FStreetView;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.StreetViewControl.txt)
    property StreetViewControl: Boolean read FStreetViewControl write SetStreetViewControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.StreetViewControlOptions.txt)
    property StreetViewControlOptions: TGMStreetViewControlOptions read FStreetViewControlOptions write FStreetViewControlOptions;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Tilt.txt)
    property Tilt: Integer read FTilt write SetTilt default 0;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Zoom.txt)
    property Zoom: Integer read FZoom write SetZoom default 8;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.ZoomControl.txt)
    property ZoomControl: Boolean read FZoomControl write SetZoomControl default True;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.ZoomControlOptions.txt)
    property ZoomControlOptions: TGMZoomControlOptions read FZoomControlOptions write FZoomControlOptions;
  public
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMMap.TGMCustomMapOptions.GetAPIUrl.txt)
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMMap.TGMCustomGMMap.txt)
  TGMCustomGMMap = class(TGMComponent, IGMExecJS, IGMControlChanges)
  private
    FGoogleAPIVer: TGoogleAPIVer;
    FActive: Boolean;
    FGoogleAPIKey: string;
    FIntervalEvents: Integer;
    FOnActiveChange: TNotifyEvent;
    FOnIntervalEventsChange: TNotifyEvent;
    FAPILang: TGMAPILang;
    FPrecision: Integer;
    FOnPrecisionChange: TNotifyEvent;
    FOnPropertyChanges: TPropertyChanges;
    procedure SetGoogleAPIVer(const Value: TGoogleAPIVer);
    procedure SetActive(const Value: Boolean); {*1 *}
    procedure SetGoogleAPIKey(const Value: string);
    procedure SetIntervalEvents(const Value: Integer);
    procedure SetAPILang(const Value: TGMAPILang);
    procedure SetPrecision(const Value: Integer);
  protected
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.FWebBrowser.txt)
    FWebBrowser: TComponent;

    // @include(..\Help\docs\GMClasses.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMMap.TGMCustomGMMap.GetTempPath.txt)
    function GetTempPath: string; virtual; abstract;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.SetIntervalTimer.txt)
    procedure SetIntervalTimer(Interval: Integer); virtual; abstract;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.LoadMap.txt)
    procedure LoadMap; virtual; abstract;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.LoadBlankPage.txt)
    procedure LoadBlankPage; virtual; abstract;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.GetBaseHTMLCode.txt)
    function GetBaseHTMLCode: string;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(NameFunct, Params: string); virtual; abstract;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.OnTimer.txt)
    procedure OnTimer(Sender: TObject); virtual; (*1 *)


{    function GetBounds: TGMLatLngBounds;
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

    // @include(..\Help\docs\GMMap.TGMCustomGMMap.Active.txt)
    property Active: Boolean read FActive write SetActive default False;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.GoogleAPIVer.txt)
    property GoogleAPIVer: TGoogleAPIVer read FGoogleAPIVer write SetGoogleAPIVer default api323;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.GoogleAPIKey.txt)
    property GoogleAPIKey: string read FGoogleAPIKey write SetGoogleAPIKey;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.IntervalEvents.txt)
    property IntervalEvents: Integer read FIntervalEvents write SetIntervalEvents default 200;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.APILang.txt)
    property APILang: TGMAPILang read FAPILang write SetAPILang default lEnglish;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.Precision.txt)
    property Precision: Integer read FPrecision write SetPrecision default 0;

    // @include(..\Help\docs\GMMap.TGMCustomGMMap.OnActiveChange.txt)
    property OnActiveChange: TNotifyEvent read FOnActiveChange write FOnActiveChange;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange: TNotifyEvent read FOnIntervalEventsChange write FOnIntervalEventsChange;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.OnPrecisionChange.txt)
    property OnPrecisionChange: TNotifyEvent read FOnPrecisionChange write FOnPrecisionChange;
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.OnPropertyChanges.txt)
    property OnPropertyChanges: TPropertyChanges read FOnPropertyChanges write FOnPropertyChanges;
  public
    // @include(..\Help\docs\GMMap.TGMCustomGMMap.Create.txt)
    constructor Create(AOwner: TComponent); override;

    // @include(..\Help\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMMap.TGMCustomGMMap.FitBounds.txt)
    procedure FitBounds(Bounds: TGMLatLngBounds);
  end;

implementation

uses
  {$IFDEF DELPHI2010}
  System.IOUtils,
  {$ENDIF}
  {$IFDEF DELPHIXE2}
  System.Types,
  {$ELSE}
  Windows,
  {$ENDIF}

  GMConstants;

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
    FullScreenControl := TGMCustomMapOptions(Source).FullScreenControl;
    FullScreenControlOptions.Assign(TGMCustomMapOptions(Source).FullScreenControlOptions);
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

  FCenter := TGMLatLng.Create(Self, 0, 0, False);
  FDisableDefaultUI := False;
  FDisableDoubleClickZoom := True;
  FDraggable := True;
  FDraggableCursor := '';
  FDraggingCursor := '';
  FFullScreenControl := True;
  FFullScreenControlOptions := TGMFullScreenControlOptions.Create(Self);
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
  if Assigned(FFullScreenControlOptions) then FreeAndNil(FFullScreenControlOptions);
  if Assigned(FMapTypeControlOptions) then FreeAndNil(FMapTypeControlOptions);
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
  Str = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s';
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
                         LowerCase(TGMTransform.GMBoolToStr(FFullScreenControl, True)),
                         FFullScreenControlOptions.PropToString,
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
                         LowerCase(TGMTransform.GMBoolToStr(FPanControl, True)),
                         FPanControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FRotateControl, True)),
                         FRotateControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FScaleControl, True)),
                         FScaleControlOptions.PropToString,
                         LowerCase(TGMTransform.GMBoolToStr(FScrollwheel, True)),
                         FStreetView.PropToString,
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
  ControlChanges('DisableDefaultUI');
end;

procedure TGMCustomMapOptions.SetDisableDoubleClickZoom(const Value: Boolean);
begin
  if FDisableDoubleClickZoom = Value then Exit;

  FDisableDoubleClickZoom := Value;
  ControlChanges('DisableDoubleClickZoom');
end;

procedure TGMCustomMapOptions.SetDraggable(const Value: Boolean);
begin
  if FDraggable = Value then Exit;

  FDraggable := Value;
  ControlChanges('Draggable');
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

procedure TGMCustomMapOptions.SetHeading(const Value: Integer);
begin
  if FHeading = Value then Exit;

  FHeading := Value;
  ControlChanges('Heading');
end;

procedure TGMCustomMapOptions.SetKeyboardShortcuts(const Value: Boolean);
begin
  if FKeyboardShortcuts = Value then Exit;

  FKeyboardShortcuts := Value;
  ControlChanges('KeyboardShortcuts');
end;

procedure TGMCustomMapOptions.SetMapMaker(const Value: Boolean);
begin
  if FMapMaker = Value then Exit;

  FMapMaker := Value;
  ControlChanges('MapMaker');
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

procedure TGMCustomMapOptions.SetOverviewMapControl(const Value: Boolean);
begin
  if FOverviewMapControl = Value then Exit;

  FOverviewMapControl := Value;
  ControlChanges('OverviewMapControl');
end;

procedure TGMCustomMapOptions.SetPanControl(const Value: Boolean);
begin
  if FPanControl = Value then Exit;

  FPanControl := Value;
  ControlChanges('PanControl');
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

procedure TGMCustomMapOptions.SetScrollwheel(const Value: Boolean);
begin
  if FScrollwheel = Value then Exit;

  FScrollwheel := Value;
  ControlChanges('Scrollwheel');
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
  ControlChanges('Position');
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
  ControlChanges('Position');
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
                         TGMTransform.MapTypeStyleElementTypeToStr(FElementType),
                         TGMTransform.MapTypeStyleFeatureTypeToStr(FeatureType)
                         ]);
end;

procedure TGMCustomMapTypeStyle.SetElementType(const Value: TGMMapTypeStyleElementType);
begin
  if FElementType = Value then Exit;

  FElementType := Value;
  ControlChanges('ElementType');
end;

procedure TGMCustomMapTypeStyle.SetFeatureType(const Value: TGMMapTypeStyleFeatureType);
begin
  if FFeatureType = Value then Exit;

  FFeatureType := Value;
  ControlChanges('FeatureType');
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
            Format(Str, [
                         StringReplace(FloatToStr(FGamma), ',', '.', [rfReplaceAll]),
                         LowerCase(TGMTransform.GMBoolToStr(FInvertLightness, True)),
                         IntToStr(FLightness),
                         IntToStr(FSaturation),
                         TGMTransform.VisibilityToStr(FVisibility),
                         IntToStr(FWeight)
                         ]);
end;

procedure TGMCustomMapTypeStyler.SetGamma(const Value: Real);
begin
  if FGamma = Value then Exit;

  FGamma := Value;
  if FGamma < 0.01 then FGamma := 0.01;
  if FGamma > 10 then FGamma := 10;

  ControlChanges('Gamma');
end;

procedure TGMCustomMapTypeStyler.SetInvertLightness(const Value: Boolean);
begin
  if FInvertLightness = Value then Exit;

  FInvertLightness := Value;
  ControlChanges('InvertLightness');
end;

procedure TGMCustomMapTypeStyler.SetLightness(const Value: Integer);
begin
  if FLightness = Value then Exit;

  FLightness := Value;
  if FLightness < -100 then FGamma := -100;
  if FLightness > 100 then FGamma := 100;

  ControlChanges('Lightness');
end;

procedure TGMCustomMapTypeStyler.SetSaturation(const Value: Integer);
begin
  if FSaturation = Value then Exit;

  FSaturation := Value;
  if FSaturation < -100 then FGamma := -100;
  if FSaturation > 100 then FGamma := 100;

  ControlChanges('Saturation');
end;

procedure TGMCustomMapTypeStyler.SetVisibility(const Value: TGMVisibility);
begin
  if FVisibility = Value then Exit;

  FVisibility := Value;
  ControlChanges('Visibility');
end;

procedure TGMCustomMapTypeStyler.SetWeight(const Value: Integer);
begin
  if FWeight = Value then Exit;

  FWeight := Value;
  if FWeight < 0 then FWeight := 0;

  ControlChanges('Weight');
end;

{ TGMCustomGMMap }

procedure TGMCustomGMMap.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomGMMap then
  begin
    Active := TGMCustomGMMap(Source).Active;
    GoogleAPIVer := TGMCustomGMMap(Source).GoogleAPIVer;
    GoogleAPIKey := TGMCustomGMMap(Source).GoogleAPIKey;
    IntervalEvents := TGMCustomGMMap(Source).IntervalEvents;
    APILang := TGMCustomGMMap(Source).APILang;
  end;
end;

constructor TGMCustomGMMap.Create(AOwner: TComponent);
begin
  inherited;

  FActive := False;
  FGoogleAPIKey := '';
  FGoogleAPIVer := api323;
  FIntervalEvents := 200;
  FAPILang := lEnglish;
end;

procedure TGMCustomGMMap.FitBounds(Bounds: TGMLatLngBounds);
begin
  ExecuteJavaScript('FitBounds', Bounds.PropToString);
end;

function TGMCustomGMMap.GetBaseHTMLCode: string;
var
  List: TStringList;
  Stream: TResourceStream;
  StrTmp: string;
begin
  if not Assigned(FWebBrowser) then
    raise EGMUnassignedObject.Create(['WebBrowser'], Language); // Object %s unassigned.

  Result := '';

  List := TStringList.Create;
  try
    try
      Stream := TResourceStream.Create(HInstance, ct_RES_MAPA_CODE, RT_RCDATA);
      List.LoadFromStream(Stream);

      // replaces API_KEY variable
      List.Text := StringReplace(List.Text, ct_API_KEY, FGoogleAPIKey, []);

      // replaces API_VER variable
      StrTmp := TGMTransform.GoogleAPIVerToStr(FGoogleAPIVer);
      List.Text := StringReplace(List.Text, ct_API_VER, StrTmp, []);

      // replaces API_LAN variable
      StrTmp := LowerCase(TGMTransform.APILangToStr(FAPILang));
      List.Text := StringReplace(List.Text, ct_API_LAN, StrTmp, []);

      {$IFDEF DELPHI2010}
      StrTmp := IncludeTrailingPathDelimiter(TPath.GetTempPath) + ct_FILE_NAME;
      {$ELSE}
      StrTmp := IncludeTrailingPathDelimiter(GetTempPath) + ct_FILE_NAME;
      {$ENDIF}
      List.SaveToFile(StrTmp);

      Result := StrTmp;
    finally
      if Assigned(Stream) then FreeAndNil(Stream);
      if Assigned(List) then FreeAndNil(List);
    end;
  except
    raise EGMCanLoadResource.Create(Language);  // Can't load map resource.
  end;
end;

procedure TGMCustomGMMap.OnTimer(Sender: TObject);
begin

end;

procedure TGMCustomGMMap.PropertyChanged(Prop: TPersistent; PropName: string);
const
  Str1 = '%s';
  Str2 = '%s,%s';
begin
  if not FActive then Exit;

  if (Prop is TGMCustomMapOptions) and SameText(PropName, 'Zoom') then
    ExecuteJavaScript('MapChangeProperty', Format(Str2, [
                                                         QuotedStr(PropName),
                                                         IntToStr(TGMCustomMapOptions(Prop).Zoom)
                                                        ]));
  if (Prop is TGMLatLng) then
    ExecuteJavaScript('MapChangeCenter', Format(Str1, [
                                                       TGMLatLng(Prop).PropToString
                                                      ]));


  if Assigned(FOnPropertyChanges) then FOnPropertyChanges(Prop, PropName);
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
    LoadBlankPage;

  //SetEnableTimer(FActive); (*1 *)

  if Assigned(FOnActiveChange) then FOnActiveChange(Self);
end;

procedure TGMCustomGMMap.SetAPILang(const Value: TGMAPILang);
begin
  if FAPILang = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language); // The map is active. To change this property you must to deactivate it first.

  FAPILang := Value;
end;

procedure TGMCustomGMMap.SetGoogleAPIKey(const Value: string);
begin
  if FGoogleAPIKey = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language); // The map is active. To change this property you must to deactivate it first.

  FGoogleAPIKey := Value;
end;

procedure TGMCustomGMMap.SetGoogleAPIVer(const Value: TGoogleAPIVer);
begin
  if FGoogleAPIVer = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language); // The map is active. To change this property you must to deactivate it first.

  FGoogleAPIVer := Value;
end;

procedure TGMCustomGMMap.SetIntervalEvents(const Value: Integer);
begin
  if FIntervalEvents = Value then Exit;

  FIntervalEvents := Value;
  SetIntervalTimer(FIntervalEvents);

  if csDesigning in ComponentState then Exit;

  if Assigned(FOnIntervalEventsChange) then FOnIntervalEventsChange(Self);
end;

procedure TGMCustomGMMap.SetPrecision(const Value: Integer);
begin
  if FPrecision = Value then Exit;

  FPrecision := Value;

  if FPrecision < 0 then FPrecision := 0;
  if FPrecision > 17 then FPrecision := 17;

  if Assigned(FOnPrecisionChange) then FOnPrecisionChange(Self);
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
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#ZoomControlOptions';
end;

function TGMZoomControlOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         QuotedStr(TGMTransform.PositionToStr(Position))
                        ]);
end;

procedure TGMZoomControlOptions.SetPosition(const Value: TGMControlPosition);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges('Position');
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
    FullScreenControl := TGMStreetViewPanoramaOptions(Source).FullScreenControl;
    FullScreenControlOptions.Assign(TGMStreetViewPanoramaOptions(Source).FullScreenControlOptions);
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
  FFullScreenControl := True;
  FFullScreenControlOptions := TGMFullScreenControlOptions.Create(Self);
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
  if Assigned(FFullScreenControlOptions) then FreeAndNil(FFullScreenControlOptions);
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
  Str = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s';
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
                         LowerCase(TGMTransform.GMBoolToStr(FFullScreenControl, True)),
                         FFullScreenControlOptions.PropToString,
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
  ControlChanges('AddressControl');
end;

procedure TGMStreetViewPanoramaOptions.SetClickToGo(const Value: Boolean);
begin
  if FClickToGo = Value then Exit;

  FClickToGo := Value;
  ControlChanges('ClickToGo');
end;

procedure TGMStreetViewPanoramaOptions.SetDisableDefaultUI(
  const Value: Boolean);
begin
  if FDisableDefaultUI = Value then Exit;

  FDisableDefaultUI := Value;
  ControlChanges('DisableDefaultUI');
end;

procedure TGMStreetViewPanoramaOptions.SetDisableDoubleClickZoom(
  const Value: Boolean);
begin
  if FDisableDoubleClickZoom = Value then Exit;

  FDisableDoubleClickZoom := Value;
  ControlChanges('DisableDoubleClickZoom');
end;

procedure TGMStreetViewPanoramaOptions.SetEnableCloseButton(
  const Value: Boolean);
begin
  if FEnableCloseButton = Value then Exit;

  FEnableCloseButton := Value;
  ControlChanges('EnableCloseButton');
end;

procedure TGMStreetViewPanoramaOptions.SetFullScreenControl(
  const Value: Boolean);
begin
  if FFullScreenControl = Value then Exit;

  FFullScreenControl := Value;
  ControlChanges('FullScreenControl');
end;

procedure TGMStreetViewPanoramaOptions.SetImageDateControl(
  const Value: Boolean);
begin
  if FImageDateControl = Value then Exit;

  FImageDateControl := Value;
  ControlChanges('ImageDateControl');
end;

procedure TGMStreetViewPanoramaOptions.SetLinksControl(const Value: Boolean);
begin
  if FLinksControl = Value then Exit;

  FLinksControl := Value;
  ControlChanges('LinksControl');
end;

procedure TGMStreetViewPanoramaOptions.SetPanControl(const Value: Boolean);
begin
  if FPanControl = Value then Exit;

  FPanControl := Value;
  ControlChanges('PanControl');
end;

procedure TGMStreetViewPanoramaOptions.SetScrollwheel(const Value: Boolean);
begin
  if FScrollwheel = Value then Exit;

  FScrollwheel := Value;
  ControlChanges('Scrollwheel');
end;

procedure TGMStreetViewPanoramaOptions.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit;

  FVisible := Value;
  ControlChanges('Visible');
end;

procedure TGMStreetViewPanoramaOptions.SetZoomControl(const Value: Boolean);
begin
  if FZoomControl = Value then Exit;

  FZoomControl := Value;
  ControlChanges('ZoomControl');
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
  ControlChanges('Position');
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

  ControlChanges('Heading');
end;

procedure TGMStreetViewPov.SetPitch(const Value: Integer);
begin
  if FPitch = Value then Exit;

  FPitch := Value;
  if FPitch < -90 then FPitch := -90;
  if FPitch > 90 then FPitch := 90;

  ControlChanges('Pitch');
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
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#FullscreenControlOptions';
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

end.
