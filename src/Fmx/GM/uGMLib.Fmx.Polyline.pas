{**
  @abstract(Especializaciones FMX del modelo de polylines.)
}
unit uGMLib.Fmx.Polyline;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.UITypes,
  uGMLib.Polyline;

type
  TGMFmxPolylineOptions = class(TGMPolylineOptions)
  private
    function GetStrokeColorValue: TAlphaColor;
    procedure SetStrokeColorValue(const Value: TAlphaColor);
  published
    property APIUrl;
    property Clickable;
    property Draggable;
    property Editable;
    property Geodesic;
    property Path;
    property StrokeColor: TAlphaColor read GetStrokeColorValue write SetStrokeColorValue default 0;
    property StrokeOpacity;
    property StrokeWeight;
    property Visible;
    property ZIndex;
  end;

  TGMFmxPolylineItem = class(TGMPolylineItem)
  private
    function GetOptions: TGMFmxPolylineOptions;
    procedure SetOptions(const Value: TGMFmxPolylineOptions);
  protected
    function CreatePolylineOptions: TGMPolylineOptions; override;
  published
    property APIUrl;
    property Options: TGMFmxPolylineOptions read GetOptions write SetOptions;
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

  TGMFmxPolylines = class(TGMPolylines)
  private
    function GetItem(Index: Integer): TGMFmxPolylineItem;
    procedure SetItem(Index: Integer; const Value: TGMFmxPolylineItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMFmxPolylineItem;
  published
    property APIUrl;
  public
    property Items[Index: Integer]: TGMFmxPolylineItem read GetItem write SetItem; default;
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

{ TGMFmxPolylineOptions }

function TGMFmxPolylineOptions.GetStrokeColorValue: TAlphaColor;
begin
  Result := CssToAlphaColor(Trim(inherited StrokeColor));
end;

procedure TGMFmxPolylineOptions.SetStrokeColorValue(const Value: TAlphaColor);
begin
  inherited StrokeColor := AlphaColorToCss(Value);
end;

{ TGMFmxPolylineItem }

function TGMFmxPolylineItem.CreatePolylineOptions: TGMPolylineOptions;
begin
  Result := TGMFmxPolylineOptions.Create;
end;

function TGMFmxPolylineItem.GetOptions: TGMFmxPolylineOptions;
begin
  Result := TGMFmxPolylineOptions(inherited Options);
end;

procedure TGMFmxPolylineItem.SetOptions(const Value: TGMFmxPolylineOptions);
begin
  inherited Options := Value;
end;

{ TGMFmxPolylines }

function TGMFmxPolylines.Add: TGMFmxPolylineItem;
begin
  Result := TGMFmxPolylineItem(inherited Add);
end;

constructor TGMFmxPolylines.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMFmxPolylineItem);
end;

function TGMFmxPolylines.GetItem(Index: Integer): TGMFmxPolylineItem;
begin
  Result := TGMFmxPolylineItem(inherited Items[Index]);
end;

procedure TGMFmxPolylines.SetItem(Index: Integer; const Value: TGMFmxPolylineItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
