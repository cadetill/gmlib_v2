{**
  @abstract(Modelo de colección de polilíneas del mapa.)
}
unit uGMLib.Polyline;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  fpjson,
  jsonparser,
  Math,
  SysUtils,
  Generics.Collections,
{$ELSE}
  System.Classes,
  System.JSON,
  System.Math,
  System.SysUtils,
  System.Generics.Collections,
{$ENDIF}
  uGMLib.Core.ApiObject,
  uGMLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.CoordinatePoint,
  uGMLib.Platform.Format;

type
  TGMPolylinePoint = class;
  TGMPolylinePath = class;
  TGMPolylineOptions = class;
  TGMPolylineItem = class;
  TGMPolylines = class;

  TGMPolylineCoordinateEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng) of object;
  TGMPolylinePathChangedEvent = procedure(Sender: TObject) of object;
  TGMPolylineItemClass = class of TGMPolylineItem;

  TGMPolylinePoint = class(TGMCoordinatePoint);

  TGMPolylinePath = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TGMPolylinePoint;
    procedure SetItem(Index: Integer; const Value: TGMPolylinePoint);
  protected
    procedure NotifyChange;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMPolylinePoint; overload;
    function Add(ALatitude, ALongitude: Double): TGMPolylinePoint; overload;
    procedure Assign(Source: TPersistent); override;
    function IsEmpty: Boolean;
    function ToJavaScriptLiteral: string;
    property Items[Index: Integer]: TGMPolylinePoint read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TGMPolylineOptions = class(TGMLibApiObject)
  private
    FClickable: Boolean;
    FDraggable: Boolean;
    FEditable: Boolean;
    FGeodesic: Boolean;
    FPath: TGMPolylinePath;
    FStrokeColor: string;
    FStrokeOpacity: Double;
    FStrokeWeight: Integer;
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FVisible: Boolean;
    FZIndex: Integer;
    procedure PathChanged(Sender: TObject);
    procedure SetClickable(const Value: Boolean);
    procedure SetDraggable(const Value: Boolean);
    procedure SetEditable(const Value: Boolean);
    procedure SetGeodesic(const Value: Boolean);
    procedure SetPath(const Value: TGMPolylinePath);
    procedure SetStrokeColor(const Value: string);
    procedure SetStrokeOpacity(const Value: Double);
    procedure SetStrokeWeight(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetZIndex(const Value: Integer);
  protected
    function CreatePath: TGMPolylinePath; virtual;
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure Assign(Source: TPersistent); override;
    procedure Changed; override;
    procedure EndUpdate;
    function ToJavaScriptLiteral: string;
    property StrokeColor: string read FStrokeColor write SetStrokeColor;
  published
    property APIUrl;
    property Clickable: Boolean read FClickable write SetClickable default True;
    property Draggable: Boolean read FDraggable write SetDraggable default False;
    property Editable: Boolean read FEditable write SetEditable default False;
    property Geodesic: Boolean read FGeodesic write SetGeodesic default False;
    property Path: TGMPolylinePath read FPath write SetPath;
    property StrokeOpacity: Double read FStrokeOpacity write SetStrokeOpacity;
    property StrokeWeight: Integer read FStrokeWeight write SetStrokeWeight default 2;
    property Visible: Boolean read FVisible write SetVisible default True;
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
  end;

  TGMPolylineItem = class(TCollectionItem)
  private
    class var FNextObjectId: Integer;
  private
    FObjectId: TGMObjectId;
    FOnClick: TGMPolylineCoordinateEvent;
    FOnContextMenu: TGMPolylineCoordinateEvent;
    FOnDblClick: TGMPolylineCoordinateEvent;
    FOnDrag: TNotifyEvent;
    FOnDragEnd: TNotifyEvent;
    FOnDragStart: TNotifyEvent;
    FOnMouseDown: TGMPolylineCoordinateEvent;
    FOnMouseMove: TGMPolylineCoordinateEvent;
    FOnMouseOut: TGMPolylineCoordinateEvent;
    FOnMouseOver: TGMPolylineCoordinateEvent;
    FOnPathChanged: TGMPolylinePathChangedEvent;
    FOnMouseUp: TGMPolylineCoordinateEvent;
    FOptions: TGMPolylineOptions;
    FUpdatingFromMapMessage: Boolean;
    procedure ApplyPath(const APath: TJSONArray);
    procedure OptionsChanged(Sender: TObject);
    procedure SetOptions(const Value: TGMPolylineOptions);
    function TryGetCoordinateFromPayload(const APayload: string;
      out ALatLng: TGMLibLatLng): Boolean;
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreatePolylineOptions: TGMPolylineOptions; virtual;
    function GetAPIUrl: string; virtual;
{$IFNDEF FPC}
    function GetDisplayName: string; override;
{$ENDIF}
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function BuildApplyCommand: string;
    function BuildRemoveCommand: string;
    procedure ProcessMapMessage(const AEnvelope: TGMMessageEnvelope);
    property ObjectId: TGMObjectId read FObjectId;
  published
    property APIUrl: string read GetAPIUrl;
    property Options: TGMPolylineOptions read FOptions write SetOptions;
    property OnClick: TGMPolylineCoordinateEvent read FOnClick write FOnClick;
    property OnContextMenu: TGMPolylineCoordinateEvent read FOnContextMenu write FOnContextMenu;
    property OnDblClick: TGMPolylineCoordinateEvent read FOnDblClick write FOnDblClick;
    property OnDrag: TNotifyEvent read FOnDrag write FOnDrag;
    property OnDragEnd: TNotifyEvent read FOnDragEnd write FOnDragEnd;
    property OnDragStart: TNotifyEvent read FOnDragStart write FOnDragStart;
    property OnMouseDown: TGMPolylineCoordinateEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TGMPolylineCoordinateEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseOut: TGMPolylineCoordinateEvent read FOnMouseOut write FOnMouseOut;
    property OnMouseOver: TGMPolylineCoordinateEvent read FOnMouseOver write FOnMouseOver;
    property OnPathChanged: TGMPolylinePathChangedEvent read FOnPathChanged write FOnPathChanged;
    property OnMouseUp: TGMPolylineCoordinateEvent read FOnMouseUp write FOnMouseUp;
  end;

  TGMPolylines = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
{$IFDEF FPC}
    FPendingRemovals: specialize TList<TGMObjectId>;
{$ELSE}
    FPendingRemovals: TList<TGMObjectId>;
{$ENDIF}
    function GetItem(Index: Integer): TGMPolylineItem;
    procedure SetItem(Index: Integer; const Value: TGMPolylineItem);
  protected
    function GetAPIUrl: string; virtual;
    function GetViewportHost: IGMMapViewportHost;
    procedure NotifyChange;
    procedure RegisterRemoval(const AObjectId: TGMObjectId);
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TGMPolylineItemClass = nil);
    destructor Destroy; override;
    function Add: TGMPolylineItem;
    procedure Assign(Source: TPersistent); override;
    procedure ClearPendingRemovals;
    function FindByObjectId(const AObjectId: TGMObjectId): TGMPolylineItem;
    function TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
      AVisibleOnly: Boolean = True; AItemIndex: Integer = -1): Boolean;
    procedure ZoomToPoints(AVisibleOnly: Boolean = True; AItemIndex: Integer = -1);
    property APIUrl: string read GetAPIUrl;
    property Items[Index: Integer]: TGMPolylineItem read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
{$IFDEF FPC}
    property PendingRemovals: specialize TList<TGMObjectId> read FPendingRemovals;
{$ELSE}
    property PendingRemovals: TList<TGMObjectId> read FPendingRemovals;
{$ENDIF}
  end;

implementation

function JavaScriptQuotedStr(const AValue: string): string;
begin
  Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '\''', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := '''' + Result + '''';
end;

function PolylineRemoveCommand(const AObjectId: TGMObjectId): string;
begin
  Result := Format('gmlib.polyline.remove(%s);', [QuotedStr(string(AObjectId))]);
end;

function PolylineSetOptionsCommand(const AObjectId: TGMObjectId;
  const AOptionsLiteral: string): string;
begin
  Result := Format('gmlib.polyline.setOptions(%s, %s);', [
    QuotedStr(string(AObjectId)),
    AOptionsLiteral
  ]);
end;

{ TGMPolylinePath }

function TGMPolylinePath.Add: TGMPolylinePoint;
begin
  Result := TGMPolylinePoint(inherited Add);
end;

function TGMPolylinePath.Add(ALatitude, ALongitude: Double): TGMPolylinePoint;
begin
  Result := Add;
  Result.Lat := ALatitude;
  Result.Lng := ALongitude;
end;

procedure TGMPolylinePath.Assign(Source: TPersistent);
var
  i: Integer;
  NewPoint: TGMPolylinePoint;
  SourcePath: TGMPolylinePath;
begin
  if Source is TGMPolylinePath then
  begin
    SourcePath := TGMPolylinePath(Source);
    BeginUpdate;
    try
      Clear;
      for i := 0 to SourcePath.Count - 1 do
      begin
        NewPoint := Add;
        NewPoint.Assign(SourcePath[i]);
      end;
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited;
end;

constructor TGMPolylinePath.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMPolylinePoint);
end;

function TGMPolylinePath.GetItem(Index: Integer): TGMPolylinePoint;
begin
  Result := TGMPolylinePoint(inherited GetItem(Index));
end;

function TGMPolylinePath.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

procedure TGMPolylinePath.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMPolylinePath.SetItem(Index: Integer; const Value: TGMPolylinePoint);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

function TGMPolylinePath.ToJavaScriptLiteral: string;
var
  i: Integer;
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.Append('[');
    for i := 0 to Count - 1 do
    begin
      if i > 0 then
        Builder.Append(', ');
      Builder.Append(Items[i].ToJavaScriptLiteral);
    end;
    Builder.Append(']');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

procedure TGMPolylinePath.Update(Item: TCollectionItem);
begin
  inherited;
  NotifyChange;
end;

{ TGMPolylineOptions }

procedure TGMPolylineOptions.Assign(Source: TPersistent);
begin
  if Source is TGMPolylineOptions then
  begin
    BeginUpdate;
    try
    Clickable := TGMPolylineOptions(Source).Clickable;
    Draggable := TGMPolylineOptions(Source).Draggable;
    Editable := TGMPolylineOptions(Source).Editable;
    Geodesic := TGMPolylineOptions(Source).Geodesic;
    Path.Assign(TGMPolylineOptions(Source).Path);
    StrokeColor := TGMPolylineOptions(Source).StrokeColor;
    StrokeOpacity := TGMPolylineOptions(Source).StrokeOpacity;
    StrokeWeight := TGMPolylineOptions(Source).StrokeWeight;
    Visible := TGMPolylineOptions(Source).Visible;
    ZIndex := TGMPolylineOptions(Source).ZIndex;
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited;
end;

constructor TGMPolylineOptions.Create;
begin
  inherited;
  FClickable := True;
  FDraggable := False;
  FEditable := False;
  FGeodesic := False;
  FPath := CreatePath;
{$IFDEF FPC}
  FPath.OnChange := @PathChanged;
{$ELSE}
  FPath.OnChange := PathChanged;
{$ENDIF}
  FStrokeOpacity := 1.0;
  FStrokeWeight := 2;
  FUpdateCount := 0;
  FUpdatePending := False;
  FVisible := True;
  FZIndex := 0;
end;

function TGMPolylineOptions.CreatePath: TGMPolylinePath;
begin
  Result := TGMPolylinePath.Create(Self);
end;

destructor TGMPolylineOptions.Destroy;
begin
  FPath.Free;
  inherited;
end;

function TGMPolylineOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#PolylineOptions';
end;

procedure TGMPolylineOptions.PathChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMPolylineOptions.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGMPolylineOptions.SetClickable(const Value: Boolean);
begin
  if FClickable = Value then
    Exit;

  FClickable := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetDraggable(const Value: Boolean);
begin
  if FDraggable = Value then
    Exit;

  FDraggable := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetEditable(const Value: Boolean);
begin
  if FEditable = Value then
    Exit;

  FEditable := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetGeodesic(const Value: Boolean);
begin
  if FGeodesic = Value then
    Exit;

  FGeodesic := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetPath(const Value: TGMPolylinePath);
begin
  if not Assigned(Value) then
    Exit;

  FPath.Assign(Value);
  Changed;
end;

procedure TGMPolylineOptions.SetStrokeColor(const Value: string);
begin
  if SameText(FStrokeColor, Value) then
    Exit;

  FStrokeColor := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetStrokeOpacity(const Value: Double);
begin
  if SameValue(FStrokeOpacity, Value) then
    Exit;

  FStrokeOpacity := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetStrokeWeight(const Value: Integer);
begin
  if FStrokeWeight = Value then
    Exit;

  FStrokeWeight := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  Changed;
end;

procedure TGMPolylineOptions.SetZIndex(const Value: Integer);
begin
  if FZIndex = Value then
    Exit;

  FZIndex := Value;
  Changed;
end;

procedure TGMPolylineOptions.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FUpdatePending then
  begin
    FUpdatePending := False;
    Changed;
  end;
end;

procedure TGMPolylineOptions.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

function TGMPolylineOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{ path: %s, clickable: %s, draggable: %s, editable: %s, geodesic: %s, strokeColor: %s, strokeOpacity: %s, strokeWeight: %d, visible: %s, zIndex: %d }',
    [
      Path.ToJavaScriptLiteral,
      LowerCase(BoolToStr(Clickable, True)),
      LowerCase(BoolToStr(Draggable, True)),
      LowerCase(BoolToStr(Editable, True)),
      LowerCase(BoolToStr(Geodesic, True)),
      JavaScriptQuotedStr(StrokeColor),
      FloatToStr(StrokeOpacity, GMLibInvariantFormatSettings),
      StrokeWeight,
      LowerCase(BoolToStr(Visible, True)),
      ZIndex
    ]
  );
end;

{ TGMPolylineItem }

procedure TGMPolylineItem.ApplyPath(const APath: TJSONArray);
var
  i: Integer;
{$IFDEF FPC}
  JsonItem: TJSONData;
{$ELSE}
  JsonItem: TJSONValue;
{$ENDIF}
  JsonObject: TJSONObject;
  LatValue: Double;
  LngValue: Double;
begin
  if not Assigned(APath) then
    Exit;

  FUpdatingFromMapMessage := True;
  try
    Options.Path.BeginUpdate;
    try
      Options.Path.Clear;
      for i := 0 to APath.Count - 1 do
      begin
        JsonItem := APath.Items[i];
        if not (JsonItem is TJSONObject) then
          Continue;

        JsonObject := TJSONObject(JsonItem);
{$IFDEF FPC}
        if not Assigned(JsonObject.Find('lat')) then
          Continue;
        if not Assigned(JsonObject.Find('lng')) then
          Continue;
        LatValue := JsonObject.Find('lat').AsFloat;
        LngValue := JsonObject.Find('lng').AsFloat;
{$ELSE}
        if not JsonObject.TryGetValue<Double>('lat', LatValue) then
          Continue;
        if not JsonObject.TryGetValue<Double>('lng', LngValue) then
          Continue;
{$ENDIF}

        Options.Path.Add(LatValue, LngValue);
      end;
    finally
      Options.Path.EndUpdate;
    end;
  finally
    FUpdatingFromMapMessage := False;
  end;
end;

procedure TGMPolylineItem.Assign(Source: TPersistent);
begin
  if Source is TGMPolylineItem then
  begin
    Options.Assign(TGMPolylineItem(Source).Options);
    Exit;
  end;

  inherited;
end;

function TGMPolylineItem.BuildApplyCommand: string;
begin
  if not Assigned(FOptions) then
    Exit('');

  { Hidden or empty polylines are removed instead of being pushed as an empty
    JS payload, which keeps Delphi and the browser in the same state. }
  if not Options.Visible or Options.Path.IsEmpty then
    Exit(BuildRemoveCommand);

  Result := PolylineSetOptionsCommand(ObjectId, Options.ToJavaScriptLiteral);
end;

function TGMPolylineItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('polyline_%d', [FNextObjectId]));
end;

function TGMPolylineItem.BuildRemoveCommand: string;
begin
  Result := PolylineRemoveCommand(ObjectId);
end;

constructor TGMPolylineItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FObjectId := BuildObjectId;
  FOptions := CreatePolylineOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
end;

function TGMPolylineItem.CreatePolylineOptions: TGMPolylineOptions;
begin
  Result := TGMPolylineOptions.Create;
end;

destructor TGMPolylineItem.Destroy;
begin
  if Assigned(Collection) and (Collection is TGMPolylines) then
    TGMPolylines(Collection).RegisterRemoval(ObjectId);

  FOptions.Free;
  inherited;
end;

function TGMPolylineItem.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#Polyline';
end;

{$IFNDEF FPC}
function TGMPolylineItem.GetDisplayName: string;
begin
  Result := Format('Polyline %d', [Index]);
end;
{$ENDIF}

procedure TGMPolylineItem.OptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  Changed(False);
end;

procedure TGMPolylineItem.ProcessMapMessage(const AEnvelope: TGMMessageEnvelope);
var
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
  LatLng: TGMLibLatLng;
begin
  LatLng := nil;
  if SameText(AEnvelope.MessageType, 'polyline.dragstart') then
  begin
    if Assigned(FOnDragStart) then
      FOnDragStart(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.drag') then
  begin
    if Assigned(FOnDrag) then
      FOnDrag(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.dragend') then
  begin
    if Assigned(FOnDragEnd) then
      FOnDragEnd(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.path_changed') then
  begin
{$IFDEF FPC}
    JsonValue := GetJSON(AEnvelope.Payload);
{$ELSE}
    JsonValue := TJSONObject.ParseJSONValue(AEnvelope.Payload);
{$ENDIF}
    try
      if JsonValue is TJSONArray then
        ApplyPath(TJSONArray(JsonValue));
    finally
      JsonValue.Free;
    end;

    if Assigned(FOnPathChanged) then
      FOnPathChanged(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.click') then
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
    end
    else
      FOnClick(Self, LatLng);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.contextmenu') then
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
    end
    else
      FOnContextMenu(Self, LatLng);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.dblclick') then
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
    end
    else
      FOnDblClick(Self, LatLng);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.mousedown') then
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
    end
    else
      FOnMouseDown(Self, LatLng);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.mousemove') then
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
    end
    else
      FOnMouseMove(Self, LatLng);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.mouseout') then
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
    end
    else
      FOnMouseOut(Self, LatLng);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.mouseover') then
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
    end
    else
      FOnMouseOver(Self, LatLng);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polyline.mouseup') then
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
    end
    else
      FOnMouseUp(Self, LatLng);
  end;
end;

procedure TGMPolylineItem.SetOptions(const Value: TGMPolylineOptions);
begin
  if not Assigned(Value) then
    Exit;

  FOptions.Assign(Value);
  Changed(False);
end;

function TGMPolylineItem.TryGetCoordinateFromPayload(const APayload: string;
  out ALatLng: TGMLibLatLng): Boolean;
var
  JsonObject: TJSONObject;
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
  LatValue: Double;
  LngValue: Double;
begin
  Result := False;
  ALatLng := nil;

{$IFDEF FPC}
  JsonValue := GetJSON(APayload);
{$ELSE}
  JsonValue := TJSONObject.ParseJSONValue(APayload);
{$ENDIF}
  try
    if not (JsonValue is TJSONObject) then
      Exit;

    JsonObject := TJSONObject(JsonValue);
{$IFDEF FPC}
    if not Assigned(JsonObject.Find('lat')) then
      Exit;
    if not Assigned(JsonObject.Find('lng')) then
      Exit;
    LatValue := JsonObject.Find('lat').AsFloat;
    LngValue := JsonObject.Find('lng').AsFloat;
{$ELSE}
    if not JsonObject.TryGetValue<Double>('lat', LatValue) then
      Exit;
    if not JsonObject.TryGetValue<Double>('lng', LngValue) then
      Exit;
{$ENDIF}

    ALatLng := TGMLibLatLng.Create(LatValue, LngValue);
    Result := True;
  finally
    JsonValue.Free;
  end;
end;

{ TGMPolylines }

function TGMPolylines.Add: TGMPolylineItem;
begin
  Result := TGMPolylineItem(inherited Add);
end;

procedure TGMPolylines.Assign(Source: TPersistent);
var
  i: Integer;
  NewItem: TGMPolylineItem;
  SourcePolylines: TGMPolylines;
begin
  if Source is TGMPolylines then
  begin
    SourcePolylines := TGMPolylines(Source);
    Clear;
    for i := 0 to SourcePolylines.Count - 1 do
    begin
      NewItem := Add;
      NewItem.Assign(SourcePolylines[i]);
    end;
    NotifyChange;
    Exit;
  end;

  inherited;
end;

procedure TGMPolylines.ClearPendingRemovals;
begin
  FPendingRemovals.Clear;
end;

constructor TGMPolylines.Create(AOwner: TPersistent;
  AItemClass: TGMPolylineItemClass);
begin
  if not Assigned(AItemClass) then
    AItemClass := TGMPolylineItem;

  inherited Create(AOwner, TCollectionItemClass(AItemClass));
{$IFDEF FPC}
  FPendingRemovals := specialize TList<TGMObjectId>.Create;
{$ELSE}
  FPendingRemovals := TList<TGMObjectId>.Create;
{$ENDIF}
end;

destructor TGMPolylines.Destroy;
begin
  inherited;
  FPendingRemovals.Free;
end;

function TGMPolylines.FindByObjectId(const AObjectId: TGMObjectId): TGMPolylineItem;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    if SameText(string(Items[i].ObjectId), string(AObjectId)) then
      Exit(Items[i]);
  end;
end;

function TGMPolylines.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#Polyline';
end;

function TGMPolylines.GetItem(Index: Integer): TGMPolylineItem;
begin
  Result := TGMPolylineItem(inherited GetItem(Index));
end;

function TGMPolylines.GetViewportHost: IGMMapViewportHost;
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

procedure TGMPolylines.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMPolylines.RegisterRemoval(const AObjectId: TGMObjectId);
begin
  if AObjectId = '' then
    Exit;

  if not FPendingRemovals.Contains(AObjectId) then
    FPendingRemovals.Add(AObjectId);
end;

procedure TGMPolylines.SetItem(Index: Integer; const Value: TGMPolylineItem);
begin
  inherited SetItem(Index, Value);
end;

function TGMPolylines.TryGetBounds(out ANorth, ASouth, AEast,
  AWest: Double; AVisibleOnly: Boolean; AItemIndex: Integer): Boolean;
var
  i: Integer;
  j: Integer;
  Point: TGMPolylinePoint;
  Polyline: TGMPolylineItem;
begin
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;

  if (AItemIndex >= 0) and (AItemIndex < Count) then
  begin
    i := AItemIndex;
    Polyline := Items[i];
    if (not AVisibleOnly) or Polyline.Options.Visible then
    begin
      for j := 0 to Polyline.Options.Path.Count - 1 do
      begin
        Point := Polyline.Options.Path[j];

        if not Result then
        begin
          { The first point seeds the bounds accumulator; later points only
            expand it. }
          ANorth := Point.Lat;
          ASouth := Point.Lat;
          AEast := Point.Lng;
          AWest := Point.Lng;
          Result := True;
          Continue;
        end;

        ANorth := Max(ANorth, Point.Lat);
        ASouth := Min(ASouth, Point.Lat);
        AEast := Max(AEast, Point.Lng);
        AWest := Min(AWest, Point.Lng);
      end;
    end;
    Exit;
  end;

  for i := 0 to Count - 1 do
  begin
    Polyline := Items[i];
    if AVisibleOnly and not Polyline.Options.Visible then
      Continue;

    for j := 0 to Polyline.Options.Path.Count - 1 do
    begin
      Point := Polyline.Options.Path[j];

      if not Result then
      begin
        ANorth := Point.Lat;
        ASouth := Point.Lat;
        AEast := Point.Lng;
        AWest := Point.Lng;
        Result := True;
        Continue;
      end;

      ANorth := Max(ANorth, Point.Lat);
      ASouth := Min(ASouth, Point.Lat);
      AEast := Max(AEast, Point.Lng);
      AWest := Min(AWest, Point.Lng);
    end;
  end;
end;

procedure TGMPolylines.Update(Item: TCollectionItem);
begin
  inherited;
  NotifyChange;
end;

procedure TGMPolylines.ZoomToPoints(AVisibleOnly: Boolean; AItemIndex: Integer);
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
