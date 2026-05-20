{**
  @abstract(Modelo de colecciÃƒÂ³n de polÃƒÂ­gonos del mapa.)
}
unit uGMLib.Polygon;

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
  uGMLib.CoordinatePoint,
  uGMLib.Platform.Format;

type
  TGMPolygonPoint = class;
  TGMPolygonPath = class;
  TGMPolygonOptions = class;
  TGMPolygonItem = class;
  TGMPolygons = class;

  TGMPolygonCoordinateEvent = procedure(Sender: TObject; ALatLng: TMapLibLatLng) of object;
  TGMPolygonPathChangedEvent = procedure(Sender: TObject) of object;
  TGMPolygonItemClass = class of TGMPolygonItem;

  TGMPolygonPoint = class(TGMCoordinatePoint);

  TGMPolygonPath = class(TOwnedCollection)
  private
    FAddingItem: Boolean;
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TGMPolygonPoint;
    procedure SetItem(Index: Integer; const Value: TGMPolygonPoint);
    procedure PathChanged(Sender: TObject);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMPolygonPoint; overload;
    function Add(ALatitude, ALongitude: Double): TGMPolygonPoint; overload;
    procedure Assign(Source: TPersistent); override;
    function IsEmpty: Boolean;
    function ToJavaScriptLiteral: string;
    property Items[Index: Integer]: TGMPolygonPoint read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TGMPolygonOptions = class(TMapLibApiObject)
  private
    FClickable: Boolean;
    FDraggable: Boolean;
    FEditable: Boolean;
    FFillColor: string;
    FFillOpacity: Double;
    FGeodesic: Boolean;
    FPath: TGMPolygonPath;
    FStrokeColor: string;
    FStrokeOpacity: Double;
    FStrokeWeight: Integer;
    FVisible: Boolean;
    FZIndex: Integer;
    procedure PathChanged(Sender: TObject);
    procedure SetClickable(const Value: Boolean);
    procedure SetDraggable(const Value: Boolean);
    procedure SetEditable(const Value: Boolean);
    procedure SetFillColor(const Value: string);
    procedure SetFillOpacity(const Value: Double);
    procedure SetGeodesic(const Value: Boolean);
    procedure SetPath(const Value: TGMPolygonPath);
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
    property Path: TGMPolygonPath read FPath write SetPath;
    property StrokeColor: string read FStrokeColor write SetStrokeColor;
    property FillColor: string read FFillColor write SetFillColor;
  published
    property APIUrl;
    property Clickable: Boolean read FClickable write SetClickable default True;
    property Draggable: Boolean read FDraggable write SetDraggable default False;
    property Editable: Boolean read FEditable write SetEditable default False;
    property FillOpacity: Double read FFillOpacity write SetFillOpacity;
    property Geodesic: Boolean read FGeodesic write SetGeodesic default False;
    property StrokeOpacity: Double read FStrokeOpacity write SetStrokeOpacity;
    property StrokeWeight: Integer read FStrokeWeight write SetStrokeWeight default 2;
    property Visible: Boolean read FVisible write SetVisible default True;
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
  end;

  TGMPolygonItem = class(TCollectionItem)
  private
    class var FNextObjectId: Integer;
  private
    FObjectId: TGMObjectId;
    FOnClick: TGMPolygonCoordinateEvent;
    FOnContextMenu: TGMPolygonCoordinateEvent;
    FOnDblClick: TGMPolygonCoordinateEvent;
    FOnDrag: TNotifyEvent;
    FOnDragEnd: TNotifyEvent;
    FOnDragStart: TNotifyEvent;
    FOnMouseDown: TGMPolygonCoordinateEvent;
    FOnMouseMove: TGMPolygonCoordinateEvent;
    FOnMouseOut: TGMPolygonCoordinateEvent;
    FOnMouseOver: TGMPolygonCoordinateEvent;
    FOnMouseUp: TGMPolygonCoordinateEvent;
    FOnPathChanged: TGMPolygonPathChangedEvent;
    FOptions: TGMPolygonOptions;
    FUpdatingFromMapMessage: Boolean;
    procedure ApplyPath(const APath: TJSONArray);
    procedure OptionsChanged(Sender: TObject);
    procedure SetOptions(const Value: TGMPolygonOptions);
    function TryGetCoordinateFromPayload(const APayload: string;
      out ALatLng: TMapLibLatLng): Boolean;
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreatePolygonOptions: TGMPolygonOptions; virtual;
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
    procedure ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
    property ObjectId: TGMObjectId read FObjectId;
  published
    property APIUrl: string read GetAPIUrl;
    property Options: TGMPolygonOptions read FOptions write SetOptions;
    property OnClick: TGMPolygonCoordinateEvent read FOnClick write FOnClick;
    property OnContextMenu: TGMPolygonCoordinateEvent read FOnContextMenu write FOnContextMenu;
    property OnDblClick: TGMPolygonCoordinateEvent read FOnDblClick write FOnDblClick;
    property OnDrag: TNotifyEvent read FOnDrag write FOnDrag;
    property OnDragEnd: TNotifyEvent read FOnDragEnd write FOnDragEnd;
    property OnDragStart: TNotifyEvent read FOnDragStart write FOnDragStart;
    property OnMouseDown: TGMPolygonCoordinateEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TGMPolygonCoordinateEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseOut: TGMPolygonCoordinateEvent read FOnMouseOut write FOnMouseOut;
    property OnMouseOver: TGMPolygonCoordinateEvent read FOnMouseOver write FOnMouseOver;
    property OnMouseUp: TGMPolygonCoordinateEvent read FOnMouseUp write FOnMouseUp;
    property OnPathChanged: TGMPolygonPathChangedEvent read FOnPathChanged write FOnPathChanged;
  end;

  TGMPolygons = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
{$IFDEF FPC}
    FPendingRemovals: specialize TList<TGMObjectId>;
{$ELSE}
    FPendingRemovals: TList<TGMObjectId>;
{$ENDIF}
    function GetItem(Index: Integer): TGMPolygonItem;
    procedure SetItem(Index: Integer; const Value: TGMPolygonItem);
  protected
    function GetAPIUrl: string; virtual;
    function GetViewportHost: IGMMapViewportHost;
    procedure NotifyChange;
    procedure RegisterRemoval(const AObjectId: TGMObjectId);
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TGMPolygonItemClass = nil);
    destructor Destroy; override;
    function Add: TGMPolygonItem;
    procedure Assign(Source: TPersistent); override;
    procedure ClearPendingRemovals;
    function FindByObjectId(const AObjectId: TGMObjectId): TGMPolygonItem;
    function TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
      AVisibleOnly: Boolean = True; AItemIndex: Integer = -1): Boolean;
    procedure ZoomToPoints(AVisibleOnly: Boolean = True; AItemIndex: Integer = -1);
    property APIUrl: string read GetAPIUrl;
    property Items[Index: Integer]: TGMPolygonItem read GetItem write SetItem; default;
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

function PolygonRemoveCommand(const AObjectId: TGMObjectId): string;
begin
  Result := Format('gmlib.polygon.remove(%s);', [QuotedStr(string(AObjectId))]);
end;

function PolygonSetOptionsCommand(const AObjectId: TGMObjectId;
  const AOptionsLiteral: string): string;
begin
  Result := Format('gmlib.polygon.setOptions(%s, %s);', [
    QuotedStr(string(AObjectId)),
    AOptionsLiteral
  ]);
end;

{ TGMPolygonPoint }

{ TGMPolygonPath }

function TGMPolygonPath.Add: TGMPolygonPoint;
begin
  FAddingItem := True;
  try
    Result := TGMPolygonPoint(inherited Add);
  finally
    FAddingItem := False;
  end;
end;

function TGMPolygonPath.Add(ALatitude, ALongitude: Double): TGMPolygonPoint;
begin
{$IFDEF FPC}
  Result := nil;
{$ENDIF}
  Result := Add;
  if Assigned(Result) then
  begin
    Result.Lat := ALatitude;
    Result.Lng := ALongitude;
  end;
end;

procedure TGMPolygonPath.Assign(Source: TPersistent);
var
  i: Integer;
  NewPoint: TGMPolygonPoint;
  SourcePath: TGMPolygonPath;
begin
  if Source is TGMPolygonPath then
  begin
    SourcePath := TGMPolygonPath(Source);
    Clear;
    for i := 0 to SourcePath.Count - 1 do
    begin
      NewPoint := Add;
      NewPoint.Assign(SourcePath[i]);
    end;
    PathChanged(Self);
    Exit;
  end;

  inherited;
end;

constructor TGMPolygonPath.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TCollectionItemClass(TGMPolygonPoint));
end;

function TGMPolygonPath.GetItem(Index: Integer): TGMPolygonPoint;
begin
  Result := TGMPolygonPoint(inherited GetItem(Index));
end;

function TGMPolygonPath.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

procedure TGMPolygonPath.PathChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMPolygonPath.SetItem(Index: Integer; const Value: TGMPolygonPoint);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

function TGMPolygonPath.ToJavaScriptLiteral: string;
var
  i: Integer;
begin
  Result := '[';

  for i := 0 to Count - 1 do
  begin
    if i > 0 then
      Result := Result + ', ';
    Result := Result + Items[i].ToJavaScriptLiteral;
  end;

  Result := Result + ']';
end;

procedure TGMPolygonPath.Update(Item: TCollectionItem);
begin
  inherited;
  if FAddingItem then
    Exit;

  PathChanged(Self);
end;

{ TGMPolygonOptions }

procedure TGMPolygonOptions.Assign(Source: TPersistent);
begin
  if Source is TGMPolygonOptions then
  begin
    Clickable := TGMPolygonOptions(Source).Clickable;
    Draggable := TGMPolygonOptions(Source).Draggable;
    Editable := TGMPolygonOptions(Source).Editable;
    FillColor := TGMPolygonOptions(Source).FillColor;
    FillOpacity := TGMPolygonOptions(Source).FillOpacity;
    Geodesic := TGMPolygonOptions(Source).Geodesic;
    Path.Assign(TGMPolygonOptions(Source).Path);
    StrokeColor := TGMPolygonOptions(Source).StrokeColor;
    StrokeOpacity := TGMPolygonOptions(Source).StrokeOpacity;
    StrokeWeight := TGMPolygonOptions(Source).StrokeWeight;
    Visible := TGMPolygonOptions(Source).Visible;
    ZIndex := TGMPolygonOptions(Source).ZIndex;
    Exit;
  end;

  inherited;
end;

constructor TGMPolygonOptions.Create;
begin
  inherited;
  FClickable := True;
  FDraggable := False;
  FEditable := False;
  FFillOpacity := 0.35;
  FGeodesic := False;
  FPath := TGMPolygonPath.Create(Self);
{$IFDEF FPC}
  FPath.OnChange := @PathChanged;
{$ELSE}
  FPath.OnChange := PathChanged;
{$ENDIF}
  FStrokeOpacity := 1.0;
  FStrokeWeight := 2;
  FVisible := True;
  FZIndex := 0;
end;

destructor TGMPolygonOptions.Destroy;
begin
  FPath.Free;
  inherited;
end;

function TGMPolygonOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#PolygonOptions';
end;

procedure TGMPolygonOptions.PathChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMPolygonOptions.SetClickable(const Value: Boolean);
begin
  if FClickable = Value then
    Exit;

  FClickable := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetDraggable(const Value: Boolean);
begin
  if FDraggable = Value then
    Exit;

  FDraggable := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetEditable(const Value: Boolean);
begin
  if FEditable = Value then
    Exit;

  FEditable := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetFillColor(const Value: string);
begin
  if SameText(FFillColor, Value) then
    Exit;

  FFillColor := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetFillOpacity(const Value: Double);
begin
  if SameValue(FFillOpacity, Value) then
    Exit;

  FFillOpacity := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetGeodesic(const Value: Boolean);
begin
  if FGeodesic = Value then
    Exit;

  FGeodesic := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetPath(const Value: TGMPolygonPath);
begin
  if (not Assigned(Value)) or (Value = FPath) then
    Exit;

  FPath.Assign(Value);
  Changed;
end;

procedure TGMPolygonOptions.SetStrokeColor(const Value: string);
begin
  if SameText(FStrokeColor, Value) then
    Exit;

  FStrokeColor := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetStrokeOpacity(const Value: Double);
begin
  if SameValue(FStrokeOpacity, Value) then
    Exit;

  FStrokeOpacity := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetStrokeWeight(const Value: Integer);
begin
  if FStrokeWeight = Value then
    Exit;

  FStrokeWeight := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  Changed;
end;

procedure TGMPolygonOptions.SetZIndex(const Value: Integer);
begin
  if FZIndex = Value then
    Exit;

  FZIndex := Value;
  Changed;
end;

function TGMPolygonOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{ path: %s, clickable: %s, draggable: %s, editable: %s, fillColor: %s, fillOpacity: %s, geodesic: %s, strokeColor: %s, strokeOpacity: %s, strokeWeight: %d, visible: %s, zIndex: %d }',
    [
      Path.ToJavaScriptLiteral,
      LowerCase(BoolToStr(Clickable, True)),
      LowerCase(BoolToStr(Draggable, True)),
      LowerCase(BoolToStr(Editable, True)),
      JavaScriptQuotedStr(FillColor),
      FloatToStr(FillOpacity, GMLibInvariantFormatSettings),
      LowerCase(BoolToStr(Geodesic, True)),
      JavaScriptQuotedStr(StrokeColor),
      FloatToStr(StrokeOpacity, GMLibInvariantFormatSettings),
      StrokeWeight,
      LowerCase(BoolToStr(Visible, True)),
      ZIndex
    ]
  );
end;

{ TGMPolygonItem }

procedure TGMPolygonItem.ApplyPath(const APath: TJSONArray);
var
  j: Integer;
{$IFDEF FPC}
  JsonPoint: TJSONData;
{$ELSE}
  JsonPoint: TJSONValue;
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
      for j := 0 to APath.Count - 1 do
      begin
        JsonPoint := APath.Items[j];
        if not (JsonPoint is TJSONObject) then
          Continue;

        JsonObject := TJSONObject(JsonPoint);
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

procedure TGMPolygonItem.Assign(Source: TPersistent);
begin
  if Source is TGMPolygonItem then
  begin
    Options.Assign(TGMPolygonItem(Source).Options);
    Exit;
  end;

  inherited;
end;

function TGMPolygonItem.BuildApplyCommand: string;
begin
  if not Assigned(FOptions) then
    Exit('');

  { The map only receives the polygon when it is both visible and has a valid
    path, otherwise we remove the existing overlay. }
  if not Options.Visible or Options.Path.IsEmpty then
    Exit(BuildRemoveCommand);

  Result := PolygonSetOptionsCommand(ObjectId, Options.ToJavaScriptLiteral);
end;

function TGMPolygonItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('polygon_%d', [FNextObjectId]));
end;

function TGMPolygonItem.BuildRemoveCommand: string;
begin
  Result := PolygonRemoveCommand(ObjectId);
end;

constructor TGMPolygonItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FObjectId := BuildObjectId;
  FOptions := CreatePolygonOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
end;

function TGMPolygonItem.CreatePolygonOptions: TGMPolygonOptions;
begin
  Result := TGMPolygonOptions.Create;
end;

destructor TGMPolygonItem.Destroy;
begin
  if Assigned(Collection) and (Collection is TGMPolygons) then
    TGMPolygons(Collection).RegisterRemoval(ObjectId);

  FOptions.Free;
  inherited;
end;

function TGMPolygonItem.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#Polygon';
end;

{$IFNDEF FPC}
function TGMPolygonItem.GetDisplayName: string;
begin
  Result := Format('Polygon %d', [Index]);
end;
{$ENDIF}

procedure TGMPolygonItem.OptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  Changed(False);
end;

procedure TGMPolygonItem.ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
var
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
  LatLng: TMapLibLatLng;
begin
  LatLng := nil;

  if SameText(AEnvelope.MessageType, 'polygon.dragstart') then
  begin
    if Assigned(FOnDragStart) then
      FOnDragStart(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polygon.drag') then
  begin
    if Assigned(FOnDrag) then
      FOnDrag(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polygon.dragend') then
  begin
    if Assigned(FOnDragEnd) then
      FOnDragEnd(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'polygon.path_changed') then
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

  if SameText(AEnvelope.MessageType, 'polygon.click') then
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

  if SameText(AEnvelope.MessageType, 'polygon.contextmenu') then
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

  if SameText(AEnvelope.MessageType, 'polygon.dblclick') then
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

  if SameText(AEnvelope.MessageType, 'polygon.mousedown') then
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

  if SameText(AEnvelope.MessageType, 'polygon.mousemove') then
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

  if SameText(AEnvelope.MessageType, 'polygon.mouseout') then
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

  if SameText(AEnvelope.MessageType, 'polygon.mouseover') then
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

  if SameText(AEnvelope.MessageType, 'polygon.mouseup') then
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

procedure TGMPolygonItem.SetOptions(const Value: TGMPolygonOptions);
begin
  if (not Assigned(Value)) or (Value = FOptions) then
    Exit;

  FOptions.Assign(Value);
  Changed(False);
end;

function TGMPolygonItem.TryGetCoordinateFromPayload(const APayload: string;
  out ALatLng: TMapLibLatLng): Boolean;
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

    ALatLng := TMapLibLatLng.Create(LatValue, LngValue);
    Result := True;
  finally
    JsonValue.Free;
  end;
end;

{ TGMPolygons }

function TGMPolygons.Add: TGMPolygonItem;
begin
  Result := TGMPolygonItem(inherited Add);
end;

procedure TGMPolygons.Assign(Source: TPersistent);
var
  i: Integer;
  NewItem: TGMPolygonItem;
  SourcePolygons: TGMPolygons;
begin
  if Source is TGMPolygons then
  begin
    SourcePolygons := TGMPolygons(Source);
    Clear;
    for i := 0 to SourcePolygons.Count - 1 do
    begin
      NewItem := Add;
      NewItem.Assign(SourcePolygons[i]);
    end;
    NotifyChange;
    Exit;
  end;

  inherited;
end;

procedure TGMPolygons.ClearPendingRemovals;
begin
  FPendingRemovals.Clear;
end;

constructor TGMPolygons.Create(AOwner: TPersistent; AItemClass: TGMPolygonItemClass);
begin
  if not Assigned(AItemClass) then
    AItemClass := TGMPolygonItem;

  inherited Create(AOwner, TCollectionItemClass(AItemClass));
{$IFDEF FPC}
  FPendingRemovals := specialize TList<TGMObjectId>.Create;
{$ELSE}
  FPendingRemovals := TList<TGMObjectId>.Create;
{$ENDIF}
end;

destructor TGMPolygons.Destroy;
begin
  inherited;
  FPendingRemovals.Free;
end;

function TGMPolygons.FindByObjectId(const AObjectId: TGMObjectId): TGMPolygonItem;
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

function TGMPolygons.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/polygon#Polygon';
end;

function TGMPolygons.GetItem(Index: Integer): TGMPolygonItem;
begin
  Result := TGMPolygonItem(inherited GetItem(Index));
end;

function TGMPolygons.GetViewportHost: IGMMapViewportHost;
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

procedure TGMPolygons.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMPolygons.RegisterRemoval(const AObjectId: TGMObjectId);
begin
  if AObjectId = '' then
    Exit;

  if not FPendingRemovals.Contains(AObjectId) then
    FPendingRemovals.Add(AObjectId);
end;

procedure TGMPolygons.SetItem(Index: Integer; const Value: TGMPolygonItem);
begin
  inherited SetItem(Index, Value);
end;

function TGMPolygons.TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
  AVisibleOnly: Boolean; AItemIndex: Integer): Boolean;
var
  i: Integer;
  j: Integer;
  Point: TGMPolygonPoint;
  Polygon: TGMPolygonItem;
begin
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;

  if (AItemIndex >= 0) and (AItemIndex < Count) then
  begin
    Polygon := Items[AItemIndex];
    if (not AVisibleOnly) or Polygon.Options.Visible then
    begin
      for j := 0 to Polygon.Options.Path.Count - 1 do
      begin
        Point := Polygon.Options.Path[j];

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
    Polygon := Items[i];
    if AVisibleOnly and not Polygon.Options.Visible then
      Continue;

    for j := 0 to Polygon.Options.Path.Count - 1 do
    begin
      Point := Polygon.Options.Path[j];

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

procedure TGMPolygons.Update(Item: TCollectionItem);
begin
  inherited;
  NotifyChange;
end;

procedure TGMPolygons.ZoomToPoints(AVisibleOnly: Boolean; AItemIndex: Integer);
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







