/* **********************************
  this function check if a LatLngBounds contains a LatLng. 
********************************** */
function llbContains(                       
                     Lat,       // --> Lat from LatLng to check
                     Lng,       // --> Lng from LatLng to check
                     SWLat, 
                     SWLng, 
                     NELat, 
                     NELng 
                    ) {
  document.getElementById('llbResultsMapisnull_').value = "0"; 
  if (map != null) { 
    var latlng = new google.maps.LatLng(Lat, Lng); 
    var Bounds = new google.maps.LatLngBounds(new google.maps.LatLng(SWLat, SWLng), new google.maps.LatLng(NELat, NELng)); 
    document.getElementById('llbResultsBoolVal_').value = "0";
    if (Bounds.contains(latlng))  
      document.getElementById('llbResultsBoolVal_').value = "1"; 
  } 
  else 
    document.getElementById('llbResultsMapisnull_').value = "1"; 
}

/* **********************************
  this function extends a LatLngBounds with a LatLng. 
********************************** */
function llbExtend(                       
                   Lat,       // --> Lat that must be into bounds
                   Lng,       // --> Lng that must be into bounds
                   SWLat, 
                   SWLng, 
                   NELat, 
                   NELng 
                  ) { 
  document.getElementById('llbResultsMapisnull_').value = "0"; 
  if (map != null) { 
    var latlng = new google.maps.LatLng(Lat, Lng); 
    var Bounds = new google.maps.LatLngBounds(new google.maps.LatLng(SWLat, SWLng), new google.maps.LatLng(NELat, NELng)); 
    Bounds = Bounds.extend(latlng); 
    document.getElementById('llbResultsSwLat_').value = Bounds.getSouthWest().lat(); 
    document.getElementById('llbResultsSwLng_').value = Bounds.getSouthWest().lng(); 
    document.getElementById('llbResultsNeLat_').value = Bounds.getNorthEast().lat(); 
    document.getElementById('llbResultsNeLng_').value = Bounds.getNorthEast().lng(); 
  } 
  else 
    document.getElementById('llbResultsMapisnull_').value = "1"; 
}

/* **********************************
  this function get center of a bounds. 
********************************** */
function llbGetCenter(                       
                      SWLat, 
                      SWLng, 
                      NELat, 
                      NELng 
                     ) { 
  document.getElementById('llbResultsMapisnull_').value = "0"; 
  if (map != null) { 
    var Bounds = new google.maps.LatLngBounds(new google.maps.LatLng(SWLat, SWLng), new google.maps.LatLng(NELat, NELng)); 
    var LatLng = Bounds.getCenter();
    document.getElementById('llbResultsLat_').value = LatLng.lat(); 
    document.getElementById('llbResultsLng_').value = LatLng.lng(); 
  } 
  else 
    document.getElementById('llbResultsMapisnull_').value = "1"; 
} 

/* **********************************
  this function returns true if this bounds shares any points with the other bounds. 
********************************** */
function llbIntersects(                       
                      OtherSWLat, 
                      OtherSWLng, 
                      OtherNELat, 
                      OtherNELng 
                      SWLat, 
                      SWLng, 
                      NELat, 
                      NELng 
                     ) { 
  document.getElementById('llbResultsMapisnull_').value = "0"; 
  if (map != null) { 
    var Bounds = new google.maps.LatLngBounds(new google.maps.LatLng(SWLat, SWLng), new google.maps.LatLng(NELat, NELng)); 
    var OtherBounds = new google.maps.LatLngBounds(new google.maps.LatLng(OtherSWLat, OtherSWLng), new google.maps.LatLng(OtherNELat, OtherNELng)); 
    document.getElementById('llbResultsBoolVal_').value = "0";
    if (Bounds.intersects(OtherBounds))  
      document.getElementById('llbResultsBoolVal_').value = "1"; 
  } 
  else 
    document.getElementById('llbResultsMapisnull_').value = "1"; 
} 

/* **********************************
  this function converts the given bounds to a lat/lng span.
********************************** */
function llbToSpan(                       
                   SWLat, 
                   SWLng, 
                   NELat, 
                   NELng 
                  ) { 
  document.getElementById('llbResultsMapisnull_').value = "0"; 
  if (map != null) { 
    var Bounds = new google.maps.LatLngBounds(new google.maps.LatLng(SWLat, SWLng), new google.maps.LatLng(NELat, NELng)); 
    var LatLng = Bounds.toSpan();
    document.getElementById('llbResultsLat_').value = LatLng.lat(); 
    document.getElementById('llbResultsLng_').value = LatLng.lng(); 
  } 
  else 
    document.getElementById('llbResultsMapisnull_').value = "1"; 
} 

/* **********************************
  this function extends the bounds to contain the union of this and the given bounds.
********************************** */
function llbUnion(                       
                  OtherSWLat, 
                  OtherSWLng, 
                  OtherNELat, 
                  OtherNELng 
                  SWLat, 
                  SWLng, 
                  NELat, 
                  NELng 
                 ) { 
  document.getElementById('llbResultsMapisnull_').value = "0"; 
  if (map != null) { 
    var Bounds = new google.maps.LatLngBounds(new google.maps.LatLng(SWLat, SWLng), new google.maps.LatLng(NELat, NELng)); 
    var OtherBounds = new google.maps.LatLngBounds(new google.maps.LatLng(OtherSWLat, OtherSWLng), new google.maps.LatLng(OtherNELat, OtherNELng)); 
    Bounds = Bounds.union(OtherBounds); 
    document.getElementById('llbResultsSwLat_').value = Bounds.getSouthWest().lat(); 
    document.getElementById('llbResultsSwLng_').value = Bounds.getSouthWest().lng(); 
    document.getElementById('llbResultsNeLat_').value = Bounds.getNorthEast().lat(); 
    document.getElementById('llbResultsNeLng_').value = Bounds.getNorthEast().lng(); 
  } 
  else 
    document.getElementById('llbResultsMapisnull_').value = "1"; 
} 
