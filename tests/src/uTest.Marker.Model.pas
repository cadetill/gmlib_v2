{**
  @abstract(Pruebas automÃ¡ticas del modelo de `TGMMap.Markers`.)
}
unit uTest.Marker.Model;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.Marker;

type
  TMarkerViewportHostStub = class(TComponent, IGMMapViewportHost)
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
  TTestMarkerModel = class
  private
    FClickCount: Integer;
    FDragCount: Integer;
    FDragStartCount: Integer;
    FDragEndCount: Integer;
    FMouseDownCount: Integer;
    FMouseEnterCount: Integer;
    FMouseLeaveCount: Integer;
    FMouseUpCount: Integer;
    FLastDragEventLat: Double;
    FLastDragEventLng: Double;
    FLastDragLat: Double;
    FLastDragLng: Double;
    procedure HandleMarkerClick(Sender: TObject);
    procedure HandleMarkerDrag(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMarkerDragStart(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMarkerDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMarkerMouseDown(Sender: TObject);
    procedure HandleMarkerMouseEnter(Sender: TObject);
    procedure HandleMarkerMouseLeave(Sender: TObject);
    procedure HandleMarkerMouseUp(Sender: TObject);
  public
    [Test]
    procedure MarkerOptions_ToJavaScriptLiteral_EmitsCoreFields;

    [Test]
    procedure MarkerOptions_PinContent_IsSerialized;

    [Test]
    procedure MarkerOptions_HtmlContent_IsSerialized;

    [Test]
    procedure MarkerOptions_LabelContent_IsSerialized;

    [Test]
    procedure HiddenMarker_BuildApplyCommand_ReturnsRemoveCommand;

    [Test]
    procedure Markers_AddOverload_CreatesPositionedMarker;

    [Test]
    procedure Markers_LoadFromArray_CreatesItems;

    [Test]
    procedure Markers_LoadFromCSV_CreatesItems;

    [Test]
    procedure Marker_ProcessMapMessage_FiresOnClick;

    [Test]
    procedure Marker_ProcessMapMessage_Drag_UpdatesPositionAndFiresEvent;

    [Test]
    procedure Marker_ProcessMapMessage_DragStart_UpdatesPositionAndFiresEvent;

    [Test]
    procedure Marker_ProcessMapMessage_DragEnd_UpdatesPositionAndFiresEvent;

    [Test]
    procedure Marker_ProcessMapMessage_MouseDown_FiresEvent;

    [Test]
    procedure Marker_ProcessMapMessage_MouseEnter_FiresEvent;

    [Test]
    procedure Marker_ProcessMapMessage_MouseLeave_FiresEvent;

    [Test]
    procedure Marker_ProcessMapMessage_MouseUp_FiresEvent;

    [Test]
    procedure Markers_Assign_CopiesItemsAndOptions;

    [Test]
    procedure Markers_ZoomToPoints_ForwardsBoundsToViewportHost;

    [Test]
    procedure MarkerDestruction_RegistersPendingRemoval;
  end;

implementation

uses
  System.SysUtils;

procedure TMarkerViewportHostStub.CenterMapTo(const ALatLng: TMapLibLatLng);
begin
  Inc(CenterCallCount);
end;

procedure TMarkerViewportHostStub.FitBounds(ANorth, ASouth, AEast, AWest: Double);
begin
  Inc(FitBoundsCallCount);
  LastNorth := ANorth;
  LastSouth := ASouth;
  LastEast := AEast;
  LastWest := AWest;
end;

procedure TTestMarkerModel.HandleMarkerClick(Sender: TObject);
begin
  Inc(FClickCount);
end;

procedure TTestMarkerModel.HandleMarkerDrag(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Inc(FDragCount);
  FLastDragEventLat := ALatLng.Lat;
  FLastDragEventLng := ALatLng.Lng;
end;

procedure TTestMarkerModel.HandleMarkerDragStart(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Inc(FDragStartCount);
  FLastDragEventLat := ALatLng.Lat;
  FLastDragEventLng := ALatLng.Lng;
end;

procedure TTestMarkerModel.HandleMarkerDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Inc(FDragEndCount);
  FLastDragLat := ALatLng.Lat;
  FLastDragLng := ALatLng.Lng;
end;

procedure TTestMarkerModel.HandleMarkerMouseDown(Sender: TObject);
begin
  Inc(FMouseDownCount);
end;

procedure TTestMarkerModel.HandleMarkerMouseEnter(Sender: TObject);
begin
  Inc(FMouseEnterCount);
end;

procedure TTestMarkerModel.HandleMarkerMouseLeave(Sender: TObject);
begin
  Inc(FMouseLeaveCount);
end;

procedure TTestMarkerModel.HandleMarkerMouseUp(Sender: TObject);
begin
  Inc(FMouseUpCount);
end;

procedure TTestMarkerModel.HiddenMarker_BuildApplyCommand_ReturnsRemoveCommand;
var
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.Options.Visible := False;

    Assert.AreEqual(
      Marker.BuildRemoveCommand,
      Marker.BuildApplyCommand,
      'A hidden marker must be synchronized as a remove command.'
    );
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Markers_AddOverload_CreatesPositionedMarker;
var
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add(41.3874, 2.1686, 'Seed marker');

    Assert.AreEqual('Seed marker', Marker.Options.Title);
    Assert.AreEqual(41.3874, Marker.Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.1686, Marker.Options.Position.Lng, 0.000001);
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Markers_LoadFromArray_CreatesItems;
var
  Markers: TGMMarkers;
begin
  Markers := TGMMarkers.Create(nil);
  try
    Markers.LoadFromArray([
      TGMMarkerSeed.Create(41.3874, 2.1686, 'Marker A'),
      TGMMarkerSeed.Create(48.8566, 2.3522, 'Marker B', False)
    ]);

    Assert.AreEqual(2, Markers.Count);
    Assert.AreEqual('Marker A', Markers[0].Options.Title);
    Assert.AreEqual('Marker B', Markers[1].Options.Title);
    Assert.IsFalse(Markers[1].Options.Visible);
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Markers_LoadFromCSV_CreatesItems;
var
  Markers: TGMMarkers;
  CsvText: string;
begin
  Markers := TGMMarkers.Create(nil);
  try
    CsvText :=
      'lat,lng,title,visible' + sLineBreak +
      '41.3874,2.1686,Marker A,true' + sLineBreak +
      '48.8566,2.3522,Marker B,false';

    Markers.LoadFromCSV(CsvText, 'lat', 'lng', 'title', 'visible');

    Assert.AreEqual(2, Markers.Count);
    Assert.AreEqual('Marker A', Markers[0].Options.Title);
    Assert.AreEqual(41.3874, Markers[0].Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.1686, Markers[0].Options.Position.Lng, 0.000001);
    Assert.IsTrue(Markers[0].Options.Visible);
    Assert.AreEqual('Marker B', Markers[1].Options.Title);
    Assert.IsFalse(Markers[1].Options.Visible);
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_FiresOnClick;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FClickCount := 0;
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnClick := HandleMarkerClick;

    Envelope.MessageType := 'marker.click';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FClickCount, 'Marker click must reach the Delphi event.');
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_Drag_UpdatesPositionAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FDragCount := 0;
  FLastDragEventLat := 0;
  FLastDragEventLng := 0;

  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnDrag := HandleMarkerDrag;

    Envelope.MessageType := 'marker.drag';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '{"lat":41.399,"lng":2.18}';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FDragCount, 'Marker drag must reach the Delphi event.');
    Assert.AreEqual(41.399, Marker.Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.18, Marker.Options.Position.Lng, 0.000001);
    Assert.AreEqual(41.399, FLastDragEventLat, 0.000001);
    Assert.AreEqual(2.18, FLastDragEventLng, 0.000001);
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_DragStart_UpdatesPositionAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FDragStartCount := 0;
  FLastDragEventLat := 0;
  FLastDragEventLng := 0;

  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnDragStart := HandleMarkerDragStart;

    Envelope.MessageType := 'marker.dragstart';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '{"lat":41.395,"lng":2.17}';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FDragStartCount, 'Marker drag start must reach the Delphi event.');
    Assert.AreEqual(41.395, Marker.Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.17, Marker.Options.Position.Lng, 0.000001);
    Assert.AreEqual(41.395, FLastDragEventLat, 0.000001);
    Assert.AreEqual(2.17, FLastDragEventLng, 0.000001);
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_DragEnd_UpdatesPositionAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FDragCount := 0;
  FDragStartCount := 0;
  FDragEndCount := 0;
  FLastDragEventLat := 0;
  FLastDragEventLng := 0;
  FLastDragLat := 0;
  FLastDragLng := 0;

  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnDragEnd := HandleMarkerDragEnd;

    Envelope.MessageType := 'marker.dragend';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '{"lat":41.401,"lng":2.191}';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FDragEndCount, 'Marker drag end must reach the Delphi event.');
    Assert.AreEqual(41.401, Marker.Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.191, Marker.Options.Position.Lng, 0.000001);
    Assert.AreEqual(41.401, FLastDragLat, 0.000001);
    Assert.AreEqual(2.191, FLastDragLng, 0.000001);
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_MouseDown_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FMouseDownCount := 0;
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnMouseDown := HandleMarkerMouseDown;

    Envelope.MessageType := 'marker.mousedown';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FMouseDownCount, 'Marker mousedown must reach the Delphi event.');
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_MouseEnter_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FMouseEnterCount := 0;
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnMouseEnter := HandleMarkerMouseEnter;

    Envelope.MessageType := 'marker.mouseenter';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FMouseEnterCount, 'Marker mouseenter must reach the Delphi event.');
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_MouseLeave_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FMouseLeaveCount := 0;
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnMouseLeave := HandleMarkerMouseLeave;

    Envelope.MessageType := 'marker.mouseleave';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FMouseLeaveCount, 'Marker mouseleave must reach the Delphi event.');
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Marker_ProcessMapMessage_MouseUp_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  FMouseUpCount := 0;
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.OnMouseUp := HandleMarkerMouseUp;

    Envelope.MessageType := 'marker.mouseup';
    Envelope.TargetId := Marker.ObjectId;
    Envelope.Payload := '';

    Marker.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FMouseUpCount, 'Marker mouseup must reach the Delphi event.');
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.MarkerDestruction_RegistersPendingRemoval;
var
  MarkerId: TGMObjectId;
  Markers: TGMMarkers;
begin
  Markers := TGMMarkers.Create(nil);
  try
    MarkerId := Markers.Add.ObjectId;

    Assert.AreEqual(1, Markers.Count);
    Markers.Delete(0);

    Assert.AreEqual(0, Markers.Count);
    Assert.IsTrue(
      Markers.PendingRemovals.Contains(MarkerId),
      'Deleting a marker must queue its removal for JS synchronization.'
    );
  finally
    Markers.Free;
  end;
end;

procedure TTestMarkerModel.Markers_Assign_CopiesItemsAndOptions;
var
  SourceMarkers: TGMMarkers;
  TargetMarkers: TGMMarkers;
begin
  SourceMarkers := TGMMarkers.Create(nil);
  TargetMarkers := TGMMarkers.Create(nil);
  try
    SourceMarkers.BeginUpdate;
    try
      SourceMarkers.Add.Options.Title := 'Marker A';
      SourceMarkers[0].Options.Position.Lat := 41.3874;
      SourceMarkers[0].Options.Position.Lng := 2.1686;
      SourceMarkers.Add.Options.Title := 'Marker B';
      SourceMarkers[1].Options.Position.Lat := 48.8566;
      SourceMarkers[1].Options.Position.Lng := 2.3522;
      SourceMarkers[1].Options.Visible := False;
    finally
      SourceMarkers.EndUpdate;
    end;

    TargetMarkers.Assign(SourceMarkers);

    Assert.AreEqual(SourceMarkers.Count, TargetMarkers.Count);
    Assert.AreEqual('Marker A', TargetMarkers[0].Options.Title);
    Assert.AreEqual(41.3874, TargetMarkers[0].Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.1686, TargetMarkers[0].Options.Position.Lng, 0.000001);
    Assert.AreEqual('Marker B', TargetMarkers[1].Options.Title);
    Assert.IsFalse(TargetMarkers[1].Options.Visible);
  finally
    TargetMarkers.Free;
    SourceMarkers.Free;
  end;
end;

procedure TTestMarkerModel.Markers_ZoomToPoints_ForwardsBoundsToViewportHost;
var
  Host: TMarkerViewportHostStub;
  Markers: TGMMarkers;
begin
  Host := TMarkerViewportHostStub.Create(nil);
  Markers := TGMMarkers.Create(Host);
  try
    Markers.Add(41.3874, 2.1686, 'Barcelona');
    Markers.Add(48.8566, 2.3522, 'Paris');
    Markers.Add(40.4168, -3.7038, 'Madrid');

    Markers.ZoomToPoints;

    Assert.AreEqual(1, Host.FitBoundsCallCount);
    Assert.AreEqual(48.8566, Host.LastNorth, 0.000001);
    Assert.AreEqual(40.4168, Host.LastSouth, 0.000001);
    Assert.AreEqual(2.3522, Host.LastEast, 0.000001);
    Assert.AreEqual(-3.7038, Host.LastWest, 0.000001);
  finally
    Markers.Free;
    Host.Free;
  end;
end;

procedure TTestMarkerModel.MarkerOptions_ToJavaScriptLiteral_EmitsCoreFields;
var
  Literal: string;
  Options: TGMMarkerOptions;
begin
  Options := TGMMarkerOptions.Create;
  try
    Options.Position.Lat := 41.3874;
    Options.Position.Lng := 2.1686;
    Options.Title := 'Marker 1';
    Options.Visible := True;
    Options.Clickable := True;
    Options.CollisionBehavior := cbRequiredAndHidesOptional;
    Options.Draggable := True;
    Options.ZIndex := 7;

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('position:', Literal) > 0);
    Assert.IsTrue(Pos('lat: 41.3874', Literal) > 0);
    Assert.IsTrue(Pos('lng: 2.1686', Literal) > 0);
    Assert.IsTrue(Pos('title: ''Marker 1''', Literal) > 0);
    Assert.IsTrue(Pos('visible: true', Literal) > 0);
    Assert.IsTrue(Pos('gmpClickable: true', Literal) > 0);
    Assert.IsTrue(Pos('collisionBehavior: google.maps.CollisionBehavior.REQUIRED_AND_HIDES_OPTIONAL', Literal) > 0);
    Assert.IsTrue(Pos('gmpDraggable: true', Literal) > 0);
    Assert.IsTrue(Pos('zIndex: 7', Literal) > 0);
  finally
    Options.Free;
  end;
end;

procedure TTestMarkerModel.MarkerOptions_PinContent_IsSerialized;
var
  Literal: string;
  Options: TGMMarkerOptions;
begin
  Options := TGMMarkerOptions.Create;
  try
    Options.ContentMode := mcmPin;
    Options.PinOptions.BackgroundCss := '#ff0000';
    Options.PinOptions.BorderColorCss := '#00ff00';
    Options.PinOptions.GlyphColorCss := '#0000ff';
    Options.PinOptions.GlyphText := 'A';
    Options.PinOptions.Scale := 1.5;

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('contentMode: ''pin''', Literal) > 0);
    Assert.IsTrue(Pos('pinOptions:', Literal) > 0);
    Assert.IsTrue(Pos('background: ''#ff0000''', Literal) > 0);
    Assert.IsTrue(Pos('borderColor: ''#00ff00''', Literal) > 0);
    Assert.IsTrue(Pos('glyphColor: ''#0000ff''', Literal) > 0);
    Assert.IsTrue(Pos('glyphText: ''A''', Literal) > 0);
    Assert.IsTrue(Pos('scale: 1.5', Literal) > 0);
  finally
    Options.Free;
  end;
end;

procedure TTestMarkerModel.MarkerOptions_HtmlContent_IsSerialized;
var
  Literal: string;
  Options: TGMMarkerOptions;
begin
  Options := TGMMarkerOptions.Create;
  try
    Options.ContentMode := mcmHtml;
    Options.HtmlOptions.CssClassName := 'gm-marker-card';
    Options.HtmlOptions.Html := '<div><strong>42</strong><span>EUR</span></div>';

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('contentMode: ''html''', Literal) > 0);
    Assert.IsTrue(Pos('htmlOptions:', Literal) > 0);
    Assert.IsTrue(Pos('cssClassName: ''gm-marker-card''', Literal) > 0);
    Assert.IsTrue(Pos('html: ''<div><strong>42</strong><span>EUR</span></div>''', Literal) > 0);
  finally
    Options.Free;
  end;
end;

procedure TTestMarkerModel.MarkerOptions_LabelContent_IsSerialized;
var
  Literal: string;
  Options: TGMMarkerOptions;
begin
  Options := TGMMarkerOptions.Create;
  try
    Options.ContentMode := mcmLabel;
    Options.LabelOptions.CssClassName := 'gm-marker-label';
    Options.LabelOptions.Text := 'Cafe';
    Options.LabelOptions.BackgroundCss := '#1d4ed8';
    Options.LabelOptions.BorderColorCss := '#93c5fd';
    Options.LabelOptions.TextColorCss := '#eff6ff';
    Options.LabelOptions.PaddingHorizontal := 14;
    Options.LabelOptions.PaddingVertical := 9;
    Options.LabelOptions.CornerRadius := 16;
    Options.LabelOptions.FontSize := 14;
    Options.LabelOptions.FontBold := True;

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('contentMode: ''label''', Literal) > 0);
    Assert.IsTrue(Pos('labelOptions:', Literal) > 0);
    Assert.IsTrue(Pos('cssClassName: ''gm-marker-label''', Literal) > 0);
    Assert.IsTrue(Pos('text: ''Cafe''', Literal) > 0);
    Assert.IsTrue(Pos('background: ''#1d4ed8''', Literal) > 0);
    Assert.IsTrue(Pos('borderColor: ''#93c5fd''', Literal) > 0);
    Assert.IsTrue(Pos('textColor: ''#eff6ff''', Literal) > 0);
    Assert.IsTrue(Pos('paddingHorizontal: 14', Literal) > 0);
    Assert.IsTrue(Pos('paddingVertical: 9', Literal) > 0);
    Assert.IsTrue(Pos('cornerRadius: 16', Literal) > 0);
    Assert.IsTrue(Pos('fontSize: 14', Literal) > 0);
    Assert.IsTrue(Pos('fontBold: true', Literal) > 0);
  finally
    Options.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMarkerModel);

end.

