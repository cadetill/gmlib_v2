{**
  @abstract(Pruebas automaticas del modelo de `TGMMap.Polygons`.)
}
unit uTest.Polygon.Model;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  System.SysUtils,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.Polygon;

type
  TPolygonViewportHostStub = class(TComponent, IGMMapViewportHost)
  public
    CenterCallCount: Integer;
    FitBoundsCallCount: Integer;
    LastNorth: Double;
    LastSouth: Double;
    LastEast: Double;
    LastWest: Double;
    procedure CenterMapTo(const ALatLng: TMapLibLatLng);
    procedure FitBounds(ANorth, ASouth, AEast, AWest: Double);
  end;

  [TestFixture]
  TTestPolygonModel = class
  private
    FClickCount: Integer;
    FPathChangedCount: Integer;
    FLastClickLat: Double;
    FLastClickLng: Double;
    procedure HandlePolygonClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolygonPathChanged(Sender: TObject);
  public
    [Test]
    procedure PolygonOptions_ToJavaScriptLiteral_EmitsCoreFields;

    [Test]
    procedure HiddenPolygon_BuildApplyCommand_ReturnsRemoveCommand;

    [Test]
    procedure Polygon_ProcessMapMessage_Click_FiresEvent;

    [Test]
    procedure Polygon_ProcessMapMessage_PathChanged_UpdatesPathAndFiresEvent;

    [Test]
    procedure PolygonPath_Clear_NotifiesAndEmptiesPath;

    [Test]
    procedure Polygons_Assign_CopiesItemsAndPath;

    [Test]
    procedure Polygons_ZoomToPoints_ForwardsBoundsToViewportHost;

    [Test]
    procedure PolygonDestruction_RegistersPendingRemoval;
  end;

implementation

procedure TPolygonViewportHostStub.CenterMapTo(const ALatLng: TMapLibLatLng);
begin
  Inc(CenterCallCount);
end;

procedure TPolygonViewportHostStub.FitBounds(ANorth, ASouth, AEast,
  AWest: Double);
begin
  Inc(FitBoundsCallCount);
  LastNorth := ANorth;
  LastSouth := ASouth;
  LastEast := AEast;
  LastWest := AWest;
end;

procedure TTestPolygonModel.HandlePolygonClick(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FClickCount);
  if Assigned(ALatLng) then
  begin
    FLastClickLat := ALatLng.Lat;
    FLastClickLng := ALatLng.Lng;
  end;
end;

procedure TTestPolygonModel.HandlePolygonPathChanged(Sender: TObject);
begin
  Inc(FPathChangedCount);
end;

procedure TTestPolygonModel.HiddenPolygon_BuildApplyCommand_ReturnsRemoveCommand;
var
  Polygon: TGMPolygonItem;
  Polygons: TGMPolygons;
begin
  Polygons := TGMPolygons.Create(nil);
  try
    Polygon := Polygons.Add;
    Polygon.Options.Path.Add(41.3874, 2.1686);
    Polygon.Options.Path.Add(48.8566, 2.3522);
    Polygon.Options.Visible := False;

    Assert.AreEqual(
      Polygon.BuildRemoveCommand,
      Polygon.BuildApplyCommand,
      'A hidden polygon must be synchronized as a remove command.'
    );
  finally
    Polygons.Free;
  end;
end;

procedure TTestPolygonModel.PolygonDestruction_RegistersPendingRemoval;
var
  Polygon: TGMPolygonItem;
  Polygons: TGMPolygons;
  ObjectId: TGMObjectId;
begin
  Polygons := TGMPolygons.Create(nil);
  try
    Polygon := Polygons.Add;
    ObjectId := Polygon.ObjectId;
    Assert.IsTrue(Polygons.PendingRemovals.Count = 0);
    Polygon.Free;
    Assert.IsTrue(Polygons.PendingRemovals.Contains(ObjectId));
  finally
    Polygons.Free;
  end;
end;

procedure TTestPolygonModel.PolygonOptions_ToJavaScriptLiteral_EmitsCoreFields;
var
  Polygon: TGMPolygonItem;
  Polygons: TGMPolygons;
  Literal: string;
begin
  Polygons := TGMPolygons.Create(nil);
  try
    Polygon := Polygons.Add;
    Polygon.Options.FillColor := '#112233';
    Polygon.Options.FillOpacity := 0.5;
    Polygon.Options.StrokeColor := '#445566';
    Polygon.Options.Path.Add(41.3874, 2.1686);
    Polygon.Options.Path.Add(41.3880, 2.1700);

    Literal := Polygon.Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('path:', Literal) > 0, 'Polygon literal must serialize path.');
    Assert.IsTrue(Pos('fillColor:', Literal) > 0, 'Polygon literal must serialize fill color.');
    Assert.IsTrue(Pos('strokeColor:', Literal) > 0, 'Polygon literal must serialize stroke color.');
  finally
    Polygons.Free;
  end;
end;

procedure TTestPolygonModel.Polygon_ProcessMapMessage_Click_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Polygon: TGMPolygonItem;
  Polygons: TGMPolygons;
begin
  FClickCount := 0;
  FLastClickLat := 0;
  FLastClickLng := 0;

  Polygons := TGMPolygons.Create(nil);
  try
    Polygon := Polygons.Add;
    Polygon.OnClick := HandlePolygonClick;

    Envelope.MessageType := 'polygon.click';
    Envelope.TargetId := Polygon.ObjectId;
    Envelope.Payload := '{"lat":41.39,"lng":2.17}';

    Polygon.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FClickCount, 'Polygon click must reach the Delphi event.');
    Assert.AreEqual(41.39, FLastClickLat, 0.000001);
    Assert.AreEqual(2.17, FLastClickLng, 0.000001);
  finally
    Polygons.Free;
  end;
end;

procedure TTestPolygonModel.Polygon_ProcessMapMessage_PathChanged_UpdatesPathAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Polygon: TGMPolygonItem;
  Polygons: TGMPolygons;
begin
  FPathChangedCount := 0;

  Polygons := TGMPolygons.Create(nil);
  try
    Polygon := Polygons.Add;
    Polygon.OnPathChanged := HandlePolygonPathChanged;

    Envelope.MessageType := 'polygon.path_changed';
    Envelope.TargetId := Polygon.ObjectId;
    Envelope.Payload := '[{"lat":41.39,"lng":2.17},{"lat":41.40,"lng":2.18}]';

    Polygon.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FPathChangedCount, 'Polygon path_changed must reach the Delphi event.');
    Assert.AreEqual(2, Polygon.Options.Path.Count);
    Assert.AreEqual(41.39, Polygon.Options.Path[0].Lat, 0.000001);
    Assert.AreEqual(2.17, Polygon.Options.Path[0].Lng, 0.000001);
  finally
    Polygons.Free;
  end;
end;

procedure TTestPolygonModel.PolygonPath_Clear_NotifiesAndEmptiesPath;
var
  Polygon: TGMPolygonItem;
  Polygons: TGMPolygons;
begin
  FPathChangedCount := 0;

  Polygons := TGMPolygons.Create(nil);
  try
    Polygon := Polygons.Add;
    Polygon.OnPathChanged := HandlePolygonPathChanged;
    Polygon.Options.Path.Add(41.3874, 2.1686);
    Polygon.Options.Path.Add(41.3880, 2.1700);

    FPathChangedCount := 0;
    Polygon.Options.Path.Clear;

    Assert.IsTrue(FPathChangedCount > 0, 'Clearing the path must notify the owner.');
    Assert.AreEqual(0, Polygon.Options.Path.Count);
  finally
    Polygons.Free;
  end;
end;

procedure TTestPolygonModel.Polygons_Assign_CopiesItemsAndPath;
var
  SourcePolygon: TGMPolygonItem;
  SourcePolygons: TGMPolygons;
  TargetPolygons: TGMPolygons;
begin
  SourcePolygons := TGMPolygons.Create(nil);
  TargetPolygons := TGMPolygons.Create(nil);
  try
    SourcePolygon := SourcePolygons.Add;
    SourcePolygon.Options.FillColor := '#123456';
    SourcePolygon.Options.Path.Add(41.3874, 2.1686);
    SourcePolygon.Options.Path.Add(41.3880, 2.1700);

    TargetPolygons.Assign(SourcePolygons);

    Assert.AreEqual(1, TargetPolygons.Count);
    Assert.AreEqual(2, TargetPolygons[0].Options.Path.Count);
    Assert.AreEqual('#123456', TargetPolygons[0].Options.FillColor);
  finally
    SourcePolygons.Free;
    TargetPolygons.Free;
  end;
end;

procedure TTestPolygonModel.Polygons_ZoomToPoints_ForwardsBoundsToViewportHost;
var
  Host: TPolygonViewportHostStub;
  Polygon: TGMPolygonItem;
  Polygons: TGMPolygons;
begin
  Host := TPolygonViewportHostStub.Create(nil);
  Polygons := TGMPolygons.Create(Host);
  try
    Polygon := Polygons.Add;
    Polygon.Options.Path.Add(41.3874, 2.1686);
    Polygon.Options.Path.Add(48.8566, 2.3522);

    Polygons.ZoomToPoints;

    Assert.AreEqual(1, Host.FitBoundsCallCount);
    Assert.AreEqual(48.8566, Host.LastNorth, 0.000001);
    Assert.AreEqual(41.3874, Host.LastSouth, 0.000001);
    Assert.AreEqual(2.3522, Host.LastEast, 0.000001);
    Assert.AreEqual(2.1686, Host.LastWest, 0.000001);
  finally
    Polygons.Free;
    Host.Free;
  end;
end;

end.

