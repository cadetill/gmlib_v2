{**
  @abstract(Helpers geometricos basados en la esfera terrestre.)
}
unit uGMLib.Geometry;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  Math,
  SysUtils,
{$ELSE}
  System.Classes,
  System.Math,
  System.SysUtils,
{$ENDIF}
  uGMLib.Core.Types,
  uGMLib.Polyline,
  uGMLib.Polygon;

type

  {** @abstract(Helpers geodesicos independientes del runtime JS.) }
  TGMGeometry = class
  public
    class function ComputeDistanceBetween(const AFrom, ATo: TGMLibLatLng;
      ARadiusMeters: Double = 6378137): Double;
    class function ComputeHeading(const AFrom, ATo: TGMLibLatLng): Double;
    class function ComputeOffset(const AFrom: TGMLibLatLng; ADistanceMeters,
      AHeadingDegrees: Double; ARadiusMeters: Double = 6378137): TGMLibLatLng;
    class function Interpolate(const AFrom, ATo: TGMLibLatLng;
      AFraction: Double): TGMLibLatLng;
    class function ContainsLocation(const APoint: TGMLibLatLng;
      APolygon: TGMPolygonPath): Boolean;
    class function IsLocationOnEdge(const APoint: TGMLibLatLng;
      APolyline: TGMPolylinePath; AToleranceMeters: Double = 1.0): Boolean; overload;
    class function IsLocationOnEdge(const APoint: TGMLibLatLng;
      APolygon: TGMPolygonPath; AToleranceMeters: Double = 1.0): Boolean; overload;
  end;

implementation

uses
  uGMLib.CoordinatePoint;

const
  EARTH_RADIUS_METERS = 6378137.0;

function Clamp(const AValue, AMin, AMax: Double): Double;
begin
  Result := AValue;
  if Result < AMin then
    Result := AMin
  else if Result > AMax then
    Result := AMax;
end;

function DegToRadValue(const AValue: Double): Double;
begin
  Result := DegToRad(AValue);
end;

function RadToDegValue(const AValue: Double): Double;
begin
  Result := RadToDeg(AValue);
end;

function NormalizeLongitudeDelta(const AValue, AReference: Double): Double;
var
  Delta: Double;
begin
  Delta := AValue - AReference;
  while Delta > 180 do
    Delta := Delta - 360;
  while Delta < -180 do
    Delta := Delta + 360;
  Result := Delta;
end;

function TryGetPathPoint(const APath: TCollection; const AIndex: Integer;
  out ALat, ALng: Double): Boolean;
var
  Point: TGMCoordinatePoint;
begin
  Result := Assigned(APath) and (AIndex >= 0) and (AIndex < APath.Count);
  if not Result then
    Exit;

  Point := TGMCoordinatePoint(APath.Items[AIndex]);
  ALat := Point.Lat;
  ALng := Point.Lng;
end;

function CrossTrackDistanceMeters(const APoint, AStart, AEnd: TGMLibLatLng): Double;
var
  Dist13: Double;
  Heading13: Double;
  Heading12: Double;
  CrossTrackRadians: Double;
begin
  Dist13 := TGMGeometry.ComputeDistanceBetween(AStart, APoint, EARTH_RADIUS_METERS) / EARTH_RADIUS_METERS;
  if SameValue(Dist13, 0) then
    Exit(0);

  Heading13 := DegToRadValue(TGMGeometry.ComputeHeading(AStart, APoint));
  Heading12 := DegToRadValue(TGMGeometry.ComputeHeading(AStart, AEnd));
  CrossTrackRadians := ArcSin(Clamp(Sin(Dist13) * Sin(Heading13 - Heading12), -1, 1));
  Result := Abs(CrossTrackRadians) * EARTH_RADIUS_METERS;
end;

function DistancePointToSegmentMeters(const APoint, AStart, AEnd: TGMLibLatLng): Double;
var
  DistAB: Double;
  DistAP: Double;
  DistBP: Double;
  CrossTrack: Double;
  Heading13: Double;
  Heading12: Double;
  AlongTrack: Double;
  CosValue: Double;
begin
  DistAB := TGMGeometry.ComputeDistanceBetween(AStart, AEnd, EARTH_RADIUS_METERS);
  if SameValue(DistAB, 0) then
    Exit(TGMGeometry.ComputeDistanceBetween(APoint, AStart, EARTH_RADIUS_METERS));

  DistAP := TGMGeometry.ComputeDistanceBetween(AStart, APoint, EARTH_RADIUS_METERS);
  DistBP := TGMGeometry.ComputeDistanceBetween(AEnd, APoint, EARTH_RADIUS_METERS);

  Heading13 := DegToRadValue(TGMGeometry.ComputeHeading(AStart, APoint));
  Heading12 := DegToRadValue(TGMGeometry.ComputeHeading(AStart, AEnd));
  CrossTrack := Abs(ArcSin(Clamp(Sin(DistAP / EARTH_RADIUS_METERS) * Sin(Heading13 - Heading12), -1, 1))) * EARTH_RADIUS_METERS;

  CosValue := Cos(CrossTrack / EARTH_RADIUS_METERS);
  if SameValue(CosValue, 0) then
    Exit(Min(DistAP, DistBP));

  AlongTrack := ArcCos(Clamp(Cos(DistAP / EARTH_RADIUS_METERS) / CosValue, -1, 1)) * EARTH_RADIUS_METERS;
  if (AlongTrack < 0) or (AlongTrack > DistAB) then
    Result := Min(DistAP, DistBP)
  else
    Result := CrossTrack;
end;

{ TGMGeometry }

class function TGMGeometry.ComputeDistanceBetween(const AFrom, ATo: TGMLibLatLng;
  ARadiusMeters: Double): Double;
var
  Lat1: Double;
  Lat2: Double;
  DeltaLat: Double;
  DeltaLng: Double;
  A: Double;
begin
  if not Assigned(AFrom) or not Assigned(ATo) then
    Exit(0);

  Lat1 := DegToRadValue(AFrom.Lat);
  Lat2 := DegToRadValue(ATo.Lat);
  DeltaLat := DegToRadValue(ATo.Lat - AFrom.Lat);
  DeltaLng := DegToRadValue(ATo.Lng - AFrom.Lng);

  A := Sqr(Sin(DeltaLat / 2)) + Cos(Lat1) * Cos(Lat2) * Sqr(Sin(DeltaLng / 2));
  Result := 2 * ARadiusMeters * ArcTan2(Sqrt(Clamp(A, 0, 1)), Sqrt(Clamp(1 - A, 0, 1)));
end;

class function TGMGeometry.ComputeHeading(const AFrom, ATo: TGMLibLatLng): Double;
var
  Lat1: Double;
  Lat2: Double;
  DeltaLng: Double;
  Y: Double;
  X: Double;
begin
  if not Assigned(AFrom) or not Assigned(ATo) then
    Exit(0);

  Lat1 := DegToRadValue(AFrom.Lat);
  Lat2 := DegToRadValue(ATo.Lat);
  DeltaLng := DegToRadValue(ATo.Lng - AFrom.Lng);

  Y := Sin(DeltaLng) * Cos(Lat2);
  X := Cos(Lat1) * Sin(Lat2) - Sin(Lat1) * Cos(Lat2) * Cos(DeltaLng);
  Result := RadToDegValue(ArcTan2(Y, X));
end;

class function TGMGeometry.ComputeOffset(const AFrom: TGMLibLatLng; ADistanceMeters,
  AHeadingDegrees: Double; ARadiusMeters: Double): TGMLibLatLng;
var
  Lat1: Double;
  Lng1: Double;
  AngularDistance: Double;
  HeadingRadians: Double;
  Lat2: Double;
  Lng2: Double;
begin
  if not Assigned(AFrom) then
    Exit(nil);

  Lat1 := DegToRadValue(AFrom.Lat);
  Lng1 := DegToRadValue(AFrom.Lng);
  AngularDistance := ADistanceMeters / ARadiusMeters;
  HeadingRadians := DegToRadValue(AHeadingDegrees);

  Lat2 := ArcSin(
    Clamp(
      Sin(Lat1) * Cos(AngularDistance) +
      Cos(Lat1) * Sin(AngularDistance) * Cos(HeadingRadians),
      -1,
      1
    )
  );
  Lng2 := Lng1 + ArcTan2(
    Sin(HeadingRadians) * Sin(AngularDistance) * Cos(Lat1),
    Cos(AngularDistance) - Sin(Lat1) * Sin(Lat2)
  );
  Lng2 := ArcTan2(Sin(Lng2), Cos(Lng2));

  Result := TGMLibLatLng.Create(RadToDegValue(Lat2), RadToDegValue(Lng2));
end;

class function TGMGeometry.Interpolate(const AFrom, ATo: TGMLibLatLng;
  AFraction: Double): TGMLibLatLng;
var
  Lat1: Double;
  Lng1: Double;
  Lat2: Double;
  Lng2: Double;
  SinLat1: Double;
  CosLat1: Double;
  SinLat2: Double;
  CosLat2: Double;
  Delta: Double;
  A: Double;
  B: Double;
  X: Double;
  Y: Double;
  Z: Double;
begin
  if not Assigned(AFrom) or not Assigned(ATo) then
    Exit(nil);

  if AFraction <= 0 then
    Exit(TGMLibLatLng.Create(AFrom.Lat, AFrom.Lng));

  if AFraction >= 1 then
    Exit(TGMLibLatLng.Create(ATo.Lat, ATo.Lng));

  Lat1 := DegToRadValue(AFrom.Lat);
  Lng1 := DegToRadValue(AFrom.Lng);
  Lat2 := DegToRadValue(ATo.Lat);
  Lng2 := DegToRadValue(ATo.Lng);

  SinLat1 := Sin(Lat1);
  CosLat1 := Cos(Lat1);
  SinLat2 := Sin(Lat2);
  CosLat2 := Cos(Lat2);

  Delta := 2 * ArcSin(
    Sqrt(
      Sqr(Sin((Lat2 - Lat1) / 2)) +
      Cos(Lat1) * Cos(Lat2) * Sqr(Sin((Lng2 - Lng1) / 2))
    )
  );

  if SameValue(Delta, 0) then
    Exit(TGMLibLatLng.Create(AFrom.Lat, AFrom.Lng));

  A := Sin((1 - AFraction) * Delta) / Sin(Delta);
  B := Sin(AFraction * Delta) / Sin(Delta);

  X := A * CosLat1 * Cos(Lng1) + B * CosLat2 * Cos(Lng2);
  Y := A * CosLat1 * Sin(Lng1) + B * CosLat2 * Sin(Lng2);
  Z := A * SinLat1 + B * SinLat2;

  Result := TGMLibLatLng.Create(
    RadToDegValue(ArcTan2(Z, Sqrt(Sqr(X) + Sqr(Y)))),
    RadToDegValue(ArcTan2(Y, X))
  );
end;

class function TGMGeometry.ContainsLocation(const APoint: TGMLibLatLng;
  APolygon: TGMPolygonPath): Boolean;
var
  I: Integer;
  J: Integer;
  LatI: Double;
  LngI: Double;
  LatJ: Double;
  LngJ: Double;
  NormalizedI: Double;
  NormalizedJ: Double;
  Intersects: Boolean;
begin
  Result := False;
  if not Assigned(APoint) or not Assigned(APolygon) or (APolygon.Count < 3) then
    Exit;

  { The edge test is checked first so a point exactly on the boundary counts as
    contained, matching the typical Maps Geometry semantics. }
  if IsLocationOnEdge(APoint, APolygon, 0.1) then
    Exit(True);

  { Classic ray-casting test on longitude-normalized coordinates. }
  J := APolygon.Count - 1;
  for I := 0 to APolygon.Count - 1 do
  begin
    if not TryGetPathPoint(APolygon, I, LatI, LngI) then
      Continue;
    if not TryGetPathPoint(APolygon, J, LatJ, LngJ) then
      Continue;

    NormalizedI := NormalizeLongitudeDelta(LngI, APoint.Lng);
    NormalizedJ := NormalizeLongitudeDelta(LngJ, APoint.Lng);

    Intersects :=
      ((LatI > APoint.Lat) <> (LatJ > APoint.Lat)) and
      (0 < (NormalizedJ - NormalizedI) * (APoint.Lat - LatI) / (LatJ - LatI) + NormalizedI);

    if Intersects then
      Result := not Result;

    J := I;
  end;
end;

class function TGMGeometry.IsLocationOnEdge(const APoint: TGMLibLatLng;
  APolyline: TGMPolylinePath; AToleranceMeters: Double): Boolean;
var
  I: Integer;
  StartLat: Double;
  StartLng: Double;
  EndLat: Double;
  EndLng: Double;
  StartPoint: TGMLibLatLng;
  EndPoint: TGMLibLatLng;
begin
  Result := False;
  if not Assigned(APoint) or not Assigned(APolyline) or (APolyline.Count < 2) then
    Exit;

  { We work segment by segment and approximate the geodesic distance to the
    current segment in meters. }
  StartPoint := nil;
  EndPoint := nil;
  try
    for I := 0 to APolyline.Count - 2 do
    begin
      if not TryGetPathPoint(APolyline, I, StartLat, StartLng) then
        Continue;
      if not TryGetPathPoint(APolyline, I + 1, EndLat, EndLng) then
        Continue;

      StartPoint := TGMLibLatLng.Create(StartLat, StartLng);
      EndPoint := TGMLibLatLng.Create(EndLat, EndLng);
      if DistancePointToSegmentMeters(APoint, StartPoint, EndPoint) <= AToleranceMeters then
        Exit(True);

      FreeAndNil(StartPoint);
      FreeAndNil(EndPoint);
    end;
  finally
    StartPoint.Free;
    EndPoint.Free;
  end;
end;

class function TGMGeometry.IsLocationOnEdge(const APoint: TGMLibLatLng;
  APolygon: TGMPolygonPath; AToleranceMeters: Double): Boolean;
var
  I: Integer;
  StartLat: Double;
  StartLng: Double;
  EndLat: Double;
  EndLng: Double;
  StartPoint: TGMLibLatLng;
  EndPoint: TGMLibLatLng;
begin
  Result := False;
  if not Assigned(APoint) or not Assigned(APolygon) or (APolygon.Count < 2) then
    Exit;

  StartPoint := nil;
  EndPoint := nil;
  try
    for I := 0 to APolygon.Count - 2 do
    begin
      if not TryGetPathPoint(APolygon, I, StartLat, StartLng) then
        Continue;
      if not TryGetPathPoint(APolygon, I + 1, EndLat, EndLng) then
        Continue;

      StartPoint := TGMLibLatLng.Create(StartLat, StartLng);
      EndPoint := TGMLibLatLng.Create(EndLat, EndLng);
      if DistancePointToSegmentMeters(APoint, StartPoint, EndPoint) <= AToleranceMeters then
        Exit(True);
      FreeAndNil(StartPoint);
      FreeAndNil(EndPoint);
    end;

    if APolygon.Count > 2 then
    begin
      if TryGetPathPoint(APolygon, APolygon.Count - 1, StartLat, StartLng) and
         TryGetPathPoint(APolygon, 0, EndLat, EndLng) then
      begin
        StartPoint := TGMLibLatLng.Create(StartLat, StartLng);
        EndPoint := TGMLibLatLng.Create(EndLat, EndLng);
        if DistancePointToSegmentMeters(APoint, StartPoint, EndPoint) <= AToleranceMeters then
          Exit(True);
      end;
    end;
  finally
    StartPoint.Free;
    EndPoint.Free;
  end;
end;

end.

