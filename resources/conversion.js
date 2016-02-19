  
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
  function StrToMapType(aMapType) { 
    switch (aMapType) { 
      case "mtHYBRID": return google.maps.MapTypeId.HYBRID; break; 
      case "mtROADMAP": return google.maps.MapTypeId.ROADMAP; break; 
      case "mtSATELLITE": return google.maps.MapTypeId.SATELLITE; break; 
	  case "mtOSM": return "OSM"; break;
      default: return google.maps.MapTypeId.TERRAIN; 
    } 
  }
  
  /* StrToMapTypeControlStyle */
  function StrToMapTypeControlStyle(aStyleMenu) { 
    switch (aStyleMenu) { 
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
