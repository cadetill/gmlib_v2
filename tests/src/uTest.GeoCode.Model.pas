{**
  @abstract(Pruebas automaticas del modelo de `TGMGeoCode`.)
}
unit uTest.GeoCode.Model;

{$HINTS OFF}

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  uGMLib.Core.Types,
  uGMLib.GeoCode;

type
  [TestFixture]
  TTestGeoCodeModel = class
  public
    [Test]
    procedure GeoCodeResponse_FromJson_ParsesPrimaryResult;

    [Test]
    procedure GeoCodeResponse_TryGetFirstLocation_ReturnsLatLng;
  end;

implementation

procedure TTestGeoCodeModel.GeoCodeResponse_FromJson_ParsesPrimaryResult;
var
  Response: TGMGeocodeResponse;
begin
  Response := TGMGeocodeResponse.FromJson(
    '{"requestId":"geocode_1","status":"OK","errorMessage":"","results":[' +
    '{"formattedAddress":"Main St, Barcelona","placeId":"abc123","locationType":"ROOFTOP",' +
    '"location":{"lat":41.401,"lng":2.152},"types":["street_address","political"],"partialMatch":false}' +
    ']}'
  );

  Assert.AreEqual('geocode_1', Response.RequestId);
  Assert.AreEqual('OK', Response.Status);
  Assert.IsTrue(Response.HasResults);
  Assert.AreEqual('Main St, Barcelona', Response.Results[0].FormattedAddress);
  Assert.AreEqual('abc123', Response.Results[0].PlaceId);
  Assert.AreEqual(41.401, Response.Results[0].Latitude, 0.000001);
  Assert.AreEqual(2.152, Response.Results[0].Longitude, 0.000001);
  Assert.AreEqual('ROOFTOP', Response.Results[0].LocationType);
  Assert.IsFalse(Response.Results[0].PartialMatch);
  Assert.IsTrue(Pos('street_address', Response.Results[0].TypesText) > 0);
end;

procedure TTestGeoCodeModel.GeoCodeResponse_TryGetFirstLocation_ReturnsLatLng;
var
  LatLng: TGMLibLatLng;
  Response: TGMGeocodeResponse;
begin
  Response := TGMGeocodeResponse.FromJson(
    '{"requestId":"geocode_2","status":"OK","errorMessage":"","results":[' +
    '{"formattedAddress":"Diagonal, Barcelona","placeId":"def456","locationType":"GEOMETRIC_CENTER",' +
    '"location":{"lat":41.3925,"lng":2.1404},"types":["route"],"partialMatch":true}' +
    ']}'
  );

  LatLng := nil;
  try
    Assert.IsTrue(Response.TryGetFirstLocation(LatLng));
    Assert.IsNotNull(LatLng);
    Assert.AreEqual(41.3925, LatLng.Lat, 0.000001);
    Assert.AreEqual(2.1404, LatLng.Lng, 0.000001);
  finally
    LatLng.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGeoCodeModel);

end.
