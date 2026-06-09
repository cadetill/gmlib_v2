{**
  @abstract(Especializaciones VCL del modelo de markers OSM.)
}
unit uOSMLib.Vcl.Marker;

{$I ..\..\..\gmlib.inc}

interface

uses
  System.Classes,
  Vcl.Graphics,
  uOSMLib.Map;

type
  TOSMVclMarkerStandardOptions = class(TOSMMarkerStandardOptions)
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

  TOSMVclMarkerPinOptions = class(TOSMMarkerPinOptions)
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

  TOSMVclMarkerDotOptions = class(TOSMMarkerDotOptions)
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

  TOSMVclMarkerItem = class(TOSMMarkerItem)
  private
    function GetStandardOptions: TOSMVclMarkerStandardOptions;
    function GetPinOptions: TOSMVclMarkerPinOptions;
    function GetDotOptions: TOSMVclMarkerDotOptions;
    procedure SetStandardOptions(const Value: TOSMVclMarkerStandardOptions);
    procedure SetPinOptions(const Value: TOSMVclMarkerPinOptions);
    procedure SetDotOptions(const Value: TOSMVclMarkerDotOptions);
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
    property StandardOptions: TOSMVclMarkerStandardOptions read GetStandardOptions write SetStandardOptions;
    property PinOptions: TOSMVclMarkerPinOptions read GetPinOptions write SetPinOptions;
    property DotOptions: TOSMVclMarkerDotOptions read GetDotOptions write SetDotOptions;
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

  TOSMVclMarkers = class(TOSMMarkers)
  private
    function GetItem(Index: Integer): TOSMVclMarkerItem;
    procedure SetItem(Index: Integer; const Value: TOSMVclMarkerItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TOSMVclMarkerItem; reintroduce; overload;
    function Add(ALat, ALng: Double; const ATitle: string = ''): TOSMVclMarkerItem; reintroduce; overload;
  public
    property Items[Index: Integer]: TOSMVclMarkerItem read GetItem write SetItem; default;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

function CssToVclColor(const ACssValue: string): TColor;
var
  RgbValue: Integer;
begin
  if (Length(ACssValue) = 7) and (ACssValue[1] = '#') then
  begin
    RgbValue := StrToIntDef('$' + Copy(ACssValue, 2, 6), -1);
    if RgbValue >= 0 then
      Exit(RGB(GetBValue(RgbValue), GetGValue(RgbValue), GetRValue(RgbValue)));
  end;

  Result := clBlack;
end;

function VclColorToCss(const AColor: TColor): string;
var
  RgbColor: TColor;
begin
  if AColor = clNone then
    Exit('');

  RgbColor := ColorToRGB(AColor);
  Result := Format('#%.2x%.2x%.2x', [
    GetRValue(RgbColor),
    GetGValue(RgbColor),
    GetBValue(RgbColor)
  ]);
end;

{ TOSMVclMarkerStandardOptions }

function TOSMVclMarkerStandardOptions.GetBorderColor: TColor;
begin
  Result := CssToVclColor(Trim(BorderColorCss));
end;

function TOSMVclMarkerStandardOptions.GetColor: TColor;
begin
  Result := CssToVclColor(Trim(ColorCss));
end;

function TOSMVclMarkerStandardOptions.GetGlyphTextColor: TColor;
begin
  Result := CssToVclColor(Trim(GlyphTextColorCss));
end;

procedure TOSMVclMarkerStandardOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerStandardOptions.SetColor(const Value: TColor);
begin
  ColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerStandardOptions.SetGlyphTextColor(const Value: TColor);
begin
  GlyphTextColorCss := VclColorToCss(Value);
end;

{ TOSMVclMarkerPinOptions }

function TOSMVclMarkerPinOptions.GetBackgroundColor: TColor;
begin
  Result := CssToVclColor(Trim(BackgroundColorCss));
end;

function TOSMVclMarkerPinOptions.GetBorderColor: TColor;
begin
  Result := CssToVclColor(Trim(BorderColorCss));
end;

function TOSMVclMarkerPinOptions.GetGlyphTextColor: TColor;
begin
  Result := CssToVclColor(Trim(GlyphTextColorCss));
end;

function TOSMVclMarkerPinOptions.GetShadowColor: TColor;
begin
  Result := CssToVclColor(Trim(ShadowColorCss));
end;

procedure TOSMVclMarkerPinOptions.SetBackgroundColor(const Value: TColor);
begin
  BackgroundColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerPinOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerPinOptions.SetGlyphTextColor(const Value: TColor);
begin
  GlyphTextColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerPinOptions.SetShadowColor(const Value: TColor);
begin
  ShadowColorCss := VclColorToCss(Value);
end;

{ TOSMVclMarkerDotOptions }

function TOSMVclMarkerDotOptions.GetBorderColor: TColor;
begin
  Result := CssToVclColor(Trim(BorderColorCss));
end;

function TOSMVclMarkerDotOptions.GetColor: TColor;
begin
  Result := CssToVclColor(Trim(ColorCss));
end;

function TOSMVclMarkerDotOptions.GetGlyphTextColor: TColor;
begin
  Result := CssToVclColor(Trim(GlyphTextColorCss));
end;

function TOSMVclMarkerDotOptions.GetPulseColor: TColor;
begin
  Result := CssToVclColor(Trim(PulseColorCss));
end;

function TOSMVclMarkerDotOptions.GetShadowColor: TColor;
begin
  Result := CssToVclColor(Trim(ShadowColorCss));
end;

procedure TOSMVclMarkerDotOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerDotOptions.SetColor(const Value: TColor);
begin
  ColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerDotOptions.SetGlyphTextColor(const Value: TColor);
begin
  GlyphTextColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerDotOptions.SetPulseColor(const Value: TColor);
begin
  PulseColorCss := VclColorToCss(Value);
end;

procedure TOSMVclMarkerDotOptions.SetShadowColor(const Value: TColor);
begin
  ShadowColorCss := VclColorToCss(Value);
end;

{ TOSMVclMarkerItem }

function TOSMVclMarkerItem.CreateDotOptions: TOSMMarkerDotOptions;
begin
  Result := TOSMVclMarkerDotOptions.Create;
end;

function TOSMVclMarkerItem.CreatePinOptions: TOSMMarkerPinOptions;
begin
  Result := TOSMVclMarkerPinOptions.Create;
end;

function TOSMVclMarkerItem.CreateStandardOptions: TOSMMarkerStandardOptions;
begin
  Result := TOSMVclMarkerStandardOptions.Create;
end;

function TOSMVclMarkerItem.GetDotOptions: TOSMVclMarkerDotOptions;
begin
  Result := TOSMVclMarkerDotOptions(inherited DotOptions);
end;

function TOSMVclMarkerItem.GetPinOptions: TOSMVclMarkerPinOptions;
begin
  Result := TOSMVclMarkerPinOptions(inherited PinOptions);
end;

function TOSMVclMarkerItem.GetStandardOptions: TOSMVclMarkerStandardOptions;
begin
  Result := TOSMVclMarkerStandardOptions(inherited StandardOptions);
end;

procedure TOSMVclMarkerItem.SetDotOptions(const Value: TOSMVclMarkerDotOptions);
begin
  inherited DotOptions := Value;
end;

procedure TOSMVclMarkerItem.SetPinOptions(const Value: TOSMVclMarkerPinOptions);
begin
  inherited PinOptions := Value;
end;

procedure TOSMVclMarkerItem.SetStandardOptions(const Value: TOSMVclMarkerStandardOptions);
begin
  inherited StandardOptions := Value;
end;

{ TOSMVclMarkers }

function TOSMVclMarkers.Add: TOSMVclMarkerItem;
begin
  Result := TOSMVclMarkerItem(inherited Add);
end;

function TOSMVclMarkers.Add(ALat, ALng: Double; const ATitle: string): TOSMVclMarkerItem;
begin
  Result := TOSMVclMarkerItem(inherited Add(ALat, ALng, ATitle));
end;

constructor TOSMVclMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TOSMVclMarkerItem);
end;

function TOSMVclMarkers.GetItem(Index: Integer): TOSMVclMarkerItem;
begin
  Result := TOSMVclMarkerItem(inherited Items[Index]);
end;

procedure TOSMVclMarkers.SetItem(Index: Integer; const Value: TOSMVclMarkerItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
