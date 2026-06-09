{**
  @abstract(Pruebas automáticas del modelo base de `OSMLib`.)
}
unit uTest.OSM.Marker.Model;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  uMapLib.Core.Bridge,
  uMapLib.Core.Messages,
  uMapLib.Core.Types,
  uOSMLib.Map;

type
  TBridgeTransportStub = class(TInterfacedObject, IMapBridgeTransport)
  private
    FLoadedHtml: string;
    FOnMessageReceived: TMapBridgeMessageReceivedEvent;
    FPostedCommands: TArray<TMapLibMessageEnvelope>;
    FExecutedScripts: TArray<string>;
  public
    procedure AttachBrowser(const ABrowser: TComponent);
    procedure ExecuteJavaScript(const AScript: string);
    function GetBackend: TGMBridgeBackend;
    function GetIsReady: Boolean;
    procedure LoadHtml(const AHtml: string);
    procedure PostCommand(const AEnvelope: TMapLibMessageEnvelope);
    procedure SetOnMessageReceived(const AHandler: TMapBridgeMessageReceivedEvent);

    property ExecutedScripts: TArray<string> read FExecutedScripts;
    property LoadedHtml: string read FLoadedHtml;
    property PostedCommands: TArray<TMapLibMessageEnvelope> read FPostedCommands;
  end;

  [TestFixture]
  TTestOSMMarkerModel = class
  public
    [Test]
    procedure MarkerBuildAddPayload_SerializesCoreFields;

    [Test]
    procedure MarkersDeleteByObjectId_RemovesExpectedMarker;

    [Test]
    procedure MapActivate_SyncsMarkerClearAndMarkerAddsToBridge;

    [Test]
    procedure BuildJsBootstrapConfig_OnlineModeEmitsCenterZoomAndStyle;
  end;

implementation

uses
  System.JSON,
  System.SysUtils;

procedure TBridgeTransportStub.AttachBrowser(const ABrowser: TComponent);
begin
end;

procedure TBridgeTransportStub.ExecuteJavaScript(const AScript: string);
begin
  SetLength(FExecutedScripts, Length(FExecutedScripts) + 1);
  FExecutedScripts[High(FExecutedScripts)] := AScript;
end;

function TBridgeTransportStub.GetBackend: TGMBridgeBackend;
begin
  Result := bbUnknown;
end;

function TBridgeTransportStub.GetIsReady: Boolean;
begin
  Result := True;
end;

procedure TBridgeTransportStub.LoadHtml(const AHtml: string);
begin
  FLoadedHtml := AHtml;
end;

procedure TBridgeTransportStub.PostCommand(const AEnvelope: TMapLibMessageEnvelope);
begin
  SetLength(FPostedCommands, Length(FPostedCommands) + 1);
  FPostedCommands[High(FPostedCommands)] := AEnvelope;
end;

procedure TBridgeTransportStub.SetOnMessageReceived(
  const AHandler: TMapBridgeMessageReceivedEvent);
begin
  FOnMessageReceived := AHandler;
end;

procedure TTestOSMMarkerModel.BuildJsBootstrapConfig_OnlineModeEmitsCenterZoomAndStyle;
var
  Config: string;
  JsonValue: TJSONValue;
  JsonObject: TJSONObject;
  CenterObject: TJSONObject;
begin
  with TOSMMap.Create(nil) do
  try
    CenterLat := 41.3874;
    CenterLng := 2.1686;
    Zoom := 11.5;
    MapId := 'osm_map_1';
    StyleUrl := 'https://example.com/style.json';

    Config := BuildJsBootstrapConfig;
    JsonValue := TJSONObject.ParseJSONValue(Config);
    try
      Assert.IsTrue(JsonValue is TJSONObject);
      JsonObject := TJSONObject(JsonValue);
      CenterObject := JsonObject.GetValue<TJSONObject>('center');

      Assert.AreEqual('osm_map_1', JsonObject.GetValue<string>('mapId'));
      Assert.AreEqual(11.5, JsonObject.GetValue<Double>('zoom'), 0.000001);
      Assert.AreEqual('https://example.com/style.json', JsonObject.GetValue<string>('styleUrl'));
      Assert.AreEqual('', JsonObject.GetValue<string>('styleJson'));
      Assert.AreEqual(41.3874, CenterObject.GetValue<Double>('lat'), 0.000001);
      Assert.AreEqual(2.1686, CenterObject.GetValue<Double>('lng'), 0.000001);
    finally
      JsonValue.Free;
    end;
  finally
    Free;
  end;
end;

procedure TTestOSMMarkerModel.MapActivate_SyncsMarkerClearAndMarkerAddsToBridge;
var
  Bridge: TBridgeTransportStub;
  Map: TOSMMap;
begin
  Map := TOSMMap.Create(nil);
  try
    Bridge := TBridgeTransportStub.Create;
    Map.Bridge := Bridge;

    Map.Markers.Add(41.3874, 2.1686, 'Barcelona');
    Map.Markers.Add(48.8566, 2.3522, 'Paris');

    Map.Active := True;

    Assert.AreEqual(3, Length(Bridge.PostedCommands));
    Assert.AreEqual('marker.clear', Bridge.PostedCommands[0].MessageType);
    Assert.AreEqual('marker.add', Bridge.PostedCommands[1].MessageType);
    Assert.AreEqual('marker.add', Bridge.PostedCommands[2].MessageType);
    Assert.IsTrue(Pos('"title":"Barcelona"', Bridge.PostedCommands[1].Payload) > 0);
    Assert.IsTrue(Pos('"title":"Paris"', Bridge.PostedCommands[2].Payload) > 0);
  finally
    Map.Free;
  end;
end;

procedure TTestOSMMarkerModel.MarkerBuildAddPayload_SerializesCoreFields;
var
  Marker: TOSMMarkerItem;
  Markers: TOSMMarkers;
  Payload: string;
begin
  Markers := TOSMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.ObjectId := 'osm_marker_42';
    Marker.Lat := 41.3874;
    Marker.Lng := 2.1686;
    Marker.Title := 'Marker "quoted"';
    Marker.Visible := False;
    Marker.StandardOptions.ColorCss := '#ff0000';
    Marker.StandardOptions.GlyphText := 'A';
    Marker.StandardOptions.GlyphTextColorCss := '#ffffff';
    Marker.StandardOptions.Scale := 1.25;
    Marker.StandardOptions.HideDefaultCenterDot := True;

    Payload := Marker.BuildAddPayload;

    Assert.IsTrue(Pos('"objectId":"osm_marker_42"', Payload) > 0);
    Assert.IsTrue(Pos('"lat":41.3874', Payload) > 0);
    Assert.IsTrue(Pos('"lng":2.1686', Payload) > 0);
    Assert.IsTrue(Pos('"title":"Marker \"quoted\""', Payload) > 0);
    Assert.IsTrue(Pos('"visible":false', Payload) > 0);
    Assert.IsTrue(Pos('"kind":"standard"', Payload) > 0);
    Assert.IsTrue(Pos('"color":"#ff0000"', Payload) > 0);
    Assert.IsTrue(Pos('"glyphText":"A"', Payload) > 0);
    Assert.IsTrue(Pos('"glyphTextColor":"#ffffff"', Payload) > 0);
    Assert.IsTrue(Pos('"hideDefaultCenterDot":true', Payload) > 0);
  finally
    Markers.Free;
  end;
end;

procedure TTestOSMMarkerModel.MarkersDeleteByObjectId_RemovesExpectedMarker;
var
  FirstMarker: TOSMMarkerItem;
  SecondMarker: TOSMMarkerItem;
  Markers: TOSMMarkers;
begin
  Markers := TOSMMarkers.Create(nil);
  try
    FirstMarker := Markers.Add(41.3874, 2.1686, 'A');
    SecondMarker := Markers.Add(48.8566, 2.3522, 'B');

    Assert.IsTrue(Markers.DeleteByObjectId(FirstMarker.ObjectId));
    Assert.AreEqual(1, Markers.Count);
    Assert.AreSame(SecondMarker, Markers[0]);
    Assert.IsFalse(Markers.DeleteByObjectId('missing_marker'));
  finally
    Markers.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestOSMMarkerModel);

end.
