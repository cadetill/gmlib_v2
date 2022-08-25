var map = null;
    function showMessage(aMessage) {
	  document.getElementById('eventsMapEventFired_').value = "999999"; 
	  //alert(aMessage);
    }

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
                               
                                             document.getElementById('eventsMapSwLat_').value = SW.lat(); 
                                             document.getElementById('eventsMapSwLng_').value = SW.lng(); 
                                             document.getElementById('eventsMapNeLat_').value = NE.lat(); 
                                             document.getElementById('eventsMapNeLng_').value = NE.lng(); 
                                             document.getElementById('eventsMapBoundsChange_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "center_changed", 
                                function() { 
                                             var LatLng = map.getCenter(); 
                                             var proj = map.getProjection();
                                             var point = proj.fromLatLngToPoint(LatLng);
                                             
                                             document.getElementById('eventsMapX_').value = point.x; 
                                             document.getElementById('eventsMapY_').value = point.y; 
                                             document.getElementById('eventsMapLat_').value = LatLng.lat(); 
                                             document.getElementById('eventsMapLng_').value = LatLng.lng(); 
                                             document.getElementById('eventsMapCenterChange_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "click", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);
                                                  
                                                 document.getElementById('eventsMapX_').value = point.x; 
                                                 document.getElementById('eventsMapY_').value = point.y; 
                                                 document.getElementById('eventsMapLat_').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng_').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapClick_').value = "1"; 
                                                 document.getElementById('eventsMapEventFired_').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "dblclick", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);
                                                  
                                                 document.getElementById('eventsMapX_').value = point.x; 
                                                 document.getElementById('eventsMapY_').value = point.y; 
                                                 document.getElementById('eventsMapLat_').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng_').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapDblclick_').value = "1"; 
                                                 document.getElementById('eventsMapEventFired_').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "drag", 
                                function() { 
                                             document.getElementById('eventsMapDrag_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "dragend", 
                                function() { 
                                             document.getElementById('eventsMapDragEnd_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "dragstart", 
                                function() { 
                                             document.getElementById('eventsMapDragStart_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map,
                                "maptypeid_changed", 
                                function() { 
                                             var MapType = map.getMapTypeId(); 
                                             
                                             document.getElementById('eventsMapMapTypeId_').value = mapTypeIdToStr(MapType); 
                                             document.getElementById('eventsMapMapTypeId_changed_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
                                           }
                               ); 
  google.maps.event.addListener(map, 
                                "mousemove", 
                                function(event) {
                                                 var proj = map.getProjection();
                                                 var point = proj.fromLatLngToPoint(event.latLng);

                                                 document.getElementById('eventsMapX_').value = point.x; 
                                                 document.getElementById('eventsMapY_').value = point.y; 
                                                 document.getElementById('eventsMapLat_').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng_').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapMouseMove_').value = "1";
                                                 document.getElementById('eventsMapEventFired_').value = "1"; 
                                                }
                               );
  google.maps.event.addListener(map, 
                                "mouseout", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);

                                                 document.getElementById('eventsMapX_').value = point.x; 
                                                 document.getElementById('eventsMapY_').value = point.y; 
                                                 document.getElementById('eventsMapLat_').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng_').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapMouseOut_').value = "1";
                                                 document.getElementById('eventsMapEventFired_').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "mouseover", 
                                function(event) { 
                                                  var proj = map.getProjection();
                                                  var point = proj.fromLatLngToPoint(event.latLng);

                                                 document.getElementById('eventsMapX_').value = point.x; 
                                                 document.getElementById('eventsMapY_').value = point.y; 
                                                 document.getElementById('eventsMapLat_').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng_').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapMouseOver_').value = "1";
                                                 document.getElementById('eventsMapEventFired_').value = "1"; 
                                                }
                               ); 
  google.maps.event.addListener(map, 
                                "tilesloaded", 
                                function() { 
                                             document.getElementById('eventsMapTilesLoaded_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
                                           }
                               ); 
                               
  google.maps.event.addListener(map, 
                                "zoom_changed", 
                                function() { 
                                             document.getElementById('eventsMapZoom_').value = map.getZoom(); 
                                             document.getElementById('eventsMapZoomChanged_').value = "1"; 
                                             document.getElementById('eventsMapEventFired_').value = "1"; 
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


