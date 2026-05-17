{**
  @abstract(Modelo de coleccion de ground overlays del mapa.)
}
unit uGMLib.GroundOverlay;

{$I ..\..\..\gmlib.inc}

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
  uMapLib.Core.ApiObject,
  uMapLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.MapOptions,
  uGMLib.Platform.Format;

type
  TGMGroundOverlayOptions = class;
  TGMGroundOverlayItem = class;
  TGMGroundOverlays = class;

  TGMGroundOverlayCoordinateEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng) of object;
  TGMGroundOverlayItemClass = class of TGMGroundOverlayItem;

  TGMGroundOverlayOptions = class(TMapLibApiObject)
  private
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FBounds: TGMLatLngBounds;
    FClickable: Boolean;
    FOpacity: Double;
    FUrl: string;
    FVisible: Boolean;
    procedure BoundsChanged(Sender: TObject);
    procedure SetBounds(const Value: TGMLatLngBounds);
    procedure SetClickable(const Value: Boolean);
    procedure SetOpacity(const Value: Double);
    procedure SetUrl(const Value: string);
    procedure SetVisible(const Value: Boolean);
  protected
    procedure Changed; override;
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    function ToJavaScriptLiteral: string;
    procedure EndUpdate;
    property Bounds: TGMLatLngBounds read FBounds write SetBounds;
  published
    property APIUrl;
    property Clickable: Boolean read FClickable write SetClickable default True;
    property Opacity: Double read FOpacity write SetOpacity;
    property Url: string read FUrl write SetUrl;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TGMGroundOverlayItem = class(TCollectionItem)
  private
    class var FNextObjectId: Integer;
  private
    FObjectId: TGMObjectId;
    FOnClick: TGMGroundOverlayCoordinateEvent;
    FOnDblClick: TGMGroundOverlayCoordinateEvent;
    FOptions: TGMGroundOverlayOptions;
    FUpdatingFromMapMessage: Boolean;
    procedure OptionsChanged(Sender: TObject);
    procedure SetOptions(const Value: TGMGroundOverlayOptions);
    function TryGetCoordinateFromPayload(const APayload: string;
      out ALatLng: TGMLibLatLng): Boolean;
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreateGroundOverlayOptions: TGMGroundOverlayOptions; virtual;
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
    property Options: TGMGroundOverlayOptions read FOptions write SetOptions;
    property OnClick: TGMGroundOverlayCoordinateEvent read FOnClick write FOnClick;
    property OnDblClick: TGMGroundOverlayCoordinateEvent read FOnDblClick write FOnDblClick;
  end;

  TGMGroundOverlays = class(TOwnedCollection)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
{$IFDEF FPC}
    FPendingRemovals: specialize TList<TGMObjectId>;
{$ELSE}
    FPendingRemovals: TList<TGMObjectId>;
{$ENDIF}
    function GetItem(Index: Integer): TGMGroundOverlayItem;
    function GetViewportHost: IGMMapViewportHost;
    procedure SetItem(Index: Integer; const Value: TGMGroundOverlayItem);
  protected
    function GetAPIUrl: string; virtual;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TGMGroundOverlayItemClass = nil);
    destructor Destroy; override;
    function Add: TGMGroundOverlayItem;
    function FindByObjectId(const AObjectId: TGMObjectId): TGMGroundOverlayItem;
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
    property Items[Index: Integer]: TGMGroundOverlayItem read GetItem write SetItem; default;
  end;

function GroundOverlaySetOptionsCommand(const AObjectId: TGMObjectId;
  const AOptions: string): string;

implementation

function GroundOverlaySetOptionsCommand(const AObjectId: TGMObjectId;
  const AOptions: string): string;
begin
  Result := Format('gmlib.groundOverlay.setOptions("%s", %s);', [AObjectId, AOptions]);
end;

function GroundOverlayRemoveCommand(const AObjectId: TGMObjectId): string;
begin
  Result := Format('gmlib.groundOverlay.remove("%s");', [AObjectId]);
end;

function JsonQuotedStr(const AValue: string): string;
begin
  Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := '"' + Result + '"';
end;

function NormalizeGroundOverlayUrl(const AValue: string): string;
begin
  Result := AValue;
  if Result = '' then
    Exit;

  if FileExists(Result) then
  begin
    Result := 'file:///' + Result;
    Result := StringReplace(Result, '\', '/', [rfReplaceAll]);
  end;
end;

{ TGMGroundOverlayOptions }

procedure TGMGroundOverlayOptions.Assign(Source: TPersistent);
begin
  if Source is TGMGroundOverlayOptions then
  begin
    Bounds.Assign(TGMGroundOverlayOptions(Source).Bounds);
    Clickable := TGMGroundOverlayOptions(Source).Clickable;
    Opacity := TGMGroundOverlayOptions(Source).Opacity;
    Url := TGMGroundOverlayOptions(Source).Url;
    Visible := TGMGroundOverlayOptions(Source).Visible;
  end
  else
    inherited;
end;

procedure TGMGroundOverlayOptions.BoundsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMGroundOverlayOptions.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

constructor TGMGroundOverlayOptions.Create;
begin
  inherited;
  FBounds := TGMLatLngBounds.Create;
{$IFDEF FPC}
  FBounds.OnChange := @BoundsChanged;
{$ELSE}
  FBounds.OnChange := BoundsChanged;
{$ENDIF}
  FClickable := True;
  FOpacity := 1.0;
  FUrl := '';
  FVisible := True;
end;

procedure TGMGroundOverlayOptions.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

destructor TGMGroundOverlayOptions.Destroy;
begin
  FBounds.Free;
  inherited;
end;

function TGMGroundOverlayOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/image-overlay#GroundOverlay';
end;

procedure TGMGroundOverlayOptions.SetBounds(const Value: TGMLatLngBounds);
begin
  BeginUpdate;
  try
    FBounds.Assign(Value);
  finally
    EndUpdate;
  end;
end;

procedure TGMGroundOverlayOptions.SetClickable(const Value: Boolean);
begin
  if FClickable <> Value then
  begin
    FClickable := Value;
    Changed;
  end;
end;

procedure TGMGroundOverlayOptions.SetOpacity(const Value: Double);
var
  Clamped: Double;
begin
  Clamped := Value;
  if Clamped < 0 then
    Clamped := 0;
  if Clamped > 1 then
    Clamped := 1;
  Clamped := Trunc(Clamped * 100) / 100;

  if SameValue(FOpacity, Clamped) then
    Exit;

  FOpacity := Clamped;
  Changed;
end;

procedure TGMGroundOverlayOptions.SetUrl(const Value: string);
begin
  if FUrl <> Value then
  begin
    FUrl := Value;
    Changed;
  end;
end;

procedure TGMGroundOverlayOptions.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

procedure TGMGroundOverlayOptions.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FUpdatePending then
  begin
    FUpdatePending := False;
    inherited Changed;
  end;
end;

function TGMGroundOverlayOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{url: %s, bounds: %s, clickable: %s, opacity: %s, visible: %s}',
    [
      JsonQuotedStr(NormalizeGroundOverlayUrl(Url)),
      Bounds.ToJavaScriptLiteral,
      LowerCase(BoolToStr(Clickable, True)),
      FloatToStr(Opacity, GMLibInvariantFormatSettings),
      LowerCase(BoolToStr(Visible, True))
    ]
  );
end;

{ TGMGroundOverlayItem }

procedure TGMGroundOverlayItem.Assign(Source: TPersistent);
begin
  if Source is TGMGroundOverlayItem then
  begin
    Options.Assign(TGMGroundOverlayItem(Source).Options);
    OnClick := TGMGroundOverlayItem(Source).OnClick;
    OnDblClick := TGMGroundOverlayItem(Source).OnDblClick;
  end
  else
    inherited;
end;

function TGMGroundOverlayItem.BuildApplyCommand: string;
begin
  if not Assigned(FOptions) then
    Exit('');

  if (Options.Url = '') or not Options.Bounds.IsComplete then
    Exit(BuildRemoveCommand);

  Result := GroundOverlaySetOptionsCommand(ObjectId, Options.ToJavaScriptLiteral);
end;

function TGMGroundOverlayItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('groundoverlay_%d', [FNextObjectId]));
end;

function TGMGroundOverlayItem.BuildRemoveCommand: string;
begin
  Result := GroundOverlayRemoveCommand(ObjectId);
end;

constructor TGMGroundOverlayItem.Create(ACollection: TCollection);
begin
  inherited;
  FObjectId := BuildObjectId;
  FOptions := CreateGroundOverlayOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
end;

function TGMGroundOverlayItem.CreateGroundOverlayOptions: TGMGroundOverlayOptions;
begin
  Result := TGMGroundOverlayOptions.Create;
end;

function TGMGroundOverlayItem.GetAPIUrl: string;
begin
  Result := FOptions.APIUrl;
end;

destructor TGMGroundOverlayItem.Destroy;
begin
  FOptions.Free;
  if Assigned(Collection) and (Collection is TGMGroundOverlays) then
    TGMGroundOverlays(Collection).RegisterRemoval(ObjectId);
  inherited;
end;

{$IFNDEF FPC}
function TGMGroundOverlayItem.GetDisplayName: string;
begin
  Result := Format('GroundOverlay %d', [Index]);
end;
{$ENDIF}

procedure TGMGroundOverlayItem.OptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  Changed(False);
end;

procedure TGMGroundOverlayItem.ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
var
  LatLng: TGMLibLatLng;
begin
  if SameText(AEnvelope.MessageType, 'groundoverlay.click') then
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

  if SameText(AEnvelope.MessageType, 'groundoverlay.dblclick') then
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
  end;
end;

procedure TGMGroundOverlayItem.SetOptions(const Value: TGMGroundOverlayOptions);
begin
  FOptions.Assign(Value);
end;

function TGMGroundOverlayItem.TryGetCoordinateFromPayload(const APayload: string;
  out ALatLng: TGMLibLatLng): Boolean;
var
  JsonObj: TJSONObject;
  LatVal: Double;
  LngVal: Double;
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

{ TGMGroundOverlays }

function TGMGroundOverlays.Add: TGMGroundOverlayItem;
begin
  Result := TGMGroundOverlayItem(inherited Add);
end;

procedure TGMGroundOverlays.ClearPendingRemovals;
begin
  FPendingRemovals.Clear;
end;

constructor TGMGroundOverlays.Create(AOwner: TPersistent; AItemClass: TGMGroundOverlayItemClass);
begin
  if AItemClass = nil then
    AItemClass := TGMGroundOverlayItem;

  inherited Create(AOwner, AItemClass);
  FOwner := AOwner;
{$IFDEF FPC}
  FPendingRemovals := specialize TList<TGMObjectId>.Create;
{$ELSE}
  FPendingRemovals := TList<TGMObjectId>.Create;
{$ENDIF}
end;

destructor TGMGroundOverlays.Destroy;
begin
  inherited;
  FPendingRemovals.Free;
end;

function TGMGroundOverlays.FindByObjectId(const AObjectId: TGMObjectId): TGMGroundOverlayItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].ObjectId = AObjectId then
      Exit(Items[I]);
  Result := nil;
end;

function TGMGroundOverlays.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/image-overlay#GroundOverlay';
end;

function TGMGroundOverlays.GetItem(Index: Integer): TGMGroundOverlayItem;
begin
  Result := TGMGroundOverlayItem(inherited GetItem(Index));
end;

function TGMGroundOverlays.GetViewportHost: IGMMapViewportHost;
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

procedure TGMGroundOverlays.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMGroundOverlays.RegisterRemoval(const AObjectId: TGMObjectId);
begin
  if AObjectId = '' then
    Exit;

  if not FPendingRemovals.Contains(AObjectId) then
    FPendingRemovals.Add(AObjectId);
end;

procedure TGMGroundOverlays.SetItem(Index: Integer; const Value: TGMGroundOverlayItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TGMGroundOverlays.Update(Item: TCollectionItem);
begin
  inherited;
  NotifyChange;
end;

function TGMGroundOverlays.TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
  AVisibleOnly: Boolean; AItemIndex: Integer): Boolean;
var
  I: Integer;
  GroundOverlay: TGMGroundOverlayItem;
begin
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;

  if (AItemIndex >= 0) and (AItemIndex < Count) then
  begin
    GroundOverlay := Items[AItemIndex];
    if (not AVisibleOnly) or GroundOverlay.Options.Visible then
      if GroundOverlay.Options.Bounds.IsComplete then
      begin
        ANorth := GroundOverlay.Options.Bounds.North;
        ASouth := GroundOverlay.Options.Bounds.South;
        AEast := GroundOverlay.Options.Bounds.East;
        AWest := GroundOverlay.Options.Bounds.West;
        Exit(True);
      end;
    Exit(False);
  end;

  for I := 0 to Count - 1 do
  begin
    GroundOverlay := Items[I];
    if AVisibleOnly and not GroundOverlay.Options.Visible then
      Continue;

    if not GroundOverlay.Options.Bounds.IsComplete then
      Continue;

    if not Result then
    begin
      ANorth := GroundOverlay.Options.Bounds.North;
      ASouth := GroundOverlay.Options.Bounds.South;
      AEast := GroundOverlay.Options.Bounds.East;
      AWest := GroundOverlay.Options.Bounds.West;
      Result := True;
      Continue;
    end;

    ANorth := Max(ANorth, GroundOverlay.Options.Bounds.North);
    ASouth := Min(ASouth, GroundOverlay.Options.Bounds.South);
    AEast := Max(AEast, GroundOverlay.Options.Bounds.East);
    AWest := Min(AWest, GroundOverlay.Options.Bounds.West);
  end;
end;

procedure TGMGroundOverlays.ZoomToPoints(AVisibleOnly: Boolean; AItemIndex: Integer);
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




