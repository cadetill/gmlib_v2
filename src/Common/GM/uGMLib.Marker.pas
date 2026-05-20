{**
  @abstract(Modelo de colección de marcadores del mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define `TGMMarkers` como colección publicada del mapa y
  `TGMMarkerItem` como item individual. La sincronización con JavaScript la
  coordina `TGMMap`, que posee esta colección.
}
unit uGMLib.Marker;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  DB,
  fpjson,
  jsonparser,
  Math,
  SysUtils,
  Generics.Collections,
{$ELSE}
  System.Classes,
  Data.DB,
  System.JSON,
  System.Math,
  System.SysUtils,
  System.Generics.Collections,
{$ENDIF}
  uMapLib.Core.ApiObject,
  uMapLib.Core.Messages,
  uGMLib.Core.Types,
  uGMLib.Google.Types,
  uGMLib.Platform.Format;

type
  TGMPinOptions = class;
  TGMHtmlMarkerOptions = class;
  TGMLabelMarkerOptions = class;
  TGMMarkerOptions = class;
  TGMMarkerItem = class;

  TGMMarkerSeed = record
    Latitude: Double;
    Longitude: Double;
    Title: string;
    Visible: Boolean;
{$IFNDEF FPC}
    class function Create(ALatitude, ALongitude: Double; const ATitle: string = '';
      AVisible: Boolean = True): TGMMarkerSeed; static;
{$ENDIF}
  end;

  TGMMarkerPositionEvent = procedure(Sender: TObject; ALatLng: TMapLibLatLng) of object;
  TGMMarkerItemClass = class of TGMMarkerItem;

  {** @abstract(Configuración común del contenido `PinElement` del marker.) }
  TGMPinOptions = class(TMapLibApiObject)
  private
    FBackgroundCss: string;
    FBorderColorCss: string;
    FGlyphColorCss: string;
    FGlyphText: string;
    FScale: Double;
    procedure SetBackgroundCss(const Value: string);
    procedure SetBorderColorCss(const Value: string);
    procedure SetGlyphColorCss(const Value: string);
    procedure SetGlyphText(const Value: string);
    procedure SetScale(const Value: Double);
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    function ToJavaScriptLiteral: string;
    property BackgroundCss: string read FBackgroundCss write SetBackgroundCss;
    property BorderColorCss: string read FBorderColorCss write SetBorderColorCss;
    property GlyphColorCss: string read FGlyphColorCss write SetGlyphColorCss;
  published
    property APIUrl;
    property GlyphText: string read FGlyphText write SetGlyphText;
    property Scale: Double read FScale write SetScale;
  end;

  {** @abstract(Contenido HTML libre para `AdvancedMarkerElement`.) }
  TGMHtmlMarkerOptions = class(TMapLibApiObject)
  private
    FCssClassName: string;
    FHtml: string;
    procedure SetCssClassName(const Value: string);
    procedure SetHtml(const Value: string);
  protected
    function GetAPIUrl: string; override;
  public
    procedure Assign(Source: TPersistent); override;
    function ToJavaScriptLiteral: string;
  published
    property APIUrl;
    property CssClassName: string read FCssClassName write SetCssClassName;
    property Html: string read FHtml write SetHtml;
  end;

  {** @abstract(Contenido tipado tipo label/badge para `AdvancedMarkerElement`.) }
  TGMLabelMarkerOptions = class(TMapLibApiObject)
  private
    FBackgroundCss: string;
    FBorderColorCss: string;
    FCornerRadius: Integer;
    FCssClassName: string;
    FFontSize: Integer;
    FFontBold: Boolean;
    FPaddingHorizontal: Integer;
    FPaddingVertical: Integer;
    FText: string;
    FTextColorCss: string;
    procedure SetBackgroundCss(const Value: string);
    procedure SetBorderColorCss(const Value: string);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetCssClassName(const Value: string);
    procedure SetFontBold(const Value: Boolean);
    procedure SetFontSize(const Value: Integer);
    procedure SetPaddingHorizontal(const Value: Integer);
    procedure SetPaddingVertical(const Value: Integer);
    procedure SetText(const Value: string);
    procedure SetTextColorCss(const Value: string);
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    function ToJavaScriptLiteral: string;
    property BackgroundCss: string read FBackgroundCss write SetBackgroundCss;
    property BorderColorCss: string read FBorderColorCss write SetBorderColorCss;
    property TextColorCss: string read FTextColorCss write SetTextColorCss;
  published
    property APIUrl;
    property CssClassName: string read FCssClassName write SetCssClassName;
    property Text: string read FText write SetText;
    property PaddingHorizontal: Integer read FPaddingHorizontal write SetPaddingHorizontal default 12;
    property PaddingVertical: Integer read FPaddingVertical write SetPaddingVertical default 8;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 14;
    property FontSize: Integer read FFontSize write SetFontSize default 13;
    property FontBold: Boolean read FFontBold write SetFontBold default True;
  end;

  {** @abstract(Bloque inicial de opciones neutrales para `AdvancedMarkerElement`.) }
  TGMMarkerOptions = class(TMapLibApiObject)
  private
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FClickable: Boolean;
    FCollisionBehavior: TGMCollisionBehavior;
    FContentMode: TGMMarkerContentMode;
    FDraggable: Boolean;
    FHtmlOptions: TGMHtmlMarkerOptions;
    FLabelOptions: TGMLabelMarkerOptions;
    FPinOptions: TGMPinOptions;
    FPosition: TMapLibLatLng;
    FTitle: string;
    FVisible: Boolean;
    FZIndex: Integer;
    procedure SetClickable(const Value: Boolean);
    procedure SetCollisionBehavior(const Value: TGMCollisionBehavior);
    procedure SetContentMode(const Value: TGMMarkerContentMode);
    procedure SetDraggable(const Value: Boolean);
    procedure HtmlOptionsChanged(Sender: TObject);
    procedure SetHtmlOptions(const Value: TGMHtmlMarkerOptions);
    procedure LabelOptionsChanged(Sender: TObject);
    procedure SetLabelOptions(const Value: TGMLabelMarkerOptions);
    procedure PinOptionsChanged(Sender: TObject);
    procedure SetPinOptions(const Value: TGMPinOptions);
    procedure PositionChanged(Sender: TObject);
    procedure SetPosition(const Value: TMapLibLatLng);
    procedure SetTitle(const Value: string);
    procedure SetVisible(const Value: Boolean);
    procedure SetZIndex(const Value: Integer);
  protected
    procedure Changed; override;
    function BuildCollisionBehaviorValue: string;
    function BuildContentModeValue: string;
    function CreateHtmlOptions: TGMHtmlMarkerOptions; virtual;
    function CreateLabelOptions: TGMLabelMarkerOptions; virtual;
    function CreatePinOptions: TGMPinOptions; virtual;
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure Assign(Source: TPersistent); override;
    procedure EndUpdate;
    {** @abstract(Serializa las opciones minimas del marker a literal JavaScript.) }
    function ToJavaScriptLiteral: string;
  published
    property APIUrl;
    {** @abstract(Indica si el marcador debe responder a clicks.) }
    property Clickable: Boolean read FClickable write SetClickable default True;
    {** @abstract(Define cómo compite el marcador cuando colisiona con otros.) }
    property CollisionBehavior: TGMCollisionBehavior read FCollisionBehavior write SetCollisionBehavior default cbRequired;
    {** @abstract(Selecciona el modo de contenido visual del marker.) }
    property ContentMode: TGMMarkerContentMode read FContentMode write SetContentMode default mcmDefault;
    {** @abstract(Indica si el usuario puede arrastrar el marcador.) }
    property Draggable: Boolean read FDraggable write SetDraggable default False;
    {** @abstract(Contenido HTML libre usado cuando `ContentMode = mcmHtml`.) }
    property HtmlOptions: TGMHtmlMarkerOptions read FHtmlOptions write SetHtmlOptions;
    {** @abstract(Contenido tipado tipo label usado cuando `ContentMode = mcmLabel`.) }
    property LabelOptions: TGMLabelMarkerOptions read FLabelOptions write SetLabelOptions;
    {** @abstract(Configuración del contenido tipo pin del marker.) }
    property PinOptions: TGMPinOptions read FPinOptions write SetPinOptions;
    {** @abstract(Posicion actual del marcador.) }
    property Position: TMapLibLatLng read FPosition write SetPosition;
    {** @abstract(Titulo accesible del marcador.) }
    property Title: string read FTitle write SetTitle;
    {** @abstract(Indica si el marcador debe mostrarse en el mapa.) }
    property Visible: Boolean read FVisible write SetVisible default True;
    {** @abstract(Orden de apilado del marcador.) }
    property ZIndex: Integer read FZIndex write SetZIndex default 0;
  end;

  {** @abstract(Item de colección para representar un marcador del mapa.) }
  TGMMarkerItem = class(TCollectionItem)
  private
    class var FNextObjectId: Integer;
  private
    FOnMouseDown: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseUp: TNotifyEvent;
    FOnDrag: TGMMarkerPositionEvent;
    FOnDragStart: TGMMarkerPositionEvent;
    FObjectId: TGMObjectId;
    FOnClick: TNotifyEvent;
    FOnDragEnd: TGMMarkerPositionEvent;
    FOptions: TGMMarkerOptions;
    FUpdatingFromMapMessage: Boolean;
    FNeedsSync: Boolean;
    function TryApplyPositionFromPayload(const APayload: string; out ALatLng: TMapLibLatLng): Boolean;
    procedure OptionsChanged(Sender: TObject);
    procedure SetOptions(const Value: TGMMarkerOptions);
    function IsInitialized: Boolean;
  protected
    function BuildObjectId: TGMObjectId; virtual;
    function CreateMarkerOptions: TGMMarkerOptions; virtual;
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
    function NeedsSync: Boolean;
    procedure ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
    property ObjectId: TGMObjectId read FObjectId;
  published
    property APIUrl: string read GetAPIUrl;
    {** @abstract(Bloque de opciones del marcador.) }
    property Options: TGMMarkerOptions read FOptions write SetOptions;
    {** @abstract(Evento disparado cuando el usuario pulsa el marcador.) }
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    {** @abstract(Evento disparado al iniciar el arrastre de un marcador.) }
    property OnDragStart: TGMMarkerPositionEvent read FOnDragStart write FOnDragStart;
    {** @abstract(Evento disparado mientras el usuario arrastra un marcador.) }
    property OnDrag: TGMMarkerPositionEvent read FOnDrag write FOnDrag;
    {** @abstract(Evento disparado al finalizar el arrastre de un marcador.) }
    property OnDragEnd: TGMMarkerPositionEvent read FOnDragEnd write FOnDragEnd;
    {** @abstract(Evento disparado cuando el puntero entra en el marcador.) }
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    {** @abstract(Evento disparado cuando el puntero sale del marcador.) }
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    {** @abstract(Evento disparado al presionar el ratón sobre el marcador.) }
    property OnMouseDown: TNotifyEvent read FOnMouseDown write FOnMouseDown;
    {** @abstract(Evento disparado al soltar el ratón sobre el marcador.) }
    property OnMouseUp: TNotifyEvent read FOnMouseUp write FOnMouseUp;
  end;

  {** @abstract(Colección publicada por `TGMMap` para gestionar múltiples marcadores.) }
  TGMMarkers = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
{$IFDEF FPC}
    FPendingRemovals: specialize TList<TGMObjectId>;
{$ELSE}
    FPendingRemovals: TList<TGMObjectId>;
{$ENDIF}
    function GetItem(Index: Integer): TGMMarkerItem;
    procedure SetItem(Index: Integer; const Value: TGMMarkerItem);
  protected
    function GetAPIUrl: string; virtual;
    function GetViewportHost: IGMMapViewportHost;
    procedure NotifyChange;
    procedure RegisterRemoval(const AObjectId: TGMObjectId);
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TGMMarkerItemClass = nil);
    destructor Destroy; override;
    function Add: TGMMarkerItem; overload;
    function Add(ALatitude, ALongitude: Double; const ATitle: string = ''): TGMMarkerItem; overload;
    function FindByObjectId(const AObjectId: TGMObjectId): TGMMarkerItem;
    function TryGetBounds(out ANorth, ASouth, AEast, AWest: Double;
      AVisibleOnly: Boolean = True; AItemIndex: Integer = -1): Boolean;
    procedure Assign(Source: TPersistent); override;
    procedure ClearPendingRemovals;
    procedure LoadFromArray(const AItems: array of TGMMarkerSeed;
      AClearBeforeLoad: Boolean = True);
    procedure LoadFromCSV(const ACSVText: string; const ALatField, ALongField: string;
      const ATitleField: string = ''; const AVisibleField: string = '';
      ADelimiter: Char = ','; AClearBeforeLoad: Boolean = True);
    procedure LoadFromDataSet(ADataSet: TDataSet; const ALatField, ALongField: string;
      const ATitleField: string = ''; const AVisibleField: string = '';
      AClearBeforeLoad: Boolean = True);
    procedure ZoomToPoints(AVisibleOnly: Boolean = True; AItemIndex: Integer = -1);
    property APIUrl: string read GetAPIUrl;
    property Items[Index: Integer]: TGMMarkerItem read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
{$IFDEF FPC}
    property PendingRemovals: specialize TList<TGMObjectId> read FPendingRemovals;
{$ELSE}
    property PendingRemovals: TList<TGMObjectId> read FPendingRemovals;
{$ENDIF}
  end;

implementation

{ TGMMarkerSeed }

{$IFDEF FPC}
function GMLibMarkerSeedCreate(ALatitude, ALongitude: Double; const ATitle: string;
  AVisible: Boolean): TGMMarkerSeed;
begin
  Result.Latitude := ALatitude;
  Result.Longitude := ALongitude;
  Result.Title := ATitle;
  Result.Visible := AVisible;
end;
{$ELSE}
class function TGMMarkerSeed.Create(ALatitude, ALongitude: Double;
  const ATitle: string; AVisible: Boolean): TGMMarkerSeed;
begin
  Result.Latitude := ALatitude;
  Result.Longitude := ALongitude;
  Result.Title := ATitle;
  Result.Visible := AVisible;
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

function MarkerRemoveCommand(const AObjectId: TGMObjectId): string;
begin
  Result := Format('gmlib.marker.remove(%s);', [QuotedStr(string(AObjectId))]);
end;

function MarkerSetOptionsCommand(const AObjectId: TGMObjectId; const AOptionsLiteral: string): string;
begin
  Result := Format(
    'gmlib.marker.setOptions(%s, %s);',
    [QuotedStr(string(AObjectId)), AOptionsLiteral]
  );
end;

function SplitCsvLine(const ALine: string; ADelimiter: Char): TStrings;
begin
  Result := TStringList.Create;
  Result.StrictDelimiter := True;
  Result.Delimiter := ADelimiter;
  Result.QuoteChar := '"';
  Result.DelimitedText := ALine;
end;

function IndexOfText(const AStrings: TStrings; const AValue: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  if not Assigned(AStrings) then
    Exit;

  for i := 0 to AStrings.Count - 1 do
    if SameText(Trim(AStrings[i]), AValue) then
      Exit(i);
end;

function TryParseMarkerVisible(const AValue: string; out AVisible: Boolean): Boolean;
begin
  Result := True;
  if SameText(Trim(AValue), '') then
  begin
    AVisible := True;
    Exit;
  end;

  if SameText(Trim(AValue), '1') or SameText(Trim(AValue), 'true') or SameText(Trim(AValue), 'yes') or SameText(Trim(AValue), 'y') then
  begin
    AVisible := True;
    Exit;
  end;

  if SameText(Trim(AValue), '0') or SameText(Trim(AValue), 'false') or SameText(Trim(AValue), 'no') or SameText(Trim(AValue), 'n') then
  begin
    AVisible := False;
    Exit;
  end;

  Result := False;
end;

{ TGMPinOptions }

procedure TGMPinOptions.Assign(Source: TPersistent);
begin
  if Source is TGMPinOptions then
  begin
    BackgroundCss := TGMPinOptions(Source).BackgroundCss;
    BorderColorCss := TGMPinOptions(Source).BorderColorCss;
    GlyphColorCss := TGMPinOptions(Source).GlyphColorCss;
    GlyphText := TGMPinOptions(Source).GlyphText;
    Scale := TGMPinOptions(Source).Scale;
    Exit;
  end;

  inherited;
end;

constructor TGMPinOptions.Create;
begin
  inherited;
  FScale := 1.0;
end;

function TGMPinOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/advanced-markers#PinElementOptions';
end;

procedure TGMPinOptions.SetBackgroundCss(const Value: string);
begin
  if SameText(FBackgroundCss, Value) then
    Exit;

  FBackgroundCss := Value;
  Changed;
end;

procedure TGMPinOptions.SetBorderColorCss(const Value: string);
begin
  if SameText(FBorderColorCss, Value) then
    Exit;

  FBorderColorCss := Value;
  Changed;
end;

procedure TGMPinOptions.SetGlyphColorCss(const Value: string);
begin
  if SameText(FGlyphColorCss, Value) then
    Exit;

  FGlyphColorCss := Value;
  Changed;
end;

procedure TGMPinOptions.SetGlyphText(const Value: string);
begin
  if FGlyphText = Value then
    Exit;

  FGlyphText := Value;
  Changed;
end;

procedure TGMPinOptions.SetScale(const Value: Double);
begin
  if SameValue(FScale, Value) then
    Exit;

  FScale := Value;
  Changed;
end;

function TGMPinOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{ background: %s, borderColor: %s, glyphColor: %s, glyphText: %s, scale: %s }',
    [
      JavaScriptQuotedStr(BackgroundCss),
      JavaScriptQuotedStr(BorderColorCss),
      JavaScriptQuotedStr(GlyphColorCss),
      JavaScriptQuotedStr(GlyphText),
      FloatToStr(Scale, GMLibInvariantFormatSettings)
    ]
  );
end;

{ TGMHtmlMarkerOptions }

procedure TGMHtmlMarkerOptions.Assign(Source: TPersistent);
begin
  if Source is TGMHtmlMarkerOptions then
  begin
    CssClassName := TGMHtmlMarkerOptions(Source).CssClassName;
    Html := TGMHtmlMarkerOptions(Source).Html;
    Exit;
  end;

  inherited;
end;

function TGMHtmlMarkerOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/advanced-markers#AdvancedMarkerElementOptions.content';
end;

procedure TGMHtmlMarkerOptions.SetCssClassName(const Value: string);
begin
  if FCssClassName = Value then
    Exit;

  FCssClassName := Value;
  Changed;
end;

procedure TGMHtmlMarkerOptions.SetHtml(const Value: string);
begin
  if FHtml = Value then
    Exit;

  FHtml := Value;
  Changed;
end;

function TGMHtmlMarkerOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{ cssClassName: %s, html: %s }',
    [JavaScriptQuotedStr(CssClassName), JavaScriptQuotedStr(Html)]
  );
end;

{ TGMLabelMarkerOptions }

procedure TGMLabelMarkerOptions.Assign(Source: TPersistent);
begin
  if Source is TGMLabelMarkerOptions then
  begin
    BackgroundCss := TGMLabelMarkerOptions(Source).BackgroundCss;
    BorderColorCss := TGMLabelMarkerOptions(Source).BorderColorCss;
    CornerRadius := TGMLabelMarkerOptions(Source).CornerRadius;
    CssClassName := TGMLabelMarkerOptions(Source).CssClassName;
    FontBold := TGMLabelMarkerOptions(Source).FontBold;
    FontSize := TGMLabelMarkerOptions(Source).FontSize;
    PaddingHorizontal := TGMLabelMarkerOptions(Source).PaddingHorizontal;
    PaddingVertical := TGMLabelMarkerOptions(Source).PaddingVertical;
    Text := TGMLabelMarkerOptions(Source).Text;
    TextColorCss := TGMLabelMarkerOptions(Source).TextColorCss;
    Exit;
  end;

  inherited;
end;

constructor TGMLabelMarkerOptions.Create;
begin
  inherited;
  FPaddingHorizontal := 12;
  FPaddingVertical := 8;
  FCornerRadius := 14;
  FFontSize := 13;
  FFontBold := True;
end;

function TGMLabelMarkerOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/advanced-markers#AdvancedMarkerElementOptions.content';
end;

procedure TGMLabelMarkerOptions.SetBackgroundCss(const Value: string);
begin
  if SameText(FBackgroundCss, Value) then
    Exit;

  FBackgroundCss := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetBorderColorCss(const Value: string);
begin
  if SameText(FBorderColorCss, Value) then
    Exit;

  FBorderColorCss := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then
    Exit;

  FCornerRadius := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetCssClassName(const Value: string);
begin
  if FCssClassName = Value then
    Exit;

  FCssClassName := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetFontBold(const Value: Boolean);
begin
  if FFontBold = Value then
    Exit;

  FFontBold := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetFontSize(const Value: Integer);
begin
  if FFontSize = Value then
    Exit;

  FFontSize := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetPaddingHorizontal(const Value: Integer);
begin
  if FPaddingHorizontal = Value then
    Exit;

  FPaddingHorizontal := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetPaddingVertical(const Value: Integer);
begin
  if FPaddingVertical = Value then
    Exit;

  FPaddingVertical := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetText(const Value: string);
begin
  if FText = Value then
    Exit;

  FText := Value;
  Changed;
end;

procedure TGMLabelMarkerOptions.SetTextColorCss(const Value: string);
begin
  if SameText(FTextColorCss, Value) then
    Exit;

  FTextColorCss := Value;
  Changed;
end;

function TGMLabelMarkerOptions.ToJavaScriptLiteral: string;
begin
  Result := Format(
    '{ cssClassName: %s, text: %s, background: %s, borderColor: %s, textColor: %s, paddingHorizontal: %d, paddingVertical: %d, cornerRadius: %d, fontSize: %d, fontBold: %s }',
    [
      JavaScriptQuotedStr(CssClassName),
      JavaScriptQuotedStr(Text),
      JavaScriptQuotedStr(BackgroundCss),
      JavaScriptQuotedStr(BorderColorCss),
      JavaScriptQuotedStr(TextColorCss),
      PaddingHorizontal,
      PaddingVertical,
      CornerRadius,
      FontSize,
      LowerCase(BoolToStr(FontBold, True))
    ]
  );
end;

{ TGMMarkerOptions }

procedure TGMMarkerOptions.Assign(Source: TPersistent);
begin
  if Source is TGMMarkerOptions then
  begin
    BeginUpdate;
    try
    Clickable := TGMMarkerOptions(Source).Clickable;
    CollisionBehavior := TGMMarkerOptions(Source).CollisionBehavior;
    ContentMode := TGMMarkerOptions(Source).ContentMode;
    Draggable := TGMMarkerOptions(Source).Draggable;
    HtmlOptions.Assign(TGMMarkerOptions(Source).HtmlOptions);
    LabelOptions.Assign(TGMMarkerOptions(Source).LabelOptions);
    PinOptions.Assign(TGMMarkerOptions(Source).PinOptions);
    Position.Assign(TGMMarkerOptions(Source).Position);
    Title := TGMMarkerOptions(Source).Title;
    Visible := TGMMarkerOptions(Source).Visible;
    ZIndex := TGMMarkerOptions(Source).ZIndex;
    finally
      EndUpdate;
    end;
    Exit;
  end;

  inherited;
end;

constructor TGMMarkerOptions.Create;
begin
  inherited;
  FClickable := True;
  FCollisionBehavior := cbRequired;
  FContentMode := mcmDefault;
  FDraggable := False;
  FHtmlOptions := CreateHtmlOptions;
{$IFDEF FPC}
  FHtmlOptions.OnChange := @HtmlOptionsChanged;
{$ELSE}
  FHtmlOptions.OnChange := HtmlOptionsChanged;
{$ENDIF}
  FLabelOptions := CreateLabelOptions;
{$IFDEF FPC}
  FLabelOptions.OnChange := @LabelOptionsChanged;
{$ELSE}
  FLabelOptions.OnChange := LabelOptionsChanged;
{$ENDIF}
  FPinOptions := CreatePinOptions;
{$IFDEF FPC}
  FPinOptions.OnChange := @PinOptionsChanged;
{$ELSE}
  FPinOptions.OnChange := PinOptionsChanged;
{$ENDIF}
  FPosition := TMapLibLatLng.Create(0, 0);
{$IFDEF FPC}
  FPosition.OnChange := @PositionChanged;
{$ELSE}
  FPosition.OnChange := PositionChanged;
{$ENDIF}
  FVisible := True;
  FZIndex := 0;
end;

procedure TGMMarkerOptions.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

destructor TGMMarkerOptions.Destroy;
begin
  FHtmlOptions.Free;
  FLabelOptions.Free;
  FPinOptions.Free;
  FPosition.Free;
  inherited;
end;

procedure TGMMarkerOptions.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

function TGMMarkerOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/advanced-markers#AdvancedMarkerElementOptions';
end;

function TGMMarkerOptions.BuildCollisionBehaviorValue: string;
begin
  case FCollisionBehavior of
    cbOptionalAndHidesLowerPriority:
      Result := 'google.maps.CollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY';
    cbRequiredAndHidesOptional:
      Result := 'google.maps.CollisionBehavior.REQUIRED_AND_HIDES_OPTIONAL';
  else
    Result := 'google.maps.CollisionBehavior.REQUIRED';
  end;
end;

function TGMMarkerOptions.BuildContentModeValue: string;
begin
  case FContentMode of
    mcmPin:
      Result := 'pin';
    mcmHtml:
      Result := 'html';
    mcmLabel:
      Result := 'label';
  else
    Result := 'default';
  end;
end;

function TGMMarkerOptions.CreateHtmlOptions: TGMHtmlMarkerOptions;
begin
  Result := TGMHtmlMarkerOptions.Create;
end;

function TGMMarkerOptions.CreateLabelOptions: TGMLabelMarkerOptions;
begin
  Result := TGMLabelMarkerOptions.Create;
end;

function TGMMarkerOptions.CreatePinOptions: TGMPinOptions;
begin
  Result := TGMPinOptions.Create;
end;

procedure TGMMarkerOptions.SetClickable(const Value: Boolean);
begin
  if FClickable = Value then
    Exit;

  FClickable := Value;
  Changed;
end;

procedure TGMMarkerOptions.SetCollisionBehavior(
  const Value: TGMCollisionBehavior);
begin
  if FCollisionBehavior = Value then
    Exit;

  FCollisionBehavior := Value;
  Changed;
end;

procedure TGMMarkerOptions.SetContentMode(const Value: TGMMarkerContentMode);
begin
  if FContentMode = Value then
    Exit;

  FContentMode := Value;
  Changed;
end;

procedure TGMMarkerOptions.SetDraggable(const Value: Boolean);
begin
  if FDraggable = Value then
    Exit;

  FDraggable := Value;
  Changed;
end;

procedure TGMMarkerOptions.HtmlOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMarkerOptions.LabelOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMarkerOptions.PinOptionsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMarkerOptions.SetHtmlOptions(const Value: TGMHtmlMarkerOptions);
begin
  if not Assigned(Value) then
    Exit;

  FHtmlOptions.Assign(Value);
  Changed;
end;

procedure TGMMarkerOptions.SetLabelOptions(const Value: TGMLabelMarkerOptions);
begin
  if not Assigned(Value) then
    Exit;

  FLabelOptions.Assign(Value);
  Changed;
end;

procedure TGMMarkerOptions.SetPinOptions(const Value: TGMPinOptions);
begin
  if not Assigned(Value) then
    Exit;

  FPinOptions.Assign(Value);
  Changed;
end;

procedure TGMMarkerOptions.PositionChanged(Sender: TObject);
begin
  Changed;
end;

procedure TGMMarkerOptions.SetPosition(const Value: TMapLibLatLng);
begin
  if not Assigned(Value) then
    Exit;

  if FPosition.Equals(Value) then
    Exit;

  FPosition.Assign(Value);
  Changed;
end;

procedure TGMMarkerOptions.SetTitle(const Value: string);
begin
  if FTitle = Value then
    Exit;

  FTitle := Value;
  Changed;
end;

procedure TGMMarkerOptions.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  Changed;
end;

procedure TGMMarkerOptions.SetZIndex(const Value: Integer);
begin
  if FZIndex = Value then
    Exit;

  FZIndex := Value;
  Changed;
end;

procedure TGMMarkerOptions.EndUpdate;
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

function TGMMarkerOptions.ToJavaScriptLiteral: string;
var
  First: Boolean;

  procedure AddPart(const Part: string);
  begin
    if not First then
      Result := Result + ', ';
    Result := Result + Part;
    First := False;
  end;
begin
  Result := '';
  First := True;

  AddPart('position: ' + Position.ToJavaScriptLiteral);
  AddPart('visible: ' + LowerCase(BoolToStr(Visible, True)));
  AddPart('gmpClickable: ' + LowerCase(BoolToStr(Clickable, True)));
  AddPart('gmpDraggable: ' + LowerCase(BoolToStr(Draggable, True)));
  AddPart('zIndex: ' + IntToStr(ZIndex));

  if Title <> '' then
    AddPart('title: ' + JavaScriptQuotedStr(Title));
  if CollisionBehavior <> cbRequired then
    AddPart('collisionBehavior: ' + BuildCollisionBehaviorValue);
  if ContentMode <> mcmDefault then
    AddPart('contentMode: ' + JavaScriptQuotedStr(BuildContentModeValue));

  if (HtmlOptions.CssClassName <> '') or (HtmlOptions.Html <> '') then
    AddPart('htmlOptions: ' + HtmlOptions.ToJavaScriptLiteral);
  if (LabelOptions.Text <> '') or (LabelOptions.CssClassName <> '') then
    AddPart('labelOptions: ' + LabelOptions.ToJavaScriptLiteral);
  if (PinOptions.GlyphText <> '') or (PinOptions.BackgroundCss <> '') or
     (PinOptions.BorderColorCss <> '') or (PinOptions.GlyphColorCss <> '') or
     not SameValue(PinOptions.Scale, 1.0) then
    AddPart('pinOptions: ' + PinOptions.ToJavaScriptLiteral);

  Result := '{ ' + Result + ' }';
end;

{ TGMMarkerItem }

procedure TGMMarkerItem.Assign(Source: TPersistent);
begin
  if Source is TGMMarkerItem then
  begin
    Options.Assign(TGMMarkerItem(Source).Options);
    Exit;
  end;

  inherited;
end;

function TGMMarkerItem.BuildApplyCommand: string;
begin
  if not IsInitialized then
    Exit('');

  if not Options.Visible then
  begin
    Result := BuildRemoveCommand;
    FNeedsSync := False;
    Exit;
  end;

  Result := MarkerSetOptionsCommand(ObjectId, Options.ToJavaScriptLiteral);
  FNeedsSync := False;
end;

function TGMMarkerItem.BuildObjectId: TGMObjectId;
begin
  Inc(FNextObjectId);
  Result := TGMObjectId(Format('marker_%d', [FNextObjectId]));
end;

function TGMMarkerItem.CreateMarkerOptions: TGMMarkerOptions;
begin
  Result := TGMMarkerOptions.Create;
end;

function TGMMarkerItem.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/advanced-markers#AdvancedMarkerElement';
end;

function TGMMarkerItem.BuildRemoveCommand: string;
begin
  Result := MarkerRemoveCommand(ObjectId);
end;

constructor TGMMarkerItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FObjectId := BuildObjectId;
  FNeedsSync := True;
  FOptions := CreateMarkerOptions;
  FOptions.Owner := Self;
{$IFDEF FPC}
  FOptions.OnChange := @OptionsChanged;
{$ELSE}
  FOptions.OnChange := OptionsChanged;
{$ENDIF}
end;

destructor TGMMarkerItem.Destroy;
begin
  if Assigned(Collection) and (Collection is TGMMarkers) then
    TGMMarkers(Collection).RegisterRemoval(ObjectId);

  FOptions.Free;
  inherited;
end;

{$IFNDEF FPC}
function TGMMarkerItem.GetDisplayName: string;
begin
  if IsInitialized and (Options.Title <> '') then
    Result := Options.Title
  else
    Result := inherited GetDisplayName;
end;
{$ENDIF}

function TGMMarkerItem.IsInitialized: Boolean;
begin
  Result := Assigned(FOptions);
end;

function TGMMarkerItem.NeedsSync: Boolean;
begin
  Result := FNeedsSync;
end;

procedure TGMMarkerItem.OptionsChanged(Sender: TObject);
begin
  if FUpdatingFromMapMessage then
    Exit;

  FNeedsSync := True;
  Changed(False);
end;

procedure TGMMarkerItem.ProcessMapMessage(const AEnvelope: TMapLibMessageEnvelope);
var
  NewPosition: TMapLibLatLng;
begin
  if SameText(AEnvelope.MessageType, 'marker.click') and Assigned(FOnClick) then
  begin
    FOnClick(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'marker.dragstart') then
  begin
    NewPosition := nil;
    if TryApplyPositionFromPayload(AEnvelope.Payload, NewPosition) then
    begin
      try
        FUpdatingFromMapMessage := True;
        try
          Options.Position.Assign(NewPosition);
        finally
          FUpdatingFromMapMessage := False;
        end;

        if Assigned(FOnDragStart) then
          FOnDragStart(Self, NewPosition);
      finally
        NewPosition.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'marker.drag') then
  begin
    NewPosition := nil;
    if TryApplyPositionFromPayload(AEnvelope.Payload, NewPosition) then
    begin
      try
        FUpdatingFromMapMessage := True;
        try
          Options.Position.Assign(NewPosition);
        finally
          FUpdatingFromMapMessage := False;
        end;

        if Assigned(FOnDrag) then
          FOnDrag(Self, NewPosition);
      finally
        NewPosition.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'marker.dragend') then
  begin
    NewPosition := nil;
    if TryApplyPositionFromPayload(AEnvelope.Payload, NewPosition) then
    begin
      try
        FUpdatingFromMapMessage := True;
        try
          Options.Position.Assign(NewPosition);
        finally
          FUpdatingFromMapMessage := False;
        end;

        if Assigned(FOnDragEnd) then
          FOnDragEnd(Self, NewPosition);
      finally
        NewPosition.Free;
      end;
    end;
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'marker.mouseenter') and Assigned(FOnMouseEnter) then
  begin
    FOnMouseEnter(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'marker.mouseleave') and Assigned(FOnMouseLeave) then
  begin
    FOnMouseLeave(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'marker.mousedown') and Assigned(FOnMouseDown) then
  begin
    FOnMouseDown(Self);
    Exit;
  end;

  if SameText(AEnvelope.MessageType, 'marker.mouseup') and Assigned(FOnMouseUp) then
  begin
    FOnMouseUp(Self);
  end;
end;

procedure TGMMarkerItem.SetOptions(const Value: TGMMarkerOptions);
begin
  if not Assigned(Value) then
    Exit;

  FOptions.Assign(Value);
  Changed(False);
end;

function TGMMarkerItem.TryApplyPositionFromPayload(const APayload: string;
  out ALatLng: TMapLibLatLng): Boolean;
var
  JsonObject: TJSONObject;
{$IFNDEF FPC}
  JsonValue: TJSONValue;
{$ENDIF}
  LatValue: Double;
  LngValue: Double;
begin
  Result := False;
  ALatLng := nil;

{$IFDEF FPC}
  JsonObject := GetJSON(APayload) as TJSONObject;
  if not Assigned(JsonObject) then
    Exit;
  try
    if Assigned(JsonObject.Find('lat')) then
      LatValue := JsonObject.Find('lat').AsFloat
    else
      Exit;
    if Assigned(JsonObject.Find('lng')) then
      LngValue := JsonObject.Find('lng').AsFloat
    else
      Exit;

    ALatLng := TMapLibLatLng.Create(LatValue, LngValue);
    Result := True;
  finally
    JsonObject.Free;
  end;
{$ELSE}
  JsonValue := TJSONObject.ParseJSONValue(APayload);
  try
    if not (JsonValue is TJSONObject) then
      Exit;

    JsonObject := TJSONObject(JsonValue);
    if not JsonObject.TryGetValue<Double>('lat', LatValue) then
      Exit;
    if not JsonObject.TryGetValue<Double>('lng', LngValue) then
      Exit;

    ALatLng := TMapLibLatLng.Create(LatValue, LngValue);
    Result := True;
  finally
    JsonValue.Free;
  end;
{$ENDIF}
end;

{ TGMMarkers }

function TGMMarkers.Add: TGMMarkerItem;
begin
  Result := TGMMarkerItem(inherited Add);
end;

function TGMMarkers.Add(ALatitude, ALongitude: Double;
  const ATitle: string): TGMMarkerItem;
begin
{$IFDEF FPC}
  Result := nil;
{$ENDIF}
  Result := Add;
  if Assigned(Result) then
  begin
    Result.Options.Position.Lat := ALatitude;
    Result.Options.Position.Lng := ALongitude;
    Result.Options.Title := ATitle;
  end;
end;

procedure TGMMarkers.Assign(Source: TPersistent);
var
  i: Integer;
  SourceMarkers: TGMMarkers;
  NewItem: TGMMarkerItem;
begin
  if Source is TGMMarkers then
  begin
    SourceMarkers := TGMMarkers(Source);
    Clear;
    for i := 0 to SourceMarkers.Count - 1 do
    begin
      NewItem := Add;
      NewItem.Assign(SourceMarkers[i]);
    end;
    NotifyChange;
    Exit;
  end;

  inherited;
end;

procedure TGMMarkers.ClearPendingRemovals;
begin
  FPendingRemovals.Clear;
end;

constructor TGMMarkers.Create(AOwner: TPersistent; AItemClass: TGMMarkerItemClass);
begin
  if not Assigned(AItemClass) then
    AItemClass := TGMMarkerItem;

  inherited Create(AOwner, AItemClass);
{$IFDEF FPC}
  FPendingRemovals := specialize TList<TGMObjectId>.Create;
{$ELSE}
  FPendingRemovals := TList<TGMObjectId>.Create;
{$ENDIF}
end;

function TGMMarkers.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/advanced-markers';
end;

function TGMMarkers.GetViewportHost: IGMMapViewportHost;
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

destructor TGMMarkers.Destroy;
begin
  inherited;
  FPendingRemovals.Free;
end;

function TGMMarkers.FindByObjectId(const AObjectId: TGMObjectId): TGMMarkerItem;
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

function TGMMarkers.GetItem(Index: Integer): TGMMarkerItem;
begin
  Result := TGMMarkerItem(inherited GetItem(Index));
end;

procedure TGMMarkers.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMMarkers.LoadFromArray(const AItems: array of TGMMarkerSeed;
  AClearBeforeLoad: Boolean);
var
  i: Integer;
  Marker: TGMMarkerItem;
begin
  BeginUpdate;
  try
    if AClearBeforeLoad then
      Clear;

    for i := Low(AItems) to High(AItems) do
    begin
      Marker := Add(AItems[i].Latitude, AItems[i].Longitude, AItems[i].Title);
      Marker.Options.Visible := AItems[i].Visible;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TGMMarkers.LoadFromCSV(const ACSVText: string; const ALatField, ALongField: string;
  const ATitleField: string; const AVisibleField: string; ADelimiter: Char; AClearBeforeLoad: Boolean);
var
  Lines: TStringList;
  HeaderFields: TStrings;
  RowFields: TStrings;
  HeaderLine: string;
  LatIndex: Integer;
  LngIndex: Integer;
  TitleIndex: Integer;
  VisibleIndex: Integer;
  Row: Integer;
  Lat: Double;
  Lng: Double;
  Title: string;
  Visible: Boolean;
  Marker: TGMMarkerItem;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := ACSVText;
    if Lines.Count = 0 then
      Exit;

    HeaderLine := Trim(Lines[0]);
    if HeaderLine = '' then
      Exit;

    HeaderFields := SplitCsvLine(HeaderLine, ADelimiter);
    try
      LatIndex := IndexOfText(HeaderFields, ALatField);
      LngIndex := IndexOfText(HeaderFields, ALongField);
      TitleIndex := -1;
      VisibleIndex := -1;
      if ATitleField <> '' then
        TitleIndex := IndexOfText(HeaderFields, ATitleField);
      if AVisibleField <> '' then
        VisibleIndex := IndexOfText(HeaderFields, AVisibleField);

      if (LatIndex < 0) or (LngIndex < 0) then
        Exit;

      BeginUpdate;
      try
        if AClearBeforeLoad then
          Clear;

        for Row := 1 to Lines.Count - 1 do
        begin
          if Trim(Lines[Row]) = '' then
            Continue;

          RowFields := SplitCsvLine(Lines[Row], ADelimiter);
          try
            if (LatIndex >= RowFields.Count) or (LngIndex >= RowFields.Count) then
              Continue;

            if not TryStrToFloat(Trim(RowFields[LatIndex]), Lat, GMLibInvariantFormatSettings) then
              Continue;

            if not TryStrToFloat(Trim(RowFields[LngIndex]), Lng, GMLibInvariantFormatSettings) then
              Continue;

            Title := '';
            if (TitleIndex >= 0) and (TitleIndex < RowFields.Count) then
              Title := Trim(RowFields[TitleIndex]);

            Visible := True;
            if (VisibleIndex >= 0) and (VisibleIndex < RowFields.Count) then
              TryParseMarkerVisible(RowFields[VisibleIndex], Visible);

            Marker := Add(Lat, Lng, Title);
            Marker.Options.Visible := Visible;
          finally
            RowFields.Free;
          end;
        end;
      finally
        EndUpdate;
      end;
    finally
      HeaderFields.Free;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TGMMarkers.LoadFromDataSet(ADataSet: TDataSet; const ALatField, ALongField: string;
  const ATitleField: string; const AVisibleField: string; AClearBeforeLoad: Boolean);
var
  Lat: Double;
  Lng: Double;
  Title: string;
  Visible: Boolean;
  Marker: TGMMarkerItem;
begin
  if not Assigned(ADataSet) then
    Exit;

  if not ADataSet.Active then
    Exit;

  BeginUpdate;
  try
    if AClearBeforeLoad then
      Clear;

    ADataSet.DisableControls;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        if not TryStrToFloat(Trim(ADataSet.FieldByName(ALatField).AsString), Lat, GMLibInvariantFormatSettings) then
        begin
          ADataSet.Next;
          Continue;
        end;

        if not TryStrToFloat(Trim(ADataSet.FieldByName(ALongField).AsString), Lng, GMLibInvariantFormatSettings) then
        begin
          ADataSet.Next;
          Continue;
        end;

        Title := '';
        if ATitleField <> '' then
          Title := Trim(ADataSet.FieldByName(ATitleField).AsString);

        Visible := True;
        if AVisibleField <> '' then
          TryParseMarkerVisible(ADataSet.FieldByName(AVisibleField).AsString, Visible);

        Marker := Add(Lat, Lng, Title);
        Marker.Options.Visible := Visible;

        ADataSet.Next;
      end;
    finally
      ADataSet.EnableControls;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TGMMarkers.RegisterRemoval(const AObjectId: TGMObjectId);
begin
  if AObjectId = '' then
    Exit;

  if not FPendingRemovals.Contains(AObjectId) then
    FPendingRemovals.Add(AObjectId);
end;

function TGMMarkers.TryGetBounds(out ANorth, ASouth, AEast,
  AWest: Double; AVisibleOnly: Boolean; AItemIndex: Integer): Boolean;
var
  i: Integer;
  Marker: TGMMarkerItem;
begin
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;

  if (AItemIndex >= 0) and (AItemIndex < Count) then
  begin
    Marker := Items[AItemIndex];
    if (not AVisibleOnly) or Marker.Options.Visible then
    begin
      ANorth := Marker.Options.Position.Lat;
      ASouth := Marker.Options.Position.Lat;
      AEast := Marker.Options.Position.Lng;
      AWest := Marker.Options.Position.Lng;
      Result := True;
    end;
    Exit;
  end;

  for i := 0 to Count - 1 do
  begin
    Marker := Items[i];
    if AVisibleOnly and not Marker.Options.Visible then
      Continue;

    if not Result then
    begin
      ANorth := Marker.Options.Position.Lat;
      ASouth := Marker.Options.Position.Lat;
      AEast := Marker.Options.Position.Lng;
      AWest := Marker.Options.Position.Lng;
      Result := True;
      Continue;
    end;

    ANorth := Max(ANorth, Marker.Options.Position.Lat);
    ASouth := Min(ASouth, Marker.Options.Position.Lat);
    AEast := Max(AEast, Marker.Options.Position.Lng);
    AWest := Min(AWest, Marker.Options.Position.Lng);
  end;
end;

procedure TGMMarkers.SetItem(Index: Integer; const Value: TGMMarkerItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TGMMarkers.Update(Item: TCollectionItem);
begin
  inherited;

  if (Item is TGMMarkerItem) and (not TGMMarkerItem(Item).IsInitialized) then
    Exit;

  NotifyChange;
end;

procedure TGMMarkers.ZoomToPoints(AVisibleOnly: Boolean; AItemIndex: Integer);
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
