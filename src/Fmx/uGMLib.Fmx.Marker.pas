{**
  @abstract(Especializaciones FMX del modelo de markers.)
}
unit uGMLib.Fmx.Marker;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.UITypes,
  uGMLib.Marker;

type
  TGMFmxPinOptions = class(TGMPinOptions)
  private
    function GetBackgroundColor: TAlphaColor;
    function GetBorderColor: TAlphaColor;
    function GetGlyphColor: TAlphaColor;
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetGlyphColor(const Value: TAlphaColor);
  published
    property APIUrl;
    property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor default 0;
    property BorderColor: TAlphaColor read GetBorderColor write SetBorderColor default 0;
    property GlyphColor: TAlphaColor read GetGlyphColor write SetGlyphColor default 0;
    property GlyphText;
    property Scale;
  end;

  TGMFmxLabelMarkerOptions = class(TGMLabelMarkerOptions)
  private
    function GetBackgroundColor: TAlphaColor;
    function GetBorderColor: TAlphaColor;
    function GetTextColor: TAlphaColor;
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetTextColor(const Value: TAlphaColor);
  published
    property APIUrl;
    property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor default 0;
    property BorderColor: TAlphaColor read GetBorderColor write SetBorderColor default 0;
    property TextColor: TAlphaColor read GetTextColor write SetTextColor default 0;
    property CssClassName;
    property Text;
    property PaddingHorizontal;
    property PaddingVertical;
    property CornerRadius;
    property FontSize;
    property FontBold;
  end;

  TGMFmxMarkerOptions = class(TGMMarkerOptions)
  private
    function GetLabelOptions: TGMFmxLabelMarkerOptions;
    function GetPinOptions: TGMFmxPinOptions;
    procedure SetLabelOptions(const Value: TGMFmxLabelMarkerOptions);
    procedure SetPinOptions(const Value: TGMFmxPinOptions);
  protected
    function CreateLabelOptions: TGMLabelMarkerOptions; override;
    function CreatePinOptions: TGMPinOptions; override;
  published
    property APIUrl;
    property Clickable;
    property CollisionBehavior;
    property ContentMode;
    property Draggable;
    property HtmlOptions;
    property LabelOptions: TGMFmxLabelMarkerOptions read GetLabelOptions write SetLabelOptions;
    property PinOptions: TGMFmxPinOptions read GetPinOptions write SetPinOptions;
    property Position;
    property Title;
    property Visible;
    property ZIndex;
  end;

  TGMFmxMarkerItem = class(TGMMarkerItem)
  private
    function GetOptions: TGMFmxMarkerOptions;
    procedure SetOptions(const Value: TGMFmxMarkerOptions);
  protected
    function CreateMarkerOptions: TGMMarkerOptions; override;
  published
    property APIUrl;
    property Options: TGMFmxMarkerOptions read GetOptions write SetOptions;
    property OnClick;
    property OnDragStart;
    property OnDrag;
    property OnDragEnd;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
  end;

  TGMFmxMarkers = class(TGMMarkers)
  private
    function GetItem(Index: Integer): TGMFmxMarkerItem;
    procedure SetItem(Index: Integer; const Value: TGMFmxMarkerItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMFmxMarkerItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMFmxMarkerItem read GetItem write SetItem; default;
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

  Result := 0;
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

{ TGMFmxPinOptions }

function TGMFmxPinOptions.GetBackgroundColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BackgroundCss));
end;

function TGMFmxPinOptions.GetBorderColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BorderColorCss));
end;

function TGMFmxPinOptions.GetGlyphColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(GlyphColorCss));
end;

procedure TGMFmxPinOptions.SetBackgroundColor(const Value: TAlphaColor);
begin
  BackgroundCss := AlphaColorToCss(Value);
end;

procedure TGMFmxPinOptions.SetBorderColor(const Value: TAlphaColor);
begin
  BorderColorCss := AlphaColorToCss(Value);
end;

procedure TGMFmxPinOptions.SetGlyphColor(const Value: TAlphaColor);
begin
  GlyphColorCss := AlphaColorToCss(Value);
end;

{ TGMFmxLabelMarkerOptions }

function TGMFmxLabelMarkerOptions.GetBackgroundColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BackgroundCss));
end;

function TGMFmxLabelMarkerOptions.GetBorderColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(BorderColorCss));
end;

function TGMFmxLabelMarkerOptions.GetTextColor: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(TextColorCss));
end;

procedure TGMFmxLabelMarkerOptions.SetBackgroundColor(const Value: TAlphaColor);
begin
  BackgroundCss := AlphaColorToCss(Value);
end;

procedure TGMFmxLabelMarkerOptions.SetBorderColor(const Value: TAlphaColor);
begin
  BorderColorCss := AlphaColorToCss(Value);
end;

procedure TGMFmxLabelMarkerOptions.SetTextColor(const Value: TAlphaColor);
begin
  TextColorCss := AlphaColorToCss(Value);
end;

{ TGMFmxMarkerOptions }

function TGMFmxMarkerOptions.CreateLabelOptions: TGMLabelMarkerOptions;
begin
  Result := TGMFmxLabelMarkerOptions.Create;
end;

function TGMFmxMarkerOptions.CreatePinOptions: TGMPinOptions;
begin
  Result := TGMFmxPinOptions.Create;
end;

function TGMFmxMarkerOptions.GetLabelOptions: TGMFmxLabelMarkerOptions;
begin
  Result := TGMFmxLabelMarkerOptions(inherited LabelOptions);
end;

function TGMFmxMarkerOptions.GetPinOptions: TGMFmxPinOptions;
begin
  Result := TGMFmxPinOptions(inherited PinOptions);
end;

procedure TGMFmxMarkerOptions.SetLabelOptions(const Value: TGMFmxLabelMarkerOptions);
begin
  inherited LabelOptions := Value;
end;

procedure TGMFmxMarkerOptions.SetPinOptions(const Value: TGMFmxPinOptions);
begin
  inherited PinOptions := Value;
end;

{ TGMFmxMarkerItem }

function TGMFmxMarkerItem.CreateMarkerOptions: TGMMarkerOptions;
begin
  Result := TGMFmxMarkerOptions.Create;
end;

function TGMFmxMarkerItem.GetOptions: TGMFmxMarkerOptions;
begin
  Result := TGMFmxMarkerOptions(inherited Options);
end;

procedure TGMFmxMarkerItem.SetOptions(const Value: TGMFmxMarkerOptions);
begin
  inherited Options := Value;
end;

{ TGMFmxMarkers }

function TGMFmxMarkers.Add: TGMFmxMarkerItem;
begin
  Result := TGMFmxMarkerItem(inherited Add);
end;

constructor TGMFmxMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMFmxMarkerItem);
end;

function TGMFmxMarkers.GetItem(Index: Integer): TGMFmxMarkerItem;
begin
  Result := TGMFmxMarkerItem(inherited Items[Index]);
end;

procedure TGMFmxMarkers.SetItem(Index: Integer; const Value: TGMFmxMarkerItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
