{**
  @abstract(Pruebas automaticas de los helpers geometricos de GMLib.)
}
unit uTest.Geometry.Model;

interface

uses
  DUnitX.TestFramework,
  uGMLib.Core.Types,
  uGMLib.Geometry,
  uGMLib.Polygon,
  uGMLib.Polyline;

type
  [TestFixture]
  TTestGeometryModel = class
  public
    [Test]
    procedure ComputeDistanceBetween_ReturnsExpectedDistanceForOneDegreeAtEquator;

    [Test]
    procedure ComputeHeading_ReturnsExpectedCardinalHeadings;

    [Test]
    procedure ComputeOffset_ShiftsPointAlongBearing;

    [Test]
    procedure Interpolate_ReturnsMidpointForHalfFraction;

    [Test]
    procedure ContainsLocation_ReturnsTrueInsideSimplePolygon;

    [Test]
    procedure IsLocationOnEdge_ReturnsTrueForPointOnPolyline;
  end;

implementation

uses
  System.Math;

procedure TTestGeometryModel.ComputeDistanceBetween_ReturnsExpectedDistanceForOneDegreeAtEquator;
var
  FromPoint: TMapLibLatLng;
  ToPoint: TMapLibLatLng;
  Distance: Double;
begin
  FromPoint := TMapLibLatLng.Create(0, 0);
  ToPoint := TMapLibLatLng.Create(0, 1);
  try
    Distance := TGMGeometry.ComputeDistanceBetween(FromPoint, ToPoint);

    Assert.AreEqual(111319.4908, Distance, 5.0);
  finally
    FromPoint.Free;
    ToPoint.Free;
  end;
end;

procedure TTestGeometryModel.ComputeHeading_ReturnsExpectedCardinalHeadings;
var
  FromPoint: TMapLibLatLng;
  EastPoint: TMapLibLatLng;
  NorthPoint: TMapLibLatLng;
begin
  FromPoint := TMapLibLatLng.Create(0, 0);
  EastPoint := TMapLibLatLng.Create(0, 1);
  NorthPoint := TMapLibLatLng.Create(1, 0);
  try
    Assert.AreEqual(90.0, TGMGeometry.ComputeHeading(FromPoint, EastPoint), 0.01);
    Assert.AreEqual(0.0, TGMGeometry.ComputeHeading(FromPoint, NorthPoint), 0.01);
  finally
    FromPoint.Free;
    EastPoint.Free;
    NorthPoint.Free;
  end;
end;

procedure TTestGeometryModel.ComputeOffset_ShiftsPointAlongBearing;
var
  FromPoint: TMapLibLatLng;
  OffsetPoint: TMapLibLatLng;
begin
  FromPoint := TMapLibLatLng.Create(0, 0);
  try
    OffsetPoint := TGMGeometry.ComputeOffset(FromPoint, 111319.4908, 90.0);
    try
      Assert.AreEqual(0.0, OffsetPoint.Lat, 0.01);
      Assert.AreEqual(1.0, OffsetPoint.Lng, 0.01);
    finally
      OffsetPoint.Free;
    end;
  finally
    FromPoint.Free;
  end;
end;

procedure TTestGeometryModel.Interpolate_ReturnsMidpointForHalfFraction;
var
  FromPoint: TMapLibLatLng;
  ToPoint: TMapLibLatLng;
  MidPoint: TMapLibLatLng;
begin
  FromPoint := TMapLibLatLng.Create(0, 0);
  ToPoint := TMapLibLatLng.Create(0, 2);
  try
    MidPoint := TGMGeometry.Interpolate(FromPoint, ToPoint, 0.5);
    try
      Assert.AreEqual(0.0, MidPoint.Lat, 0.01);
      Assert.AreEqual(1.0, MidPoint.Lng, 0.01);
    finally
      MidPoint.Free;
    end;
  finally
    FromPoint.Free;
    ToPoint.Free;
  end;
end;

procedure TTestGeometryModel.ContainsLocation_ReturnsTrueInsideSimplePolygon;
var
  Polygon: TGMPolygonPath;
  InsidePoint: TMapLibLatLng;
  OutsidePoint: TMapLibLatLng;
begin
  Polygon := TGMPolygonPath.Create(nil);
  InsidePoint := TMapLibLatLng.Create(1, 1);
  OutsidePoint := TMapLibLatLng.Create(3, 3);
  try
    Polygon.Add(0, 0);
    Polygon.Add(0, 2);
    Polygon.Add(2, 2);
    Polygon.Add(2, 0);

    Assert.IsTrue(TGMGeometry.ContainsLocation(InsidePoint, Polygon));
    Assert.IsFalse(TGMGeometry.ContainsLocation(OutsidePoint, Polygon));
  finally
    InsidePoint.Free;
    OutsidePoint.Free;
    Polygon.Free;
  end;
end;

procedure TTestGeometryModel.IsLocationOnEdge_ReturnsTrueForPointOnPolyline;
var
  Polyline: TGMPolylinePath;
  OnEdgePoint: TMapLibLatLng;
  OffEdgePoint: TMapLibLatLng;
begin
  Polyline := TGMPolylinePath.Create(nil);
  OnEdgePoint := TMapLibLatLng.Create(0, 1);
  OffEdgePoint := TMapLibLatLng.Create(1, 1);
  try
    Polyline.Add(0, 0);
    Polyline.Add(0, 2);

    Assert.IsTrue(TGMGeometry.IsLocationOnEdge(OnEdgePoint, Polyline, 5));
    Assert.IsFalse(TGMGeometry.IsLocationOnEdge(OffEdgePoint, Polyline, 5));
  finally
    OnEdgePoint.Free;
    OffEdgePoint.Free;
    Polyline.Free;
  end;
end;

end.

