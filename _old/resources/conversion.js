  
  /* StrToPosition */
  function StrToPosition(Pos) { 
    switch (Pos) { 
      case "cpBOTTOM_CENTER": return google.maps.ControlPosition.BOTTOM_CENTER; break; 
      case "cpBOTTOM_LEFT": return google.maps.ControlPosition.BOTTOM_LEFT; break; 
      case "cpBOTTOM_RIGHT": return google.maps.ControlPosition.BOTTOM_RIGHT; break; 
      case "cpLEFT_BOTTOM": return google.maps.ControlPosition.LEFT_BOTTOM; break; 
      case "cpLEFT_CENTER": return google.maps.ControlPosition.LEFT_CENTER; break; 
      case "cpLEFT_TOP": return google.maps.ControlPosition.LEFT_TOP; break; 
      case "cpRIGHT_BOTTOM": return google.maps.ControlPosition.RIGHT_BOTTOM; break; 
      case "cpRIGHT_CENTER": return google.maps.ControlPosition.RIGHT_CENTER; break; 
      case "cpRIGHT_TOP": return google.maps.ControlPosition.RIGHT_TOP; break; 
      case "cpTOP_CENTER": return google.maps.ControlPosition.TOP_CENTER; break; 
      case "cpTOP_LEFT": return google.maps.ControlPosition.TOP_LEFT; break; 
      case "cpTOP_RIGHT": return google.maps.ControlPosition.TOP_RIGHT; break; 
      default: return google.maps.ControlPosition.TOP_RIGHT; 
    } 
  }

  /* StrToMapType */
  function StrToMapType(MapType) { 
    switch (MapType) { 
      case "mtHYBRID": return google.maps.MapTypeId.HYBRID; break; 
      case "mtROADMAP": return google.maps.MapTypeId.ROADMAP; break; 
      case "mtSATELLITE": return google.maps.MapTypeId.SATELLITE; break; 
	  case "mtOSM": return "OSM"; break;
      default: return google.maps.MapTypeId.TERRAIN; 
    } 
  }
  
  /* StrToMapTypeControlStyle */
  function StrToMapTypeControlStyle(StyleMenu) { 
    switch (StyleMenu) { 
      case "mtcDROPDOWN_MENU": return google.maps.MapTypeControlStyle.DROPDOWN_MENU; break; 
      case "mtcHORIZONTAL_BAR": return google.maps.MapTypeControlStyle.HORIZONTAL_BAR; break; 
      default: return google.maps.MapTypeControlStyle.DEFAULT; 
    } 
  }

  /* StrToScaleControlStyle */
  function StrToScaleControlStyle(ScaleStyle) { 
    switch (ScaleStyle) { 
      case "scDEFAULT": return google.maps.ScaleControlStyle.DEFAULT; break; 
      default: return google.maps.ScaleControlStyle.DEFAULT; 
    } 
  } 
 
  /* StrToZoomControlStyle */
  function StrToZoomControlStyle(ZStyle) { 
    switch (ZStyle) { 
      case "zcDEFAULT": return google.maps.ZoomControlStyle.DEFAULT; break; 
      case "zcLARGE": return google.maps.ZoomControlStyle.LARGE; break; 
      case "zcSMALL": return google.maps.ZoomControlStyle.SMALL; break; 
      default: return google.maps.ZoomControlStyle.DEFAULT; 
    } 
  } 

  /* StrToMapTypeStyleElementType */
  function StrToMapTypeStyleElementType(elementType) {
    switch (elementType) { 
      case "setALL": return 'all'; break; 
      case "setGEOMETRY": return 'geometry'; break; 
      case "setGEOMETRY_FILL": return 'geometry.fill'; break; 
      case "setGEOMETRY_STROKE": return 'geometry.stroke'; break; 
      case "setLABELS": return 'labels'; break; 
      case "setLABELS_ICON": return 'labels.icon'; break; 
      case "setLABELS_TEXT": return 'labels.text'; break; 
      case "setLABELS_TEXT_FILL": return 'labels.text.fill'; break; 
      case "setLABELS_TEXT_STROKE": return 'labels.text.stroke'; break; 
      default: return 'all'; 
    } 
  } 

  /* StrToMapTypeStyleFeatureType */
  function StrToMapTypeStyleFeatureType(featureType) { 
    switch (featureType) { 
      case "sftADMINISTRATIVE": return 'administrative'; break; 
      case "sftADMINISTRATIVE_COUNTRY": return 'administrative.country'; break; 
      case "sftADMINISTRATIVE_LAND__PARCEL": return 'administrative.land_parcel'; break; 
      case "sftADMINISTRATIVE_LOCALITY": return 'administrative.locality'; break; 
      case "sftADMINISTRATIVE_NEIGHBORHOOD": return 'administrative.neighborhood'; break; 
      case "sftADMINISTRATIVE_PROVINCE": return 'administrative.province'; break; 
      case "sftALL": return 'all'; break; 
      case "sftLANDSCAPE": return 'landscape'; break; 
      case "sftLANDSCAPE_MAN__MADE": return 'landscape.man_made'; break; 
      case "sftLANDSCAPE_NATURAL": return 'landscape.natural'; break; 
      case "sftLANDSCAPE_NATURAL_LANDCOVER": return 'landscape.natural.landcover'; break; 
      case "sftLANDSCAPE_NATURAL_TERRAIN": return 'landscape.natural.terrain'; break; 
      case "sftPOI": return 'poi'; break; 
      case "sftPOI_ATTRACTION": return 'poi.attraction'; break; 
      case "sftPOI_BUSINESS": return 'poi.business'; break; 
      case "sftPOI_GOVERNMENT": return 'poi.government'; break; 
      case "sftPOI_MEDICAL": return 'poi.medical'; break; 
      case "sftPOI_PARK": return 'poi.park'; break; 
      case "sftPOI_PLACE__OF__WORSHIP": return 'poi.place_of_worship'; break; 
      case "sftPOI_SCHOOL": return 'poi.school'; break; 
      case "sftPOI_SPORTS__COMPLEX": return 'poi.sports_complex'; break; 
      case "sftROAD": return 'road'; break; 
      case "sftROAD_ARTERIAL": return 'road.arterial'; break; 
      case "sftROAD_HIGHWAY": return 'road.highway'; break; 
      case "sftROAD_HIGHWAY_CONTROLLED__ACCESS": return 'road.highway.controlled_access'; break; 
      case "sftROAD_LOCAL": return 'road.local'; break; 
      case "sftTRANSIT": return 'transit'; break; 
      case "sftTRANSIT_LINE": return 'transit.line'; break; 
      case "sftTRANSIT_STATION": return 'transit.station'; break; 
      case "sftTRANSIT_STATION_AIRPORT": return 'transit.station.airport'; break; 
      case "sftTRANSIT_STATION_BUS": return 'transit.station.bus'; break; 
      case "sftTRANSIT_STATION_RAIL": return 'transit.station.rail'; break; 
      case "sftWATER": return 'water'; break; 
      default: return 'all'; 
    } 
  } 

  /* StrToVisibility */
  function StrToVisibility(visibility) {
    switch (visibility) { 
      case "vOn": return 'on'; break; 
      case "vOff": return 'off'; break; 
      case "vSimplified": return 'simplified'; break; 
      default: return 'on'; 
    } 
  } 

  /* StrToStyles */
  function StrToStyles(StrStyle) { 
    if ((StrStyle == '') || (typeof variable == 'undefined')) return [];
	
    var MapTypeStyle = StrStyle.split("¬"); 
    for (i = 0; i < MapTypeStyle.length; i++) { 
      MapTypeStyle[i] = MapTypeStyle[i].split("&");
      if (MapTypeStyle[i].length > 0) {
        var elementType = MapTypeStyle[i][0].split(",");
        var featureType = elementType[1];
        elementType = elementType[0];
        elementType = StrToMapTypeStyleElementType(elementType);
        featureType = StrToMapTypeStyleFeatureType(featureType);

        var stylers = [];
        for (j = 1; j < MapTypeStyle[i].length; j++) {
          var data = MapTypeStyle[i][j].split(",");
          stylers.push({
                        color: data[6],
                        gamma: data[0],
                        hue: data[7],
                        invert_lightness: data[1],
                        lightness: data[2],
                        saturation: data[3],
                        visibility: data[4],
                        weight: data[5]
                      });
        }
        MapTypeStyle[i] = {
                            elementType: elementType,
                            featureType: featureType,
                            stylers: stylers
                          }
      }
    }
    return MapTypeStyle;
  }

  /* StrToGestureHandling */
  function StrToGestureHandling(gestureHandling) {
    switch (gestureHandling) { 
      case "ghCooperative": return 'cooperative'; break; 
      case "ghGreedy": return 'greedy'; break; 
      case "ghNone": return 'none'; break; 
      default: return 'auto'; 
    } 
  } 
  