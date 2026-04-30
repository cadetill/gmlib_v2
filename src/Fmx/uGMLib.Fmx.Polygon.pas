{**
  @abstract(Especializaciones FMX del modelo de polígonos.)
}
unit uGMLib.Fmx.Polygon;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.UITypes,
  uGMLib.Polygon;

type
  TGMFmxPolygonOptions = class(TGMPolygonOptions)
  private
    function GetFillColorValue: TAlphaColor;
    function GetStrokeColorValue: TAlphaColor;
    procedure SetFillColorValue(const Value: TAlphaColor);
    procedure SetStrokeColorValue(const Value: TAlphaColor);
  published
    property APIUrl;
    property Clickable;
    property Draggable;
    property Editable;
    property FillColor: TAlphaColor read GetFillColorValue write SetFillColorValue default 0;
    property FillOpacity;
    property Geodesic;
    property Path;
    property StrokeColor: TAlphaColor read GetStrokeColorValue write SetStrokeColorValue default 0;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMFmxPolygonItem = class(TGMPolygonItem)
  private
    function GetOptions: TGMFmxPolygonOptions;
    procedure SetOptions(const Value: TGMFmxPolygonOptions);
  protected
    function CreatePolygonOptions: TGMPolygonOptions; override;
  published
    property APIUrl;
    property Options: TGMFmxPolygonOptions read GetOptions write SetOptions;
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

  TGMFmxPolygons = class(TGMPolygons)
  private
    function GetItem(Index: Integer): TGMFmxPolygonItem;
    procedure SetItem(Index: Integer; const Value: TGMFmxPolygonItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMFmxPolygonItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMFmxPolygonItem read GetItem write SetItem; default;
  end;

implementation

uses
  System.SysUtils;

function CssToAlphaColor(const ACssValue: string): TAlphaColor;
var
  RgbValue: Integer;
begin
  if (Length(ACssValue) = 7) and (ACssValue[1] = '#') then
  begin
    RgbValue := StrToIntDef('$' + Copy(ACssValue, 2, 6), -1);
    if RgbValue >= 0 then
      Exit($FF000000 or Cardinal(RgbValue));
  end;

  Result := 0;
end;

function AlphaColorToCss(const AColor: TAlphaColor): string;
var
  Red: Byte;
  Green: Byte;
  Blue: Byte;
begin
  if AColor = 0 then
    Exit('');

  Red := (AColor shr 16) and $FF;
  Green := (AColor shr 8) and $FF;
  Blue := AColor and $FF;
  Result := Format('#%.2x%.2x%.2x', [Red, Green, Blue]);
end;

{ TGMFmxPolygonOptions }

function TGMFmxPolygonOptions.GetFillColorValue: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(inherited FillColor));
end;

function TGMFmxPolygonOptions.GetStrokeColorValue: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(inherited StrokeColor));
end;

procedure TGMFmxPolygonOptions.SetFillColorValue(const Value: TAlphaColor);
begin
  inherited FillColor := AlphaColorToCss(Value);
end;

procedure TGMFmxPolygonOptions.SetStrokeColorValue(const Value: TAlphaColor);
begin
  inherited StrokeColor := AlphaColorToCss(Value);
end;

{ TGMFmxPolygonItem }

function TGMFmxPolygonItem.CreatePolygonOptions: TGMPolygonOptions;
begin
  Result := TGMFmxPolygonOptions.Create;
end;

function TGMFmxPolygonItem.GetOptions: TGMFmxPolygonOptions;
begin
  Result := TGMFmxPolygonOptions(inherited Options);
end;

procedure TGMFmxPolygonItem.SetOptions(const Value: TGMFmxPolygonOptions);
begin
  inherited Options := Value;
end;

{ TGMFmxPolygons }

function TGMFmxPolygons.Add: TGMFmxPolygonItem;
begin
  Result := TGMFmxPolygonItem(inherited Add);
end;

constructor TGMFmxPolygons.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMFmxPolygonItem);
end;

function TGMFmxPolygons.GetItem(Index: Integer): TGMFmxPolygonItem;
begin
  Result := TGMFmxPolygonItem(inherited Items[Index]);
end;

procedure TGMFmxPolygons.SetItem(Index: Integer; const Value: TGMFmxPolygonItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
