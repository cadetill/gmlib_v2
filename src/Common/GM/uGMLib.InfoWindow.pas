{**
  @abstract(Modelo de colecciÃ³n de ventanas de informaciÃ³n del mapa.)
}
unit uGMLib.InfoWindow;

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
  uGMLib.Marker;

type
  TGMInfoWindowPixelOffset = class;
  TGMInfoWindowOpenOptions = class;
  TGMInfoWindowOptions = class;
  TGMInfoWindowItem = class;

  TGMInfoWindowContentEvent = procedure(Sender: TObject; const AValue: string) of object;
  TGMInfoWindowHeaderDisabledEvent = procedure(Sender: TObject; AValue: Boolean) of object;
  TGMInfoWindowPositionEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng) of object;
  TGMInfoWindowZIndexEvent = procedure(Sender: TObject; AValue: Integer) of object;
  TGMInfoWindowItemClass = class of TGMInfoWindowItem;

  TGMInfoWindowPixelOffset = class(TMapLibApiObject)
  private
    FHeight: Integer;
    FWidth: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  protected
    function GetAPIUrl: string; override;
  public
    procedure Assign(Source: TPersistent); override;
    function IsEmpty: Boolean;
    function ToJavaScriptLiteral: string;
  published
    property APIUrl;
    property Height: Integer read FHeight write SetHeight default 0;
    property Width: Integer read FWidth write SetWidth default 0;
  end;

  TGMInfoWindowOpenOptions = class(TMapLibApiObject)
  private
    FAnchorObjectId: TGMObjectId;
    FShouldFocus: Boolean;
    procedure SetAnchorObjectId(const Value: TGMObjectId);
    procedure SetShouldFocus(const Value: Boolean);
  protected
    function GetAPIUrl: string; override;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property APIUrl;
    property AnchorObjectId: TGMObjectId read FAnchorObjectId write SetAnchorObjectId;
    property ShouldFocus: Boolean read FShouldFocus write SetShouldFocus default False;
  end;

  TGMInfoWindowOptions = class(TMapLibApiObject)
  private
    FAriaLabel: string;
    FContent: string;
    FDisableAutoPan: Boolean;
    FHeaderContent: string;
    FHeaderDisabled: Boolean;
    FMaxWidth: Integer;
    FMinWidth: Integer;
    FPixelOffset: TGMInfoWindowPixelOffset;
    FPosition: TGMLibLatLng;
    FVisible: Boolean;
    FZIndex: Integer;
    procedure PixelOffsetChanged(Sender: TObject);
    procedure SetAriaLabel(const Value: string);
    procedure PositionChanged(Sender: TObject);
    procedure SetContent(const Value: string);
    procedure SetDisableAutoPan(const Value: Boolean);
    procedure SetHeaderContent(const Value: string);
    procedure SetHeaderDisabled(const Value: Boolean);
    procedure SetMaxWidth(const Value: Integer);
    procedure SetMinWidth(const Value: Integer);
    procedure SetPixelOffset(const Value: TGMInfoWindowPixelOffset);
    procedure SetPosition(const Value: TGMLibLatLng);
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
    property AriaLabel: string read FAriaLabel write SetAriaLabel;
    property Content: string read FContent write SetContent;
    property DisableAutoPan: Boolean read FDisableAutoPan write SetDisableAutoPan default False;
    property HeaderContent: string read FHeaderContent write SetHeaderContent;
    property HeaderDisabled: Boolean read FHeaderDisabled write SetHeaderDisabled default False;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 0;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property PixelOffset: TGMInfoWindowPixelOffset read FPixelOffset write SetPixelOffset;
    property Position: TGMLibLatLng read FPosition write SetPosition;
    property Visible: Boolean read FVisible write SetVisible default False;
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
  end;

  TGMInfoWindowItem = class(TCollectionItem)
  private
    class var FNextObjectId: Integer;
  private
    FIsOpen: Boolean;
    FOnContentChanged: TGMInfoWindowContentEvent;
    FOnClose: TNotifyEvent;
    FObjectId: TGMObjectId;
    FOnCloseClick: TNotifyEvent;
    FOnDomReady: TNotifyEvent;
    FOnHeaderContentChanged: TGMInfoWindowContentEvent;
    FOnHeaderDisabledChanged: TGMInfoWindowHeaderDisabledEvent;
    FOnPositionChanged: TGMInfoWindowPositionEvent;
    FOnVisible: TNotifyEvent;
    FOnZIndexChanged: TGMInfoWindowZIndexEvent;
    FOpenOptions: TGMInfoWindowOpenOptions;
    FOptions: TGMInfoWindowOptions;
    FPendingFocus: Boolean;
    FUpdatingFromMapMessage: Boolean;
    procedure ApplyCloseOthersBeforeOpenPolicy;
    function TryApplyPositionFromPayload(const APayload: string; out ALatLng: TGMLibLatLng): Boolean;
    function GetAnchorObjectId: TGMObjectId;
    function GetShouldFocus: Boolean;
    procedure OpenOptionsChanged(Sender: TObject);
    procedure OptionsChanged(Sender: TObject);
    procedure SetAnchorObjectId(const Value: TGMObjectId);
    procedure SetOpenOptions(const Value: TGMInfoWindowOpenOptions);
    procedure SetOptions(const Value: TGMInfoWindowOptions);
    procedure SetShouldFocus(const Value: Boolean);
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreateOpenOptions: TGMInfoWindowOpenOptions; virtual;
    function CreateInfoWindowOptions: TGMInfoWindowOptions; virtual;
    function GetAPIUrl: string; virtual;
{$IFNDEF FPC}
    function GetDisplayName: string; override;
{$ENDIF}
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function BuildApplyCommand: string;
    function BuildOpenCommand: string;
    function BuildCloseCommand: string;
    function BuildFocusCommand: string;
    function BuildRemoveCommand: string;
    procedure Focus;
    procedure Open; overload;
    procedure Open(AAnchorMarker: TGMMarkerItem; AShouldFocus: Boolean = False); overload;
    procedure OpenByObjectId(const AAnchorObjectId: TGMObjectId;
      AShouldFocus: Boolean = False);
    procedure CenterMapTo;
    procedure Close;
    procedure ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
    property ObjectId: TGMObjectId read FObjectId;
    property IsOpen: Boolean read FIsOpen;
    property AnchorObjectId: TGMObjectId read GetAnchorObjectId write SetAnchorObjectId;
    property ShouldFocus: Boolean read GetShouldFocus write SetShouldFocus default False;
  published
    property APIUrl: string read GetAPIUrl;
    property OpenOptions: TGMInfoWindowOpenOptions read FOpenOptions write SetOpenOptions;
    property Options: TGMInfoWindowOptions read FOptions write SetOptions;
    property OnContentChanged: TGMInfoWindowContentEvent read FOnContentChanged write FOnContentChanged;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnCloseClick: TNotifyEvent read FOnCloseClick write FOnCloseClick;
    property OnDomReady: TNotifyEvent read FOnDomReady write FOnDomReady;
    property OnHeaderContentChanged: TGMInfoWindowContentEvent read FOnHeaderContentChanged write FOnHeaderContentChanged;
    property OnHeaderDisabledChanged: TGMInfoWindowHeaderDisabledEvent read FOnHeaderDisabledChanged write FOnHeaderDisabledChanged;
    property OnPositionChanged: TGMInfoWindowPositionEvent read FOnPositionChanged write FOnPositionChanged;
    property OnVisible: TNotifyEvent read FOnVisible write FOnVisible;
    property OnZIndexChanged: TGMInfoWindowZIndexEvent read FOnZIndexChanged write FOnZIndexChanged;
  end;

  TGMInfoWindows = class(TOwnedCollection)
  private
    FCloseOthersBeforeOpen: Boolean;
    FClosingOthersBeforeOpen: Boolean;
    FOnChange: TNotifyEvent;
{$IFDEF FPC}
    FPendingRemovals: specialize TList<TGMObjectId>;
{$ELSE}
    FPendingRemovals: TList<TGMObjectId>;
{$ENDIF}
    function GetItem(Index: Integer): TGMInfoWindowItem;
    procedure SetItem(Index: Integer; const Value: TGMInfoWindowItem);
  protected
    function GetAPIUrl: string; virtual;
    function GetViewportHost: IGMMapViewportHost;
    procedure NotifyChange;
    procedure RegisterRemoval(const AObjectId: TGMObjectId);
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TGMInfoWindowItemClass = nil);
    destructor Destroy; override;
    function Add: TGMInfoWindowItem;
    procedure CloseOthers(AExcept: TGMInfoWindowItem);
    procedure DetachAnchorFromObject(const AObjectId: TGMObjectId);
    procedure DetachAnchorFromMarker(const AMarkerObjectId: TGMObjectId);
    function FindByObjectId(const AObjectId: TGMObjectId): TGMInfoWindowItem;
    procedure Assign(Source: TPersistent); override;
    procedure ClearPendingRemovals;
    property APIUrl: string read GetAPIUrl;
    property Items[Index: Integer]: TGMInfoWindowItem read GetItem write SetItem; default;
    property CloseOthersBeforeOpen: Boolean read FCloseOthersBeforeOpen write FCloseOthersBeforeOpen default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
{$IFDEF FPC}
    property PendingRemovals: specialize TList<TGMObjectId> read FPendingRemovals;
{$ELSE}
    property PendingRemovals: TList<TGMObjectId> read FPendingRemovals;
{$ENDIF}
  end;

implementation

{$IFDEF FPC}
function InfoWindowPayloadAsString(const AEnvelope: TMapLibMessageEnvelope): string;
begin
  Result := Trim(AEnvelope.Payload);
  if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;
{$ENDIF}

function JavaScriptQuotedStr(const AValue: string): string;
begin
  Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '\''', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := '''' + Result + '''';
end;

function JoinJavaScriptParts(AParts: TStrings): string;
var
  i: Integer;
begin
  Result := '';
  if not Assigned(AParts) then
    Exit;

  for i := 0 to AParts.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + AParts[i];
  end;
end;

function BooleanToJavaScriptLiteral(const AValue: Boolean): string;
begin
  Result := LowerCase(BoolToStr(AValue, True));
end;

function InfoWindowSetOptionsCommand(const AObjectId: TGMObjectId; const AOptionsLiteral: string): string;
begin
  Result := Format('gmlib.infoWindow.setOptions(%s, %s);', [
    QuotedStr(string(AObjectId)),
    AOptionsLiteral
  ]);
end;

function InfoWindowOpenCommand(const AObjectId, AAnchorObjectId: TGMObjectId;
  AShouldFocus: Boolean): string;
var
  OpenOptions: string;
begin
  OpenOptions := Format('{ shouldFocus: %s', [BooleanToJavaScriptLiteral(AShouldFocus)]);
  if AAnchorObjectId <> '' then
    OpenOptions := OpenOptions + ', anchorId: ' + QuotedStr(string(AAnchorObjectId));
  OpenOptions := OpenOptions + ' }';

  Result := Format('gmlib.infoWindow.open(%s, %s);', [
    QuotedStr(string(AObjectId)),
    OpenOptions
  ]);
end;

function InfoWindowCloseCommand(const AObjectId: TGMObjectId): string;
begin
  Result := Format('gmlib.infoWindow.close(%s);', [QuotedStr(string(AObjectId))]);
end;

function InfoWindowFocusCommand(const AObjectId: TGMObjectId): string;
begin
  Result := Format('gmlib.infoWindow.focus(%s);', [QuotedStr(string(AObjectId))]);
end;

function InfoWindowRemoveCommand(const AObjectId: TGMObjectId): string;
begin
  Result := Format('gmlib.infoWindow.remove(%s);', [QuotedStr(string(AObjectId))]);
end;

{ TGMInfoWindowPixelOffset }

procedure TGMInfoWindowPixelOffset.Assign(Source: TPersistent);
begin
  if Source is TGMInfoWindowPixelOffset then
  begin
    Height := TGMInfoWindowPixelOffset(Source).Height;
    Width := TGMInfoWindowPixelOffset(Source).Width;
    Exit;
  end;

  inherited;
end;

function TGMInfoWindowPixelOffset.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/coordinates#Size';
end;

function TGMInfoWindowPixelOffset.IsEmpty: Boolean;
begin
  Result := (FHeight = 0) and (FWidth = 0);
end;

procedure TGMInfoWindowPixelOffset.SetHeight(const Value: Integer);
begin
  if FHeight = Value then
    Exit;

  FHeight := Value;
  Changed;
end;

procedure TGMInfoWindowPixelOffset.SetWidth(const Value: Integer);
begin
  if FWidth = Value then
    Exit;

  FWidth := Value;
  Changed;
end;

function TGMInfoWindowPixelOffset.ToJavaScriptLiteral: string;
begin
  Result := Format('{ width: %d, height: %d }', [FWidth, FHeight]);
end;

{ TGMInfoWindowOpenOptions }

procedure TGMInfoWindowOpenOptions.Assign(Source: TPersistent);
begin
  if Source is TGMInfoWindowOpenOptions then
  begin
    AnchorObjectId := TGMInfoWindowOpenOptions(Source).AnchorObjectId;
    ShouldFocus := TGMInfoWindowOpenOptions(Source).ShouldFocus;
    Exit;
  end;

  inherited;
end;

function TGMInfoWindowOpenOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/info-window#InfoWindowOpenOptions';
end;

procedure TGMInfoWindowOpenOptions.SetAnchorObjectId(const Value: TGMObjectId);
begin
  if string(FAnchorObjectId) = string(Value) then
    Exit;

  FAnchorObjectId := Value;
  Changed;
end;

procedure TGMInfoWindowOpenOptions.SetShouldFocus(const Value: Boolean);
begin
  if FShouldFocus = Value then
    Exit;

  FShouldFocus := Value;
  Changed;
end;

{ TGMInfoWindowOptions }

procedure TGMInfoWindowOptions.Assign(Source: TPersistent);
begin
  if Source is TGMInfoWindowOptions then
  begin
    AriaLabel := TGMInfoWindowOptions(Source).AriaLabel;
    Content := TGMInfoWindowOptions(Source).Content;
    DisableAutoPan := TGMInfoWindowOptions(Source).DisableAutoPan;
    HeaderContent := TGMInfoWindowOptions(Source).HeaderContent;
    HeaderDisabled := TGMInfoWindowOptions(Source).HeaderDisabled;
    MaxWidth := TGMInfoWindowOptions(Source).MaxWidth;
    MinWidth := TGMInfoWindowOptions(Source).MinWidth;
    PixelOffset.Assign(TGMInfoWindowOptions(Source).PixelOffset);
    Position.Assign(TGMInfoWindowOptions(Source).Position);
    Visible := TGMInfoWindowOptions(Source).Visible;
    ZIndex := TGMInfoWindowOptions(Source).ZIndex;
    Exit;
  end;

  inherited;
end;

constructor TGMInfoWindowOptions.Create;
begin
  inherited;
  FPixelOffset := TGMInfoWindowPixelOffset.Create;
{$IFDEF FPC}
  FPixelOffset.OnChange := @PixelOffsetChanged;
{$ELSE}
  FPixelOffset.OnChange := PixelOffsetChanged;
{$ENDIF}
  FPosition := TGMLibLatLng.Create;
{$IFDEF FPC}
  FPosition.OnChange := @PositionChanged;
{$ELSE}
  FPosition.OnChange := PositionChanged;
{$ENDIF}
  FVisible := False;
end;

destructor TGMInfoWindowOptions.Destroy;
begin
  FPixelOffset.Free;
  FPosition.Free;
  inherited;
end;

function TGMInfoWindowOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/info-window#InfoWindowOptions';
end;

procedure TGMInfoWindowOptions.PixelOffsetChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMInfoWindowOptions.PositionChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMInfoWindowOptions.SetAriaLabel(const Value: string);
begin
  if FAriaLabel = Value then
    Exit;
  FAriaLabel := Value;
  Changed;
end;

procedure TGMInfoWindowOptions.SetContent(const Value: string);
begin
  if FContent = Value then
    Exit;
  FContent := Value;
  Changed;
end;

procedure TGMInfoWindowOptions.SetDisableAutoPan(const Value: Boolean);
begin
  if FDisableAutoPan = Value then
    Exit;
  FDisableAutoPan := Value;
  Changed;
end;

procedure TGMInfoWindowOptions.SetHeaderContent(const Value: string);
begin
  if FHeaderContent = Value then
    Exit;
  FHeaderContent := Value;
  Changed;
end;

procedure TGMInfoWindowOptions.SetHeaderDisabled(const Value: Boolean);
begin
  if FHeaderDisabled = Value then
    Exit;
  FHeaderDisabled := Value;
  Changed;
end;

procedure TGMInfoWindowOptions.SetMaxWidth(const Value: Integer);
begin
  if FMaxWidth = Value then
    Exit;
  FMaxWidth := Max(0, Value);
  Changed;
end;

procedure TGMInfoWindowOptions.SetMinWidth(const Value: Integer);
begin
  if FMinWidth = Value then
    Exit;
  FMinWidth := Max(0, Value);
  Changed;
end;

procedure TGMInfoWindowOptions.SetPixelOffset(
  const Value: TGMInfoWindowPixelOffset);
begin
  if not Assigned(Value) then
    Exit;

  FPixelOffset.Assign(Value);
end;

procedure TGMInfoWindowOptions.SetPosition(const Value: TGMLibLatLng);
begin
  if not Assigned(Value) then
    Exit;
  FPosition.Assign(Value);
end;

procedure TGMInfoWindowOptions.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;
  FVisible := Value;
  Changed;
end;

procedure TGMInfoWindowOptions.SetZIndex(const Value: Integer);
begin
  if FZIndex = Value then
    Exit;
  FZIndex := Value;
  Changed;
end;

function TGMInfoWindowOptions.ToJavaScriptLiteral: string;
var
  Parts: TStringList;
begin
  Parts := TStringList.Create;
  try
    Parts.Add('ariaLabel: ' + JavaScriptQuotedStr(FAriaLabel));
    Parts.Add('content: ' + JavaScriptQuotedStr(FContent));
    Parts.Add('disableAutoPan: ' + BooleanToJavaScriptLiteral(FDisableAutoPan));
    Parts.Add('headerContent: ' + JavaScriptQuotedStr(FHeaderContent));
    Parts.Add('headerDisabled: ' + BooleanToJavaScriptLiteral(FHeaderDisabled));
    if FMaxWidth > 0 then
      Parts.Add('maxWidth: ' + IntToStr(FMaxWidth));
    if FMinWidth > 0 then
      Parts.Add('minWidth: ' + IntToStr(FMinWidth));
    if not FPixelOffset.IsEmpty then
      Parts.Add('pixelOffset: ' + FPixelOffset.ToJavaScriptLiteral);
    Parts.Add('position: ' + FPosition.ToJavaScriptLiteral);
    Parts.Add('zIndex: ' + IntToStr(FZIndex));
    Result := '{ ' + JoinJavaScriptParts(Parts) + ' }';
  finally
    Parts.Free;
  end;
end;

{ TGMInfoWindowItem }

procedure TGMInfoWindowItem.Assign(Source: TPersistent);
begin
  if Source is TGMInfoWindowItem then
  begin
    OpenOptions.Assign(TGMInfoWindowItem(Source).OpenOptions);
    Options.Assign(TGMInfoWindowItem(Source).Options);
    Exit;
  end;

  inherited;
end;

function TGMInfoWindowItem.BuildApplyCommand: string;
begin
  if not Assigned(FOptions) then
    Exit('');

  if Options.Visible then
    ApplyCloseOthersBeforeOpenPolicy;

  Result := InfoWindowSetOptionsCommand(ObjectId, Options.ToJavaScriptLiteral);
  if Options.Visible then
  begin
    Result := Result + BuildOpenCommand;
    if FPendingFocus and not OpenOptions.ShouldFocus then
      Result := Result + BuildFocusCommand;
  end
  else
    Result := Result + BuildCloseCommand;

  FPendingFocus := False;
end;

procedure TGMInfoWindowItem.ApplyCloseOthersBeforeOpenPolicy;
begin
  if not (Assigned(Collection) and (Collection is TGMInfoWindows)) then
    Exit;

  if TGMInfoWindows(Collection).FClosingOthersBeforeOpen then
    Exit;

  if TGMInfoWindows(Collection).CloseOthersBeforeOpen then
    TGMInfoWindows(Collection).CloseOthers(Self);
end;

function TGMInfoWindowItem.BuildCloseCommand: string;
begin
  Result := InfoWindowCloseCommand(ObjectId);
end;

function TGMInfoWindowItem.BuildFocusCommand: string;
begin
  Result := InfoWindowFocusCommand(ObjectId);
end;

function TGMInfoWindowItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('infoWindow_%d', [FNextObjectId]));
end;

function TGMInfoWindowItem.BuildOpenCommand: string;
begin
  Result := InfoWindowOpenCommand(
    ObjectId,
    OpenOptions.AnchorObjectId,
    OpenOptions.ShouldFocus
  );
end;

function TGMInfoWindowItem.BuildRemoveCommand: string;
begin
  Result := InfoWindowRemoveCommand(ObjectId);
end;

procedure TGMInfoWindowItem.CenterMapTo;
var
  ViewportHost: IGMMapViewportHost;
begin
  if not Assigned(Collection) or not (Collection is TGMInfoWindows) then
    Exit;

  ViewportHost := TGMInfoWindows(Collection).GetViewportHost;
  if not Assigned(ViewportHost) then
    Exit;

  ViewportHost.CenterMapTo(Options.Position);
end;

procedure TGMInfoWindowItem.Close;
begin
  FIsOpen := False;
  FPendingFocus := False;
  Options.Visible := False;
end;

constructor TGMInfoWindowItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FObjectId := BuildObjectId;
  FOpenOptions := CreateOpenOptions;
{$IFDEF FPC}
  FOpenOptions.OnChange := @OpenOptionsChanged;
{$ELSE}
  FOpenOptions.OnChange := OpenOptionsChanged;
{$ENDIF}
  FOptions := CreateInfoWindowOptions;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
end;

function TGMInfoWindowItem.CreateInfoWindowOptions: TGMInfoWindowOptions;
begin
  Result := TGMInfoWindowOptions.Create;
end;

function TGMInfoWindowItem.CreateOpenOptions: TGMInfoWindowOpenOptions;
begin
  Result := TGMInfoWindowOpenOptions.Create;
end;

destructor TGMInfoWindowItem.Destroy;
begin
  if Assigned(Collection) and (Collection is TGMInfoWindows) then
    TGMInfoWindows(Collection).RegisterRemoval(ObjectId);
  FOpenOptions.Free;
  FOptions.Free;
  inherited;
end;

function TGMInfoWindowItem.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/info-window#InfoWindow';
end;

function TGMInfoWindowItem.GetAnchorObjectId: TGMObjectId;
begin
  Result := OpenOptions.AnchorObjectId;
end;

{$IFNDEF FPC}
function TGMInfoWindowItem.GetDisplayName: string;
begin
  Result := Format('InfoWindow %d', [Index]);
end;
{$ENDIF}

function TGMInfoWindowItem.GetShouldFocus: Boolean;
begin
  Result := OpenOptions.ShouldFocus;
end;

procedure TGMInfoWindowItem.Focus;
begin
  if not (Options.Visible or FIsOpen) then
    Exit;

  if OpenOptions.ShouldFocus then
    Exit;

  FPendingFocus := True;
  Changed(False);
end;

procedure TGMInfoWindowItem.Open;
begin
  FIsOpen := False;
  FPendingFocus := False;
  AnchorObjectId := '';
  ShouldFocus := False;
  Options.Visible := True;
end;

procedure TGMInfoWindowItem.Open(AAnchorMarker: TGMMarkerItem;
  AShouldFocus: Boolean);
begin
  FIsOpen := False;
  FPendingFocus := False;

  if Assigned(AAnchorMarker) then
    AnchorObjectId := AAnchorMarker.ObjectId
  else
    AnchorObjectId := '';

  ShouldFocus := AShouldFocus;
  Options.Visible := True;
end;

procedure TGMInfoWindowItem.OpenByObjectId(
  const AAnchorObjectId: TGMObjectId; AShouldFocus: Boolean);
begin
  FIsOpen := False;
  FPendingFocus := False;
  AnchorObjectId := AAnchorObjectId;
  ShouldFocus := AShouldFocus;
  Options.Visible := True;
end;

procedure TGMInfoWindowItem.OpenOptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  Changed(False);
end;

procedure TGMInfoWindowItem.OptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  Changed(False);
end;

procedure TGMInfoWindowItem.SetAnchorObjectId(const Value: TGMObjectId);
begin
  OpenOptions.AnchorObjectId := Value;
end;

procedure TGMInfoWindowItem.SetOpenOptions(const Value: TGMInfoWindowOpenOptions);
begin
  if not Assigned(Value) then
    Exit;

  FOpenOptions.Assign(Value);
end;

procedure TGMInfoWindowItem.ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
var
  HeaderDisabledValue: Boolean;
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
  LatLng: TGMLibLatLng;
  ZIndexValue: Integer;
begin
  if SameText(AEnvelope.MessageType, 'infowindow.closeclick') then
  begin
    FUpdatingFromMapMessage := True;
    try
      FIsOpen := False;
      Options.Visible := False;
    finally
      FUpdatingFromMapMessage := False;
    end;

    if Assigned(FOnCloseClick) then
      FOnCloseClick(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.close') then
  begin
    FUpdatingFromMapMessage := True;
    try
      FIsOpen := False;
      Options.Visible := False;
    finally
      FUpdatingFromMapMessage := False;
    end;

    if Assigned(FOnClose) then
      FOnClose(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.domready') then
  begin
    if Assigned(FOnDomReady) then
      FOnDomReady(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.content_changed') then
  begin
    FUpdatingFromMapMessage := True;
    try
{$IFDEF FPC}
      Options.Content := InfoWindowPayloadAsString(AEnvelope);
{$ELSE}
      Options.Content := AEnvelope.PayloadAsString;
{$ENDIF}
    finally
      FUpdatingFromMapMessage := False;
    end;

    if Assigned(FOnContentChanged) then
      FOnContentChanged(Self, Options.Content);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.headercontent_changed') then
  begin
    FUpdatingFromMapMessage := True;
    try
{$IFDEF FPC}
      Options.HeaderContent := InfoWindowPayloadAsString(AEnvelope);
{$ELSE}
      Options.HeaderContent := AEnvelope.PayloadAsString;
{$ENDIF}
    finally
      FUpdatingFromMapMessage := False;
    end;

    if Assigned(FOnHeaderContentChanged) then
      FOnHeaderContentChanged(Self, Options.HeaderContent);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.headerdisabled_changed') then
  begin
{$IFDEF FPC}
    HeaderDisabledValue := SameText(InfoWindowPayloadAsString(AEnvelope), 'true');
{$ELSE}
    JsonValue := TJSONObject.ParseJSONValue(AEnvelope.Payload);
    try
      if JsonValue is TJSONBool then
        HeaderDisabledValue := TJSONBool(JsonValue).AsBoolean
      else
        HeaderDisabledValue := SameText(AEnvelope.PayloadAsString, 'true');
    finally
      JsonValue.Free;
    end;
{$ENDIF}

    FUpdatingFromMapMessage := True;
    try
      Options.HeaderDisabled := HeaderDisabledValue;
    finally
      FUpdatingFromMapMessage := False;
    end;

    if Assigned(FOnHeaderDisabledChanged) then
      FOnHeaderDisabledChanged(Self, Options.HeaderDisabled);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.visible') then
  begin
    FUpdatingFromMapMessage := True;
    try
      FIsOpen := True;
      Options.Visible := True;
    finally
      FUpdatingFromMapMessage := False;
    end;

    if Assigned(FOnVisible) then
      FOnVisible(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.zindex_changed') then
  begin
{$IFDEF FPC}
    ZIndexValue := StrToIntDef(InfoWindowPayloadAsString(AEnvelope), Options.ZIndex);
{$ELSE}
    ZIndexValue := StrToIntDef(AEnvelope.PayloadAsString, Options.ZIndex);
{$ENDIF}

    FUpdatingFromMapMessage := True;
    try
      Options.ZIndex := ZIndexValue;
    finally
      FUpdatingFromMapMessage := False;
    end;

    if Assigned(FOnZIndexChanged) then
      FOnZIndexChanged(Self, Options.ZIndex);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'infowindow.position_changed') then
  begin
    LatLng := nil;
    if TryApplyPositionFromPayload(AEnvelope.Payload, LatLng) then
    begin
      try
        if Assigned(FOnPositionChanged) then
          FOnPositionChanged(Self, Options.Position);
      finally
        LatLng.Free;
      end;
    end;
  end;
end;

procedure TGMInfoWindowItem.SetOptions(const Value: TGMInfoWindowOptions);
begin
  if not Assigned(Value) then
    Exit;
  FOptions.Assign(Value);
end;

procedure TGMInfoWindowItem.SetShouldFocus(const Value: Boolean);
begin
  OpenOptions.ShouldFocus := Value;
end;

function TGMInfoWindowItem.TryApplyPositionFromPayload(const APayload: string;
  out ALatLng: TGMLibLatLng): Boolean;
var
  JsonObject: TJSONObject;
{$IFDEF FPC}
  JsonValue: TJSONData;
{$ELSE}
  JsonValue: TJSONValue;
{$ENDIF}
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
    ALatLng := TGMLibLatLng.Create(
      JsonObject.Find('lat').AsFloat,
      JsonObject.Find('lng').AsFloat
    );
{$ELSE}
    ALatLng := TGMLibLatLng.Create(
      JsonObject.GetValue<Double>('lat', 0),
      JsonObject.GetValue<Double>('lng', 0)
    );
{$ENDIF}

    FUpdatingFromMapMessage := True;
    try
      Options.Position.Assign(ALatLng);
    finally
      FUpdatingFromMapMessage := False;
    end;

    Result := True;
  finally
    JsonValue.Free;
  end;
end;

{ TGMInfoWindows }

function TGMInfoWindows.Add: TGMInfoWindowItem;
begin
  Result := TGMInfoWindowItem(inherited Add);
end;

procedure TGMInfoWindows.DetachAnchorFromMarker(
  const AMarkerObjectId: TGMObjectId);
begin
  DetachAnchorFromObject(AMarkerObjectId);
end;

procedure TGMInfoWindows.DetachAnchorFromObject(const AObjectId: TGMObjectId);
var
  i: Integer;
  InfoWindow: TGMInfoWindowItem;
begin
  if AObjectId = '' then
    Exit;

  for i := 0 to Count - 1 do
  begin
    InfoWindow := Items[i];
    if not SameText(string(InfoWindow.AnchorObjectId), string(AObjectId)) then
      Continue;

    InfoWindow.AnchorObjectId := '';
    if InfoWindow.Options.Visible then
      InfoWindow.Close;
  end;
end;

procedure TGMInfoWindows.Assign(Source: TPersistent);
var
  i: Integer;
  NewItem: TGMInfoWindowItem;
  SourceItems: TGMInfoWindows;
begin
  if Source is TGMInfoWindows then
  begin
    SourceItems := TGMInfoWindows(Source);
    FCloseOthersBeforeOpen := SourceItems.CloseOthersBeforeOpen;
    Clear;
    BeginUpdate;
    try
      for i := 0 to SourceItems.Count - 1 do
      begin
        NewItem := Add;
        NewItem.Assign(SourceItems[i]);
      end;
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited;
end;

procedure TGMInfoWindows.CloseOthers(AExcept: TGMInfoWindowItem);
var
  i: Integer;
begin
  if FClosingOthersBeforeOpen then
    Exit;

  FClosingOthersBeforeOpen := True;
  BeginUpdate;
  try
    for i := 0 to Count - 1 do
    begin
      if Items[i] = AExcept then
        Continue;

      if Items[i].Options.Visible or Items[i].IsOpen then
        Items[i].Close;
    end;
  finally
    EndUpdate;
    FClosingOthersBeforeOpen := False;
  end;
end;

procedure TGMInfoWindows.ClearPendingRemovals;
begin
  FPendingRemovals.Clear;
end;

constructor TGMInfoWindows.Create(AOwner: TPersistent; AItemClass: TGMInfoWindowItemClass);
begin
  if not Assigned(AItemClass) then
    AItemClass := TGMInfoWindowItem;
  inherited Create(AOwner, AItemClass);
{$IFDEF FPC}
  FPendingRemovals := specialize TList<TGMObjectId>.Create;
{$ELSE}
  FPendingRemovals := TList<TGMObjectId>.Create;
{$ENDIF}
end;

destructor TGMInfoWindows.Destroy;
begin
  inherited;
  FPendingRemovals.Free;
end;

function TGMInfoWindows.FindByObjectId(const AObjectId: TGMObjectId): TGMInfoWindowItem;
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

function TGMInfoWindows.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/info-window';
end;

function TGMInfoWindows.GetViewportHost: IGMMapViewportHost;
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

function TGMInfoWindows.GetItem(Index: Integer): TGMInfoWindowItem;
begin
  Result := TGMInfoWindowItem(inherited Items[Index]);
end;

procedure TGMInfoWindows.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMInfoWindows.RegisterRemoval(const AObjectId: TGMObjectId);
begin
  if AObjectId = '' then
    Exit;
  if not FPendingRemovals.Contains(AObjectId) then
    FPendingRemovals.Add(AObjectId);
end;

procedure TGMInfoWindows.SetItem(Index: Integer; const Value: TGMInfoWindowItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

procedure TGMInfoWindows.Update(Item: TCollectionItem);
begin
  inherited;
  if Item = nil then
    Exit;
  NotifyChange;
end;

end.




