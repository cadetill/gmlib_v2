{**
  @abstract(Especializaciones LCL del modelo de polígonos.)
}
unit uGMLib.Lcl.Polygon;

{$I ..\..\gmlib.inc}

interface

uses
  Classes,
  Graphics,
  uGMLib.Polygon;

type
  TGMLclPolygonOptions = class(TGMPolygonOptions)
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
    property Geodesic;
    property Path;
    property StrokeColor: TColor read GetStrokeColorValue write SetStrokeColorValue default clNone;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMLclPolygonItem = class(TGMPolygonItem)
  private
    function GetOptions: TGMLclPolygonOptions;
    procedure SetOptions(const Value: TGMLclPolygonOptions);
  protected
    function CreatePolygonOptions: TGMPolygonOptions; override;
  published
    property Options: TGMLclPolygonOptions read GetOptions write SetOptions;
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
    property OnPathChanged;
  end;

  TGMLclPolygons = class(TGMPolygons)
  private
    function GetItem(Index: Integer): TGMLclPolygonItem;
    procedure SetItem(Index: Integer; const Value: TGMLclPolygonItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMLclPolygonItem;
  public
    property Items[Index: Integer]: TGMLclPolygonItem read GetItem write SetItem; default;
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

{ TGMLclPolygonOptions }

function TGMLclPolygonOptions.GetFillColorValue: TColor;
begin
  Result := CssToLclColor(Trim(inherited FillColor));
end;

function TGMLclPolygonOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToLclColor(Trim(inherited StrokeColor));
end;

procedure TGMLclPolygonOptions.SetFillColorValue(const Value: TColor);
begin
  inherited FillColor := LclColorToCss(Value);
end;

procedure TGMLclPolygonOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := LclColorToCss(Value);
end;

{ TGMLclPolygonItem }

function TGMLclPolygonItem.CreatePolygonOptions: TGMPolygonOptions;
begin
  Result := TGMLclPolygonOptions.Create;
end;

function TGMLclPolygonItem.GetOptions: TGMLclPolygonOptions;
begin
  Result := TGMLclPolygonOptions(inherited Options);
end;

procedure TGMLclPolygonItem.SetOptions(const Value: TGMLclPolygonOptions);
begin
  inherited Options := Value;
end;

{ TGMLclPolygons }

function TGMLclPolygons.Add: TGMLclPolygonItem;
begin
  Result := TGMLclPolygonItem(inherited Add);
end;

constructor TGMLclPolygons.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMLclPolygonItem);
end;

function TGMLclPolygons.GetItem(Index: Integer): TGMLclPolygonItem;
begin
  Result := TGMLclPolygonItem(inherited Items[Index]);
end;

procedure TGMLclPolygons.SetItem(Index: Integer; const Value: TGMLclPolygonItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
