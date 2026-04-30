unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Edge, Vcl.ExtCtrls, Vcl.CheckLst, System.RegularExpressions,
  uGMLib.Core.Component, uGMLib.Map, uGMLib.Vcl.Map, uGMLib.Vcl.Marker,
  uGMLib.Vcl.Polyline, uGMLib.Vcl.Polygon, uGMLib.Vcl.Rectangle,
  uGMLib.Vcl.Circle, uGMLib.Vcl.InfoWindow, uGMLib.Core.Types, uGMLib.MapOptions,
  uGMLib.Polyline, uGMLib.Polygon, uGMLib.Rectangle, uGMLib.Circle,
  uGMLib.GroundOverlay, uGMLib.GeoCode, uGMLib.Elevation, uGMLib.Routes,
  uGMLib.Geometry;

type
  TMainFrm = class(TForm)
    pcOptions: TPageControl;
    tsMap: TTabSheet;
    tsMarkers: TTabSheet;
    tsOverlays: TTabSheet;
    tsInfoWindows: TTabSheet;
    tsGeoCode: TTabSheet;
    tsElevation: TTabSheet;
    tsRoutes: TTabSheet;
    tsGeometry: TTabSheet;
    mLog: TMemo;
    Map: TGMLibVclMap;
    EdgeBrowser1: TEdgeBrowser;
    pMapTop: TPanel;
    lAPIKey: TLabel;
    MapIdLabel: TLabel;
    lStatus: TLabel;
    eAPIKey: TEdit;
    eMapId: TEdit;
    bApplyOptions: TButton;
    bActivate: TButton;
    pcMapOptions: TPageControl;
    tsMapGeneral: TTabSheet;
    lMapTypeId: TLabel;
    cbMapTypeId: TComboBox;
    cbColorScheme: TComboBox;
    lColorScheme: TLabel;
    lRenderType: TLabel;
    cbRenderType: TComboBox;
    eZoom: TEdit;
    lZoom: TLabel;
    lCenter: TLabel;
    eLat: TEdit;
    eLng: TEdit;
    lSep: TLabel;
    cbGestureHandling: TComboBox;
    lGestureHandling: TLabel;
    eHeading: TEdit;
    HeadingLabel: TLabel;
    eTilt: TEdit;
    TiltLabel: TLabel;
    cbClickableIcons: TCheckBox;
    cbDisableDefaultUI: TCheckBox;
    cbDisableDoubleClickZoom: TCheckBox;
    cbHeadingInteractionEnabled: TCheckBox;
    cbKeyboardShortcuts: TCheckBox;
    cbIsFractionalZoomEnabled: TCheckBox;
    cbBackGroundColor: TColorBox;
    lBackGroundColor: TLabel;
    tsControls: TTabSheet;
    cbCameraControl: TCheckBox;
    cbFullscreenControl: TCheckBox;
    cbFullscreenPosition: TComboBox;
    cbCameraPosition: TComboBox;
    lMaxZoom: TLabel;
    eMaxZoom: TEdit;
    eMinZoom: TEdit;
    lMinZoom: TLabel;
    lControlSize: TLabel;
    eControlSize: TEdit;
    cbMapTypeControl: TCheckBox;
    cbMapTypePosition: TComboBox;
    cbMapTypeStyle: TComboBox;
    clbMapTypeIds: TCheckListBox;
    cbNoClear: TCheckBox;
    cbRotateControl: TCheckBox;
    cbRotatePosition: TComboBox;
    cbScaleControl: TCheckBox;
    cbScaleStyle: TComboBox;
    cbScrollwheel: TCheckBox;
    cbStreetViewControl: TCheckBox;
    cbStreetViewPosition: TComboBox;
    cbTiltInteractionEnabled: TCheckBox;
    cbZoomControl: TCheckBox;
    cbZoomPosition: TComboBox;
    lbMarkers: TListBox;
    bAddMarker: TButton;
    bDeleteMarker: TButton;
    bClearMarkers: TButton;
    lMarkerLat: TLabel;
    eMarkerLat: TEdit;
    lMarkerLng: TLabel;
    eMarkerLng: TEdit;
    lMarkerTitle: TLabel;
    eMarkerTitle: TEdit;
    cbMarkerDraggable: TCheckBox;
    cbMarkerVisible: TCheckBox;
    cbMarkerClickable: TCheckBox;
    lMarkerContentMode: TLabel;
    cbMarkerContentMode: TComboBox;
    lMarkerCollision: TLabel;
    cbMarkerCollision: TComboBox;
    pcMakerContent: TPageControl;
    tsHTML: TTabSheet;
    mMarkerHtml: TMemo;
    lMarkerHtml: TLabel;
    tsLabel: TTabSheet;
    lMarkerLabelText: TLabel;
    eMarkerLabelText: TEdit;
    lMarkerLabelTextColor: TLabel;
    cbMarkerLabelTextColor: TColorBox;
    cbMarkerLabelBackgroundColor: TColorBox;
    lMarkerLabelBackgroundColor: TLabel;
    cbMarkerLabelBorderColor: TColorBox;
    lMarkerLabelBorderColor: TLabel;
    lMarkerLabelCornerRadius: TLabel;
    eMarkerLabelCornerRadius: TEdit;
    lMarkerLabelFontSize: TLabel;
    eMarkerLabelFontSize: TEdit;
    cbMarkerLabelFontBold: TCheckBox;
    lMarkerLabelPaddingHorizontal: TLabel;
    eMarkerLabelPaddingHorizontal: TEdit;
    eMarkerLabelPaddingVertical: TEdit;
    lMarkerLabelPaddingVertical: TLabel;
    tsPin: TTabSheet;
    lMarkerPinBackgroundColor: TLabel;
    cbMarkerPinBackgroundColor: TColorBox;
    lMarkerPinBorderColor: TLabel;
    cbMarkerPinBorderColor: TColorBox;
    eMarkerPinGlyphText: TEdit;
    lMarkerPinGlyphText: TLabel;
    lMarkerPinGlyphColor: TLabel;
    cbMarkerPinGlyphColor: TColorBox;
    eMarkerPinScale: TEdit;
    lMarkerPinScale: TLabel;
    bUpdate: TButton;
    pcOverlays: TPageControl;
    tsPolyline: TTabSheet;
    tsPolygon: TTabSheet;
    tsRectangle: TTabSheet;
    tsCircle: TTabSheet;
    tsGroundOverlay: TTabSheet;
    tsLayers: TTabSheet;
    lbPolylines: TListBox;
    bAddPolyline: TButton;
    bDeletePolyline: TButton;
    bClearPolylines: TButton;
    bUpdatePolyline: TButton;
    lPolylinePath: TLabel;
    mPolylinePath: TMemo;
    lPolylineStrokeColor: TLabel;
    cbPolylineStrokeColor: TColorBox;
    lPolylineStrokeOpacity: TLabel;
    ePolylineStrokeOpacity: TEdit;
    lPolylineStrokeWeight: TLabel;
    ePolylineStrokeWeight: TEdit;
    cbPolylineClickable: TCheckBox;
    cbPolylineDraggable: TCheckBox;
    cbPolylineEditable: TCheckBox;
    cbPolylineGeodesic: TCheckBox;
    cbPolylineVisible: TCheckBox;
    bZoomToMarker: TButton;
    bZoomToMarkers: TButton;
    bZoomToPolylines: TButton;
    bZoomToPolyline: TButton;
    lbPolygons: TListBox;
    bAddPolygon: TButton;
    bDeletePolygon: TButton;
    bClearPolygons: TButton;
    bUpdatePolygon: TButton;
    bZoomToPolygon: TButton;
    lPolygonPath: TLabel;
    mPolygonPath: TMemo;
    lPolygonStrokeColor: TLabel;
    cbPolygonStrokeColor: TColorBox;
    lPolygonStrokeOpacity: TLabel;
    ePolygonStrokeOpacity: TEdit;
    lPolygonStrokeWeight: TLabel;
    ePolygonStrokeWeight: TEdit;
    lPolygonFillColor: TLabel;
    cbPolygonFillColor: TColorBox;
    lPolygonFillOpacity: TLabel;
    ePolygonFillOpacity: TEdit;
    cbPolygonClickable: TCheckBox;
    cbPolygonDraggable: TCheckBox;
    cbPolygonEditable: TCheckBox;
    cbPolygonGeodesic: TCheckBox;
    cbPolygonVisible: TCheckBox;
    bZoomToPolygons: TButton;
    lbRectangles: TListBox;
    bAddRectangle: TButton;
    bDeleteRectangle: TButton;
    bClearRectangles: TButton;
    bUpdateRectangle: TButton;
    bZoomToRectangle: TButton;
    lRectangleNorth: TLabel;
    eRectangleNorth: TEdit;
    lRectangleSouth: TLabel;
    eRectangleSouth: TEdit;
    lRectangleEast: TLabel;
    eRectangleEast: TEdit;
    lRectangleWest: TLabel;
    eRectangleWest: TEdit;
    lRectangleStrokeColor: TLabel;
    cbRectangleStrokeColor: TColorBox;
    lRectangleStrokeOpacity: TLabel;
    eRectangleStrokeOpacity: TEdit;
    lRectangleStrokeWeight: TLabel;
    eRectangleStrokeWeight: TEdit;
    lRectangleFillColor: TLabel;
    cbRectangleFillColor: TColorBox;
    lRectangleFillOpacity: TLabel;
    eRectangleFillOpacity: TEdit;
    cbRectangleClickable: TCheckBox;
    cbRectangleDraggable: TCheckBox;
    cbRectangleEditable: TCheckBox;
    cbRectangleVisible: TCheckBox;
    bZoomToRectangles: TButton;
    lbCircles: TListBox;
    bAddCircle: TButton;
    bDeleteCircle: TButton;
    bClearCircles: TButton;
    bUpdateCircle: TButton;
    bZoomToCircle: TButton;
    lCircleCenterLat: TLabel;
    eCircleCenterLat: TEdit;
    lCircleCenterLng: TLabel;
    eCircleCenterLng: TEdit;
    lCircleRadius: TLabel;
    eCircleRadius: TEdit;
    lCircleStrokeColor: TLabel;
    cbCircleStrokeColor: TColorBox;
    lCircleStrokeOpacity: TLabel;
    eCircleStrokeOpacity: TEdit;
    lCircleStrokeWeight: TLabel;
    eCircleStrokeWeight: TEdit;
    lCircleFillColor: TLabel;
    cbCircleFillColor: TColorBox;
    lCircleFillOpacity: TLabel;
    eCircleFillOpacity: TEdit;
    cbCircleClickable: TCheckBox;
    cbCircleDraggable: TCheckBox;
    cbCircleEditable: TCheckBox;
    cbCircleVisible: TCheckBox;
    bZoomToCircles: TButton;
    lbGroundOverlays: TListBox;
    bAddGroundOverlay: TButton;
    bDeleteGroundOverlay: TButton;
    bClearGroundOverlays: TButton;
    bUpdateGroundOverlay: TButton;
    bZoomToGroundOverlay: TButton;
    bZoomToGroundOverlays: TButton;
    lGroundOverlayUrl: TLabel;
    eGroundOverlayUrl: TEdit;
    lGroundOverlayNorth: TLabel;
    eGroundOverlayNorth: TEdit;
    lGroundOverlaySouth: TLabel;
    eGroundOverlaySouth: TEdit;
    lGroundOverlayEast: TLabel;
    eGroundOverlayEast: TEdit;
    lGroundOverlayWest: TLabel;
    eGroundOverlayWest: TEdit;
    cbGroundOverlayClickable: TCheckBox;
    cbGroundOverlayVisible: TCheckBox;
    lGroundOverlayOpacity: TLabel;
    eGroundOverlayOpacity: TEdit;
    lTrafficVisible: TLabel;
    cbTrafficVisible: TCheckBox;
    cbTrafficAutoRefresh: TCheckBox;
    cbTransitVisible: TCheckBox;
    cbBicyclingVisible: TCheckBox;
    lKmlUrl: TLabel;
    eKmlUrl: TEdit;
    lKmlZIndex: TLabel;
    eKmlZIndex: TEdit;
    cbKmlVisible: TCheckBox;
    cbKmlClickable: TCheckBox;
    cbKmlPreserveViewport: TCheckBox;
    cbKmlScreenOverlays: TCheckBox;
    cbKmlSuppressInfoWindows: TCheckBox;
    bApplyLayers: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    eRouteFrom: TEdit;
    eRouteTo: TEdit;
    lbRoutes: TListBox;
    cbRouteCloseOthers: TCheckBox;
    lGeomFromLat: TLabel;
    eGeomFromLat: TEdit;
    lGeomFromLng: TLabel;
    eGeomFromLng: TEdit;
    lGeomToLat: TLabel;
    eGeomToLat: TEdit;
    lGeomToLng: TLabel;
    eGeomToLng: TEdit;
    lGeomPointLat: TLabel;
    eGeomPointLat: TEdit;
    lGeomPointLng: TLabel;
    eGeomPointLng: TEdit;
    bComputeGeometry: TButton;
    mGeometryResults: TMemo;
    procedure bActivateClick(Sender: TObject);
    procedure bAddMarkerClick(Sender: TObject);
    procedure bDeleteMarkerClick(Sender: TObject);
    procedure bClearMarkersClick(Sender: TObject);
    procedure bLoadMarkersCsvClick(Sender: TObject);
    procedure bLoadMarkersSampleClick(Sender: TObject);
    procedure lbMarkersClick(Sender: TObject);
    procedure bUpdateClick(Sender: TObject);
    procedure MapMarkersClick(Sender: TObject);
    procedure MapMarkersDrag(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapMarkersDragEnd(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapMarkersDragStart(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapMarkersMouseDown(Sender: TObject);
    procedure MapMarkersMouseEnter(Sender: TObject);
    procedure MapMarkersMouseLeave(Sender: TObject);
    procedure MapMarkersMouseUp(Sender: TObject);
    procedure lbPolylinesClick(Sender: TObject);
    procedure bAddPolylineClick(Sender: TObject);
    procedure bDeletePolylineClick(Sender: TObject);
    procedure bClearPolylinesClick(Sender: TObject);
    procedure bUpdatePolylineClick(Sender: TObject);
    procedure bLoadGpxClick(Sender: TObject);
    procedure bApplyOptionsClick(Sender: TObject);
    procedure MapBoundsChanged(Sender: TObject; ABounds: TGMLatLngBounds);
    procedure MapCenterChanged(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapContextMenu(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure MapDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapDrag(Sender: TObject);
    procedure MapDragEnd(Sender: TObject);
    procedure MapDragStart(Sender: TObject);
    procedure MapHeadingChanged(Sender: TObject; AHeading: Double);
    procedure MapIdle(Sender: TObject);
    procedure MapMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure MapMapReady(Sender: TObject);
    procedure MapMapTypeIdChanged(Sender: TObject; AMapTypeId: TGMMapTypeId);
    procedure MapMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapProjectionChanged(Sender: TObject);
    procedure MapRenderingTypeChanged(Sender: TObject; ARenderingType: TGMRenderingType);
    procedure MapTilesLoaded(Sender: TObject);
    procedure MapTiltChanged(Sender: TObject; ATilt: Integer);
    procedure MapZoomChanged(Sender: TObject; AZoom: Integer);
    procedure bZoomToMarkersClick(Sender: TObject);
    procedure bZoomToMarkerClick(Sender: TObject);
    procedure bZoomToPolylineClick(Sender: TObject);
    procedure bZoomToPolylinesClick(Sender: TObject);
    procedure MapPolylineClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylineContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylineDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylineDrag(Sender: TObject);
    procedure MapPolylineDragEnd(Sender: TObject);
    procedure MapPolylineDragStart(Sender: TObject);
    procedure MapPolylineMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylineMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylineMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylineMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylineMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolylinePathChanged(Sender: TObject);
    procedure MapPolygonClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonDrag(Sender: TObject);
    procedure MapPolygonDragEnd(Sender: TObject);
    procedure MapPolygonDragStart(Sender: TObject);
    procedure MapPolygonMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapPolygonPathChanged(Sender: TObject);
    procedure bZoomToPolygonsClick(Sender: TObject);
    procedure lbPolygonsClick(Sender: TObject);
    procedure bAddPolygonClick(Sender: TObject);
    procedure bDeletePolygonClick(Sender: TObject);
    procedure bClearPolygonsClick(Sender: TObject);
    procedure bUpdatePolygonClick(Sender: TObject);
    procedure bZoomToPolygonClick(Sender: TObject);
    procedure MapRectangleClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleDrag(Sender: TObject);
    procedure MapRectangleDragEnd(Sender: TObject);
    procedure MapRectangleDragStart(Sender: TObject);
    procedure MapRectangleMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapRectangleBoundsChanged(Sender: TObject);
    procedure bZoomToRectanglesClick(Sender: TObject);
    procedure lbRectanglesClick(Sender: TObject);
    procedure bAddRectangleClick(Sender: TObject);
    procedure bDeleteRectangleClick(Sender: TObject);
    procedure bClearRectanglesClick(Sender: TObject);
    procedure bUpdateRectangleClick(Sender: TObject);
    procedure bZoomToRectangleClick(Sender: TObject);
    procedure MapCircleClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleDrag(Sender: TObject);
    procedure MapCircleDragEnd(Sender: TObject);
    procedure MapCircleDragStart(Sender: TObject);
    procedure MapCircleMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapCircleCenterChanged(Sender: TObject);
    procedure MapCircleRadiusChanged(Sender: TObject);
    procedure MapGroundOverlayClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure MapGroundOverlayDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure bZoomToCirclesClick(Sender: TObject);
    procedure lbCirclesClick(Sender: TObject);
    procedure bAddCircleClick(Sender: TObject);
    procedure bDeleteCircleClick(Sender: TObject);
    procedure bClearCirclesClick(Sender: TObject);
    procedure bUpdateCircleClick(Sender: TObject);
    procedure bZoomToCircleClick(Sender: TObject);
    procedure lbGroundOverlaysClick(Sender: TObject);
    procedure bAddGroundOverlayClick(Sender: TObject);
    procedure bDeleteGroundOverlayClick(Sender: TObject);
    procedure bClearGroundOverlaysClick(Sender: TObject);
    procedure bUpdateGroundOverlayClick(Sender: TObject);
    procedure bZoomToGroundOverlayClick(Sender: TObject);
    procedure bZoomToGroundOverlaysClick(Sender: TObject);
    procedure bApplyLayersClick(Sender: TObject);
    procedure bApplyRouteClick(Sender: TObject);
    procedure lbRoutesClick(Sender: TObject);
    procedure cbRouteCloseOthersClick(Sender: TObject);
    procedure bComputeGeometryClick(Sender: TObject);
    procedure RouteCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
    procedure RefreshRouteList;
  private
    FIsDraggingPolyline: Boolean;
    FIsDraggingPolygon: Boolean;
    FIsDraggingRectangle: Boolean;
    FIsDraggingCircle: Boolean;
    FCurrentMarkerForInfoWindow: TGMVclMarkerItem;
    FCurrentInfoWindowForMarker: TGMVclInfoWindowItem;
    procedure Log(const AText: string);
    procedure UpdateStatus(const AText: string);
    procedure InitializeDefaults;
    function Checks: Boolean;
    procedure ApplyOptions;
    procedure LoadMarkerToUI(AMarker: TGMVclMarkerItem);
    procedure LoadUIToMarker(AMarker: TGMVclMarkerItem);
    procedure BindMarkerEvents(AMarker: TGMVclMarkerItem);
    procedure RefreshMarkerList;
    procedure RefreshPolylineList;
    procedure LoadPolylineToUI(APolyline: TGMVclPolylineItem);
    procedure LoadUIToPolyline(APolyline: TGMVclPolylineItem);
    procedure BindPolylineEvents(APolyline: TGMVclPolylineItem);
    procedure ParseGpxTrack(const AGpxContent: string; APath: TGMPolylinePath);
    procedure RefreshPolygonList;
    procedure LoadPolygonToUI(APolygon: TGMVclPolygonItem);
    procedure LoadUIToPolygon(APolygon: TGMVclPolygonItem);
    procedure BindPolygonEvents(APolygon: TGMVclPolygonItem);
    procedure RefreshRectangleList;
    procedure LoadRectangleToUI(ARectangle: TGMVclRectangleItem);
    procedure LoadUIToRectangle(ARectangle: TGMVclRectangleItem);
    procedure BindRectangleEvents(ARectangle: TGMVclRectangleItem);
    procedure RefreshCircleList;
    procedure LoadCircleToUI(ACircle: TGMVclCircleItem);
    procedure LoadUIToCircle(ACircle: TGMVclCircleItem);
    procedure BindCircleEvents(ACircle: TGMVclCircleItem);
    procedure BindGroundOverlayEvents(AGroundOverlay: TGMGroundOverlayItem);
    procedure RefreshGroundOverlayList;
    procedure LoadGroundOverlayToUI(AGroundOverlay: TGMGroundOverlayItem);
    procedure LoadUIToGroundOverlay(AGroundOverlay: TGMGroundOverlayItem);
    procedure ApplyLayers;
    procedure ShowMarkerInfoWindow(AMarker: TGMVclMarkerItem);
    procedure GeoCodeCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
    procedure ElevationCompleted(Sender: TObject; const AResponse: TGMElevationResponse);
  public
    constructor Create(AOwner: TComponent); override;
  end;

const
  COORD_TOLERANCE = 0.000001;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

procedure TMainFrm.bActivateClick(Sender: TObject);
begin
  Map.APIKey := Trim(eAPIKey.Text);
  Map.Options.MapId := Trim(eMapId.Text);
  if not Checks then
    Exit;

  ApplyOptions;

  if not Map.Active then
  begin
    Map.Active := True;
    Log('Map activation requested.');
    if Map.APIKey = '' then
      Log('Loading Google Maps API without API key.')
    else
      Log('Loading Google Maps API with API key.');
    bActivate.Caption := 'Deactivate';
    UpdateStatus('Loading map...');
  end
  else
  begin
    Map.Active := False;
    EdgeBrowser1.Navigate('about:blank');
    bActivate.Caption := 'Activate';
    Log('Map is inactive.');
    UpdateStatus('Map inactive...');
  end;
end;

procedure TMainFrm.ApplyOptions;
begin
  // General
  Map.Options.BackgroundColor := cbBackGroundColor.Selected;
  Map.Options.MapTypeId := TGMMapTypeId(cbMapTypeId.ItemIndex);
  Map.Options.ColorScheme := TGMColorScheme(cbColorScheme.ItemIndex);
  Map.Options.RenderingType := TGMRenderingType(cbRenderType.ItemIndex);
  Map.Options.GestureHandling := TGMGestureHandling(cbGestureHandling.ItemIndex);

  // Heading i Tilt
  if Trim(eHeading.Text) <> '' then
    Map.Options.Heading := StrToFloatDef(eHeading.Text, 0);
  if Trim(eTilt.Text) <> '' then
    Map.Options.Tilt := StrToIntDef(eTilt.Text, 0);

  // Min/Max Zoom
  if Trim(eMinZoom.Text) <> '' then
    Map.Options.MinZoom := StrToIntDef(eMinZoom.Text, 0);
  if Trim(eMaxZoom.Text) <> '' then
    Map.Options.MaxZoom := StrToIntDef(eMaxZoom.Text, 22);

  // Fractional Zoom
  Map.Options.IsFractionalZoomEnabled := cbIsFractionalZoomEnabled.Checked;

  // Control Size
  if Trim(eControlSize.Text) <> '' then
    Map.Options.ControlSize := StrToIntDef(eControlSize.Text, 0);

  // Map Type Ids
  Map.Options.MapTypeControlOptions.MapTypeIds := [];
  if clbMapTypeIds.Checked[0] then
    Map.Options.MapTypeControlOptions.MapTypeIds := Map.Options.MapTypeControlOptions.MapTypeIds + [mtRoadmap];
  if clbMapTypeIds.Checked[1] then
    Map.Options.MapTypeControlOptions.MapTypeIds := Map.Options.MapTypeControlOptions.MapTypeIds + [mtSatellite];
  if clbMapTypeIds.Checked[2] then
    Map.Options.MapTypeControlOptions.MapTypeIds := Map.Options.MapTypeControlOptions.MapTypeIds + [mtHybrid];
  if clbMapTypeIds.Checked[3] then
    Map.Options.MapTypeControlOptions.MapTypeIds := Map.Options.MapTypeControlOptions.MapTypeIds + [mtTerrain];

  // Controls
  Map.Options.ZoomControl := cbZoomControl.Checked;
  Map.Options.ZoomControlOptions.Position := TGMControlPosition(cbZoomPosition.ItemIndex);

  Map.Options.MapTypeControl := cbMapTypeControl.Checked;
  Map.Options.MapTypeControlOptions.Position := TGMControlPosition(cbMapTypePosition.ItemIndex);
  Map.Options.MapTypeControlOptions.Style := TGMMapTypeControlStyle(cbMapTypeStyle.ItemIndex);

  Map.Options.ScaleControl := cbScaleControl.Checked;
  Map.Options.ScaleControlOptions.Style := TGMScaleControlStyle(cbScaleStyle.ItemIndex);

  Map.Options.RotateControl := cbRotateControl.Checked;
  Map.Options.RotateControlOptions.Position := TGMControlPosition(cbRotatePosition.ItemIndex);

  Map.Options.StreetViewControl := cbStreetViewControl.Checked;
  Map.Options.StreetViewControlOptions.Position := TGMControlPosition(cbStreetViewPosition.ItemIndex);

  Map.Options.FullscreenControl := cbFullscreenControl.Checked;
  Map.Options.FullscreenControlOptions.Position := TGMControlPosition(cbFullscreenPosition.ItemIndex);

  Map.Options.CameraControl := cbCameraControl.Checked;
  Map.Options.CameraControlOptions.Position := TGMControlPosition(cbCameraPosition.ItemIndex);

  // Interaction
  Map.Options.DisableDoubleClickZoom := cbDisableDoubleClickZoom.Checked;
  Map.Options.Scrollwheel := cbScrollwheel.Checked;
  Map.Options.KeyboardShortcuts := cbKeyboardShortcuts.Checked;
  Map.Options.TiltInteractionEnabled := cbTiltInteractionEnabled.Checked;
  Map.Options.HeadingInteractionEnabled := cbHeadingInteractionEnabled.Checked;

  // Focus
  Map.Options.ClickableIcons := cbClickableIcons.Checked;
  Map.Options.DisableDefaultUI := cbDisableDefaultUI.Checked;
  Map.Options.NoClear := cbNoClear.Checked;
end;

procedure TMainFrm.bApplyOptionsClick(Sender: TObject);
begin
  if not Checks then
    Exit;

  ApplyOptions;
end;

procedure TMainFrm.bApplyLayersClick(Sender: TObject);
begin
  ApplyLayers;
  Log('Layers applied.');
end;

function TMainFrm.Checks: Boolean;
var
  latitude: Double;
  longitude: Double;
  zoomLevel: Integer;
begin
  Result := False;
  if not TryStrToFloat(Trim(eLat.Text), latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(eLng.Text), longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  if not TryStrToInt(Trim(eZoom.Text), zoomLevel) then
  begin
    Log('Invalid zoom value.');
    Exit;
  end;

  Map.Options.Zoom := zoomLevel;
  Map.Options.Center.Lat := latitude;
  Map.Options.Center.Lng := longitude;

  Result := True;
end;

constructor TMainFrm.Create(AOwner: TComponent);
begin
  inherited;

  pcOptions.ActivePage := tsMap;
  InitializeDefaults;
  RefreshMarkerList;
  RefreshPolylineList;
  RefreshGroundOverlayList;
end;

procedure TMainFrm.InitializeDefaults;
begin
  // API i Map ID
  eAPIKey.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  eMapId.Text := GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID');
  if eMapId.Text = '' then
    eMapId.Text := 'DEMO_MAP_ID';

  // Center i Zoom
  eLat.Text := '41.3874';
  eLng.Text := '2.1686';
  eZoom.Text := '12';
  eHeading.Text := '';
  eTilt.Text := '';

  // General
  cbMapTypeId.ItemIndex := 0;
  cbColorScheme.ItemIndex := 0;
  cbRenderType.ItemIndex := 0;
  cbGestureHandling.ItemIndex := 0;
  cbBackGroundColor.Selected := clSilver;

  // Map Type Ids
  clbMapTypeIds.CheckAll(cbChecked);

  // Controls
  cbZoomControl.Checked := True;
  cbZoomPosition.ItemIndex := 0;
  cbMapTypeControl.Checked := True;
  cbMapTypePosition.ItemIndex := 0;
  cbMapTypeStyle.ItemIndex := 0;
  cbScaleControl.Checked := False;
  cbRotateControl.Checked := False;
  cbStreetViewControl.Checked := True;
  cbStreetViewPosition.ItemIndex := 0;
  cbFullscreenControl.Checked := False;
  cbFullscreenPosition.ItemIndex := 0;
  cbCameraControl.Checked := False;

  // Zoom/Min/Max
  eMinZoom.Text := '0';
  eMaxZoom.Text := '22';

  // Interaction
  cbDisableDoubleClickZoom.Checked := False;
  cbScrollwheel.Checked := True;
  cbKeyboardShortcuts.Checked := True;
  cbTiltInteractionEnabled.Checked := True;
  cbHeadingInteractionEnabled.Checked := True;
  cbIsFractionalZoomEnabled.Checked := False;

  // Focus
  cbClickableIcons.Checked := True;
  cbDisableDefaultUI.Checked := False;
  cbNoClear.Checked := False;

  // Markers
  eMarkerLat.Text := '41.3874';
  eMarkerLng.Text := '2.1686';
  cbMarkerDraggable.Checked := False;
  cbMarkerVisible.Checked := True;
  cbMarkerClickable.Checked := True;
  cbMarkerContentMode.ItemIndex := 0;
  cbMarkerCollision.ItemIndex := 0;

  // Ground overlays
  eGroundOverlayUrl.Text := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + '..\..\..\..\..\resources\GMMap.bmp');
  eGroundOverlayNorth.Text := '41.42';
  eGroundOverlaySouth.Text := '41.35';
  eGroundOverlayEast.Text := '2.22';
  eGroundOverlayWest.Text := '2.12';
  cbGroundOverlayClickable.Checked := True;
  cbGroundOverlayVisible.Checked := True;
  eGroundOverlayOpacity.Text := '0.75';

  // Layers
  cbTrafficVisible.Checked := False;
  cbTrafficAutoRefresh.Checked := True;
  cbTransitVisible.Checked := False;
  cbBicyclingVisible.Checked := False;
  cbKmlVisible.Checked := False;
  cbKmlClickable.Checked := True;
  cbKmlPreserveViewport.Checked := False;
  cbKmlScreenOverlays.Checked := True;
  cbKmlSuppressInfoWindows.Checked := False;
  eKmlUrl.Text := '';
  eKmlZIndex.Text := '0';

  UpdateStatus('Defaults loaded.');
end;

procedure TMainFrm.ApplyLayers;
begin
  { The button applies the current UI snapshot in one go so the map does not
    receive half-edited layer state while the user is still typing. }
  Map.Layers.Traffic.AutoRefresh := cbTrafficAutoRefresh.Checked;
  Map.Layers.Traffic.Visible := cbTrafficVisible.Checked;
  Map.Layers.Transit.Visible := cbTransitVisible.Checked;
  Map.Layers.Bicycling.Visible := cbBicyclingVisible.Checked;
  Map.Layers.Kml.Visible := cbKmlVisible.Checked;
  Map.Layers.Kml.Clickable := cbKmlClickable.Checked;
  Map.Layers.Kml.PreserveViewport := cbKmlPreserveViewport.Checked;
  Map.Layers.Kml.ScreenOverlays := cbKmlScreenOverlays.Checked;
  Map.Layers.Kml.SuppressInfoWindows := cbKmlSuppressInfoWindows.Checked;
  Map.Layers.Kml.Url := Trim(eKmlUrl.Text);
  Map.Layers.Kml.ZIndex := StrToIntDef(Trim(eKmlZIndex.Text), 0);
end;

procedure TMainFrm.Log(const AText: string);
begin
  while mLog.Lines.Count >= 500 do
    mLog.Lines.Delete(0);

  mLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainFrm.MapBoundsChanged(Sender: TObject; ABounds: TGMLatLngBounds);
begin
  Log(Format('BoundsChanged: S(%.6f) N(%.6f) E(%.6f) W(%.6f)', [ABounds.South, ABounds.North, ABounds.East, ABounds.West]));
end;

procedure TMainFrm.MapCenterChanged(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('CenterChanged: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
  eLat.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  eLng.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);
end;

procedure TMainFrm.MapContextMenu(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
begin
  Log(Format('ContextMenu: %.6f,%.6f PlaceId:%s', [ALatLng.Lat, ALatLng.Lng, APlaceId]));
end;

procedure TMainFrm.MapDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('DblClick: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapDrag(Sender: TObject);
begin
  Log('Drag');
end;

procedure TMainFrm.MapDragEnd(Sender: TObject);
begin
  Log('DragEnd');
end;

procedure TMainFrm.MapDragStart(Sender: TObject);
begin
  Log('DragStart');
end;

procedure TMainFrm.MapHeadingChanged(Sender: TObject; AHeading: Double);
begin
  Log(Format('HeadingChanged: %.2f', [AHeading]));
  eHeading.Text := FloatToStr(AHeading, TFormatSettings.Invariant);
end;

procedure TMainFrm.MapIdle(Sender: TObject);
begin
  Log('Idle');
end;

procedure TMainFrm.MapMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
var
  Marker: TGMVclMarkerItem;
begin
  Log(Format('MapClick: %.6f,%.6f PlaceId:%s', [ALatLng.Lat, ALatLng.Lng, APlaceId]));

  Marker := Map.Markers.Add;
  Marker.Options.Position.Lat := ALatLng.Lat;
  Marker.Options.Position.Lng := ALatLng.Lng;
  Marker.Options.Title := 'Marker ' + IntToStr(Map.Markers.Count);
  BindMarkerEvents(Marker);
  RefreshMarkerList;
  lbMarkers.ItemIndex := lbMarkers.Items.IndexOfObject(Marker);
  LoadMarkerToUI(Marker);
end;

procedure TMainFrm.MapMapReady(Sender: TObject);
var
  I: Integer;
  Marker: TGMVclMarkerItem;
  Polyline: TGMVclPolylineItem;
  Polygon: TGMVclPolygonItem;
  Rectangle: TGMVclRectangleItem;
  Circle: TGMVclCircleItem;
begin
  Log('MapReady');
  UpdateStatus('Map loaded.');

  Log('Assigning GeoCode.OnCompleted...');
  Map.GeoCode.OnCompleted := GeoCodeCompleted;

  Log('Assigning Elevations.OnCompleted...');
  Map.Elevations.OnCompleted := ElevationCompleted;

  Log('Assigning Routes.OnCompleted...');
  Map.Routes.OnCompleted := RouteCompleted;
  Map.Routes.CloseOthersBeforeVisible := cbRouteCloseOthers.Checked;
  cbRouteCloseOthers.Checked := Map.Routes.CloseOthersBeforeVisible;

  for I := 0 to Map.Markers.Count - 1 do
  begin
    Marker := Map.Markers[I];
    BindMarkerEvents(Marker);
  end;

  for I := 0 to Map.Polylines.Count - 1 do
  begin
    Polyline := Map.Polylines[I];
    BindPolylineEvents(Polyline);
  end;

  for I := 0 to Map.Polygons.Count - 1 do
  begin
    Polygon := Map.Polygons[I];
    BindPolygonEvents(Polygon);
  end;

  for I := 0 to Map.Rectangles.Count - 1 do
  begin
    Rectangle := Map.Rectangles[I];
    BindRectangleEvents(Rectangle);
  end;

  for I := 0 to Map.Circles.Count - 1 do
  begin
    Circle := Map.Circles[I];
    BindCircleEvents(Circle);
  end;

  for I := 0 to Map.GroundOverlays.Count - 1 do
    BindGroundOverlayEvents(Map.GroundOverlays[I]);

  Map.GeoCode.OnCompleted := GeoCodeCompleted;
  Map.Elevations.OnCompleted := ElevationCompleted;

  RefreshMarkerList;
  RefreshPolylineList;
  RefreshPolygonList;
  RefreshRectangleList;
  RefreshCircleList;
  RefreshGroundOverlayList;
end;

procedure TMainFrm.MapMapTypeIdChanged(Sender: TObject; AMapTypeId: TGMMapTypeId);
var
  S: string;
begin
  case AMapTypeId of
    mtRoadmap:
      S := 'roadmap';
    mtSatellite:
      S := 'satellite';
    mtHybrid:
      S := 'hybrid';
    mtTerrain:
      S := 'terrain';
  else
    S := 'unknown';
  end;
  Log('MapTypeIdChanged: ' + S);
  cbMapTypeId.ItemIndex := Ord(AMapTypeId);
end;

procedure TMainFrm.MapMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('MouseMove: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('MouseOut: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('MouseOver: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapProjectionChanged(Sender: TObject);
begin
  Log('ProjectionChanged');
end;

procedure TMainFrm.MapRenderingTypeChanged(Sender: TObject; ARenderingType: TGMRenderingType);
var
  S: string;
begin
  case ARenderingType of
    rtRaster:
      S := 'raster';
    rtVector:
      S := 'vector';
  else
    S := 'raster';
  end;
  Log('RenderingTypeChanged: ' + S);
  cbRenderType.ItemIndex := Ord(ARenderingType);
end;

procedure TMainFrm.MapTilesLoaded(Sender: TObject);
begin
  Log('TilesLoaded');
end;

procedure TMainFrm.MapTiltChanged(Sender: TObject; ATilt: Integer);
begin
  Log(Format('TiltChanged: %d', [ATilt]));
  eTilt.Text := IntToStr(ATilt);
end;

procedure TMainFrm.MapZoomChanged(Sender: TObject; AZoom: Integer);
begin
  Log(Format('ZoomChanged: %d', [AZoom]));
  eZoom.Text := IntToStr(AZoom);
end;

procedure TMainFrm.UpdateStatus(const AText: string);
begin
  lStatus.Caption := AText;
end;

procedure TMainFrm.LoadMarkerToUI(AMarker: TGMVclMarkerItem);
begin
  if not Assigned(AMarker) then
    Exit;

  cbMarkerClickable.Checked := AMarker.Options.Clickable;
  cbMarkerCollision.ItemIndex := Ord(AMarker.Options.CollisionBehavior);
  cbMarkerContentMode.ItemIndex := Ord(AMarker.Options.ContentMode);
  cbMarkerDraggable.Checked := AMarker.Options.Draggable;
  eMarkerTitle.Text := AMarker.Options.Title;
  cbMarkerVisible.Checked := AMarker.Options.Visible;

  eMarkerLat.Text := FloatToStr(AMarker.Options.Position.Lat, TFormatSettings.Invariant);
  eMarkerLng.Text := FloatToStr(AMarker.Options.Position.Lng, TFormatSettings.Invariant);

  mMarkerHtml.Lines.Text := AMarker.Options.HtmlOptions.Html;

  cbMarkerLabelBackgroundColor.Selected := AMarker.Options.LabelOptions.BackgroundColor;
  cbMarkerLabelBorderColor.Selected := AMarker.Options.LabelOptions.BorderColor;
  eMarkerLabelCornerRadius.Text := IntToStr(AMarker.Options.LabelOptions.CornerRadius);
  cbMarkerLabelFontBold.Checked := AMarker.Options.LabelOptions.FontBold;
  eMarkerLabelFontSize.Text := IntToStr(AMarker.Options.LabelOptions.FontSize);
  eMarkerLabelPaddingHorizontal.Text := IntToStr(AMarker.Options.LabelOptions.PaddingHorizontal);
  eMarkerLabelPaddingVertical.Text := IntToStr(AMarker.Options.LabelOptions.PaddingVertical);
  eMarkerLabelText.Text := AMarker.Options.LabelOptions.Text;
  cbMarkerLabelTextColor.Selected := AMarker.Options.LabelOptions.TextColor;

  cbMarkerPinBackgroundColor.Selected := AMarker.Options.PinOptions.BackgroundColor;
  cbMarkerPinBorderColor.Selected := AMarker.Options.PinOptions.BorderColor;
  cbMarkerPinGlyphColor.Selected := AMarker.Options.PinOptions.GlyphColor;
  eMarkerPinGlyphText.Text := AMarker.Options.PinOptions.GlyphText;
  eMarkerPinScale.Text := FloatToStr(AMarker.Options.PinOptions.Scale, TFormatSettings.Invariant);
end;

procedure TMainFrm.RefreshMarkerList;
var
  I: Integer;
  Marker: TGMVclMarkerItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if lbMarkers.ItemIndex >= 0 then
    SelectedObject := lbMarkers.Items.Objects[lbMarkers.ItemIndex];

  lbMarkers.Items.BeginUpdate;
  try
    lbMarkers.Clear;
    for I := 0 to Map.Markers.Count - 1 do
    begin
      Marker := Map.Markers[I];
      lbMarkers.Items.AddObject(IfThen(Marker.Options.Title <> '', Marker.Options.Title, Format('Marker %d', [I])), Marker);
    end;
  finally
    lbMarkers.Items.EndUpdate;
  end;

  if Assigned(SelectedObject) then
    lbMarkers.ItemIndex := lbMarkers.Items.IndexOfObject(SelectedObject)
  else if lbMarkers.Items.Count > 0 then
    lbMarkers.ItemIndex := 0;
end;

procedure TMainFrm.LoadUIToMarker(AMarker: TGMVclMarkerItem);
var
  Lat, Lng: Double;
  TmpI: Integer;
begin
  if not Assigned(AMarker) then
    Exit;

  AMarker.Options.BeginUpdate;
  try
    AMarker.Options.Clickable := cbMarkerClickable.Checked;
    AMarker.Options.CollisionBehavior := TGMCollisionBehavior(cbMarkerCollision.ItemIndex);
    AMarker.Options.Draggable := cbMarkerDraggable.Checked;
    AMarker.Options.Title := eMarkerTitle.Text;
    AMarker.Options.Visible := cbMarkerVisible.Checked;

    if TryStrToFloat(Trim(eMarkerLat.Text), Lat, TFormatSettings.Invariant) then
      AMarker.Options.Position.Lat := Lat;
    if TryStrToFloat(Trim(eMarkerLng.Text), Lng, TFormatSettings.Invariant) then
      AMarker.Options.Position.Lng := Lng;

    AMarker.Options.HtmlOptions.Html := mMarkerHtml.Lines.Text;

    AMarker.Options.LabelOptions.BackgroundColor := cbMarkerLabelBackgroundColor.Selected;
    AMarker.Options.LabelOptions.BorderColor := cbMarkerLabelBorderColor.Selected;
    if TryStrToInt(Trim(eMarkerLabelCornerRadius.Text), TmpI) then
      AMarker.Options.LabelOptions.CornerRadius := TmpI;
    AMarker.Options.LabelOptions.FontBold := cbMarkerLabelFontBold.Checked;
    if TryStrToInt(Trim(eMarkerLabelFontSize.Text), TmpI) then
      AMarker.Options.LabelOptions.FontSize := TmpI;
    if TryStrToInt(Trim(eMarkerLabelPaddingHorizontal.Text), TmpI) then
      AMarker.Options.LabelOptions.PaddingHorizontal := TmpI;
    if TryStrToInt(Trim(eMarkerLabelPaddingVertical.Text), TmpI) then
      AMarker.Options.LabelOptions.PaddingVertical := TmpI;
    AMarker.Options.LabelOptions.Text := eMarkerLabelText.Text;
    AMarker.Options.LabelOptions.TextColor := cbMarkerLabelTextColor.Selected;

    AMarker.Options.PinOptions.BackgroundColor := cbMarkerPinBackgroundColor.Selected;
    AMarker.Options.PinOptions.BorderColor := cbMarkerPinBorderColor.Selected;
    AMarker.Options.PinOptions.GlyphColor := cbMarkerPinGlyphColor.Selected;
    AMarker.Options.PinOptions.GlyphText := eMarkerPinGlyphText.Text;
    AMarker.Options.PinOptions.Scale := StrToFloatDef(eMarkerPinScale.Text, 1, TFormatSettings.Invariant);
    AMarker.Options.ContentMode := TGMMarkerContentMode(cbMarkerContentMode.ItemIndex);
  finally
    AMarker.Options.EndUpdate;
  end;
end;

procedure TMainFrm.bAddMarkerClick(Sender: TObject);
var
  Marker: TGMVclMarkerItem;
begin
  Marker := Map.Markers.Add;
  try
    LoadUIToMarker(Marker);
    BindMarkerEvents(Marker);

    RefreshMarkerList;
    lbMarkers.ItemIndex := lbMarkers.Items.IndexOfObject(Marker);
    Log('Marker added: ' + Marker.Options.Title);
  except
    Marker.Free;
    raise;
  end;
end;

procedure TMainFrm.bDeleteMarkerClick(Sender: TObject);
var
  Marker: TGMVclMarkerItem;
  Idx: Integer;
begin
  Idx := lbMarkers.ItemIndex;
  if Idx < 0 then
    Exit;

  Marker := TGMVclMarkerItem(lbMarkers.Items.Objects[Idx]);
  if Assigned(Marker) then
    Map.Markers.Delete(Marker.Index);
  RefreshMarkerList;
  Log('Marker deleted');
end;

procedure TMainFrm.bUpdateClick(Sender: TObject);
var
  Idx: Integer;
  Marker: TGMVclMarkerItem;
begin
  Idx := lbMarkers.ItemIndex;
  if Idx < 0 then
  begin
    Log('No marker selected');
    Exit;
  end;

  Marker := TGMVclMarkerItem(lbMarkers.Items.Objects[Idx]);
  if Assigned(Marker) then
  begin
    LoadUIToMarker(Marker);
    RefreshMarkerList;
    lbMarkers.ItemIndex := lbMarkers.Items.IndexOfObject(Marker);
    Log('Marker updated: ' + Marker.Options.Title);
  end;
end;

procedure TMainFrm.bClearMarkersClick(Sender: TObject);
begin
  Map.Markers.Clear;
  RefreshMarkerList;
  Log('All markers cleared');
end;

procedure TMainFrm.bLoadMarkersCsvClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  CsvText: TStringList;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter := 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*';
    OpenDialog.Title := 'Load markers from CSV';
    if not OpenDialog.Execute then
      Exit;

    CsvText := TStringList.Create;
    try
      CsvText.LoadFromFile(OpenDialog.FileName);
      Map.Markers.LoadFromCSV(CsvText.Text, 'lat', 'lng', 'title', 'visible');

      for var I := 0 to Map.Markers.Count - 1 do
        BindMarkerEvents(Map.Markers[I]);

      RefreshMarkerList;
      Log(Format('Markers loaded from CSV: %d', [Map.Markers.Count]));
    finally
      CsvText.Free;
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure TMainFrm.bLoadMarkersSampleClick(Sender: TObject);
var
  CsvText: TStringList;
begin
  CsvText := TStringList.Create;
  try
    CsvText.Text := 'lat,lng,title,visible' + sLineBreak + '41.3874,2.1686,Marker A,true' + sLineBreak + '41.3892,2.1701,Marker B,true' + sLineBreak + '41.3857,2.1669,Marker C,false';

    Map.Markers.LoadFromCSV(CsvText.Text, 'lat', 'lng', 'title', 'visible');

    for var I := 0 to Map.Markers.Count - 1 do
      BindMarkerEvents(Map.Markers[I]);

    RefreshMarkerList;
    Log(Format('Sample markers loaded: %d', [Map.Markers.Count]));
  finally
    CsvText.Free;
  end;
end;

procedure TMainFrm.lbMarkersClick(Sender: TObject);
var
  Idx: Integer;
  Marker: TGMVclMarkerItem;
begin
  Idx := lbMarkers.ItemIndex;
  if Idx < 0 then
    Exit;

  Marker := TGMVclMarkerItem(lbMarkers.Items.Objects[Idx]);
  if Assigned(Marker) then
    LoadMarkerToUI(Marker);
end;

procedure TMainFrm.BindMarkerEvents(AMarker: TGMVclMarkerItem);
begin
  if not Assigned(AMarker) then
    Exit;

  AMarker.OnClick := MapMarkersClick;
  AMarker.OnDragStart := MapMarkersDragStart;
  AMarker.OnDrag := MapMarkersDrag;
  AMarker.OnDragEnd := MapMarkersDragEnd;
  AMarker.OnMouseDown := MapMarkersMouseDown;
  AMarker.OnMouseEnter := MapMarkersMouseEnter;
  AMarker.OnMouseLeave := MapMarkersMouseLeave;
  AMarker.OnMouseUp := MapMarkersMouseUp;
end;

procedure TMainFrm.MapMarkersClick(Sender: TObject);
var
  Marker: TGMVclMarkerItem;
  Idx: Integer;
begin
  Log('Marker Click: ' + TGMVclMarkerItem(Sender).Options.Title);
  Marker := TGMVclMarkerItem(Sender);
  Idx := lbMarkers.Items.IndexOfObject(Marker);
  if Idx >= 0 then
  begin
    lbMarkers.ItemIndex := Idx;
    LoadMarkerToUI(Marker);
  end;
  ShowMarkerInfoWindow(Marker);
end;

procedure TMainFrm.MapMarkersDrag(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Marker Drag: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapMarkersDragEnd(Sender: TObject; ALatLng: TGMLibLatLng);
var
  Marker: TGMVclMarkerItem;
  Idx: Integer;
begin
  Log(Format('Marker DragEnd: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
  Marker := TGMVclMarkerItem(Sender);
  Marker.Options.Position.Lat := ALatLng.Lat;
  Marker.Options.Position.Lng := ALatLng.Lng;
  eMarkerLat.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  eMarkerLng.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);
  Idx := lbMarkers.Items.IndexOfObject(Marker);
  if Idx >= 0 then
    lbMarkers.ItemIndex := Idx;
end;

procedure TMainFrm.MapMarkersDragStart(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Marker DragStart: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapMarkersMouseDown(Sender: TObject);
begin
  Log('Marker MouseDown');
end;

procedure TMainFrm.MapMarkersMouseEnter(Sender: TObject);
begin
  Log('Marker MouseEnter');
end;

procedure TMainFrm.MapMarkersMouseLeave(Sender: TObject);
begin
  Log('Marker MouseLeave');
end;

procedure TMainFrm.MapMarkersMouseUp(Sender: TObject);
begin
  Log('Marker MouseUp');
end;

procedure TMainFrm.LoadPolylineToUI(APolyline: TGMVclPolylineItem);
var
  I: Integer;
  PathStr: string;
begin
  if not Assigned(APolyline) then
    Exit;

  mPolylinePath.Lines.Clear;
  for I := 0 to APolyline.Options.Path.Count - 1 do
  begin
    PathStr := Format('%s,%s', [FloatToStr(APolyline.Options.Path[I].Lat, TFormatSettings.Invariant), FloatToStr(APolyline.Options.Path[I].Lng, TFormatSettings.Invariant)]);
    mPolylinePath.Lines.Add(PathStr);
  end;

  cbPolylineStrokeColor.Selected := APolyline.Options.StrokeColor;
  ePolylineStrokeOpacity.Text := FloatToStr(APolyline.Options.StrokeOpacity, TFormatSettings.Invariant);
  ePolylineStrokeWeight.Text := IntToStr(APolyline.Options.StrokeWeight);

  cbPolylineClickable.Checked := APolyline.Options.Clickable;
  cbPolylineDraggable.Checked := APolyline.Options.Draggable;
  cbPolylineEditable.Checked := APolyline.Options.Editable;
  cbPolylineGeodesic.Checked := APolyline.Options.Geodesic;
  cbPolylineVisible.Checked := APolyline.Options.Visible;
end;

procedure TMainFrm.RefreshPolylineList;
var
  I: Integer;
  Polyline: TGMVclPolylineItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if lbPolylines.ItemIndex >= 0 then
    SelectedObject := lbPolylines.Items.Objects[lbPolylines.ItemIndex];

  lbPolylines.Items.BeginUpdate;
  try
    lbPolylines.Clear;
    for I := 0 to Map.Polylines.Count - 1 do
    begin
      Polyline := Map.Polylines[I];
      lbPolylines.Items.AddObject(Format('Polyline %d', [I]), Polyline);
    end;
  finally
    lbPolylines.Items.EndUpdate;
  end;

  if Assigned(SelectedObject) then
    lbPolylines.ItemIndex := lbPolylines.Items.IndexOfObject(SelectedObject)
  else if lbPolylines.Items.Count > 0 then
    lbPolylines.ItemIndex := 0;
end;

procedure TMainFrm.LoadUIToPolyline(APolyline: TGMVclPolylineItem);
var
  Lat, Lng: Double;
begin
  if not Assigned(APolyline) then
    Exit;

  APolyline.Options.Path.Clear;
  APolyline.Options.Path.BeginUpdate;
  for var I := 0 to mPolylinePath.Lines.Count - 1 do
  begin
    var Line := Trim(mPolylinePath.Lines[I]);
    if Line = '' then
      Continue;

    var lPos := Pos(',', Line);
    var LatStr := Copy(Line, 1, lPos - 1);
    var LngStr := Copy(Line, lPos + 1, Length(Line));

    if TryStrToFloat(LatStr, Lat, TFormatSettings.Invariant) and TryStrToFloat(LngStr, Lng, TFormatSettings.Invariant) then
      APolyline.Options.Path.Add(Lat, Lng);
  end;
  APolyline.Options.Path.EndUpdate;

  APolyline.Options.StrokeColor := cbPolylineStrokeColor.Selected;
  APolyline.Options.StrokeOpacity := StrToFloatDef(ePolylineStrokeOpacity.Text, 1, TFormatSettings.Invariant);
  APolyline.Options.StrokeWeight := StrToIntDef(ePolylineStrokeWeight.Text, 2);

  APolyline.Options.Clickable := cbPolylineClickable.Checked;
  APolyline.Options.Draggable := cbPolylineDraggable.Checked;
  APolyline.Options.Editable := cbPolylineEditable.Checked;
  APolyline.Options.Geodesic := cbPolylineGeodesic.Checked;
  APolyline.Options.Visible := cbPolylineVisible.Checked;
end;

procedure TMainFrm.lbPolylinesClick(Sender: TObject);
var
  Idx: Integer;
  Polyline: TGMVclPolylineItem;
begin
  Idx := lbPolylines.ItemIndex;
  if Idx < 0 then
    Exit;

  Polyline := TGMVclPolylineItem(lbPolylines.Items.Objects[Idx]);
  if Assigned(Polyline) then
    LoadPolylineToUI(Polyline);
end;

procedure TMainFrm.bAddPolylineClick(Sender: TObject);
var
  Polyline: TGMVclPolylineItem;
begin
  Polyline := Map.Polylines.Add;
  LoadUIToPolyline(Polyline);
  BindPolylineEvents(Polyline);

  RefreshPolylineList;
  lbPolylines.ItemIndex := lbPolylines.Items.IndexOfObject(Polyline);
  Log('Polyline added');
end;

procedure TMainFrm.bDeletePolylineClick(Sender: TObject);
var
  Polyline: TGMVclPolylineItem;
  Idx: Integer;
begin
  Idx := lbPolylines.ItemIndex;
  if Idx < 0 then
    Exit;

  Polyline := TGMVclPolylineItem(lbPolylines.Items.Objects[Idx]);
  if Assigned(Polyline) then
    Map.Polylines.Delete(Polyline.Index);
  RefreshPolylineList;
  Log('Polyline deleted');
end;

procedure TMainFrm.bClearPolylinesClick(Sender: TObject);
begin
  Map.Polylines.Clear;
  RefreshPolylineList;
  Log('All polylines cleared');
end;

procedure TMainFrm.bUpdatePolylineClick(Sender: TObject);
var
  Idx: Integer;
  Polyline: TGMVclPolylineItem;
begin
  Idx := lbPolylines.ItemIndex;
  if Idx < 0 then
  begin
    Log('No polyline selected');
    Exit;
  end;

  Polyline := TGMVclPolylineItem(lbPolylines.Items.Objects[Idx]);
  if Assigned(Polyline) then
  begin
    LoadUIToPolyline(Polyline);
    RefreshPolylineList;
    lbPolylines.ItemIndex := lbPolylines.Items.IndexOfObject(Polyline);
    Log('Polyline updated');
  end;
end;

procedure TMainFrm.bZoomToMarkerClick(Sender: TObject);
var
  Marker: TGMVclMarkerItem;
begin
  if lbMarkers.ItemIndex < 0 then
  begin
    Log('No marker selected');
    Exit;
  end;

  Marker := TGMVclMarkerItem(lbMarkers.Items.Objects[lbMarkers.ItemIndex]);
  if Assigned(Marker) then
    Map.Markers.ZoomToPoints(False, Marker.Index);
end;

procedure TMainFrm.bZoomToMarkersClick(Sender: TObject);
begin
  if lbMarkers.ItemIndex < 0 then
  begin
    Log('No marker selected');
    Exit;
  end;

  Map.Markers.ZoomToPoints;
end;

procedure TMainFrm.bZoomToPolylineClick(Sender: TObject);
var
  Polyline: TGMVclPolylineItem;
begin
  if lbPolylines.ItemIndex < 0 then
  begin
    Log('No polyline selected');
    Exit;
  end;

  Polyline := TGMVclPolylineItem(lbPolylines.Items.Objects[lbPolylines.ItemIndex]);
  if Assigned(Polyline) then
    Map.Polylines.ZoomToPoints(False, Polyline.Index);
end;

procedure TMainFrm.bZoomToPolylinesClick(Sender: TObject);
begin
  if lbPolylines.ItemIndex < 0 then
  begin
    Log('No polyline selected');
    Exit;
  end;

  Map.Polylines.ZoomToPoints;
end;

procedure TMainFrm.bLoadGpxClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  GpxContent: TStringList;
  Polyline: TGMVclPolylineItem;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter := 'GPX Files (*.gpx)|*.gpx|All Files (*.*)|*.*';
    OpenDialog.Title := 'Load GPX File';
    if not OpenDialog.Execute then
      Exit;

    GpxContent := TStringList.Create;
    try
      GpxContent.LoadFromFile(OpenDialog.FileName);

      Polyline := Map.Polylines.Add;
      Polyline.Options.Path.Clear;
      Polyline.Options.Path.BeginUpdate;
      try
        ParseGpxTrack(GpxContent.Text, Polyline.Options.Path);
      finally
        Polyline.Options.Path.EndUpdate;
      end;

      BindPolylineEvents(Polyline);

      if Polyline.Options.Path.Count > 0 then
      begin
        RefreshPolylineList;
        lbPolylines.ItemIndex := lbPolylines.Items.IndexOfObject(Polyline);
        Log(Format('GPX loaded: %d points', [Polyline.Options.Path.Count]));
      end
      else
      begin
        Map.Polylines.Delete(Map.Polylines.Count - 1);
        RefreshPolylineList;
        Log('No points found in GPX file');
      end;
    finally
      GpxContent.Free;
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure TMainFrm.ParseGpxTrack(const AGpxContent: string; APath: TGMPolylinePath);
var
  Match: TMatch;
  Lat, Lng: Double;
begin
  if not Assigned(APath) then
    Exit;

  Match := TRegEx.Match(AGpxContent, 'lat="([^"]+)"\s+lon="([^"]+)"');
  while Match.Success do
  begin
    if TryStrToFloat(Match.Groups[1].Value, Lat, TFormatSettings.Invariant) and TryStrToFloat(Match.Groups[2].Value, Lng, TFormatSettings.Invariant) then
      APath.Add(Lat, Lng);
    Match := Match.NextMatch;
  end;
end;

procedure TMainFrm.BindPolylineEvents(APolyline: TGMVclPolylineItem);
begin
  if not Assigned(APolyline) then
    Exit;

  APolyline.OnClick := MapPolylineClick;
  APolyline.OnContextMenu := MapPolylineContextMenu;
  APolyline.OnDblClick := MapPolylineDblClick;
  APolyline.OnDragStart := MapPolylineDragStart;
  APolyline.OnDrag := MapPolylineDrag;
  APolyline.OnDragEnd := MapPolylineDragEnd;
  APolyline.OnMouseDown := MapPolylineMouseDown;
  APolyline.OnMouseMove := MapPolylineMouseMove;
  APolyline.OnMouseOut := MapPolylineMouseOut;
  APolyline.OnMouseOver := MapPolylineMouseOver;
  APolyline.OnMouseUp := MapPolylineMouseUp;
  APolyline.OnPathChanged := MapPolylinePathChanged;
end;

procedure TMainFrm.MapPolylineClick(Sender: TObject; ALatLng: TGMLibLatLng);
var
  Polyline: TGMVclPolylineItem;
  Idx: Integer;
begin
  Log(Format('Polyline Click: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
  Polyline := TGMVclPolylineItem(Sender);
  Idx := lbPolylines.Items.IndexOfObject(Polyline);
  if Idx >= 0 then
  begin
    lbPolylines.ItemIndex := Idx;
    LoadPolylineToUI(Polyline);
  end;
end;

procedure TMainFrm.MapPolylineContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline ContextMenu: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolylineDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline DblClick: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolylineDrag(Sender: TObject);
begin
  Log('Polyline Drag');
end;

procedure TMainFrm.MapPolylineDragEnd(Sender: TObject);
var
  Polyline: TGMVclPolylineItem;
  I: Integer;
  PathStr: string;
begin
  Log('Polyline DragEnd');
  FIsDraggingPolyline := False;
  Polyline := TGMVclPolylineItem(Sender);
  if Assigned(Polyline) then
  begin
    mPolylinePath.Lines.Clear;
    for I := 0 to Polyline.Options.Path.Count - 1 do
    begin
      PathStr := Format('%.6f,%.6f', [Polyline.Options.Path[I].Lat, Polyline.Options.Path[I].Lng]);
      mPolylinePath.Lines.Add(PathStr);
    end;
  end;
end;

procedure TMainFrm.MapPolylineDragStart(Sender: TObject);
begin
  Log('Polyline DragStart');
  FIsDraggingPolyline := True;
end;

procedure TMainFrm.MapPolylineMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline MouseDown: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolylineMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline MouseMove: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolylineMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline MouseOut: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolylineMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline MouseOver: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolylineMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polyline MouseUp: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolylinePathChanged(Sender: TObject);
var
  Polyline: TGMVclPolylineItem;
  I: Integer;
  PathStr: string;
begin
  Log('Polyline PathChanged');
  if FIsDraggingPolyline then
    Exit;

  Polyline := TGMVclPolylineItem(Sender);
  if Assigned(Polyline) then
  begin
    mPolylinePath.Lines.Clear;
    for I := 0 to Polyline.Options.Path.Count - 1 do
    begin
      PathStr := Format('%.6f,%.6f', [Polyline.Options.Path[I].Lat, Polyline.Options.Path[I].Lng]);
      mPolylinePath.Lines.Add(PathStr);
    end;
  end;
end;

procedure TMainFrm.RefreshPolygonList;
var
  I: Integer;
  Polygon: TGMVclPolygonItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if lbPolygons.ItemIndex >= 0 then
    SelectedObject := lbPolygons.Items.Objects[lbPolygons.ItemIndex];

  lbPolygons.Items.BeginUpdate;
  try
    lbPolygons.Clear;
    for I := 0 to Map.Polygons.Count - 1 do
    begin
      Polygon := Map.Polygons[I];
      lbPolygons.Items.AddObject(Format('Polygon %d', [I]), Polygon);
    end;
  finally
    lbPolygons.Items.EndUpdate;
  end;

  if Assigned(SelectedObject) then
    lbPolygons.ItemIndex := lbPolygons.Items.IndexOfObject(SelectedObject)
  else if lbPolygons.Items.Count > 0 then
    lbPolygons.ItemIndex := 0;
end;

procedure TMainFrm.LoadPolygonToUI(APolygon: TGMVclPolygonItem);
var
  I: Integer;
  PathStr: string;
begin
  if not Assigned(APolygon) then
    Exit;

  mPolygonPath.Lines.Clear;
  for I := 0 to APolygon.Options.Path.Count - 1 do
  begin
    PathStr := Format('%s,%s', [FloatToStr(APolygon.Options.Path[I].Lat, TFormatSettings.Invariant), FloatToStr(APolygon.Options.Path[I].Lng, TFormatSettings.Invariant)]);
    mPolygonPath.Lines.Add(PathStr);
  end;

  cbPolygonStrokeColor.Selected := APolygon.Options.StrokeColor;
  ePolygonStrokeOpacity.Text := FloatToStr(APolygon.Options.StrokeOpacity, TFormatSettings.Invariant);
  ePolygonStrokeWeight.Text := IntToStr(APolygon.Options.StrokeWeight);
  cbPolygonFillColor.Selected := APolygon.Options.FillColor;
  ePolygonFillOpacity.Text := FloatToStr(APolygon.Options.FillOpacity, TFormatSettings.Invariant);

  cbPolygonClickable.Checked := APolygon.Options.Clickable;
  cbPolygonDraggable.Checked := APolygon.Options.Draggable;
  cbPolygonEditable.Checked := APolygon.Options.Editable;
  cbPolygonGeodesic.Checked := APolygon.Options.Geodesic;
  cbPolygonVisible.Checked := APolygon.Options.Visible;
end;

procedure TMainFrm.LoadUIToPolygon(APolygon: TGMVclPolygonItem);
var
  Lat, Lng: Double;
begin
  if not Assigned(APolygon) then
    Exit;

  APolygon.Options.Path.Clear;
  APolygon.Options.Path.BeginUpdate;
  for var I := 0 to mPolygonPath.Lines.Count - 1 do
  begin
    var Line := Trim(mPolygonPath.Lines[I]);
    if Line = '' then
      Continue;

    var lPos := Pos(',', Line);
    var LatStr := Copy(Line, 1, lPos - 1);
    var LngStr := Copy(Line, lPos + 1, Length(Line));

    if TryStrToFloat(LatStr, Lat, TFormatSettings.Invariant) and TryStrToFloat(LngStr, Lng, TFormatSettings.Invariant) then
      APolygon.Options.Path.Add(Lat, Lng);
  end;
  APolygon.Options.Path.EndUpdate;

  APolygon.Options.StrokeColor := cbPolygonStrokeColor.Selected;
  APolygon.Options.StrokeOpacity := StrToFloatDef(ePolygonStrokeOpacity.Text, 1, TFormatSettings.Invariant);
  APolygon.Options.StrokeWeight := StrToIntDef(ePolygonStrokeWeight.Text, 2);
  APolygon.Options.FillColor := cbPolygonFillColor.Selected;
  APolygon.Options.FillOpacity := StrToFloatDef(ePolygonFillOpacity.Text, 0.3, TFormatSettings.Invariant);

  APolygon.Options.Clickable := cbPolygonClickable.Checked;
  APolygon.Options.Draggable := cbPolygonDraggable.Checked;
  APolygon.Options.Editable := cbPolygonEditable.Checked;
  APolygon.Options.Geodesic := cbPolygonGeodesic.Checked;
  APolygon.Options.Visible := cbPolygonVisible.Checked;
end;

procedure TMainFrm.BindPolygonEvents(APolygon: TGMVclPolygonItem);
begin
  if not Assigned(APolygon) then
    Exit;

  APolygon.OnClick := MapPolygonClick;
  APolygon.OnContextMenu := MapPolygonContextMenu;
  APolygon.OnDblClick := MapPolygonDblClick;
  APolygon.OnDragStart := MapPolygonDragStart;
  APolygon.OnDrag := MapPolygonDrag;
  APolygon.OnDragEnd := MapPolygonDragEnd;
  APolygon.OnMouseDown := MapPolygonMouseDown;
  APolygon.OnMouseMove := MapPolygonMouseMove;
  APolygon.OnMouseOut := MapPolygonMouseOut;
  APolygon.OnMouseOver := MapPolygonMouseOver;
  APolygon.OnMouseUp := MapPolygonMouseUp;
  APolygon.OnPathChanged := MapPolygonPathChanged;
end;

procedure TMainFrm.lbPolygonsClick(Sender: TObject);
var
  Idx: Integer;
  Polygon: TGMVclPolygonItem;
begin
  Idx := lbPolygons.ItemIndex;
  if Idx < 0 then
    Exit;

  Polygon := TGMVclPolygonItem(lbPolygons.Items.Objects[Idx]);
  if Assigned(Polygon) then
    LoadPolygonToUI(Polygon);
end;

procedure TMainFrm.bAddPolygonClick(Sender: TObject);
var
  Polygon: TGMVclPolygonItem;
begin
  Polygon := Map.Polygons.Add;
  LoadUIToPolygon(Polygon);
  BindPolygonEvents(Polygon);

  RefreshPolygonList;
  lbPolygons.ItemIndex := lbPolygons.Items.IndexOfObject(Polygon);
  Log('Polygon added');
end;

procedure TMainFrm.bDeletePolygonClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbPolygons.ItemIndex;
  if Idx < 0 then
    Exit;

  Map.Polygons.Delete(Idx);
  RefreshPolygonList;
  Log('Polygon deleted');
end;

procedure TMainFrm.bClearPolygonsClick(Sender: TObject);
begin
  Map.Polygons.Clear;
  RefreshPolygonList;
  Log('All polygons cleared');
end;

procedure TMainFrm.bUpdatePolygonClick(Sender: TObject);
var
  Idx: Integer;
  Polygon: TGMVclPolygonItem;
begin
  Idx := lbPolygons.ItemIndex;
  if Idx < 0 then
  begin
    Log('No polygon selected');
    Exit;
  end;

  Polygon := TGMVclPolygonItem(lbPolygons.Items.Objects[Idx]);
  if Assigned(Polygon) then
  begin
    LoadUIToPolygon(Polygon);
    Log('Polygon updated');
  end;
end;

procedure TMainFrm.bZoomToPolygonClick(Sender: TObject);
begin
  if lbPolygons.ItemIndex < 0 then
  begin
    Log('No polygon selected');
    Exit;
  end;

  Map.Polygons.ZoomToPoints(False, lbPolygons.ItemIndex);
end;

procedure TMainFrm.bZoomToPolygonsClick(Sender: TObject);
begin
  if lbPolygons.ItemIndex < 0 then
  begin
    Log('No polygon selected');
    Exit;
  end;

  Map.Polygons.ZoomToPoints;
end;

procedure TMainFrm.MapPolygonClick(Sender: TObject; ALatLng: TGMLibLatLng);
var
  Polygon: TGMVclPolygonItem;
  Idx: Integer;
begin
  Log(Format('Polygon Click: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
  Polygon := TGMVclPolygonItem(Sender);
  Idx := lbPolygons.Items.IndexOfObject(Polygon);
  if Idx >= 0 then
  begin
    lbPolygons.ItemIndex := Idx;
    LoadPolygonToUI(Polygon);
  end;
end;

procedure TMainFrm.MapPolygonContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polygon ContextMenu: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolygonDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polygon DblClick: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolygonDrag(Sender: TObject);
begin
  Log('Polygon Drag');
end;

procedure TMainFrm.MapPolygonDragEnd(Sender: TObject);
var
  Polygon: TGMVclPolygonItem;
  I: Integer;
  PathStr: string;
begin
  Log('Polygon DragEnd');
  FIsDraggingPolygon := False;
  Polygon := TGMVclPolygonItem(Sender);
  if Assigned(Polygon) then
  begin
    mPolygonPath.Lines.Clear;
    for I := 0 to Polygon.Options.Path.Count - 1 do
    begin
      PathStr := Format('%.6f,%.6f', [Polygon.Options.Path[I].Lat, Polygon.Options.Path[I].Lng]);
      mPolygonPath.Lines.Add(PathStr);
    end;
  end;
end;

procedure TMainFrm.MapPolygonDragStart(Sender: TObject);
begin
  Log('Polygon DragStart');
  FIsDraggingPolygon := True;
end;

procedure TMainFrm.MapPolygonMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polygon MouseDown: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolygonMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polygon MouseMove: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolygonMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polygon MouseOut: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolygonMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polygon MouseOver: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolygonMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Polygon MouseUp: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapPolygonPathChanged(Sender: TObject);
var
  Polygon: TGMVclPolygonItem;
  I: Integer;
  PathStr: string;
begin
  Log('Polygon PathChanged');
  if FIsDraggingPolygon then
    Exit;

  Polygon := TGMVclPolygonItem(Sender);
  if Assigned(Polygon) then
  begin
    mPolygonPath.Lines.Clear;
    for I := 0 to Polygon.Options.Path.Count - 1 do
    begin
      PathStr := Format('%.6f,%.6f', [Polygon.Options.Path[I].Lat, Polygon.Options.Path[I].Lng]);
      mPolygonPath.Lines.Add(PathStr);
    end;
  end;
end;

procedure TMainFrm.RefreshRectangleList;
var
  I: Integer;
  Rectangle: TGMVclRectangleItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if lbRectangles.ItemIndex >= 0 then
    SelectedObject := lbRectangles.Items.Objects[lbRectangles.ItemIndex];

  lbRectangles.Items.BeginUpdate;
  try
    lbRectangles.Clear;
    for I := 0 to Map.Rectangles.Count - 1 do
    begin
      Rectangle := Map.Rectangles[I];
      lbRectangles.Items.AddObject(Format('Rectangle %d', [I]), Rectangle);
    end;
  finally
    lbRectangles.Items.EndUpdate;
  end;

  if Assigned(SelectedObject) then
    lbRectangles.ItemIndex := lbRectangles.Items.IndexOfObject(SelectedObject)
  else if lbRectangles.Items.Count > 0 then
    lbRectangles.ItemIndex := 0;
end;

procedure TMainFrm.LoadRectangleToUI(ARectangle: TGMVclRectangleItem);
begin
  if not Assigned(ARectangle) then
    Exit;

  eRectangleNorth.Text := FloatToStr(ARectangle.Options.Bounds.North, TFormatSettings.Invariant);
  eRectangleSouth.Text := FloatToStr(ARectangle.Options.Bounds.South, TFormatSettings.Invariant);
  eRectangleEast.Text := FloatToStr(ARectangle.Options.Bounds.East, TFormatSettings.Invariant);
  eRectangleWest.Text := FloatToStr(ARectangle.Options.Bounds.West, TFormatSettings.Invariant);

  cbRectangleStrokeColor.Selected := ARectangle.Options.StrokeColor;
  eRectangleStrokeOpacity.Text := FloatToStr(ARectangle.Options.StrokeOpacity, TFormatSettings.Invariant);
  eRectangleStrokeWeight.Text := IntToStr(ARectangle.Options.StrokeWeight);
  cbRectangleFillColor.Selected := ARectangle.Options.FillColor;
  eRectangleFillOpacity.Text := FloatToStr(ARectangle.Options.FillOpacity, TFormatSettings.Invariant);

  cbRectangleClickable.Checked := ARectangle.Options.Clickable;
  cbRectangleDraggable.Checked := ARectangle.Options.Draggable;
  cbRectangleEditable.Checked := ARectangle.Options.Editable;
  cbRectangleVisible.Checked := ARectangle.Options.Visible;
end;

procedure TMainFrm.LoadUIToRectangle(ARectangle: TGMVclRectangleItem);
var
  North, South, East, West: Double;
begin
  if not Assigned(ARectangle) then
    Exit;

  if TryStrToFloat(Trim(eRectangleNorth.Text), North, TFormatSettings.Invariant) then
    ARectangle.Options.Bounds.North := North;
  if TryStrToFloat(Trim(eRectangleSouth.Text), South, TFormatSettings.Invariant) then
    ARectangle.Options.Bounds.South := South;
  if TryStrToFloat(Trim(eRectangleEast.Text), East, TFormatSettings.Invariant) then
    ARectangle.Options.Bounds.East := East;
  if TryStrToFloat(Trim(eRectangleWest.Text), West, TFormatSettings.Invariant) then
    ARectangle.Options.Bounds.West := West;

  ARectangle.Options.StrokeColor := cbRectangleStrokeColor.Selected;
  ARectangle.Options.StrokeOpacity := StrToFloatDef(eRectangleStrokeOpacity.Text, 1, TFormatSettings.Invariant);
  ARectangle.Options.StrokeWeight := StrToIntDef(eRectangleStrokeWeight.Text, 2);
  ARectangle.Options.FillColor := cbRectangleFillColor.Selected;
  ARectangle.Options.FillOpacity := StrToFloatDef(eRectangleFillOpacity.Text, 0.3, TFormatSettings.Invariant);

  ARectangle.Options.Clickable := cbRectangleClickable.Checked;
  ARectangle.Options.Draggable := cbRectangleDraggable.Checked;
  ARectangle.Options.Editable := cbRectangleEditable.Checked;
  ARectangle.Options.Visible := cbRectangleVisible.Checked;
end;

procedure TMainFrm.BindRectangleEvents(ARectangle: TGMVclRectangleItem);
begin
  if not Assigned(ARectangle) then
    Exit;

  ARectangle.OnClick := MapRectangleClick;
  ARectangle.OnContextMenu := MapRectangleContextMenu;
  ARectangle.OnDblClick := MapRectangleDblClick;
  ARectangle.OnDragStart := MapRectangleDragStart;
  ARectangle.OnDrag := MapRectangleDrag;
  ARectangle.OnDragEnd := MapRectangleDragEnd;
  ARectangle.OnMouseDown := MapRectangleMouseDown;
  ARectangle.OnMouseMove := MapRectangleMouseMove;
  ARectangle.OnMouseOut := MapRectangleMouseOut;
  ARectangle.OnMouseOver := MapRectangleMouseOver;
  ARectangle.OnMouseUp := MapRectangleMouseUp;
  ARectangle.OnBoundsChanged := MapRectangleBoundsChanged;
end;

procedure TMainFrm.lbRectanglesClick(Sender: TObject);
var
  Idx: Integer;
  Rectangle: TGMVclRectangleItem;
begin
  Idx := lbRectangles.ItemIndex;
  if Idx < 0 then
    Exit;

  Rectangle := TGMVclRectangleItem(lbRectangles.Items.Objects[Idx]);
  if Assigned(Rectangle) then
    LoadRectangleToUI(Rectangle);
end;

procedure TMainFrm.bAddRectangleClick(Sender: TObject);
var
  Rectangle: TGMVclRectangleItem;
begin
  Rectangle := Map.Rectangles.Add;
  LoadUIToRectangle(Rectangle);
  BindRectangleEvents(Rectangle);

  RefreshRectangleList;
  lbRectangles.ItemIndex := lbRectangles.Items.IndexOfObject(Rectangle);
  Log('Rectangle added');
end;

procedure TMainFrm.bDeleteRectangleClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbRectangles.ItemIndex;
  if Idx < 0 then
    Exit;

  Map.Rectangles.Delete(Idx);
  RefreshRectangleList;
  Log('Rectangle deleted');
end;

procedure TMainFrm.bClearRectanglesClick(Sender: TObject);
begin
  Map.Rectangles.Clear;
  RefreshRectangleList;
  Log('All rectangles cleared');
end;

procedure TMainFrm.bUpdateRectangleClick(Sender: TObject);
var
  Idx: Integer;
  Rectangle: TGMVclRectangleItem;
begin
  Idx := lbRectangles.ItemIndex;
  if Idx < 0 then
  begin
    Log('No rectangle selected');
    Exit;
  end;

  Rectangle := TGMVclRectangleItem(lbRectangles.Items.Objects[Idx]);
  if Assigned(Rectangle) then
  begin
    LoadUIToRectangle(Rectangle);
    Log('Rectangle updated');
  end;
end;

procedure TMainFrm.bZoomToRectangleClick(Sender: TObject);
begin
  if lbRectangles.ItemIndex < 0 then
  begin
    Log('No rectangle selected');
    Exit;
  end;

  Map.Rectangles.ZoomToPoints(False, lbRectangles.ItemIndex);
end;

procedure TMainFrm.bZoomToRectanglesClick(Sender: TObject);
begin
  if lbRectangles.ItemIndex < 0 then
  begin
    Log('No rectangle selected');
    Exit;
  end;

  Map.Rectangles.ZoomToPoints;
end;

procedure TMainFrm.MapRectangleClick(Sender: TObject; ALatLng: TGMLibLatLng);
var
  Rectangle: TGMVclRectangleItem;
  Idx: Integer;
begin
  Log(Format('Rectangle Click: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
  Rectangle := TGMVclRectangleItem(Sender);
  Idx := lbRectangles.Items.IndexOfObject(Rectangle);
  if Idx >= 0 then
  begin
    lbRectangles.ItemIndex := Idx;
    LoadRectangleToUI(Rectangle);
  end;
end;

procedure TMainFrm.MapRectangleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Rectangle ContextMenu: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapRectangleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Rectangle DblClick: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapRectangleDrag(Sender: TObject);
begin
  Log('Rectangle Drag');
end;

procedure TMainFrm.MapRectangleDragEnd(Sender: TObject);
var
  Rectangle: TGMVclRectangleItem;
begin
  Log('Rectangle DragEnd');
  FIsDraggingRectangle := False;
  Rectangle := TGMVclRectangleItem(Sender);
  if Assigned(Rectangle) then
    LoadRectangleToUI(Rectangle);
end;

procedure TMainFrm.MapRectangleDragStart(Sender: TObject);
begin
  Log('Rectangle DragStart');
  FIsDraggingRectangle := True;
end;

procedure TMainFrm.MapRectangleMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Rectangle MouseDown: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapRectangleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Rectangle MouseMove: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapRectangleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Rectangle MouseOut: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapRectangleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Rectangle MouseOver: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapRectangleMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Rectangle MouseUp: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapRectangleBoundsChanged(Sender: TObject);
var
  Rectangle: TGMVclRectangleItem;
begin
  Log('Rectangle BoundsChanged');
  if FIsDraggingRectangle then
    Exit;

  Rectangle := TGMVclRectangleItem(Sender);
  if Assigned(Rectangle) then
    LoadRectangleToUI(Rectangle);
end;

procedure TMainFrm.RefreshCircleList;
var
  I: Integer;
  Circle: TGMVclCircleItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if lbCircles.ItemIndex >= 0 then
    SelectedObject := lbCircles.Items.Objects[lbCircles.ItemIndex];

  lbCircles.Items.BeginUpdate;
  try
    lbCircles.Clear;
    for I := 0 to Map.Circles.Count - 1 do
    begin
      Circle := Map.Circles[I];
      lbCircles.Items.AddObject(Format('Circle %d', [I]), Circle);
    end;
  finally
    lbCircles.Items.EndUpdate;
  end;

  if Assigned(SelectedObject) then
    lbCircles.ItemIndex := lbCircles.Items.IndexOfObject(SelectedObject)
  else if lbCircles.Items.Count > 0 then
    lbCircles.ItemIndex := 0;
end;

procedure TMainFrm.LoadCircleToUI(ACircle: TGMVclCircleItem);
begin
  if not Assigned(ACircle) then
    Exit;

  eCircleCenterLat.Text := FloatToStr(ACircle.Options.Center.Lat, TFormatSettings.Invariant);
  eCircleCenterLng.Text := FloatToStr(ACircle.Options.Center.Lng, TFormatSettings.Invariant);
  eCircleRadius.Text := FloatToStr(ACircle.Options.Radius, TFormatSettings.Invariant);

  cbCircleStrokeColor.Selected := ACircle.Options.StrokeColor;
  eCircleStrokeOpacity.Text := FloatToStr(ACircle.Options.StrokeOpacity, TFormatSettings.Invariant);
  eCircleStrokeWeight.Text := IntToStr(ACircle.Options.StrokeWeight);
  cbCircleFillColor.Selected := ACircle.Options.FillColor;
  eCircleFillOpacity.Text := FloatToStr(ACircle.Options.FillOpacity, TFormatSettings.Invariant);

  cbCircleClickable.Checked := ACircle.Options.Clickable;
  cbCircleDraggable.Checked := ACircle.Options.Draggable;
  cbCircleEditable.Checked := ACircle.Options.Editable;
  cbCircleVisible.Checked := ACircle.Options.Visible;
end;

procedure TMainFrm.LoadUIToCircle(ACircle: TGMVclCircleItem);
var
  Lat, Lng, Radius: Double;
begin
  if not Assigned(ACircle) then
    Exit;

  if TryStrToFloat(Trim(eCircleCenterLat.Text), Lat, TFormatSettings.Invariant) then
    ACircle.Options.Center.Lat := Lat;
  if TryStrToFloat(Trim(eCircleCenterLng.Text), Lng, TFormatSettings.Invariant) then
    ACircle.Options.Center.Lng := Lng;
  if TryStrToFloat(Trim(eCircleRadius.Text), Radius, TFormatSettings.Invariant) then
    ACircle.Options.Radius := Radius;

  ACircle.Options.StrokeColor := cbCircleStrokeColor.Selected;
  ACircle.Options.StrokeOpacity := StrToFloatDef(eCircleStrokeOpacity.Text, 1, TFormatSettings.Invariant);
  ACircle.Options.StrokeWeight := StrToIntDef(eCircleStrokeWeight.Text, 2);
  ACircle.Options.FillColor := cbCircleFillColor.Selected;
  ACircle.Options.FillOpacity := StrToFloatDef(eCircleFillOpacity.Text, 0.3, TFormatSettings.Invariant);

  ACircle.Options.Clickable := cbCircleClickable.Checked;
  ACircle.Options.Draggable := cbCircleDraggable.Checked;
  ACircle.Options.Editable := cbCircleEditable.Checked;
  ACircle.Options.Visible := cbCircleVisible.Checked;
end;

procedure TMainFrm.BindCircleEvents(ACircle: TGMVclCircleItem);
begin
  if not Assigned(ACircle) then
    Exit;

  ACircle.OnClick := MapCircleClick;
  ACircle.OnContextMenu := MapCircleContextMenu;
  ACircle.OnDblClick := MapCircleDblClick;
  ACircle.OnDragStart := MapCircleDragStart;
  ACircle.OnDrag := MapCircleDrag;
  ACircle.OnDragEnd := MapCircleDragEnd;
  ACircle.OnMouseDown := MapCircleMouseDown;
  ACircle.OnMouseMove := MapCircleMouseMove;
  ACircle.OnMouseOut := MapCircleMouseOut;
  ACircle.OnMouseOver := MapCircleMouseOver;
  ACircle.OnMouseUp := MapCircleMouseUp;
  ACircle.OnCenterChanged := MapCircleCenterChanged;
  ACircle.OnRadiusChanged := MapCircleRadiusChanged;
end;

procedure TMainFrm.lbCirclesClick(Sender: TObject);
var
  Idx: Integer;
  Circle: TGMVclCircleItem;
begin
  Idx := lbCircles.ItemIndex;
  if Idx < 0 then
    Exit;

  Circle := TGMVclCircleItem(lbCircles.Items.Objects[Idx]);
  if Assigned(Circle) then
    LoadCircleToUI(Circle);
end;

procedure TMainFrm.bAddCircleClick(Sender: TObject);
var
  Circle: TGMVclCircleItem;
begin
  Circle := Map.Circles.Add;
  LoadUIToCircle(Circle);
  BindCircleEvents(Circle);

  RefreshCircleList;
  lbCircles.ItemIndex := lbCircles.Items.IndexOfObject(Circle);
  Log('Circle added');
end;

procedure TMainFrm.bDeleteCircleClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbCircles.ItemIndex;
  if Idx < 0 then
    Exit;

  Map.Circles.Delete(Idx);
  RefreshCircleList;
  Log('Circle deleted');
end;

procedure TMainFrm.bClearCirclesClick(Sender: TObject);
begin
  Map.Circles.Clear;
  RefreshCircleList;
  Log('All circles cleared');
end;

procedure TMainFrm.bUpdateCircleClick(Sender: TObject);
var
  Idx: Integer;
  Circle: TGMVclCircleItem;
begin
  Idx := lbCircles.ItemIndex;
  if Idx < 0 then
  begin
    Log('No circle selected');
    Exit;
  end;

  Circle := TGMVclCircleItem(lbCircles.Items.Objects[Idx]);
  if Assigned(Circle) then
  begin
    LoadUIToCircle(Circle);
    Log('Circle updated');
  end;
end;

procedure TMainFrm.bZoomToCircleClick(Sender: TObject);
begin
  if lbCircles.ItemIndex < 0 then
  begin
    Log('No circle selected');
    Exit;
  end;

  Map.Circles.ZoomToPoints(False, lbCircles.ItemIndex);
end;

procedure TMainFrm.bZoomToCirclesClick(Sender: TObject);
begin
  if lbCircles.ItemIndex < 0 then
  begin
    Log('No circle selected');
    Exit;
  end;

  Map.Circles.ZoomToPoints;
end;

procedure TMainFrm.MapCircleClick(Sender: TObject; ALatLng: TGMLibLatLng);
var
  Circle: TGMVclCircleItem;
  Idx: Integer;
begin
  Log(Format('Circle Click: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
  Circle := TGMVclCircleItem(Sender);
  Idx := lbCircles.Items.IndexOfObject(Circle);
  if Idx >= 0 then
  begin
    lbCircles.ItemIndex := Idx;
    LoadCircleToUI(Circle);
  end;
end;

procedure TMainFrm.MapCircleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle ContextMenu: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapCircleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle DblClick: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapCircleDrag(Sender: TObject);
begin
  Log('Circle Drag');
end;

procedure TMainFrm.MapCircleDragEnd(Sender: TObject);
var
  Circle: TGMVclCircleItem;
begin
  Log('Circle DragEnd');
  FIsDraggingCircle := False;
  Circle := TGMVclCircleItem(Sender);
  if Assigned(Circle) then
    LoadCircleToUI(Circle);
end;

procedure TMainFrm.MapCircleDragStart(Sender: TObject);
begin
  Log('Circle DragStart');
  FIsDraggingCircle := True;
end;

procedure TMainFrm.MapCircleMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle MouseDown: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapCircleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle MouseMove: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapCircleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle MouseOut: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapCircleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle MouseOver: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapCircleMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle MouseUp: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.MapCircleCenterChanged(Sender: TObject);
var
  Circle: TGMVclCircleItem;
begin
  Log('Circle CenterChanged');
  if FIsDraggingCircle then
    Exit;

  Circle := TGMVclCircleItem(Sender);
  if Assigned(Circle) then
    LoadCircleToUI(Circle);
end;

procedure TMainFrm.MapCircleRadiusChanged(Sender: TObject);
var
  Circle: TGMVclCircleItem;
begin
  Log('Circle RadiusChanged');
  if FIsDraggingCircle then
    Exit;

  Circle := TGMVclCircleItem(Sender);
  if Assigned(Circle) then
    LoadCircleToUI(Circle);
end;

procedure TMainFrm.RefreshGroundOverlayList;
var
  I: Integer;
  GroundOverlay: TGMGroundOverlayItem;
  SelectedObject: TObject;
begin
  SelectedObject := nil;
  if lbGroundOverlays.ItemIndex >= 0 then
    SelectedObject := lbGroundOverlays.Items.Objects[lbGroundOverlays.ItemIndex];

  lbGroundOverlays.Items.BeginUpdate;
  try
    lbGroundOverlays.Clear;
    for I := 0 to Map.GroundOverlays.Count - 1 do
    begin
      GroundOverlay := Map.GroundOverlays[I];
      lbGroundOverlays.Items.AddObject(Format('GroundOverlay %d', [I]), GroundOverlay);
    end;
  finally
    lbGroundOverlays.Items.EndUpdate;
  end;

  if Assigned(SelectedObject) then
    lbGroundOverlays.ItemIndex := lbGroundOverlays.Items.IndexOfObject(SelectedObject)
  else if lbGroundOverlays.Items.Count > 0 then
    lbGroundOverlays.ItemIndex := 0;
end;

procedure TMainFrm.LoadGroundOverlayToUI(AGroundOverlay: TGMGroundOverlayItem);
begin
  if not Assigned(AGroundOverlay) then
    Exit;

  eGroundOverlayUrl.Text := AGroundOverlay.Options.Url;
  eGroundOverlayNorth.Text := FloatToStr(AGroundOverlay.Options.Bounds.North, TFormatSettings.Invariant);
  eGroundOverlaySouth.Text := FloatToStr(AGroundOverlay.Options.Bounds.South, TFormatSettings.Invariant);
  eGroundOverlayEast.Text := FloatToStr(AGroundOverlay.Options.Bounds.East, TFormatSettings.Invariant);
  eGroundOverlayWest.Text := FloatToStr(AGroundOverlay.Options.Bounds.West, TFormatSettings.Invariant);
  cbGroundOverlayClickable.Checked := AGroundOverlay.Options.Clickable;
  cbGroundOverlayVisible.Checked := AGroundOverlay.Options.Visible;
  eGroundOverlayOpacity.Text := FloatToStr(AGroundOverlay.Options.Opacity, TFormatSettings.Invariant);
end;

procedure TMainFrm.LoadUIToGroundOverlay(AGroundOverlay: TGMGroundOverlayItem);
var
  North: Double;
  South: Double;
  East: Double;
  West: Double;
begin
  if not Assigned(AGroundOverlay) then
    Exit;

  AGroundOverlay.Options.BeginUpdate;
  try
    AGroundOverlay.Options.Url := Trim(eGroundOverlayUrl.Text);
    if TryStrToFloat(Trim(eGroundOverlayNorth.Text), North, TFormatSettings.Invariant) then
      AGroundOverlay.Options.Bounds.North := North;
    if TryStrToFloat(Trim(eGroundOverlaySouth.Text), South, TFormatSettings.Invariant) then
      AGroundOverlay.Options.Bounds.South := South;
    if TryStrToFloat(Trim(eGroundOverlayEast.Text), East, TFormatSettings.Invariant) then
      AGroundOverlay.Options.Bounds.East := East;
    if TryStrToFloat(Trim(eGroundOverlayWest.Text), West, TFormatSettings.Invariant) then
      AGroundOverlay.Options.Bounds.West := West;
    AGroundOverlay.Options.Clickable := cbGroundOverlayClickable.Checked;
    AGroundOverlay.Options.Visible := cbGroundOverlayVisible.Checked;
    AGroundOverlay.Options.Opacity := StrToFloatDef(eGroundOverlayOpacity.Text, 1, TFormatSettings.Invariant);
  finally
    AGroundOverlay.Options.EndUpdate;
  end;
end;

procedure TMainFrm.BindGroundOverlayEvents(AGroundOverlay: TGMGroundOverlayItem);
begin
  if not Assigned(AGroundOverlay) then
    Exit;

  AGroundOverlay.OnClick := MapGroundOverlayClick;
  AGroundOverlay.OnDblClick := MapGroundOverlayDblClick;
end;

procedure TMainFrm.lbGroundOverlaysClick(Sender: TObject);
var
  Idx: Integer;
  GroundOverlay: TGMGroundOverlayItem;
begin
  Idx := lbGroundOverlays.ItemIndex;
  if Idx < 0 then
    Exit;

  GroundOverlay := TGMGroundOverlayItem(lbGroundOverlays.Items.Objects[Idx]);
  if Assigned(GroundOverlay) then
    LoadGroundOverlayToUI(GroundOverlay);
end;

procedure TMainFrm.bAddGroundOverlayClick(Sender: TObject);
var
  GroundOverlay: TGMGroundOverlayItem;
begin
  GroundOverlay := Map.GroundOverlays.Add;
  try
    LoadUIToGroundOverlay(GroundOverlay);
    BindGroundOverlayEvents(GroundOverlay);

    RefreshGroundOverlayList;
    lbGroundOverlays.ItemIndex := lbGroundOverlays.Items.IndexOfObject(GroundOverlay);
    Log('GroundOverlay added');
  except
    GroundOverlay.Free;
    raise;
  end;
end;

procedure TMainFrm.bDeleteGroundOverlayClick(Sender: TObject);
var
  GroundOverlay: TGMGroundOverlayItem;
  Idx: Integer;
begin
  Idx := lbGroundOverlays.ItemIndex;
  if Idx < 0 then
    Exit;

  GroundOverlay := TGMGroundOverlayItem(lbGroundOverlays.Items.Objects[Idx]);
  if Assigned(GroundOverlay) then
    Map.GroundOverlays.Delete(GroundOverlay.Index);

  RefreshGroundOverlayList;
  Log('GroundOverlay deleted');
end;

procedure TMainFrm.bClearGroundOverlaysClick(Sender: TObject);
begin
  Map.GroundOverlays.Clear;
  RefreshGroundOverlayList;
  Log('All ground overlays cleared');
end;

procedure TMainFrm.bUpdateGroundOverlayClick(Sender: TObject);
var
  Idx: Integer;
  GroundOverlay: TGMGroundOverlayItem;
begin
  Idx := lbGroundOverlays.ItemIndex;
  if Idx < 0 then
  begin
    Log('No ground overlay selected');
    Exit;
  end;

  GroundOverlay := TGMGroundOverlayItem(lbGroundOverlays.Items.Objects[Idx]);
  if Assigned(GroundOverlay) then
  begin
    LoadUIToGroundOverlay(GroundOverlay);
    RefreshGroundOverlayList;
    lbGroundOverlays.ItemIndex := lbGroundOverlays.Items.IndexOfObject(GroundOverlay);
    Log('GroundOverlay updated');
  end;
end;

procedure TMainFrm.bZoomToGroundOverlayClick(Sender: TObject);
var
  GroundOverlay: TGMGroundOverlayItem;
begin
  if lbGroundOverlays.ItemIndex < 0 then
  begin
    Log('No ground overlay selected');
    Exit;
  end;

  GroundOverlay := TGMGroundOverlayItem(lbGroundOverlays.Items.Objects[lbGroundOverlays.ItemIndex]);
  if Assigned(GroundOverlay) then
    Map.GroundOverlays.ZoomToPoints(False, GroundOverlay.Index);
end;

procedure TMainFrm.bZoomToGroundOverlaysClick(Sender: TObject);
begin
  if lbGroundOverlays.ItemIndex < 0 then
  begin
    Log('No ground overlay selected');
    Exit;
  end;

  Map.GroundOverlays.ZoomToPoints;
end;

procedure TMainFrm.MapGroundOverlayClick(Sender: TObject; ALatLng: TGMLibLatLng);
var
  GroundOverlay: TGMGroundOverlayItem;
  Idx: Integer;
begin
  Log(Format('GroundOverlay Click: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
  GroundOverlay := TGMGroundOverlayItem(Sender);
  Idx := lbGroundOverlays.Items.IndexOfObject(GroundOverlay);
  if Idx >= 0 then
  begin
    lbGroundOverlays.ItemIndex := Idx;
    LoadGroundOverlayToUI(GroundOverlay);
  end;
end;

procedure TMainFrm.MapGroundOverlayDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('GroundOverlay DblClick: %.6f,%.6f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainFrm.ShowMarkerInfoWindow(AMarker: TGMVclMarkerItem);
var
  HTML: string;
begin
  { Keep a single InfoWindow instance alive for the marker currently selected
    in the UI; async callbacks keep filling the same window instead of racing
    against a brand new one each time. }
  FCurrentMarkerForInfoWindow := AMarker;

  if not Map.IsReady then
  begin
    Log('Map not ready yet');
    Exit;
  end;

  if Assigned(FCurrentInfoWindowForMarker) then
    FCurrentInfoWindowForMarker.Free;

  FCurrentInfoWindowForMarker := Map.InfoWindows.Add;
  HTML := '<div style="font-family:Arial,sans-serif;font-size:12px;">';
  HTML := HTML + '<strong>Loading...</strong>';
  HTML := HTML + '</div>';
  FCurrentInfoWindowForMarker.Options.Content := HTML;
  FCurrentInfoWindowForMarker.Options.DisableAutoPan := True;
  FCurrentInfoWindowForMarker.Options.Position := AMarker.Options.Position;
  FCurrentInfoWindowForMarker.OpenByObjectId(AMarker.ObjectId);

  Log('Requesting reverse geocode for marker: ' + Format('%.6f, %.6f', [AMarker.Options.Position.Lat, AMarker.Options.Position.Lng]));
  Map.GeoCode.Geocode(AMarker.Options.Position);
end;

procedure TMainFrm.GeoCodeCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
var
  Lat, Lng: Double;
  HTML: string;
  FirstResult: TGMGeocodeResult;
begin
  Log('GeoCodeCompleted - Status: ' + AResponse.Status + ', HasResults: ' + BoolToStr(AResponse.HasResults, True));

  if not Assigned(FCurrentMarkerForInfoWindow) or not Assigned(FCurrentInfoWindowForMarker) then
  begin
    Log('No marker or info window selected');
    Exit;
  end;

  Lat := FCurrentMarkerForInfoWindow.Options.Position.Lat;
  Lng := FCurrentMarkerForInfoWindow.Options.Position.Lng;

  HTML := '<div style="font-family:Arial,sans-serif;font-size:12px;">';
  HTML := HTML + '<strong>Coords:</strong> ' + Format('%.6f, %.6f', [Lat, Lng]) + '<br/>';

  if AResponse.HasResults then
  begin
    if AResponse.TryGetFirstResult(FirstResult) then
    begin
      HTML := HTML + '<strong>Address:</strong><br/>' + FirstResult.FormattedAddress + '<br/>';
      HTML := HTML + '<strong>Place ID:</strong> ' + FirstResult.PlaceId + '<br/>';
      HTML := HTML + '<strong>Type:</strong> ' + FirstResult.LocationType + '<br/>';
    end;
  end
  else
    HTML := HTML + '<em>No address found</em><br/>';

  HTML := HTML + '<br/><strong>Getting elevation...</strong>';
  HTML := HTML + '</div>';

  FCurrentInfoWindowForMarker.Options.Content := HTML;
  FCurrentInfoWindowForMarker.Options.Position := FCurrentMarkerForInfoWindow.Options.Position;
  FCurrentInfoWindowForMarker.OpenByObjectId(FCurrentMarkerForInfoWindow.ObjectId);

  Log('Requesting elevation...');
  Map.Elevations.Clear;
  Map.Elevations.AddLatLng(FCurrentMarkerForInfoWindow.Options.Position);
  Map.Elevations.Execute;
end;

procedure TMainFrm.ElevationCompleted(Sender: TObject; const AResponse: TGMElevationResponse);
var
  HTML: string;
  FirstResult: TGMElevationResult;
  GeocodeResult: TGMGeocodeResult;
begin
  Log('ElevationCompleted - Status: ' + AResponse.Status + ', HasResults: ' + BoolToStr(AResponse.HasResults, True));

  if (not Assigned(FCurrentMarkerForInfoWindow)) or (not Assigned(FCurrentInfoWindowForMarker)) then
  begin
    Log('No InfoWindow or marker available');
    Exit;
  end;

  Log(Format('InfoWindow Pos: %.10f, %.10f', [FCurrentInfoWindowForMarker.Options.Position.Lat, FCurrentInfoWindowForMarker.Options.Position.Lng]));
  Log(Format('Marker Pos: %.10f, %.10f', [FCurrentMarkerForInfoWindow.Options.Position.Lat, FCurrentMarkerForInfoWindow.Options.Position.Lng]));

  if (Abs(FCurrentInfoWindowForMarker.Options.Position.Lat - FCurrentMarkerForInfoWindow.Options.Position.Lat) > COORD_TOLERANCE) or (Abs(FCurrentInfoWindowForMarker.Options.Position.Lng - FCurrentMarkerForInfoWindow.Options.Position.Lng) > COORD_TOLERANCE) then
  begin
    Log('InfoWindow position mismatch');
    Exit;
  end;

  HTML := '<div style="font-family:Arial,sans-serif;font-size:12px;">';
  HTML := HTML + '<strong>Coords:</strong> ' + Format('%.6f, %.6f', [FCurrentMarkerForInfoWindow.Options.Position.Lat, FCurrentMarkerForInfoWindow.Options.Position.Lng]) + '<br/>';

  if Map.GeoCode.LastResponse.HasResults then
  begin
    GeocodeResult := Map.GeoCode.LastResponse.Results[0];
    HTML := HTML + '<strong>Address:</strong><br/>' + GeocodeResult.FormattedAddress + '<br/>';
    HTML := HTML + '<strong>Place ID:</strong> ' + GeocodeResult.PlaceId + '<br/>';
    HTML := HTML + '<strong>Type:</strong> ' + GeocodeResult.LocationType + '<br/>';
  end
  else
    HTML := HTML + '<em>No address found</em><br/>';

  if AResponse.HasResults then
  begin
    if AResponse.TryGetFirstResult(FirstResult) then
    begin
      HTML := HTML + '<strong>Elevation:</strong> ' + Format('%.2f m', [FirstResult.Elevation]) + '<br/>';
      HTML := HTML + '<strong>Resolution:</strong> ' + Format('%.2f m', [FirstResult.Resolution]) + '<br/>';
    end;
  end
  else
    HTML := HTML + '<em>Elevation unavailable</em><br/>';

  HTML := HTML + '</div>';

  Log('Updating InfoWindow with elevation data...');
  FCurrentInfoWindowForMarker.Options.Content := HTML;
end;

procedure TMainFrm.bApplyRouteClick(Sender: TObject);
var
  Query: TGMRouteQuery;
begin
  if not Map.IsReady then
  begin
    Log('Map not ready');
    Exit;
  end;

  Log('Route from: ' + eRouteFrom.Text + ' to: ' + eRouteTo.Text);

  Map.Routes.OriginAddress := eRouteFrom.Text;
  Map.Routes.OriginLocation.Lat := 0;
  Map.Routes.OriginLocation.Lng := 0;

  Map.Routes.DestinationAddress := eRouteTo.Text;
  Map.Routes.DestinationLocation.Lat := 0;
  Map.Routes.DestinationLocation.Lng := 0;

  Map.Routes.TravelMode := rtmDrive;
  Map.Routes.RequestFields := '';
  Map.Routes.ComputeAlternativeRoutes := True;

  UpdateStatus('Computing route...');
  Log('Computing route...');
  Query := Map.Routes.ExecuteQuery;
  if Assigned(Query) then
    Log('Route query created: ' + Query.RequestId);
end;

procedure TMainFrm.RouteCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
begin
  Log('Route completed. Status: ' + AResponse.Status + ', HasResults: ' + BoolToStr(AResponse.HasResults, True));
  RefreshRouteList;
end;

procedure TMainFrm.RefreshRouteList;
var
  i: Integer;
  Query: TGMRouteQuery;
  QueryResult: TGMRouteQueryResult;
begin
  lbRoutes.Clear;

  if Map.Routes.QueryCount = 0 then
    Exit;

  { The demo lists the latest query first because that is the route the user
    just asked for and the one they are most likely to inspect or hide. }
  Query := Map.Routes.Queries[Map.Routes.QueryCount - 1];

  for i := 0 to Query.Count - 1 do
  begin
    QueryResult := Query.ResultItems[i];
    lbRoutes.Items.AddObject(Format('%s - %s', [QueryResult.ResponseResult.LocalizedDistance, QueryResult.ResponseResult.LocalizedDuration]), QueryResult);
  end;

  Log(Format('Added %d routes to list', [lbRoutes.Items.Count]));
end;

procedure TMainFrm.cbRouteCloseOthersClick(Sender: TObject);
begin
  Map.Routes.CloseOthersBeforeVisible := cbRouteCloseOthers.Checked;
  Log(Format('Routes.CloseOthersBeforeVisible: %s', [BoolToStr(cbRouteCloseOthers.Checked, True)]));
end;

procedure TMainFrm.bComputeGeometryClick(Sender: TObject);
var
  FromPoint: TGMLibLatLng;
  ToPoint: TGMLibLatLng;
  ProbePoint: TGMLibLatLng;
  DistanceMeters: Double;
  HeadingDegrees: Double;
  OffsetPoint: TGMLibLatLng;
  MidPoint: TGMLibLatLng;
  Polyline: TGMPolylinePath;
  Polygon: TGMPolygonPath;
  InPolygon: Boolean;
  OnEdge: Boolean;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Invariant;
  FromPoint := TGMLibLatLng.Create(StrToFloatDef(eGeomFromLat.Text, 0, FS), StrToFloatDef(eGeomFromLng.Text, 0, FS));
  ToPoint := TGMLibLatLng.Create(StrToFloatDef(eGeomToLat.Text, 0, FS), StrToFloatDef(eGeomToLng.Text, 0, FS));
  ProbePoint := TGMLibLatLng.Create(StrToFloatDef(eGeomPointLat.Text, 0, FS), StrToFloatDef(eGeomPointLng.Text, 0, FS));
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

      mGeometryResults.Lines.BeginUpdate;
      try
        mGeometryResults.Clear;
        mGeometryResults.Lines.Add(Format('From: %.6f, %.6f', [FromPoint.Lat, FromPoint.Lng]));
        mGeometryResults.Lines.Add(Format('To: %.6f, %.6f', [ToPoint.Lat, ToPoint.Lng]));
        mGeometryResults.Lines.Add(Format('Distance: %.2f m', [DistanceMeters]));
        mGeometryResults.Lines.Add(Format('Heading: %.2f deg', [HeadingDegrees]));
        mGeometryResults.Lines.Add(Format('Midpoint: %.6f, %.6f', [MidPoint.Lat, MidPoint.Lng]));
        mGeometryResults.Lines.Add(Format('Offset (25%%): %.6f, %.6f', [OffsetPoint.Lat, OffsetPoint.Lng]));
        mGeometryResults.Lines.Add(Format('Probe: %.6f, %.6f', [ProbePoint.Lat, ProbePoint.Lng]));
        mGeometryResults.Lines.Add(Format('Probe inside sample polygon: %s', [BoolToStr(InPolygon, True)]));
        mGeometryResults.Lines.Add(Format('Midpoint on sample polyline edge: %s', [BoolToStr(OnEdge, True)]));
      finally
        mGeometryResults.Lines.EndUpdate;
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

procedure TMainFrm.lbRoutesClick(Sender: TObject);
var
  Idx: Integer;
  RouteResult: TGMRouteQueryResult;
begin
  Idx := lbRoutes.ItemIndex;
  if Idx < 0 then
    Exit;

  Log('Route selected: ' + IntToStr(Idx));

  RouteResult := TGMRouteQueryResult(lbRoutes.Items.Objects[Idx]);
  if not Assigned(RouteResult) then
    Exit;

  Log(Format('Distance: %.0fm, Duration: %dms', [RouteResult.ResponseResult.DistanceMeters, RouteResult.ResponseResult.DurationMillis]));

  if not RouteResult.Visible then
    RouteResult.Visible := True;

  RouteResult.ZoomToRoute;
end;

end.

