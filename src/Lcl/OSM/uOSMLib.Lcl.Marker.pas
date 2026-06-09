{**
  @abstract(Especializaciones LCL del modelo de markers OSM.)
}
unit uOSMLib.Lcl.Marker;

{$I ..\..\..\gmlib.inc}

interface

uses
  Classes,
  Graphics,
  uOSMLib.Map;

type
  TOSMLclMarkerStandardOptions = class(TOSMMarkerStandardOptions)
  private
    function GetBorderColor: TColor;
    function GetColor: TColor;
    function GetGlyphTextColor: TColor;
    procedure SetBorderColor(const Value: TColor);
    procedure SetColor(const Value: TColor);
    procedure SetGlyphTextColor(const Value: TColor);
  published
    property BorderColor: TColor read GetBorderColor write SetBorderColor default clBlack;
    property Color: TColor read GetColor write SetColor default clBlack;
    property GlyphTextColor: TColor read GetGlyphTextColor write SetGlyphTextColor default clBlack;
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

  TOSMLclMarkerPinOptions = class(TOSMMarkerPinOptions)
  private
    function GetBackgroundColor: TColor;
    function GetBorderColor: TColor;
    function GetGlyphTextColor: TColor;
    function GetShadowColor: TColor;
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetGlyphTextColor(const Value: TColor);
    procedure SetShadowColor(const Value: TColor);
  published
    property BackgroundColor: TColor read GetBackgroundColor write SetBackgroundColor default clBlack;
    property BorderColor: TColor read GetBorderColor write SetBorderColor default clBlack;
    property GlyphTextColor: TColor read GetGlyphTextColor write SetGlyphTextColor default clBlack;
    property ShadowColor: TColor read GetShadowColor write SetShadowColor default clBlack;
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

  TOSMLclMarkerDotOptions = class(TOSMMarkerDotOptions)
  private
    function GetColor: TColor;
    function GetBorderColor: TColor;
    function GetGlyphTextColor: TColor;
    function GetPulseColor: TColor;
    function GetShadowColor: TColor;
    procedure SetColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetGlyphTextColor(const Value: TColor);
    procedure SetPulseColor(const Value: TColor);
    procedure SetShadowColor(const Value: TColor);
  published
    property Color: TColor read GetColor write SetColor default clBlack;
    property BorderColor: TColor read GetBorderColor write SetBorderColor default clBlack;
    property GlyphTextColor: TColor read GetGlyphTextColor write SetGlyphTextColor default clBlack;
    property PulseColor: TColor read GetPulseColor write SetPulseColor default clBlack;
    property ShadowColor: TColor read GetShadowColor write SetShadowColor default clBlack;
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

  TOSMLclMarkerItem = class(TOSMMarkerItem)
  private
    function GetStandardOptions: TOSMLclMarkerStandardOptions;
    function GetPinOptions: TOSMLclMarkerPinOptions;
    function GetDotOptions: TOSMLclMarkerDotOptions;
    procedure SetStandardOptions(const Value: TOSMLclMarkerStandardOptions);
    procedure SetPinOptions(const Value: TOSMLclMarkerPinOptions);
    procedure SetDotOptions(const Value: TOSMLclMarkerDotOptions);
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
    property StandardOptions: TOSMLclMarkerStandardOptions read GetStandardOptions write SetStandardOptions;
    property PinOptions: TOSMLclMarkerPinOptions read GetPinOptions write SetPinOptions;
    property DotOptions: TOSMLclMarkerDotOptions read GetDotOptions write SetDotOptions;
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

  TOSMLclMarkers = class(TOSMMarkers)
  private
    function GetItem(Index: Integer): TOSMLclMarkerItem;
    procedure SetItem(Index: Integer; const Value: TOSMLclMarkerItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TOSMLclMarkerItem; reintroduce; overload;
    function Add(ALat, ALng: Double; const ATitle: string = ''): TOSMLclMarkerItem; reintroduce; overload;
  public
    property Items[Index: Integer]: TOSMLclMarkerItem read GetItem write SetItem; default;
  end;

implementation

uses
  SysUtils;

function CssToLclColor(const ACssValue: string): TColor;
var
  RgbValue: Integer;
begin
  if (Length(ACssValue) = 7) and (ACssValue[1] = '#') then
  begin
    RgbValue := StrToIntDef('$' + Copy(ACssValue, 2, 6), -1);
    if RgbValue >= 0 then
      Exit(TColor(RgbValue));
  end;

  Result := clBlack;
end;

function LclColorToCss(const AColor: TColor): string;
var
  RgbColor: Integer;
begin
  if AColor = clNone then
    Exit('');

  RgbColor := ColorToRGB(AColor) and $00FFFFFF;
  Result := Format('#%.2x%.2x%.2x', [
    (RgbColor shr 16) and $FF,
    (RgbColor shr 8) and $FF,
    RgbColor and $FF
  ]);
end;

function TOSMLclMarkerStandardOptions.GetBorderColor: TColor;
begin
  Result := CssToLclColor(Trim(BorderColorCss));
end;

function TOSMLclMarkerStandardOptions.GetColor: TColor;
begin
  Result := CssToLclColor(Trim(ColorCss));
end;

function TOSMLclMarkerStandardOptions.GetGlyphTextColor: TColor;
begin
  Result := CssToLclColor(Trim(GlyphTextColorCss));
end;

procedure TOSMLclMarkerStandardOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerStandardOptions.SetColor(const Value: TColor);
begin
  ColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerStandardOptions.SetGlyphTextColor(const Value: TColor);
begin
  GlyphTextColorCss := LclColorToCss(Value);
end;

function TOSMLclMarkerPinOptions.GetBackgroundColor: TColor;
begin
  Result := CssToLclColor(Trim(BackgroundColorCss));
end;

function TOSMLclMarkerPinOptions.GetBorderColor: TColor;
begin
  Result := CssToLclColor(Trim(BorderColorCss));
end;

function TOSMLclMarkerPinOptions.GetGlyphTextColor: TColor;
begin
  Result := CssToLclColor(Trim(GlyphTextColorCss));
end;

function TOSMLclMarkerPinOptions.GetShadowColor: TColor;
begin
  Result := CssToLclColor(Trim(ShadowColorCss));
end;

procedure TOSMLclMarkerPinOptions.SetBackgroundColor(const Value: TColor);
begin
  BackgroundColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerPinOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerPinOptions.SetGlyphTextColor(const Value: TColor);
begin
  GlyphTextColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerPinOptions.SetShadowColor(const Value: TColor);
begin
  ShadowColorCss := LclColorToCss(Value);
end;

function TOSMLclMarkerDotOptions.GetBorderColor: TColor;
begin
  Result := CssToLclColor(Trim(BorderColorCss));
end;

function TOSMLclMarkerDotOptions.GetColor: TColor;
begin
  Result := CssToLclColor(Trim(ColorCss));
end;

function TOSMLclMarkerDotOptions.GetGlyphTextColor: TColor;
begin
  Result := CssToLclColor(Trim(GlyphTextColorCss));
end;

function TOSMLclMarkerDotOptions.GetPulseColor: TColor;
begin
  Result := CssToLclColor(Trim(PulseColorCss));
end;

function TOSMLclMarkerDotOptions.GetShadowColor: TColor;
begin
  Result := CssToLclColor(Trim(ShadowColorCss));
end;

procedure TOSMLclMarkerDotOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerDotOptions.SetColor(const Value: TColor);
begin
  ColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerDotOptions.SetGlyphTextColor(const Value: TColor);
begin
  GlyphTextColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerDotOptions.SetPulseColor(const Value: TColor);
begin
  PulseColorCss := LclColorToCss(Value);
end;

procedure TOSMLclMarkerDotOptions.SetShadowColor(const Value: TColor);
begin
  ShadowColorCss := LclColorToCss(Value);
end;

function TOSMLclMarkerItem.CreateDotOptions: TOSMMarkerDotOptions;
begin
  Result := TOSMLclMarkerDotOptions.Create;
end;

function TOSMLclMarkerItem.CreatePinOptions: TOSMMarkerPinOptions;
begin
  Result := TOSMLclMarkerPinOptions.Create;
end;

function TOSMLclMarkerItem.CreateStandardOptions: TOSMMarkerStandardOptions;
begin
  Result := TOSMLclMarkerStandardOptions.Create;
end;

function TOSMLclMarkerItem.GetDotOptions: TOSMLclMarkerDotOptions;
begin
  Result := TOSMLclMarkerDotOptions(inherited DotOptions);
end;

function TOSMLclMarkerItem.GetPinOptions: TOSMLclMarkerPinOptions;
begin
  Result := TOSMLclMarkerPinOptions(inherited PinOptions);
end;

function TOSMLclMarkerItem.GetStandardOptions: TOSMLclMarkerStandardOptions;
begin
  Result := TOSMLclMarkerStandardOptions(inherited StandardOptions);
end;

procedure TOSMLclMarkerItem.SetDotOptions(const Value: TOSMLclMarkerDotOptions);
begin
  inherited DotOptions := Value;
end;

procedure TOSMLclMarkerItem.SetPinOptions(const Value: TOSMLclMarkerPinOptions);
begin
  inherited PinOptions := Value;
end;

procedure TOSMLclMarkerItem.SetStandardOptions(const Value: TOSMLclMarkerStandardOptions);
begin
  inherited StandardOptions := Value;
end;

function TOSMLclMarkers.Add: TOSMLclMarkerItem;
begin
  Result := TOSMLclMarkerItem(inherited Add);
end;

function TOSMLclMarkers.Add(ALat, ALng: Double; const ATitle: string): TOSMLclMarkerItem;
begin
  Result := TOSMLclMarkerItem(inherited Add(ALat, ALng, ATitle));
end;

constructor TOSMLclMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TOSMLclMarkerItem);
end;

function TOSMLclMarkers.GetItem(Index: Integer): TOSMLclMarkerItem;
begin
  Result := TOSMLclMarkerItem(inherited Items[Index]);
end;

procedure TOSMLclMarkers.SetItem(Index: Integer; const Value: TOSMLclMarkerItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
