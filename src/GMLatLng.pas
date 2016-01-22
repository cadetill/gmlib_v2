{
  @abstract(@code(google.maps.LatLng) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Septembre 30, 2015)
  @lastmod(October 1, 2015)

  The GMLatLng contains the implementation of TGMLatLng class that encapsulate the @code(google.maps.LatLng) class from Google Maps API.
}
unit GMLatLng;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}

  GMSets, GMClasses;

type
  {
    @abstract(A TGMLatLng is a point in geographical coordinates: latitude and longitude.)
    @unorderedList(
      @item(Latitude ranges between -90 and 90 degrees, inclusive. Values above or below this range will be clamped to the range [-90, 90]. This means that if the value specified is less than -90, it will be set to -90. And if the value is greater than 90, it will be set to 90.)
      @item(Longitude ranges between -180 and 180 degrees, inclusive. Values above or below this range will be wrapped so that they fall within the range. For example, a value of -190 will be converted to 170. A value of 190 will be converted to -170. This reflects the fact that longitudes wrap around the globe.)
    )
    Although the default map projection associates longitude with the x-coordinate of the map, and latitude with the y-coordinate, the latitude coordinate is always written first, followed by the longitude.@br@br
    More information at https://developers.google.com/maps/documentation/javascript/reference#LatLng
  }
  TGMLatLng = class(TGMPersistentStr)
  private
    FLang: TGMLang;
    FLat: Double;
    FLng: Double;
    FNoWrap: Boolean;
    procedure SetLat(const Value: Double);
    procedure SetLng(const Value: Double);
    procedure SetNoWrap(const Value: Boolean);
  protected
    // Converts the Lat and Lng property to a string values. It takes into account the locale.
    // @param aLat The latitude.
    // @param aLng The longitude.
    // @param Precision Precision of values. Default 6.
    procedure LatLngToStr(var aLat, aLng: string; Precision: Integer = 6);

    // @exclude
    function GetAPIUrl: string; override;

    // Returns the Lang of the Owner.@br@br If Owner is not assigned or not supports IGMOwnerLang interface then returns @code(lnEnglish).)
    // @return TLang of the owner object.
    function GetOwnerLang: TGMLang; override;
  public
    // @abstract(Constructor class.)
    // Creates a LatLng object representing a geographic point. Latitude is specified in degrees within the range [-90, 90]. Longitude is specified in degrees within the range [-180, 180]. Set noWrap to true to enable values outside of this range.
    // @param Lat Latitude. Default 0.
    // @param Lng Longitude. Default 0.
    // @param NoWrap Allows to put values outside the default range of lat/lng.
    // @param Lang TLang to use in exceptions.
    constructor Create(Lat: Real = 0; Lng: Real = 0; NoWrap: Boolean = False; Lang: TGMLang = lnEnglish); reintroduce; overload; virtual;
    // @abstract(Constructor class.)
    // Creates a LatLng object representing a geographic point. Latitude is specified in degrees within the range [-90, 90]. Longitude is specified in degrees within the range [-180, 180]. Set noWrap to true to enable values outside of this range.
    // @param AOwner Owner of the object.
    // @param Lat Latitude. Default 0.
    // @param Lng Longitude. Default 0.
    // @param NoWrap Allows to put values outside the default range of lat/lng.
    constructor Create(AOwner: TPersistent; Lat: Real = 0; Lng: Real = 0; NoWrap: Boolean = False); reintroduce; overload; virtual;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);) @br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // Set a Lang to the object.
    // @param Lang Language to set.
    procedure SetLang(Lang: TGMLang);

    // Convert Lat value to a string.
    // @param Precision Precision of value. Default 6.
    // @return String with the latitude.
    function LatToStr(Precision: Integer = 6): string;
    // Convert Lng value to a string.
    // @param Precision Precision of value. Default 6.
    // @return String with the longitude.
    function LngToStr(Precision: Integer = 6): string;
    // Returns @code(True) if this LatLng is equals the given LatLng.
    // @param Other LatLng to compare.
    // @return @code(True) if equals, otherwise @code(False).
    function IsEqual(Other: TGMLatLng): Boolean; virtual;
    // Convert LatLng to string representation in format (Lat, Lng).
    // @param Precision Precision of values. Default 6.
    // @return String with the conversion.
    function ToStr(Precision: Integer = 6): string;
    // Returns a string of the form "lat,lng" for this LatLng. By default, round the LatLng to 6 decimal.
    // @param Precision Precision of values. Default 6.
    // @return String with the formatted LatLng.
    function ToUrlValue(Precision: Integer = 6): string;

    // Given a string, converts it to a real value considering the locale.
    // @raises EGMNotValidRealNumber This exception is raised if it can't do transformation.
    // @param Value String to convert to real.
    // @return Real with the conversion.
    function StringToReal(Value: string): Real;

    // Converts all class properties values to a string separated by semicolon.
    // @return String with all properties.
    function PropToString: string; override;

    // URL to Google Maps API class.
    property APIUrl;
  published
    // Latitude in degrees.
    property Lat: Double read FLat write SetLat;
    // Longitude in degrees
    property Lng: Double read FLng write SetLng;
    // Allows to put values outside the default range of Lat/Lng properties.
    property NoWrap: Boolean read FNoWrap write SetNoWrap default False;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils;
  {$ELSE}
  SysUtils;
  {$ENDIF}

{ TGMLatLng }

procedure TGMLatLng.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMLatLng then
  begin
    NoWrap := TGMLatLng(Source).NoWrap;
    Lat := TGMLatLng(Source).Lat;
    Lng := TGMLatLng(Source).Lng;
  end;
end;

constructor TGMLatLng.Create(Lat, Lng: Real; NoWrap: Boolean; Lang: TGMLang);
begin
  inherited Create(nil);

  FNoWrap := NoWrap;
  FLat := Lat;
  FLng := Lng;
  FLang := Lang;
end;

constructor TGMLatLng.Create(AOwner: TPersistent; Lat, Lng: Real;
  NoWrap: Boolean);
begin
  inherited Create(AOwner);

  FNoWrap := NoWrap;
  FLat := Lat;
  FLng := Lng;
  FLang := lnUnknown;
end;

function TGMLatLng.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#LatLng';
end;

function TGMLatLng.GetOwnerLang: TGMLang;
begin
  Result := FLang;
  if FLang = lnUnknown then
    inherited;
end;

function TGMLatLng.IsEqual(Other: TGMLatLng): Boolean;
begin
  Result := (FLat = Other.Lat) and (FLng = Other.Lng);
end;

procedure TGMLatLng.LatLngToStr(var aLat, aLng: string; Precision: Integer);
var
  i: Integer;
  Prec: Integer;
begin
  if Precision > 0 then
  begin
    Prec := 1;
    for i := 1 to Precision do Prec := Prec * 10;
    aLat := FloatToStr(Trunc(FLat * Prec) / Prec);
    aLng := FloatToStr(Trunc(FLng * Prec) / Prec);
  end
  else
  begin
    aLat := FloatToStr(FLat);
    aLng := FloatToStr(FLng);
  end;

  if {$IFDEF DELPHIXE}FormatSettings.DecimalSeparator{$ELSE}DecimalSeparator{$ENDIF} = ',' then
  begin
    aLat := StringReplace(aLat, ',', '.', [rfReplaceAll]);
    aLng := StringReplace(aLng, ',', '.', [rfReplaceAll]);
  end;
end;

function TGMLatLng.LatToStr(Precision: Integer): string;
var
  Ln: string;
begin
  LatLngToStr(Result, Ln, Precision);
end;

function TGMLatLng.LngToStr(Precision: Integer): string;
var
  La: string;
begin
  LatLngToStr(La, Result, Precision);
end;

function TGMLatLng.PropToString: string;
const
  Str = '%s,%s,%s';
var
  La, Ln: string;
begin
  LatLngToStr(La, Ln, 0);

  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [La,
                         Ln,
                         LowerCase(TGMTransform.GMBoolToStr(FNoWrap, True))
                         ]);
end;

procedure TGMLatLng.SetLang(Lang: TGMLang);
begin
  FLang := Lang;
end;

procedure TGMLatLng.SetLat(const Value: Double);
begin
  if FLat = Value then Exit;

  FLat := Value;
  if not FNoWrap then
  begin
    if FLat > 90 then FLat := 90;
    if FLat < -90 then FLat := -90;
  end;
  ControlChanges;
end;

procedure TGMLatLng.SetLng(const Value: Double);
begin
  if FLng = Value then Exit;

  FLng := Value;
  if not FNoWrap then
  begin
    if FLng > 180 then FLng := 180;
    if FLng < -180 then FLng := -180;
  end;
  ControlChanges;
end;

procedure TGMLatLng.SetNoWrap(const Value: Boolean);
begin
  if FNoWrap = Value then Exit;

  FNoWrap := Value;
  if not FNoWrap then
  begin
    Lat := FLat;
    Lng := FLng;
  end;
end;

function TGMLatLng.StringToReal(Value: string): Real;
begin
  if {$IFDEF DELPHIXE}FormatSettings.DecimalSeparator{$ELSE}DecimalSeparator{$ENDIF} = ',' then
    Value := StringReplace(Value, '.', ',', [rfReplaceAll]);
  try
    Result := StrToFloat(Value);
  except
    on E: Exception do
      raise EGMNotValidRealNumber.Create(1, [Value], GetOwnerLang);
  end;
end;

function TGMLatLng.ToStr(Precision: Integer): string;
const
  Str = '(%s, %s)';
var
  La, Ln: string;
begin
  LatLngToStr(La, Ln, Precision);
  Result := Format(Str, [La, Ln]);
end;

function TGMLatLng.ToUrlValue(Precision: Integer): string;
const
  Str = '%s,%s';
var
  La, Ln: string;
begin
  LatLngToStr(La, Ln, Precision);
  Result := Format(Str, [La, Ln]);
end;

end.
