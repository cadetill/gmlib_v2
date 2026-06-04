{**
  @abstract(Especializaciones LCL del modelo de polylines.)
}
unit uGMLib.Lcl.Polyline;

{$I ..\..\..\gmlib.inc}

interface

uses
  Classes,
  Graphics,
  uGMLib.Polyline;

type
  TGMLclPolylineOptions = class(TGMPolylineOptions)
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

  TGMLclPolylineItem = class(TGMPolylineItem)
  private
    function GetOptions: TGMLclPolylineOptions;
    procedure SetOptions(const Value: TGMLclPolylineOptions);
  protected
    function CreatePolylineOptions: TGMPolylineOptions; override;
  published
    property APIUrl;
    property Options: TGMLclPolylineOptions read GetOptions write SetOptions;
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

  TGMLclPolylines = class(TGMPolylines)
  private
    function GetItem(Index: Integer): TGMLclPolylineItem;
    procedure SetItem(Index: Integer; const Value: TGMLclPolylineItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMLclPolylineItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMLclPolylineItem read GetItem write SetItem; default;
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

{ TGMLclPolylineOptions }

function TGMLclPolylineOptions.GetStrokeColorValue: TColor;
begin
  Result := CssToLclColor(Trim(inherited StrokeColor));
end;

procedure TGMLclPolylineOptions.SetStrokeColorValue(const Value: TColor);
begin
  inherited StrokeColor := LclColorToCss(Value);
end;

{ TGMLclPolylineItem }

function TGMLclPolylineItem.CreatePolylineOptions: TGMPolylineOptions;
begin
  Result := TGMLclPolylineOptions.Create;
end;

function TGMLclPolylineItem.GetOptions: TGMLclPolylineOptions;
begin
  Result := TGMLclPolylineOptions(inherited Options);
end;

procedure TGMLclPolylineItem.SetOptions(const Value: TGMLclPolylineOptions);
begin
  inherited Options := Value;
end;

{ TGMLclPolylines }

function TGMLclPolylines.Add: TGMLclPolylineItem;
begin
  Result := TGMLclPolylineItem(inherited Add);
end;

constructor TGMLclPolylines.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMLclPolylineItem);
end;

function TGMLclPolylines.GetItem(Index: Integer): TGMLclPolylineItem;
begin
  Result := TGMLclPolylineItem(inherited Items[Index]);
end;

procedure TGMLclPolylines.SetItem(Index: Integer; const Value: TGMLclPolylineItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
