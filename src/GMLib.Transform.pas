{
  @abstract(Transform a data from Delphi to JS ans JS to Delphi.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 21, 2022)

  The GMLib.Transform unit contains all functions needed to transform a JavaScript value to Delphi value and viceversa.
}
unit GMLib.Transform;

{$I ..\gmlib.inc}

interface

uses
  GMLib.Sets;

type
  // @include(..\Help\docs\GMLib.Transform.TGMTransform.txt)
  TGMTransform = class
  public
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.GMBoolToStr.txt)
    class function GMBoolToStr(Value: Boolean; UseBoolStrs: Boolean = False): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.GetStrToDouble.txt)
    class function GetStrToDouble(Value: string): Double;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.GetDoubleToStr.txt)
    class function GetDoubleToStr(Value: Double): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.GetStrToInteger.txt)
    class function GetStrToInteger(Value: string; Default: Integer = 0): Integer;

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.APIVerToStr.txt)
    class function APIVerToStr(Value: TGMAPIVer): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.APILangToStr.txt)
    class function APILangToStr(Value: TGMAPILang): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.APIRegionToStr.txt)
    class function APIRegionToStr(Value: TGMAPIRegion): string;

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToAPILang.txt)
    class function StrToAPILang(Value: string): TGMAPILang;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToAPIRegion.txt)
    class function StrToAPIRegion(Value: string): TGMAPIRegion;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToAPIVer.txt)
    class function StrToAPIVer(Value: string): TGMAPIVer;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToLang.txt)
    class function StrToLang(Value: string): TGMLang;

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.PositionToStr.txt)
    class function PositionToStr(Value: TGMControlPosition): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.GestureHandlingToStr.txt)
    class function GestureHandlingToStr(Value: TGMGestureHandling): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeIdToStr.txt)
    class function MapTypeIdToStr(Value: TGMMapTypeId): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeIdsToStr.txt)
    class function MapTypeIdsToStr(Values: TGMMapTypeIds; Delimiter: Char = ';'): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeControlStyleToStr.txt)
    class function MapTypeControlStyleToStr(Value: TGMMapTypeControlStyle): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.ScaleControlStyleToStr.txt)
    class function ScaleControlStyleToStr(Value: TGMScaleControlStyle): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.SymbolPathToStr.txt)
    class function SymbolPathToStr(Value: TGMSymbolPath): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.AnimationToStr.txt)
    class function AnimationToStr(Value: TGMAnimation): string;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.CollisionBehaviorToStr.txt)
    class function CollisionBehaviorToStr(Value: TGMCollisionBehavior): string;

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToPosition.txt)
    class function StrToPosition(Value: string): TGMControlPosition;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToGestureHandling.txt)
    class function StrToGestureHandling(Value: string): TGMGestureHandling;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToMapTypeId.txt)
    class function StrToMapTypeId(Value: string): TGMMapTypeId;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToMapTypeControlStyle.txt)
    class function StrToMapTypeControlStyle(Value: string): TGMMapTypeControlStyle;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToScaleControlStyle.txt)
    class function StrToScaleControlStyle(Value: string): TGMScaleControlStyle;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToSymbolPath.txt)
    class function StrToSymbolPath(Value: string): TGMSymbolPath;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToAnimation.txt)
    class function StrToAnimation(Value: string): TGMAnimation;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToCollisionBehavior.txt)
    class function StrToCollisionBehavior(Value: string): TGMCollisionBehavior;

(*

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.VisibilityToStr.txt)
    class function VisibilityToStr(Visibility: TGMVisibility): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToVisibility.txt)
    class function StrToVisibility(Visibility: string): TGMVisibility; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.ScaleControlStyleToStr.txt)
    class function ScaleControlStyleToStr(ScaleControlStyle: TGMScaleControlStyle): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeStyleElementTypeToStr.txt)
    class function MapTypeStyleElementTypeToStr(MapTypeStyleElementType: TGMMapTypeStyleElementType): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeStyleFeatureTypeToStr.txt)
    class function MapTypeStyleFeatureTypeToStr(MapTypeStyleFeatureType: TGMMapTypeStyleFeatureType): string; static;
*)
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.TypInfo, System.SysUtils
  {$ELSE}
  TypInfo, SysUtils
  {$ENDIF}
  ;


{ TGMTransform }

class function TGMTransform.AnimationToStr(Value: TGMAnimation): string;
begin
  Result := GetEnumName(TypeInfo(TGMAnimation), Ord(Value));
end;

class function TGMTransform.APILangToStr(Value: TGMAPILang): string;
begin
  case Value of
    lAfrikaans: Result := 'af';
    lAlbanian: Result := 'sq';
    lAmharic: Result := 'am';
    lArabic: Result := 'ar';
    lArmenian: Result := 'hy';
    lAzerbaijani: Result := 'az';
    lBasque: Result := 'eu';
    lBelarusian: Result := 'be';
    lBengali: Result := 'bn';
    lBosnian: Result := 'bs';
    lBulgarian: Result := 'bg';
    lBurmese: Result := 'my';
    lCatalan: Result := 'ca';
    lChinese: Result := 'zh';
    lChinese_Simp: Result := 'zh-CN';
    lChinese_HK: Result := 'zh-HK';
    lChinese_Trad: Result := 'zh-TW';
    lCroatian: Result := 'hr';
    lCzech: Result := 'cs';
    lDanish: Result := 'da';
    lDutch: Result := 'nl';
    lEnglish: Result := 'en';
    lEnglish_Aust: Result := 'en-AU';
    lEnglish_GB: Result := 'en-GB';
    lEstonian: Result := 'et';
    lFarsi: Result := 'fa';
    lFinnish: Result := 'fi';
    lFilipino: Result := 'fil';
    lFrench: Result := 'fr';
    lFrench_Ca: Result := 'fr-CA';
    lGalician: Result := 'gl';
    lGeorgian: Result := 'ka';
    lGerman: Result := 'de';
    lGreek: Result := 'el';
    lGujarati: Result := 'gu';
    lHebrew: Result := 'iw';
    lHindi: Result := 'hi';
    lHungarian: Result := 'hu';
    lIcelandic: Result := 'is';
    lIndonesian: Result := 'id';
    lItalian: Result := 'it';
    lJapanese: Result := 'ja';
    lKannada: Result := 'kn';
    lKazakh: Result := 'kk';
    lKhmer: Result := 'km';
    lKorean: Result := 'ko';
    lKyrgyz: Result := 'ky';
    lLao: Result := 'lo';
    lLatvian: Result := 'lv';
    lLithuanian: Result := 'lt';
    lMacedonian: Result := 'mk';
    lMalay: Result := 'ms';
    lMalayalam: Result := 'ml';
    lMarathi: Result := 'mr';
    lMongolian: Result := 'mn';
    lNepali: Result := 'ne';
    lNorwegian: Result := 'no';
    lPolish: Result := 'pl';
    lPortuguese: Result := 'pt';
    lPortuguese_Br: Result := 'pt-BR';
    lPortuguese_Ptg: Result := 'pt-PT';
    lPunjabi: Result := 'pa';
    lRomanian: Result := 'ro';
    lRussian: Result := 'ru';
    lSerbian: Result := 'sr';
    lSinhalese: Result := 'si';
    lSlovak: Result := 'sk';
    lSlovenian: Result := 'sl';
    lSpanish: Result := 'es';
    lSpanish_LA: Result := 'es-419';
    lSwahili: Result := 'sw';
    lSwedish: Result := 'sv';
    lTamil: Result := 'ta';
    lTelugu: Result := 'te';
    lThai: Result := 'th';
    lTurkish: Result := 'tr';
    lUkrainian: Result := 'uk';
    lUrdu: Result := 'ur';
    lUzbek: Result := 'uz';
    lVietnamese: Result := 'vi';
    lZulu: Result := 'zu';
    lUndefined: Result := 'en';
  end;
end;

class function TGMTransform.APIRegionToStr(Value: TGMAPIRegion): string;
begin
  case Value of
    rAfghanistan: Result := 'AF';
    rAlbania: Result := 'AL';
    rAlgeria: Result := 'DZ';
    rAmerican_Samoa: Result := 'AS';
    rAndorra: Result := 'AD';
    rAngola: Result := 'AO';
    rAnguilla: Result := 'AI';
    rAntarctica: Result := 'AQ';
    rAntigua_Barbuda: Result := 'AG';
    rArgentina: Result := 'AR';
    rArmenia: Result := 'AM';
    rAruba: Result := 'AW';
    rAscension_Island: Result := 'AC';
    rAustralia: Result := 'AU';
    rAustriam: Result := 'AT';
    rAzerbaijan: Result := 'AZ';
    rBahamas: Result := 'BS';
    rBahrain: Result := 'BH';
    rBangladesh: Result := 'BD';
    rBarbados: Result := 'BB';
    rBelarus: Result := 'BY';
    rBelgium: Result := 'BE';
    rBelize: Result := 'BZ';
    rBenin: Result := 'BJ';
    rBermuda: Result := 'BM';
    rBhutan: Result := 'BT';
    rBolivia: Result := 'BO';
    rBosnia_Herzegovina: Result := 'BA';
    rBotswana: Result := 'BW';
    rBouvet_Island: Result := 'BV';
    rBrazil: Result := 'BR';
    rBritish_Indian_OT: Result := 'IO';
    rBritish_Virgin_Is: Result := 'VG';
    rBrunei: Result := 'BN';
    rBulgaria: Result := 'BG';
    rBurkina_Faso: Result := 'BF';
    rBurundi: Result := 'BI';
    rCambodia: Result := 'KH';
    rCameroon: Result := 'CM';
    rCanada: Result := 'CA';
    rCanary_Islands: Result := 'IC';
    rCape_Verde: Result := 'CV';
    rCaribbean_Netherlands: Result := 'BQ';
    rCayman_Islands: Result := 'KY';
    rCentral_African_Rep: Result := 'CF';
    rCeuta_Melilla: Result := 'EA';
    rChad: Result := 'TD';
    rChile: Result := 'CL';
    rChina: Result := 'CN';
    rChristmas_Island: Result := 'CX';
    rClipperton_Island: Result := 'CP';
    rCocos_Islands: Result := 'CC';
    rColombia: Result := 'CO';
    rComoros: Result := 'KM';
    rCongo_Brazzaville: Result := 'CG';
    rCongo_Kinshasa: Result := 'CD';
    rCook_Islands: Result := 'CK';
    rCosta_Rica: Result := 'CR';
    rCroatia: Result := 'HR';
    rCuba: Result := 'CU';
    rCuracao: Result := 'CW';
    rCyprus: Result := 'CY';
    rCzechia: Result := 'CZ';
    rCote_Ivoire: Result := 'CI';
    rDenmark: Result := 'DK';
    rDiego_Garcia: Result := 'DG';
    rDjibouti: Result := 'DJ';
    rDominica: Result := 'DM';
    rDominican_Republic: Result := 'DO';
    rEcuador: Result := 'EC';
    rEgypt: Result := 'EG';
    rEl_Salvador: Result := 'SV';
    rEquatorial_Guinea: Result := 'GQ';
    rEritrea: Result := 'ER';
    rEstonia: Result := 'EE';
    rEswatini: Result := 'SZ';
    rEthiopia: Result := 'ET';
    rFalkland_Islands: Result := 'FK';
    rFaroe_Islands: Result := 'FO';
    rFiji: Result := 'FJ';
    rFinland: Result := 'FI';
    rFrance: Result := 'FR';
    rFrench_Guiana: Result := 'GF';
    rFrench_Polynesia: Result := 'PF';
    rFrench_Southern_Territories: Result := 'TF';
    rGabon: Result := 'GA';
    rGambia: Result := 'GM';
    rGeorgia: Result := 'GE';
    rGermany: Result := 'DE';
    rGhana: Result := 'GH';
    rGibraltar: Result := 'GI';
    rGreece: Result := 'GR';
    rGreenland: Result := 'GL';
    rGrenada: Result := 'GD';
    rGuadeloupe: Result := 'GP';
    rGuam: Result := 'GU';
    rGuatemala: Result := 'GT';
    rGuernsey: Result := 'GG';
    rGuinea: Result := 'GN';
    rGuinea_Bissau: Result := 'GW';
    rGuyana: Result := 'GY';
    rHaiti: Result := 'HT';
    rHeard_McDonald: Result := 'HM';
    rHonduras: Result := 'HN';
    rHong_Kong: Result := 'HK';
    rHungary: Result := 'HU';
    rIceland: Result := 'IS';
    rIndia: Result := 'IN';
    rIndonesia: Result := 'ID';
    rIran: Result := 'IR';
    rIraq: Result := 'IQ';
    rIreland: Result := 'IE';
    rIsle_Man: Result := 'IM';
    rIsrael: Result := 'IL';
    rItaly: Result := 'IT';
    rJamaica: Result := 'JM';
    rJapan: Result := 'JP';
    rJersey: Result := 'JE';
    rJordan: Result := 'JO';
    rKazakhstan: Result := 'KZ';
    rKenya: Result := 'KE';
    rKiribati: Result := 'KI';
    rKosovo: Result := 'XK';
    rKuwait: Result := 'KW';
    rKyrgyzstan: Result := 'KG';
    rLaos: Result := 'LA';
    rLatvia: Result := 'LV';
    rLebanon: Result := 'LB';
    rLesotho: Result := 'LS';
    rLiberia: Result := 'LR';
    rLibya: Result := 'LY';
    rLiechtenstein: Result := 'LI';
    rLithuania: Result := 'LT';
    rLuxembourg: Result := 'LU';
    rMacao: Result := 'MO';
    rMadagascar: Result := 'MG';
    rMalawi: Result := 'MW';
    rMalaysia: Result := 'MY';
    rMaldives: Result := 'MV';
    rMali: Result := 'ML';
    rMalta: Result := 'MT';
    rMarshall_Islands: Result := 'MH';
    rMartinique: Result := 'MQ';
    rMauritania: Result := 'MR';
    rMauritius: Result := 'MU';
    rMayotte: Result := 'YT';
    rMexico: Result := 'MX';
    rMicronesia: Result := 'FM';
    rMoldova: Result := 'MD';
    rMonaco: Result := 'MC';
    rMongolia: Result := 'MN';
    rMontenegro: Result := 'ME';
    rMontserrat: Result := 'MS';
    rMorocco: Result := 'MA';
    rMozambique: Result := 'MZ';
    rMyanmar: Result := 'MM';
    rNamibia: Result := 'NA';
    rNauru: Result := 'NR';
    rNepal: Result := 'NP';
    rNetherlands: Result := 'NL';
    rNew_Caledonia: Result := 'NC';
    rNew_Zealand: Result := 'NZ';
    rNicaragua: Result := 'NI';
    rNiger: Result := 'NE';
    rNigeria: Result := 'NG';
    rNiue: Result := 'NU';
    rNorfolk_Island: Result := 'NF';
    rNorth_Korea: Result := 'KP';
    rNorth_Macedonia: Result := 'MK';
    rNorthern_Mariana: Result := 'MP';
    rNorway: Result := 'NO';
    rOman: Result := 'OM';
    rPakistan: Result := 'PK';
    rPalau: Result := 'PW';
    rPalestine: Result := 'PS';
    rPanama: Result := 'PA';
    rPapua_New_Guinea: Result := 'PG';
    rParaguay: Result := 'PY';
    rPeru: Result := 'PE';
    rPhilippines: Result := 'PH';
    rPitcairn_Islands: Result := 'PN';
    rPoland: Result := 'PL';
    rPortugal: Result := 'PT';
    rPuerto_Rico: Result := 'PR';
    rQatar: Result := 'QA';
    rRomania: Result := 'RO';
    rRussia: Result := 'RU';
    rRwanda: Result := 'RW';
    rReunion: Result := 'RE';
    rSamoa: Result := 'WS';
    rSan_Marino: Result := 'SM';
    rSaudi_Arabia: Result := 'SA';
    rSenegal: Result := 'SN';
    rSerbia: Result := 'RS';
    rSeychelles: Result := 'SC';
    rSierra_Leone: Result := 'SL';
    rSingapore: Result := 'SG';
    rSint_Maarten: Result := 'SX';
    rSlovakia: Result := 'SK';
    rSlovenia: Result := 'SI';
    rSolomon_Islands: Result := 'SB';
    rSomalia: Result := 'SO';
    rSouth_Africa: Result := 'ZA';
    rSouth_Georgia_South_Sandwich: Result := 'GS';
    rSouth_Korea: Result := 'KR';
    rSouth_Sudan: Result := 'SS';
    rSpain: Result := 'ES';
    rSri_Lanka: Result := 'LK';
    rSt_Barthelemy: Result := 'BL';
    rSt_Helena: Result := 'SH';
    rSt_Kitts_Nevis: Result := 'KN';
    rSt_Lucia: Result := 'LC';
    rSt_Martin: Result := 'MF';
    rSt_Pierre_Miquelon: Result := 'PM';
    rSt_Vincent_Grenadines: Result := 'VC';
    rSudan: Result := 'SD';
    rSuriname: Result := 'SR';
    rSvalbard_Jan_Mayen: Result := 'SJ';
    rSweden: Result := 'SE';
    rSwitzerland: Result := 'CH';
    rSyria: Result := 'SY';
    rSao_Tome_Principe: Result := 'ST';
    rTaiwan: Result := 'TW';
    rTajikistan: Result := 'TJ';
    rTanzania: Result := 'TZ';
    rThailand: Result := 'TH';
    rTimor_Leste: Result := 'TL';
    rTogo: Result := 'TG';
    rTokelau: Result := 'TK';
    rTonga: Result := 'TO';
    rTrinidad_Tobago: Result := 'TT';
    rTristan_da_Cunha: Result := 'TA';
    rTunisia: Result := 'TN';
    rTurkey: Result := 'TR';
    rTurkmenistan: Result := 'TM';
    rTurks_Caicos_Islands: Result := 'TC';
    rTuvalu: Result := 'TV';
    rUS_Outlying_Islands: Result := 'UM';
    rUS_Virgin_Islands: Result := 'VI';
    rUganda: Result := 'UG';
    rUkraine: Result := 'UA';
    rUnited_Arab_Emirates: Result := 'AE';
    rUnited_Kingdom: Result := 'GB';
    rUnited_States: Result := 'US';
    rUruguay: Result := 'UY';
    rUzbekistan: Result := 'UZ';
    rVanuatu: Result := 'VU';
    rVatican_City: Result := 'VA';
    rVenezuela: Result := 'VE';
    rVietnam: Result := 'VN';
    rWallis_Futuna: Result := 'WF';
    rWestern_Sahara: Result := 'EH';
    rYemen: Result := 'YE';
    rZambia: Result := 'ZM';
    rZimbabwe: Result := 'ZW';
    rAland_Islands: Result := 'AX';
    rUndefined: Result := 'ES';
  end;
end;

class function TGMTransform.APIVerToStr(Value: TGMAPIVer): string;
begin
  case Value of
    av347: Result := '3.47';
    av348: Result := '3.48';
    av349: Result := '3.49';
    avWeekly: Result := 'weekly';
    avQuarterly: Result := 'quarterly';
    avBeta: Result := 'beta';
  end;
end;

class function TGMTransform.CollisionBehaviorToStr(
  Value: TGMCollisionBehavior): string;
begin
  Result := GetEnumName(TypeInfo(TGMCollisionBehavior), Ord(Value));
end;

class function TGMTransform.GestureHandlingToStr(Value: TGMGestureHandling): string;
begin
  Result := GetEnumName(TypeInfo(TGMGestureHandling), Ord(Value));
end;

class function TGMTransform.GetDoubleToStr(Value: Double): string;
begin
  Result := FloatToStr(Value);

  Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
end;

class function TGMTransform.GetStrToDouble(Value: string): Double;
var
  Val: Extended;
begin
  Result := 0;

  if {$IFDEF DELPHIXE}FormatSettings.DecimalSeparator{$ELSE}DecimalSeparator{$ENDIF} = ',' then
    Value := StringReplace(Value, '.', ',', [rfReplaceAll]);
  if (Value <> '') and TryStrToFloat(Value, Val) then
    Result := Val;
end;

class function TGMTransform.GetStrToInteger(Value: string; Default: Integer): Integer;
var
  Val: Integer;
begin
  Result := Default;

  if (Value <> '') and TryStrToInt(Value, Val) then
    Result := Val;
end;

class function TGMTransform.GMBoolToStr(Value, UseBoolStrs: Boolean): string;
const
  cSimpleBoolStrs: array [boolean] of string = ('0', '-1');
begin
  if UseBoolStrs then
  begin
    if Value then Result := 'true'
    else Result := 'false';
  end
  else
    Result := cSimpleBoolStrs[Value];
end;

class function TGMTransform.MapTypeControlStyleToStr(Value: TGMMapTypeControlStyle): string;
begin
  Result := GetEnumName(TypeInfo(TGMMapTypeControlStyle), Ord(Value));
end;

class function TGMTransform.MapTypeIdsToStr(Values: TGMMapTypeIds;
  Delimiter: Char): string;
begin
  Result := '';

  if mtHYBRID in Values then
    Result := Result + TGMTransform.MapTypeIdToStr(mtHYBRID);

  if mtROADMAP in Values then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + TGMTransform.MapTypeIdToStr(mtROADMAP);
  end;

  if mtSATELLITE in Values then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + TGMTransform.MapTypeIdToStr(mtSATELLITE);
  end;

  if mtTERRAIN in Values then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + TGMTransform.MapTypeIdToStr(mtTERRAIN);
  end;
end;

class function TGMTransform.MapTypeIdToStr(Value: TGMMapTypeId): string;
begin
  Result := GetEnumName(TypeInfo(TGMMapTypeId), Ord(Value));
end;

class function TGMTransform.PositionToStr(Value: TGMControlPosition): string;
begin
  Result := GetEnumName(TypeInfo(TGMControlPosition), Ord(Value));
end;

class function TGMTransform.ScaleControlStyleToStr(Value: TGMScaleControlStyle): string;
begin
  Result := GetEnumName(TypeInfo(TGMScaleControlStyle), Ord(Value));
end;

class function TGMTransform.StrToAnimation(Value: string): TGMAnimation;
begin
  Result := TGMAnimation(GetEnumValue(TypeInfo(TGMAnimation), Value));
end;

class function TGMTransform.StrToAPILang(Value: string): TGMAPILang;
begin
  Result := TGMAPILang(GetEnumValue(TypeInfo(TGMAPILang), Value));
end;

class function TGMTransform.StrToAPIRegion(Value: string): TGMAPIRegion;
begin
  Result := TGMAPIRegion(GetEnumValue(TypeInfo(TGMAPIRegion), Value));
end;

class function TGMTransform.StrToAPIVer(Value: string): TGMAPIVer;
begin
  Result := TGMAPIVer(GetEnumValue(TypeInfo(TGMAPIVer), Value));
end;

class function TGMTransform.StrToCollisionBehavior(
  Value: string): TGMCollisionBehavior;
begin
  Result := TGMCollisionBehavior(GetEnumValue(TypeInfo(TGMCollisionBehavior), Value));
end;

class function TGMTransform.StrToGestureHandling(Value: string): TGMGestureHandling;
begin
  Result := TGMGestureHandling(GetEnumValue(TypeInfo(TGMGestureHandling), Value));
end;

class function TGMTransform.StrToLang(Value: string): TGMLang;
begin
  Result := TGMLang(GetEnumValue(TypeInfo(TGMLang), Value));
end;

class function TGMTransform.StrToMapTypeControlStyle(Value: string): TGMMapTypeControlStyle;
begin
  Result := TGMMapTypeControlStyle(GetEnumValue(TypeInfo(TGMMapTypeControlStyle), Value));
end;

class function TGMTransform.StrToMapTypeId(Value: string): TGMMapTypeId;
begin
  Result := TGMMapTypeId(GetEnumValue(TypeInfo(TGMMapTypeId), Value));
end;

class function TGMTransform.StrToPosition(Value: string): TGMControlPosition;
begin
  Result := TGMControlPosition(GetEnumValue(TypeInfo(TGMControlPosition), Value));
end;

class function TGMTransform.StrToScaleControlStyle(Value: string): TGMScaleControlStyle;
begin
  Result := TGMScaleControlStyle(GetEnumValue(TypeInfo(TGMScaleControlStyle), Value));
end;

class function TGMTransform.StrToSymbolPath(Value: string): TGMSymbolPath;
begin
  Result := TGMSymbolPath(GetEnumValue(TypeInfo(TGMSymbolPath), Value));
end;

class function TGMTransform.SymbolPathToStr(Value: TGMSymbolPath): string;
begin
  Result := GetEnumName(TypeInfo(TGMSymbolPath), Ord(Value));
end;

end.
