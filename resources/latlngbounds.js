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
    document.getElementById('llbResultsContains_').value = "0";
    if (Bounds.contains(latlng))  
      document.getElementById('llbResultsContains_').value = "1"; 
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
