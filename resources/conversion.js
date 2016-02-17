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
