{
  @abstract(@code(google.maps.LatLngBounds) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(October 1, 2015)
  @lastmod(October 1, 2015)

  The GMLatLngBounds contains the implementation of TGMLatLngBounds class that encapsulate the @code(google.maps.LatLngBounds) class from Google Maps API.
}
unit GMLatLngBounds;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}

  GMClasses, GMSets, GMLatLng;

type
  {
    @abstract(A TGMLatLngBounds instance represents a rectangle in geographical coordinates, including one that crosses the 180 degrees longitudinal meridian.)
    More information at https://developers.google.com/maps/documentation/javascript/reference#LatLngBounds
  }
  TGMLatLngBounds = class(TGMPersistentStr, IGMControlChanges)
  private
    FLang: TGMLang;
    FNE: TGMLatLng;
    FSW: TGMLatLng;
  protected
    // Returns the Lang of the Owner.@br@br If Owner is not assigned or not supports IGMOwnerLang interface then returns @code(lnEnglish).
    // @return TLang of the owner object.
    function GetOwnerLang: TGMLang; override;

    // @exclude
    function GetAPIUrl: string; override;

    // Method to call of the owner object when changes a property of the object.
    // @param Prop Object property that has changed.
    procedure PropertyChanged(Prop: TPersistent);
  public
    // Constructor class.
    // @param SWLat South-west latitude. Default 0.
    // @param SWLng South-west longitude. Default 0.
    // @param NELat North-east latitude. Default 0.
    // @param NELng North-east longitude. Default 0.
    // @param Lang TLang to use in exceptions.
    constructor Create(SWLat: Real = 0; SWLng: Real = 0; NELat: Real = 0; NELng: Real = 0; Lang: TGMLang = lnEnglish); reintroduce; overload; virtual;
    // Constructor class.
    // @param SW South-west corner.
    // @param NE North-east corner.
    // @param Lang TLang to use in exceptions.
    constructor Create(SW, NE: TGMLatLng; Lang: TGMLang = lnEnglish); reintroduce; overload; virtual;
    // Constructor class.
    // @param AOwner Owner of the object.
    // @param SWLat South-west latitude. Default 0.
    // @param SWLng South-west longitude. Default 0.
    // @param NELat North-east latitude. Default 0.
    // @param NELng North-east longitude. Default 0.
    constructor Create(AOwner: TPersistent; SWLat: Real = 0; SWLng: Real = 0; NELat: Real = 0; NELng: Real = 0); reintroduce; overload; virtual;
    // Constructor class.
    // @param AOwner Owner of the object.
    // @param SW South-west corner.
    // @param NE North-east corner.
    constructor Create(AOwner: TPersistent; SW, NE: TGMLatLng); reintroduce; overload; virtual;
    // Destructor class.
    destructor Destroy; override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Extends the bounds to contain the given point.
    // @param LatLng TGMLatLng to contain.
    // @raises EGMWithoutOwner This exception is raised if the object don't have a owner.
    // @raises EGMOwnerWithoutJS This exception is raised if the owner can't execute JavaScript functions.
    // @raises EGMJSError This exception is raised if an error occurred executing JavaScript function.
    // @raises EGMUnassignedObject This exception is raised if LanLng param is unassigned.
    procedure Extend(LatLng: TGMLatLng);
    // Extends this bounds to contain the union of this and the given bounds.
    // @param Other TGMLatLngBounds to union.
    // @raises EGMWithoutOwner This exception is raised if the object don't have a owner.
    // @raises EGMOwnerWithoutJS This exception is raised if the owner can't execute JavaScript functions.
    // @raises EGMJSError This exception is raised if an error occurred executing JavaScript function.
    // @raises EGMUnassignedObject This exception is raised if LanLng param is unassigned.
    procedure Union(Other: TGMLatLngBounds);
    // Get the center of current bounds.
    // @param LatLng TGMLatLng representing the centre.
    // @raises EGMWithoutOwner This exception is raised if the object don't have a owner.
    // @raises EGMOwnerWithoutJS This exception is raised if the owner can't execute JavaScript functions.
    // @raises EGMJSError This exception is raised if an error occurred executing JavaScript function.
    procedure GetCenter(LatLng: TGMLatLng);
    // Converts the given bounds to a lat/lng span.
    // @param LatLng TGMLatLng with the span.
    // @raises EGMWithoutOwner This exception is raised if the object don't have a owner.
    // @raises EGMOwnerWithoutJS This exception is raised if the owner can't execute JavaScript functions.
    // @raises EGMJSError This exception is raised if an error occurred executing JavaScript function.
    procedure ToSpan(LatLng: TGMLatLng);
    // Returns @code(True) if the given TGMLatLng is in the bounds.
    // @param LatLng TGMLatLng to check.
    // @return @code(True) if the given TGMLatLng is in the bounds, otherwise @code(False).
    // @raises EGMWithoutOwner This exception is raised if the object don't have a owner.
    // @raises EGMOwnerWithoutJS This exception is raised if the owner can't execute JavaScript functions.
    // @raises EGMJSError This exception is raised if an error occurred executing JavaScript function.
    // @raises EGMUnassignedObject This exception is raised if LanLng param is unassigned.
    function Contains(LatLng: TGMLatLng): Boolean;
    // Returns @code(True) if this bounds is equals the given bounds.
    // @param Other Bounds to compare.
    // @return @code(True) if equals, otherwise @code(False).
    function IsEqual(Other: TGMLatLngBounds): Boolean;
    // Returns @code(True) if this bounds shares any points with this bounds.
    // @param Other Bounds to compare.
    // @return @code(True) if shares, otherwise @code(False).
    // @raises EGMWithoutOwner This exception is raised if the object don't have a owner.
    // @raises EGMOwnerWithoutJS This exception is raised if the owner can't execute JavaScript functions.
    // @raises EGMJSError This exception is raised if an error occurred executing JavaScript function.
    // @raises EGMUnassignedObject This exception is raised if LanLng param is unassigned.
    function Intersects(Other: TGMLatLngBounds): Boolean;
    // Returns @code(True) if the bounds are empty.
    // @return @code(True) if empty, otherwise @code(False).
    function IsEmpty: Boolean;
    // Convert bounds to string representation.
    // @param Precision Precision of values. Default 6.
    // @return String with the bounds.
    function ToStr(Precision: Integer = 6): string;
    // Returns a string with format "lat_lo,lng_lo,lat_hi,lng_hi" for this bounds, where "lo" corresponds to the southwest corner of the bounding box and "hi" corresponds to the northeast corner of that box.
    // @param Precision Precision of values. Default 6.
    // @return Formatted string.
    function ToUrlValue(Precision: Integer = 6): string;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;

    // URL to Google Maps API class.
    property APIUrl;
  published
    // South-west coordinates.
    property SW: TGMLatLng read FSW write FSW;
    // North-east coordinates.
    property NE: TGMLatLng read FNE write FNE;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils;
  {$ELSE}
  SysUtils;
  {$ENDIF}

{ TGMLatLngBounds }

constructor TGMLatLngBounds.Create(SW, NE: TGMLatLng; Lang: TGMLang);
begin
  inherited Create(nil);

  FSW := TGMLatLng.Create(SW.Lat, SW.Lng, False, Lang);
  FNE := TGMLatLng.Create(NE.Lat, NE.Lng, False, Lang);
  FLang := Lang;
end;

constructor TGMLatLngBounds.Create(SWLat, SWLng, NELat, NELng: Real;
  Lang: TGMLang);
begin
  inherited Create(nil);

  FSW := TGMLatLng.Create(SWLat, SWLng, False, Lang);
  FNE := TGMLatLng.Create(NELat, NELng, False, Lang);
  FLang := Lang;
end;

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
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(2, [], GetOwnerLang);
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(3, [], GetOwnerLang);
  if not Assigned(LatLng) then
    raise EGMUnassignedObject.Create(5, ['LatLng'], GetOwnerLang);

  Params := Format(StrParams, [LatLng.LatToStr,
                               LatLng.LngToStr,
                               FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  if Intf.ExecuteScript('LLB_Contains', Params) then
  begin
    Result := True;
//    FSW.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLat), Precision);
//    FSW.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLng), Precision);
//    FNE.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELat), Precision);
//    FNE.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELng), Precision);
  end
  else
    raise EGMJSError.Create(4, ['LLB_Contains'], GetOwnerLang);
end;

constructor TGMLatLngBounds.Create(AOwner: TPersistent; SW, NE: TGMLatLng);
begin
  inherited Create(AOwner);

  FSW := TGMLatLng.Create(Self, SW.Lat, SW.Lng, False);
  FNE := TGMLatLng.Create(Self, NE.Lat, NE.Lng, False);
  FLang := lnUnknown;
end;

destructor TGMLatLngBounds.Destroy;
begin
  if Assigned(FSW) then FreeAndNil(FSW);
  if Assigned(FNE) then FreeAndNil(FNE);

  inherited;
end;

procedure TGMLatLngBounds.Extend(LatLng: TGMLatLng);
const
  StrParams = '%s,%s,%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(2, [], GetOwnerLang);
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(3, [], GetOwnerLang);
  if not Assigned(LatLng) then
    raise EGMUnassignedObject.Create(5, ['LatLng'], GetOwnerLang);

  Params := Format(StrParams, [LatLng.LatToStr,
                               LatLng.LngToStr,
                               FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  if Intf.ExecuteScript('LLB_Extend', Params) then
  begin
//    FSW.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLat), Precision);
//    FSW.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLng), Precision);
//    FNE.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELat), Precision);
//    FNE.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELng), Precision);
  end
  else
    raise EGMJSError.Create(4, ['LLB_Extend'], GetOwnerLang);
end;

function TGMLatLngBounds.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#LatLngBounds';
end;

procedure TGMLatLngBounds.GetCenter(LatLng: TGMLatLng);
const
  StrParams = '%s,%s,%s,%s';
var
  Params: string;
  Intf: IGMExecJS;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(2, [], GetOwnerLang);
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(3, [], GetOwnerLang);

  Params := Format(StrParams, [FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  if Intf.ExecuteScript('LLB_Center', Params) then
  begin
//    FSW.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLat), Precision);
//    FSW.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLng), Precision);
//    FNE.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELat), Precision);
//    FNE.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELng), Precision);
  end
  else
    raise EGMJSError.Create(4, ['LLB_Center'], GetOwnerLang);
end;

function TGMLatLngBounds.GetOwnerLang: TGMLang;
begin
  Result := FLang;
  if FLang = lnUnknown then
    inherited;
end;

function TGMLatLngBounds.Intersects(Other: TGMLatLngBounds): Boolean;
var
  Intf: IGMExecJS;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(2, [], GetOwnerLang);
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(3, [], GetOwnerLang);
  if not Assigned(Other) then
    raise EGMUnassignedObject.Create(5, ['Other'], GetOwnerLang);

  if Intf.ExecuteScript('LLB_Intersects', '') then
  begin
//    FSW.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLat), Precision);
//    FSW.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLng), Precision);
//    FNE.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELat), Precision);
//    FNE.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELng), Precision);
  end
  else
    raise EGMJSError.Create(4, ['LLB_Intersects'], GetOwnerLang);
end;

function TGMLatLngBounds.IsEmpty: Boolean;
begin
  Result := FSW.IsEqual(FNE);
end;

function TGMLatLngBounds.IsEqual(Other: TGMLatLngBounds): Boolean;
begin
  Result := FNE.IsEqual(Other.NE) and FSW.IsEqual(Other.SW);
end;

procedure TGMLatLngBounds.PropertyChanged(Prop: TPersistent);
begin
  ControlChanges;
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

procedure TGMLatLngBounds.ToSpan(LatLng: TGMLatLng);
var
  Intf: IGMExecJS;
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(2, [], GetOwnerLang);
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(3, [], GetOwnerLang);

  if Intf.ExecuteScript('LLB_Span', '') then
  begin
//    FSW.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLat), Precision);
//    FSW.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLng), Precision);
//    FNE.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELat), Precision);
//    FNE.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELng), Precision);
  end
  else
    raise EGMJSError.Create(4, ['LLB_Span'], GetOwnerLang);
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
begin
  if not Assigned(GetOwner()) then
    raise EGMWithoutOwner.Create(2, [], GetOwnerLang);
  if not Supports(GetOwner(), IGMExecJS, Intf) then
    raise EGMOwnerWithoutJS.Create(3, [], GetOwnerLang);
  if not Assigned(Other) then
    raise EGMUnassignedObject.Create(5, ['Other'], GetOwnerLang);

  Params := Format(StrParams, [Other.SW.LatToStr,
                               Other.SW.LngToStr,
                               Other.NE.LatToStr,
                               Other.NE.LngToStr,
                               FSW.LatToStr,
                               FSW.LngToStr,
                               FNE.LatToStr,
                               FNE.LngToStr
                               ]);
  if Intf.ExecuteScript('LLB_Union', Params) then
  begin
//    FSW.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLat), Precision);
//    FSW.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormSWLng), Precision);
//    FNE.Lat := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELat), Precision);
//    FNE.Lng := ControlPrecision(FWC.GetFloatField(LatLngBoundsForm, LatLngBoundsFormNELng), Precision);
  end
  else
    raise EGMJSError.Create(4, ['LLB_Union'], GetOwnerLang);
end;

constructor TGMLatLngBounds.Create(AOwner: TPersistent; SWLat, SWLng, NELat,
  NELng: Real);
begin
  inherited Create(AOwner);

  FSW := TGMLatLng.Create(Self, SWLat, SWLng, False);
  FNE := TGMLatLng.Create(Self, NELat, NELng, False);
  FLang := lnUnknown;
end;

end.
