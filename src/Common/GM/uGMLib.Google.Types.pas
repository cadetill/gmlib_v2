{**
  @abstract(Google Maps specific type definitions.)
}
unit uGMLib.Google.Types;

{$I ..\..\..\gmlib.inc}

interface

type
  TGMMapId = type string;

  { Map types supported by Google Maps. }
  TGMMapTypeId = (
    mtRoadmap,
    mtSatellite,
    mtHybrid,
    mtTerrain
  );

  TGMMapTypeIds = set of TGMMapTypeId;

  { Google Maps control positions. }
  TGMControlPosition = (
    cpBlockEndInlineCenter,
    cpBlockEndInlineEnd,
    cpBlockEndInlineStart,
    cpBlockStartInlineCenter,
    cpBlockStartInlineEnd,
    cpBlockStartInlineStart,
    cpBottomCenter,
    cpBottomLeft,
    cpBottomRight,
    cpInlineEndBlockCenter,
    cpInlineEndBlockEnd,
    cpInlineEndBlockStart,
    cpInlineStartBlockCenter,
    cpInlineStartBlockEnd,
    cpInlineStartBlockStart,
    cpLeftBottom,
    cpLeftCenter,
    cpLeftTop,
    cpRightBottom,
    cpRightCenter,
    cpRightTop,
    cpTopCenter,
    cpTopLeft,
    cpTopRight
  );

  TGMMapTypeControlStyle = (
    mtcsDefault,
    mtcsDropdownMenu,
    mtcsHorizontalBar
  );

  TGMGestureHandling = (
    ghAuto,
    ghCooperative,
    ghGreedy,
    ghNone
  );

  TGMScaleControlStyle = (
    scsDefault
  );

  TGMColorScheme = (
    csLight,
    csDark,
    csFollowSystem
  );

  TGMRenderingType = (
    rtRaster,
    rtVector
  );

  { Google Maps JavaScript API loader channels. }
  TGMJavaScriptApiChannel = (
    gacWeekly,
    gacQuarterly,
    gacBeta,
    gacAlpha
  );

  { AdvancedMarkerElement specific. }
  TGMCollisionBehavior = (
    cbRequired,
    cbOptionalAndHidesLowerPriority,
    cbRequiredAndHidesOptional
  );

  TGMMarkerContentMode = (
    mcmDefault,
    mcmPin,
    mcmHtml,
    mcmLabel
  );

implementation

end.



