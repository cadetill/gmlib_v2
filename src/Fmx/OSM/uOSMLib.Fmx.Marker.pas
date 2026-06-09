{**
  @abstract(Especializaciones FMX del modelo de markers OSM.)
}
unit uOSMLib.Fmx.Marker;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.UITypes,
  uOSMLib.Map;

type
  TOSMFmxMarkerStandardOptions = class(TOSMMarkerStandardOptions)
  private
    function GetBorderColor: TAlphaColor;
    function GetColor: TAlphaColor;
    function GetGlyphTextColor: TAlphaColor;
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetColor(const Value: TAlphaColor);
    procedure SetGlyphTextColor(const Value: TAlphaColor);
  published
    property BorderColor: TAlphaColor read GetBorderColor write SetBorderColor default TAlphaColorRec.Black;
    property Color: TAlphaColor read GetColor write SetColor default TAlphaColorRec.Black;
    property GlyphTextColor: TAlphaColor read GetGlyphTextColor write SetGlyphTextColor default TAlphaColorRec.Black;
    property BorderWidth;
    property GlyphFontSize;
    property GlyphOffsetX;
    property GlyphOffsetY;
    property HideDefaultCenterDot;
    property ShadowEnabled;
    property GlyphText;
    property Scale;
    property Opacity;
    property ZIndex;
    property Rotation;
    property AnchorX;
    property AnchorY;
    property PopupEnabled;
    property PopupText;
    property UseDefaultMapLibreShape;
    property UseGlyph;
  end;

  TOSMFmxMarkerPinOptions = class(TOSMMarkerPinOptions)
  private
    function GetBackgroundColor: TAlphaColor;
    function GetBorderColor: TAlphaColor;
    function GetGlyphTextColor: TAlphaColor;
    function GetShadowColor: TAlphaColor;
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetGlyphTextColor(const Value: TAlphaColor);
    procedure SetShadowColor(const Value: TAlphaColor);
  published
    property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor default TAlphaColorRec.Black;
    property BorderColor: TAlphaColor read GetBorderColor write SetBorderColor default TAlphaColorRec.Black;
    property GlyphTextColor: TAlphaColor read GetGlyphTextColor write SetGlyphTextColor default TAlphaColorRec.Black;
    property ShadowColor: TAlphaColor read GetShadowColor write SetShadowColor default TAlphaColorRec.Black;
    property BorderWidth;
    property CornerStyle;
    property GlyphFontSize;
    property GlyphText;
    property MinHeight;
    property MinWidth;
    property Padding;
    property PointerLength;
    property PointerWidth;
    property Scale;
    property ShadowBlur;
    property ShadowEnabled;
    property ShapeVariant;
    property Opacity;
    property ZIndex;
    property Rotation;
    property AnchorX;
    property AnchorY;
    property PopupEnabled;
    property PopupText;
  end;

  TOSMFmxMarkerDotOptions = class(TOSMMarkerDotOptions)
  private
    function GetColor: TAlphaColor;
    function GetBorderColor: TAlphaColor;
    function GetGlyphTextColor: TAlphaColor;
    function GetPulseColor: TAlphaColor;
    function GetShadowColor: TAlphaColor;
    procedure SetColor(const Value: TAlphaColor);
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetGlyphTextColor(const Value: TAlphaColor);
    procedure SetPulseColor(const Value: TAlphaColor);
    procedure SetShadowColor(const Value: TAlphaColor);
  published
    property Color: TAlphaColor read GetColor write SetColor default TAlphaColorRec.Black;
    property BorderColor: TAlphaColor read GetBorderColor write SetBorderColor default TAlphaColorRec.Black;
    property GlyphTextColor: TAlphaColor read GetGlyphTextColor write SetGlyphTextColor default TAlphaColorRec.Black;
    property PulseColor: TAlphaColor read GetPulseColor write SetPulseColor default TAlphaColorRec.Black;
    property ShadowColor: TAlphaColor read GetShadowColor write SetShadowColor default TAlphaColorRec.Black;
    property BorderWidth;
    property Diameter;
    property GlyphFontSize;
    property GlyphText;
    property PulseDuration;
    property PulseEnabled;
    property PulseRadius;
    property Radius;
    property Scale;
    property ShadowBlur;
    property ShadowEnabled;
    property Opacity;
    property ZIndex;
    property Rotation;
    property AnchorX;
    property AnchorY;
    property PopupEnabled;
    property PopupText;
  end;

  TOSMFmxMarkerItem = class(TOSMMarkerItem)
  private
    function GetStandardOptions: TOSMFmxMarkerStandardOptions;
    function GetPinOptions: TOSMFmxMarkerPinOptions;
    function GetDotOptions: TOSMFmxMarkerDotOptions;
    procedure SetStandardOptions(const Value: TOSMFmxMarkerStandardOptions);
    procedure SetPinOptions(const Value: TOSMFmxMarkerPinOptions);
    procedure SetDotOptions(const Value: TOSMFmxMarkerDotOptions);
  protected
    function CreateStandardOptions: TOSMMarkerStandardOptions; override;
    function CreatePinOptions: TOSMMarkerPinOptions; override;
    function CreateDotOptions: TOSMMarkerDotOptions; override;
  published
    property ObjectId;
    property Lat;
    property Lng;
    property Title;
    property Visible;
    property Draggable;
    property Kind;
    property StandardOptions: TOSMFmxMarkerStandardOptions read GetStandardOptions write SetStandardOptions;
    property PinOptions: TOSMFmxMarkerPinOptions read GetPinOptions write SetPinOptions;
    property DotOptions: TOSMFmxMarkerDotOptions read GetDotOptions write SetDotOptions;
    property OnClick;
    property OnDblClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnDragStart;
    property OnDrag;
    property OnDragEnd;
  end;

  TOSMFmxMarkers = class(TOSMMarkers)
  private
    function GetItem(Index: Integer): TOSMFmxMarkerItem;
    procedure SetItem(Index: Integer; const Value: TOSMFmxMarkerItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TOSMFmxMarkerItem; reintroduce; overload;
    function Add(ALat, ALng: Double; const ATitle: string = ''): TOSMFmxMarkerItem; reintroduce; overload;
  public
    property Items[Index: Integer]: TOSMFmxMarkerItem read GetItem write SetItem; default;
  end;

implementation

uses
  System.SysUtils;

function CssToAlphaColor(const ACssValue: string): TAlphaColor;
var
  RgbValue: Integer;
begin
  if (Length(ACssValue) = 7) and (ACssValue[1] = '#') then
  begin
    RgbValue := StrToIntDef('$' + Copy(ACssValue, 2, 6), -1);
    if RgbValue >= 0 then
      Exit($FF000000 or Cardinal(RgbValue));
  end;

  Result := TAlphaColorRec.Black;
end;

function AlphaColorToCss(const AColor: TAlphaColor): string;
var
  Red: Byte;
  Green: Byte;
  Blue: Byte;
begin
  if AColor = 0 then
    Exit('');

  Red := (AColor shr 16) and $FF;
  Green := (AColor shr 8) and $FF;
  Blue := AColor and $FF;
  Result := Format('#%.2x%.2x%.2x', [Red, Green, Blue]);
end;

function TOSMFmxMarkerStandardOptions.GetBorderColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BorderColorCss));
end;

function TOSMFmxMarkerStandardOptions.GetColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(ColorCss));
end;

function TOSMFmxMarkerStandardOptions.GetGlyphTextColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(GlyphTextColorCss));
end;

procedure TOSMFmxMarkerStandardOptions.SetBorderColor(const Value: TAlphaColor);
begin
  BorderColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerStandardOptions.SetColor(const Value: TAlphaColor);
begin
  ColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerStandardOptions.SetGlyphTextColor(const Value: TAlphaColor);
begin
  GlyphTextColorCss := AlphaColorToCss(Value);
end;

function TOSMFmxMarkerPinOptions.GetBackgroundColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BackgroundColorCss));
end;

function TOSMFmxMarkerPinOptions.GetBorderColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BorderColorCss));
end;

function TOSMFmxMarkerPinOptions.GetGlyphTextColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(GlyphTextColorCss));
end;

function TOSMFmxMarkerPinOptions.GetShadowColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(ShadowColorCss));
end;

procedure TOSMFmxMarkerPinOptions.SetBackgroundColor(const Value: TAlphaColor);
begin
  BackgroundColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerPinOptions.SetBorderColor(const Value: TAlphaColor);
begin
  BorderColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerPinOptions.SetGlyphTextColor(const Value: TAlphaColor);
begin
  GlyphTextColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerPinOptions.SetShadowColor(const Value: TAlphaColor);
begin
  ShadowColorCss := AlphaColorToCss(Value);
end;

function TOSMFmxMarkerDotOptions.GetBorderColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BorderColorCss));
end;

function TOSMFmxMarkerDotOptions.GetColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(ColorCss));
end;

function TOSMFmxMarkerDotOptions.GetGlyphTextColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(GlyphTextColorCss));
end;

function TOSMFmxMarkerDotOptions.GetPulseColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(PulseColorCss));
end;

function TOSMFmxMarkerDotOptions.GetShadowColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(ShadowColorCss));
end;

procedure TOSMFmxMarkerDotOptions.SetBorderColor(const Value: TAlphaColor);
begin
  BorderColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerDotOptions.SetColor(const Value: TAlphaColor);
begin
  ColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerDotOptions.SetGlyphTextColor(const Value: TAlphaColor);
begin
  GlyphTextColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerDotOptions.SetPulseColor(const Value: TAlphaColor);
begin
  PulseColorCss := AlphaColorToCss(Value);
end;

procedure TOSMFmxMarkerDotOptions.SetShadowColor(const Value: TAlphaColor);
begin
  ShadowColorCss := AlphaColorToCss(Value);
end;

function TOSMFmxMarkerItem.CreateDotOptions: TOSMMarkerDotOptions;
begin
  Result := TOSMFmxMarkerDotOptions.Create;
end;

function TOSMFmxMarkerItem.CreatePinOptions: TOSMMarkerPinOptions;
begin
  Result := TOSMFmxMarkerPinOptions.Create;
end;

function TOSMFmxMarkerItem.CreateStandardOptions: TOSMMarkerStandardOptions;
begin
  Result := TOSMFmxMarkerStandardOptions.Create;
end;

function TOSMFmxMarkerItem.GetDotOptions: TOSMFmxMarkerDotOptions;
begin
  Result := TOSMFmxMarkerDotOptions(inherited DotOptions);
end;

function TOSMFmxMarkerItem.GetPinOptions: TOSMFmxMarkerPinOptions;
begin
  Result := TOSMFmxMarkerPinOptions(inherited PinOptions);
end;

function TOSMFmxMarkerItem.GetStandardOptions: TOSMFmxMarkerStandardOptions;
begin
  Result := TOSMFmxMarkerStandardOptions(inherited StandardOptions);
end;

procedure TOSMFmxMarkerItem.SetDotOptions(const Value: TOSMFmxMarkerDotOptions);
begin
  inherited DotOptions := Value;
end;

procedure TOSMFmxMarkerItem.SetPinOptions(const Value: TOSMFmxMarkerPinOptions);
begin
  inherited PinOptions := Value;
end;

procedure TOSMFmxMarkerItem.SetStandardOptions(const Value: TOSMFmxMarkerStandardOptions);
begin
  inherited StandardOptions := Value;
end;

function TOSMFmxMarkers.Add: TOSMFmxMarkerItem;
begin
  Result := TOSMFmxMarkerItem(inherited Add);
end;

function TOSMFmxMarkers.Add(ALat, ALng: Double; const ATitle: string): TOSMFmxMarkerItem;
begin
  Result := TOSMFmxMarkerItem(inherited Add(ALat, ALng, ATitle));
end;

constructor TOSMFmxMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TOSMFmxMarkerItem);
end;

function TOSMFmxMarkers.GetItem(Index: Integer): TOSMFmxMarkerItem;
begin
  Result := TOSMFmxMarkerItem(inherited Items[Index]);
end;

procedure TOSMFmxMarkers.SetItem(Index: Integer; const Value: TOSMFmxMarkerItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
