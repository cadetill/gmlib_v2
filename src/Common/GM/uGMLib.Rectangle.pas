{**
  @abstract(Modelo de rectángulos del mapa.)
}
unit uGMLib.Rectangle;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  Generics.Collections,
  fpjson,
  jsonparser,
  Math,
  SysUtils,
{$ELSE}
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  System.Math,
  System.SysUtils,
{$ENDIF}
  uMapLib.Core.ApiObject,
  uMapLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.MapOptions,
  uGMLib.Platform.Format;

type
  TGMRectangleOptions = class;
  TGMRectangleItem = class;
  TGMRectangles = class;

  TGMRectangleCoordinateEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng) of object;
  TGMRectangleBoundsChangedEvent = procedure(Sender: TObject) of object;
  TGMRectangleItemClass = class of TGMRectangleItem;

  TGMRectangleOptions = class(TMapLibApiObject)
  private
    FBounds: TGMLatLngBounds;
    FClickable: Boolean;
    FDraggable: Boolean;
    FEditable: Boolean;
    FFillColor: string;
    FFillOpacity: Double;
    FStrokeColor: string;
    FStrokeOpacity: Double;
    FStrokeWeight: Integer;
    FVisible: Boolean;
    FZIndex: Integer;
    procedure BoundsChanged(Sender: TObject);
    procedure SetBounds(const Value: TGMLatLngBounds);
    procedure SetClickable(const Value: Boolean);
    procedure SetDraggable(const Value: Boolean);
    procedure SetEditable(const Value: Boolean);
    procedure SetFillColor(const Value: string);
    procedure SetFillOpacity(const Value: Double);
    procedure SetStrokeColor(const Value: string);
    procedure SetStrokeOpacity(const Value: Double);
    procedure SetStrokeWeight(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetZIndex(const Value: Integer);
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function ToJavaScriptLiteral: string;
    property Bounds: TGMLatLngBounds read FBounds write SetBounds;
  published
    property APIUrl;
    property Clickable: Boolean read FClickable write SetClickable default True;
    property Draggable: Boolean read FDraggable write SetDraggable default False;
    property Editable: Boolean read FEditable write SetEditable default False;
    property FillColor: string read FFillColor write SetFillColor;
    property FillOpacity: Double read FFillOpacity write SetFillOpacity;
    property StrokeColor: string read FStrokeColor write SetStrokeColor;
    property StrokeOpacity: Double read FStrokeOpacity write SetStrokeOpacity;
    property StrokeWeight: Integer read FStrokeWeight write SetStrokeWeight default 2;
    property Visible: Boolean read FVisible write SetVisible default True;
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
  end;

  TGMRectangleItem = class(TCollectionItem)
  private
    class var FNextObjectId: Integer;
  private
    FObjectId: TGMObjectId;
    FOnBoundsChanged: TGMRectangleBoundsChangedEvent;
    FOnClick: TGMRectangleCoordinateEvent;
    FOnContextMenu: TGMRectangleCoordinateEvent;
    FOnDblClick: TGMRectangleCoordinateEvent;
    FOnDrag: TNotifyEvent;
    FOnDragEnd: TNotifyEvent;
    FOnDragStart: TNotifyEvent;
    FOnMouseDown: TGMRectangleCoordinateEvent;
    FOnMouseMove: TGMRectangleCoordinateEvent;
    FOnMouseOut: TGMRectangleCoordinateEvent;
    FOnMouseOver: TGMRectangleCoordinateEvent;
    FOnMouseUp: TGMRectangleCoordinateEvent;
    FOptions: TGMRectangleOptions;
    FUpdatingFromMapMessage: Boolean;
    procedure ApplyBounds(const ABounds: TJSONObject);
    procedure OptionsChanged(Sender: TObject);
    procedure SetOptions(const Value: TGMRectangleOptions);
    function TryGetCoordinateFromPayload(const APayload: string;
      out ALatLng: TGMLibLatLng): Boolean;
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreateRectangleOptions: TGMRectangleOptions; virtual;
{$IFNDEF FPC}
    function GetDisplayName: string; override;
{$ENDIF}
    property ObjectId: TGMObjectId read FObjectId;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function BuildApplyCommand: string;
    function BuildRemoveCommand: string;
    function GetAPIUrl: string;
    procedure ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope); virtual;
    property Options: TGMRectangleOptions read FOptions write SetOptions;
  published
    property OnBoundsChanged: TGMRectangleBoundsChangedEvent read FOnBoundsChanged write FOnBoundsChanged;
    property OnClick: TGMRectangleCoordinateEvent read FOnClick write FOnClick;
    property OnContextMenu: TGMRectangleCoordinateEvent read FOnContextMenu write FOnContextMenu;
    property OnDblClick: TGMRectangleCoordinateEvent read FOnDblClick write FOnDblClick;
    property OnDrag: TNotifyEvent read FOnDrag write FOnDrag;
    property OnDragEnd: TNotifyEvent read FOnDragEnd write FOnDragEnd;
    property OnDragStart: TNotifyEvent read FOnDragStart write FOnDragStart;
    property OnMouseDown: TGMRectangleCoordinateEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TGMRectangleCoordinateEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseOut: TGMRectangleCoordinateEvent read FOnMouseOut write FOnMouseOut;
    property OnMouseOver: TGMRectangleCoordinateEvent read FOnMouseOver write FOnMouseOver;
    property OnMouseUp: TGMRectangleCoordinateEvent read FOnMouseUp write FOnMouseUp;
  end;

  TGMRectangles = class(TOwnedCollection)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
{$IFDEF FPC}
    FPendingRemovals: specialize TList<TGMObjectId>;
{$ELSE}
    FPendingRemovals: TList<TGMObjectId>;
{$ENDIF}
    function GetItem(Index: Integer): TGMRectangleItem;
    function GetViewportHost: IGMMapViewportHost;
    procedure SetItem(Index: Integer; const Value: TGMRectangleItem);
  public
    constructor Create(AOwner: TPersistent; AItemClass: TGMRectangleItemClass = nil);
    destructor Destroy; override;
    function Add: TGMRectangleItem;
    function FindByObjectId(const AObjectId: TGMObjectId): TGMRectangleItem;
    function TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
      AVisibleOnly: Boolean = True; AItemIndex: Integer = -1): Boolean;
    procedure ClearPendingRemovals;
    procedure RegisterRemoval(const AObjectId: TGMObjectId);
    procedure NotifyChange;
    procedure Update(Item: TCollectionItem); override;
    procedure ZoomToPoints(AVisibleOnly: Boolean = True; AItemIndex: Integer = -1);
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
{$IFDEF FPC}
    property PendingRemovals: specialize TList<TGMObjectId> read FPendingRemovals;
{$ELSE}
    property PendingRemovals: TList<TGMObjectId> read FPendingRemovals;
{$ENDIF}
    property Items[Index: Integer]: TGMRectangleItem read GetItem write SetItem; default;
  end;

function RectangleSetOptionsCommand(const AObjectId: TGMObjectId;
  const AOptions: string): string;

implementation

function RectangleSetOptionsCommand(const AObjectId: TGMObjectId;
  const AOptions: string): string;
begin
  Result := Format('gmlib.rectangle.setOptions("%s", %s);', [AObjectId, AOptions]);
end;

{ TGMRectangleOptions }

procedure TGMRectangleOptions.Assign(Source: TPersistent);
begin
  if Source is TGMRectangleOptions then
  begin
    Bounds.Assign(TGMRectangleOptions(Source).Bounds);
    Clickable := TGMRectangleOptions(Source).Clickable;
    Draggable := TGMRectangleOptions(Source).Draggable;
    Editable := TGMRectangleOptions(Source).Editable;
    FillColor := TGMRectangleOptions(Source).FillColor;
    FillOpacity := TGMRectangleOptions(Source).FillOpacity;
    StrokeColor := TGMRectangleOptions(Source).StrokeColor;
    StrokeOpacity := TGMRectangleOptions(Source).StrokeOpacity;
    StrokeWeight := TGMRectangleOptions(Source).StrokeWeight;
    Visible := TGMRectangleOptions(Source).Visible;
    ZIndex := TGMRectangleOptions(Source).ZIndex;
  end
  else
    inherited;
end;

procedure TGMRectangleOptions.BoundsChanged(Sender: TObject);
begin
  Changed;
end;

constructor TGMRectangleOptions.Create;
begin
  inherited;
  FBounds := TGMLatLngBounds.Create;
{$IFDEF FPC}
  FBounds.OnChange := @BoundsChanged;
{$ELSE}
  FBounds.OnChange := BoundsChanged;
{$ENDIF}
  FClickable := True;
  FDraggable := False;
  FEditable := False;
  FFillColor := '#FF0000';
  FFillOpacity := 0.35;
  FStrokeColor := '#FF0000';
  FStrokeOpacity := 1.0;
  FStrokeWeight := 2;
  FVisible := True;
  FZIndex := 0;
end;

destructor TGMRectangleOptions.Destroy;
begin
  FBounds.Free;
  inherited;
end;

function TGMRectangleOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#RectangleOptions';
end;

procedure TGMRectangleOptions.SetBounds(const Value: TGMLatLngBounds);
begin
  FBounds.BeginUpdate;
  try
    FBounds.Assign(Value);
  finally
    FBounds.EndUpdate;
  end;
end;

procedure TGMRectangleOptions.SetClickable(const Value: Boolean);
begin
  if FClickable <> Value then
  begin
    FClickable := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetDraggable(const Value: Boolean);
begin
  if FDraggable <> Value then
  begin
    FDraggable := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetEditable(const Value: Boolean);
begin
  if FEditable <> Value then
  begin
    FEditable := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetFillColor(const Value: string);
begin
  if FFillColor <> Value then
  begin
    FFillColor := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetFillOpacity(const Value: Double);
begin
  if not SameValue(FFillOpacity, Value) then
  begin
    FFillOpacity := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetStrokeColor(const Value: string);
begin
  if FStrokeColor <> Value then
  begin
    FStrokeColor := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetStrokeOpacity(const Value: Double);
begin
  if not SameValue(FStrokeOpacity, Value) then
  begin
    FStrokeOpacity := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetStrokeWeight(const Value: Integer);
begin
  if FStrokeWeight <> Value then
  begin
    FStrokeWeight := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

procedure TGMRectangleOptions.SetZIndex(const Value: Integer);
begin
  if FZIndex <> Value then
  begin
    FZIndex := Value;
    Changed;
  end;
end;

function TGMRectangleOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{bounds: %s, clickable: %s, draggable: %s, editable: %s, fillColor: "%s", fillOpacity: %s, strokeColor: "%s", strokeOpacity: %s, strokeWeight: %d, visible: %s, zIndex: %d}',
    [
      Bounds.ToJavaScriptLiteral,
      LowerCase(BoolToStr(Clickable, True)),
      LowerCase(BoolToStr(Draggable, True)),
      LowerCase(BoolToStr(Editable, True)),
      FillColor,
      FloatToStr(FillOpacity, GMLibInvariantFormatSettings),
      StrokeColor,
      FloatToStr(StrokeOpacity, GMLibInvariantFormatSettings),
      StrokeWeight,
      LowerCase(BoolToStr(Visible, True)),
      ZIndex
    ]
  );
end;

{ TGMRectangleItem }

procedure TGMRectangleItem.ApplyBounds(const ABounds: TJSONObject);
var
  North: Double;
  South: Double;
  East: Double;
  West: Double;
begin
  if not Assigned(ABounds) then
    Exit;

{$IFDEF FPC}
  if not Assigned(ABounds.Find('north')) then
    Exit;
  if not Assigned(ABounds.Find('south')) then
    Exit;
  if not Assigned(ABounds.Find('east')) then
    Exit;
  if not Assigned(ABounds.Find('west')) then
    Exit;
  North := ABounds.Find('north').AsFloat;
  South := ABounds.Find('south').AsFloat;
  East := ABounds.Find('east').AsFloat;
  West := ABounds.Find('west').AsFloat;
{$ELSE}
  if not ABounds.TryGetValue<Double>('north', North) then
    Exit;
  if not ABounds.TryGetValue<Double>('south', South) then
    Exit;
  if not ABounds.TryGetValue<Double>('east', East) then
    Exit;
  if not ABounds.TryGetValue<Double>('west', West) then
    Exit;
{$ENDIF}

  FUpdatingFromMapMessage := True;
  try
    { Bounds updates arrive from the JS side as a single object, so we batch
      the four coordinates to keep the Delphi-side notifications consistent. }
    Options.Bounds.BeginUpdate;
    try
    Options.Bounds.North := North;
    Options.Bounds.South := South;
    Options.Bounds.East := East;
    Options.Bounds.West := West;
    finally
      Options.Bounds.EndUpdate;
    end;
  finally
    FUpdatingFromMapMessage := False;
  end;
end;

procedure TGMRectangleItem.Assign(Source: TPersistent);
begin
  if Source is TGMRectangleItem then
  begin
    Options.Assign(TGMRectangleItem(Source).Options);
    OnClick := TGMRectangleItem(Source).OnClick;
    OnBoundsChanged := TGMRectangleItem(Source).OnBoundsChanged;
  end
  else
    inherited;
end;

function TGMRectangleItem.BuildApplyCommand: string;
begin
  if not Assigned(FOptions) then
    Exit('');

  if not Options.Visible or not Options.Bounds.IsComplete then
    Exit(BuildRemoveCommand);

  Result := RectangleSetOptionsCommand(ObjectId, Options.ToJavaScriptLiteral);
end;

function TGMRectangleItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('rectangle_%d', [FNextObjectId]));
end;

function TGMRectangleItem.BuildRemoveCommand: string;
begin
  Result := Format('gmlib.rectangle.remove("%s");', [ObjectId]);
end;

constructor TGMRectangleItem.Create(ACollection: TCollection);
begin
  inherited;
  FObjectId := BuildObjectId;
  FOptions := CreateRectangleOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
end;

function TGMRectangleItem.CreateRectangleOptions: TGMRectangleOptions;
begin
  Result := TGMRectangleOptions.Create;
end;

destructor TGMRectangleItem.Destroy;
begin
  FOptions.Free;
  if Assigned(Collection) and (Collection is TGMRectangles) then
    TGMRectangles(Collection).RegisterRemoval(ObjectId);
  inherited;
end;

function TGMRectangleItem.GetAPIUrl: string;
begin
  Result := Options.APIUrl;
end;

{$IFNDEF FPC}
function TGMRectangleItem.GetDisplayName: string;
begin
  Result := Format('Rectangle %d', [Index]);
end;
{$ENDIF}

procedure TGMRectangleItem.OptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  Changed(False);
end;

procedure TGMRectangleItem.ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
var
  LatLng: TGMLibLatLng;
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
  BoundsObj: TJSONObject;
begin
  if SameText(AEnvelope.MessageType, 'rectangle.click') then
  begin
    if not Assigned(FOnClick) then
      Exit;

    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnClick(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'rectangle.bounds_changed') then
  begin
{$IFDEF FPC}
    JsonValue := GetJSON(AEnvelope.Payload);
{$ELSE}
    JsonValue := TJSONObject.ParseJSONValue(AEnvelope.Payload);
{$ENDIF}
    try
      if JsonValue is TJSONObject then
      begin
        BoundsObj := TJSONObject(JsonValue);
        ApplyBounds(BoundsObj);
        if Assigned(FOnBoundsChanged) then
          FOnBoundsChanged(Self);
      end;
    finally
      JsonValue.Free;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'rectangle.dragstart') then
  begin
    if Assigned(FOnDragStart) then
      FOnDragStart(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'rectangle.drag') then
  begin
    if Assigned(FOnDrag) then
      FOnDrag(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'rectangle.dragend') then
  begin
    if Assigned(FOnDragEnd) then
      FOnDragEnd(Self);
  end;
end;

procedure TGMRectangleItem.SetOptions(const Value: TGMRectangleOptions);
begin
  FOptions.Assign(Value);
end;

function TGMRectangleItem.TryGetCoordinateFromPayload(const APayload: string;
  out ALatLng: TGMLibLatLng): Boolean;
var
  JsonObj: TJSONObject;
  LatVal, LngVal: Double;
begin
  Result := False;
  if APayload = '' then
    Exit;

{$IFDEF FPC}
  JsonObj := TJSONObject(GetJSON(APayload));
{$ELSE}
  JsonObj := TJSONObject.ParseJSONValue(APayload) as TJSONObject;
{$ENDIF}
  if not Assigned(JsonObj) then
    Exit;

  try
{$IFDEF FPC}
    if not Assigned(JsonObj.Find('lat')) then
      Exit;
    if not Assigned(JsonObj.Find('lng')) then
      Exit;
    LatVal := JsonObj.Find('lat').AsFloat;
    LngVal := JsonObj.Find('lng').AsFloat;
{$ELSE}
    if JsonObj.TryGetValue<Double>('lat', LatVal) and JsonObj.TryGetValue<Double>('lng', LngVal) then
{$ENDIF}
    begin
      ALatLng := TGMLibLatLng.Create(LatVal, LngVal);
      Result := True;
    end;
  finally
    JsonObj.Free;
  end;
end;

{ TGMRectangles }

function TGMRectangles.Add: TGMRectangleItem;
begin
  Result := TGMRectangleItem(inherited Add);
end;

constructor TGMRectangles.Create(AOwner: TPersistent; AItemClass: TGMRectangleItemClass);
begin
  if AItemClass = nil then
    AItemClass := TGMRectangleItem;

  inherited Create(AOwner, AItemClass);
  FOwner := AOwner;
{$IFDEF FPC}
  FPendingRemovals := specialize TList<TGMObjectId>.Create;
{$ELSE}
  FPendingRemovals := TList<TGMObjectId>.Create;
{$ENDIF}
end;

destructor TGMRectangles.Destroy;
begin
  inherited;
  FPendingRemovals.Free;
end;

function TGMRectangles.FindByObjectId(const AObjectId: TGMObjectId): TGMRectangleItem;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].ObjectId = AObjectId then
      Exit(Items[i]);
  Result := nil;
end;

function TGMRectangles.GetViewportHost: IGMMapViewportHost;
var
  OwnerRef: TPersistent;
begin
  Result := nil;
  OwnerRef := GetOwner;
  if not Assigned(OwnerRef) then
    Exit;

  if not Supports(OwnerRef, IGMMapViewportHost, Result) then
    Result := nil;
end;

procedure TGMRectangles.ClearPendingRemovals;
begin
  FPendingRemovals.Clear;
end;

function TGMRectangles.GetItem(Index: Integer): TGMRectangleItem;
begin
  Result := TGMRectangleItem(inherited GetItem(Index));
end;

procedure TGMRectangles.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMRectangles.RegisterRemoval(const AObjectId: TGMObjectId);
begin
  if AObjectId = '' then
    Exit;

  if not FPendingRemovals.Contains(AObjectId) then
    FPendingRemovals.Add(AObjectId);
end;

procedure TGMRectangles.SetItem(Index: Integer; const Value: TGMRectangleItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TGMRectangles.Update(Item: TCollectionItem);
begin
  inherited;
  NotifyChange;
end;

function TGMRectangles.TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
  AVisibleOnly: Boolean; AItemIndex: Integer): Boolean;
var
  i: Integer;
  Rectangle: TGMRectangleItem;
begin
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;

  if (AItemIndex >= 0) and (AItemIndex < Count) then
  begin
    Rectangle := Items[AItemIndex];
    if (not AVisibleOnly) or Rectangle.Options.Visible then
      if Rectangle.Options.Bounds.IsComplete then
      begin
        ANorth := Rectangle.Options.Bounds.North;
        ASouth := Rectangle.Options.Bounds.South;
        AEast := Rectangle.Options.Bounds.East;
        AWest := Rectangle.Options.Bounds.West;
        Exit(True);
      end;
    Exit(False);
  end;

  for i := 0 to Count - 1 do
  begin
    Rectangle := Items[i];
    if AVisibleOnly and not Rectangle.Options.Visible then
      Continue;

    if not Rectangle.Options.Bounds.IsComplete then
      Continue;

    if not Result then
    begin
      { The first valid rectangle seeds the accumulator, then the remaining
        ones only expand the current bounds. }
      ANorth := Rectangle.Options.Bounds.North;
      ASouth := Rectangle.Options.Bounds.South;
      AEast := Rectangle.Options.Bounds.East;
      AWest := Rectangle.Options.Bounds.West;
      Result := True;
      Continue;
    end;

    ANorth := Max(ANorth, Rectangle.Options.Bounds.North);
    ASouth := Min(ASouth, Rectangle.Options.Bounds.South);
    AEast := Max(AEast, Rectangle.Options.Bounds.East);
    AWest := Min(AWest, Rectangle.Options.Bounds.West);
  end;
end;

procedure TGMRectangles.ZoomToPoints(AVisibleOnly: Boolean; AItemIndex: Integer);
var
  East: Double;
  North: Double;
  South: Double;
  ViewportHost: IGMMapViewportHost;
  West: Double;
begin
  if not TryGetBounds(North, South, East, West, AVisibleOnly, AItemIndex) then
    Exit;

  ViewportHost := GetViewportHost;
  if not Assigned(ViewportHost) then
    Exit;

  ViewportHost.FitBounds(North, South, East, West);
end;

end.




