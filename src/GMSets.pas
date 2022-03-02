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
  // @include(..\Help\docs\GMSets.TGMLang.txt)
  TGMLang = (// unknown exception language
             lnUnknown,
             // Spanish exception language
             lnEspanol,
             // English exception language
             lnEnglish,
             // French exception language
             lnFrench);

  // @include(..\Help\docs\GMSets.TGoogleAPIVer.txt)
  TGoogleAPIVer = (api348, apiNewest);

  // @include(..\Help\docs\GMSets.TGMAPILang.txt)
  TGMAPILang = (lArabic, lBulgarian, lBengali, lCatalan, lCzech, lDanish, lGerman, lGreek, lEnglish,
                lEnglish_Aust, lEnglish_GB, lSpanish, lBasque, lFarsi, lFinnish, lFilipino, lFrench,
                lGalician, lGujarati, lHindi, lCroatian, lHungarian, lIndonesian, lItalian, lHebrew,
                lJapanese, lKannada, lKorean, lLithuanian, lLatvian, lMalayalam, lMarathi, lDutch,
                lNorwegian, lPolish, lPortuguese, lPortuguese_Br, lPortuguese_Ptg, lRomanian, lRussian,
                lSlovak, lSlovenian, lSerbian, lSwedish, lTamil, lTelugu, lThai, lTagalog, lTurkish,
                lUkrainian, lVietnamese, lChinese_Simp, lChinese_Trad, lUndefined);

  // @include(..\Help\docs\GMSets.TGMMapTypeId.txt)
  TGMMapTypeId = (mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN, mtOSM);
  // @include(..\Help\docs\GMSets.TGMMapTypeIds.txt)
  TGMMapTypeIds = set of TGMMapTypeId;

  // @include(..\Help\docs\GMSets.TGMControlPosition.txt)
  TGMControlPosition = (cpBOTTOM_CENTER, cpBOTTOM_LEFT, cpBOTTOM_RIGHT,
                        cpLEFT_BOTTOM, cpLEFT_CENTER, cpLEFT_TOP,
                        cpRIGHT_BOTTOM, cpRIGHT_CENTER, cpRIGHT_TOP,
                        cpTOP_CENTER, cpTOP_LEFT, cpTOP_RIGHT);

  // @include(..\Help\docs\GMSets.TGMMapTypeControlStyle.txt)
  TGMMapTypeControlStyle = (mtcDEFAULT, mtcDROPDOWN_MENU, mtcHORIZONTAL_BAR);

  // @include(..\Help\docs\GMSets.TGMScaleControlStyle.txt)
  TGMScaleControlStyle = (scDEFAULT);

  // @include(..\Help\docs\GMSets.TGMMapTypeStyleElementType.txt)
  TGMMapTypeStyleElementType = (setALL, setGEOMETRY, setGEOMETRY_FILL, setGEOMETRY_STROKE,
                        setLABELS, setLABELS_ICON, setLABELS_TEXT, setLABELS_TEXT_FILL,
                        setLABELS_TEXT_STROKE);

  // @include(..\Help\docs\GMSets.TGMMapTypeStyleFeatureType.txt)
  TGMMapTypeStyleFeatureType = (sftADMINISTRATIVE, sftADMINISTRATIVE_COUNTRY, sftADMINISTRATIVE_LAND__PARCEL,
              sftADMINISTRATIVE_LOCALITY, sftADMINISTRATIVE_NEIGHBORHOOD, sftADMINISTRATIVE_PROVINCE,
              sftALL, sftLANDSCAPE, sftLANDSCAPE_MAN__MADE, sftLANDSCAPE_NATURAL, sftLANDSCAPE_NATURAL_LANDCOVER,
              sftLANDSCAPE_NATURAL_TERRAIN, sftPOI, sftPOI_ATTRACTION, sftPOI_BUSINESS, sftPOI_GOVERNMENT,
              sftPOI_MEDICAL, sftPOI_PARK, sftPOI_PLACE__OF__WORSHIP, sftPOI_SCHOOL, sftPOI_SPORTS__COMPLEX,
              sftROAD, sftROAD_ARTERIAL, sftROAD_HIGHWAY, sftROAD_HIGHWAY_CONTROLLED__ACCESS, sftROAD_LOCAL,
              sftTRANSIT, sftTRANSIT_LINE, sftTRANSIT_STATION, sftTRANSIT_STATION_AIRPORT, sftTRANSIT_STATION_BUS,
              sftTRANSIT_STATION_RAIL, sftWATER);

  // @include(..\Help\docs\GMSets.TGMVisibility.txt)
  TGMVisibility = (vOn, vOff, vSimplified);

  // @include(..\Help\docs\GMSets.TGMGestureHandling.txt)
  TGMGestureHandling = (ghCooperative, ghGreedy, ghNone, ghAuto);

implementation

end.
