{
  @abstract(Transform a data from Delphi to JS ans JS to Delphi.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 2, 2022)

  The GMLib.Transform unit contains all functions needed to transform a JavaScript value to Delphi value and viceversa.
}
unit GMLib.Transform;

interface

uses
  GMLib.Sets;

type
  // @include(..\Help\docs\GMLib.Transform.TGMTransform.txt)
  TGMTransform = record
  public
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.GMBoolToStr.txt)
    class function GMBoolToStr(Value: Boolean; UseBoolStrs: Boolean = False): string; static;

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.PositionToStr.txt)
    class function PositionToStr(Value: TGMControlPosition): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.GestureHandlingToStr.txt)
    class function GestureHandlingToStr(Value: TGMGestureHandling): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeIdToStr.txt)
    class function MapTypeIdToStr(Value: TGMMapTypeId): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeIdsToStr.txt)
    class function MapTypeIdsToStr(Values: TGMMapTypeIds; Delimiter: Char = ';'): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.MapTypeControlStyleToStr.txt)
    class function MapTypeControlStyleToStr(Value: TGMMapTypeControlStyle): string; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.ScaleControlStyleToStr.txt)
    class function ScaleControlStyleToStr(Value: TGMScaleControlStyle): string; static;

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToPosition.txt)
    class function StrToPosition(Value: string): TGMControlPosition; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToGestureHandling.txt)
    class function StrToGestureHandling(Value: string): TGMGestureHandling; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToMapTypeId.txt)
    class function StrToMapTypeId(Value: string): TGMMapTypeId; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToMapTypeControlStyle.txt)
    class function StrToMapTypeControlStyle(Value: string): TGMMapTypeControlStyle; static;
    // @include(..\Help\docs\GMLib.Transform.TGMTransform.StrToScaleControlStyle.txt)
    class function StrToScaleControlStyle(Value: string): TGMScaleControlStyle; static;

(*

    // @include(..\Help\docs\GMLib.Transform.TGMTransform.APILangToStr.txt)
    class function APILangToStr(APILang: TGMAPILang): string; static;
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
  System.TypInfo
  {$ELSE}
  TypInfo
  {$ENDIF}
  ;


{ TGMTransform }

class function TGMTransform.GestureHandlingToStr(Value: TGMGestureHandling): string;
begin
  Result := GetEnumName(TypeInfo(TGMGestureHandling), Ord(Value));
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

  if mtOSM in Values then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + TGMTransform.MapTypeIdToStr(mtOSM);
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

class function TGMTransform.StrToGestureHandling(Value: string): TGMGestureHandling;
begin
  Result := TGMGestureHandling(GetEnumValue(TypeInfo(TGMGestureHandling), Value));
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

end.
