{**
  @abstract(Especializaciones VCL del modelo de rectángulos.)
 }
unit uGMLib.Vcl.Rectangle;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  Vcl.Graphics,
  uGMLib.Rectangle;

type
  TGMVclRectangleOptions = class(TGMRectangleOptions)
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
    property Bounds;
    property StrokeColor: TColor read GetStrokeColorValue write SetStrokeColorValue default clNone;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMVclRectangleItem = class(TGMRectangleItem)
  private
    function GetOptions: TGMVclRectangleOptions;
    procedure SetOptions(const Value: TGMVclRectangleOptions);
  protected
    function CreateRectangleOptions: TGMRectangleOptions; override;
  published
    property Options: TGMVclRectangleOptions read GetOptions write SetOptions;
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

  TGMVclRectangles = class(TGMRectangles)
  private
    function GetItem(Index: Integer): TGMVclRectangleItem;
    procedure SetItem(Index: Integer; const Value: TGMVclRectangleItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMVclRectangleItem;
  public
    property Items[Index: Integer]: TGMVclRectangleItem read GetItem write SetItem; default;
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

{ TGMVclRectangleOptions }

function TGMVclRectangleOptions.GetFillColorValue: TColor;
begin
  Result := CssToVclColor(Trim(inherited FillColor));
end;

function TGMVclRectangleOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToVclColor(Trim(inherited StrokeColor));
end;

procedure TGMVclRectangleOptions.SetFillColorValue(const Value: TColor);
begin
  inherited FillColor := VclColorToCss(Value);
end;

procedure TGMVclRectangleOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := VclColorToCss(Value);
end;

{ TGMVclRectangleItem }

function TGMVclRectangleItem.CreateRectangleOptions: TGMRectangleOptions;
begin
  Result := TGMVclRectangleOptions.Create;
end;

function TGMVclRectangleItem.GetOptions: TGMVclRectangleOptions;
begin
  Result := TGMVclRectangleOptions(inherited Options);
end;

procedure TGMVclRectangleItem.SetOptions(const Value: TGMVclRectangleOptions);
begin
  inherited Options := Value;
end;

{ TGMVclRectangles }

function TGMVclRectangles.Add: TGMVclRectangleItem;
begin
  Result := TGMVclRectangleItem(inherited Add);
end;

constructor TGMVclRectangles.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMVclRectangleItem);
end;

function TGMVclRectangles.GetItem(Index: Integer): TGMVclRectangleItem;
begin
  Result := TGMVclRectangleItem(inherited Items[Index]);
end;

procedure TGMVclRectangles.SetItem(Index: Integer; const Value: TGMVclRectangleItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
