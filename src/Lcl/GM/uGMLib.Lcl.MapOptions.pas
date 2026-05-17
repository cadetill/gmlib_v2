{**
  @abstract(Especializaciones LCL de las opciones del mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad aÃ±ade propiedades visuales especÃ­ficas de LCL sobre el bloque
  comÃºn de opciones del mapa.
}
unit uGMLib.Lcl.MapOptions;

{$I ..\..\..\gmlib.inc}

interface

uses
  Graphics,
  uGMLib.MapOptions;

type
  {** @abstract(Bloque de opciones del mapa enriquecido con tipos LCL.) }
  TGMLclMapOptions = class(TGMMapOptions)
  private
    function GetBackgroundColor: TColor;
    procedure SetBackgroundColor(const Value: TColor);
  published
    {** @abstract(Color de fondo LCL serializado a CSS para Google Maps.) }
    property BackgroundColor: TColor read GetBackgroundColor write SetBackgroundColor default clNone;
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

{ TGMLclMapOptions }

function TGMLclMapOptions.GetBackgroundColor: TColor;
begin
  Result := CssToLclColor(Trim(BackgroundColorCss));
end;

procedure TGMLclMapOptions.SetBackgroundColor(const Value: TColor);
begin
  BackgroundColorCss := LclColorToCss(Value);
end;

end.

