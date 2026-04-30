{**
  @abstract(Pruebas automáticas de serialización para `TGMMapOptions`.)
}
unit uTest.MapOptions.Serialization;

interface

uses
  DUnitX.TestFramework,
  uGMLib.Core.Types,
  uGMLib.MapOptions;

type
  [TestFixture]
  TTestMapOptionsSerialization = class
  private
    procedure AssertContains(const AText, AExpected: string);
    procedure AssertNotContains(const AText, AUnexpected: string);
  public
    [Test]
    procedure DefaultOptions_DoNotEmitOptionalPhase1OrPhase2Fields;

    [Test]
    procedure CameraControl_IsSerializedOnlyAfterExplicitAssignment;

    [Test]
    procedure InitOnlyOptions_AppearInInitializationLiteralWhenAssigned;

    [Test]
    procedure Restriction_IsSerializedOnlyWhenBoundsAreComplete;

    [Test]
    procedure CursorOptions_AreSerializedWhenAssigned;

    [Test]
    procedure MapTypeControlOptions_SerializeConfiguredMapTypeIds;
  end;

implementation

uses
  System.SysUtils;

procedure TTestMapOptionsSerialization.AssertContains(const AText,
  AExpected: string);
begin
  Assert.IsTrue(
    Pos(AExpected, AText) > 0,
    Format('Expected to find "%s" in "%s"', [AExpected, AText])
  );
end;

procedure TTestMapOptionsSerialization.AssertNotContains(const AText,
  AUnexpected: string);
begin
  Assert.IsTrue(
    Pos(AUnexpected, AText) = 0,
    Format('Did not expect to find "%s" in "%s"', [AUnexpected, AText])
  );
end;

procedure TTestMapOptionsSerialization.CameraControl_IsSerializedOnlyAfterExplicitAssignment;
var
  Options: TGMMapOptions;
  JsLiteral: string;
begin
  Options := TGMMapOptions.Create;
  try
    JsLiteral := Options.ToJavaScriptLiteral;
    AssertNotContains(JsLiteral, 'cameraControl:');

    Options.CameraControl := True;
    Options.CameraControlOptions.Position := cpTopLeft;
    JsLiteral := Options.ToJavaScriptLiteral;

    AssertContains(JsLiteral, 'cameraControl: true');
    AssertContains(JsLiteral, 'cameraControlOptions:');
    AssertContains(JsLiteral, 'google.maps.ControlPosition.TOP_LEFT');
  finally
    Options.Free;
  end;
end;

procedure TTestMapOptionsSerialization.CursorOptions_AreSerializedWhenAssigned;
var
  Options: TGMMapOptions;
  JsLiteral: string;
begin
  Options := TGMMapOptions.Create;
  try
    Options.DraggableCursor := 'crosshair';
    Options.DraggingCursor := 'move';

    JsLiteral := Options.ToJavaScriptLiteral;

    AssertContains(JsLiteral, 'draggableCursor: ''crosshair''');
    AssertContains(JsLiteral, 'draggingCursor: ''move''');
  finally
    Options.Free;
  end;
end;

procedure TTestMapOptionsSerialization.DefaultOptions_DoNotEmitOptionalPhase1OrPhase2Fields;
var
  Options: TGMMapOptions;
  JsLiteral: string;
begin
  Options := TGMMapOptions.Create;
  try
    JsLiteral := Options.ToJavaScriptLiteral;

    AssertNotContains(JsLiteral, 'cameraControl:');
    AssertNotContains(JsLiteral, 'colorScheme:');
    AssertNotContains(JsLiteral, 'controlSize:');
    AssertNotContains(JsLiteral, 'mapId:');
    AssertNotContains(JsLiteral, 'renderingType:');
    AssertNotContains(JsLiteral, 'restriction:');
    AssertNotContains(JsLiteral, 'draggableCursor:');
    AssertNotContains(JsLiteral, 'draggingCursor:');
  finally
    Options.Free;
  end;
end;

procedure TTestMapOptionsSerialization.InitOnlyOptions_AppearInInitializationLiteralWhenAssigned;
var
  InitLiteral: string;
  JsLiteral: string;
  Options: TGMMapOptions;
begin
  Options := TGMMapOptions.Create;
  try
    Options.ColorScheme := csDark;
    Options.ControlSize := 48;
    Options.MapId := 'demo-map-id';
    Options.RenderingType := rtVector;

    InitLiteral := Options.BuildInitializationOptionsLiteral;
    JsLiteral := Options.ToJavaScriptLiteral;

    AssertContains(InitLiteral, 'colorScheme=google.maps.ColorScheme.DARK;');
    AssertContains(InitLiteral, 'controlSize=48;');
    AssertContains(InitLiteral, 'mapId=demo-map-id;');
    AssertContains(InitLiteral, 'renderingType=google.maps.RenderingType.VECTOR;');

    AssertContains(JsLiteral, 'colorScheme: google.maps.ColorScheme.DARK');
    AssertContains(JsLiteral, 'controlSize: 48');
    AssertContains(JsLiteral, 'mapId: ''demo-map-id''');
    AssertContains(JsLiteral, 'renderingType: google.maps.RenderingType.VECTOR');
  finally
    Options.Free;
  end;
end;

procedure TTestMapOptionsSerialization.MapTypeControlOptions_SerializeConfiguredMapTypeIds;
var
  JsLiteral: string;
  Options: TGMMapOptions;
begin
  Options := TGMMapOptions.Create;
  try
    Options.MapTypeControlOptions.MapTypeIds := [mtRoadmap, mtTerrain];
    JsLiteral := Options.ToJavaScriptLiteral;

    AssertContains(JsLiteral, 'mapTypeIds: [''roadmap'', ''terrain'']');
  finally
    Options.Free;
  end;
end;

procedure TTestMapOptionsSerialization.Restriction_IsSerializedOnlyWhenBoundsAreComplete;
var
  JsLiteral: string;
  Options: TGMMapOptions;
begin
  Options := TGMMapOptions.Create;
  try
    Options.Restriction.LatLngBounds.North := 45.0;
    Options.Restriction.LatLngBounds.South := 40.0;
    Options.Restriction.LatLngBounds.East := 3.0;
    JsLiteral := Options.ToJavaScriptLiteral;
    AssertNotContains(JsLiteral, 'restriction:');

    Options.Restriction.LatLngBounds.West := -2.0;
    Options.Restriction.StrictBounds := True;
    JsLiteral := Options.ToJavaScriptLiteral;

    AssertContains(JsLiteral, 'restriction: { latLngBounds:');
    AssertContains(JsLiteral, 'north: 45');
    AssertContains(JsLiteral, 'south: 40');
    AssertContains(JsLiteral, 'east: 3');
    AssertContains(JsLiteral, 'west: -2');
    AssertContains(JsLiteral, 'strictBounds: true');
  finally
    Options.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMapOptionsSerialization);

end.
