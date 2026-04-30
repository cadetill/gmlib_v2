{**
  @abstract(Especializaciones FMX del modelo de rectángulos.)
 }
unit uGMLib.Fmx.Rectangle;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.UITypes,
  uGMLib.Rectangle;

type
  TGMFmxRectangleOptions = class(TGMRectangleOptions)
  private
    function GetFillColorValue: TAlphaColor;
    function GetStrokeColorValue: TAlphaColor;
    procedure SetFillColorValue(const Value: TAlphaColor);
    procedure SetStrokeColorValue(const Value: TAlphaColor);
  published
    property Clickable;
    property Draggable;
    property Editable;
    property FillColor: TAlphaColor read GetFillColorValue write SetFillColorValue default 0;
    property FillOpacity;
    property Bounds;
    property StrokeColor: TAlphaColor read GetStrokeColorValue write SetStrokeColorValue default 0;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMFmxRectangleItem = class(TGMRectangleItem)
  private
    function GetOptions: TGMFmxRectangleOptions;
    procedure SetOptions(const Value: TGMFmxRectangleOptions);
  protected
    function CreateRectangleOptions: TGMRectangleOptions; override;
  published
    property Options: TGMFmxRectangleOptions read GetOptions write SetOptions;
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

  TGMFmxRectangles = class(TGMRectangles)
  private
    function GetItem(Index: Integer): TGMFmxRectangleItem;
    procedure SetItem(Index: Integer; const Value: TGMFmxRectangleItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMFmxRectangleItem;
  public
    property Items[Index: Integer]: TGMFmxRectangleItem read GetItem write SetItem; default;
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

{ TGMFmxRectangleOptions }

function TGMFmxRectangleOptions.GetFillColorValue: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(inherited FillColor));
end;

function TGMFmxRectangleOptions.GetStrokeColorValue: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(inherited StrokeColor));
end;

procedure TGMFmxRectangleOptions.SetFillColorValue(const Value: TAlphaColor);
begin
  inherited FillColor := AlphaColorToCss(Value);
end;

procedure TGMFmxRectangleOptions.SetStrokeColorValue(const Value: TAlphaColor);
begin
  inherited StrokeColor := AlphaColorToCss(Value);
end;

{ TGMFmxRectangleItem }

function TGMFmxRectangleItem.CreateRectangleOptions: TGMRectangleOptions;
begin
  Result := TGMFmxRectangleOptions.Create;
end;

function TGMFmxRectangleItem.GetOptions: TGMFmxRectangleOptions;
begin
  Result := TGMFmxRectangleOptions(inherited Options);
end;

procedure TGMFmxRectangleItem.SetOptions(const Value: TGMFmxRectangleOptions);
begin
  inherited Options := Value;
end;

{ TGMFmxRectangles }

function TGMFmxRectangles.Add: TGMFmxRectangleItem;
begin
  Result := TGMFmxRectangleItem(inherited Add);
end;

constructor TGMFmxRectangles.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMFmxRectangleItem);
end;

function TGMFmxRectangles.GetItem(Index: Integer): TGMFmxRectangleItem;
begin
  Result := TGMFmxRectangleItem(inherited Items[Index]);
end;

procedure TGMFmxRectangles.SetItem(Index: Integer; const Value: TGMFmxRectangleItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
