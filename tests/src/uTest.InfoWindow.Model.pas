{**
  @abstract(Pruebas automáticas del modelo de `TGMMap.InfoWindows`.)
}
unit uTest.InfoWindow.Model;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.InfoWindow,
  uGMLib.Marker;

type
  TViewportHostStub = class(TComponent, IGMMapViewportHost)
  public
    CenterCallCount: Integer;
    LastLat: Double;
    LastLng: Double;
    procedure CenterMapTo(const ALatLng: TGMLibLatLng);
    procedure FitBounds(ANorth, ASouth, AEast, AWest: Double);
  end;

  [TestFixture]
  TTestInfoWindowModel = class
  private
    FCloseCount: Integer;
    FCloseClickCount: Integer;
    FContentChangedCount: Integer;
    FDomReadyCount: Integer;
    FHeaderContentChangedCount: Integer;
    FHeaderDisabledChangedCount: Integer;
    FLastContent: string;
    FLastHeaderContent: string;
    FLastHeaderDisabled: Boolean;
    FLastZIndex: Integer;
    FPositionChangedCount: Integer;
    FVisibleCount: Integer;
    FZIndexChangedCount: Integer;
    FLastPositionLat: Double;
    FLastPositionLng: Double;
    procedure HandleClose(Sender: TObject);
    procedure HandleCloseClick(Sender: TObject);
    procedure HandleContentChanged(Sender: TObject; const AValue: string);
    procedure HandleDomReady(Sender: TObject);
    procedure HandleHeaderContentChanged(Sender: TObject; const AValue: string);
    procedure HandleHeaderDisabledChanged(Sender: TObject; AValue: Boolean);
    procedure HandlePositionChanged(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleVisible(Sender: TObject);
    procedure HandleZIndexChanged(Sender: TObject; AValue: Integer);
  public
    [Test]
    procedure InfoWindowOptions_ToJavaScriptLiteral_EmitsCoreFields;

    [Test]
    procedure InfoWindowOptions_ToJavaScriptLiteral_PreservesContentWithCommas;

    [Test]
    procedure InfoWindowOptions_ToJavaScriptLiteral_EmitsAriaLabelAndPixelOffset;

    [Test]
    procedure InfoWindow_BuildApplyCommand_OpensWithAnchorMarker;

    [Test]
    procedure InfoWindow_BuildApplyCommand_OpensWithGenericAnchorObjectId;

    [Test]
    procedure InfoWindow_CenterMapTo_ForwardsPositionToViewportHost;

    [Test]
    procedure InfoWindow_Assign_CopiesOpenOptions;

    [Test]
    procedure InfoWindow_BuildApplyCommand_ClosesWithoutAnchorByDefault;

    [Test]
    procedure InfoWindow_BuildApplyCommand_OpensWithoutAnchorAndWithoutFocusByDefault;

    [Test]
    procedure InfoWindow_BuildApplyCommand_AppendsFocusForVisibleInfoWindow;

    [Test]
    procedure InfoWindow_Focus_DoesNothingWhenClosed;

    [Test]
    procedure InfoWindows_DetachAnchorFromMarker_ClearsAnchorAndClosesVisibleInfoWindow;

    [Test]
    procedure InfoWindows_CloseOthersBeforeOpen_ClosesPreviousVisibleItem;

    [Test]
    procedure InfoWindow_ProcessMapMessage_Close_UpdatesVisibilityAndFiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_CloseClick_UpdatesVisibilityAndFiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_DomReady_FiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_ContentChanged_UpdatesOptionsAndFiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_HeaderContentChanged_UpdatesOptionsAndFiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_HeaderDisabledChanged_UpdatesOptionsAndFiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_ZIndexChanged_UpdatesOptionsAndFiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_PositionChanged_UpdatesPositionAndFiresEvent;

    [Test]
    procedure InfoWindow_ProcessMapMessage_Visible_UpdatesVisibilityAndFiresEvent;

    [Test]
    procedure InfoWindows_Assign_CopiesItemsAndOptions;

    [Test]
    procedure InfoWindowDestruction_RegistersPendingRemoval;
  end;

implementation

uses
  System.SysUtils;

procedure TViewportHostStub.CenterMapTo(const ALatLng: TGMLibLatLng);
begin
  Inc(CenterCallCount);
  if Assigned(ALatLng) then
  begin
    LastLat := ALatLng.Lat;
    LastLng := ALatLng.Lng;
  end;
end;

procedure TViewportHostStub.FitBounds(ANorth, ASouth, AEast, AWest: Double);
begin
end;

procedure TTestInfoWindowModel.HandleClose(Sender: TObject);
begin
  Inc(FCloseCount);
end;

procedure TTestInfoWindowModel.HandleCloseClick(Sender: TObject);
begin
  Inc(FCloseClickCount);
end;

procedure TTestInfoWindowModel.HandleContentChanged(Sender: TObject; const AValue: string);
begin
  Inc(FContentChangedCount);
  FLastContent := AValue;
end;

procedure TTestInfoWindowModel.HandleDomReady(Sender: TObject);
begin
  Inc(FDomReadyCount);
end;

procedure TTestInfoWindowModel.HandleHeaderContentChanged(Sender: TObject; const AValue: string);
begin
  Inc(FHeaderContentChangedCount);
  FLastHeaderContent := AValue;
end;

procedure TTestInfoWindowModel.HandleHeaderDisabledChanged(Sender: TObject; AValue: Boolean);
begin
  Inc(FHeaderDisabledChangedCount);
  FLastHeaderDisabled := AValue;
end;

procedure TTestInfoWindowModel.HandlePositionChanged(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Inc(FPositionChangedCount);
  FLastPositionLat := ALatLng.Lat;
  FLastPositionLng := ALatLng.Lng;
end;

procedure TTestInfoWindowModel.HandleVisible(Sender: TObject);
begin
  Inc(FVisibleCount);
end;

procedure TTestInfoWindowModel.HandleZIndexChanged(Sender: TObject; AValue: Integer);
begin
  Inc(FZIndexChangedCount);
  FLastZIndex := AValue;
end;

procedure TTestInfoWindowModel.InfoWindowDestruction_RegistersPendingRemoval;
var
  InfoWindowId: TGMObjectId;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindowId := InfoWindows.Add.ObjectId;

    Assert.AreEqual(1, InfoWindows.Count);
    InfoWindows.Delete(0);

    Assert.AreEqual(0, InfoWindows.Count);
    Assert.IsTrue(
      InfoWindows.PendingRemovals.Contains(InfoWindowId),
      'Deleting an info window must register its ObjectId for JS removal.'
    );
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindows_Assign_CopiesItemsAndOptions;
var
  SourceItems: TGMInfoWindows;
  TargetItems: TGMInfoWindows;
begin
  SourceItems := TGMInfoWindows.Create(nil);
  TargetItems := TGMInfoWindows.Create(nil);
  try
    SourceItems.BeginUpdate;
    try
      SourceItems.Add.Options.Content := '<b>A</b>';
      SourceItems[0].Options.Position.Lat := 41.3874;
      SourceItems[0].Options.Position.Lng := 2.1686;
      SourceItems[0].Options.Visible := True;

      SourceItems.Add.Options.Content := '<b>B</b>';
      SourceItems[1].Options.HeaderContent := 'Header';
      SourceItems[1].Options.MaxWidth := 320;
    finally
      SourceItems.EndUpdate;
    end;

    TargetItems.Assign(SourceItems);

    Assert.AreEqual(SourceItems.Count, TargetItems.Count);
    Assert.AreEqual('<b>A</b>', TargetItems[0].Options.Content);
    Assert.AreEqual(41.3874, TargetItems[0].Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.1686, TargetItems[0].Options.Position.Lng, 0.000001);
    Assert.IsTrue(TargetItems[0].Options.Visible);
    Assert.AreEqual('<b>B</b>', TargetItems[1].Options.Content);
    Assert.AreEqual('Header', TargetItems[1].Options.HeaderContent);
    Assert.AreEqual(320, TargetItems[1].Options.MaxWidth);
  finally
    TargetItems.Free;
    SourceItems.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindowOptions_ToJavaScriptLiteral_EmitsCoreFields;
var
  Options: TGMInfoWindowOptions;
  Literal: string;
begin
  Options := TGMInfoWindowOptions.Create;
  try
    Options.Content := '<div>Hello</div>';
    Options.HeaderContent := '<strong>Title</strong>';
    Options.DisableAutoPan := True;
    Options.HeaderDisabled := False;
    Options.MaxWidth := 320;
    Options.MinWidth := 180;
    Options.Position.Lat := 41.3874;
    Options.Position.Lng := 2.1686;
    Options.Visible := True;
    Options.ZIndex := 7;

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsTrue(Literal.Contains('content: ''<div>Hello</div>'''));
    Assert.IsTrue(Literal.Contains('headerContent: ''<strong>Title</strong>'''));
    Assert.IsTrue(Literal.Contains('disableAutoPan: true'));
    Assert.IsTrue(Literal.Contains('maxWidth: 320'));
    Assert.IsTrue(Literal.Contains('minWidth: 180'));
    Assert.IsTrue(Literal.Contains('position: { lat: 41.3874, lng: 2.1686 }'));
    Assert.IsTrue(Literal.Contains('zIndex: 7'));
    Assert.IsFalse(
      Literal.Contains('visible:'),
      'Visible is internal Delphi state and must not be serialized as InfoWindowOptions.'
    );
  finally
    Options.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindowOptions_ToJavaScriptLiteral_PreservesContentWithCommas;
var
  Options: TGMInfoWindowOptions;
  Literal: string;
begin
  Options := TGMInfoWindowOptions.Create;
  try
    Options.Content :=
      '<div style="font:13px Segoe UI,sans-serif;color:#334155">InfoWindow</div>';
    Options.Position.Lat := 41.3874;
    Options.Position.Lng := 2.1686;
    Options.Visible := True;

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsFalse(
      Literal.Contains('"content:'),
      'The JavaScript literal must not quote the whole content entry when HTML contains commas.'
    );
    Assert.IsTrue(
      Literal.Contains('content: ''<div style="font:13px Segoe UI,sans-serif;color:#334155">InfoWindow</div>'''),
      'The content entry must remain a valid key/value pair even when the HTML contains commas.'
    );
  finally
    Options.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindowOptions_ToJavaScriptLiteral_EmitsAriaLabelAndPixelOffset;
var
  Literal: string;
  Options: TGMInfoWindowOptions;
begin
  Options := TGMInfoWindowOptions.Create;
  try
    Options.AriaLabel := 'Store details';
    Options.Content := '<div>Open now</div>';
    Options.PixelOffset.Width := 12;
    Options.PixelOffset.Height := 24;
    Options.Position.Lat := 41.3874;
    Options.Position.Lng := 2.1686;

    Literal := Options.ToJavaScriptLiteral;

    Assert.IsTrue(Literal.Contains('ariaLabel: ''Store details'''));
    Assert.IsTrue(Literal.Contains('pixelOffset: { width: 12, height: 24 }'));
  finally
    Options.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_BuildApplyCommand_OpensWithAnchorMarker;
var
  Command: string;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
  Marker: TGMMarkerItem;
  Markers: TGMMarkers;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  Markers := TGMMarkers.Create(nil);
  try
    Marker := Markers.Add;
    Marker.Options.Position.Lat := 41.3874;
    Marker.Options.Position.Lng := 2.1686;

    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Content := '<div>Anchor</div>';
    InfoWindow.Options.Position.Assign(Marker.Options.Position);
    InfoWindow.Open(Marker, True);

    Command := InfoWindow.BuildApplyCommand;

    Assert.IsTrue(Command.Contains('gmlib.infoWindow.setOptions('));
    Assert.IsTrue(
      Command.Contains(
        Format('gmlib.infoWindow.open(''%s'', { shouldFocus: true, anchorId: ''%s'' });', [
          string(InfoWindow.ObjectId),
          string(Marker.ObjectId)
        ])
      )
    );
  finally
    Markers.Free;
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_BuildApplyCommand_OpensWithGenericAnchorObjectId;
var
  Command: string;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Content := '<div>Anchor</div>';
    InfoWindow.Options.Position.Lat := 41.3874;
    InfoWindow.Options.Position.Lng := 2.1686;
    InfoWindow.OpenByObjectId('overlay_42', True);

    Command := InfoWindow.BuildApplyCommand;

    Assert.IsTrue(
      Command.Contains(
        Format('gmlib.infoWindow.open(''%s'', { shouldFocus: true, anchorId: ''overlay_42'' });', [
          string(InfoWindow.ObjectId)
        ])
      )
    );
    Assert.AreEqual('overlay_42', string(InfoWindow.AnchorObjectId));
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_CenterMapTo_ForwardsPositionToViewportHost;
var
  Host: TViewportHostStub;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  Host := TViewportHostStub.Create(nil);
  InfoWindows := TGMInfoWindows.Create(Host);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Position.Lat := 41.3874;
    InfoWindow.Options.Position.Lng := 2.1686;

    InfoWindow.CenterMapTo;

    Assert.AreEqual(1, Host.CenterCallCount);
    Assert.AreEqual(41.3874, Host.LastLat, 0.000001);
    Assert.AreEqual(2.1686, Host.LastLng, 0.000001);
  finally
    InfoWindows.Free;
    Host.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_Assign_CopiesOpenOptions;
var
  SourceInfoWindow: TGMInfoWindowItem;
  SourceItems: TGMInfoWindows;
  TargetInfoWindow: TGMInfoWindowItem;
  TargetItems: TGMInfoWindows;
begin
  SourceItems := TGMInfoWindows.Create(nil);
  TargetItems := TGMInfoWindows.Create(nil);
  try
    SourceInfoWindow := SourceItems.Add;
    SourceInfoWindow.OpenOptions.AnchorObjectId := 'marker_42';
    SourceInfoWindow.OpenOptions.ShouldFocus := True;
    SourceInfoWindow.Options.Content := '<div>Open options</div>';

    TargetInfoWindow := TargetItems.Add;
    TargetInfoWindow.Assign(SourceInfoWindow);

    Assert.AreEqual(
      string(SourceInfoWindow.OpenOptions.AnchorObjectId),
      string(TargetInfoWindow.OpenOptions.AnchorObjectId)
    );
    Assert.AreEqual(
      SourceInfoWindow.OpenOptions.ShouldFocus,
      TargetInfoWindow.OpenOptions.ShouldFocus
    );
  finally
    TargetItems.Free;
    SourceItems.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_BuildApplyCommand_ClosesWithoutAnchorByDefault;
var
  Command: string;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Content := '<div>Headerless</div>';
    InfoWindow.Options.HeaderContent := 'Title';
    InfoWindow.Options.HeaderDisabled := True;
    InfoWindow.Options.Position.Lat := 41.3874;
    InfoWindow.Options.Position.Lng := 2.1686;
    InfoWindow.Options.Visible := False;

    Command := InfoWindow.BuildApplyCommand;

    Assert.IsTrue(Command.Contains('headerContent: ''Title'''));
    Assert.IsTrue(Command.Contains('headerDisabled: true'));
    Assert.IsTrue(
      Command.Contains(Format('gmlib.infoWindow.close(''%s'');', [string(InfoWindow.ObjectId)]))
    );
    Assert.IsFalse(Command.Contains('anchorId:'));
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_BuildApplyCommand_OpensWithoutAnchorAndWithoutFocusByDefault;
var
  Command: string;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Content := '<div>Open</div>';
    InfoWindow.Options.Position.Lat := 41.3874;
    InfoWindow.Options.Position.Lng := 2.1686;
    InfoWindow.Open;

    Command := InfoWindow.BuildApplyCommand;

    Assert.IsTrue(
      Command.Contains(
        Format('gmlib.infoWindow.open(''%s'', { shouldFocus: false });', [
          string(InfoWindow.ObjectId)
        ])
      )
    );
    Assert.IsFalse(Command.Contains('anchorId:'));
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_BuildApplyCommand_AppendsFocusForVisibleInfoWindow;
var
  Command: string;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Content := '<div>Focusable</div>';
    InfoWindow.Options.Position.Lat := 41.3874;
    InfoWindow.Options.Position.Lng := 2.1686;
    InfoWindow.Open;
    InfoWindow.Focus;

    Command := InfoWindow.BuildApplyCommand;

    Assert.IsTrue(
      Command.Contains(
        Format('gmlib.infoWindow.focus(''%s'');', [string(InfoWindow.ObjectId)])
      )
    );
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_Focus_DoesNothingWhenClosed;
var
  Command: string;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Content := '<div>Closed</div>';
    InfoWindow.Options.Position.Lat := 41.3874;
    InfoWindow.Options.Position.Lng := 2.1686;
    InfoWindow.Focus;

    Command := InfoWindow.BuildApplyCommand;

    Assert.IsFalse(Command.Contains('gmlib.infoWindow.focus('));
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindows_DetachAnchorFromMarker_ClearsAnchorAndClosesVisibleInfoWindow;
var
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OpenOptions.AnchorObjectId := 'marker_77';
    InfoWindow.Options.Visible := True;

    InfoWindows.DetachAnchorFromMarker('marker_77');

    Assert.AreEqual('', string(InfoWindow.AnchorObjectId));
    Assert.IsFalse(InfoWindow.Options.Visible);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindows_CloseOthersBeforeOpen_ClosesPreviousVisibleItem;
var
  FirstInfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
  SecondInfoWindow: TGMInfoWindowItem;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindows.CloseOthersBeforeOpen := True;

    FirstInfoWindow := InfoWindows.Add;
    FirstInfoWindow.Options.Content := '<div>First</div>';
    FirstInfoWindow.Options.Position.Lat := 41.3874;
    FirstInfoWindow.Options.Position.Lng := 2.1686;
    FirstInfoWindow.Open;

    SecondInfoWindow := InfoWindows.Add;
    SecondInfoWindow.Options.Content := '<div>Second</div>';
    SecondInfoWindow.Options.Position.Lat := 41.4036;
    SecondInfoWindow.Options.Position.Lng := 2.1744;
    SecondInfoWindow.Open;

    SecondInfoWindow.BuildApplyCommand;

    Assert.IsFalse(FirstInfoWindow.Options.Visible);
    Assert.IsTrue(SecondInfoWindow.Options.Visible);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_Close_UpdatesVisibilityAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Visible := True;
    InfoWindow.OnClose := HandleClose;

    Envelope.MessageType := 'infowindow.close';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FCloseCount);
    Assert.IsFalse(InfoWindow.Options.Visible);
    Assert.IsFalse(InfoWindow.IsOpen);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_CloseClick_UpdatesVisibilityAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.Options.Visible := True;
    InfoWindow.OnClose := HandleClose;
    InfoWindow.OnCloseClick := HandleCloseClick;

    Envelope.MessageType := 'infowindow.closeclick';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(0, FCloseCount);
    Assert.AreEqual(1, FCloseClickCount);
    Assert.IsFalse(InfoWindow.Options.Visible);
    Assert.IsFalse(InfoWindow.IsOpen);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_DomReady_FiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OnDomReady := HandleDomReady;

    Envelope.MessageType := 'infowindow.domready';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FDomReadyCount);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_ContentChanged_UpdatesOptionsAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OnContentChanged := HandleContentChanged;

    Envelope.MessageType := 'infowindow.content_changed';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '"<div>Updated</div>"';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FContentChangedCount);
    Assert.AreEqual('<div>Updated</div>', FLastContent);
    Assert.AreEqual('<div>Updated</div>', InfoWindow.Options.Content);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_HeaderContentChanged_UpdatesOptionsAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OnHeaderContentChanged := HandleHeaderContentChanged;

    Envelope.MessageType := 'infowindow.headercontent_changed';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '"Header from JS"';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FHeaderContentChangedCount);
    Assert.AreEqual('Header from JS', FLastHeaderContent);
    Assert.AreEqual('Header from JS', InfoWindow.Options.HeaderContent);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_HeaderDisabledChanged_UpdatesOptionsAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OnHeaderDisabledChanged := HandleHeaderDisabledChanged;

    Envelope.MessageType := 'infowindow.headerdisabled_changed';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := 'true';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FHeaderDisabledChangedCount);
    Assert.IsTrue(FLastHeaderDisabled);
    Assert.IsTrue(InfoWindow.Options.HeaderDisabled);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_ZIndexChanged_UpdatesOptionsAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OnZIndexChanged := HandleZIndexChanged;

    Envelope.MessageType := 'infowindow.zindex_changed';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '9';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FZIndexChangedCount);
    Assert.AreEqual(9, FLastZIndex);
    Assert.AreEqual(9, InfoWindow.Options.ZIndex);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_PositionChanged_UpdatesPositionAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OnPositionChanged := HandlePositionChanged;

    Envelope.MessageType := 'infowindow.position_changed';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '{"lat":41.4036,"lng":2.1744}';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FPositionChangedCount);
    Assert.AreEqual(41.4036, FLastPositionLat, 0.000001);
    Assert.AreEqual(2.1744, FLastPositionLng, 0.000001);
    Assert.AreEqual(41.4036, InfoWindow.Options.Position.Lat, 0.000001);
    Assert.AreEqual(2.1744, InfoWindow.Options.Position.Lng, 0.000001);
  finally
    InfoWindows.Free;
  end;
end;

procedure TTestInfoWindowModel.InfoWindow_ProcessMapMessage_Visible_UpdatesVisibilityAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  InfoWindow: TGMInfoWindowItem;
  InfoWindows: TGMInfoWindows;
begin
  InfoWindows := TGMInfoWindows.Create(nil);
  try
    InfoWindow := InfoWindows.Add;
    InfoWindow.OnVisible := HandleVisible;

    Envelope.MessageType := 'infowindow.visible';
    Envelope.TargetId := InfoWindow.ObjectId;
    Envelope.Payload := '';

    InfoWindow.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FVisibleCount);
    Assert.IsTrue(InfoWindow.Options.Visible);
    Assert.IsTrue(InfoWindow.IsOpen);
  finally
    InfoWindows.Free;
  end;
end;

end.
