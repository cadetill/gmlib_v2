{**
  @abstract(Pruebas automaticas del modelo de `TGMMap.GroundOverlays`.)
}
unit uTest.GroundOverlay.Model;

{$HINTS OFF}

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.MapOptions,
  uGMLib.GroundOverlay;

type
  [TestFixture]
  TTestGroundOverlayModel = class
  private
    FClickCount: Integer;
    procedure HandleGroundOverlayClick(Sender: TObject; ALatLng: TGMLibLatLng);
  public
    [Test]
    procedure GroundOverlayOptions_ToJavaScriptLiteral_EmitsUrlAndBounds;

    [Test]
    procedure GroundOverlay_ProcessMapMessage_Click_InvokesEvent;
  end;

implementation

procedure TTestGroundOverlayModel.HandleGroundOverlayClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Inc(FClickCount);
end;

procedure TTestGroundOverlayModel.GroundOverlayOptions_ToJavaScriptLiteral_EmitsUrlAndBounds;
var
  Bounds: TGMLatLngBounds;
  GroundOverlay: TGMGroundOverlayItem;
  GroundOverlays: TGMGroundOverlays;
  Literal: string;
begin
  GroundOverlays := TGMGroundOverlays.Create(nil);
  Bounds := TGMLatLngBounds.Create;
  try
    Bounds.North := 41.40;
    Bounds.South := 41.37;
    Bounds.East := 2.18;
    Bounds.West := 2.15;

    GroundOverlay := GroundOverlays.Add;
    GroundOverlay.Options.Url := 'https://example.com/overlay.png';
    GroundOverlay.Options.Bounds.Assign(Bounds);

    Literal := GroundOverlay.Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('url:', Literal) > 0, 'GroundOverlay literal must serialize the url.');
    Assert.IsTrue(Pos('bounds:', Literal) > 0, 'GroundOverlay literal must serialize bounds.');
    Assert.IsTrue(Pos('visible:', Literal) > 0, 'GroundOverlay literal must serialize visibility.');
  finally
    Bounds.Free;
    GroundOverlays.Free;
  end;
end;

procedure TTestGroundOverlayModel.GroundOverlay_ProcessMapMessage_Click_InvokesEvent;
var
  Envelope: TGMMessageEnvelope;
  GroundOverlay: TGMGroundOverlayItem;
  GroundOverlays: TGMGroundOverlays;
begin
  FClickCount := 0;

  GroundOverlays := TGMGroundOverlays.Create(nil);
  try
    GroundOverlay := GroundOverlays.Add;
    GroundOverlay.OnClick := HandleGroundOverlayClick;

    Envelope.MessageType := 'groundoverlay.click';
    Envelope.Payload := '{"lat":41.39,"lng":2.17}';

    GroundOverlay.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FClickCount, 'GroundOverlay click must reach the Delphi event.');
  finally
    GroundOverlays.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGroundOverlayModel);

end.
