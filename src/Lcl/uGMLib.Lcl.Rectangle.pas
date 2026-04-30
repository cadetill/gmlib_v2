{**
  @abstract(Especializaciones LCL del modelo de rectángulos.)
}
unit uGMLib.Lcl.Rectangle;

{$I ..\..\gmlib.inc}

interface

uses
  Classes,
  Graphics,
  uGMLib.MapOptions,
  uGMLib.Rectangle;

type
  TGMLclRectangleOptions = class(TGMRectangleOptions)
  private
    function GetFillColorValue: TColor;
    function GetBoundsValue: TGMLatLngBounds;
    function GetStrokeColorValue: TColor;
    procedure SetFillColorValue(const Value: TColor);
    procedure SetBoundsValue(const Value: TGMLatLngBounds);
    procedure SetStrokeColorValue(const Value: TColor);
  published
    property Clickable;
    property Draggable;
    property Editable;
    property FillColor: TColor read GetFillColorValue write SetFillColorValue default clNone;
    property FillOpacity;
    property LatLngBounds: TGMLatLngBounds read GetBoundsValue write SetBoundsValue;
    property StrokeColor: TColor read GetStrokeColorValue write SetStrokeColorValue default clNone;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMLclRectangleItem = class(TGMRectangleItem)
  private
    function GetOptions: TGMLclRectangleOptions;
    procedure SetOptions(const Value: TGMLclRectangleOptions);
  protected
    function CreateRectangleOptions: TGMRectangleOptions; override;
  published
    property Options: TGMLclRectangleOptions read GetOptions write SetOptions;
    property OnBoundsChanged;
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
  end;

  TGMLclRectangles = class(TGMRectangles)
  private
    function GetItem(Index: Integer): TGMLclRectangleItem;
    procedure SetItem(Index: Integer; const Value: TGMLclRectangleItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMLclRectangleItem;
  public
    property Items[Index: Integer]: TGMLclRectangleItem read GetItem write SetItem; default;
  end;

implementation

uses
  SysUtils,
  Windows;

function CssToLclColor(const ACssValue: string): TColor;
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

function LclColorToCss(const AColor: TColor): string;
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

{ TGMLclRectangleOptions }

function TGMLclRectangleOptions.GetFillColorValue: TColor;
begin
  Result := CssToLclColor(Trim(inherited FillColor));
end;

function TGMLclRectangleOptions.GetBoundsValue: TGMLatLngBounds;
begin
  Result := inherited Bounds;
end;

function TGMLclRectangleOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToLclColor(Trim(inherited StrokeColor));
end;

procedure TGMLclRectangleOptions.SetFillColorValue(const Value: TColor);
begin
  inherited FillColor := LclColorToCss(Value);
end;

procedure TGMLclRectangleOptions.SetBoundsValue(const Value: TGMLatLngBounds);
begin
  inherited Bounds := Value;
end;

procedure TGMLclRectangleOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := LclColorToCss(Value);
end;

{ TGMLclRectangleItem }

function TGMLclRectangleItem.CreateRectangleOptions: TGMRectangleOptions;
begin
  Result := TGMLclRectangleOptions.Create;
end;

function TGMLclRectangleItem.GetOptions: TGMLclRectangleOptions;
begin
  Result := TGMLclRectangleOptions(inherited Options);
end;

procedure TGMLclRectangleItem.SetOptions(const Value: TGMLclRectangleOptions);
begin
  inherited Options := Value;
end;

{ TGMLclRectangles }

function TGMLclRectangles.Add: TGMLclRectangleItem;
begin
  Result := TGMLclRectangleItem(inherited Add);
end;

constructor TGMLclRectangles.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMLclRectangleItem);
end;

function TGMLclRectangles.GetItem(Index: Integer): TGMLclRectangleItem;
begin
  Result := TGMLclRectangleItem(inherited Items[Index]);
end;

procedure TGMLclRectangles.SetItem(Index: Integer; const Value: TGMLclRectangleItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
