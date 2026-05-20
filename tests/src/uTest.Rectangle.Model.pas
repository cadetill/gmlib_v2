{**
  @abstract(Pruebas automaticas del modelo de `TGMMap.Rectangles`.)
}
unit uTest.Rectangle.Model;

{$HINTS OFF}

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  System.SysUtils,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.MapOptions,
  uGMLib.Rectangle;

type
  [TestFixture]
  TTestRectangleModel = class
  private
    FBoundsChangedCount: Integer;
    FClickCount: Integer;
    procedure HandleRectangleBoundsChanged(Sender: TObject);
    procedure HandleRectangleClick(Sender: TObject; ALatLng: TMapLibLatLng);
  public
    [Test]
    procedure RectangleOptions_ToJavaScriptLiteral_EmitsBounds;

    [Test]
    procedure Rectangle_ProcessMapMessage_BoundsChanged_UpdatesBoundsAndFiresEvent;

    [Test]
    procedure Rectangle_ProcessMapMessage_InvalidClickPayload_DoesNotFireClickEvent;
  end;

implementation

procedure TTestRectangleModel.HandleRectangleBoundsChanged(Sender: TObject);
begin
  Inc(FBoundsChangedCount);
end;

procedure TTestRectangleModel.HandleRectangleClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Inc(FClickCount);
end;

procedure TTestRectangleModel.RectangleOptions_ToJavaScriptLiteral_EmitsBounds;
var
  Bounds: TGMLatLngBounds;
  Rectangle: TGMRectangleItem;
  Rectangles: TGMRectangles;
  Literal: string;
begin
  Rectangles := TGMRectangles.Create(nil);
  Bounds := TGMLatLngBounds.Create;
  try
    Bounds.North := 41.40;
    Bounds.South := 41.37;
    Bounds.East := 2.18;
    Bounds.West := 2.15;

    Rectangle := Rectangles.Add;
    Rectangle.Options.Bounds.Assign(Bounds);

    Literal := Rectangle.Options.ToJavaScriptLiteral;

    Assert.IsTrue(Pos('bounds:', Literal) > 0, 'Rectangle literal must serialize bounds.');
    Assert.IsTrue(Pos('visible:', Literal) > 0, 'Rectangle literal must serialize visibility.');
  finally
    Bounds.Free;
    Rectangles.Free;
  end;
end;

procedure TTestRectangleModel.Rectangle_ProcessMapMessage_BoundsChanged_UpdatesBoundsAndFiresEvent;
var
  Envelope: TGMMessageEnvelope;
  Rectangle: TGMRectangleItem;
  Rectangles: TGMRectangles;
begin
  FBoundsChangedCount := 0;

  Rectangles := TGMRectangles.Create(nil);
  try
    Rectangle := Rectangles.Add;
    Rectangle.OnBoundsChanged := HandleRectangleBoundsChanged;

    Envelope.MessageType := 'rectangle.bounds_changed';
    Envelope.Payload := '{"north":41.40,"south":41.37,"east":2.18,"west":2.15}';

    Rectangle.ProcessMapMessage(Envelope);

    Assert.AreEqual(1, FBoundsChangedCount, 'Rectangle bounds_changed must reach the Delphi event.');
    Assert.IsTrue(Rectangle.Options.Bounds.IsComplete);
    Assert.AreEqual(41.40, Rectangle.Options.Bounds.North, 0.000001);
    Assert.AreEqual(2.15, Rectangle.Options.Bounds.West, 0.000001);
  finally
    Rectangles.Free;
  end;
end;

procedure TTestRectangleModel.Rectangle_ProcessMapMessage_InvalidClickPayload_DoesNotFireClickEvent;
var
  Envelope: TGMMessageEnvelope;
  Rectangle: TGMRectangleItem;
  Rectangles: TGMRectangles;
begin
  FClickCount := 0;

  Rectangles := TGMRectangles.Create(nil);
  try
    Rectangle := Rectangles.Add;
    Rectangle.OnClick := HandleRectangleClick;

    Envelope.MessageType := 'rectangle.click';
    Envelope.Payload := '{"lat":"oops","lng":2.15}';

    Rectangle.ProcessMapMessage(Envelope);

    Assert.AreEqual(0, FClickCount, 'Invalid click payload must not fire the rectangle click event.');
  finally
    Rectangles.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRectangleModel);

end.

