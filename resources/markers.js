/* **********************************
  Shows or hides a marker on the map
********************************** */
function ShowMarker(AnchorX,           // --> anchorPoint
                    AnchorY,           // --> anchorPoint
					Animation,
					Clickable,
					CollisionBehavior,
					CrossOnDrag,
					Cursor,
					Draggable,
					//Icon,
					//Label,
					Opacity,
					Optimized,
					PositionLat,       // --> position
					PositionLng,       // --> position
					//Shape,
					Title,
					Visible,
					ZIndex,
					IconIconUrl,
					
                   ) {
  if (map == null) exit; //throw new Error('map is null');
  
  var aMarker = null;
  
  var Idx = indexOf('marker', ZIndex);

  if (Idx == -1) {
    aMarker = new google.maps.Marker({ 
                                      map: map, 
                                      GMLibZIndex: ZIndex
                                    });
    //MarkerAssignEvents(aMarker);
    Idx = itemsArr['markers'].push(aMarker);
    Idx--;
  }
    
  if (OnDrop) { OnDrop = google.maps.Animation.DROP; }
  else { OnDrop = null; }
  itemsArr['markers'][Idx].setOptions({
                                       animation: OnDrop,
                                       clickable: Click,
                                       draggable: Drag,
                                       flat: Flat,
                                       optimize: Optimize,
                                       position: new google.maps.LatLng(Lat,Lng),
                                       raiseOnDrag: Raise,
                                       crossOnDrag: CrossOnDrag,
                                       title: Title.replace('.#%#:', '\''),
                                       visible: Visible,
                                       zIndex: ZIndex,
                                       GMLibShowIWMouseover: ShowIWMouseover,
                                       GMLibInfoWin: InfoWindowsCreate(IdObj, ZIndex, IWContent, IWDisAutopan, IWMaxW, IWPixelOffH, IWPixelOffW, Lat, Lng, CloseOther)
                                      });
  if (Bounce) itemsArr['markers'][Idx].setAnimation(google.maps.Animation.BOUNCE);
}