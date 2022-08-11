{
  @abstract(Sets for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 2, 2022)

  The GMLib.Sets unit contains all sets used by GMLib.
}
unit GMLib.Sets;

interface

type
  // @include(..\Help\docs\GMLib.Sets.TGMLang.txt)
  TGMLang = (// unknown exception language
             lnUnknown,
             // Spanish exception language
             lnEspanol,
             // English exception language
             lnEnglish,
             // French exception language
             lnFrench);

  // @include(..\Help\docs\GMLib.Sets.TGMControlPosition.txt)
  TGMControlPosition = (cpBOTTOM_CENTER, cpBOTTOM_LEFT, cpBOTTOM_RIGHT,
                        cpLEFT_BOTTOM, cpLEFT_CENTER, cpLEFT_TOP,
                        cpRIGHT_BOTTOM, cpRIGHT_CENTER, cpRIGHT_TOP,
                        cpTOP_CENTER, cpTOP_LEFT, cpTOP_RIGHT);

  // @include(..\Help\docs\GMLib.Sets.TGMGestureHandling.txt)
  TGMGestureHandling = (ghCooperative, ghGreedy, ghNone, ghAuto);

  // @include(..\Help\docs\GMLib.Sets.TGMMapTypeId.txt)
  TGMMapTypeId = (mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN, mtOSM);
  // @include(..\Help\docs\GMLib.Sets.TGMMapTypeIds.txt)
  TGMMapTypeIds = set of TGMMapTypeId;

  // @include(..\Help\docs\GMLib.Sets.TGMMapTypeControlStyle.txt)
  TGMMapTypeControlStyle = (mtcDEFAULT, mtcDROPDOWN_MENU, mtcHORIZONTAL_BAR);

  // @include(..\Help\docs\GMLib.Sets.TGMScaleControlStyle.txt)
  TGMScaleControlStyle = (scsDEFAULT);

implementation

end.
