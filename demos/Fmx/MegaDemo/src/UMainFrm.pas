{**
  @abstract(Unidad @code(UMainFrm) para la MegaDemo FMX de GMLib.)
  @author(Xavier Martinez (cadetill) <xmartinez@julia.ad>)

  Formulario principal de la demo FMX con soporte para Google Maps y OpenStreetMap.
  Reescritura completa basada en la estructura de la VCL MegaDemo.
  @br@br
  @bold(Dependencias):
  @unorderedList(
    @item(FMX.Controls - Controles de FMX)
    @item(FMX.TabControl - Tabs)
    @item(FMX.WebBrowser - Navegador web)
    @item(uGMLib.Fmx.Map - Componente GM)
    @item(uOSMLib.Fmx.Map - Componente OSM)
    @item(uGMLib.Geometry - Funciones geom&eacute;tricas)
  )
}
unit UMainFrm;

interface

uses
  System.Classes, System.SysUtils, System.StrUtils, System.Types, System.UITypes,
  System.Math, System.RegularExpressions, System.IOUtils,
  FMX.Controls, FMX.Controls.Presentation, FMX.Edit, FMX.Forms, FMX.Layouts,
  FMX.ListBox, FMX.Memo, FMX.Memo.Types, FMX.StdCtrls, FMX.Types, FMX.WebBrowser,
  FMX.ScrollBox, FMX.TabControl, FMX.DialogService,
  uMapLib.Core.Offline, uMapLib.Offline.Types,
  uMapLib.Core.Component,
  uGMLib.Core.Types, uGMLib.Google.Types, uGMLib.Map, uGMLib.MapOptions,
  uGMLib.Fmx.Map, uGMLib.Fmx.Marker, uGMLib.Fmx.Polyline, uGMLib.Fmx.Polygon,
  uGMLib.Fmx.Rectangle, uGMLib.Fmx.Circle, uGMLib.Fmx.InfoWindow,
  uGMLib.Marker, uGMLib.Polyline, uGMLib.Polygon, uGMLib.Rectangle, uGMLib.Circle,
  uGMLib.InfoWindow, uGMLib.GroundOverlay, uGMLib.GeoCode, uGMLib.Elevation,
  uGMLib.Routes, uGMLib.Geometry,
  uOSMLib.Fmx.Map, uOSMLib.Map, FMX.Colors;

type
  TMainFrm = class(TForm)
    // === Outer structure ===
    pcSupplier: TTabControl;
    tsGM: TTabItem;
    tsOSM: TTabItem;
    pRight: TLayout;
    lStatus: TLabel;
    mLog: TMemo;
    EdgeBrowser1: TWebBrowser;
    GMMap: TGMLibFmxMap;
    OSMMap: TOSMLibFmxMap;

    // === GM nested TabControl ===
    pcGMOptions: TTabControl;
    tsMap: TTabItem;
    FTabMarkers: TTabItem;
    FTabOverlays: TTabItem;
    FTabInfoWindows: TTabItem;
    FTabGeoCode: TTabItem;
    FTabElevation: TTabItem;
    FTabRoutes: TTabItem;
    FTabGeometry: TTabItem;

    // === GM > Map > Top layout (API Key, MapId, buttons) ===
    pMapTop: TLayout;
    lAPIKey: TLabel;
    eAPIKey: TEdit;
    MapIdLabel: TLabel;
    eMapId: TEdit;
    bActivate: TButton;
    bApplyOptions: TButton;

    // === GM > Map > Map options TabControl (General | Controls) ===
    pcMapOptions: TTabControl;
    tsGMGeneral: TTabItem;
    FGeneralScroll: TVertScrollBox;
    lblMapType: TLabel;
    cbMapTypeId: TComboBox;
    lColorScheme: TLabel;
    cbColorScheme: TComboBox;
    lRenderType: TLabel;
    cbRenderType: TComboBox;
    lGestureHandling: TLabel;
    cbGestureHandling: TComboBox;
    HeadingLabel: TLabel;
    eHeading: TEdit;
    TiltLabel: TLabel;
    eTilt: TEdit;
    lBackGroundColor: TLabel;
    lMinZoom: TLabel;
    eMinZoom: TEdit;
    lMaxZoom: TLabel;
    eMaxZoom: TEdit;
    cbClickableIcons: TCheckBox;
    cbDisableDefaultUI: TCheckBox;
    cbDisableDoubleClickZoom: TCheckBox;
    cbScrollwheel: TCheckBox;
    cbKeyboardShortcuts: TCheckBox;
    cbIsFractionalZoomEnabled: TCheckBox;
    lCenter: TLabel;
    eLat: TEdit;
    eLng: TEdit;
    lSep: TLabel;
    eZoom: TEdit;
    lZoom: TLabel;
    cbNoClear: TCheckBox;

    // === GM > Map > Controls ===
    FTabControls: TTabItem;
    FControlsScroll: TVertScrollBox;
    FZoomCtrlChk: TCheckBox;
    FZoomPosCombo: TComboBox;
    FMapTypeCtrlChk: TCheckBox;
    FMapTypePosCombo: TComboBox;
    FMapTypeStyleCombo: TComboBox;
    FScaleCtrlChk: TCheckBox;
    FScaleStyleCombo: TComboBox;
    FRotateCtrlChk: TCheckBox;
    FRotatePosCombo: TComboBox;
    FStreetViewCtrlChk: TCheckBox;
    FStreetViewPosCombo: TComboBox;
    FFullscreenCtrlChk: TCheckBox;
    FFullscreenPosCombo: TComboBox;
    FCameraCtrlChk: TCheckBox;
    FCameraPosCombo: TComboBox;

    // === GM > Markers ===
    FMarkersScroll: TVertScrollBox;
    FMarkerAddBtn: TButton;
    FMarkerDelBtn: TButton;
    FMarkerClearBtn: TButton;
    FMarkerUpdateBtn: TButton;
    FZoomToMarkerBtn: TButton;
    FZoomToMarkersBtn: TButton;
    FMarkerList: TListBox;
    lblMarkerLat: TLabel;
    FMarkerLatEd: TEdit;
    lblMarkerLng: TLabel;
    FMarkerLngEd: TEdit;
    lblMarkerTitle: TLabel;
    FMarkerTitleEd: TEdit;
    FMarkerDraggChk: TCheckBox;
    FMarkerVisChk: TCheckBox;
    FMarkerClickChk: TCheckBox;
    lblMarkerContentMode: TLabel;
    FMarkerContentModeCombo: TComboBox;
    lblMarkerCollision: TLabel;
    FMarkerCollisionCombo: TComboBox;

    // === GM > Markers > Content tabs (HTML | Label | Pin) ===
    FMarkerContentTabControl: TTabControl;
    FTabMarkerHTML: TTabItem;
    FMarkerHtmlMemo: TMemo;
    FTabMarkerLabel: TTabItem;
    lblMarkerLabelText: TLabel;
    FMarkerLabelTextEd: TEdit;
    lblMarkerLabelTextColor: TLabel;
    FMarkerLabelTextColorCombo: TColorComboBox;
    lblMarkerLabelBgColor: TLabel;
    FMarkerLabelBgColorCombo: TColorComboBox;
    lblMarkerLabelBorderColor: TLabel;
    FMarkerLabelBorderColorCombo: TColorComboBox;
    lblMarkerLabelCorner: TLabel;
    FMarkerLabelCornerEd: TEdit;
    lblFontSize: TLabel;
    FMarkerLabelFontSizeEd: TEdit;
    FMarkerLabelFontBoldChk: TCheckBox;
    lblMarkerLabelPadH: TLabel;
    FMarkerLabelPadHEd: TEdit;
    lblMarkerLabelPadV: TLabel;
    FMarkerLabelPadVEd: TEdit;
    FTabMarkerPin: TTabItem;
    lblMarkerPinBgColor: TLabel;
    FMarkerPinBgColorCombo: TColorComboBox;
    lblMarkerPinBorderColor: TLabel;
    FMarkerPinBorderColorCombo: TColorComboBox;
    lblMarkerPinGlyphText: TLabel;
    FMarkerPinGlyphTextEd: TEdit;
    lblMarkerPinGlyphColor: TLabel;
    FMarkerPinGlyphColorCombo: TColorComboBox;
    lblMarkerPinScale: TLabel;
    FMarkerPinScaleEd: TEdit;

    // === GM > Overlays nested TabControl ===
    FOverlaysTabControl: TTabControl;
    FTabPolyline: TTabItem;
    FTabPolygon: TTabItem;
    FTabRectangle: TTabItem;
    FTabCircle: TTabItem;
    FTabGroundOverlay: TTabItem;
    FTabLayers: TTabItem;

    // === Polyline ===
    FPolylineAddBtn: TButton;
    FPolylineDelBtn: TButton;
    FPolylineClearBtn: TButton;
    FPolylineUpdBtn: TButton;
    FZoomToPolylineBtn: TButton;
    FZoomToPolylinesBtn: TButton;
    FPolylineList: TListBox;
    lblPolylinePath: TLabel;
    FPolylinePathMemo: TMemo;
    lblPolylineStrokeColor: TLabel;
    FPolylineStrokeColorCombo: TColorComboBox;
    lblPolylineOpacity: TLabel;
    FPolylineStrokeOpacityEd: TEdit;
    lblPolylineWeight: TLabel;
    FPolylineStrokeWeightEd: TEdit;
    FPolylineClickChk: TCheckBox;
    FPolylineDragChk: TCheckBox;
    FPolylineEditChk: TCheckBox;
    FPolylineGeoChk: TCheckBox;
    FPolylineVisChk: TCheckBox;

    // === Polygon ===
    FPolygonAddBtn: TButton;
    FPolygonDelBtn: TButton;
    FPolygonClearBtn: TButton;
    FPolygonUpdBtn: TButton;
    FZoomToPolygonBtn: TButton;
    FZoomToPolygonsBtn: TButton;
    FPolygonList: TListBox;
    lblPolygonPath: TLabel;
    FPolygonPathMemo: TMemo;
    lblPolygonStrokeColor: TLabel;
    FPolygonStrokeColorCombo: TColorComboBox;
    lblPolygonFillColor: TLabel;
    FPolygonFillColorCombo: TColorComboBox;
    lblPolygonStrokeOp: TLabel;
    FPolygonStrokeOpEd: TEdit;
    lblPolygonStrokeWt: TLabel;
    FPolygonStrokeWtEd: TEdit;
    lblPolygonFillOp: TLabel;
    FPolygonFillOpEd: TEdit;
    FPolygonClickChk: TCheckBox;
    FPolygonDragChk: TCheckBox;
    FPolygonEditChk: TCheckBox;
    FPolygonGeoChk: TCheckBox;
    FPolygonVisChk: TCheckBox;

    // === Rectangle ===
    FRectAddBtn: TButton;
    FRectDelBtn: TButton;
    FRectClearBtn: TButton;
    FRectUpdBtn: TButton;
    FZoomToRectBtn: TButton;
    FZoomToRectsBtn: TButton;
    FRectList: TListBox;
    lblRectNorth: TLabel;
    FRectNorthEd: TEdit;
    lblRectSouth: TLabel;
    FRectSouthEd: TEdit;
    lblRectEast: TLabel;
    FRectEastEd: TEdit;
    lblRectWest: TLabel;
    FRectWestEd: TEdit;
    lblRectStrokeColor: TLabel;
    FRectStrokeColorCombo: TColorComboBox;
    lblRectFillColor: TLabel;
    FRectFillColorCombo: TColorComboBox;
    lblRectStrokeOp: TLabel;
    FRectStrokeOpEd: TEdit;
    lblRectStrokeWt: TLabel;
    FRectStrokeWtEd: TEdit;
    lblRectFillOp: TLabel;
    FRectFillOpEd: TEdit;
    FRectClickChk: TCheckBox;
    FRectDragChk: TCheckBox;
    FRectEditChk: TCheckBox;
    FRectVisChk: TCheckBox;

    // === Circle ===
    FCircleAddBtn: TButton;
    FCircleDelBtn: TButton;
    FCircleClearBtn: TButton;
    FCircleUpdBtn: TButton;
    FZoomToCircleBtn: TButton;
    FZoomToCirclesBtn: TButton;
    FCircleList: TListBox;
    lblCircleCenterLat: TLabel;
    FCircleLatEd: TEdit;
    lblCircleCenterLng: TLabel;
    FCircleLngEd: TEdit;
    lblCircleRadius: TLabel;
    FRadiusEd: TEdit;
    lblCircleStrokeColor: TLabel;
    FCircleStrokeColorCombo: TColorComboBox;
    lblCircleFillColor: TLabel;
    FCircleFillColorCombo: TColorComboBox;
    lblCircleStrokeOp: TLabel;
    FCircleStrokeOpEd: TEdit;
    lblCircleStrokeWt: TLabel;
    FCircleStrokeWtEd: TEdit;
    lblCircleFillOp: TLabel;
    FCircleFillOpEd: TEdit;
    FCircleClickChk: TCheckBox;
    FCircleDragChk: TCheckBox;
    FCircleEditChk: TCheckBox;
    FCircleVisChk: TCheckBox;

    // === GroundOverlay ===
    FGroundScroll: TVertScrollBox;
    lblGroundUrl: TLabel;
    FGroundUrlEd: TEdit;
    lblGroundNorth: TLabel;
    FGroundNorthEd: TEdit;
    lblGroundSouth: TLabel;
    FGroundSouthEd: TEdit;
    lblGroundEast: TLabel;
    FGroundEastEd: TEdit;
    lblGroundWest: TLabel;
    FGroundWestEd: TEdit;
    lblGroundOpacity: TLabel;
    FGroundOpacityEd: TEdit;
    FGroundAddBtn: TButton;
    FGroundDelBtn: TButton;
    FGroundClearBtn: TButton;
    FGroundUpdBtn: TButton;
    FGroundZoomBtn: TButton;
    FGroundZoomAllBtn: TButton;
    FGroundClickableChk: TCheckBox;
    FGroundVisibleChk: TCheckBox;
    FGroundList: TListBox;

    // === Layers ===
    FLayersScroll: TVertScrollBox;
    FTrafficVisChk: TCheckBox;
    FTrafficAutoChk: TCheckBox;
    FTransitVisChk: TCheckBox;
    FBicyclingVisChk: TCheckBox;
    lblKmlUrl: TLabel;
    FKmlUrlEd: TEdit;
    lblKmlZIndex: TLabel;
    FKmlZIndexEd: TEdit;
    FKmlVisChk: TCheckBox;
    FKmlClickChk: TCheckBox;
    FKmlPreserveChk: TCheckBox;
    FKmlScreenChk: TCheckBox;
    FKmlSuppressChk: TCheckBox;
    FApplyLayersBtn: TButton;

    // === GM > InfoWindows ===
    FInfoWindowLabel: TLabel;

    // === GM > GeoCode ===
    FGeoScroll: TVertScrollBox;

    // === GM > Elevation ===
    FElevScroll: TVertScrollBox;

    // === GM > Routes ===
    FRoutesScroll: TVertScrollBox;
    lblRouteOrigin: TLabel;
    FRouteFromEd: TEdit;
    lblRouteDest: TLabel;
    FRouteToEd: TEdit;
    FRouteComputeBtn: TButton;
    lbRoutes: TListBox;
    cbRouteCloseOthers: TCheckBox;

    // === GM > Geometry ===
    FGeometryScroll: TVertScrollBox;
    lblGeomFromLat: TLabel;
    FGeomFromLatEd: TEdit;
    lblGeomFromLng: TLabel;
    FGeomFromLngEd: TEdit;
    lblGeomToLat: TLabel;
    FGeomToLatEd: TEdit;
    lblGeomToLng: TLabel;
    FGeomToLngEd: TEdit;
    lblGeomPointLat: TLabel;
    FGeomPointLatEd: TEdit;
    lblGeomPointLng: TLabel;
    FGeomPointLngEd: TEdit;
    FGeomComputeBtn: TButton;
    FGeomResultMemo: TMemo;

    // === OSM nested TabControl ===
    pcOSMOptions: TTabControl;
    tsOSMGeneral: TTabItem;
    tsOSMOffline: TTabItem;
    tsOSMMarkers: TTabItem;
    tsOSMPopups: TTabItem;

    // === OSM > General ===
    FOSMScroll: TVertScrollBox;
    bActivateOSM: TButton;
    lblOSMCenterLat: TLabel;
    eOSMCenterLat: TEdit;
    lblOSMCenterLng: TLabel;
    eOSMCenterLng: TEdit;
    lblOSMZoom: TLabel;
    eOSMZoom: TEdit;
    lblOSMBearing: TLabel;
    eOSMBearing: TEdit;
    lblOSMPitch: TLabel;
    eOSMPitch: TEdit;
    lblOSMMinZoom: TLabel;
    eOSMMinZoom: TEdit;
    lblOSMMaxZoom: TLabel;
    eOSMMaxZoom: TEdit;
    bApplyOSMView: TButton;
    lblOSMStyleUrl: TLabel;
    eOSMStyleUrl: TEdit;
    bApplyOSMStyle: TButton;
    cbOSMLogMove: TCheckBox;
    cbOSMLogRender: TCheckBox;
    cbOSMLogData: TCheckBox;
    cbOSMDragPan: TCheckBox;
    cbOSMDragRotate: TCheckBox;
    cbOSMDoubleClickZoom: TCheckBox;
    cbOSMScrollZoom: TCheckBox;
    cbOSMKeyboard: TCheckBox;
    cbOSMTouchZoomRotate: TCheckBox;
    cbOSMTouchPitch: TCheckBox;
    cbOSMCooperativeGestures: TCheckBox;
    lblOSMMapMode: TLabel;
    cbOSMMapMode: TComboBox;
    lOSMOfflineTileJsonUrl: TLabel;
    eOSMOfflineTileJsonUrl: TEdit;
    lOSMOfflineServerExecutable: TLabel;
    eOSMOfflineServerExecutable: TEdit;
    lOSMOfflineServerPort: TLabel;
    eOSMOfflineServerPort: TEdit;
    lOSMOfflineSourcePreset: TLabel;
    cbOSMOfflineSourcePreset: TComboBox;
    bOSMDownloadRegion: TButton;
    bOSMDeleteRegion: TButton;
    lbOSMRegions: TListBox;

    // === OSM > Markers ===
    lbOSMMarkers: TListBox;
    bOSMClearMarkers: TButton;
    bOSMZoomToMarkers: TButton;

    // === OSM > Popups ===
    lbOSMPopups: TListBox;
    bOSMAddPopup: TButton;
    bOSMDeletePopup: TButton;
    bOSMClearPopups: TButton;
    bOSMUpdatePopup: TButton;
    bOSMPopupUseSelectedMarker: TButton;
    lOSMPopupLat: TLabel;
    lOSMPopupLng: TLabel;
    lOSMPopupAnchorObjectId: TLabel;
    lOSMPopupMaxWidth: TLabel;
    lOSMPopupPresetStyle: TLabel;
    lOSMPopupContentType: TLabel;
    lOSMPopupContent: TLabel;
    eOSMPopupLat: TEdit;
    eOSMPopupLng: TEdit;
    eOSMPopupAnchorObjectId: TEdit;
    eOSMPopupMaxWidth: TEdit;
    cbOSMPopupCssClass: TComboBox;
    cbOSMPopupContentType: TComboBox;
    mOSMPopupContent: TMemo;
    cbOSMPopupVisible: TCheckBox;
    cbOSMPopupCloseButton: TCheckBox;
    cbOSMPopupCloseOnClick: TCheckBox;
    cbOSMPopupCloseOnMove: TCheckBox;
    cbOSMPopupCloseOthersBeforeOpen: TCheckBox;

    FBackgroundColorCombo: TColorComboBox;
    lblControlSize: TLabel;
    FControlSizeEd: TEdit;
    clbMapTypeIds: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;

    // ========== Event declarations ==========
    procedure ActivateBtnClick(Sender: TObject);
    procedure ApplyOptionsBtnClick(Sender: TObject);
    procedure SupplierTabChange(Sender: TObject);
    procedure MarkerAddClick(Sender: TObject);
    procedure MarkerDeleteClick(Sender: TObject);
    procedure MarkerClearClick(Sender: TObject);
    procedure MarkerUpdateClick(Sender: TObject);
    procedure MarkerListClick(Sender: TObject);
    procedure ZoomToMarkerClick(Sender: TObject);
    procedure ZoomToMarkersClick(Sender: TObject);
    procedure PolylineAddClick(Sender: TObject);
    procedure PolylineDeleteClick(Sender: TObject);
    procedure PolylineClearClick(Sender: TObject);
    procedure PolylineUpdateClick(Sender: TObject);
    procedure PolylineListClick(Sender: TObject);
    procedure ZoomToPolylineClick(Sender: TObject);
    procedure ZoomToPolylinesClick(Sender: TObject);
    procedure PolygonAddClick(Sender: TObject);
    procedure PolygonDeleteClick(Sender: TObject);
    procedure PolygonClearClick(Sender: TObject);
    procedure PolygonUpdateClick(Sender: TObject);
    procedure PolygonListClick(Sender: TObject);
    procedure ZoomToPolygonClick(Sender: TObject);
    procedure ZoomToPolygonsClick(Sender: TObject);
    procedure RectAddClick(Sender: TObject);
    procedure RectDeleteClick(Sender: TObject);
    procedure RectClearClick(Sender: TObject);
    procedure RectUpdateClick(Sender: TObject);
    procedure RectListClick(Sender: TObject);
    procedure ZoomToRectClick(Sender: TObject);
    procedure ZoomToRectsClick(Sender: TObject);
    procedure CircleAddClick(Sender: TObject);
    procedure CircleDeleteClick(Sender: TObject);
    procedure CircleClearClick(Sender: TObject);
    procedure CircleUpdateClick(Sender: TObject);
    procedure CircleListClick(Sender: TObject);
    procedure ZoomToCircleClick(Sender: TObject);
    procedure ZoomToCirclesClick(Sender: TObject);
    procedure ApplyLayers;
    procedure ApplyLayersClick(Sender: TObject);
    procedure RouteCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
    procedure RouteListClick(Sender: TObject);
    procedure RouteComputeClick(Sender: TObject);
    procedure GroundAddClick(Sender: TObject);
    procedure GroundDeleteClick(Sender: TObject);
    procedure GroundClearClick(Sender: TObject);
    procedure GroundUpdateClick(Sender: TObject);
    procedure GroundZoomClick(Sender: TObject);
    procedure GroundZoomAllClick(Sender: TObject);
    procedure GroundListClick(Sender: TObject);
    procedure GeomComputeClick(Sender: TObject);
    procedure OSMActivateClick(Sender: TObject);
    procedure OSMApplyViewClick(Sender: TObject);
    procedure OSMApplyStyleClick(Sender: TObject);
    procedure ApplyOSMEventFilterClick(Sender: TObject);
    procedure OSMDownloadRegionClick(Sender: TObject);
    procedure OSMDeleteRegionClick(Sender: TObject);
    procedure OSMListRegionsClick(Sender: TObject);
    procedure OSMClearMarkersClick(Sender: TObject);
    procedure OSMZoomToMarkersClick(Sender: TObject);
    procedure OSMMarkerListClick(Sender: TObject);
    procedure OSMPopupListClick(Sender: TObject);
    procedure OSMAddPopupClick(Sender: TObject);
    procedure OSMUpdatePopupClick(Sender: TObject);
    procedure OSMDeletePopupClick(Sender: TObject);
    procedure OSMClearPopupsClick(Sender: TObject);
    procedure OSMUseSelectedMarkerForPopupClick(Sender: TObject);

    // === Map events ===
    procedure GMMapMapReady(Sender: TObject);
    procedure GMMapMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure GMMapMapDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure GMMapMapDragEnd(Sender: TObject);
    procedure GMMapMapZoomChanged(Sender: TObject; AZoom: Integer);
    procedure GMMapMapBoundsChanged(Sender: TObject; ABounds: TGMLatLngBounds);
    procedure GMMapMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure GMMapIdle(Sender: TObject);

    // === OSM Map events ===
    procedure OSMMapReady(Sender: TObject);
    procedure OSMMapClickEvent(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure OSMMarkerClickEvent(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure OSMMapCoordinateEvent(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure OSMMapSimpleEvent(Sender: TObject);
    procedure OSMMapBoundsChangedEvent(Sender: TObject; ANorth, ASouth, AEast, AWest: Double);
    procedure OSMMapViewChangedEvent(Sender: TObject; ACenter: TMapLibLatLng; AZoom, ABearing, APitch: Double);
    procedure OSMMapErrorEvent(Sender: TObject; const AMessage: string);
    procedure OSMMapDownloadProgress(Sender: TObject; const AJobId: string; APercent: Double; ABytesDone, ABytesTotal: Int64);
    procedure OSMMapRegionReady(Sender: TObject; const ARegionId: TMapLibOfflineRegionId);
    procedure OSMMapOfflineError(Sender: TObject; AErrorCode: Integer; const AUserMessage, ATechnicalMessage: string);

    procedure MapMarkerClick(Sender: TObject);
    procedure MapMarkersDragStart(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure MapMarkersDrag(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure MapMarkersDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);

    procedure MapPolylineDragStart(Sender: TObject);
    procedure MapPolylineDrag(Sender: TObject);
    procedure MapPolylineDragEnd(Sender: TObject);
    procedure MapPolylinePathChanged(Sender: TObject);

    procedure MapPolygonDragStart(Sender: TObject);
    procedure MapPolygonDrag(Sender: TObject);
    procedure MapPolygonDragEnd(Sender: TObject);
    procedure MapPolygonPathChanged(Sender: TObject);

    procedure MapRectangleDragStart(Sender: TObject);
    procedure MapRectangleDrag(Sender: TObject);
    procedure MapRectangleDragEnd(Sender: TObject);
    procedure MapRectangleBoundsChanged(Sender: TObject);

    procedure MapCircleDragStart(Sender: TObject);
    procedure MapCircleDrag(Sender: TObject);
    procedure MapCircleDragEnd(Sender: TObject);
    procedure MapCircleCenterChanged(Sender: TObject);
    procedure MapCircleRadiusChanged(Sender: TObject);

    procedure GeoCodeCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
    procedure ElevationCompleted(Sender: TObject; const AResponse: TGMElevationResponse);

  private
    FIsDraggingPolyline: Boolean;
    FIsDraggingPolygon: Boolean;
    FIsDraggingRectangle: Boolean;
    FIsDraggingCircle: Boolean;
    FCurrentMarkerForInfoWindow: TGMFmxMarkerItem;
    FCurrentInfoWindowForMarker: TGMFmxInfoWindowItem;
    FCurrentOSMMarkerForPopup: TOSMMarkerItem;
    FCurrentOSMPopupForMarker: TOSMPopupItem;

    function GM_COLORS(AIndex: Integer): TAlphaColor;
    procedure Log(const AText: string);
    procedure UpdateStatus(const AText: string);
    procedure InitializeDefaults;
    function Checks: Boolean;
    procedure ApplyOptions;
    procedure LoadMarkerToUI(AMarker: TGMFmxMarkerItem);
    procedure RefreshMarkerList;
    procedure RefreshPolylineList;
    procedure RefreshPolygonList;
    procedure RefreshRectangleList;
    procedure RefreshCircleList;
    procedure RefreshRouteList;
    procedure RefreshGroundOverlayList;
    procedure RefreshOSMMarkerList;
    procedure RefreshOSMPopupList;
    procedure RefreshOSMRegionsList;
    function ResolveRepoRootPath: string;
    function ResolveRepoAssetPathFromRoot(const ARelativePath: string): string;

    procedure BindMarkerEvents(AMarker: TGMFmxMarkerItem);
    procedure BindPolylineEvents(APolyline: TGMFmxPolylineItem);
    procedure BindPolygonEvents(APolygon: TGMFmxPolygonItem);
    procedure BindRectangleEvents(ARectangle: TGMFmxRectangleItem);
    procedure BindCircleEvents(ACircle: TGMFmxCircleItem);
    procedure BindGroundOverlayEvents(AGroundOverlay: TGMGroundOverlayItem);
    procedure BindOSMMarkerEvents(AMarker: TOSMMarkerItem);
    procedure BindOSMPopupEvents(APopup: TOSMPopupItem);
    procedure LoadOSMPopupToUI(APopup: TOSMPopupItem);
    procedure LoadUIToOSMPopup(APopup: TOSMPopupItem; APreservePosition: Boolean = False);
    function GetSelectedOSMPopupPresetStyle: TOSMPopupPresetStyle;
    function GetSelectedOSMPopupContentType: TOSMPopupContentType;
    procedure SelectOSMPopupPresetStyle(AValue: TOSMPopupPresetStyle);
    procedure SelectOSMPopupContentType(AValue: TOSMPopupContentType);
    procedure OSMPopupCloseEvent(Sender: TObject);
    procedure OSMPopupOpenEvent(Sender: TObject);
    procedure ShowOSMMarkerPopup(AMarker: TOSMMarkerItem);

    procedure ShowMarkerInfoWindow(AMarker: TGMFmxMarkerItem);
  public
    constructor Create(AOwner: TComponent); override;
  end;

const
  GM_COLORS_ARR: array[0..9] of TAlphaColor = (
    $FF000000, $FFFF0000, $FF00FF00, $FF0000FF, $FFFFFF00,
    $FFFF00FF, $FF00FFFF, $FFFFFFFF, $FF808080, $FFC0C0C0
  );
  COORD_TOLERANCE = 0.000001;

var
  MainFrm: TMainFrm;

implementation

{$R *.fmx}

uses
  FMX.Dialogs;

{ TMainFrm }

constructor TMainFrm.Create(AOwner: TComponent);
begin
  inherited;
  InitializeDefaults;
  RefreshMarkerList;
  RefreshPolylineList;
  RefreshPolygonList;
  RefreshRectangleList;
  RefreshCircleList;
  RefreshGroundOverlayList;
  RefreshOSMMarkerList;
  RefreshOSMRegionsList;
  pcSupplier.ActiveTab := tsGM;
  pcGMOptions.ActiveTab := tsMap;
  pcOSMOptions.ActiveTab := tsOSMGeneral;
  FOverlaysTabControl.ActiveTab := FTabPolyline;
  FMarkerContentTabControl.ActiveTab := FTabMarkerHTML;
  pcMapOptions.ActiveTab := tsGMGeneral;
  cbOSMMapMode.Items.Clear;
  cbOSMMapMode.Items.Add('Online');
  cbOSMMapMode.Items.Add('Offline');
  cbOSMMapMode.Items.Add('Hybrid');
  cbOSMMapMode.ItemIndex := 2;
  cbOSMPopupCssClass.Items.Clear;
  cbOSMPopupCssClass.Items.Add('Default');
  cbOSMPopupCssClass.Items.Add('Note');
  cbOSMPopupCssClass.Items.Add('Warning');
  cbOSMPopupCssClass.Items.Add('Dark');
  cbOSMPopupCssClass.Items.Add('Success');
  cbOSMPopupCssClass.ItemIndex := 0;
  cbOSMPopupContentType.Items.Clear;
  cbOSMPopupContentType.Items.Add('HTML');
  cbOSMPopupContentType.Items.Add('Text');
  cbOSMPopupContentType.ItemIndex := 0;
  OSMMap.OnMapReady := OSMMapReady;
  OSMMap.OnClick := OSMMapClickEvent;
  OSMMap.OnContextMenu := OSMMapCoordinateEvent;
  OSMMap.OnDblClick := OSMMapCoordinateEvent;
  OSMMap.OnBoundsChanged := OSMMapBoundsChangedEvent;
  ApplyOSMEventFilterClick(nil);
  OSMMap.OnError := OSMMapErrorEvent;
  OSMMap.OnOfflineDownloadProgress := OSMMapDownloadProgress;
  OSMMap.OnOfflineRegionReady := OSMMapRegionReady;
  OSMMap.OnOfflineError := OSMMapOfflineError;
  lbOSMPopups.OnChange := OSMPopupListClick;
  bOSMAddPopup.OnClick := OSMAddPopupClick;
  bOSMUpdatePopup.OnClick := OSMUpdatePopupClick;
  bOSMDeletePopup.OnClick := OSMDeletePopupClick;
  bOSMClearPopups.OnClick := OSMClearPopupsClick;
  bOSMPopupUseSelectedMarker.OnClick := OSMUseSelectedMarkerForPopupClick;

  for var I := 0 to OSMMap.Markers.Count - 1 do
    BindOSMMarkerEvents(OSMMap.Markers[I]);
  for var I := 0 to OSMMap.Popups.Count - 1 do
    BindOSMPopupEvents(OSMMap.Popups[I]);
  RefreshOSMMarkerList;
  RefreshOSMPopupList;
  RefreshOSMRegionsList;

  Log('MegaDemo FMX initialized.');
end;

function TMainFrm.GM_COLORS(AIndex: Integer): TAlphaColor;
begin
  if (AIndex >= 0) and (AIndex < Length(GM_COLORS_ARR)) then
    Result := GM_COLORS_ARR[AIndex]
  else
    Result := $FF000000;
end;

procedure TMainFrm.Log(const AText: string);
begin
  if Assigned(mLog) then
    mLog.Lines.Add(Format('[%s] %s', [FormatDateTime('hh:nn:ss', Now), AText]));
end;

procedure TMainFrm.UpdateStatus(const AText: string);
begin
  if Assigned(lStatus) then
    lStatus.Text := AText;
end;

procedure TMainFrm.InitializeDefaults;
begin
  eAPIKey.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  eMapId.Text := GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID');
  if eMapId.Text = '' then
    eMapId.Text := 'DEMO_MAP_ID';

  GMMap.Options.MapTypeId := mtRoadmap;
  GMMap.Options.ColorScheme := csLight;
  GMMap.Options.RenderingType := rtRaster;
  GMMap.Options.GestureHandling := ghAuto;
  GMMap.Options.Heading := 0;
  GMMap.Options.Tilt := 0;
  GMMap.Options.BackgroundColor := $FFC0C0C0;
  GMMap.Options.MinZoom := 0;
  GMMap.Options.MaxZoom := 22;
  GMMap.Options.ClickableIcons := True;
  GMMap.Options.DisableDefaultUI := False;
  GMMap.Options.DisableDoubleClickZoom := False;
  GMMap.Options.Scrollwheel := True;
  GMMap.Options.KeyboardShortcuts := True;
  GMMap.Options.IsFractionalZoomEnabled := False;
  GMMap.Options.TiltInteractionEnabled := True;
  GMMap.Options.HeadingInteractionEnabled := True;
  GMMap.Options.ZoomControl := True;
  GMMap.Options.MapTypeControl := True;
  GMMap.Options.ScaleControl := False;
  GMMap.Options.RotateControl := False;
  GMMap.Options.StreetViewControl := True;
  GMMap.Options.FullscreenControl := False;
  GMMap.Options.CameraControl := False;
  cbMapTypeId.ItemIndex := 0;
  cbColorScheme.ItemIndex := 0;
  cbRenderType.ItemIndex := 0;
  cbGestureHandling.ItemIndex := 0;
  FBackgroundColorCombo.ItemIndex := 9;
  FZoomPosCombo.ItemIndex := 0;
  FMapTypePosCombo.ItemIndex := 0;
  FMapTypeStyleCombo.ItemIndex := 0;
  FScaleStyleCombo.ItemIndex := 0;
  FRotatePosCombo.ItemIndex := 0;
  FStreetViewPosCombo.ItemIndex := 0;
  FFullscreenPosCombo.ItemIndex := 0;
  FCameraPosCombo.ItemIndex := 0;
  eMinZoom.Text := '0';
  eMaxZoom.Text := '22';
  eHeading.Text := '';
  eTilt.Text := '';
  FControlSizeEd.Text := '300';
  cbClickableIcons.IsChecked := True;
  cbDisableDefaultUI.IsChecked := False;
  cbDisableDoubleClickZoom.IsChecked := False;
  cbScrollwheel.IsChecked := True;
  cbKeyboardShortcuts.IsChecked := True;
  cbIsFractionalZoomEnabled.IsChecked := False;
  cbNoClear.IsChecked := False;
  FZoomCtrlChk.IsChecked := True;
  FMapTypeCtrlChk.IsChecked := True;
  FScaleCtrlChk.IsChecked := False;
  FRotateCtrlChk.IsChecked := False;
  FStreetViewCtrlChk.IsChecked := True;
  FFullscreenCtrlChk.IsChecked := False;
  FCameraCtrlChk.IsChecked := False;
  FTrafficVisChk.IsChecked := False;
  FTrafficAutoChk.IsChecked := True;
  FTransitVisChk.IsChecked := False;
  FBicyclingVisChk.IsChecked := False;
  cbRouteCloseOthers.IsChecked := False;
  eLat.Text := '41.3874';
  eLng.Text := '2.1686';
  eZoom.Text := '12';
  GMMap.Options.Zoom := 12;
  GMMap.Options.Center.Lat := 41.3874;
  GMMap.Options.Center.Lng := 2.1686;
  GMMap.Routes.OnCompleted := RouteCompleted;
  GMMap.Routes.CloseOthersBeforeVisible := False;

  eOSMCenterLat.Text := '41.3874';
  eOSMCenterLng.Text := '2.1686';
  eOSMZoom.Text := '12';
  eOSMBearing.Text := '0';
  eOSMPitch.Text := '0';
  eOSMMinZoom.Text := '0';
  eOSMMaxZoom.Text := '22';
  bActivateOSM.Text := 'Activate';
  bApplyOSMView.Text := 'Apply View';
  eOSMStyleUrl.Text := 'https://tiles.openfreemap.org/styles/bright';
  cbOSMDragPan.IsChecked := True;
  cbOSMDragRotate.IsChecked := True;
  cbOSMDoubleClickZoom.IsChecked := True;
  cbOSMScrollZoom.IsChecked := True;
  cbOSMKeyboard.IsChecked := True;
  cbOSMTouchZoomRotate.IsChecked := True;
  cbOSMTouchPitch.IsChecked := True;
  cbOSMCooperativeGestures.IsChecked := False;
  cbOSMLogMove.IsChecked := False;
  cbOSMLogRender.IsChecked := False;
  cbOSMLogData.IsChecked := False;
  cbOSMMapMode.ItemIndex := 2;
  eOSMOfflineTileJsonUrl.Text := 'https://tiles.openfreemap.org/planet/latest/{z}/{x}/{y}.pbf';
  eOSMOfflineServerExecutable.Text := ResolveRepoAssetPathFromRoot('resources\js\osm\vendor');
  eOSMOfflineServerPort.Text := ResolveRepoAssetPathFromRoot('resources\js\osm\offline\style.template.json');
  cbOSMOfflineSourcePreset.ItemIndex := 1;
  lbOSMRegions.Clear;
  lbOSMMarkers.Clear;
  lbOSMPopups.Clear;
  eOSMPopupLat.Text := '41.3874';
  eOSMPopupLng.Text := '2.1686';
  eOSMPopupAnchorObjectId.Text := '';
  eOSMPopupMaxWidth.Text := '0';
  cbOSMPopupCssClass.ItemIndex := 0;
  cbOSMPopupContentType.ItemIndex := 0;
  mOSMPopupContent.Lines.Text := '';
  cbOSMPopupVisible.IsChecked := True;
  cbOSMPopupCloseButton.IsChecked := True;
  cbOSMPopupCloseOnClick.IsChecked := True;
  cbOSMPopupCloseOnMove.IsChecked := False;
  cbOSMPopupCloseOthersBeforeOpen.IsChecked := False;
  OSMMap.StyleUrl := eOSMStyleUrl.Text;
  OSMMap.MapLibreCssUrl := ResolveRepoAssetPathFromRoot('resources\js\osm\vendor\maplibre-gl.css');
  OSMMap.MapLibreJsUrl := ResolveRepoAssetPathFromRoot('resources\js\osm\vendor\maplibre-gl.js');
  OSMMap.MapMode := omHybrid;
  OSMMap.OfflinePolicy := opPreferOffline;
  OSMMap.OfflineStoragePath := TPath.Combine(TPath.GetAppPath, 'offline');
  Log('Defaults initialized');
end;

function TMainFrm.Checks: Boolean;
begin
  Result := True;
end;

procedure TMainFrm.SupplierTabChange(Sender: TObject);
begin
  if pcSupplier.ActiveTab = tsGM then
  begin
    UpdateStatus('Google Maps tab active');
    if GMMap.Active then
      EdgeBrowser1.Visible := True
    else
      EdgeBrowser1.Visible := False;
  end
  else if pcSupplier.ActiveTab = tsOSM then
  begin
    UpdateStatus('OpenStreetMap tab active');
    if OSMMap.Active then
      EdgeBrowser1.Visible := True
    else
      EdgeBrowser1.Visible := False;
  end;
end;

procedure TMainFrm.ApplyOptions;
begin
  if not Assigned(GMMap) then Exit;
  GMMap.Options.MapTypeId := TGMMapTypeId(cbMapTypeId.ItemIndex);
  GMMap.Options.ColorScheme := TGMColorScheme(cbColorScheme.ItemIndex);
  GMMap.Options.RenderingType := TGMRenderingType(cbRenderType.ItemIndex);
  GMMap.Options.GestureHandling := TGMGestureHandling(cbGestureHandling.ItemIndex);
  GMMap.Options.Heading := StrToFloatDef(eHeading.Text, 0, TFormatSettings.Invariant);
  GMMap.Options.Tilt := StrToIntDef(eTilt.Text, 0);
  GMMap.Options.BackgroundColor := GM_COLORS(FBackgroundColorCombo.ItemIndex);
  GMMap.Options.MinZoom := StrToIntDef(eMinZoom.Text, 0);
  GMMap.Options.MaxZoom := StrToIntDef(eMaxZoom.Text, 22);
  GMMap.Options.ClickableIcons := cbClickableIcons.IsChecked;
  GMMap.Options.DisableDefaultUI := cbDisableDefaultUI.IsChecked;
  GMMap.Options.DisableDoubleClickZoom := cbDisableDoubleClickZoom.IsChecked;
  GMMap.Options.Scrollwheel := cbScrollwheel.IsChecked;
  GMMap.Options.KeyboardShortcuts := cbKeyboardShortcuts.IsChecked;
  GMMap.Options.IsFractionalZoomEnabled := cbIsFractionalZoomEnabled.IsChecked;
  GMMap.Options.NoClear := cbNoClear.IsChecked;
  GMMap.Options.ZoomControl := FZoomCtrlChk.IsChecked;
  GMMap.Options.ZoomControlOptions.Position := TGMControlPosition(FZoomPosCombo.ItemIndex);
  GMMap.Options.MapTypeControl := FMapTypeCtrlChk.IsChecked;
  GMMap.Options.MapTypeControlOptions.Position := TGMControlPosition(FMapTypePosCombo.ItemIndex);
  GMMap.Options.MapTypeControlOptions.Style := TGMMapTypeControlStyle(FMapTypeStyleCombo.ItemIndex);
  GMMap.Options.ScaleControl := FScaleCtrlChk.IsChecked;
  GMMap.Options.ScaleControlOptions.Style := TGMScaleControlStyle(FScaleStyleCombo.ItemIndex);
  GMMap.Options.RotateControl := FRotateCtrlChk.IsChecked;
  GMMap.Options.RotateControlOptions.Position := TGMControlPosition(FRotatePosCombo.ItemIndex);
  GMMap.Options.StreetViewControl := FStreetViewCtrlChk.IsChecked;
  GMMap.Options.StreetViewControlOptions.Position := TGMControlPosition(FStreetViewPosCombo.ItemIndex);
  GMMap.Options.FullscreenControl := FFullscreenCtrlChk.IsChecked;
  GMMap.Options.FullscreenControlOptions.Position := TGMControlPosition(FFullscreenPosCombo.ItemIndex);
  GMMap.Options.CameraControl := FCameraCtrlChk.IsChecked;
  GMMap.Options.CameraControlOptions.Position := TGMControlPosition(FCameraPosCombo.ItemIndex);
  GMMap.Options.Zoom := StrToIntDef(eZoom.Text, 12);
  GMMap.Options.Center.Lat := StrToFloatDef(eLat.Text, 41.3874, TFormatSettings.Invariant);
  GMMap.Options.Center.Lng := StrToFloatDef(eLng.Text, 2.1686, TFormatSettings.Invariant);
  Log('Options applied');
end;

{ ========== GM Activation ========== }

procedure TMainFrm.ActivateBtnClick(Sender: TObject);
begin
  GMMap.APIKey := Trim(eAPIKey.Text);
  GMMap.Options.MapId := Trim(eMapId.Text);
  if not Checks then Exit;
  ApplyOptions;
  if not GMMap.Active then
  begin
    if OSMMap.Active then
    begin
      OSMMap.Active := False;
      bActivateOSM.Text := 'Activate';
      Log('OSM map deactivated (Google map activation).');
    end;

    GMMap.Browser := EdgeBrowser1;
    GMMap.Active := True;
    Log('Map activation requested.');
    if GMMap.APIKey = '' then
      Log('Loading Google Maps API without API key.')
    else
      Log('Loading Google Maps API with API key.');
    bActivate.Text := 'Deactivate';
    UpdateStatus('Loading GMMap...');
  end
  else
  begin
    GMMap.Active := False;
    GMMap.Browser := nil;
    EdgeBrowser1.Navigate('about:blank');
    bActivate.Text := 'Activate';
    Log('GMMap is inactive.');
    UpdateStatus('Map inactive...');
  end;
end;

procedure TMainFrm.ApplyOptionsBtnClick(Sender: TObject);
begin
  ApplyOptions;
  Log('Options applied via button');
end;

{ ========== GM Map Events ========== }

procedure TMainFrm.GMMapMapReady(Sender: TObject);
var
  I: Integer;
  Marker: TGMFmxMarkerItem;
  Polyline: TGMFmxPolylineItem;
  Polygon: TGMFmxPolygonItem;
  Rectangle: TGMFmxRectangleItem;
  Circle: TGMFmxCircleItem;
begin
  Log('GMMap is ready');
  UpdateStatus('GMMap ready');
  EdgeBrowser1.Visible := True;

  GMMap.GeoCode.OnCompleted := GeoCodeCompleted;
  GMMap.Elevations.OnCompleted := ElevationCompleted;
  GMMap.Routes.OnCompleted := RouteCompleted;
  GMMap.Routes.CloseOthersBeforeVisible := cbRouteCloseOthers.IsChecked;

  for I := 0 to GMMap.Markers.Count - 1 do
  begin
    Marker := GMMap.Markers[I];
    BindMarkerEvents(Marker);
  end;

  for I := 0 to GMMap.Polylines.Count - 1 do
  begin
    Polyline := GMMap.Polylines[I];
    BindPolylineEvents(Polyline);
  end;

  for I := 0 to GMMap.Polygons.Count - 1 do
  begin
    Polygon := GMMap.Polygons[I];
    BindPolygonEvents(Polygon);
  end;

  for I := 0 to GMMap.Rectangles.Count - 1 do
  begin
    Rectangle := GMMap.Rectangles[I];
    BindRectangleEvents(Rectangle);
  end;

  for I := 0 to GMMap.Circles.Count - 1 do
  begin
    Circle := GMMap.Circles[I];
    BindCircleEvents(Circle);
  end;

  for I := 0 to GMMap.GroundOverlays.Count - 1 do
    BindGroundOverlayEvents(GMMap.GroundOverlays[I]);

  RefreshMarkerList;
  RefreshPolylineList;
  RefreshPolygonList;
  RefreshRectangleList;
  RefreshCircleList;
  RefreshGroundOverlayList;
end;

procedure TMainFrm.GMMapMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
var
  Marker: TGMFmxMarkerItem;
begin
  Log(Format('Map click: %.6f, %.6f PlaceId=%s', [ALatLng.Lat, ALatLng.Lng, APlaceId]));
  UpdateStatus(Format('Clicked: %.4f, %.4f', [ALatLng.Lat, ALatLng.Lng]));

  Marker := GMMap.Markers.Add;
  Marker.Options.Position.Lat := ALatLng.Lat;
  Marker.Options.Position.Lng := ALatLng.Lng;
  Marker.Options.Title := 'Marker ' + IntToStr(GMMap.Markers.Count);
  BindMarkerEvents(Marker);
  RefreshMarkerList;
  FMarkerList.ItemIndex := FMarkerList.Items.IndexOfObject(Marker);
  LoadMarkerToUI(Marker);
end;

procedure TMainFrm.GMMapMapDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Map double click: %.6f, %.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.GMMapMapDragEnd(Sender: TObject);
begin
  Log('Map drag ended');
  UpdateStatus(Format('Center: %.4f, %.4f', [GMMap.Options.Center.Lat, GMMap.Options.Center.Lng]));
end;

procedure TMainFrm.GMMapMapZoomChanged(Sender: TObject; AZoom: Integer);
begin
  Log(Format('Zoom changed: %d', [AZoom]));
  UpdateStatus(Format('Zoom: %d', [AZoom]));
end;

procedure TMainFrm.GMMapMapBoundsChanged(Sender: TObject; ABounds: TGMLatLngBounds);
begin
  Log(Format('Bounds: N=%.4f S=%.4f E=%.4f W=%.4f',
    [ABounds.North, ABounds.South, ABounds.East, ABounds.West]));
end;

procedure TMainFrm.GMMapMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  // Optional: status update on mouse move
end;

procedure TMainFrm.GMMapIdle(Sender: TObject);
begin
  Log('Map idle');
end;

{ ========== GM MARKERS ========== }

procedure TMainFrm.BindMarkerEvents(AMarker: TGMFmxMarkerItem);
begin
  AMarker.OnClick := MapMarkerClick;
  AMarker.OnDragStart := MapMarkersDragStart;
  AMarker.OnDrag := MapMarkersDrag;
  AMarker.OnDragEnd := MapMarkersDragEnd;
end;

procedure TMainFrm.LoadMarkerToUI(AMarker: TGMFmxMarkerItem);
begin
  if not Assigned(AMarker) then Exit;
  FMarkerLatEd.Text := Format('%.6f', [AMarker.Options.Position.Lat]);
  FMarkerLngEd.Text := Format('%.6f', [AMarker.Options.Position.Lng]);
  FMarkerTitleEd.Text := AMarker.Options.Title;
  FMarkerDraggChk.IsChecked := AMarker.Options.Draggable;
  FMarkerVisChk.IsChecked := AMarker.Options.Visible;
  FMarkerClickChk.IsChecked := AMarker.Options.Clickable;
  FMarkerContentModeCombo.ItemIndex := Ord(AMarker.Options.ContentMode);
  FMarkerCollisionCombo.ItemIndex := Ord(AMarker.Options.CollisionBehavior);
  FMarkerLabelTextEd.Text := AMarker.Options.LabelOptions.Text;
  FMarkerLabelFontSizeEd.Text := IntToStr(AMarker.Options.LabelOptions.FontSize);
  FMarkerLabelCornerEd.Text := IntToStr(AMarker.Options.LabelOptions.CornerRadius);
  FMarkerLabelPadHEd.Text := IntToStr(AMarker.Options.LabelOptions.PaddingHorizontal);
  FMarkerLabelPadVEd.Text := IntToStr(AMarker.Options.LabelOptions.PaddingVertical);
  FMarkerLabelFontBoldChk.IsChecked := AMarker.Options.LabelOptions.FontBold;
  FMarkerHtmlMemo.Text := AMarker.Options.HtmlOptions.Html;
end;

procedure TMainFrm.RefreshMarkerList;
var
  I: Integer;
  Marker: TGMFmxMarkerItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if FMarkerList.ItemIndex >= 0 then
    SelectedObject := FMarkerList.Items.Objects[FMarkerList.ItemIndex];
  FMarkerList.Items.BeginUpdate;
  try
    FMarkerList.Clear;
    for I := 0 to GMMap.Markers.Count - 1 do
    begin
      Marker := GMMap.Markers[I];
      FMarkerList.Items.AddObject(
        IfThen(Marker.Options.Title <> '', Marker.Options.Title, Format('Marker %d', [I])),
        Marker);
    end;
  finally
    FMarkerList.Items.EndUpdate;
  end;
  if Assigned(SelectedObject) then
    FMarkerList.ItemIndex := FMarkerList.Items.IndexOfObject(SelectedObject)
  else if FMarkerList.Items.Count > 0 then
    FMarkerList.ItemIndex := 0;
end;

procedure TMainFrm.MarkerAddClick(Sender: TObject);
var
  Marker: TGMFmxMarkerItem;
  Lat, Lng: Double;
begin
  Lat := StrToFloatDef(Trim(FMarkerLatEd.Text), 41.3874, TFormatSettings.Invariant);
  Lng := StrToFloatDef(Trim(FMarkerLngEd.Text), 2.1686, TFormatSettings.Invariant);
  Marker := GMMap.Markers.Add;
  Marker.Options.Position.Lat := Lat;
  Marker.Options.Position.Lng := Lng;
  Marker.Options.Title := FMarkerTitleEd.Text;
  Marker.Options.Visible := FMarkerVisChk.IsChecked;
  Marker.Options.Clickable := FMarkerClickChk.IsChecked;
  Marker.Options.Draggable := FMarkerDraggChk.IsChecked;
  BindMarkerEvents(Marker);
  RefreshMarkerList;
  FMarkerList.ItemIndex := FMarkerList.Items.IndexOfObject(Marker);
  Log('Marker added: ' + Marker.Options.Title);
end;

procedure TMainFrm.MarkerDeleteClick(Sender: TObject);
var
  Marker: TGMFmxMarkerItem;
  Idx: Integer;
begin
  Idx := FMarkerList.ItemIndex;
  if Idx < 0 then Exit;
  Marker := TGMFmxMarkerItem(FMarkerList.Items.Objects[Idx]);
  if Assigned(Marker) then GMMap.Markers.Delete(Marker.Index);
  RefreshMarkerList;
  Log('Marker deleted');
end;

procedure TMainFrm.MarkerClearClick(Sender: TObject);
begin
  GMMap.Markers.Clear;
  RefreshMarkerList;
  Log('All markers cleared');
end;

procedure TMainFrm.MarkerUpdateClick(Sender: TObject);
var
  Marker: TGMFmxMarkerItem;
  Idx: Integer;
  Lat, Lng: Double;
begin
  Idx := FMarkerList.ItemIndex;
  if Idx < 0 then
  begin
    Log('No marker selected');
    Exit;
  end;
  Marker := TGMFmxMarkerItem(FMarkerList.Items.Objects[Idx]);
  if Assigned(Marker) then
  begin
    Marker.Options.BeginUpdate;
    try
      if TryStrToFloat(Trim(FMarkerLatEd.Text), Lat, TFormatSettings.Invariant) then
        Marker.Options.Position.Lat := Lat;
      if TryStrToFloat(Trim(FMarkerLngEd.Text), Lng, TFormatSettings.Invariant) then
        Marker.Options.Position.Lng := Lng;
      Marker.Options.Title := FMarkerTitleEd.Text;
      Marker.Options.Visible := FMarkerVisChk.IsChecked;
      Marker.Options.Clickable := FMarkerClickChk.IsChecked;
      Marker.Options.Draggable := FMarkerDraggChk.IsChecked;
    finally
      Marker.Options.EndUpdate;
    end;
    RefreshMarkerList;
    FMarkerList.ItemIndex := FMarkerList.Items.IndexOfObject(Marker);
    Log('Marker updated');
  end;
end;

procedure TMainFrm.MarkerListClick(Sender: TObject);
var
  Idx: Integer;
  Marker: TGMFmxMarkerItem;
begin
  Idx := FMarkerList.ItemIndex;
  if Idx < 0 then Exit;
  Marker := TGMFmxMarkerItem(FMarkerList.Items.Objects[Idx]);
  if Assigned(Marker) then
    LoadMarkerToUI(Marker);
end;

procedure TMainFrm.ZoomToMarkerClick(Sender: TObject);
var
  Idx: Integer;
  Marker: TGMFmxMarkerItem;
begin
  Idx := FMarkerList.ItemIndex;
  if Idx < 0 then Exit;
  Marker := TGMFmxMarkerItem(FMarkerList.Items.Objects[Idx]);
  if Assigned(Marker) then
    GMMap.Markers.ZoomToPoints(False, Marker.Index);
end;

procedure TMainFrm.ZoomToMarkersClick(Sender: TObject);
begin
  if GMMap.Markers.Count > 0 then
    GMMap.Markers.ZoomToPoints;
end;

procedure TMainFrm.MapMarkerClick(Sender: TObject);
var
  Marker: TGMFmxMarkerItem;
begin
  if not (Sender is TGMFmxMarkerItem) then Exit;
  Marker := TGMFmxMarkerItem(Sender);
  Log('Marker clicked: ' + Marker.Options.Title);
  ShowMarkerInfoWindow(Marker);
end;

procedure TMainFrm.MapMarkersDragStart(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Marker drag start: %.6f, %.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapMarkersDrag(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  UpdateStatus(Format('Dragging marker: %.4f, %.4f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapMarkersDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);
var
  Marker: TGMFmxMarkerItem;
begin
  if not (Sender is TGMFmxMarkerItem) then Exit;
  Marker := TGMFmxMarkerItem(Sender);
  Log(Format('Marker drag end: %.6f, %.6f', [ALatLng.Lat, ALatLng.Lng]));
  Marker.Options.Position.Lat := ALatLng.Lat;
  Marker.Options.Position.Lng := ALatLng.Lng;
  RefreshMarkerList;
end;

procedure TMainFrm.ShowMarkerInfoWindow(AMarker: TGMFmxMarkerItem);
begin
  if not Assigned(AMarker) then Exit;
  if Assigned(FCurrentInfoWindowForMarker) then
  begin
    FCurrentInfoWindowForMarker.Close;
    FCurrentInfoWindowForMarker := nil;
    FCurrentMarkerForInfoWindow := nil;
  end;
  if AMarker.Options.Title <> '' then
  begin
    FCurrentMarkerForInfoWindow := AMarker;
    FCurrentInfoWindowForMarker := GMMap.InfoWindows.Add;
    FCurrentInfoWindowForMarker.Options.Content :=
      '<div style="font-family:Arial,sans-serif;font-size:12px;"><strong>Loading...</strong></div>';
    FCurrentInfoWindowForMarker.Options.DisableAutoPan := True;
    FCurrentInfoWindowForMarker.Options.Position := AMarker.Options.Position;
    FCurrentInfoWindowForMarker.Open(AMarker);
    FInfoWindowLabel.Text := 'InfoWindow open for: ' + AMarker.Options.Title;
    Log('Requesting reverse geocode for marker: ' + Format('%.6f, %.6f',
      [AMarker.Options.Position.Lat, AMarker.Options.Position.Lng]));
    GMMap.GeoCode.Geocode(AMarker.Options.Position);
  end;
end;

{ ========== POLYLINE ========== }

procedure TMainFrm.BindPolylineEvents(APolyline: TGMFmxPolylineItem);
begin
  APolyline.OnDragStart := MapPolylineDragStart;
  APolyline.OnDrag := MapPolylineDrag;
  APolyline.OnDragEnd := MapPolylineDragEnd;
  APolyline.OnPathChanged := MapPolylinePathChanged;
end;

procedure TMainFrm.RefreshPolylineList;
var
  I: Integer;
  Polyline: TGMFmxPolylineItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if FPolylineList.ItemIndex >= 0 then
    SelectedObject := FPolylineList.Items.Objects[FPolylineList.ItemIndex];
  FPolylineList.Items.BeginUpdate;
  try
    FPolylineList.Clear;
    for I := 0 to GMMap.Polylines.Count - 1 do
    begin
      Polyline := GMMap.Polylines[I];
      FPolylineList.Items.AddObject(Format('Polyline %d', [I]), Polyline);
    end;
  finally
    FPolylineList.Items.EndUpdate;
  end;
  if Assigned(SelectedObject) then
    FPolylineList.ItemIndex := FPolylineList.Items.IndexOfObject(SelectedObject)
  else if FPolylineList.Items.Count > 0 then
    FPolylineList.ItemIndex := 0;
end;

procedure TMainFrm.PolylineAddClick(Sender: TObject);
var
  Polyline: TGMFmxPolylineItem;
begin
  Polyline := GMMap.Polylines.Add;
  Polyline.Options.StrokeColor := GM_COLORS(FPolylineStrokeColorCombo.ItemIndex);
  Polyline.Options.StrokeOpacity := StrToFloatDef(FPolylineStrokeOpacityEd.Text, 1.0, TFormatSettings.Invariant);
  Polyline.Options.StrokeWeight := StrToIntDef(FPolylineStrokeWeightEd.Text, 5);
  Polyline.Options.Clickable := FPolylineClickChk.IsChecked;
  Polyline.Options.Draggable := FPolylineDragChk.IsChecked;
  Polyline.Options.Editable := FPolylineEditChk.IsChecked;
  Polyline.Options.Geodesic := FPolylineGeoChk.IsChecked;
  Polyline.Options.Visible := FPolylineVisChk.IsChecked;
  BindPolylineEvents(Polyline);
  RefreshPolylineList;
  Log('Polyline added');
end;

procedure TMainFrm.PolylineDeleteClick(Sender: TObject);
var
  Polyline: TGMFmxPolylineItem;
  Idx: Integer;
begin
  Idx := FPolylineList.ItemIndex;
  if Idx < 0 then Exit;
  Polyline := TGMFmxPolylineItem(FPolylineList.Items.Objects[Idx]);
  if Assigned(Polyline) then GMMap.Polylines.Delete(Polyline.Index);
  RefreshPolylineList;
  Log('Polyline deleted');
end;

procedure TMainFrm.PolylineClearClick(Sender: TObject);
begin
  GMMap.Polylines.Clear;
  RefreshPolylineList;
  Log('All polylines cleared');
end;

procedure TMainFrm.PolylineUpdateClick(Sender: TObject);
var
  Polyline: TGMFmxPolylineItem;
  Idx: Integer;
begin
  Idx := FPolylineList.ItemIndex;
  if Idx < 0 then
  begin
    Log('No polyline selected');
    Exit;
  end;
  Polyline := TGMFmxPolylineItem(FPolylineList.Items.Objects[Idx]);
  if Assigned(Polyline) then
  begin
    Polyline.Options.StrokeColor := GM_COLORS(FPolylineStrokeColorCombo.ItemIndex);
    Polyline.Options.StrokeOpacity := StrToFloatDef(FPolylineStrokeOpacityEd.Text, 1.0, TFormatSettings.Invariant);
    Polyline.Options.StrokeWeight := StrToIntDef(FPolylineStrokeWeightEd.Text, 5);
    Polyline.Options.Clickable := FPolylineClickChk.IsChecked;
    Polyline.Options.Draggable := FPolylineDragChk.IsChecked;
    Polyline.Options.Editable := FPolylineEditChk.IsChecked;
    Polyline.Options.Geodesic := FPolylineGeoChk.IsChecked;
    Polyline.Options.Visible := FPolylineVisChk.IsChecked;
    RefreshPolylineList;
    Log('Polyline updated');
  end;
end;

procedure TMainFrm.PolylineListClick(Sender: TObject);
var
  Idx: Integer;
  Polyline: TGMFmxPolylineItem;
begin
  Idx := FPolylineList.ItemIndex;
  if Idx < 0 then Exit;
  Polyline := TGMFmxPolylineItem(FPolylineList.Items.Objects[Idx]);
  if Assigned(Polyline) then
  begin
    FPolylineStrokeColorCombo.ItemIndex := FPolylineStrokeColorCombo.Items.IndexOf(
      IntToStr(Polyline.Options.StrokeColor));
    FPolylineStrokeOpacityEd.Text := Format('%.2f', [Polyline.Options.StrokeOpacity]);
    FPolylineStrokeWeightEd.Text := IntToStr(Polyline.Options.StrokeWeight);
    FPolylineClickChk.IsChecked := Polyline.Options.Clickable;
    FPolylineDragChk.IsChecked := Polyline.Options.Draggable;
    FPolylineEditChk.IsChecked := Polyline.Options.Editable;
    FPolylineGeoChk.IsChecked := Polyline.Options.Geodesic;
    FPolylineVisChk.IsChecked := Polyline.Options.Visible;
  end;
end;

procedure TMainFrm.ZoomToPolylineClick(Sender: TObject);
var
  Idx: Integer;
  Polyline: TGMFmxPolylineItem;
begin
  Idx := FPolylineList.ItemIndex;
  if Idx < 0 then Exit;
  Polyline := TGMFmxPolylineItem(FPolylineList.Items.Objects[Idx]);
  if Assigned(Polyline) and (Polyline.Options.Path.Count > 0) then
    GMMap.Polylines.ZoomToPoints(False, Polyline.Index);
end;

procedure TMainFrm.ZoomToPolylinesClick(Sender: TObject);
begin
  if GMMap.Polylines.Count > 0 then
    GMMap.Polylines.ZoomToPoints;
end;

procedure TMainFrm.MapPolylineDragStart(Sender: TObject);
begin
  FIsDraggingPolyline := True;
  Log('Polyline drag start');
end;

procedure TMainFrm.MapPolylineDrag(Sender: TObject);
begin
  UpdateStatus('Dragging polyline...');
end;

procedure TMainFrm.MapPolylineDragEnd(Sender: TObject);
begin
  FIsDraggingPolyline := False;
  Log('Polyline drag end');
end;

procedure TMainFrm.MapPolylinePathChanged(Sender: TObject);
begin
  Log('Polyline path changed');
end;

{ ========== POLYGON ========== }

procedure TMainFrm.BindPolygonEvents(APolygon: TGMFmxPolygonItem);
begin
  APolygon.OnDragStart := MapPolygonDragStart;
  APolygon.OnDrag := MapPolygonDrag;
  APolygon.OnDragEnd := MapPolygonDragEnd;
  APolygon.OnPathChanged := MapPolygonPathChanged;
end;

procedure TMainFrm.RefreshPolygonList;
var
  I: Integer;
  Polygon: TGMFmxPolygonItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if FPolygonList.ItemIndex >= 0 then
    SelectedObject := FPolygonList.Items.Objects[FPolygonList.ItemIndex];
  FPolygonList.Items.BeginUpdate;
  try
    FPolygonList.Clear;
    for I := 0 to GMMap.Polygons.Count - 1 do
    begin
      Polygon := GMMap.Polygons[I];
      FPolygonList.Items.AddObject(Format('Polygon %d', [I]), Polygon);
    end;
  finally
    FPolygonList.Items.EndUpdate;
  end;
  if Assigned(SelectedObject) then
    FPolygonList.ItemIndex := FPolygonList.Items.IndexOfObject(SelectedObject)
  else if FPolygonList.Items.Count > 0 then
    FPolygonList.ItemIndex := 0;
end;

procedure TMainFrm.PolygonAddClick(Sender: TObject);
var
  Polygon: TGMFmxPolygonItem;
begin
  Polygon := GMMap.Polygons.Add;
  Polygon.Options.StrokeColor := GM_COLORS(FPolygonStrokeColorCombo.ItemIndex);
  Polygon.Options.FillColor := GM_COLORS(FPolygonFillColorCombo.ItemIndex);
  Polygon.Options.StrokeOpacity := StrToFloatDef(FPolygonStrokeOpEd.Text, 1.0, TFormatSettings.Invariant);
  Polygon.Options.StrokeWeight := StrToIntDef(FPolygonStrokeWtEd.Text, 5);
  Polygon.Options.FillOpacity := StrToFloatDef(FPolygonFillOpEd.Text, 0.5, TFormatSettings.Invariant);
  Polygon.Options.Clickable := FPolygonClickChk.IsChecked;
  Polygon.Options.Draggable := FPolygonDragChk.IsChecked;
  Polygon.Options.Editable := FPolygonEditChk.IsChecked;
  Polygon.Options.Geodesic := FPolygonGeoChk.IsChecked;
  Polygon.Options.Visible := FPolygonVisChk.IsChecked;
  BindPolygonEvents(Polygon);
  RefreshPolygonList;
  Log('Polygon added');
end;

procedure TMainFrm.PolygonDeleteClick(Sender: TObject);
var
  Polygon: TGMFmxPolygonItem;
  Idx: Integer;
begin
  Idx := FPolygonList.ItemIndex;
  if Idx < 0 then Exit;
  Polygon := TGMFmxPolygonItem(FPolygonList.Items.Objects[Idx]);
  if Assigned(Polygon) then GMMap.Polygons.Delete(Polygon.Index);
  RefreshPolygonList;
  Log('Polygon deleted');
end;

procedure TMainFrm.PolygonClearClick(Sender: TObject);
begin
  GMMap.Polygons.Clear;
  RefreshPolygonList;
  Log('All polygons cleared');
end;

procedure TMainFrm.PolygonUpdateClick(Sender: TObject);
var
  Polygon: TGMFmxPolygonItem;
  Idx: Integer;
begin
  Idx := FPolygonList.ItemIndex;
  if Idx < 0 then
  begin
    Log('No polygon selected');
    Exit;
  end;
  Polygon := TGMFmxPolygonItem(FPolygonList.Items.Objects[Idx]);
  if Assigned(Polygon) then
  begin
    Polygon.Options.StrokeColor := GM_COLORS(FPolygonStrokeColorCombo.ItemIndex);
    Polygon.Options.FillColor := GM_COLORS(FPolygonFillColorCombo.ItemIndex);
    Polygon.Options.StrokeOpacity := StrToFloatDef(FPolygonStrokeOpEd.Text, 1.0, TFormatSettings.Invariant);
    Polygon.Options.StrokeWeight := StrToIntDef(FPolygonStrokeWtEd.Text, 5);
    Polygon.Options.FillOpacity := StrToFloatDef(FPolygonFillOpEd.Text, 0.5, TFormatSettings.Invariant);
    Polygon.Options.Clickable := FPolygonClickChk.IsChecked;
    Polygon.Options.Draggable := FPolygonDragChk.IsChecked;
    Polygon.Options.Editable := FPolygonEditChk.IsChecked;
    Polygon.Options.Geodesic := FPolygonGeoChk.IsChecked;
    Polygon.Options.Visible := FPolygonVisChk.IsChecked;
    RefreshPolygonList;
    Log('Polygon updated');
  end;
end;

procedure TMainFrm.PolygonListClick(Sender: TObject);
var
  Idx: Integer;
  Polygon: TGMFmxPolygonItem;
begin
  Idx := FPolygonList.ItemIndex;
  if Idx < 0 then Exit;
  Polygon := TGMFmxPolygonItem(FPolygonList.Items.Objects[Idx]);
  if Assigned(Polygon) then
  begin
    FPolygonStrokeColorCombo.ItemIndex := 0;
    FPolygonFillColorCombo.ItemIndex := 0;
    FPolygonStrokeOpEd.Text := Format('%.2f', [Polygon.Options.StrokeOpacity]);
    FPolygonStrokeWtEd.Text := IntToStr(Polygon.Options.StrokeWeight);
    FPolygonFillOpEd.Text := Format('%.2f', [Polygon.Options.FillOpacity]);
    FPolygonClickChk.IsChecked := Polygon.Options.Clickable;
    FPolygonDragChk.IsChecked := Polygon.Options.Draggable;
    FPolygonEditChk.IsChecked := Polygon.Options.Editable;
    FPolygonGeoChk.IsChecked := Polygon.Options.Geodesic;
    FPolygonVisChk.IsChecked := Polygon.Options.Visible;
  end;
end;

procedure TMainFrm.ZoomToPolygonClick(Sender: TObject);
var
  Idx: Integer;
  Polygon: TGMFmxPolygonItem;
begin
  Idx := FPolygonList.ItemIndex;
  if Idx < 0 then Exit;
  Polygon := TGMFmxPolygonItem(FPolygonList.Items.Objects[Idx]);
  if Assigned(Polygon) and (Polygon.Options.Path.Count > 0) then
    GMMap.Polygons.ZoomToPoints(False, Idx);
end;

procedure TMainFrm.ZoomToPolygonsClick(Sender: TObject);
begin
  if GMMap.Polygons.Count > 0 then
    GMMap.Polygons.ZoomToPoints;
end;

procedure TMainFrm.MapPolygonDragStart(Sender: TObject);
begin
  FIsDraggingPolygon := True;
  Log('Polygon drag start');
end;

procedure TMainFrm.MapPolygonDrag(Sender: TObject);
begin
  UpdateStatus('Dragging polygon...');
end;

procedure TMainFrm.MapPolygonDragEnd(Sender: TObject);
begin
  FIsDraggingPolygon := False;
  Log('Polygon drag end');
end;

procedure TMainFrm.MapPolygonPathChanged(Sender: TObject);
begin
  Log('Polygon path changed');
end;

{ ========== RECTANGLE ========== }

procedure TMainFrm.BindRectangleEvents(ARectangle: TGMFmxRectangleItem);
begin
  ARectangle.OnDragStart := MapRectangleDragStart;
  ARectangle.OnDrag := MapRectangleDrag;
  ARectangle.OnDragEnd := MapRectangleDragEnd;
  ARectangle.OnBoundsChanged := MapRectangleBoundsChanged;
end;

procedure TMainFrm.RefreshRectangleList;
var
  I: Integer;
  Rect: TGMFmxRectangleItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if FRectList.ItemIndex >= 0 then
    SelectedObject := FRectList.Items.Objects[FRectList.ItemIndex];
  FRectList.Items.BeginUpdate;
  try
    FRectList.Clear;
    for I := 0 to GMMap.Rectangles.Count - 1 do
    begin
      Rect := GMMap.Rectangles[I];
      FRectList.Items.AddObject(Format('Rectangle %d', [I]), Rect);
    end;
  finally
    FRectList.Items.EndUpdate;
  end;
  if Assigned(SelectedObject) then
    FRectList.ItemIndex := FRectList.Items.IndexOfObject(SelectedObject)
  else if FRectList.Items.Count > 0 then
    FRectList.ItemIndex := 0;
end;

procedure TMainFrm.RectAddClick(Sender: TObject);
var
  Rect: TGMFmxRectangleItem;
  north, south, east, west: Double;
begin
  Rect := GMMap.Rectangles.Add;
  if TryStrToFloat(Trim(FRectNorthEd.Text), north, TFormatSettings.Invariant) then
    Rect.Options.Bounds.North := north;
  if TryStrToFloat(Trim(FRectSouthEd.Text), south, TFormatSettings.Invariant) then
    Rect.Options.Bounds.South := south;
  if TryStrToFloat(Trim(FRectEastEd.Text), east, TFormatSettings.Invariant) then
    Rect.Options.Bounds.East := east;
  if TryStrToFloat(Trim(FRectWestEd.Text), west, TFormatSettings.Invariant) then
    Rect.Options.Bounds.West := west;
  Rect.Options.StrokeColor := GM_COLORS(FRectStrokeColorCombo.ItemIndex);
  Rect.Options.FillColor := GM_COLORS(FRectFillColorCombo.ItemIndex);
  Rect.Options.StrokeOpacity := StrToFloatDef(FRectStrokeOpEd.Text, 1.0, TFormatSettings.Invariant);
  Rect.Options.StrokeWeight := StrToIntDef(FRectStrokeWtEd.Text, 5);
  Rect.Options.FillOpacity := StrToFloatDef(FRectFillOpEd.Text, 0.5, TFormatSettings.Invariant);
  Rect.Options.Clickable := FRectClickChk.IsChecked;
  Rect.Options.Draggable := FRectDragChk.IsChecked;
  Rect.Options.Editable := FRectEditChk.IsChecked;
  Rect.Options.Visible := FRectVisChk.IsChecked;
  BindRectangleEvents(Rect);
  RefreshRectangleList;
  Log('Rectangle added');
end;

procedure TMainFrm.RectDeleteClick(Sender: TObject);
var
  Rect: TGMFmxRectangleItem;
  Idx: Integer;
begin
  Idx := FRectList.ItemIndex;
  if Idx < 0 then Exit;
  Rect := TGMFmxRectangleItem(FRectList.Items.Objects[Idx]);
  if Assigned(Rect) then GMMap.Rectangles.Delete(Rect.Index);
  RefreshRectangleList;
  Log('Rectangle deleted');
end;

procedure TMainFrm.RectClearClick(Sender: TObject);
begin
  GMMap.Rectangles.Clear;
  RefreshRectangleList;
  Log('All rectangles cleared');
end;

procedure TMainFrm.RectUpdateClick(Sender: TObject);
var
  Rect: TGMFmxRectangleItem;
  Idx: Integer;
  north, south, east, west: Double;
begin
  Idx := FRectList.ItemIndex;
  if Idx < 0 then
  begin
    Log('No rectangle selected');
    Exit;
  end;
  Rect := TGMFmxRectangleItem(FRectList.Items.Objects[Idx]);
  if Assigned(Rect) then
  begin
    if TryStrToFloat(Trim(FRectNorthEd.Text), north, TFormatSettings.Invariant) then
      Rect.Options.Bounds.North := north;
    if TryStrToFloat(Trim(FRectSouthEd.Text), south, TFormatSettings.Invariant) then
      Rect.Options.Bounds.South := south;
    if TryStrToFloat(Trim(FRectEastEd.Text), east, TFormatSettings.Invariant) then
      Rect.Options.Bounds.East := east;
    if TryStrToFloat(Trim(FRectWestEd.Text), west, TFormatSettings.Invariant) then
      Rect.Options.Bounds.West := west;
    Rect.Options.StrokeColor := GM_COLORS(FRectStrokeColorCombo.ItemIndex);
    Rect.Options.FillColor := GM_COLORS(FRectFillColorCombo.ItemIndex);
    Rect.Options.StrokeOpacity := StrToFloatDef(FRectStrokeOpEd.Text, 1.0, TFormatSettings.Invariant);
    Rect.Options.StrokeWeight := StrToIntDef(FRectStrokeWtEd.Text, 5);
    Rect.Options.FillOpacity := StrToFloatDef(FRectFillOpEd.Text, 0.5, TFormatSettings.Invariant);
    Rect.Options.Clickable := FRectClickChk.IsChecked;
    Rect.Options.Draggable := FRectDragChk.IsChecked;
    Rect.Options.Editable := FRectEditChk.IsChecked;
    Rect.Options.Visible := FRectVisChk.IsChecked;
    RefreshRectangleList;
    Log('Rectangle updated');
  end;
end;

procedure TMainFrm.RectListClick(Sender: TObject);
var
  Idx: Integer;
  Rect: TGMFmxRectangleItem;
begin
  Idx := FRectList.ItemIndex;
  if Idx < 0 then Exit;
  Rect := TGMFmxRectangleItem(FRectList.Items.Objects[Idx]);
  if Assigned(Rect) then
  begin
    FRectNorthEd.Text := Format('%.6f', [Rect.Options.Bounds.North]);
    FRectSouthEd.Text := Format('%.6f', [Rect.Options.Bounds.South]);
    FRectEastEd.Text := Format('%.6f', [Rect.Options.Bounds.East]);
    FRectWestEd.Text := Format('%.6f', [Rect.Options.Bounds.West]);
    FRectStrokeColorCombo.ItemIndex := 0;
    FRectFillColorCombo.ItemIndex := 0;
    FRectStrokeOpEd.Text := Format('%.2f', [Rect.Options.StrokeOpacity]);
    FRectStrokeWtEd.Text := IntToStr(Rect.Options.StrokeWeight);
    FRectFillOpEd.Text := Format('%.2f', [Rect.Options.FillOpacity]);
    FRectClickChk.IsChecked := Rect.Options.Clickable;
    FRectDragChk.IsChecked := Rect.Options.Draggable;
    FRectEditChk.IsChecked := Rect.Options.Editable;
    FRectVisChk.IsChecked := Rect.Options.Visible;
  end;
end;

procedure TMainFrm.ZoomToRectClick(Sender: TObject);
var
  Idx: Integer;
  Rect: TGMFmxRectangleItem;
begin
  Idx := FRectList.ItemIndex;
  if Idx < 0 then Exit;
  Rect := TGMFmxRectangleItem(FRectList.Items.Objects[Idx]);
  if Assigned(Rect) then
    GMMap.Rectangles.ZoomToPoints(False, Idx);
end;

procedure TMainFrm.ZoomToRectsClick(Sender: TObject);
begin
  if GMMap.Rectangles.Count > 0 then
    GMMap.Rectangles.ZoomToPoints;
end;

procedure TMainFrm.MapRectangleDragStart(Sender: TObject);
begin
  FIsDraggingRectangle := True;
  Log('Rectangle drag start');
end;

procedure TMainFrm.MapRectangleDrag(Sender: TObject);
begin
  UpdateStatus('Dragging rectangle...');
end;

procedure TMainFrm.MapRectangleDragEnd(Sender: TObject);
begin
  FIsDraggingRectangle := False;
  Log('Rectangle drag end');
end;

procedure TMainFrm.MapRectangleBoundsChanged(Sender: TObject);
begin
  Log('Rectangle bounds changed');
end;

{ ========== CIRCLE ========== }

procedure TMainFrm.BindCircleEvents(ACircle: TGMFmxCircleItem);
begin
  ACircle.OnDragStart := MapCircleDragStart;
  ACircle.OnDrag := MapCircleDrag;
  ACircle.OnDragEnd := MapCircleDragEnd;
  ACircle.OnCenterChanged := MapCircleCenterChanged;
  ACircle.OnRadiusChanged := MapCircleRadiusChanged;
end;

procedure TMainFrm.RefreshCircleList;
var
  I: Integer;
  Circle: TGMFmxCircleItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if FCircleList.ItemIndex >= 0 then
    SelectedObject := FCircleList.Items.Objects[FCircleList.ItemIndex];
  FCircleList.Items.BeginUpdate;
  try
    FCircleList.Clear;
    for I := 0 to GMMap.Circles.Count - 1 do
    begin
      Circle := GMMap.Circles[I];
      FCircleList.Items.AddObject(Format('Circle %d', [I]), Circle);
    end;
  finally
    FCircleList.Items.EndUpdate;
  end;
  if Assigned(SelectedObject) then
    FCircleList.ItemIndex := FCircleList.Items.IndexOfObject(SelectedObject)
  else if FCircleList.Items.Count > 0 then
    FCircleList.ItemIndex := 0;
end;

procedure TMainFrm.CircleAddClick(Sender: TObject);
var
  Circle: TGMFmxCircleItem;
  lat, lng, radius: Double;
begin
  Circle := GMMap.Circles.Add;
  if TryStrToFloat(Trim(FCircleLatEd.Text), lat, TFormatSettings.Invariant) then
    Circle.Options.Center.Lat := lat;
  if TryStrToFloat(Trim(FCircleLngEd.Text), lng, TFormatSettings.Invariant) then
    Circle.Options.Center.Lng := lng;
  radius := StrToFloatDef(Trim(FRadiusEd.Text), 1000, TFormatSettings.Invariant);
  Circle.Options.Radius := radius;
  Circle.Options.StrokeColor := GM_COLORS(FCircleStrokeColorCombo.ItemIndex);
  Circle.Options.FillColor := GM_COLORS(FCircleFillColorCombo.ItemIndex);
  Circle.Options.StrokeOpacity := StrToFloatDef(FCircleStrokeOpEd.Text, 1.0, TFormatSettings.Invariant);
  Circle.Options.StrokeWeight := StrToIntDef(FCircleStrokeWtEd.Text, 5);
  Circle.Options.FillOpacity := StrToFloatDef(FCircleFillOpEd.Text, 0.5, TFormatSettings.Invariant);
  Circle.Options.Clickable := FCircleClickChk.IsChecked;
  Circle.Options.Draggable := FCircleDragChk.IsChecked;
  Circle.Options.Editable := FCircleEditChk.IsChecked;
  Circle.Options.Visible := FCircleVisChk.IsChecked;
  BindCircleEvents(Circle);
  RefreshCircleList;
  Log('Circle added');
end;

procedure TMainFrm.CircleDeleteClick(Sender: TObject);
var
  Circle: TGMFmxCircleItem;
  Idx: Integer;
begin
  Idx := FCircleList.ItemIndex;
  if Idx < 0 then Exit;
  Circle := TGMFmxCircleItem(FCircleList.Items.Objects[Idx]);
  if Assigned(Circle) then GMMap.Circles.Delete(Circle.Index);
  RefreshCircleList;
  Log('Circle deleted');
end;

procedure TMainFrm.CircleClearClick(Sender: TObject);
begin
  GMMap.Circles.Clear;
  RefreshCircleList;
  Log('All circles cleared');
end;

procedure TMainFrm.CircleUpdateClick(Sender: TObject);
var
  Circle: TGMFmxCircleItem;
  Idx: Integer;
  lat, lng, radius: Double;
begin
  Idx := FCircleList.ItemIndex;
  if Idx < 0 then
  begin
    Log('No circle selected');
    Exit;
  end;
  Circle := TGMFmxCircleItem(FCircleList.Items.Objects[Idx]);
  if Assigned(Circle) then
  begin
    if TryStrToFloat(Trim(FCircleLatEd.Text), lat, TFormatSettings.Invariant) then
      Circle.Options.Center.Lat := lat;
    if TryStrToFloat(Trim(FCircleLngEd.Text), lng, TFormatSettings.Invariant) then
      Circle.Options.Center.Lng := lng;
    radius := StrToFloatDef(Trim(FRadiusEd.Text), Circle.Options.Radius, TFormatSettings.Invariant);
    Circle.Options.Radius := radius;
    Circle.Options.StrokeColor := GM_COLORS(FCircleStrokeColorCombo.ItemIndex);
    Circle.Options.FillColor := GM_COLORS(FCircleFillColorCombo.ItemIndex);
    Circle.Options.StrokeOpacity := StrToFloatDef(FCircleStrokeOpEd.Text, 1.0, TFormatSettings.Invariant);
    Circle.Options.StrokeWeight := StrToIntDef(FCircleStrokeWtEd.Text, 5);
    Circle.Options.FillOpacity := StrToFloatDef(FCircleFillOpEd.Text, 0.5, TFormatSettings.Invariant);
    Circle.Options.Clickable := FCircleClickChk.IsChecked;
    Circle.Options.Draggable := FCircleDragChk.IsChecked;
    Circle.Options.Editable := FCircleEditChk.IsChecked;
    Circle.Options.Visible := FCircleVisChk.IsChecked;
    RefreshCircleList;
    Log('Circle updated');
  end;
end;

procedure TMainFrm.CircleListClick(Sender: TObject);
var
  Idx: Integer;
  Circle: TGMFmxCircleItem;
begin
  Idx := FCircleList.ItemIndex;
  if Idx < 0 then Exit;
  Circle := TGMFmxCircleItem(FCircleList.Items.Objects[Idx]);
  if Assigned(Circle) then
  begin
    FCircleLatEd.Text := Format('%.6f', [Circle.Options.Center.Lat]);
    FCircleLngEd.Text := Format('%.6f', [Circle.Options.Center.Lng]);
    FRadiusEd.Text := Format('%.0f', [Circle.Options.Radius]);
    FCircleStrokeColorCombo.ItemIndex := 0;
    FCircleFillColorCombo.ItemIndex := 0;
    FCircleStrokeOpEd.Text := Format('%.2f', [Circle.Options.StrokeOpacity]);
    FCircleStrokeWtEd.Text := IntToStr(Circle.Options.StrokeWeight);
    FCircleFillOpEd.Text := Format('%.2f', [Circle.Options.FillOpacity]);
    FCircleClickChk.IsChecked := Circle.Options.Clickable;
    FCircleDragChk.IsChecked := Circle.Options.Draggable;
    FCircleEditChk.IsChecked := Circle.Options.Editable;
    FCircleVisChk.IsChecked := Circle.Options.Visible;
  end;
end;

procedure TMainFrm.ZoomToCircleClick(Sender: TObject);
var
  Idx: Integer;
  Circle: TGMFmxCircleItem;
begin
  Idx := FCircleList.ItemIndex;
  if Idx < 0 then Exit;
  Circle := TGMFmxCircleItem(FCircleList.Items.Objects[Idx]);
  if Assigned(Circle) then
    GMMap.Circles.ZoomToPoints(False, Idx);
end;

procedure TMainFrm.ZoomToCirclesClick(Sender: TObject);
begin
  if GMMap.Circles.Count > 0 then
    GMMap.Circles.ZoomToPoints;
end;

procedure TMainFrm.MapCircleDragStart(Sender: TObject);
begin
  FIsDraggingCircle := True;
  Log('Circle drag start');
end;

procedure TMainFrm.MapCircleDrag(Sender: TObject);
begin
  UpdateStatus('Dragging circle...');
end;

procedure TMainFrm.MapCircleDragEnd(Sender: TObject);
begin
  FIsDraggingCircle := False;
  Log('Circle drag end');
end;

procedure TMainFrm.MapCircleCenterChanged(Sender: TObject);
begin
  Log('Circle center changed');
end;

procedure TMainFrm.MapCircleRadiusChanged(Sender: TObject);
begin
  Log('Circle radius changed');
end;

{ ========== GROUND OVERLAY ========== }

procedure TMainFrm.BindGroundOverlayEvents(AGroundOverlay: TGMGroundOverlayItem);
begin
  // GroundOverlay events
end;

procedure TMainFrm.RefreshGroundOverlayList;
var
  I: Integer;
  Item: TGMGroundOverlayItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if FGroundList.ItemIndex >= 0 then
    SelectedObject := FGroundList.Items.Objects[FGroundList.ItemIndex];
  FGroundList.Items.BeginUpdate;
  try
    FGroundList.Clear;
    for I := 0 to GMMap.GroundOverlays.Count - 1 do
    begin
      Item := GMMap.GroundOverlays[I];
      FGroundList.Items.AddObject(Format('GroundOverlay %d', [I]), Item);
    end;
  finally
    FGroundList.Items.EndUpdate;
  end;
  if Assigned(SelectedObject) then
    FGroundList.ItemIndex := FGroundList.Items.IndexOfObject(SelectedObject)
  else if FGroundList.Items.Count > 0 then
    FGroundList.ItemIndex := 0;
end;

procedure TMainFrm.GroundAddClick(Sender: TObject);
var
  Item: TGMGroundOverlayItem;
  north, south, east, west: Double;
begin
  Item := GMMap.GroundOverlays.Add;
  if TryStrToFloat(Trim(FGroundNorthEd.Text), north, TFormatSettings.Invariant) then
    Item.Options.Bounds.North := north;
  if TryStrToFloat(Trim(FGroundSouthEd.Text), south, TFormatSettings.Invariant) then
    Item.Options.Bounds.South := south;
  if TryStrToFloat(Trim(FGroundEastEd.Text), east, TFormatSettings.Invariant) then
    Item.Options.Bounds.East := east;
  if TryStrToFloat(Trim(FGroundWestEd.Text), west, TFormatSettings.Invariant) then
    Item.Options.Bounds.West := west;
  Item.Options.Url := FGroundUrlEd.Text;
  Item.Options.Opacity := StrToFloatDef(FGroundOpacityEd.Text, 1.0, TFormatSettings.Invariant);
  Item.Options.Clickable := FGroundClickableChk.IsChecked;
  Item.Options.Visible := FGroundVisibleChk.IsChecked;
  BindGroundOverlayEvents(Item);
  RefreshGroundOverlayList;
  Log('GroundOverlay added');
end;

procedure TMainFrm.GroundDeleteClick(Sender: TObject);
var
  Item: TGMGroundOverlayItem;
  Idx: Integer;
begin
  Idx := FGroundList.ItemIndex;
  if Idx < 0 then Exit;
  Item := TGMGroundOverlayItem(FGroundList.Items.Objects[Idx]);
  if Assigned(Item) then GMMap.GroundOverlays.Delete(Item.Index);
  RefreshGroundOverlayList;
  Log('GroundOverlay deleted');
end;

procedure TMainFrm.GroundClearClick(Sender: TObject);
begin
  GMMap.GroundOverlays.Clear;
  RefreshGroundOverlayList;
  Log('All ground overlays cleared');
end;

procedure TMainFrm.GroundUpdateClick(Sender: TObject);
var
  Item: TGMGroundOverlayItem;
  Idx: Integer;
  north, south, east, west: Double;
begin
  Idx := FGroundList.ItemIndex;
  if Idx < 0 then
  begin
    Log('No ground overlay selected');
    Exit;
  end;
  Item := TGMGroundOverlayItem(FGroundList.Items.Objects[Idx]);
  if Assigned(Item) then
  begin
    if TryStrToFloat(Trim(FGroundNorthEd.Text), north, TFormatSettings.Invariant) then
      Item.Options.Bounds.North := north;
    if TryStrToFloat(Trim(FGroundSouthEd.Text), south, TFormatSettings.Invariant) then
      Item.Options.Bounds.South := south;
    if TryStrToFloat(Trim(FGroundEastEd.Text), east, TFormatSettings.Invariant) then
      Item.Options.Bounds.East := east;
    if TryStrToFloat(Trim(FGroundWestEd.Text), west, TFormatSettings.Invariant) then
      Item.Options.Bounds.West := west;
    Item.Options.Url := FGroundUrlEd.Text;
    Item.Options.Opacity := StrToFloatDef(FGroundOpacityEd.Text, 1.0, TFormatSettings.Invariant);
    Item.Options.Clickable := FGroundClickableChk.IsChecked;
    Item.Options.Visible := FGroundVisibleChk.IsChecked;
    RefreshGroundOverlayList;
    Log('GroundOverlay updated');
  end;
end;

procedure TMainFrm.GroundZoomClick(Sender: TObject);
var
  Item: TGMGroundOverlayItem;
  Idx: Integer;
begin
  Idx := FGroundList.ItemIndex;
  if Idx < 0 then Exit;
  Item := TGMGroundOverlayItem(FGroundList.Items.Objects[Idx]);
  if Assigned(Item) then
    GMMap.GroundOverlays.ZoomToPoints(False, Idx);
end;

procedure TMainFrm.GroundZoomAllClick(Sender: TObject);
begin
  if GMMap.GroundOverlays.Count > 0 then
    GMMap.GroundOverlays.ZoomToPoints;
end;

procedure TMainFrm.GroundListClick(Sender: TObject);
var
  Idx: Integer;
  Item: TGMGroundOverlayItem;
begin
  Idx := FGroundList.ItemIndex;
  if Idx < 0 then Exit;
  Item := TGMGroundOverlayItem(FGroundList.Items.Objects[Idx]);
  if Assigned(Item) then
  begin
    FGroundUrlEd.Text := Item.Options.Url;
    FGroundNorthEd.Text := Format('%.6f', [Item.Options.Bounds.North]);
    FGroundSouthEd.Text := Format('%.6f', [Item.Options.Bounds.South]);
    FGroundEastEd.Text := Format('%.6f', [Item.Options.Bounds.East]);
    FGroundWestEd.Text := Format('%.6f', [Item.Options.Bounds.West]);
    FGroundOpacityEd.Text := Format('%.2f', [Item.Options.Opacity]);
    FGroundClickableChk.IsChecked := Item.Options.Clickable;
    FGroundVisibleChk.IsChecked := Item.Options.Visible;
  end;
end;

{ ========== LAYERS ========== }

procedure TMainFrm.ApplyLayersClick(Sender: TObject);
begin
  ApplyLayers;
end;

procedure TMainFrm.ApplyLayers;
begin
  GMMap.Layers.Traffic.Visible := FTrafficVisChk.IsChecked;
  GMMap.Layers.Traffic.AutoRefresh := FTrafficAutoChk.IsChecked;
  GMMap.Layers.Transit.Visible := FTransitVisChk.IsChecked;
  GMMap.Layers.Bicycling.Visible := FBicyclingVisChk.IsChecked;
  Log('Layers applied');
end;

{ ========== INFO WINDOW ========== }

{ ========== GEOCODE ========== }

procedure TMainFrm.GeoCodeCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
var
  Lat, Lng: Double;
  HTML: string;
  FirstResult: TGMGeocodeResult;
begin
  Log(Format('GeoCode completed. Status: %s, HasResults: %s',
    [AResponse.Status, BoolToStr(AResponse.HasResults, True)]));

  if not Assigned(FCurrentMarkerForInfoWindow) or not Assigned(FCurrentInfoWindowForMarker) then
  begin
    Log('No marker or info window selected');
    Exit;
  end;

  Lat := FCurrentMarkerForInfoWindow.Options.Position.Lat;
  Lng := FCurrentMarkerForInfoWindow.Options.Position.Lng;

  HTML := '<div style="font-family:Arial,sans-serif;font-size:12px;">';
  HTML := HTML + '<strong>Coords:</strong> ' + Format('%.6f, %.6f', [Lat, Lng]) + '<br/>';

  if AResponse.HasResults and AResponse.TryGetFirstResult(FirstResult) then
  begin
    HTML := HTML + '<strong>Address:</strong><br/>' + FirstResult.FormattedAddress + '<br/>';
    HTML := HTML + '<strong>Place ID:</strong> ' + FirstResult.PlaceId + '<br/>';
    HTML := HTML + '<strong>Type:</strong> ' + FirstResult.LocationType + '<br/>';
  end
  else
    HTML := HTML + '<em>No address found</em><br/>';

  HTML := HTML + '<br/><strong>Getting elevation...</strong>';
  HTML := HTML + '</div>';

  FCurrentInfoWindowForMarker.Options.Content := HTML;
  FCurrentInfoWindowForMarker.Options.Position := FCurrentMarkerForInfoWindow.Options.Position;
  FCurrentInfoWindowForMarker.Open(FCurrentMarkerForInfoWindow);

  Log('Requesting elevation...');
  GMMap.Elevations.Clear;
  GMMap.Elevations.AddLatLng(FCurrentMarkerForInfoWindow.Options.Position);
  GMMap.Elevations.Execute;
end;

{ ========== ELEVATION ========== }

procedure TMainFrm.ElevationCompleted(Sender: TObject; const AResponse: TGMElevationResponse);
var
  HTML: string;
  FirstResult: TGMElevationResult;
  GeocodeResult: TGMGeocodeResult;
begin
  Log(Format('Elevation completed. Status: %s, HasResults: %s',
    [AResponse.Status, BoolToStr(AResponse.HasResults, True)]));

  if (not Assigned(FCurrentMarkerForInfoWindow)) or (not Assigned(FCurrentInfoWindowForMarker)) then
  begin
    Log('No InfoWindow or marker available');
    Exit;
  end;

  HTML := '<div style="font-family:Arial,sans-serif;font-size:12px;">';
  HTML := HTML + '<strong>Coords:</strong> ' + Format('%.6f, %.6f',
    [FCurrentMarkerForInfoWindow.Options.Position.Lat, FCurrentMarkerForInfoWindow.Options.Position.Lng]) + '<br/>';

  if GMMap.GeoCode.LastResponse.HasResults then
  begin
    GeocodeResult := GMMap.GeoCode.LastResponse.Results[0];
    HTML := HTML + '<strong>Address:</strong><br/>' + GeocodeResult.FormattedAddress + '<br/>';
    HTML := HTML + '<strong>Place ID:</strong> ' + GeocodeResult.PlaceId + '<br/>';
    HTML := HTML + '<strong>Type:</strong> ' + GeocodeResult.LocationType + '<br/>';
  end
  else
    HTML := HTML + '<em>No address found</em><br/>';

  if AResponse.HasResults and AResponse.TryGetFirstResult(FirstResult) then
  begin
    HTML := HTML + '<strong>Elevation:</strong> ' + Format('%.2f m', [FirstResult.Elevation]) + '<br/>';
    HTML := HTML + '<strong>Resolution:</strong> ' + Format('%.2f m', [FirstResult.Resolution]) + '<br/>';
  end
  else
    HTML := HTML + '<em>Elevation unavailable</em><br/>';

  HTML := HTML + '</div>';
  FCurrentInfoWindowForMarker.Options.Content := HTML;
end;

{ ========== ROUTES ========== }

procedure TMainFrm.RefreshRouteList;
var
  i: Integer;
  Query: TGMRouteQuery;
  QueryResult: TGMRouteQueryResult;
begin
  lbRoutes.Items.BeginUpdate;
  try
    lbRoutes.Clear;
    if GMMap.Routes.QueryCount = 0 then Exit;
    Query := GMMap.Routes.Queries[GMMap.Routes.QueryCount - 1];
    for i := 0 to Query.Count - 1 do
    begin
      QueryResult := Query.ResultItems[i];
      lbRoutes.Items.AddObject(
        Format('%s - %s',
          [QueryResult.ResponseResult.LocalizedDistance,
           QueryResult.ResponseResult.LocalizedDuration]),
        QueryResult);
    end;
  finally
    lbRoutes.Items.EndUpdate;
  end;
end;

procedure TMainFrm.RouteComputeClick(Sender: TObject);
var
  Query: TGMRouteQuery;
begin
  if not GMMap.IsReady then
  begin
    Log('Map not ready');
    Exit;
  end;

  Log('Route from: ' + FRouteFromEd.Text + ' to: ' + FRouteToEd.Text);

  GMMap.Routes.OriginAddress := FRouteFromEd.Text;
  GMMap.Routes.OriginLocation.Lat := 0;
  GMMap.Routes.OriginLocation.Lng := 0;

  GMMap.Routes.DestinationAddress := FRouteToEd.Text;
  GMMap.Routes.DestinationLocation.Lat := 0;
  GMMap.Routes.DestinationLocation.Lng := 0;

  GMMap.Routes.TravelMode := rtmDrive;
  GMMap.Routes.RequestFields := '';
  GMMap.Routes.ComputeAlternativeRoutes := True;

  UpdateStatus('Computing route...');
  Log('Computing route...');
  Query := GMMap.Routes.ExecuteQuery;
  if Assigned(Query) then
    Log('Route query created: ' + Query.RequestId);
end;

procedure TMainFrm.RouteCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
begin
  Log(Format('Route completed. Status: %s, HasResults: %s',
    [AResponse.Status, BoolToStr(AResponse.HasResults, True)]));
  RefreshRouteList;
end;

procedure TMainFrm.RouteListClick(Sender: TObject);
var
  Idx: Integer;
  RouteResult: TGMRouteQueryResult;
begin
  Idx := lbRoutes.ItemIndex;
  if Idx < 0 then Exit;
  RouteResult := TGMRouteQueryResult(lbRoutes.Items.Objects[Idx]);
  if Assigned(RouteResult) then
  begin
    Log(Format('Route selected: Distance=%.0fm, Duration=%dms',
      [RouteResult.ResponseResult.DistanceMeters,
       RouteResult.ResponseResult.DurationMillis]));
    if not RouteResult.Visible then
      RouteResult.Visible := True;
    RouteResult.ZoomToRoute;
  end;
end;

{ ========== GEOMETRY ========== }

procedure TMainFrm.GeomComputeClick(Sender: TObject);
var
  FromPoint, ToPoint, ProbePoint, MidPoint, OffsetPoint: TMapLibLatLng;
  DistanceMeters, HeadingDegrees: Double;
  Polyline: TGMPolylinePath;
  Polygon: TGMPolygonPath;
  InPolygon, OnEdge: Boolean;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Invariant;
  FromPoint := TMapLibLatLng.Create(
    StrToFloatDef(FGeomFromLatEd.Text, 0, FS),
    StrToFloatDef(FGeomFromLngEd.Text, 0, FS));
  ToPoint := TMapLibLatLng.Create(
    StrToFloatDef(FGeomToLatEd.Text, 0, FS),
    StrToFloatDef(FGeomToLngEd.Text, 0, FS));
  ProbePoint := TMapLibLatLng.Create(
    StrToFloatDef(FGeomPointLatEd.Text, 0, FS),
    StrToFloatDef(FGeomPointLngEd.Text, 0, FS));
  Polyline := TGMPolylinePath.Create(nil);
  Polygon := TGMPolygonPath.Create(nil);
  try
    DistanceMeters := TGMGeometry.ComputeDistanceBetween(FromPoint, ToPoint);
    HeadingDegrees := TGMGeometry.ComputeHeading(FromPoint, ToPoint);
    MidPoint := TGMGeometry.Interpolate(FromPoint, ToPoint, 0.5);
    OffsetPoint := TGMGeometry.ComputeOffset(FromPoint, DistanceMeters / 4, HeadingDegrees);
    try
      Polyline.Add(FromPoint.Lat, FromPoint.Lng);
      Polyline.Add(ToPoint.Lat, ToPoint.Lng);

      Polygon.Add(MidPoint.Lat - 0.01, MidPoint.Lng - 0.01);
      Polygon.Add(MidPoint.Lat - 0.01, MidPoint.Lng + 0.01);
      Polygon.Add(MidPoint.Lat + 0.01, MidPoint.Lng + 0.01);
      Polygon.Add(MidPoint.Lat + 0.01, MidPoint.Lng - 0.01);

      InPolygon := TGMGeometry.ContainsLocation(ProbePoint, Polygon);
      OnEdge := TGMGeometry.IsLocationOnEdge(MidPoint, Polyline, 50);

      FGeomResultMemo.Lines.BeginUpdate;
      try
        FGeomResultMemo.Lines.Clear;
        FGeomResultMemo.Lines.Add(Format('From: %.6f, %.6f', [FromPoint.Lat, FromPoint.Lng]));
        FGeomResultMemo.Lines.Add(Format('To: %.6f, %.6f', [ToPoint.Lat, ToPoint.Lng]));
        FGeomResultMemo.Lines.Add(Format('Distance: %.2f m', [DistanceMeters]));
        FGeomResultMemo.Lines.Add(Format('Heading: %.2f deg', [HeadingDegrees]));
        FGeomResultMemo.Lines.Add(Format('Midpoint: %.6f, %.6f', [MidPoint.Lat, MidPoint.Lng]));
        FGeomResultMemo.Lines.Add(Format('Offset (25%%): %.6f, %.6f', [OffsetPoint.Lat, OffsetPoint.Lng]));
        FGeomResultMemo.Lines.Add(Format('Probe: %.6f, %.6f', [ProbePoint.Lat, ProbePoint.Lng]));
        FGeomResultMemo.Lines.Add(Format('Probe inside sample polygon: %s', [BoolToStr(InPolygon, True)]));
        FGeomResultMemo.Lines.Add(Format('Midpoint on sample polyline edge: %s', [BoolToStr(OnEdge, True)]));
      finally
        FGeomResultMemo.Lines.EndUpdate;
      end;

      Log('Geometry helpers computed');
    finally
      MidPoint.Free;
      OffsetPoint.Free;
    end;
  finally
    Polyline.Free;
    Polygon.Free;
    FromPoint.Free;
    ToPoint.Free;
    ProbePoint.Free;
  end;
end;

{ ========== OSM ========== }

procedure TMainFrm.OSMActivateClick(Sender: TObject);
var
  centerLat: Double;
  centerLng: Double;
  zoom: Double;
  mapMode: TMapLibMapMode;
  styleTemplatePath: string;
  glyphsRootPath: string;
  remoteTileTemplate: string;
  localCssPath: string;
  localJsPath: string;
begin
  UpdateStatus('Activating OSM...');

  if not TryStrToFloat(Trim(eOSMCenterLat.Text), centerLat, TFormatSettings.Invariant) then
  begin
    Log('Invalid OSM center latitude.');
    Exit;
  end;
  if not TryStrToFloat(Trim(eOSMCenterLng.Text), centerLng, TFormatSettings.Invariant) then
  begin
    Log('Invalid OSM center longitude.');
    Exit;
  end;
  if not TryStrToFloat(Trim(eOSMZoom.Text), zoom, TFormatSettings.Invariant) then
  begin
    Log('Invalid OSM zoom.');
    Exit;
  end;

  if OSMMap.Active then
  begin
    OSMMap.Active := False;
    OSMMap.Browser := nil;
    EdgeBrowser1.Navigate('about:blank');
    bActivateOSM.Text := 'Activate';
    Log('Map is inactive.');
    UpdateStatus('Map inactive...');
    Exit;
  end;

  if GMMap.Active then
  begin
    GMMap.Active := False;
    GMMap.Browser := nil;
    bActivate.Text := 'Activate';
    Log('GM map deactivated (OSM map activation).');
  end;

  OSMMap.CenterLat := centerLat;
  OSMMap.CenterLng := centerLng;
  OSMMap.Zoom := zoom;
  OSMMap.Bearing := StrToFloatDef(Trim(eOSMBearing.Text), 0, TFormatSettings.Invariant);
  OSMMap.Pitch := StrToFloatDef(Trim(eOSMPitch.Text), 0, TFormatSettings.Invariant);
  OSMMap.MinZoom := StrToFloatDef(Trim(eOSMMinZoom.Text), 0, TFormatSettings.Invariant);
  OSMMap.MaxZoom := StrToFloatDef(Trim(eOSMMaxZoom.Text), 22, TFormatSettings.Invariant);
  OSMMap.DragPanEnabled := cbOSMDragPan.IsChecked;
  OSMMap.DragRotateEnabled := cbOSMDragRotate.IsChecked;
  OSMMap.DoubleClickZoomEnabled := cbOSMDoubleClickZoom.IsChecked;
  OSMMap.ScrollZoomEnabled := cbOSMScrollZoom.IsChecked;
  OSMMap.KeyboardEnabled := cbOSMKeyboard.IsChecked;
  OSMMap.TouchZoomRotateEnabled := cbOSMTouchZoomRotate.IsChecked;
  OSMMap.TouchPitchEnabled := cbOSMTouchPitch.IsChecked;
  OSMMap.CooperativeGesturesEnabled := cbOSMCooperativeGestures.IsChecked;

  case cbOSMMapMode.ItemIndex of
    1: mapMode := omOffline;
    2: mapMode := omHybrid;
  else
    mapMode := omOnline;
  end;

  OSMMap.MapMode := mapMode;
  case mapMode of
    omOnline:
      OSMMap.OfflinePolicy := opPreferOnline;
    omOffline:
      OSMMap.OfflinePolicy := opOfflineOnly;
  else
    OSMMap.OfflinePolicy := opPreferOffline;
  end;

  remoteTileTemplate := Trim(eOSMOfflineTileJsonUrl.Text);
  styleTemplatePath := Trim(eOSMOfflineServerPort.Text);
  glyphsRootPath := Trim(eOSMOfflineServerExecutable.Text);

  if styleTemplatePath = '' then
    styleTemplatePath := ResolveRepoAssetPathFromRoot('resources\js\osm\offline\style.template.json');
  if (styleTemplatePath <> '') and not FileExists(styleTemplatePath) then
    styleTemplatePath := ResolveRepoAssetPathFromRoot('resources\js\osm\offline\style.template.json');
  if glyphsRootPath = '' then
    glyphsRootPath := ResolveRepoAssetPathFromRoot('resources\js\osm\vendor');
  if (glyphsRootPath <> '') and not DirectoryExists(glyphsRootPath) then
    glyphsRootPath := ResolveRepoAssetPathFromRoot('resources\js\osm\vendor');

  localCssPath := ResolveRepoAssetPathFromRoot('resources\js\osm\vendor\maplibre-gl.css');
  localJsPath := ResolveRepoAssetPathFromRoot('resources\js\osm\vendor\maplibre-gl.js');

  if mapMode <> omOnline then
  begin
    OSMMap.StyleTemplateFileName := styleTemplatePath;
    OSMMap.GlyphsRootPath := glyphsRootPath;
    OSMMap.RemoteTileTemplate := remoteTileTemplate;

    if FileExists(localCssPath) then
      OSMMap.MapLibreCssUrl := localCssPath;
    if FileExists(localJsPath) then
      OSMMap.MapLibreJsUrl := localJsPath;
  end
  else
  begin
    OSMMap.StyleTemplateFileName := '';
    OSMMap.GlyphsRootPath := '';
    OSMMap.RemoteTileTemplate := '';
  end;

  EdgeBrowser1.Visible := True;
  EdgeBrowser1.BringToFront;
  OSMMap.Browser := EdgeBrowser1;
  try
    OSMMap.Active := True;
  except
    on E: Exception do
    begin
      Log('OSM activation failed: ' + E.Message);
      raise;
    end;
  end;
  bActivateOSM.Text := 'Deactivate';
  UpdateStatus('Loading OSM map...');
end;

procedure TMainFrm.OSMApplyViewClick(Sender: TObject);
var
  lat, lng: Double;
  zoom: Double;
begin
  if not TryStrToFloat(Trim(eOSMCenterLat.Text), lat, TFormatSettings.Invariant) then
    Exit;
  if not TryStrToFloat(Trim(eOSMCenterLng.Text), lng, TFormatSettings.Invariant) then
    Exit;
  if not TryStrToFloat(Trim(eOSMZoom.Text), zoom, TFormatSettings.Invariant) then
    Exit;
  OSMMap.CenterLat := lat;
  OSMMap.CenterLng := lng;
  OSMMap.Zoom := zoom;
  OSMMap.Bearing := StrToFloatDef(Trim(eOSMBearing.Text), 0, TFormatSettings.Invariant);
  OSMMap.Pitch := StrToFloatDef(Trim(eOSMPitch.Text), 0, TFormatSettings.Invariant);
  OSMMap.MinZoom := StrToFloatDef(Trim(eOSMMinZoom.Text), 0, TFormatSettings.Invariant);
  OSMMap.MaxZoom := StrToFloatDef(Trim(eOSMMaxZoom.Text), 22, TFormatSettings.Invariant);
  OSMMap.DragPanEnabled := cbOSMDragPan.IsChecked;
  OSMMap.DragRotateEnabled := cbOSMDragRotate.IsChecked;
  OSMMap.DoubleClickZoomEnabled := cbOSMDoubleClickZoom.IsChecked;
  OSMMap.ScrollZoomEnabled := cbOSMScrollZoom.IsChecked;
  OSMMap.KeyboardEnabled := cbOSMKeyboard.IsChecked;
  OSMMap.TouchZoomRotateEnabled := cbOSMTouchZoomRotate.IsChecked;
  OSMMap.TouchPitchEnabled := cbOSMTouchPitch.IsChecked;
  OSMMap.CooperativeGesturesEnabled := cbOSMCooperativeGestures.IsChecked;
  Log('OSM view updated.');
end;

procedure TMainFrm.OSMApplyStyleClick(Sender: TObject);
begin
  if Trim(eOSMStyleUrl.Text) <> '' then
  begin
    OSMMap.StyleUrl := eOSMStyleUrl.Text;
    OSMMap.ApplyStyle;
    Log('OSM style applied.');
  end;
end;

procedure TMainFrm.ApplyOSMEventFilterClick(Sender: TObject);
begin
  OSMMap.OnMoveStart := nil;
  OSMMap.OnMove := nil;
  OSMMap.OnMoveEnd := nil;
  OSMMap.OnDragStart := nil;
  OSMMap.OnDrag := nil;
  OSMMap.OnDragEnd := nil;
  OSMMap.OnZoomStart := nil;
  OSMMap.OnZoom := nil;
  OSMMap.OnZoomEnd := nil;
  OSMMap.OnRotateStart := nil;
  OSMMap.OnRotate := nil;
  OSMMap.OnRotateEnd := nil;
  OSMMap.OnPitchStart := nil;
  OSMMap.OnPitch := nil;
  OSMMap.OnPitchEnd := nil;
  OSMMap.OnRender := nil;
  OSMMap.OnResize := nil;
  OSMMap.OnLoad := nil;
  OSMMap.OnIdle := nil;
  OSMMap.OnData := nil;
  OSMMap.OnDataLoading := nil;
  OSMMap.OnDataAbort := nil;
  OSMMap.OnSourceData := nil;
  OSMMap.OnSourceDataLoading := nil;
  OSMMap.OnSourceDataAbort := nil;
  OSMMap.OnStyleData := nil;
  OSMMap.OnStyleDataLoading := nil;
  OSMMap.OnStyleImageMissing := nil;
  OSMMap.OnTerrain := nil;
  OSMMap.OnProjectionTransition := nil;
  OSMMap.OnWebGLContextLost := nil;
  OSMMap.OnWebGLContextRestored := nil;
  OSMMap.OnWheel := nil;
  OSMMap.OnTouchCancel := nil;
  OSMMap.OnTouchEnd := nil;
  OSMMap.OnTouchMove := nil;
  OSMMap.OnTouchStart := nil;
  OSMMap.OnBoxZoomStart := nil;
  OSMMap.OnBoxZoomEnd := nil;
  OSMMap.OnBoxZoomCancel := nil;

  if cbOSMLogMove.IsChecked then
  begin
    OSMMap.OnMoveStart := OSMMapViewChangedEvent;
    OSMMap.OnMove := OSMMapViewChangedEvent;
    OSMMap.OnMoveEnd := OSMMapViewChangedEvent;
    OSMMap.OnDragStart := OSMMapViewChangedEvent;
    OSMMap.OnDrag := OSMMapViewChangedEvent;
    OSMMap.OnDragEnd := OSMMapViewChangedEvent;
    OSMMap.OnZoomStart := OSMMapViewChangedEvent;
    OSMMap.OnZoom := OSMMapViewChangedEvent;
    OSMMap.OnZoomEnd := OSMMapViewChangedEvent;
    OSMMap.OnRotateStart := OSMMapViewChangedEvent;
    OSMMap.OnRotate := OSMMapViewChangedEvent;
    OSMMap.OnRotateEnd := OSMMapViewChangedEvent;
    OSMMap.OnPitchStart := OSMMapViewChangedEvent;
    OSMMap.OnPitch := OSMMapViewChangedEvent;
    OSMMap.OnPitchEnd := OSMMapViewChangedEvent;
  end;
  if cbOSMLogRender.IsChecked then
  begin
    OSMMap.OnRender := OSMMapSimpleEvent;
    OSMMap.OnResize := OSMMapSimpleEvent;
    OSMMap.OnLoad := OSMMapSimpleEvent;
    OSMMap.OnIdle := OSMMapSimpleEvent;
    OSMMap.OnTouchCancel := OSMMapSimpleEvent;
    OSMMap.OnTouchEnd := OSMMapSimpleEvent;
    OSMMap.OnTouchMove := OSMMapSimpleEvent;
    OSMMap.OnTouchStart := OSMMapSimpleEvent;
    OSMMap.OnBoxZoomStart := OSMMapSimpleEvent;
    OSMMap.OnBoxZoomEnd := OSMMapSimpleEvent;
    OSMMap.OnBoxZoomCancel := OSMMapSimpleEvent;
    OSMMap.OnWheel := OSMMapSimpleEvent;
  end;
  if cbOSMLogData.IsChecked then
  begin
    OSMMap.OnData := OSMMapSimpleEvent;
    OSMMap.OnDataLoading := OSMMapSimpleEvent;
    OSMMap.OnDataAbort := OSMMapSimpleEvent;
    OSMMap.OnSourceData := OSMMapSimpleEvent;
    OSMMap.OnSourceDataLoading := OSMMapSimpleEvent;
    OSMMap.OnSourceDataAbort := OSMMapSimpleEvent;
    OSMMap.OnStyleData := OSMMapSimpleEvent;
    OSMMap.OnStyleDataLoading := OSMMapSimpleEvent;
    OSMMap.OnStyleImageMissing := OSMMapSimpleEvent;
    OSMMap.OnTerrain := OSMMapSimpleEvent;
    OSMMap.OnProjectionTransition := OSMMapSimpleEvent;
    OSMMap.OnWebGLContextLost := OSMMapSimpleEvent;
    OSMMap.OnWebGLContextRestored := OSMMapSimpleEvent;
  end;

  Log('OSM event filter applied.');
end;

{ ========== OSM Map Events ========== }

procedure TMainFrm.OSMMapReady(Sender: TObject);
begin
  Log('OSM map is ready');
  UpdateStatus('OSM ready');
  EdgeBrowser1.Visible := True;
  EdgeBrowser1.BringToFront;
end;

procedure TMainFrm.OSMMapClickEvent(Sender: TObject; ALatLng: TMapLibLatLng);
var
  Marker: TOSMMarkerItem;
begin
  if not Assigned(ALatLng) then
    Exit;

  Log(Format('OSM click: %.6f, %.6f', [ALatLng.Lat, ALatLng.Lng]));

  Marker := OSMMap.Markers.Add;
  Marker.Lat := ALatLng.Lat;
  Marker.Lng := ALatLng.Lng;
  Marker.Title := Format('OSM Marker %d', [OSMMap.Markers.Count]);
  BindOSMMarkerEvents(Marker);
  Log('OSM marker added: ' + string(Marker.ObjectId));
  RefreshOSMMarkerList;
end;

procedure TMainFrm.OSMMarkerClickEvent(Sender: TObject; ALatLng: TMapLibLatLng);
var
  Marker: TOSMMarkerItem;
begin
  if Sender is TOSMMarkerItem then
    Marker := TOSMMarkerItem(Sender)
  else
    Marker := nil;

  if Assigned(ALatLng) and Assigned(Marker) then
    Log(Format('OSM marker click: %s @ %.6f, %.6f', [string(Marker.ObjectId), ALatLng.Lat, ALatLng.Lng]))
  else if Assigned(Marker) then
    Log('OSM marker click: ' + string(Marker.ObjectId))
  else
    Log('OSM marker click');

  if Assigned(lbOSMMarkers) and Assigned(Marker) then
    lbOSMMarkers.ItemIndex := lbOSMMarkers.Items.IndexOfObject(Marker);

  ShowOSMMarkerPopup(Marker);
end;

procedure TMainFrm.OSMMapCoordinateEvent(Sender: TObject; ALatLng: TMapLibLatLng);
var
  Marker: TOSMMarkerItem;
begin
  if not Assigned(ALatLng) then
    Exit;

  if Sender is TOSMMarkerItem then
    Marker := TOSMMarkerItem(Sender)
  else
    Marker := nil;

  Log(Format('OSM coordinate [%s]: %.6f, %.6f', [OSMMap.LastEventName, ALatLng.Lat, ALatLng.Lng]));

  if Assigned(Marker) and SameText(OSMMap.LastEventName, 'dragend') and
     Assigned(FCurrentOSMMarkerForPopup) and (Marker = FCurrentOSMMarkerForPopup) and
     Assigned(FCurrentOSMPopupForMarker) and FCurrentOSMPopupForMarker.Options.Visible then
    ShowOSMMarkerPopup(Marker);
end;

procedure TMainFrm.OSMMapSimpleEvent(Sender: TObject);
begin
  Log('OSM event: ' + OSMMap.LastEventName);
end;

procedure TMainFrm.OSMMapBoundsChangedEvent(Sender: TObject; ANorth, ASouth, AEast, AWest: Double);
begin
  Log(Format('OSM bounds: N=%.4f S=%.4f E=%.4f W=%.4f', [ANorth, ASouth, AEast, AWest]));
end;

procedure TMainFrm.OSMMapViewChangedEvent(Sender: TObject; ACenter: TMapLibLatLng; AZoom, ABearing, APitch: Double);
begin
  if Assigned(ACenter) then
  begin
    eOSMCenterLat.Text := FloatToStr(ACenter.Lat, TFormatSettings.Invariant);
    eOSMCenterLng.Text := FloatToStr(ACenter.Lng, TFormatSettings.Invariant);
    Log(Format('OSM view [%s]: %.6f,%.6f z=%.2f b=%.2f p=%.2f',
      [OSMMap.LastEventName, ACenter.Lat, ACenter.Lng, AZoom, ABearing, APitch]));
  end;
  eOSMZoom.Text := FloatToStr(AZoom, TFormatSettings.Invariant);
  eOSMBearing.Text := FloatToStr(ABearing, TFormatSettings.Invariant);
  eOSMPitch.Text := FloatToStr(APitch, TFormatSettings.Invariant);
end;

procedure TMainFrm.OSMMapErrorEvent(Sender: TObject; const AMessage: string);
begin
  Log('OSM error: ' + AMessage);
  UpdateStatus('OSM error');
end;

procedure TMainFrm.OSMMapDownloadProgress(Sender: TObject; const AJobId: string; APercent: Double; ABytesDone, ABytesTotal: Int64);
begin
  Log(Format('OSM download %s: %.1f%% (%d/%d bytes)', [AJobId, APercent, ABytesDone, ABytesTotal]));
end;

procedure TMainFrm.OSMMapRegionReady(Sender: TObject; const ARegionId: TMapLibOfflineRegionId);
begin
  Log('OSM offline region ready: ' + string(ARegionId));
  RefreshOSMRegionsList;
end;

procedure TMainFrm.OSMMapOfflineError(Sender: TObject; AErrorCode: Integer; const AUserMessage, ATechnicalMessage: string);
begin
  Log(Format('OSM offline error %d: %s (%s)', [AErrorCode, AUserMessage, ATechnicalMessage]));
end;

{ ========== OSM Offline Regions ========== }

procedure TMainFrm.RefreshOSMRegionsList;
var
  Regions: TMapLibOfflineRegionMetadataArray;
  I: Integer;
begin
  if not Assigned(lbOSMRegions) then
    Exit;

  lbOSMRegions.Items.BeginUpdate;
  try
    lbOSMRegions.Clear;
    if Assigned(OSMMap) and Assigned(OSMMap.OfflineRegionManager) then
    begin
      Regions := OSMMap.OfflineRegionManager.ListRegions;
      for I := Low(Regions) to High(Regions) do
        lbOSMRegions.Items.Add(
          Format('%s (%s, %d bytes)', [string(Regions[I].RegionId), Regions[I].StoragePath, Regions[I].SizeBytes]));
    end;
  finally
    lbOSMRegions.Items.EndUpdate;
  end;
end;

procedure TMainFrm.OSMDownloadRegionClick(Sender: TObject);
var
  RegionId: string;
  SourceUrl: string;
  Req: TMapLibOfflineDownloadRequest;
begin
  RegionId := 'spain';
  SourceUrl := 'https://github.com/cadetill/gmlib_v2/raw/master/resources/js/osm/vendor/spain.pmtiles';
  TDialogService.InputQuery(
    'Download Offline Region',
    ['Enter Region ID (e.g. spain):'],
    [RegionId],
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      if AResult <> mrOk then
        Exit;
      if Length(AValues) > 0 then
        RegionId := AValues[0];
      TDialogService.InputQuery(
        'Download Offline Region',
        ['Enter PMTiles/MBTiles HTTP Source URL:'],
        [SourceUrl],
        procedure(const AInnerResult: TModalResult; const AInnerValues: array of string)
        begin
          if AInnerResult <> mrOk then
            Exit;
          if Length(AInnerValues) > 0 then
            SourceUrl := AInnerValues[0];
          if (Trim(RegionId) = '') or (Trim(SourceUrl) = '') then
          begin
            Log('Region ID and Source URL are required.');
            Exit;
          end;
          if Assigned(OSMMap.OfflineRegionManager) then
          begin
            Req.RegionId := TMapLibOfflineRegionId(RegionId);
            Req.SourceUrl := SourceUrl;
            Req.MinZoom := 0;
            Req.MaxZoom := 10;
            Req.Bounds.North := 43.79;
            Req.Bounds.South := 35.17;
            Req.Bounds.East := 4.33;
            Req.Bounds.West := -9.30;
            Req.DataVersion := '1.0.0';
            if OSMMap.OfflineRegionManager.DownloadRegion(Req) <> '' then
              Log('OSM download started for region: ' + RegionId)
            else
              Log('OSM download failed to start or is already active.');
          end;
        end
      );
    end
  );
end;

procedure TMainFrm.OSMDeleteRegionClick(Sender: TObject);
var
  Regions: TMapLibOfflineRegionMetadataArray;
  I: Integer;
  regionId: string;
begin
  if not Assigned(lbOSMRegions) or (lbOSMRegions.ItemIndex < 0) then
  begin
    Log('Please select a region to delete.');
    Exit;
  end;

  if not Assigned(OSMMap.OfflineRegionManager) then
    Exit;

  Regions := OSMMap.OfflineRegionManager.ListRegions;
  I := lbOSMRegions.ItemIndex;
  if (I >= Low(Regions)) and (I <= High(Regions)) then
  begin
    regionId := string(Regions[I].RegionId);
    TDialogService.MessageDialog(
      Format('Are you sure you want to delete region "%s" and its associated files?', [regionId]),
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo,
      0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          if OSMMap.OfflineRegionManager.DeleteRegion(regionId) then
          begin
            Log('OSM region deleted: ' + regionId);
            RefreshOSMRegionsList;
          end
          else
            Log('Failed to delete OSM region: ' + regionId);
        end;
      end);
  end;
end;

procedure TMainFrm.OSMListRegionsClick(Sender: TObject);
begin
  RefreshOSMRegionsList;
  Log('OSM regions listed');
end;

{ ========== OSM Markers ========== }

procedure TMainFrm.RefreshOSMMarkerList;
var
  I: Integer;
begin
  lbOSMMarkers.Items.BeginUpdate;
  try
    lbOSMMarkers.Clear;
    for I := 0 to OSMMap.Markers.Count - 1 do
      lbOSMMarkers.Items.AddObject(
        Format('Marker %d', [I]), OSMMap.Markers[I]);
  finally
    lbOSMMarkers.Items.EndUpdate;
  end;
end;

procedure TMainFrm.RefreshOSMPopupList;
var
  I: Integer;
  Popup: TOSMPopupItem;
  anchorText: string;
begin
  if not Assigned(lbOSMPopups) then
    Exit;

  lbOSMPopups.Items.BeginUpdate;
  try
    lbOSMPopups.Clear;
    for I := 0 to OSMMap.Popups.Count - 1 do
    begin
      Popup := OSMMap.Popups[I];
      anchorText := IfThen(string(Popup.AnchorObjectId) <> '', string(Popup.AnchorObjectId), '-');
      lbOSMPopups.Items.AddObject(
        Format('%s [anchor=%s] (%.5f, %.5f) %s', [
          string(Popup.ObjectId),
          anchorText,
          Popup.Options.Position.Lat,
          Popup.Options.Position.Lng,
          IfThen(Popup.Options.Visible, 'open', 'closed')
        ]),
        Popup
      );
    end;
  finally
    lbOSMPopups.Items.EndUpdate;
  end;
end;

procedure TMainFrm.BindOSMMarkerEvents(AMarker: TOSMMarkerItem);
begin
  if not Assigned(AMarker) then
    Exit;

  AMarker.OnClick := OSMMarkerClickEvent;
  AMarker.OnDragStart := OSMMapCoordinateEvent;
  AMarker.OnDrag := OSMMapCoordinateEvent;
  AMarker.OnDragEnd := OSMMapCoordinateEvent;
end;

procedure TMainFrm.BindOSMPopupEvents(APopup: TOSMPopupItem);
begin
  if not Assigned(APopup) then
    Exit;

  APopup.OnClose := OSMPopupCloseEvent;
  APopup.OnOpen := OSMPopupOpenEvent;
end;

procedure TMainFrm.OSMClearMarkersClick(Sender: TObject);
begin
  if Assigned(FCurrentOSMPopupForMarker) then
  begin
    OSMMap.Popups.Clear;
    FCurrentOSMPopupForMarker := nil;
    FCurrentOSMMarkerForPopup := nil;
    RefreshOSMPopupList;
  end;
  OSMMap.Markers.Clear;
  RefreshOSMMarkerList;
  Log('OSM markers cleared');
end;

procedure TMainFrm.OSMZoomToMarkersClick(Sender: TObject);
begin
  if OSMMap.Markers.ZoomToMarkers then
    Log('OSM zoom to markers applied')
  else
    Log('No visible OSM markers to zoom');
end;

procedure TMainFrm.OSMMarkerListClick(Sender: TObject);
var
  Marker: TOSMMarkerItem;
begin
  if not Assigned(lbOSMMarkers) or (lbOSMMarkers.ItemIndex < 0) then
    Exit;

  Marker := TOSMMarkerItem(lbOSMMarkers.Items.Objects[lbOSMMarkers.ItemIndex]);
  if not Assigned(Marker) then
    Exit;

  Log(Format('OSM marker selected: %s @ %.6f, %.6f',
    [string(Marker.ObjectId), Marker.Lat, Marker.Lng]));
end;

procedure TMainFrm.LoadOSMPopupToUI(APopup: TOSMPopupItem);
begin
  if not Assigned(APopup) then
    Exit;

  eOSMPopupLat.Text := FloatToStr(APopup.Options.Position.Lat, TFormatSettings.Invariant);
  eOSMPopupLng.Text := FloatToStr(APopup.Options.Position.Lng, TFormatSettings.Invariant);
  eOSMPopupAnchorObjectId.Text := string(APopup.AnchorObjectId);
  eOSMPopupMaxWidth.Text := IntToStr(APopup.Options.MaxWidth);
  SelectOSMPopupPresetStyle(APopup.Options.PresetStyle);
  SelectOSMPopupContentType(APopup.Options.ContentType);
  mOSMPopupContent.Lines.Text := APopup.Options.Content;
  cbOSMPopupVisible.IsChecked := APopup.Options.Visible;
  cbOSMPopupCloseButton.IsChecked := APopup.Options.CloseButton;
  cbOSMPopupCloseOnClick.IsChecked := APopup.Options.CloseOnClick;
  cbOSMPopupCloseOnMove.IsChecked := APopup.Options.CloseOnMove;
  cbOSMPopupCloseOthersBeforeOpen.IsChecked := OSMMap.Popups.CloseOthersBeforeOpen;
end;

procedure TMainFrm.LoadUIToOSMPopup(APopup: TOSMPopupItem; APreservePosition: Boolean);
var
  Lat: Double;
  Lng: Double;
begin
  if not Assigned(APopup) then
    Exit;

  APopup.BeginUpdate;
  try
    if not APreservePosition then
    begin
      if TryStrToFloat(Trim(eOSMPopupLat.Text), Lat, TFormatSettings.Invariant) then
        APopup.Options.Position.Lat := Lat;
      if TryStrToFloat(Trim(eOSMPopupLng.Text), Lng, TFormatSettings.Invariant) then
        APopup.Options.Position.Lng := Lng;
    end;

    OSMMap.Popups.CloseOthersBeforeOpen := cbOSMPopupCloseOthersBeforeOpen.IsChecked;
    APopup.AnchorObjectId := TGMObjectId(Trim(eOSMPopupAnchorObjectId.Text));
    APopup.Options.MaxWidth := StrToIntDef(Trim(eOSMPopupMaxWidth.Text), 0);
    APopup.Options.PresetStyle := GetSelectedOSMPopupPresetStyle;
    APopup.Options.ContentType := GetSelectedOSMPopupContentType;
    APopup.Options.Content := mOSMPopupContent.Lines.Text;
    APopup.Options.CloseButton := cbOSMPopupCloseButton.IsChecked;
    APopup.Options.CloseOnClick := cbOSMPopupCloseOnClick.IsChecked;
    APopup.Options.CloseOnMove := cbOSMPopupCloseOnMove.IsChecked;
    APopup.Options.Visible := cbOSMPopupVisible.IsChecked;
  finally
    APopup.EndUpdate;
  end;
end;

function TMainFrm.GetSelectedOSMPopupPresetStyle: TOSMPopupPresetStyle;
begin
  Result := ppsDefault;
  if not Assigned(cbOSMPopupCssClass) then
    Exit;

  case cbOSMPopupCssClass.ItemIndex of
    1: Result := ppsNote;
    2: Result := ppsWarning;
    3: Result := ppsDark;
    4: Result := ppsSuccess;
  end;
end;

function TMainFrm.GetSelectedOSMPopupContentType: TOSMPopupContentType;
begin
  Result := pctHtml;
  if Assigned(cbOSMPopupContentType) and (cbOSMPopupContentType.ItemIndex = 1) then
    Result := pctText;
end;

procedure TMainFrm.SelectOSMPopupPresetStyle(AValue: TOSMPopupPresetStyle);
begin
  if not Assigned(cbOSMPopupCssClass) then
    Exit;

  case AValue of
    ppsNote: cbOSMPopupCssClass.ItemIndex := 1;
    ppsWarning: cbOSMPopupCssClass.ItemIndex := 2;
    ppsDark: cbOSMPopupCssClass.ItemIndex := 3;
    ppsSuccess: cbOSMPopupCssClass.ItemIndex := 4;
  else
    cbOSMPopupCssClass.ItemIndex := 0;
  end;
end;

procedure TMainFrm.SelectOSMPopupContentType(AValue: TOSMPopupContentType);
begin
  if not Assigned(cbOSMPopupContentType) then
    Exit;

  case AValue of
    pctText: cbOSMPopupContentType.ItemIndex := 1;
  else
    cbOSMPopupContentType.ItemIndex := 0;
  end;
end;

procedure TMainFrm.OSMPopupCloseEvent(Sender: TObject);
var
  Popup: TOSMPopupItem;
begin
  if Sender is TOSMPopupItem then
  begin
    Popup := TOSMPopupItem(Sender);
    Log('OSM popup closed: ' + string(Popup.ObjectId));
    RefreshOSMPopupList;
    if Assigned(lbOSMPopups) then
      lbOSMPopups.ItemIndex := lbOSMPopups.Items.IndexOfObject(Popup);
    LoadOSMPopupToUI(Popup);
  end;
end;

procedure TMainFrm.OSMPopupOpenEvent(Sender: TObject);
var
  Popup: TOSMPopupItem;
begin
  if Sender is TOSMPopupItem then
  begin
    Popup := TOSMPopupItem(Sender);
    Log('OSM popup opened: ' + string(Popup.ObjectId));
    RefreshOSMPopupList;
    if Assigned(lbOSMPopups) then
      lbOSMPopups.ItemIndex := lbOSMPopups.Items.IndexOfObject(Popup);
  end;
end;

procedure TMainFrm.ShowOSMMarkerPopup(AMarker: TOSMMarkerItem);
var
  Popup: TOSMPopupItem;
  popupContent: string;
begin
  if not Assigned(AMarker) then
    Exit;

  // La demo reutiliza un unico popup automatico para markers y asi evita
  // crear items efimeros cada vez que se hace click o termina un drag.
  if not Assigned(FCurrentOSMPopupForMarker) then
  begin
    FCurrentOSMPopupForMarker := OSMMap.Popups.Add;
    BindOSMPopupEvents(FCurrentOSMPopupForMarker);
  end;

  FCurrentOSMMarkerForPopup := AMarker;
  Popup := FCurrentOSMPopupForMarker;
  popupContent := Format(
    '<div><strong>Marker position</strong><br/>Lat: %.6f<br/>Lng: %.6f</div>',
    [AMarker.Lat, AMarker.Lng],
    TFormatSettings.Invariant
  );

  Popup.BeginUpdate;
  try
    Popup.AnchorObjectId := AMarker.ObjectId;
    Popup.Options.Position.Lat := AMarker.Lat;
    Popup.Options.Position.Lng := AMarker.Lng;
    Popup.Options.PresetStyle := ppsDark;
    Popup.Options.ContentType := pctHtml;
    Popup.Options.MaxWidth := 220;
    Popup.Options.Content := popupContent;
    Popup.Options.CloseButton := True;
    Popup.Options.CloseOnClick := False;
    Popup.Options.CloseOnMove := False;
    Popup.Options.Visible := True;
  finally
    Popup.EndUpdate;
  end;

  RefreshOSMPopupList;
  if Assigned(lbOSMPopups) then
    lbOSMPopups.ItemIndex := lbOSMPopups.Items.IndexOfObject(Popup);
end;

procedure TMainFrm.OSMPopupListClick(Sender: TObject);
var
  Popup: TOSMPopupItem;
begin
  if not Assigned(lbOSMPopups) or (lbOSMPopups.ItemIndex < 0) then
    Exit;

  Popup := TOSMPopupItem(lbOSMPopups.Items.Objects[lbOSMPopups.ItemIndex]);
  if not Assigned(Popup) then
    Exit;

  LoadOSMPopupToUI(Popup);
  Log('OSM popup selected: ' + string(Popup.ObjectId));
end;

procedure TMainFrm.OSMAddPopupClick(Sender: TObject);
var
  Popup: TOSMPopupItem;
begin
  if Trim(mOSMPopupContent.Lines.Text) = '' then
    mOSMPopupContent.Lines.Text := '<b>OSM popup</b>';

  cbOSMPopupVisible.IsChecked := True;
  Popup := OSMMap.Popups.Add;
  try
    BindOSMPopupEvents(Popup);
    LoadUIToOSMPopup(Popup);
    RefreshOSMPopupList;
    lbOSMPopups.ItemIndex := lbOSMPopups.Items.IndexOfObject(Popup);
    LoadOSMPopupToUI(Popup);
    Log('OSM popup added: ' + string(Popup.ObjectId));
  except
    Popup.Free;
    raise;
  end;
end;

procedure TMainFrm.OSMUpdatePopupClick(Sender: TObject);
var
  Popup: TOSMPopupItem;
begin
  if not Assigned(lbOSMPopups) or (lbOSMPopups.ItemIndex < 0) then
  begin
    Log('No OSM popup selected.');
    Exit;
  end;

  Popup := TOSMPopupItem(lbOSMPopups.Items.Objects[lbOSMPopups.ItemIndex]);
  if not Assigned(Popup) then
    Exit;

  LoadUIToOSMPopup(Popup);
  RefreshOSMPopupList;
  lbOSMPopups.ItemIndex := lbOSMPopups.Items.IndexOfObject(Popup);
  Log('OSM popup updated: ' + string(Popup.ObjectId));
end;

procedure TMainFrm.OSMDeletePopupClick(Sender: TObject);
var
  Popup: TOSMPopupItem;
begin
  if not Assigned(lbOSMPopups) or (lbOSMPopups.ItemIndex < 0) then
  begin
    Log('No OSM popup selected.');
    Exit;
  end;

  Popup := TOSMPopupItem(lbOSMPopups.Items.Objects[lbOSMPopups.ItemIndex]);
  if not Assigned(Popup) then
    Exit;

  if Assigned(FCurrentOSMPopupForMarker) and (Popup = FCurrentOSMPopupForMarker) then
  begin
    FCurrentOSMPopupForMarker := nil;
    FCurrentOSMMarkerForPopup := nil;
  end;

  OSMMap.Popups.Delete(Popup.Index);
  RefreshOSMPopupList;
  lbOSMPopups.ItemIndex := -1;
  Log('OSM popup deleted.');
end;

procedure TMainFrm.OSMClearPopupsClick(Sender: TObject);
begin
  FCurrentOSMPopupForMarker := nil;
  FCurrentOSMMarkerForPopup := nil;
  OSMMap.Popups.Clear;
  RefreshOSMPopupList;
  Log('OSM popups cleared');
end;

procedure TMainFrm.OSMUseSelectedMarkerForPopupClick(Sender: TObject);
var
  Marker: TOSMMarkerItem;
begin
  if not Assigned(lbOSMMarkers) or (lbOSMMarkers.ItemIndex < 0) then
  begin
    Log('No OSM marker selected for popup anchor.');
    Exit;
  end;

  Marker := TOSMMarkerItem(lbOSMMarkers.Items.Objects[lbOSMMarkers.ItemIndex]);
  if not Assigned(Marker) then
    Exit;

  eOSMPopupAnchorObjectId.Text := string(Marker.ObjectId);
  eOSMPopupLat.Text := FloatToStr(Marker.Lat, TFormatSettings.Invariant);
  eOSMPopupLng.Text := FloatToStr(Marker.Lng, TFormatSettings.Invariant);
  Log('OSM popup anchor set to marker: ' + string(Marker.ObjectId));
end;

function TMainFrm.ResolveRepoRootPath: string;
begin
  Result := ExpandFileName(
    IncludeTrailingPathDelimiter(TPath.GetAppPath) +
    '..\..\..\..\..'
  );
end;

function TMainFrm.ResolveRepoAssetPathFromRoot(const ARelativePath: string): string;
begin
  Result := ExpandFileName(
    IncludeTrailingPathDelimiter(ResolveRepoRootPath) + ARelativePath
  );
end;

end.
