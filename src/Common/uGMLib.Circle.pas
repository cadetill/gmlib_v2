{**
  @abstract(Modelo de círculos del mapa.)
 }
unit uGMLib.Circle;

 {$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, Generics.Collections, fpjson, jsonparser, Math, SysUtils,
{$ELSE}
  System.Classes, System.Generics.Collections, System.JSON, System.Math,
  System.SysUtils,
{$ENDIF}
  uGMLib.Core.ApiObject, uGMLib.Core.Messages,
  uGMLib.Core.Types, uGMLib.MapOptions, uGMLib.Platform.Format;

type
  TGMCircleOptions = class;

  TGMCircleItem = class;

  TGMCircles = class;

  TGMCircleStrokePosition = (spCenter, spInside, spOutside);

  TGMCircleCenterChangedEvent = procedure(Sender: TObject) of object;

  TGMCircleCoordinateEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng) of object;

  TGMCircleRadiusChangedEvent = procedure(Sender: TObject) of object;

  TGMCircleItemClass = class of TGMCircleItem;

  TGMCircleOptions = class(TGMLibApiObject)
  private
    FCenter: TGMLibLatLng;
    FRadius: Double;
    FClickable: Boolean;
    FDraggable: Boolean;
    FEditable: Boolean;
    FFillColor: string;
    FFillOpacity: Double;
    FStrokeColor: string;
    FStrokeOpacity: Double;
    FStrokePosition: TGMCircleStrokePosition;
    FStrokeWeight: Integer;
    FVisible: Boolean;
    FZIndex: Integer;
    procedure CenterChanged(Sender: TObject);
    procedure SetCenter(const Value: TGMLibLatLng);
    procedure SetRadius(const Value: Double);
    procedure SetClickable(const Value: Boolean);
    procedure SetDraggable(const Value: Boolean);
    procedure SetEditable(const Value: Boolean);
    procedure SetFillColor(const Value: string);
    procedure SetFillOpacity(const Value: Double);
    procedure SetStrokeColor(const Value: string);
    procedure SetStrokeOpacity(const Value: Double);
    procedure SetStrokePosition(const Value: TGMCircleStrokePosition);
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
  published
    property APIUrl;
    property Center: TGMLibLatLng read FCenter write SetCenter;
    property Radius: Double read FRadius write SetRadius;
    property Clickable: Boolean read FClickable write SetClickable default True;
    property Draggable: Boolean read FDraggable write SetDraggable default False;
    property Editable: Boolean read FEditable write SetEditable default False;
    property FillColor: string read FFillColor write SetFillColor;
    property FillOpacity: Double read FFillOpacity write SetFillOpacity;
    property StrokeColor: string read FStrokeColor write SetStrokeColor;
    property StrokeOpacity: Double read FStrokeOpacity write SetStrokeOpacity;
    property StrokePosition: TGMCircleStrokePosition read FStrokePosition write SetStrokePosition default spOutside;
    property StrokeWeight: Integer read FStrokeWeight write SetStrokeWeight default 2;
    property Visible: Boolean read FVisible write SetVisible default True;
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
  end;

  TGMCircleItem = class(TCollectionItem)
  private
    class var
      FNextObjectId: Integer;
  private
    FObjectId: TGMObjectId;
    FOnCenterChanged: TGMCircleCenterChangedEvent;
    FOnClick: TGMCircleCoordinateEvent;
    FOnContextMenu: TGMCircleCoordinateEvent;
    FOnDblClick: TGMCircleCoordinateEvent;
    FOnDrag: TNotifyEvent;
    FOnDragEnd: TNotifyEvent;
    FOnDragStart: TNotifyEvent;
    FOnMouseDown: TGMCircleCoordinateEvent;
    FOnMouseMove: TGMCircleCoordinateEvent;
    FOnMouseOut: TGMCircleCoordinateEvent;
    FOnMouseOver: TGMCircleCoordinateEvent;
    FOnMouseUp: TGMCircleCoordinateEvent;
    FOnRadiusChanged: TGMCircleRadiusChangedEvent;
    FOptions: TGMCircleOptions;
    FUpdatingFromMapMessage: Boolean;
    procedure ApplyCenter(const ACenter: TJSONObject);
    procedure ApplyRadius(const ARadius: Double);
    procedure OptionsChanged(Sender: TObject);
    procedure SetOptions(const Value: TGMCircleOptions);
    function TryGetCoordinateFromPayload(const APayload: string; out ALatLng: TGMLibLatLng): Boolean;
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreateCircleOptions: TGMCircleOptions; virtual;
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
    procedure ProcessMapMessage(const AEnvelope: TGMMessageEnvelope); virtual;
    property Options: TGMCircleOptions read FOptions write SetOptions;
  published
    property OnCenterChanged: TGMCircleCenterChangedEvent read FOnCenterChanged write FOnCenterChanged;
    property OnClick: TGMCircleCoordinateEvent read FOnClick write FOnClick;
    property OnContextMenu: TGMCircleCoordinateEvent read FOnContextMenu write FOnContextMenu;
    property OnDblClick: TGMCircleCoordinateEvent read FOnDblClick write FOnDblClick;
    property OnDrag: TNotifyEvent read FOnDrag write FOnDrag;
    property OnDragEnd: TNotifyEvent read FOnDragEnd write FOnDragEnd;
    property OnDragStart: TNotifyEvent read FOnDragStart write FOnDragStart;
    property OnMouseDown: TGMCircleCoordinateEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TGMCircleCoordinateEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseOut: TGMCircleCoordinateEvent read FOnMouseOut write FOnMouseOut;
    property OnMouseOver: TGMCircleCoordinateEvent read FOnMouseOver write FOnMouseOver;
    property OnMouseUp: TGMCircleCoordinateEvent read FOnMouseUp write FOnMouseUp;
    property OnRadiusChanged: TGMCircleRadiusChangedEvent read FOnRadiusChanged write FOnRadiusChanged;
  end;

  TGMCircles = class(TOwnedCollection)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
{$IFDEF FPC}
    FPendingRemovals: specialize TList<TGMObjectId>;
{$ELSE}
    FPendingRemovals: TList<TGMObjectId>;
{$ENDIF}
    function GetItem(Index: Integer): TGMCircleItem;
    function GetViewportHost: IGMMapViewportHost;
    procedure SetItem(Index: Integer; const Value: TGMCircleItem);
  public
    constructor Create(AOwner: TPersistent; AItemClass: TGMCircleItemClass = nil);
    destructor Destroy; override;
    function Add: TGMCircleItem;
    function FindByObjectId(const AObjectId: TGMObjectId): TGMCircleItem;
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
    property Items[Index: Integer]: TGMCircleItem read GetItem write SetItem; default;
  end;

function CircleSetOptionsCommand(const AObjectId: TGMObjectId; const AOptions: string): string;

implementation

function CircleSetOptionsCommand(const AObjectId: TGMObjectId; const AOptions: string): string;
begin
  Result := Format('gmlib.circle.setOptions("%s", %s);', [AObjectId, AOptions]);
end;

 { TGMCircleOptions }

procedure TGMCircleOptions.Assign(Source: TPersistent);
begin
  if Source is TGMCircleOptions then
  begin
    Center.Assign(TGMCircleOptions(Source).Center);
    Radius := TGMCircleOptions(Source).Radius;
    Clickable := TGMCircleOptions(Source).Clickable;
    Draggable := TGMCircleOptions(Source).Draggable;
    Editable := TGMCircleOptions(Source).Editable;
    FillColor := TGMCircleOptions(Source).FillColor;
    FillOpacity := TGMCircleOptions(Source).FillOpacity;
    StrokeColor := TGMCircleOptions(Source).StrokeColor;
    StrokeOpacity := TGMCircleOptions(Source).StrokeOpacity;
    StrokePosition := TGMCircleOptions(Source).StrokePosition;
    StrokeWeight := TGMCircleOptions(Source).StrokeWeight;
    Visible := TGMCircleOptions(Source).Visible;
    ZIndex := TGMCircleOptions(Source).ZIndex;
  end
  else
    inherited;
end;

procedure TGMCircleOptions.CenterChanged(Sender: TObject);
begin
  Changed;
end;

constructor TGMCircleOptions.Create;
begin
  inherited;
  FCenter := TGMLibLatLng.Create(0, 0);
{$IFDEF FPC}
  FCenter.OnChange := @CenterChanged;
{$ELSE}
  FCenter.OnChange := CenterChanged;
{$ENDIF}
  FRadius := 1000;
  FClickable := True;
  FDraggable := False;
  FEditable := False;
  FFillColor := '#FF0000';
  FFillOpacity := 0.35;
  FStrokeColor := '#FF0000';
  FStrokeOpacity := 1.0;
  FStrokePosition := spOutside;
  FStrokeWeight := 2;
  FVisible := True;
  FZIndex := 0;
end;

destructor TGMCircleOptions.Destroy;
begin
  FCenter.Free;
  inherited;
end;

function TGMCircleOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#CircleOptions';
end;

procedure TGMCircleOptions.SetCenter(const Value: TGMLibLatLng);
begin
  FCenter.Assign(Value);
end;

procedure TGMCircleOptions.SetRadius(const Value: Double);
begin
  if not SameValue(FRadius, Value) then
  begin
    FRadius := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetClickable(const Value: Boolean);
begin
  if FClickable <> Value then
  begin
    FClickable := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetDraggable(const Value: Boolean);
begin
  if FDraggable <> Value then
  begin
    FDraggable := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetEditable(const Value: Boolean);
begin
  if FEditable <> Value then
  begin
    FEditable := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetFillColor(const Value: string);
begin
  if FFillColor <> Value then
  begin
    FFillColor := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetFillOpacity(const Value: Double);
begin
  if not SameValue(FFillOpacity, Value) then
  begin
    FFillOpacity := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetStrokeColor(const Value: string);
begin
  if FStrokeColor <> Value then
  begin
    FStrokeColor := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetStrokeOpacity(const Value: Double);
begin
  if not SameValue(FStrokeOpacity, Value) then
  begin
    FStrokeOpacity := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetStrokePosition(const Value: TGMCircleStrokePosition);
begin
  if FStrokePosition <> Value then
  begin
    FStrokePosition := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetStrokeWeight(const Value: Integer);
begin
  if FStrokeWeight <> Value then
  begin
    FStrokeWeight := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

procedure TGMCircleOptions.SetZIndex(const Value: Integer);
begin
  if FZIndex <> Value then
  begin
    FZIndex := Value;
    Changed;
  end;
end;

function TGMCircleOptions.ToJavaScriptLiteral: string;
begin
  Result := Format('{center: %s, radius: %s, clickable: %s, draggable: %s, editable: %s, fillColor: "%s", fillOpacity: %s, strokeColor: "%s", strokeOpacity: %s, strokeWeight: %d, visible: %s, zIndex: %d}', [Center.ToJavaScriptLiteral, FloatToStr(Radius, GMLibInvariantFormatSettings), LowerCase(BoolToStr(Clickable, True)), LowerCase(BoolToStr(Draggable, True)), LowerCase(BoolToStr(Editable, True)), FillColor, FloatToStr(FillOpacity, GMLibInvariantFormatSettings), StrokeColor, FloatToStr(StrokeOpacity, GMLibInvariantFormatSettings), StrokeWeight, LowerCase(BoolToStr(Visible, True)), ZIndex]);
end;

 { TGMCircleItem }

procedure TGMCircleItem.ApplyCenter(const ACenter: TJSONObject);
var
  Lat: Double;
  Lng: Double;
begin
  if not Assigned(ACenter) then
    Exit;

{$IFDEF FPC}
  if not Assigned(ACenter.Find('lat')) then
    Exit;
  if not Assigned(ACenter.Find('lng')) then
    Exit;
  Lat := ACenter.Find('lat').AsFloat;
  Lng := ACenter.Find('lng').AsFloat;
{$ELSE}
  if not ACenter.TryGetValue<Double>('lat', Lat) then
    Exit;
  if not ACenter.TryGetValue<Double>('lng', Lng) then
    Exit;
{$ENDIF}

  FUpdatingFromMapMessage := True;
  try
    { Center changes are applied as a single update so the map-side drag/move
      events do not bounce back into Delphi one coordinate at a time. }
    Options.Center.Lat := Lat;
    Options.Center.Lng := Lng;
  finally
    FUpdatingFromMapMessage := False;
  end;
end;

procedure TGMCircleItem.ApplyRadius(const ARadius: Double);
begin
  if ARadius <= 0 then
    Exit;

  FUpdatingFromMapMessage := True;
  try
    Options.Radius := ARadius;
  finally
    FUpdatingFromMapMessage := False;
  end;
end;

procedure TGMCircleItem.Assign(Source: TPersistent);
begin
  if Source is TGMCircleItem then
  begin
    Options.Assign(TGMCircleItem(Source).Options);
    OnClick := TGMCircleItem(Source).OnClick;
    OnCenterChanged := TGMCircleItem(Source).OnCenterChanged;
    OnRadiusChanged := TGMCircleItem(Source).OnRadiusChanged;
  end
  else
    inherited;
end;

function TGMCircleItem.BuildApplyCommand: string;
begin
  if not Assigned(FOptions) then
    Exit('');

  { (0,0) es una coordenada valida, no una señal de borrado. Solo removemos el
    overlay cuando la propiedad Visible lo indica de forma explicita. }
  if not Options.Visible then
    Exit(BuildRemoveCommand);

  Result := CircleSetOptionsCommand(ObjectId, Options.ToJavaScriptLiteral);
end;

function TGMCircleItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('circle_%d', [FNextObjectId]));
end;

function TGMCircleItem.BuildRemoveCommand: string;
begin
  Result := Format('gmlib.circle.remove("%s");', [ObjectId]);
end;

constructor TGMCircleItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FObjectId := BuildObjectId;
  FOptions := CreateCircleOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
end;

function TGMCircleItem.CreateCircleOptions: TGMCircleOptions;
begin
  Result := TGMCircleOptions.Create;
end;

destructor TGMCircleItem.Destroy;
begin
  FOptions.Free;
  if Assigned(Collection) and (Collection is TGMCircles) then
    TGMCircles(Collection).RegisterRemoval(ObjectId);
  inherited;
end;

function TGMCircleItem.GetAPIUrl: string;
begin
  Result := Options.APIUrl;
end;

{$IFNDEF FPC}
function TGMCircleItem.GetDisplayName: string;
begin
  Result := Format('Circle %d', [Index]);
end;
{$ENDIF}

procedure TGMCircleItem.OptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  Changed(False);
end;

procedure TGMCircleItem.ProcessMapMessage(const AEnvelope: TGMMessageEnvelope);
var
  LatLng: TGMLibLatLng;
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
  CenterObj: TJSONObject;
  RadiusValue: Double;
begin
  if SameText(AEnvelope.MessageType, 'circle.click') then
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

  if SameText(AEnvelope.MessageType, 'circle.center_changed') then
  begin
{$IFDEF FPC}
    JsonValue := GetJSON(AEnvelope.Payload);
{$ELSE}
    JsonValue := TJSONObject.ParseJSONValue(AEnvelope.Payload);
{$ENDIF}
    try
      if JsonValue is TJSONObject then
      begin
        CenterObj := TJSONObject(JsonValue);
        ApplyCenter(CenterObj);
        if Assigned(FOnCenterChanged) then
          FOnCenterChanged(Self);
      end;
    finally
      JsonValue.Free;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.radius_changed') then
  begin
    if TryStrToFloat(AEnvelope.Payload, RadiusValue, GMLibInvariantFormatSettings) then
    begin
      ApplyRadius(RadiusValue);
      if Assigned(FOnRadiusChanged) then
        FOnRadiusChanged(Self);
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.dragstart') then
  begin
    if Assigned(FOnDragStart) then
      FOnDragStart(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.drag') then
  begin
    if Assigned(FOnDrag) then
      FOnDrag(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.dragend') then
  begin
    if Assigned(FOnDragEnd) then
      FOnDragEnd(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.contextmenu') then
  begin
    if not Assigned(FOnContextMenu) then
      Exit;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnContextMenu(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.dblclick') then
  begin
    if not Assigned(FOnDblClick) then
      Exit;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnDblClick(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.mousedown') then
  begin
    if not Assigned(FOnMouseDown) then
      Exit;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnMouseDown(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.mousemove') then
  begin
    if not Assigned(FOnMouseMove) then
      Exit;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnMouseMove(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.mouseout') then
  begin
    if not Assigned(FOnMouseOut) then
      Exit;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnMouseOut(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.mouseover') then
  begin
    if not Assigned(FOnMouseOver) then
      Exit;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnMouseOver(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'circle.mouseup') then
  begin
    if not Assigned(FOnMouseUp) then
      Exit;
    if TryGetCoordinateFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        FOnMouseUp(Self, LatLng);
      finally
        LatLng.Free;
      end;
    end;
  end;
end;

procedure TGMCircleItem.SetOptions(const Value: TGMCircleOptions);
begin
  FOptions.Assign(Value);
end;

function TGMCircleItem.TryGetCoordinateFromPayload(const APayload: string; out ALatLng: TGMLibLatLng): Boolean;
var
  JsonObj: TJSONObject;
  LatVal, LngVal: Double;
begin
  Result := False;
  if APayload = '' then
    Exit;

{$IFDEF FPC}
  JsonObj := GetJSON(APayload) as TJSONObject;
{$ELSE}
  JsonObj := TJSONObject.ParseJSONValue(APayload) as TJSONObject;
{$ENDIF}
  if not Assigned(JsonObj) then
    Exit;

  try
{$IFDEF FPC}
    if Assigned(JsonObj.Find('lat')) and Assigned(JsonObj.Find('lng')) then
    begin
      LatVal := JsonObj.Find('lat').AsFloat;
      LngVal := JsonObj.Find('lng').AsFloat;
      ALatLng := TGMLibLatLng.Create(LatVal, LngVal);
      Result := True;
    end;
{$ELSE}
    if JsonObj.TryGetValue<double>('lat', LatVal) and JsonObj.TryGetValue<double>('lng', LngVal) then
    begin
      ALatLng := TGMLibLatLng.Create(LatVal, LngVal);
      Result := True;
    end;
{$ENDIF}
  finally
    JsonObj.Free;
  end;
end;

 { TGMCircles }

function TGMCircles.Add: TGMCircleItem;
begin
  Result := TGMCircleItem(inherited Add);
end;

constructor TGMCircles.Create(AOwner: TPersistent; AItemClass: TGMCircleItemClass);
begin
  if AItemClass = nil then
    AItemClass := TGMCircleItem;

  inherited Create(AOwner, AItemClass);
  FOwner := AOwner;
{$IFDEF FPC}
  FPendingRemovals := specialize TList<TGMObjectId>.Create;
{$ELSE}
  FPendingRemovals := TList<TGMObjectId>.Create;
{$ENDIF}
end;

destructor TGMCircles.Destroy;
begin
  inherited;
  FPendingRemovals.Free;
end;

function TGMCircles.FindByObjectId(const AObjectId: TGMObjectId): TGMCircleItem;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].ObjectId = AObjectId then
      Exit(Items[i]);
  Result := nil;
end;

function TGMCircles.GetViewportHost: IGMMapViewportHost;
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

procedure TGMCircles.ClearPendingRemovals;
begin
  FPendingRemovals.Clear;
end;

function TGMCircles.GetItem(Index: Integer): TGMCircleItem;
begin
  Result := TGMCircleItem(inherited GetItem(Index));
end;

procedure TGMCircles.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMCircles.RegisterRemoval(const AObjectId: TGMObjectId);
begin
  if AObjectId = '' then
    Exit;

  if not FPendingRemovals.Contains(AObjectId) then
    FPendingRemovals.Add(AObjectId);
end;

procedure TGMCircles.SetItem(Index: Integer; const Value: TGMCircleItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TGMCircles.Update(Item: TCollectionItem);
begin
  inherited;
  NotifyChange;
end;

function TGMCircles.TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
  AVisibleOnly: Boolean; AItemIndex: Integer): Boolean;
const
  EarthRadiusMeters = 6378137.0;
var
  Circle: TGMCircleItem;
  Center: TGMLibLatLng;
  EastDelta: Double;
  i: Integer;
  LatDelta: Double;
  RadiusMeters: Double;
begin
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;

  if (AItemIndex >= 0) and (AItemIndex < Count) then
  begin
    Circle := Items[AItemIndex];
    if (not AVisibleOnly) or Circle.Options.Visible then
    begin
      Center := Circle.Options.Center;
      RadiusMeters := Max(0, Circle.Options.Radius);
      { Circle bounds are approximated from center + radius so they can be
        used for FitBounds without introducing a heavier geometry path. }
      LatDelta := (RadiusMeters / EarthRadiusMeters) * (180 / Pi);
      if Abs(Cos(DegToRad(Center.Lat))) < 1E-12 then
        EastDelta := 180
      else
        EastDelta := (RadiusMeters / (EarthRadiusMeters * Cos(DegToRad(Center.Lat)))) * (180 / Pi);

      ANorth := Center.Lat + LatDelta;
      ASouth := Center.Lat - LatDelta;
      AEast := Center.Lng + EastDelta;
      AWest := Center.Lng - EastDelta;
      Exit(True);
    end;
    Exit(False);
  end;

  for i := 0 to Count - 1 do
  begin
    Circle := Items[i];
    if AVisibleOnly and not Circle.Options.Visible then
      Continue;

    Center := Circle.Options.Center;
    RadiusMeters := Max(0, Circle.Options.Radius);
    LatDelta := (RadiusMeters / EarthRadiusMeters) * (180 / Pi);
    if Abs(Cos(DegToRad(Center.Lat))) < 1E-12 then
      EastDelta := 180
    else
      EastDelta := (RadiusMeters / (EarthRadiusMeters * Cos(DegToRad(Center.Lat)))) * (180 / Pi);

    if not Result then
    begin
      ANorth := Center.Lat + LatDelta;
      ASouth := Center.Lat - LatDelta;
      AEast := Center.Lng + EastDelta;
      AWest := Center.Lng - EastDelta;
      Result := True;
      Continue;
    end;

    ANorth := Max(ANorth, Center.Lat + LatDelta);
    ASouth := Min(ASouth, Center.Lat - LatDelta);
    AEast := Max(AEast, Center.Lng + EastDelta);
    AWest := Min(AWest, Center.Lng - EastDelta);
  end;
end;

procedure TGMCircles.ZoomToPoints(AVisibleOnly: Boolean; AItemIndex: Integer);
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
