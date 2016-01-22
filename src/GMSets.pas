{
  @abstract(Sets for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Septembre 30, 2015)
  @lastmod(Septembre 30, 2015)

  The GMSets unit contains all sets used by GMLib.
}
unit GMSets;

interface

type
  // Language in which messages are displayed the exceptions shown by GMLib.
  TGMLang = (// unknown exception language
             lnUnknown,
             // Spanish exception language
             lnEspanol,
             // English exception language
             lnEnglish,
             // French exception language
             lnFrench);

  // Version of the Google Maps API to use
  TGoogleAPIVer = (api321, api322, api323, apiNewest);

  // @abstract(Identifiers for common MapTypes.)
  // More info at https://developers.google.com/maps/documentation/javascript/reference#MapTypeId
  TGMMapTypeId = (mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN, mtOSM);
  // @abstract(Set of TGMMapTypeId.)
  TGMMapTypeIds = set of TGMMapTypeId;

  // @abstract(Identifiers used to specify the placement of controls on the map.)
  // Controls are positioned relative to other controls in the same layout position. Controls that are added first are positioned closer to the edge of the map.
  // @longcode(#  +----------------+
  //  + TL    TC    TR +
  //  + LT          RT +
  //  +                +
  //  + LC          RC +
  //  +                +
  //  + LB          RB +
  //  + BL    BC    BR +
  //  +----------------+#)
  // Elements in the top or bottom row flow towards the middle of the row. Elements in the left or right column flow towards the middle of the column.@br@br
  // More info at https://developers.google.com/maps/documentation/javascript/reference#ControlPosition
  TGMControlPosition = (cpBOTTOM_CENTER, cpBOTTOM_LEFT, cpBOTTOM_RIGHT,
                        cpLEFT_BOTTOM, cpLEFT_CENTER, cpLEFT_TOP,
                        cpRIGHT_BOTTOM, cpRIGHT_CENTER, cpRIGHT_TOP,
                        cpTOP_CENTER, cpTOP_LEFT, cpTOP_RIGHT);

  // @abstract(Identifiers for common MapTypesControls.)
  // More info at https://developers.google.com/maps/documentation/javascript/reference#MapTypeControlStyle
  TGMMapTypeControlStyle = (mtcDEFAULT, mtcDROPDOWN_MENU, mtcHORIZONTAL_BAR);

  // @abstract(Identifiers for scale control ids.)
  // More info at https://developers.google.com/maps/documentation/javascript/reference#ScaleControlStyle
  TGMScaleControlStyle = (scDEFAULT);

  // @abstract(@code(google.maps.MapTypeStyleElementType) object specification)
  // Each TGMMapTypeStyleElementType distinguishes between the different representations of a feature.@br@br
  // More info at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyleElementType
  TGMMapTypeStyleElementType = (setALL, setGEOMETRY, setGEOMETRY_FILL, setGEOMETRY_STROKE,
                        setLABELS, setLABELS_ICON, setLABELS_TEXT, setLABELS_TEXT_FILL,
                        setLABELS_TEXT_STROKE);

  // @abstract(@code(google.maps.MapTypeStyleFeatureType) object specification)
  // Possible values for feature types. Stylers applied to a parent feature type automatically apply to all child feature types. Note however that parent features may include some additional features that are not included in one of their child feature types.@br@br
  // More info at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyleFeatureType
  TGMMapTypeStyleFeatureType = (sftADMINISTRATIVE, sftADMINISTRATIVE_COUNTRY, sftADMINISTRATIVE_LAND__PARCEL,
              sftADMINISTRATIVE_LOCALITY, sftADMINISTRATIVE_NEIGHBORHOOD, sftADMINISTRATIVE_PROVINCE,
              sftALL, sftLANDSCAPE, sftLANDSCAPE_MAN__MADE, sftLANDSCAPE_NATURAL, sftLANDSCAPE_NATURAL_LANDCOVER,
              sftLANDSCAPE_NATURAL_TERRAIN, sftPOI, sftPOI_ATTRACTION, sftPOI_BUSINESS, sftPOI_GOVERNMENT,
              sftPOI_MEDICAL, sftPOI_PARK, sftPOI_PLACE__OF__WORSHIP, sftPOI_SCHOOL, sftPOI_SPORTS__COMPLEX,
              sftROAD, sftROAD_ARTERIAL, sftROAD_HIGHWAY, sftROAD_HIGHWAY_CONTROLLED__ACCESS, sftROAD_LOCAL,
              sftTRANSIT, sftTRANSIT_LINE, sftTRANSIT_STATION, sftTRANSIT_STATION_AIRPORT, sftTRANSIT_STATION_BUS,
              sftTRANSIT_STATION_RAIL, sftWATER);

  // @abstract(Possible values for visibility property from MapTypeStyler object.)
  // More info at https://developers.google.com/maps/documentation/javascript/reference#MapTypeStyler
  TGMVisibility = (vOn, vOff, vSimplified);

  // @abstract(@code(google.maps.ZoomControlStyle) constants)
  // Styles for the zoom control. @br@br
  // Note: Zoom control styles are not available in the new set of controls introduced in v3.22 of the Google Maps JavaScript API. While using v3.22 and v3.23, you can choose to use the earlier set of controls rather than the new controls, thus making the large Zoom control available as part of the old control set. See What's New in the v3.22 Map Controls at https://developers.google.com/maps/articles/v322-controls-diff. @br@br
  // More info at https://developers.google.com/maps/documentation/javascript/reference#ZoomControlStyle
  TGMZoomControlStyle = (zcDEFAULT, zcLARGE, zcSMALL);

implementation

end.
