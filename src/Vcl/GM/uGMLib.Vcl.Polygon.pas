{**
  @abstract(Especializaciones VCL del modelo de polÃ­gonos.)
}
unit uGMLib.Vcl.Polygon;

{$I ..\..\..\gmlib.inc}

interface

uses
  System.Classes,
  Vcl.Graphics,
  uGMLib.Polygon;

type
  TGMVclPolygonOptions = class(TGMPolygonOptions)
  private
    function GetFillColorValue: TColor;
    function GetStrokeColorValue: TColor;
    procedure SetFillColorValue(const Value: TColor);
    procedure SetStrokeColorValue(const Value: TColor);
  published
    property APIUrl;
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

  TGMVclPolygonItem = class(TGMPolygonItem)
  private
    function GetOptions: TGMVclPolygonOptions;
    procedure SetOptions(const Value: TGMVclPolygonOptions);
  protected
    function CreatePolygonOptions: TGMPolygonOptions; override;
  published
    property APIUrl;
    property Options: TGMVclPolygonOptions read GetOptions write SetOptions;
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

  TGMVclPolygons = class(TGMPolygons)
  private
    function GetItem(Index: Integer): TGMVclPolygonItem;
    procedure SetItem(Index: Integer; const Value: TGMVclPolygonItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMVclPolygonItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMVclPolygonItem read GetItem write SetItem; default;
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

{ TGMVclPolygonOptions }

function TGMVclPolygonOptions.GetFillColorValue: TColor;
begin
  Result := CssToVclColor(Trim(inherited FillColor));
end;

function TGMVclPolygonOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToVclColor(Trim(inherited StrokeColor));
end;

procedure TGMVclPolygonOptions.SetFillColorValue(const Value: TColor);
begin
  inherited FillColor := VclColorToCss(Value);
end;

procedure TGMVclPolygonOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := VclColorToCss(Value);
end;

{ TGMVclPolygonItem }

function TGMVclPolygonItem.CreatePolygonOptions: TGMPolygonOptions;
begin
  Result := TGMVclPolygonOptions.Create;
end;

function TGMVclPolygonItem.GetOptions: TGMVclPolygonOptions;
begin
  Result := TGMVclPolygonOptions(inherited Options);
end;

procedure TGMVclPolygonItem.SetOptions(const Value: TGMVclPolygonOptions);
begin
  inherited Options := Value;
end;

{ TGMVclPolygons }

function TGMVclPolygons.Add: TGMVclPolygonItem;
begin
  Result := TGMVclPolygonItem(inherited Add);
end;

constructor TGMVclPolygons.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMVclPolygonItem);
end;

function TGMVclPolygons.GetItem(Index: Integer): TGMVclPolygonItem;
begin
  Result := TGMVclPolygonItem(inherited Items[Index]);
end;

procedure TGMVclPolygons.SetItem(Index: Integer; const Value: TGMVclPolygonItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.

