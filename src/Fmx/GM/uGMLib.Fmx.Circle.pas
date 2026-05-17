{**
  @abstract(Especializaciones FMX del modelo de círculos.)
  }
unit uGMLib.Fmx.Circle;

 {$I ..\..\gmlib.inc}

interface

uses
  System.Classes, System.UITypes, uGMLib.Circle;

type
  TGMFmxCircleOptions = class(TGMCircleOptions)
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
    property Radius;
    property StrokeColor: TAlphaColor read GetStrokeColorValue write SetStrokeColorValue default 0;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMFmxCircleItem = class(TGMCircleItem)
  private
    function GetOptions: TGMFmxCircleOptions;
    procedure SetOptions(const Value: TGMFmxCircleOptions);
  protected
    function CreateCircleOptions: TGMCircleOptions; override;
  published
    property Options: TGMFmxCircleOptions read GetOptions write SetOptions;
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

  TGMFmxCircles = class(TGMCircles)
  private
    function GetItem(Index: Integer): TGMFmxCircleItem;
    procedure SetItem(Index: Integer; const Value: TGMFmxCircleItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMFmxCircleItem;
  public
    property Items[Index: Integer]: TGMFmxCircleItem read GetItem write SetItem; default;
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

 { TGMFmxCircleOptions }

function TGMFmxCircleOptions.GetFillColorValue: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(inherited FillColor));
end;

function TGMFmxCircleOptions.GetStrokeColorValue: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(inherited StrokeColor));
end;

procedure TGMFmxCircleOptions.SetFillColorValue(const Value: TAlphaColor);
begin
  inherited FillColor := AlphaColorToCss(Value);
end;

procedure TGMFmxCircleOptions.SetStrokeColorValue(const Value: TAlphaColor);
begin
  inherited StrokeColor := AlphaColorToCss(Value);
end;

 { TGMFmxCircleItem }

function TGMFmxCircleItem.CreateCircleOptions: TGMCircleOptions;
begin
  Result := TGMFmxCircleOptions.Create;
end;

function TGMFmxCircleItem.GetOptions: TGMFmxCircleOptions;
begin
  Result := TGMFmxCircleOptions(inherited Options);
end;

procedure TGMFmxCircleItem.SetOptions(const Value: TGMFmxCircleOptions);
begin
  inherited Options := Value;
end;

 { TGMFmxCircles }

function TGMFmxCircles.Add: TGMFmxCircleItem;
begin
  Result := TGMFmxCircleItem(inherited Add);
end;

constructor TGMFmxCircles.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMFmxCircleItem);
end;

function TGMFmxCircles.GetItem(Index: Integer): TGMFmxCircleItem;
begin
  Result := TGMFmxCircleItem(inherited Items[Index]);
end;

procedure TGMFmxCircles.SetItem(Index: Integer; const Value: TGMFmxCircleItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.

