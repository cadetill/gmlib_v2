{**
  @abstract(Base compartida para puntos con coordenadas Lat/Lng.)
}
unit uGMLib.CoordinatePoint;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  Math,
  SysUtils;
{$ELSE}
  System.Classes,
  System.Math,
  System.SysUtils;
{$ENDIF}

type
  TGMCoordinatePoint = class(TCollectionItem)
  private
    FLat: Double;
    FLng: Double;
    procedure SetLat(const Value: Double);
    procedure SetLng(const Value: Double);
  public
    procedure Assign(Source: TPersistent); override;
    function ToJavaScriptLiteral: string;
  published
    property Lat: Double read FLat write SetLat;
    property Lng: Double read FLng write SetLng;
  end;

implementation

uses
  uGMLib.Platform.Format;

procedure TGMCoordinatePoint.Assign(Source: TPersistent);
begin
  if Source is TGMCoordinatePoint then
  begin
    Lat := TGMCoordinatePoint(Source).Lat;
    Lng := TGMCoordinatePoint(Source).Lng;
    Exit;
  end;

  inherited;
end;

procedure TGMCoordinatePoint.SetLat(const Value: Double);
begin
  if SameValue(FLat, Value) then
    Exit;

  FLat := Value;
  Changed(False);
end;

procedure TGMCoordinatePoint.SetLng(const Value: Double);
begin
  if SameValue(FLng, Value) then
    Exit;

  FLng := Value;
  Changed(False);
end;

function TGMCoordinatePoint.ToJavaScriptLiteral: string;
begin
  Result := Format('{ lat: %s, lng: %s }', [
    FloatToStr(FLat, GMLibInvariantFormatSettings),
    FloatToStr(FLng, GMLibInvariantFormatSettings)
  ]);
end;

end.



