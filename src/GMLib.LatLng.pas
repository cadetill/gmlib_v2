{
  @abstract(@code(google.maps.LatLng) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 2, 2022)

  The GMLib.LatLng contains the implementation of TGMLatLng class that encapsulate the @code(google.maps.LatLng) class from Google Maps API.
}
unit GMLib.LatLng;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}

  GMLib.Sets, GMLib.Classes;

type
  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.txt)
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
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.LatLngToStr.txt)
    procedure LatLngToStr(var aLat, aLng: string; Precision: Integer = 6);

    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMOwnerLang.GetOwnerLang.txt)
    function GetOwnerLang: TGMLang; override;
  public
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.Create_1.txt)
    constructor Create(Lat: Real = 0; Lng: Real = 0; NoWrap: Boolean = False; Lang: TGMLang = lnEnglish); reintroduce; overload; virtual;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.Create_2.txt)
    constructor Create(AOwner: TPersistent; Lat: Real = 0; Lng: Real = 0; NoWrap: Boolean = False); reintroduce; overload; virtual;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.SetLang.txt)
    procedure SetLang(Lang: TGMLang);

    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.LatToStr.txt)
    function LatToStr(Precision: Integer = 6): string;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.LngToStr.txt)
    function LngToStr(Precision: Integer = 6): string;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.IsEqual.txt)
    function IsEqual(Other: TGMLatLng): Boolean; virtual;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.ToStr.txt)
    function ToStr(Precision: Integer = 6): string;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.ToJson.txt)
    function ToJson(Precision: Integer = 6): string;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.ToUrlValue.txt)
    function ToUrlValue(Precision: Integer = 6): string;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.Lat.txt)
    property Lat: Double read FLat write SetLat;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.Lng.txt)
    property Lng: Double read FLng write SetLng;
    // @include(..\Help\docs\GMLib.LatLng.TGMLatLng.NoWrap.txt)
    property NoWrap: Boolean read FNoWrap write SetNoWrap default False;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  GMLib.Transform;

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
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/coordinates#LatLng';
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
  ControlChanges('Lat');
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
  ControlChanges('Lng');
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

function TGMLatLng.ToJson(Precision: Integer): string;
const
  Str = '{"Lat": "%s", "Lng": "%s"}';
var
  La, Ln: string;
begin
  LatLngToStr(La, Ln, Precision);
  Result := Format(Str, [La, Ln]);
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
