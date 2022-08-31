var map = null;

/* 
  this function activates the map events
*/
function mapAssignEvents() {
  google.maps.event.addListener(map, 
                                "mousemove", 
                                function(event) {
                                                 var proj = map.getProjection();
                                                 var point = proj.fromLatLngToPoint(event.latLng);

                                                 document.getElementById('eventsMapX').value = point.x; 
                                                 document.getElementById('eventsMapY').value = point.y; 
                                                 document.getElementById('eventsMapLat').value = event.latLng.lat(); 
                                                 document.getElementById('eventsMapLng').value = event.latLng.lng(); 
                                                 document.getElementById('eventsMapEventfired').value = "1"; 
                                                 document.getElementById('eventsMapMouseMove').value = "1";
/*
                                                 var xhr = new XMLHttpRequest();
                                                 var url = 'hello://localhost/customrequest?lat=' + event.latLng.lat();
                                                 xhr.open('GET', url, true);
                                                 xhr.onreadystatechange = function() {
                                                                                       if(xhr.readyState == 4 && xhr.status == 200) {
                                                                                         //alert(xhr.responseText);
                                                                                       }
                                                                                     }
                                                 xhr.send();
*/
                                                }
                               );
}


/* 
  this function establish MapOptions object used to define the properties that can be set on a Map. 
*/
function setMapOptions(Lat, Lng, Zoom) {
  var mapOptions = {
                    center:new google.maps.LatLng(Lat, Lng),
                    zoom: Zoom
                   };
  map.setOptions(mapOptions);  
}



  
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
