  
  /* FitBounds */
  function FitBounds(NELat, NELng, NENoWrap, SWLat, SWLng, SWNoWrap) {
    bounds = new google.maps.LatLngBounds(new google.maps.LatLng(SWLat, SWLng, SWNoWrap), 
                                          new google.maps.LatLng(NELat, NELng, NENoWrap));
    try{
        map.fitBounds(bounds);
    } catch(err) {
        alert(err.message);
    }
  }
