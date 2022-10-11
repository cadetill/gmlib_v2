{
  @abstract(Sets for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 11, 2022)

  The GMLib.Sets unit contains all sets used by GMLib.
}
unit GMLib.Sets;

{$I ..\gmlib.inc}

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

  // @include(..\Help\docs\GMLib.Sets.TGMAPIVer.txt)
  TGMAPIVer = (av347, av348, av349, avWeekly, avQuarterly, avBeta);

  // @include(..\Help\docs\GMLib.Sets.TGMAPILang.txt)
  TGMAPILang = (lAfrikaans, lAlbanian, lAmharic, lArabic, lArmenian, lAzerbaijani, lBasque, lBelarusian,
                lBengali, lBosnian, lBulgarian, lBurmese, lCatalan, lChinese, lChinese_Simp, lChinese_HK,
                lChinese_Trad, lCroatian, lCzech, lDanish, lDutch, lEnglish, lEnglish_Aust, lEnglish_GB,
                lEstonian, lFarsi, lFinnish, lFilipino, lFrench, lFrench_Ca, lGalician, lGeorgian, lGerman,
                lGreek, lGujarati, lHebrew, lHindi, lHungarian, lIcelandic, lIndonesian, lItalian, lJapanese,
                lKannada, lKazakh, lKhmer, lKorean, lKyrgyz, lLao, lLatvian, lLithuanian, lMacedonian,
                lMalay, lMalayalam, lMarathi, lMongolian, lNepali, lNorwegian, lPolish, lPortuguese,
                lPortuguese_Br, lPortuguese_Ptg, lPunjabi, lRomanian, lRussian, lSerbian, lSinhalese,
                lSlovak, lSlovenian, lSpanish, lSpanish_LA, lSwahili, lSwedish, lTamil, lTelugu, lThai,
                lTurkish, lUkrainian, lUrdu, lUzbek, lVietnamese, lZulu, lUndefined);

  // @include(..\Help\docs\GMLib.Sets.TGMAPIRegion.txt)
  TGMAPIRegion = (rAfghanistan, rAlbania, rAlgeria, rAmerican_Samoa, rAndorra, rAngola, rAnguilla, rAntarctica,
                  rAntigua_Barbuda, rArgentina, rArmenia, rAruba, rAscension_Island, rAustralia, rAustriam,
                  rAzerbaijan, rBahamas, rBahrain, rBangladesh, rBarbados, rBelarus, rBelgium, rBelize, rBenin,
                  rBermuda, rBhutan, rBolivia, rBosnia_Herzegovina, rBotswana, rBouvet_Island, rBrazil,
                  rBritish_Indian_OT, rBritish_Virgin_Is, rBrunei, rBulgaria, rBurkina_Faso, rBurundi, rCambodia,
                  rCameroon, rCanada, rCanary_Islands, rCape_Verde, rCaribbean_Netherlands, rCayman_Islands,
                  rCentral_African_Rep, rCeuta_Melilla, rChad, rChile, rChina, rChristmas_Island, rClipperton_Island,
                  rCocos_Islands, rColombia, rComoros, rCongo_Brazzaville, rCongo_Kinshasa, rCook_Islands,
                  rCosta_Rica, rCroatia, rCuba, rCuracao, rCyprus, rCzechia, rCote_Ivoire, rDenmark, rDiego_Garcia,
                  rDjibouti, rDominica, rDominican_Republic, rEcuador, rEgypt, rEl_Salvador, rEquatorial_Guinea,
                  rEritrea, rEstonia, rEswatini, rEthiopia, rFalkland_Islands, rFaroe_Islands, rFiji, rFinland,
                  rFrance, rFrench_Guiana, rFrench_Polynesia, rFrench_Southern_Territories, rGabon, rGambia, rGeorgia,
                  rGermany, rGhana, rGibraltar, rGreece, rGreenland, rGrenada, rGuadeloupe, rGuam, rGuatemala,
                  rGuernsey, rGuinea, rGuinea_Bissau, rGuyana, rHaiti, rHeard_McDonald, rHonduras, rHong_Kong,
                  rHungary, rIceland, rIndia, rIndonesia, rIran, rIraq, rIreland, rIsle_Man, rIsrael, rItaly, rJamaica,
                  rJapan, rJersey, rJordan, rKazakhstan, rKenya, rKiribati, rKosovo, rKuwait, rKyrgyzstan, rLaos,
                  rLatvia, rLebanon, rLesotho, rLiberia, rLibya, rLiechtenstein, rLithuania, rLuxembourg, rMacao,
                  rMadagascar, rMalawi, rMalaysia, rMaldives, rMali, rMalta, rMarshall_Islands, rMartinique,
                  rMauritania, rMauritius, rMayotte, rMexico, rMicronesia, rMoldova, rMonaco, rMongolia, rMontenegro,
                  rMontserrat, rMorocco, rMozambique, rMyanmar, rNamibia, rNauru, rNepal, rNetherlands, rNew_Caledonia,
                  rNew_Zealand, rNicaragua, rNiger, rNigeria, rNiue, rNorfolk_Island, rNorth_Korea, rNorth_Macedonia,
                  rNorthern_Mariana, rNorway, rOman, rPakistan, rPalau, rPalestine, rPanama, rPapua_New_Guinea,
                  rParaguay, rPeru, rPhilippines, rPitcairn_Islands, rPoland, rPortugal, rPuerto_Rico, rQatar,
                  rRomania, rRussia, rRwanda, rReunion, rSamoa, rSan_Marino, rSaudi_Arabia, rSenegal, rSerbia,
                  rSeychelles, rSierra_Leone, rSingapore, rSint_Maarten, rSlovakia, rSlovenia, rSolomon_Islands,
                  rSomalia, rSouth_Africa, rSouth_Georgia_South_Sandwich, rSouth_Korea, rSouth_Sudan, rSpain,
                  rSri_Lanka, rSt_Barthelemy, rSt_Helena, rSt_Kitts_Nevis, rSt_Lucia, rSt_Martin, rSt_Pierre_Miquelon,
                  rSt_Vincent_Grenadines, rSudan, rSuriname, rSvalbard_Jan_Mayen, rSweden, rSwitzerland, rSyria,
                  rSao_Tome_Principe, rTaiwan, rTajikistan, rTanzania, rThailand, rTimor_Leste, rTogo, rTokelau, rTonga,
                  rTrinidad_Tobago, rTristan_da_Cunha, rTunisia, rTurkey, rTurkmenistan, rTurks_Caicos_Islands, rTuvalu,
                  rUS_Outlying_Islands, rUS_Virgin_Islands, rUganda, rUkraine, rUnited_Arab_Emirates, rUnited_Kingdom,
                  rUnited_States, rUruguay, rUzbekistan, rVanuatu, rVatican_City, rVenezuela, rVietnam, rWallis_Futuna,
                  rWestern_Sahara, rYemen, rZambia, rZimbabwe, rAland_Islands, rUndefined);

  // @include(..\Help\docs\GMLib.Sets.TGMControlPosition.txt)
  TGMControlPosition = (cpBOTTOM_CENTER, cpBOTTOM_LEFT, cpBOTTOM_RIGHT,
                        cpLEFT_BOTTOM, cpLEFT_CENTER, cpLEFT_TOP,
                        cpRIGHT_BOTTOM, cpRIGHT_CENTER, cpRIGHT_TOP,
                        cpTOP_CENTER, cpTOP_LEFT, cpTOP_RIGHT);

  // @include(..\Help\docs\GMLib.Sets.TGMGestureHandling.txt)
  TGMGestureHandling = (ghCooperative, ghGreedy, ghNone, ghAuto);

  // @include(..\Help\docs\GMLib.Sets.TGMMapTypeId.txt)
  TGMMapTypeId = (mtHYBRID, mtROADMAP, mtSATELLITE, mtTERRAIN);
  // @include(..\Help\docs\GMLib.Sets.TGMMapTypeIds.txt)
  TGMMapTypeIds = set of TGMMapTypeId;

  // @include(..\Help\docs\GMLib.Sets.TGMMapTypeControlStyle.txt)
  TGMMapTypeControlStyle = (mtcDEFAULT, mtcDROPDOWN_MENU, mtcHORIZONTAL_BAR);

  // @include(..\Help\docs\GMLib.Sets.TGMScaleControlStyle.txt)
  TGMScaleControlStyle = (scsDEFAULT);

  // @include(..\Help\docs\GMLib.Sets.TGMAnimation.txt)
  TGMAnimation = (aniBOUNCE, aniDROP, aniNONE);

  // @include(..\Help\docs\GMLib.Sets.TGMCollisionBehavior.txt)
  TGMCollisionBehavior = (cbNONE, cbOPTIONAL_AND_HIDES_LOWER_PRIORITY, cbREQUIRED, cbREQUIRED_AND_HIDES_OPTIONAL);

  // @include(..\Help\docs\GMLib.Sets.TGMSymbolPath.txt)
  TGMSymbolPath = (spBACKWARD_CLOSED_ARROW, spBACKWARD_OPEN_ARROW, spCIRCLE, spFORWARD_CLOSED_ARROW, spFORWARD_OPEN_ARROW);

implementation

end.
