var map = null;
var mapOptions = null;


/* **********************************
  this function activates the map events
********************************** */
function mapAssignEvents() {
  google.maps.event.addListener(map, 
                                "bounds_changed", 
                                function() { 
                                             var LatLngBounds = map.getBounds(); 
                                             var SW = LatLngBounds.getSouthWest(); 
                                             var NE = LatLngBounds.getNorthEast(); 
                               
                                             document.getElementById('eventsMapSwLat').value = SW.lat(); 
                                             document.getElementById('eventsMapSwLng').value = SW.lng(); 
                                             document.getElementById('eventsMapNeLat').value = NE.lat(); 
                                             document.getElementById('eventsMapNeLng').value = NE.lng(); 
                                             document.getElementById('eventsMapBoundsChange').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "center_changed", 
                                function() { 
                                             var LatLng = map.getCenter(); 
                                             var proj = map.getProjection();
                                             var point = proj.fromLatLngToPoint(LatLng);
                                             
                                             document.getElementById('eventsMapX').value = point.x; 
                                             document.getElementById('eventsMapY').value = point.y; 
                                             document.getElementById('eventsMapLat').value = LatLng.lat(); 
                                             document.getElementById('eventsMapLng').value = LatLng.lng(); 
                                             document.getElementById('eventsMapCenterChange').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "click", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);
                                                  
                                                 document.getElementById('eventsMapX').value = point.x; 
                                                 document.getElementById('eventsMapY').value = point.y; 
                                                 document.getElementById('eventsMapLat').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapClick').value = "1"; 
                                                 document.getElementById('eventsMapEventFired').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "contextmenu", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);
                                                  
                                                 document.getElementById('eventsMapX').value = point.x; 
                                                 document.getElementById('eventsMapY').value = point.y; 
                                                 document.getElementById('eventsMapLat').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapContextmenu').value = "1"; 
                                                 document.getElementById('eventsMapEventFired').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "dblclick", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);
                                                  
                                                 document.getElementById('eventsMapX').value = point.x; 
                                                 document.getElementById('eventsMapY').value = point.y; 
                                                 document.getElementById('eventsMapLat').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapDblclick').value = "1"; 
                                                 document.getElementById('eventsMapEventFired').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "drag", 
                                function() { 
                                             document.getElementById('eventsMapDrag').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "dragend", 
                                function() { 
                                             document.getElementById('eventsMapDragEnd').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "dragstart", 
                                function() { 
                                             document.getElementById('eventsMapDragStart').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map,
                                "maptypeid_changed", 
                                function() { 
                                             var MapType = map.getMapTypeId(); 
                                             
                                             document.getElementById('eventsMapMapTypeId').value = mapTypeIdToStr(MapType); 
                                             document.getElementById('eventsMapMapTypeId_changed').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "mousemove", 
                                function(event) {
                                                 var proj = map.getProjection();
                                                 var point = proj.fromLatLngToPoint(event.latLng);

                                                 document.getElementById('eventsMapX').value = point.x; 
                                                 document.getElementById('eventsMapY').value = point.y; 
                                                 document.getElementById('eventsMapLat').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapMouseMove').value = "1";
                                                 document.getElementById('eventsMapEventFired').value = "1"; 
                                                }
                               );
  google.maps.event.addListener(map, 
                                "mouseout", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);

                                                 document.getElementById('eventsMapX').value = point.x; 
                                                 document.getElementById('eventsMapY').value = point.y; 
                                                 document.getElementById('eventsMapLat').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapMouseOut').value = "1";
                                                 document.getElementById('eventsMapEventFired').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "mouseover", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);

                                                 document.getElementById('eventsMapX').value = point.x; 
                                                 document.getElementById('eventsMapY').value = point.y; 
                                                 document.getElementById('eventsMapLat').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapMouseOver').value = "1";
                                                 document.getElementById('eventsMapEventFired').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "tilesloaded", 
                                function() { 
                                             document.getElementById('eventsMapTilesLoaded').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "zoom_changed", 
                                function() { 
                                             document.getElementById('eventsMapZoom').value = map.getZoom(); 
                                             document.getElementById('eventsMapZoomChanged').value = "1"; 
                                             document.getElementById('eventsMapEventFired').value = "1"; 
                                           }
                               ); 
}

/* **********************************
  this function establish MapOptions object used to define the properties that can be set on a Map. 
********************************** */
function setMapOptions(BackgroundColor, 
                       Lat,                              // --> Center
                       Lng,                              // --> Center
                       ClickableIcons,
                       DisableDoubleClickZoom,
                       DraggableCursor,
                       DraggingCursor,
                       FullscreenControl,
                       FullscreenControlOptionsPosition, // --> fullscreenControlOptions
                       GestureHandling,
                       Heading,
                       IsFractionalZoomEnabled,
                       KeyboardShortcuts,
                       MapTypeControl,
                       MapTypeControlOptionsMapTypeIds,  // --> mapTypeControlOptions
                       MapTypeControlOptionsPosition,    // --> mapTypeControlOptions
                       MapTypeControlOptionsStyle,       // --> mapTypeControlOptions
                       MapTypeId,
                       MaxZoom,
                       MinZoom,
                       NoClear,
                       RestrictionSwLat,                 // --> restriction
                       RestrictionSwLng,                 // --> restriction
                       RestrictionNeLat,                 // --> restriction
                       RestrictionNeLng,                 // --> restriction
                       RestrictionStrictBounds,          // --> restriction
                       RestrictionEnabled,               // --> restriction
                       RotateControl,
                       RotateControlOptionsPosition,     // --> rotateControlOptions
                       ScaleControl, 
                       ScaleControlOptionsStyle,         // --> scaleControlOptions
                       StreetViewControl,
                       StreetViewControlOptionsPosition, // --> streetViewControlOptions
                       Tilt,
                       Zoom,
                       ZoomControl,
                       ZoomControlOptionsPosition        // --> zoomControlOptions
                       ) {
  FullscreenControlOptionsPosition = StrToPosition(FullscreenControlOptionsPosition); 
  GestureHandling = StrToGestureHandling(GestureHandling); 
  MapTypeControlOptionsMapTypeIds = MapTypeControlOptionsMapTypeIds.split(";"); 
  for (i = 0; i < MapTypeControlOptionsMapTypeIds.length; i++) { 
    MapTypeControlOptionsMapTypeIds[i] = StrToMapTypeId(MapTypeControlOptionsMapTypeIds[i])
  };
  MapTypeControlOptionsPosition = StrToPosition(MapTypeControlOptionsPosition); 
  MapTypeControlOptionsStyle = StrToMapTypeControlStyle(MapTypeControlOptionsStyle);
  PanControlOptionsPosition = StrToPosition(PanControlOptionsPosition); 
  RotateControlOptionsPosition = StrToPosition(RotateControlOptionsPosition); 
  ScaleControlOptionsStyle = StrToScaleControlStyle(ScaleControlOptionsStyle);
  ZoomControlOptionsPosition = StrToPosition(ZoomControlOptionsPosition); 
  Restriction = null;
  if (RestrictionEnabled) {
    Restriction = {
                    latLngBounds: new google.maps.LatLngBounds(
                                                                new google.maps.LatLng(RestrictionSwLat, RestrictionSwLng), 
                                                                new google.maps.LatLng(RestrictionNeLat, RestrictionNeLng)
                                                              ),
                    strictBounds: RestrictionStrictBounds
                  }
  }
  
  var mapOptions = {
                    backgroundColor: BackgroundColor,
                    center: new google.maps.LatLng(Lat, Lng),
                    clickableIcons: ClickableIcons,
                    //controlSize: --> not coded
                    //disableDefaultUI: --> not coded
                    disableDoubleClickZoom: DisableDoubleClickZoom,
                    //draggable: --> deprecated, not coded
                    draggableCursor: DraggableCursor,
                    draggingCursor: DraggingCursor,
                    fullscreenControl: FullscreenControl,
                    fullscreenControlOptions: {
                                               position: FullscreenControlOptionsPosition
                                              },
                    gestureHandling: GestureHandling,
                    heading: Heading,
                    isFractionalZoomEnabled: IsFractionalZoomEnabled,
                    keyboardShortcuts: KeyboardShortcuts,
                    //mapId: --> not coded 
                    mapTypeControl: MapTypeControl,
                    mapTypeControlOptions: {
                                            mapTypeIds: MapTypeControlOptionsMapTypeIds,
                                            position: MapTypeControlOptionsPosition,
                                            style: MapTypeControlOptionsStyle
                                           },
                    mapTypeId: MapTypeId,
                    maxZoom: MaxZoom,
                    minZoom: MinZoom,
                    noClear: NoClear,
                    restriction: Restriction,
                    rotateControl: RotateControl,
                    rotateControlOptions: {
                                           position: RotateControlOptionsPosition
                                          },
                    scaleControl: ScaleControl,
                    scaleControlOptions: {
                                          style: ScaleControlOptionsStyle
                                         },
                    //scrollwheel: --> not recommended, use gestureHandling instead
                    //streetView:  --> to code
                    streetViewControl: StreetViewControl,
                    streetViewControlOptions: {
                                               position: StreetViewControlOptionsPosition
                                              },
                    //styles: --> to code
                    tilt: Tilt,
                    zoom: Zoom,
                    zoomControl: ZoomControl,
                    zoomControlOptions: {
                                         position: ZoomControlOptionsPosition
                                        }
                   }; 
  map.setOptions(mapOptions);  
}

/* **********************************
  this function initialize eventsMap form.
********************************** */
function iniEventsMapForm() {
  document.getElementById('eventsMapEventFired').value = "0"; 
  document.getElementById('eventsMapLat').value = "0"; 
  document.getElementById('eventsMapLng').value = "0"; 
  document.getElementById('eventsMapX').value = "0"; 
  document.getElementById('eventsMapY').value = "0"; 
  document.getElementById('eventsMapCenterChange').value = "0"; 
  document.getElementById('eventsMapClick').value = "0"; 
  document.getElementById('eventsMapContextmenu').value = "0"; 
  document.getElementById('eventsMapDblclick').value = "0"; 
  document.getElementById('eventsMapMouseMove').value = "0"; 
  document.getElementById('eventsMapMouseOut').value = "0"; 
  document.getElementById('eventsMapMouseOver').value = "0"; 
  document.getElementById('eventsMapDrag').value = "0"; 
  document.getElementById('eventsMapDragEnd').value = "0"; 
  document.getElementById('eventsMapDragStart').value = "0"; 
  document.getElementById('eventsMapMapTypeId').value = "0"; 
  document.getElementById('eventsMapMapTypeId_changed').value = "0"; 
  document.getElementById('eventsMapTilesLoaded').value = "0"; 
  document.getElementById('eventsMapSwLat').value = "0"; 
  document.getElementById('eventsMapSwLng').value = "0"; 
  document.getElementById('eventsMapNeLat').value = "0"; 
  document.getElementById('eventsMapNeLng').value = "0"; 
  document.getElementById('eventsMapBoundsChange').value = "0"; 
  document.getElementById('eventsMapZoom').value = "0"; 
  document.getElementById('eventsMapZoomChanged').value = "0"; 
}

/* **********************************
  this function read eventsMap form.
********************************** */
function readEventsMapForm() {
  var formData = 
        'eventsMapEventFired_' + document.getElementById('eventsMapEventFired').value + '|' +
        'eventsMapLat_' + document.getElementById('eventsMapLat').value + '|' +
        'eventsMapLng_' + document.getElementById('eventsMapLng').value + '|' +
        'eventsMapX_' + document.getElementById('eventsMapX').value + '|' +
        'eventsMapY_' + document.getElementById('eventsMapY').value + '|' +
        'eventsMapCenterChange_' + document.getElementById('eventsMapCenterChange').value + '|' +
        'eventsMapClick_' + document.getElementById('eventsMapClick').value + '|' +
        'eventsMapContextmenu_' + document.getElementById('eventsMapContextmenu').value + '|' +
        'eventsMapDblclick_' + document.getElementById('eventsMapDblclick').value + '|' +
        'eventsMapMouseMove_' + document.getElementById('eventsMapMouseMove').value + '|' +
        'eventsMapMouseOut_' + document.getElementById('eventsMapMouseOut').value + '|' +
        'eventsMapMouseOver_' + document.getElementById('eventsMapMouseOver').value + '|' +
        'eventsMapDrag_' + document.getElementById('eventsMapDrag').value + '|' +
        'eventsMapDragEnd_' + document.getElementById('eventsMapDragEnd').value + '|' +
        'eventsMapDragStart_' + document.getElementById('eventsMapDragStart').value + '|' +
        'eventsMapMapTypeId_' + document.getElementById('eventsMapMapTypeId').value + '|' +
        'eventsMapMapTypeId_changed_' + document.getElementById('eventsMapMapTypeId_changed').value + '|' +
        'eventsMapTilesLoaded_' + document.getElementById('eventsMapTilesLoaded').value + '|' +
        'eventsMapSwLat_' + document.getElementById('eventsMapSwLat').value + '|' +
        'eventsMapSwLng_' + document.getElementById('eventsMapSwLng').value + '|' +
        'eventsMapNeLat_' + document.getElementById('eventsMapNeLat').value + '|' +
        'eventsMapNeLng_' + document.getElementById('eventsMapNeLng').value + '|' +
        'eventsMapBoundsChange_' + document.getElementById('eventsMapBoundsChange').value + '|' +
        'eventsMapZoom_' + document.getElementById('eventsMapZoom').value + '|' +
        'eventsMapZoomChanged_' + document.getElementById('eventsMapZoomChanged').value = "0";
  console.log(formData);
  if (results.length >= 1) 
    window.chrome.webview.postMessage(formData);
}

