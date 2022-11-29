{
  @abstract(@code(google.maps.LatLngBounds) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 14, 2022)
  @lastmod(August 14, 2022)

  The GMLatLngBounds contains the implementation of TGMLatLngBounds class that encapsulate the @code(google.maps.LatLngBounds) class from Google Maps API.
}
unit GMLib.LatLngBounds;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}

  GMLib.Classes, GMLib.Sets, GMLib.LatLng, GMLib.HTMLForms;

type
  // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.txt)
  TGMLatLngBounds = class(TGMPersistentStr, IGMControlChanges)
  private
    FLang: TGMLang;
    FNE: TGMLatLng;
    FSW: TGMLatLng;
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMOwnerLang.GetOwnerLang.txt)
    function GetOwnerLang: TGMLang; override;

    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);
  public
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Create_1.txt)
    constructor Create(SWLat: Real = 0; SWLng: Real = 0; NELat: Real = 0; NELng: Real = 0; Lang: TGMLang = lnEnglish); reintroduce; overload; virtual;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Create_2.txt)
    constructor Create(SW, NE: TGMLatLng; Lang: TGMLang = lnEnglish); reintroduce; overload; virtual;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Create_3.txt)
    constructor Create(AOwner: TPersistent; SWLat: Real = 0; SWLng: Real = 0; NELat: Real = 0; NELng: Real = 0); reintroduce; overload; virtual;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Create_4.txt)
    constructor Create(AOwner: TPersistent; SW, NE: TGMLatLng); reintroduce; overload; virtual;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Contains.txt)
    function Contains(LatLng: TGMLatLng): Boolean;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.IsEqual.txt)
    function IsEqual(Other: TGMLatLngBounds): Boolean;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Extend.txt)
    procedure Extend(LatLng: TGMLatLng);
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.GetCenter.txt)
    function GetCenter: TGMLatLng;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Intersects.txt)
    function Intersects(Other: TGMLatLngBounds): Boolean;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.IsEmpty.txt)
    function IsEmpty: Boolean;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.ToJson.txt)
    function ToJson(Precision: Integer = 6): string;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.ToSpan.txt)
    function ToSpan: TGMLatLng;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.ToStr.txt)
    function ToStr(Precision: Integer = 6): string;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.ToUrlValue.txt)
    function ToUrlValue(Precision: Integer = 6): string;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.Union.txt)
    procedure Union(Other: TGMLatLngBounds);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.SW.txt)
    property SW: TGMLatLng read FSW write FSW;
    // @include(..\Help\docs\GMLib.LatLngBounds.TGMLatLngBounds.NE.txt)
    property NE: TGMLatLng read FNE write FNE;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  GMLib.Exceptions, GMLib.Transform;

{ TGMLatLngBounds }

procedure TGMLatLngBounds.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMLatLngBounds then
  begin
    SW.Assign(TGMLatLngBounds(Source).SW);
    NE.Assign(TGMLatLngBounds(Source).NE);
  end;
end;

function TGMLatLngBounds.Contains(LatLng: TGMLatLng): Boolean;
const
  StrParams = '%s,%s,%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
  TmpStr: string;
  Val: THTMLForms;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(GetOwnerLang);                                 // Owner not assigned.
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(GetOwnerLang);                               // The object (or its owner) does not support JavaScript calls.
  if not Assigned(LatLng) then
    raise EGMUnassignedObject.Create(['LatLng'], GetOwnerLang);                 // Unassigned %s object.

  Params := Format(StrParams, [LatLng.LatToStr,
                               LatLng.LngToStr,
                               FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  Intf.ExecuteJavaScript('llbContains', Params);
  begin
    Val := THTMLForms.GetData(Intf);
    TmpStr := Val.LlbResults.LlbResultsMapisnull;
    if TmpStr = '1' then
      raise EGMMapIsNull.Create(GetOwnerLang);                                  // The Map object in JavaScript is null.

    TmpStr := Val.LlbResults.LlbResultsBoolVal;
    Result := TmpStr = '1';
  end
end;

constructor TGMLatLngBounds.Create(SWLat, SWLng, NELat, NELng: Real;
  Lang: TGMLang);
begin
  inherited Create(nil);

  FSW := TGMLatLng.Create(SWLat, SWLng, False, Lang);
  FNE := TGMLatLng.Create(NELat, NELng, False, Lang);
  FLang := Lang;
end;

constructor TGMLatLngBounds.Create(AOwner: TPersistent; SW, NE: TGMLatLng);
begin
  inherited Create(AOwner);

  FSW := TGMLatLng.Create(Self, SW.Lat, SW.Lng, False);
  FNE := TGMLatLng.Create(Self, NE.Lat, NE.Lng, False);
  FLang := lnUnknown;
end;

constructor TGMLatLngBounds.Create(AOwner: TPersistent; SWLat, SWLng, NELat,
  NELng: Real);
begin
  inherited Create(AOwner);

  FSW := TGMLatLng.Create(Self, SWLat, SWLng, False);
  FNE := TGMLatLng.Create(Self, NELat, NELng, False);
  FLang := lnUnknown;
end;

constructor TGMLatLngBounds.Create(SW, NE: TGMLatLng; Lang: TGMLang);
begin
  inherited Create(nil);

  FSW := TGMLatLng.Create(SW.Lat, SW.Lng, False, Lang);
  FNE := TGMLatLng.Create(NE.Lat, NE.Lng, False, Lang);
  FLang := Lang;
end;

destructor TGMLatLngBounds.Destroy;
begin
  if Assigned(FSW) then FSW.Free;
  if Assigned(FNE) then FNE.Free;

  inherited;
end;

procedure TGMLatLngBounds.Extend(LatLng: TGMLatLng);
const
  StrParams = '%s,%s,%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
  TmpStr: string;
  Val: THTMLForms;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(GetOwnerLang);                                 // Owner not assigned.
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(GetOwnerLang);                               // The object (or its owner) does not support JavaScript calls.
  if not Assigned(LatLng) then
    raise EGMUnassignedObject.Create(['LatLng'], GetOwnerLang);                 // Unassigned %s object.

  Params := Format(StrParams, [LatLng.LatToStr,
                               LatLng.LngToStr,
                               FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  Intf.ExecuteJavaScript('llbExtend', Params);
  begin
    Val := THTMLForms.GetData(Intf);
    TmpStr := Val.LlbResults.LlbResultsMapisnull;
    if TmpStr = '1' then
      raise EGMMapIsNull.Create(GetOwnerLang);                                  // The Map object in JavaScript is null.

    TmpStr := Val.LlbResults.LlbResultsSwLat;
    FSW.Lat := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsSwLng;
    FSW.Lng := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsNeLat;
    FNE.Lat := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsNeLng;
    FNE.Lng := TGMTransform.GetStrToDouble(TmpStr);
  end;
end;

function TGMLatLngBounds.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/coordinates#LatLngBounds';
end;

function TGMLatLngBounds.GetCenter: TGMLatLng;
const
  StrParams = '%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
  TmpStr: string;
  Val: THTMLForms;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(GetOwnerLang);                                 // Owner not assigned.
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(GetOwnerLang);                               // The object (or its owner) does not support JavaScript calls.

  Result := TGMLatLng.Create(0, 0, False, FLang);

  Params := Format(StrParams, [FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  Intf.ExecuteJavaScript('llbGetCenter', Params);
  begin
    Val := THTMLForms.GetData(Intf);
    TmpStr := Val.LlbResults.LlbResultsMapisnull;
    if TmpStr = '1' then
      raise EGMMapIsNull.Create(GetOwnerLang);                                  // The Map object in JavaScript is null.

    TmpStr := Val.LlbResults.LlbResultsLat;
    Result.Lat := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsLng;
    Result.Lng := TGMTransform.GetStrToDouble(TmpStr);
  end
end;

function TGMLatLngBounds.GetOwnerLang: TGMLang;
begin
  Result := FLang;
  if FLang = lnUnknown then
    inherited;
end;

function TGMLatLngBounds.Intersects(Other: TGMLatLngBounds): Boolean;
const
  StrParams = '%s,%s,%s,%s,%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
  TmpStr: string;
  Val: THTMLForms;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(GetOwnerLang);                                 // Owner not assigned.
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(GetOwnerLang);                               // The object (or its owner) does not support JavaScript calls.
  if not Assigned(Other) then
    raise EGMUnassignedObject.Create(['Other'], GetOwnerLang);                  // Unassigned %s object.

  Params := Format(StrParams, [Other.SW.LatToStr,
                               Other.SW.LngToStr,
                               Other.NE.LatToStr,
                               Other.NE.LngToStr,
                               FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  Intf.ExecuteJavaScript('llbIntersects', Params);
  begin
    Val := THTMLForms.GetData(Intf);
    TmpStr := Val.LlbResults.LlbResultsMapisnull;
    if TmpStr = '1' then
      raise EGMMapIsNull.Create(GetOwnerLang);                                  // The Map object in JavaScript is null.

    TmpStr := Val.LlbResults.llbResultsBoolVal;
    Result := TmpStr = '1';
  end
end;

function TGMLatLngBounds.IsEmpty: Boolean;
begin
  Result := FSW.IsEqual(FNE);
end;

function TGMLatLngBounds.IsEqual(Other: TGMLatLngBounds): Boolean;
begin
  Result := FNE.IsEqual(Other.NE) and FSW.IsEqual(Other.SW);
end;

procedure TGMLatLngBounds.PropertyChanged(Prop: TPersistent; PropName: string);
begin
  ControlChanges(PropName);
end;

function TGMLatLngBounds.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [FNE.PropToString,
                         FSW.PropToString
                         ]);
end;

function TGMLatLngBounds.ToJson(Precision: Integer): string;
const
  Str = '{"NE": %s, "SW": %s}';
begin
  Result := Format(Str, [FSW.ToJson(Precision), FNE.ToJson(Precision)]);
end;

function TGMLatLngBounds.ToSpan: TGMLatLng;
const
  StrParams = '%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
  TmpStr: string;
  Val: THTMLForms;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(GetOwnerLang);                                 // Owner not assigned.
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(GetOwnerLang);                               // The object (or its owner) does not support JavaScript calls.

  Result := TGMLatLng.Create(0, 0, False, FLang);

  Params := Format(StrParams, [FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  Intf.ExecuteJavaScript('llbToSpan', Params);
  begin
    Val := THTMLForms.GetData(Intf);
    TmpStr := Val.LlbResults.LlbResultsMapisnull;
    if TmpStr = '1' then
      raise EGMMapIsNull.Create(GetOwnerLang);                                  // The Map object in JavaScript is null.

    TmpStr := Val.LlbResults.LlbResultsLat;
    Result.Lat := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsLng;
    Result.Lng := TGMTransform.GetStrToDouble(TmpStr);
  end
end;

function TGMLatLngBounds.ToStr(Precision: Integer): string;
const
  Str = '(%s, %s)';
begin
  Result := Format(Str, [FSW.ToStr(Precision), FNE.ToStr(Precision)]);
end;

function TGMLatLngBounds.ToUrlValue(Precision: Integer): string;
const
  Str = '%s,%s';
begin
  Result := Format(Str, [FSW.ToUrlValue(Precision), FNE.ToUrlValue(Precision)]);
end;

procedure TGMLatLngBounds.Union(Other: TGMLatLngBounds);
const
  StrParams = '%s,%s,%s,%s,%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
  TmpStr: string;
  Val: THTMLForms;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(GetOwnerLang);                                 // Owner not assigned.
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(GetOwnerLang);                               // The object (or its owner) does not support JavaScript calls.
  if not Assigned(Other) then
    raise EGMUnassignedObject.Create(['Other'], GetOwnerLang);                  // Unassigned %s object.

  Params := Format(StrParams, [Other.SW.LatToStr,
                               Other.SW.LngToStr,
                               Other.NE.LatToStr,
                               Other.NE.LngToStr,
                               FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  Intf.ExecuteJavaScript('llbUnion', Params);
  begin
    Val := THTMLForms.GetData(Intf);
    TmpStr := Val.LlbResults.LlbResultsMapisnull;
    if TmpStr = '1' then
      raise EGMMapIsNull.Create(GetOwnerLang);                                  // The Map object in JavaScript is null.

    TmpStr := Val.LlbResults.LlbResultsSwLat;
    FSW.Lat := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsSwLng;
    FSW.Lng := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsNeLat;
    FNE.Lat := TGMTransform.GetStrToDouble(TmpStr);
    TmpStr := Val.LlbResults.LlbResultsNeLng;
    FNE.Lng := TGMTransform.GetStrToDouble(TmpStr);
  end;
end;

end.
