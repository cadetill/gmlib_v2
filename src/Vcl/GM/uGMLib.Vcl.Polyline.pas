{**
  @abstract(Especializaciones VCL del modelo de polylines.)
}
unit uGMLib.Vcl.Polyline;

{$I ..\..\..\gmlib.inc}

interface

uses
  System.Classes,
  Vcl.Graphics,
  uGMLib.Polyline;

type
  TGMVclPolylineOptions = class(TGMPolylineOptions)
  private
    function GetStrokeColorValue: TColor;
    procedure SetStrokeColorValue(const Value: TColor);
  published
    property APIUrl;
    property Clickable;
    property Draggable;
    property Editable;
    property Geodesic;
    property Path;
    property StrokeColor: TColor read GetStrokeColorValue write SetStrokeColorValue default clNone;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMVclPolylineItem = class(TGMPolylineItem)
  private
    function GetOptions: TGMVclPolylineOptions;
    procedure SetOptions(const Value: TGMVclPolylineOptions);
  protected
    function CreatePolylineOptions: TGMPolylineOptions; override;
  published
    property APIUrl;
    property Options: TGMVclPolylineOptions read GetOptions write SetOptions;
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
    property OnPathChanged;
    property OnMouseUp;
  end;

  TGMVclPolylines = class(TGMPolylines)
  private
    function GetItem(Index: Integer): TGMVclPolylineItem;
    procedure SetItem(Index: Integer; const Value: TGMVclPolylineItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMVclPolylineItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMVclPolylineItem read GetItem write SetItem; default;
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

{ TGMVclPolylineOptions }

function TGMVclPolylineOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToVclColor(Trim(inherited StrokeColor));
end;

procedure TGMVclPolylineOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := VclColorToCss(Value);
end;

{ TGMVclPolylineItem }

function TGMVclPolylineItem.CreatePolylineOptions: TGMPolylineOptions;
begin
  Result := TGMVclPolylineOptions.Create;
end;

function TGMVclPolylineItem.GetOptions: TGMVclPolylineOptions;
begin
  Result := TGMVclPolylineOptions(inherited Options);
end;

procedure TGMVclPolylineItem.SetOptions(const Value: TGMVclPolylineOptions);
begin
  inherited Options := Value;
end;

{ TGMVclPolylines }

function TGMVclPolylines.Add: TGMVclPolylineItem;
begin
  Result := TGMVclPolylineItem(inherited Add);
end;

constructor TGMVclPolylines.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMVclPolylineItem);
end;

function TGMVclPolylines.GetItem(Index: Integer): TGMVclPolylineItem;
begin
  Result := TGMVclPolylineItem(inherited Items[Index]);
end;

procedure TGMVclPolylines.SetItem(Index: Integer; const Value: TGMVclPolylineItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.

