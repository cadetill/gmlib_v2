/* ----------------------------------------------------------------------------------
   Functions JavaScript to Delphi 
---------------------------------------------------------------------------------- */
/* **********************************
  this function transforms a Google Maps ControlPosition to a string ControlPosition. 
********************************** */
function PositionToStr(Value) { 
  switch (Value) { 
    case google.maps.ControlPosition.BOTTOM_CENTER: return "cpBOTTOM_CENTER"; break; 
    case google.maps.ControlPosition.BOTTOM_LEFT: return "cpBOTTOM_LEFT"; break; 
    case google.maps.ControlPosition.BOTTOM_RIGHT: return "cpBOTTOM_RIGHT"; break; 
    case google.maps.ControlPosition.LEFT_BOTTOM: return "cpLEFT_BOTTOM"; break; 
    case google.maps.ControlPosition.LEFT_CENTER: return "cpLEFT_CENTER"; break; 
    case google.maps.ControlPosition.LEFT_TOP: return "cpLEFT_TOP"; break; 
    case google.maps.ControlPosition.RIGHT_BOTTOM: return "cpRIGHT_BOTTOM"; break; 
    case google.maps.ControlPosition.RIGHT_CENTER: return "cpRIGHT_CENTER"; break; 
    case google.maps.ControlPosition.RIGHT_TOP: return "cpRIGHT_TOP"; break; 
    case google.maps.ControlPosition.TOP_CENTER: return "cpTOP_CENTER"; break; 
    case google.maps.ControlPosition.TOP_LEFT: return "cpTOP_LEFT"; break; 
    case google.maps.ControlPosition.TOP_RIGHT: return "cpTOP_RIGHT"; break; 
    default: return "cpTOP_RIGHT"; 
  } 
} 

/* **********************************
  this function transforms a Google Maps GestureHandling to a string GestureHandling. 
********************************** */
function GestureHandlingToStr(Value) {
  switch (Value) { 
    case "cooperative": return "ghCooperative"; break; 
    case "greedy": return "ghGreedy"; break; 
    case "none": return "ghNone"; break; 
    case "auto": return "ghAuto"; break; 
    default: return "ghAuto"; 
  } 
}

/* **********************************
  this function transforms a Google Maps MapTypeId to a string MapTypeId. 
********************************** */
function MapTypeIdToStr(Value) { 
  switch (Value) { 
    case google.maps.MapTypeId.HYBRID: return "mtHYBRID"; break; 
    case google.maps.MapTypeId.ROADMAP: return "mtROADMAP"; break; 
    case google.maps.MapTypeId.SATELLITE: return "mtSATELLITE"; break; 
    case google.maps.MapTypeId.TERRAIN: return "mtTERRAIN"; break; 
    default: return ""; 
  } 
} 

/* **********************************
  this function transforms a Google Maps MapTypeControlStyle to a string MapTypeControlStyle. 
********************************** */
function MapTypeControlStyleToStr(Value) { 
  switch (Value) { 
    case google.maps.MapTypeControlStyle.DEFAULT: return "mtcDEFAULT"; break; 
    case google.maps.MapTypeControlStyle.DROPDOWN_MENU: return "mtcDROPDOWN_MENU"; break; 
    case google.maps.MapTypeControlStyle.HORIZONTAL_BAR: return "mtcHORIZONTAL_BAR"; break; 
    default: return ""; 
  } 
} 

/* **********************************
  this function transforms a Google Maps ScaleControlStyle to a string ScaleControlStyle. 
********************************** */
function ScaleControlStyleToStr(Value) { 
  switch (Value) { 
    case google.maps.ScaleControlStyle.DEFAULT: return "scsDEFAULT"; break; 
    default: return "scsDEFAULT"; 
  } 
} 


/* ----------------------------------------------------------------------------------
   Functions Delphi to JavaScript
---------------------------------------------------------------------------------- */
/* **********************************
  this function transforms a string ControlPosition to a Google Maps ControlPosition. 
********************************** */
function StrToPosition(Value) { 
  switch (Value) { 
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

/* **********************************
  this function transforms a string GestureHandling to a Google Maps GestureHandling. 
********************************** */
function StrToGestureHandling(Value) {
  switch (Value) { 
    case "ghCooperative": return "cooperative"; break; 
    case "ghGreedy": return "greedy"; break; 
    case "ghNone": return "none"; break; 
    case "ghAuto": return "auto"; break; 
    default: return "auto"; 
  } 
}

/* **********************************
  this function transforms a string MapTypeId to a Google Maps MapTypeId. 
********************************** */
  function StrToMapTypeId(Value) { 
    switch (Value) { 
      case "mtHYBRID": return google.maps.MapTypeId.HYBRID; break; 
      case "mtROADMAP": return google.maps.MapTypeId.ROADMAP; break; 
      case "mtSATELLITE": return google.maps.MapTypeId.SATELLITE; break; 
	  case "mtOSM": return "OSM"; break;
      default: return google.maps.MapTypeId.TERRAIN; 
    } 
  } 

/* **********************************
  this function transforms a string MapTypeControlStyle to a Google Maps MapTypeControlStyle. 
********************************** */
  function StrToMapTypeControlStyle(Value) { 
    switch (Value) { 
      case "mtcDEFAULT": return google.maps.MapTypeControlStyle.DEFAULT; break; 
      case "mtcDROPDOWN_MENU": return google.maps.MapTypeControlStyle.DROPDOWN_MENU; break; 
      case "mtcHORIZONTAL_BAR": return google.maps.MapTypeControlStyle.HORIZONTAL_BAR; break; 
      default: return google.maps.MapTypeControlStyle.DEFAULT; 
    } 
  } 
 
/* **********************************
  this function transforms a string ScaleControlStyle to a Google Maps ScaleControlStyle. 
********************************** */
  function StrToScaleControlStyle(Value) { 
    switch (Value) { 
      case "scsDEFAULT": return google.maps.ScaleControlStyle.DEFAULT; break; 
      default: return google.maps.ScaleControlStyle.DEFAULT; 
    } 
  } 

