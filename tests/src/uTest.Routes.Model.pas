{**
  @abstract(Pruebas automaticas del modelo de `TGMRoutes`.)
}
unit uTest.Routes.Model;

{$HINTS OFF}

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  uGMLib.Map,
  uGMLib.Routes;

type
  TMockRoutePending = class
  public
    RequestId: string;
    OnCompleted: TGMRouteCompletedEvent;
  end;

  TMockRouteMap = class(TGMCustomMap)
  private
    FNextRequestId: Integer;
    FPending: TObjectList<TMockRoutePending>;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure CompleteRoute(const ARequestId, AStatus, AErrorMessage: string;
      const ADistanceMeters: Double);
    function RoutesCompute(const ARequestLiteral: string;
      const AOnCompleted: TGMRouteCompletedEvent): string; override;
  end;

  [TestFixture]
  TTestRoutesModel = class
  public
    [Test]
    procedure Routes_ExecuteQuery_StoresMultipleResponsesByRequestId;

    [Test]
    procedure Routes_Clear_RemovesStoredQueriesAndLastResponse;

    [Test]
    procedure Routes_QueryVisibility_ShowsAndHidesPolylineOnMap;
  end;

implementation

constructor TMockRouteMap.Create;
begin
  inherited Create(nil);
  FPending := TObjectList<TMockRoutePending>.Create(True);
end;

destructor TMockRouteMap.Destroy;
begin
  FPending.Free;
  inherited;
end;

procedure TMockRouteMap.CompleteRoute(const ARequestId, AStatus,
  AErrorMessage: string; const ADistanceMeters: Double);
var
  i: Integer;
  Pending: TMockRoutePending;
  Response: TGMRouteResponse;
begin
  for i := FPending.Count - 1 downto 0 do
  begin
    Pending := FPending[i];
    if not SameText(Pending.RequestId, ARequestId) then
      Continue;

    Response := Default(TGMRouteResponse);
    Response.RequestId := ARequestId;
    Response.Status := AStatus;
    Response.ErrorMessage := AErrorMessage;
    SetLength(Response.Results, 1);
    Response.Results[0].DistanceMeters := ADistanceMeters;
    Response.Results[0].PathJson := '[{"lat":41.3874,"lng":2.1686},{"lat":41.8902,"lng":12.4922}]';

    FPending.Delete(i);
    if Assigned(Pending.OnCompleted) then
      Pending.OnCompleted(Self, Response);
    Exit;
  end;

  Assert.Fail('Pending route request not found: ' + ARequestId);
end;

function TMockRouteMap.RoutesCompute(const ARequestLiteral: string;
  const AOnCompleted: TGMRouteCompletedEvent): string;
var
  Pending: TMockRoutePending;
begin
  Inc(FNextRequestId);
  Result := Format('route_test_%d', [FNextRequestId]);

  Pending := TMockRoutePending.Create;
  Pending.RequestId := Result;
  Pending.OnCompleted := AOnCompleted;
  FPending.Add(Pending);
end;

procedure TTestRoutesModel.Routes_Clear_RemovesStoredQueriesAndLastResponse;
var
  Map: TMockRouteMap;
  Query: TGMRouteQuery;
  Routes: TGMRoutes;
begin
  Map := TMockRouteMap.Create;
  Routes := TGMRoutes.Create(nil);
  try
    Routes.Map := Map;
    Routes.OriginAddress := 'Barcelona';
    Routes.DestinationAddress := 'Girona';

    Query := Routes.ExecuteQuery;
    Assert.IsNotNull(Query);
    Map.CompleteRoute(Query.RequestId, 'OK', '', 1234);

    Assert.AreEqual(1, Routes.QueryCount);
    Assert.AreEqual('OK', Routes.LastStatus);

    Routes.Clear;

    Assert.AreEqual(0, Routes.QueryCount);
    Assert.AreEqual('', Routes.LastStatus);
    Assert.AreEqual('', Routes.LastErrorMessage);
    Assert.IsFalse(Routes.LastResponse.HasResults);
  finally
    Routes.Free;
    Map.Free;
  end;
end;

procedure TTestRoutesModel.Routes_ExecuteQuery_StoresMultipleResponsesByRequestId;
var
  FirstQuery: TGMRouteQuery;
  Map: TMockRouteMap;
  Routes: TGMRoutes;
  SecondQuery: TGMRouteQuery;
begin
  Map := TMockRouteMap.Create;
  Routes := TGMRoutes.Create(nil);
  try
    Routes.Map := Map;
    Routes.OriginAddress := 'Barcelona';
    Routes.DestinationAddress := 'Girona';

    FirstQuery := Routes.ExecuteQuery;
    SecondQuery := Routes.ExecuteQuery;

    Assert.IsNotNull(FirstQuery);
    Assert.IsNotNull(SecondQuery);
    Assert.AreEqual(2, Routes.QueryCount);
    Assert.IsFalse(FirstQuery.Completed);
    Assert.IsFalse(SecondQuery.Completed);

    Map.CompleteRoute(FirstQuery.RequestId, 'OK', '', 1000);
    Map.CompleteRoute(SecondQuery.RequestId, 'OK', '', 2000);

    Assert.AreEqual(2, Routes.QueryCount);
    Assert.IsTrue(Routes.Queries[0].Completed);
    Assert.IsTrue(Routes.Queries[1].Completed);
    Assert.AreEqual(1000, Routes.Queries[0].Results[0].DistanceMeters, 0.000001);
    Assert.AreEqual(2000, Routes.Queries[1].Results[0].DistanceMeters, 0.000001);
    Assert.AreEqual(2, Map.Polylines.Count);
    Assert.AreEqual(SecondQuery.RequestId, Routes.LastResponse.RequestId);
    Assert.AreEqual(2000, Routes.Results[0].DistanceMeters, 0.000001);
  finally
    Routes.Free;
    Map.Free;
  end;
end;

procedure TTestRoutesModel.Routes_QueryVisibility_ShowsAndHidesPolylineOnMap;
var
  Map: TMockRouteMap;
  Query: TGMRouteQuery;
  Routes: TGMRoutes;
begin
  Map := TMockRouteMap.Create;
  Routes := TGMRoutes.Create(nil);
  try
    Routes.Map := Map;
    Routes.OriginAddress := 'Barcelona';
    Routes.DestinationAddress := 'Girona';

    Query := Routes.ExecuteQuery;
    Map.CompleteRoute(Query.RequestId, 'OK', '', 1234);

    Assert.AreEqual(1, Query.Count);
    Assert.IsTrue(Query.Visible);
    Assert.IsTrue(Query.ResultItems[0].Visible);
    Assert.AreEqual(1, Map.Polylines.Count);

    Query.Visible := False;
    Assert.IsFalse(Query.ResultItems[0].Visible);
    Assert.AreEqual(0, Map.Polylines.Count);

    Query.Visible := True;
    Assert.IsTrue(Query.ResultItems[0].Visible);
    Assert.AreEqual(1, Map.Polylines.Count);
  finally
    Routes.Free;
    Map.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRoutesModel);

end.
