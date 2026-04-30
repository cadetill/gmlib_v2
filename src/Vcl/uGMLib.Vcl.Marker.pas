{**
  @abstract(Especializaciones VCL del modelo de markers.)
}
unit uGMLib.Vcl.Marker;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  Vcl.Graphics,
  uGMLib.Marker;

type
  TGMVclPinOptions = class(TGMPinOptions)
  private
    function GetBackgroundColor: TColor;
    function GetBorderColor: TColor;
    function GetGlyphColor: TColor;
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetGlyphColor(const Value: TColor);
  published
    property APIUrl;
    property BackgroundColor: TColor read GetBackgroundColor write SetBackgroundColor default clNone;
    property BorderColor: TColor read GetBorderColor write SetBorderColor default clNone;
    property GlyphColor: TColor read GetGlyphColor write SetGlyphColor default clNone;
    property GlyphText;
    property Scale;
  end;

  TGMVclLabelMarkerOptions = class(TGMLabelMarkerOptions)
  private
    function GetBackgroundColor: TColor;
    function GetBorderColor: TColor;
    function GetTextColor: TColor;
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
  published
    property APIUrl;
    property BackgroundColor: TColor read GetBackgroundColor write SetBackgroundColor default clNone;
    property BorderColor: TColor read GetBorderColor write SetBorderColor default clNone;
    property TextColor: TColor read GetTextColor write SetTextColor default clNone;
    property CssClassName;
    property Text;
    property PaddingHorizontal;
    property PaddingVertical;
    property CornerRadius;
    property FontSize;
    property FontBold;
  end;

  TGMVclMarkerOptions = class(TGMMarkerOptions)
  private
    function GetLabelOptions: TGMVclLabelMarkerOptions;
    function GetPinOptions: TGMVclPinOptions;
    procedure SetLabelOptions(const Value: TGMVclLabelMarkerOptions);
    procedure SetPinOptions(const Value: TGMVclPinOptions);
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
    property LabelOptions: TGMVclLabelMarkerOptions read GetLabelOptions write SetLabelOptions;
    property PinOptions: TGMVclPinOptions read GetPinOptions write SetPinOptions;
    property Position;
    property Title;
    property Visible;
    property ZIndex;
  end;

  TGMVclMarkerItem = class(TGMMarkerItem)
  private
    function GetOptions: TGMVclMarkerOptions;
    procedure SetOptions(const Value: TGMVclMarkerOptions);
  protected
    function CreateMarkerOptions: TGMMarkerOptions; override;
  published
    property APIUrl;
    property Options: TGMVclMarkerOptions read GetOptions write SetOptions;
    property OnClick;
    property OnDragStart;
    property OnDrag;
    property OnDragEnd;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
  end;

  TGMVclMarkers = class(TGMMarkers)
  private
    function GetItem(Index: Integer): TGMVclMarkerItem;
    procedure SetItem(Index: Integer; const Value: TGMVclMarkerItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMVclMarkerItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMVclMarkerItem read GetItem write SetItem; default;
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

  Result := clNone;
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

{ TGMVclPinOptions }

function TGMVclPinOptions.GetBackgroundColor: TColor;
begin
  Result := CssToVclColor(Trim(BackgroundCss));
end;

function TGMVclPinOptions.GetBorderColor: TColor;
begin
  Result := CssToVclColor(Trim(BorderColorCss));
end;

function TGMVclPinOptions.GetGlyphColor: TColor;
begin
  Result := CssToVclColor(Trim(GlyphColorCss));
end;

procedure TGMVclPinOptions.SetBackgroundColor(const Value: TColor);
begin
  BackgroundCss := VclColorToCss(Value);
end;

procedure TGMVclPinOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := VclColorToCss(Value);
end;

procedure TGMVclPinOptions.SetGlyphColor(const Value: TColor);
begin
  GlyphColorCss := VclColorToCss(Value);
end;

{ TGMVclLabelMarkerOptions }

function TGMVclLabelMarkerOptions.GetBackgroundColor: TColor;
begin
  Result := CssToVclColor(Trim(BackgroundCss));
end;

function TGMVclLabelMarkerOptions.GetBorderColor: TColor;
begin
  Result := CssToVclColor(Trim(BorderColorCss));
end;

function TGMVclLabelMarkerOptions.GetTextColor: TColor;
begin
  Result := CssToVclColor(Trim(TextColorCss));
end;

procedure TGMVclLabelMarkerOptions.SetBackgroundColor(const Value: TColor);
begin
  BackgroundCss := VclColorToCss(Value);
end;

procedure TGMVclLabelMarkerOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := VclColorToCss(Value);
end;

procedure TGMVclLabelMarkerOptions.SetTextColor(const Value: TColor);
begin
  TextColorCss := VclColorToCss(Value);
end;

{ TGMVclMarkerOptions }

function TGMVclMarkerOptions.CreateLabelOptions: TGMLabelMarkerOptions;
begin
  Result := TGMVclLabelMarkerOptions.Create;
end;

function TGMVclMarkerOptions.CreatePinOptions: TGMPinOptions;
begin
  Result := TGMVclPinOptions.Create;
end;

function TGMVclMarkerOptions.GetLabelOptions: TGMVclLabelMarkerOptions;
begin
  Result := TGMVclLabelMarkerOptions(inherited LabelOptions);
end;

function TGMVclMarkerOptions.GetPinOptions: TGMVclPinOptions;
begin
  Result := TGMVclPinOptions(inherited PinOptions);
end;

procedure TGMVclMarkerOptions.SetLabelOptions(const Value: TGMVclLabelMarkerOptions);
begin
  inherited LabelOptions := Value;
end;

procedure TGMVclMarkerOptions.SetPinOptions(const Value: TGMVclPinOptions);
begin
  inherited PinOptions := Value;
end;

{ TGMVclMarkerItem }

function TGMVclMarkerItem.CreateMarkerOptions: TGMMarkerOptions;
begin
  Result := TGMVclMarkerOptions.Create;
end;

function TGMVclMarkerItem.GetOptions: TGMVclMarkerOptions;
begin
  Result := TGMVclMarkerOptions(inherited Options);
end;

procedure TGMVclMarkerItem.SetOptions(const Value: TGMVclMarkerOptions);
begin
  inherited Options := Value;
end;

{ TGMVclMarkers }

function TGMVclMarkers.Add: TGMVclMarkerItem;
begin
  Result := TGMVclMarkerItem(inherited Add);
end;

constructor TGMVclMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMVclMarkerItem);
end;

function TGMVclMarkers.GetItem(Index: Integer): TGMVclMarkerItem;
begin
  Result := TGMVclMarkerItem(inherited Items[Index]);
end;

procedure TGMVclMarkers.SetItem(Index: Integer; const Value: TGMVclMarkerItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
