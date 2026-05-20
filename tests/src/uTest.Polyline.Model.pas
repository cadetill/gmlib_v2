{**
  @abstract(Pruebas automÃ¡ticas del modelo de `TGMMap.Polylines`.)
}
unit uTest.Polyline.Model;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.Polyline;

type
  TPolylineViewportHostStub = class(TComponent, IGMMapViewportHost)
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
  TTestPolylineModel = class
  private
    FClickCount: Integer;
    FContextMenuCount: Integer;
    FDblClickCount: Integer;
    FDragCount: Integer;
    FDragEndCount: Integer;
    FDragStartCount: Integer;
    FLastClickLat: Double;
    FLastClickLng: Double;
    FMouseDownCount: Integer;
    FMouseMoveCount: Integer;
    FMouseOutCount: Integer;
    FMouseOverCount: Integer;
    FMouseUpCount: Integer;
    FPathChangedCount: Integer;
    procedure HandlePolylineClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineContextMenu(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineDrag(Sender: TObject);
    procedure HandlePolylineDragEnd(Sender: TObject);
    procedure HandlePolylineDragStart(Sender: TObject);
    procedure HandlePolylineMouseDown(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineMouseOut(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineMouseOver(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylineMouseUp(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandlePolylinePathChanged(Sender: TObject);
  public
    [Test]
    procedure PolylineOptions_ToJavaScriptLiteral_EmitsCoreFields;

    [Test]
    procedure HiddenPolyline_BuildApplyCommand_ReturnsRemoveCommand;

    [Test]
    procedure Polyline_ProcessMapMessage_Click_FiresEvent;

    [Test]
    procedure Polyline_ProcessMapMessage_ContextMenu_FiresEvent;

    [Test]
    procedure Polyline_ProcessMapMessage_DblClick_FiresEvent;

    [Test]
    procedure Polyline_ProcessMapMessage_DragEvents_FireEvents;

    [Test]
    procedure Polyline_ProcessMapMessage_MouseEvents_FireEvents;

    [Test]
    procedure Polyline_ProcessMapMessage_PathChanged_UpdatesPathAndFiresEvent;

    [Test]
    procedure Polylines_Assign_CopiesItemsAndPath;

    [Test]
    procedure Polylines_ZoomToPoints_ForwardsBoundsToViewportHost;

    [Test]
    procedure PolylineDestruction_RegistersPendingRemoval;
  end;

implementation

procedure TPolylineViewportHostStub.CenterMapTo(const ALatLng: TMapLibLatLng);
begin
  Inc(CenterCallCount);
end;

procedure TPolylineViewportHostStub.FitBounds(ANorth, ASouth, AEast,
  AWest: Double);
begin
  Inc(FitBoundsCallCount);
  LastNorth := ANorth;
  LastSouth := ASouth;
  LastEast := AEast;
  LastWest := AWest;
end;

procedure TTestPolylineModel.HandlePolylineClick(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FClickCount);
  if Assigned(ALatLng) then
  begin
    FLastClickLat := ALatLng.Lat;
    FLastClickLng := ALatLng.Lng;
  end;
end;

procedure TTestPolylineModel.HandlePolylineContextMenu(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FContextMenuCount);
  if Assigned(ALatLng) then
  begin
    FLastClickLat := ALatLng.Lat;
    FLastClickLng := ALatLng.Lng;
  end;
end;

procedure TTestPolylineModel.HandlePolylineDblClick(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FDblClickCount);
  if Assigned(ALatLng) then
  begin
    FLastClickLat := ALatLng.Lat;
    FLastClickLng := ALatLng.Lng;
  end;
end;

procedure TTestPolylineModel.HandlePolylineDrag(Sender: TObject);
begin
  Inc(FDragCount);
end;

procedure TTestPolylineModel.HandlePolylineDragEnd(Sender: TObject);
begin
  Inc(FDragEndCount);
end;

procedure TTestPolylineModel.HandlePolylineDragStart(Sender: TObject);
begin
  Inc(FDragStartCount);
end;

procedure TTestPolylineModel.HandlePolylineMouseDown(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FMouseDownCount);
end;

procedure TTestPolylineModel.HandlePolylineMouseMove(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FMouseMoveCount);
end;

procedure TTestPolylineModel.HandlePolylineMouseOut(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FMouseOutCount);
end;

procedure TTestPolylineModel.HandlePolylineMouseOver(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FMouseOverCount);
end;

procedure TTestPolylineModel.HandlePolylineMouseUp(Sender: TObject;
  ALatLng: TMapLibLatLng);
begin
  Inc(FMouseUpCount);
end;

procedure TTestPolylineModel.HandlePolylinePathChanged(Sender: TObject);
begin
  Inc(FPathChangedCount);
end;

procedure TTestPolylineModel.HiddenPolyline_BuildApplyCommand_ReturnsRemoveCommand;
var
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  Polylines := TGMPolylines.Create(nil);
  try
    Polyline := Polylines.Add;
    Polyline.Options.Path.Add(41.3874, 2.1686);
    Polyline.Options.Path.Add(48.8566, 2.3522);
    Polyline.Options.Visible := False;

    Assert.AreEqual(
      Polyline.BuildRemoveCommand,
      Polyline.BuildApplyCommand,
      'A hidden polyline must be synchronized as a remove command.'
    );
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.Polyline_ProcessMapMessage_Click_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  FClickCount := 0;
  FLastClickLat := 0;
  FLastClickLng := 0;

  Polylines := TGMPolylines.Create(nil);
  try
    Polyline := Polylines.Add;
    Polyline.OnClick := HandlePolylineClick;

    Envelope.MessageType := 'polyline.click';
    Envelope.TargetId := Polyline.ObjectId;
    Envelope.Payload := '{"lat":41.39,"lng":2.17}';

    Polyline.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FClickCount, 'Polyline click must reach the Delphi event.');
    Assert.AreEqual(41.39, FLastClickLat, 0.000001);
    Assert.AreEqual(2.17, FLastClickLng, 0.000001);
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.Polyline_ProcessMapMessage_ContextMenu_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  FContextMenuCount := 0;
  FLastClickLat := 0;
  FLastClickLng := 0;

  Polylines := TGMPolylines.Create(nil);
  try
    Polyline := Polylines.Add;
    Polyline.OnContextMenu := HandlePolylineContextMenu;

    Envelope.MessageType := 'polyline.contextmenu';
    Envelope.TargetId := Polyline.ObjectId;
    Envelope.Payload := '{"lat":40.41,"lng":-3.70}';

    Polyline.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FContextMenuCount, 'Polyline contextmenu must reach the Delphi event.');
    Assert.AreEqual(40.41, FLastClickLat, 0.000001);
    Assert.AreEqual(-3.70, FLastClickLng, 0.000001);
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.Polyline_ProcessMapMessage_DblClick_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  FDblClickCount := 0;
  FLastClickLat := 0;
  FLastClickLng := 0;

  Polylines := TGMPolylines.Create(nil);
  try
    Polyline := Polylines.Add;
    Polyline.OnDblClick := HandlePolylineDblClick;

    Envelope.MessageType := 'polyline.dblclick';
    Envelope.TargetId := Polyline.ObjectId;
    Envelope.Payload := '{"lat":48.85,"lng":2.35}';

    Polyline.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FDblClickCount, 'Polyline dblclick must reach the Delphi event.');
    Assert.AreEqual(48.85, FLastClickLat, 0.000001);
    Assert.AreEqual(2.35, FLastClickLng, 0.000001);
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.Polyline_ProcessMapMessage_DragEvents_FireEvents;
var
  Envelope: TGMMessageEnvelope;
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  FDragStartCount := 0;
  FDragCount := 0;
  FDragEndCount := 0;

  Polylines := TGMPolylines.Create(nil);
  try
    Polyline := Polylines.Add;
    Polyline.OnDragStart := HandlePolylineDragStart;
    Polyline.OnDrag := HandlePolylineDrag;
    Polyline.OnDragEnd := HandlePolylineDragEnd;

    Envelope.TargetId := Polyline.ObjectId;
    Envelope.Payload := '';

    Envelope.MessageType := 'polyline.dragstart';
    Polyline.ProcessMapMessage(Envelope);
    Envelope.MessageType := 'polyline.drag';
    Polyline.ProcessMapMessage(Envelope);
    Envelope.MessageType := 'polyline.dragend';
    Polyline.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FDragStartCount);
    Assert.AreEqual(1, FDragCount);
    Assert.AreEqual(1, FDragEndCount);
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.Polyline_ProcessMapMessage_MouseEvents_FireEvents;
var
  Envelope: TGMMessageEnvelope;
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  FMouseDownCount := 0;
  FMouseMoveCount := 0;
  FMouseOutCount := 0;
  FMouseOverCount := 0;
  FMouseUpCount := 0;

  Polylines := TGMPolylines.Create(nil);
  try
    Polyline := Polylines.Add;
    Polyline.OnMouseDown := HandlePolylineMouseDown;
    Polyline.OnMouseMove := HandlePolylineMouseMove;
    Polyline.OnMouseOut := HandlePolylineMouseOut;
    Polyline.OnMouseOver := HandlePolylineMouseOver;
    Polyline.OnMouseUp := HandlePolylineMouseUp;

    Envelope.TargetId := Polyline.ObjectId;
    Envelope.Payload := '{"lat":41.38,"lng":2.16}';

    Envelope.MessageType := 'polyline.mousedown';
    Polyline.ProcessMapMessage(Envelope);
    Envelope.MessageType := 'polyline.mousemove';
    Polyline.ProcessMapMessage(Envelope);
    Envelope.MessageType := 'polyline.mouseout';
    Polyline.ProcessMapMessage(Envelope);
    Envelope.MessageType := 'polyline.mouseover';
    Polyline.ProcessMapMessage(Envelope);
    Envelope.MessageType := 'polyline.mouseup';
    Polyline.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FMouseDownCount);
    Assert.AreEqual(1, FMouseMoveCount);
    Assert.AreEqual(1, FMouseOutCount);
    Assert.AreEqual(1, FMouseOverCount);
    Assert.AreEqual(1, FMouseUpCount);
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.Polyline_ProcessMapMessage_PathChanged_UpdatesPathAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  FPathChangedCount := 0;

  Polylines := TGMPolylines.Create(nil);
  try
    Polyline := Polylines.Add;
    Polyline.Options.Path.Add(0, 0);
    Polyline.OnPathChanged := HandlePolylinePathChanged;

    Envelope.MessageType := 'polyline.path_changed';
    Envelope.TargetId := Polyline.ObjectId;
    Envelope.Payload := '[{"lat":41.3874,"lng":2.1686},{"lat":48.8566,"lng":2.3522}]';

    Polyline.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FPathChangedCount, 'Polyline path_changed must reach the Delphi event.');
    Assert.AreEqual(2, Polyline.Options.Path.Count);
    Assert.AreEqual(41.3874, Polyline.Options.Path[0].Lat, 0.000001);
    Assert.AreEqual(2.3522, Polyline.Options.Path[1].Lng, 0.000001);
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.PolylineDestruction_RegistersPendingRemoval;
var
  PolylineId: TGMObjectId;
  Polylines: TGMPolylines;
begin
  Polylines := TGMPolylines.Create(nil);
  try
    PolylineId := Polylines.Add.ObjectId;

    Assert.AreEqual(1, Polylines.Count);
    Polylines.Delete(0);

    Assert.AreEqual(0, Polylines.Count);
    Assert.IsTrue(
      Polylines.PendingRemovals.Contains(PolylineId),
      'Deleting a polyline must queue its removal for JS synchronization.'
    );
  finally
    Polylines.Free;
  end;
end;

procedure TTestPolylineModel.Polylines_Assign_CopiesItemsAndPath;
var
  SourcePolylines: TGMPolylines;
  TargetPolylines: TGMPolylines;
begin
  SourcePolylines := TGMPolylines.Create(nil);
  TargetPolylines := TGMPolylines.Create(nil);
  try
    SourcePolylines.BeginUpdate;
    try
      SourcePolylines.Add.Options.Path.Add(41.3874, 2.1686);
      SourcePolylines[0].Options.Path.Add(48.8566, 2.3522);
      SourcePolylines[0].Options.StrokeColor := '#0f172a';
      SourcePolylines.Add.Options.Path.Add(40.4168, -3.7038);
      SourcePolylines[1].Options.Visible := False;
    finally
      SourcePolylines.EndUpdate;
    end;

    TargetPolylines.Assign(SourcePolylines);

    Assert.AreEqual(SourcePolylines.Count, TargetPolylines.Count);
    Assert.AreEqual(2, TargetPolylines[0].Options.Path.Count);
    Assert.AreEqual(41.3874, TargetPolylines[0].Options.Path[0].Lat, 0.000001);
    Assert.AreEqual(2.3522, TargetPolylines[0].Options.Path[1].Lng, 0.000001);
    Assert.AreEqual('#0f172a', TargetPolylines[0].Options.StrokeColor);
    Assert.IsFalse(TargetPolylines[1].Options.Visible);
  finally
    TargetPolylines.Free;
    SourcePolylines.Free;
  end;
end;

procedure TTestPolylineModel.Polylines_ZoomToPoints_ForwardsBoundsToViewportHost;
var
  Host: TPolylineViewportHostStub;
  Polyline: TGMPolylineItem;
  Polylines: TGMPolylines;
begin
  Host := TPolylineViewportHostStub.Create(nil);
  Polylines := TGMPolylines.Create(Host);
  try
    Polyline := Polylines.Add;
    Polyline.Options.Path.Add(41.3874, 2.1686);
    Polyline.Options.Path.Add(48.8566, 2.3522);
    Polyline.Options.Path.Add(40.4168, -3.7038);

    Polylines.ZoomToPoints;

    Assert.AreEqual(1, Host.FitBoundsCallCount);
    Assert.AreEqual(48.8566, Host.LastNorth, 0.000001);
    Assert.AreEqual(40.4168, Host.LastSouth, 0.000001);
    Assert.AreEqual(2.3522, Host.LastEast, 0.000001);
    Assert.AreEqual(-3.7038, Host.LastWest, 0.000001);
  finally
    Polylines.Free;
    Host.Free;
  end;
end;

procedure TTestPolylineModel.PolylineOptions_ToJavaScriptLiteral_EmitsCoreFields;
var
  Literal: string;
  Options: TGMPolylineOptions;
begin
  Options := TGMPolylineOptions.Create;
  try
    Options.Path.Add(41.3874, 2.1686);
    Options.Path.Add(48.8566, 2.3522);
    Options.Clickable := True;
    Options.Draggable := False;
    Options.Editable := True;
    Options.Geodesic := True;
    Options.StrokeColor := '#ff0000';
    Options.StrokeOpacity := 0.75;
    Options.StrokeWeight := 5;
    Options.Visible := True;
    Options.ZIndex := 9;

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('path:', Literal) > 0);
    Assert.IsTrue(Pos('lat: 41.3874', Literal) > 0);
    Assert.IsTrue(Pos('lng: 2.3522', Literal) > 0);
    Assert.IsTrue(Pos('clickable: true', Literal) > 0);
    Assert.IsTrue(Pos('editable: true', Literal) > 0);
    Assert.IsTrue(Pos('geodesic: true', Literal) > 0);
    Assert.IsTrue(Pos('strokeColor: ''#ff0000''', Literal) > 0);
    Assert.IsTrue(Pos('strokeOpacity: 0.75', Literal) > 0);
    Assert.IsTrue(Pos('strokeWeight: 5', Literal) > 0);
    Assert.IsTrue(Pos('visible: true', Literal) > 0);
    Assert.IsTrue(Pos('zIndex: 9', Literal) > 0);
  finally
    Options.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPolylineModel);

end.

