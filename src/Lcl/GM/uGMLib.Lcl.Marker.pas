{**
  @abstract(Especializaciones LCL del modelo de markers.)
}
unit uGMLib.Lcl.Marker;

{$I ..\..\..\gmlib.inc}

interface

uses
  Classes,
  Graphics,
  uGMLib.Marker;

type
  TGMLclPinOptions = class(TGMPinOptions)
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

  TGMLclLabelMarkerOptions = class(TGMLabelMarkerOptions)
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

  TGMLclMarkerOptions = class(TGMMarkerOptions)
  private
    function GetLabelOptions: TGMLclLabelMarkerOptions;
    function GetPinOptions: TGMLclPinOptions;
    procedure SetLabelOptions(const Value: TGMLclLabelMarkerOptions);
    procedure SetPinOptions(const Value: TGMLclPinOptions);
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
    property LabelOptions: TGMLclLabelMarkerOptions read GetLabelOptions write SetLabelOptions;
    property PinOptions: TGMLclPinOptions read GetPinOptions write SetPinOptions;
    property Position;
    property Title;
    property Visible;
    property ZIndex;
  end;

  TGMLclMarkerItem = class(TGMMarkerItem)
  private
    function GetOptions: TGMLclMarkerOptions;
    procedure SetOptions(const Value: TGMLclMarkerOptions);
  protected
    function CreateMarkerOptions: TGMMarkerOptions; override;
  published
    property APIUrl;
    property Options: TGMLclMarkerOptions read GetOptions write SetOptions;
    property OnClick;
    property OnDragStart;
    property OnDrag;
    property OnDragEnd;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
  end;

  TGMLclMarkers = class(TGMMarkers)
  private
    function GetItem(Index: Integer): TGMLclMarkerItem;
    procedure SetItem(Index: Integer; const Value: TGMLclMarkerItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMLclMarkerItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMLclMarkerItem read GetItem write SetItem; default;
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

  Result := clNone;
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

{ TGMLclPinOptions }

function TGMLclPinOptions.GetBackgroundColor: TColor;
begin
  Result := CssToLclColor(Trim(BackgroundCss));
end;

function TGMLclPinOptions.GetBorderColor: TColor;
begin
  Result := CssToLclColor(Trim(BorderColorCss));
end;

function TGMLclPinOptions.GetGlyphColor: TColor;
begin
  Result := CssToLclColor(Trim(GlyphColorCss));
end;

procedure TGMLclPinOptions.SetBackgroundColor(const Value: TColor);
begin
  BackgroundCss := LclColorToCss(Value);
end;

procedure TGMLclPinOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := LclColorToCss(Value);
end;

procedure TGMLclPinOptions.SetGlyphColor(const Value: TColor);
begin
  GlyphColorCss := LclColorToCss(Value);
end;

{ TGMLclLabelMarkerOptions }

function TGMLclLabelMarkerOptions.GetBackgroundColor: TColor;
begin
  Result := CssToLclColor(Trim(BackgroundCss));
end;

function TGMLclLabelMarkerOptions.GetBorderColor: TColor;
begin
  Result := CssToLclColor(Trim(BorderColorCss));
end;

function TGMLclLabelMarkerOptions.GetTextColor: TColor;
begin
  Result := CssToLclColor(Trim(TextColorCss));
end;

procedure TGMLclLabelMarkerOptions.SetBackgroundColor(const Value: TColor);
begin
  BackgroundCss := LclColorToCss(Value);
end;

procedure TGMLclLabelMarkerOptions.SetBorderColor(const Value: TColor);
begin
  BorderColorCss := LclColorToCss(Value);
end;

procedure TGMLclLabelMarkerOptions.SetTextColor(const Value: TColor);
begin
  TextColorCss := LclColorToCss(Value);
end;

{ TGMLclMarkerOptions }

function TGMLclMarkerOptions.CreateLabelOptions: TGMLabelMarkerOptions;
begin
  Result := TGMLclLabelMarkerOptions.Create;
end;

function TGMLclMarkerOptions.CreatePinOptions: TGMPinOptions;
begin
  Result := TGMLclPinOptions.Create;
end;

function TGMLclMarkerOptions.GetLabelOptions: TGMLclLabelMarkerOptions;
begin
  Result := TGMLclLabelMarkerOptions(inherited LabelOptions);
end;

function TGMLclMarkerOptions.GetPinOptions: TGMLclPinOptions;
begin
  Result := TGMLclPinOptions(inherited PinOptions);
end;

procedure TGMLclMarkerOptions.SetLabelOptions(const Value: TGMLclLabelMarkerOptions);
begin
  inherited LabelOptions := Value;
end;

procedure TGMLclMarkerOptions.SetPinOptions(const Value: TGMLclPinOptions);
begin
  inherited PinOptions := Value;
end;

{ TGMLclMarkerItem }

function TGMLclMarkerItem.CreateMarkerOptions: TGMMarkerOptions;
begin
  Result := TGMLclMarkerOptions.Create;
end;

function TGMLclMarkerItem.GetOptions: TGMLclMarkerOptions;
begin
  Result := TGMLclMarkerOptions(inherited Options);
end;

procedure TGMLclMarkerItem.SetOptions(const Value: TGMLclMarkerOptions);
begin
  inherited Options := Value;
end;

{ TGMLclMarkers }

function TGMLclMarkers.Add: TGMLclMarkerItem;
begin
  Result := TGMLclMarkerItem(inherited Add);
end;

constructor TGMLclMarkers.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMLclMarkerItem);
end;

function TGMLclMarkers.GetItem(Index: Integer): TGMLclMarkerItem;
begin
  Result := TGMLclMarkerItem(inherited Items[Index]);
end;

procedure TGMLclMarkers.SetItem(Index: Integer; const Value: TGMLclMarkerItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
