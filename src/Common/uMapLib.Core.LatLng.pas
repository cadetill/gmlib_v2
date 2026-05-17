{**
  @abstract(Provider-neutral latitude/longitude value object.)
}
unit uMapLib.Core.LatLng;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, Math, SysUtils,
{$ELSE}
  System.Classes, System.Math, System.SysUtils,
{$ENDIF}
  uMapLib.Core.ApiObject,
  uGMLib.Platform.Format;

type
  TMapLibLatLng = class(TMapLibApiObject)
  private
    FLat: Double;
    FLng: Double;
    procedure SetLat(const Value: Double);
    procedure SetLng(const Value: Double);
  public
    constructor Create(ALatitude: Double = 0; ALongitude: Double = 0); reintroduce; virtual;
    procedure Assign(Source: TPersistent); override;
    function Equals(ALatLng: TMapLibLatLng): Boolean; reintroduce;
    function ToJavaScriptLiteral: string;
  published
    property Lat: Double read FLat write SetLat;
    property Lng: Double read FLng write SetLng;
  end;

implementation

{ TMapLibLatLng }

procedure TMapLibLatLng.Assign(Source: TPersistent);
begin
  if Source is TMapLibLatLng then
  begin
    Lat := TMapLibLatLng(Source).Lat;
    Lng := TMapLibLatLng(Source).Lng;
    Exit;
  end;

  inherited;
end;

constructor TMapLibLatLng.Create(ALatitude, ALongitude: Double);
begin
  inherited Create;
  FLat := ALatitude;
  FLng := ALongitude;
end;

function TMapLibLatLng.Equals(ALatLng: TMapLibLatLng): Boolean;
begin
  Result := Assigned(ALatLng) and
    SameValue(FLat, ALatLng.Lat) and
    SameValue(FLng, ALatLng.Lng);
end;

procedure TMapLibLatLng.SetLat(const Value: Double);
begin
  if SameValue(FLat, Value) then
    Exit;

  FLat := Value;
  Changed;
end;

procedure TMapLibLatLng.SetLng(const Value: Double);
begin
  if SameValue(FLng, Value) then
    Exit;

  FLng := Value;
  Changed;
end;

function TMapLibLatLng.ToJavaScriptLiteral: string;
begin
  Result := Format('{ lat: %s, lng: %s }', [
    FloatToStr(FLat, GMLibInvariantFormatSettings),
    FloatToStr(FLng, GMLibInvariantFormatSettings)
  ]);
end;

end.
