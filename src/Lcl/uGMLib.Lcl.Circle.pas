{**
  @abstract(Especializaciones LCL del modelo de círculos.)
}
unit uGMLib.Lcl.Circle;

{$I ..\..\gmlib.inc}

interface

uses
  Classes,
  Graphics,
  uGMLib.Circle;

type
  TGMLclCircleOptions = class(TGMCircleOptions)
  private
    function GetFillColorValue: TColor;
    function GetStrokeColorValue: TColor;
    procedure SetFillColorValue(const Value: TColor);
    procedure SetStrokeColorValue(const Value: TColor);
  published
    property Clickable;
    property Draggable;
    property Editable;
    property FillColor: TColor read GetFillColorValue write SetFillColorValue default clNone;
    property FillOpacity;
    property Radius;
    property StrokeColor: TColor read GetStrokeColorValue write SetStrokeColorValue default clNone;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMLclCircleItem = class(TGMCircleItem)
  private
    function GetOptions: TGMLclCircleOptions;
    procedure SetOptions(const Value: TGMLclCircleOptions);
  protected
    function CreateCircleOptions: TGMCircleOptions; override;
  published
    property Options: TGMLclCircleOptions read GetOptions write SetOptions;
    property OnCenterChanged;
    property OnClick;
    property OnContextMenu;
    property OnDblClick;
    property OnDrag;
    property OnDragEnd;
    property OnDragStart;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseOut;
    property OnMouseOver;
    property OnMouseUp;
    property OnRadiusChanged;
  end;

  TGMLclCircles = class(TGMCircles)
  private
    function GetItem(Index: Integer): TGMLclCircleItem;
    procedure SetItem(Index: Integer; const Value: TGMLclCircleItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMLclCircleItem;
  public
    property Items[Index: Integer]: TGMLclCircleItem read GetItem write SetItem; default;
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

{ TGMLclCircleOptions }

function TGMLclCircleOptions.GetFillColorValue: TColor;
begin
  Result := CssToLclColor(Trim(inherited FillColor));
end;

function TGMLclCircleOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToLclColor(Trim(inherited StrokeColor));
end;

procedure TGMLclCircleOptions.SetFillColorValue(const Value: TColor);
begin
  inherited FillColor := LclColorToCss(Value);
end;

procedure TGMLclCircleOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := LclColorToCss(Value);
end;

{ TGMLclCircleItem }

function TGMLclCircleItem.CreateCircleOptions: TGMCircleOptions;
begin
  Result := TGMLclCircleOptions.Create;
end;

function TGMLclCircleItem.GetOptions: TGMLclCircleOptions;
begin
  Result := TGMLclCircleOptions(inherited Options);
end;

procedure TGMLclCircleItem.SetOptions(const Value: TGMLclCircleOptions);
begin
  inherited Options := Value;
end;

{ TGMLclCircles }

function TGMLclCircles.Add: TGMLclCircleItem;
begin
  Result := TGMLclCircleItem(inherited Add);
end;

constructor TGMLclCircles.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMLclCircleItem);
end;

function TGMLclCircles.GetItem(Index: Integer): TGMLclCircleItem;
begin
  Result := TGMLclCircleItem(inherited Items[Index]);
end;

procedure TGMLclCircles.SetItem(Index: Integer; const Value: TGMLclCircleItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
