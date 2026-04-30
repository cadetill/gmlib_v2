{**
  @abstract(Especializaciones VCL del modelo de círculos.)
  }
unit uGMLib.Vcl.Circle;

 {$I ..\..\gmlib.inc}

interface

uses
  System.Classes, Vcl.Graphics, uGMLib.Circle;

type
  TGMVclCircleOptions = class(TGMCircleOptions)
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

  TGMVclCircleItem = class(TGMCircleItem)
  private
    function GetOptions: TGMVclCircleOptions;
    procedure SetOptions(const Value: TGMVclCircleOptions);
  protected
    function CreateCircleOptions: TGMCircleOptions; override;
  published
    property Options: TGMVclCircleOptions read GetOptions write SetOptions;
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

  TGMVclCircles = class(TGMCircles)
  private
    function GetItem(Index: Integer): TGMVclCircleItem;
    procedure SetItem(Index: Integer; const Value: TGMVclCircleItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMVclCircleItem;
  public
    property Items[Index: Integer]: TGMVclCircleItem read GetItem write SetItem; default;
  end;

implementation

uses
  System.SysUtils, Winapi.Windows;

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
  Result := Format('#%.2x%.2x%.2x', [GetRValue(RgbColor), GetGValue(RgbColor), GetBValue(RgbColor)]);
end;

 { TGMVclCircleOptions }

function TGMVclCircleOptions.GetFillColorValue: TColor;
begin
  Result := CssToVclColor(Trim(inherited FillColor));
end;

function TGMVclCircleOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToVclColor(Trim(inherited StrokeColor));
end;

procedure TGMVclCircleOptions.SetFillColorValue(const Value: TColor);
begin
  inherited FillColor := VclColorToCss(Value);
end;

procedure TGMVclCircleOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := VclColorToCss(Value);
end;

 { TGMVclCircleItem }

function TGMVclCircleItem.CreateCircleOptions: TGMCircleOptions;
begin
  Result := TGMVclCircleOptions.Create;
end;

function TGMVclCircleItem.GetOptions: TGMVclCircleOptions;
begin
  Result := TGMVclCircleOptions(inherited Options);
end;

procedure TGMVclCircleItem.SetOptions(const Value: TGMVclCircleOptions);
begin
  inherited Options := Value;
end;

 { TGMVclCircles }

function TGMVclCircles.Add: TGMVclCircleItem;
begin
  Result := TGMVclCircleItem(inherited Add);
end;

constructor TGMVclCircles.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMVclCircleItem);
end;

function TGMVclCircles.GetItem(Index: Integer): TGMVclCircleItem;
begin
  Result := TGMVclCircleItem(inherited Items[Index]);
end;

procedure TGMVclCircles.SetItem(Index: Integer; const Value: TGMVclCircleItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.

