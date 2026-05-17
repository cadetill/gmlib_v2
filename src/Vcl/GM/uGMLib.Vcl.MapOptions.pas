{**
  @abstract(Especializaciones VCL de las opciones del mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad aÃ±ade propiedades visuales especÃ­ficas de VCL sobre el bloque
  comÃºn de opciones del mapa.
}
unit uGMLib.Vcl.MapOptions;

{$I ..\..\..\gmlib.inc}

interface

uses
  Vcl.Graphics,
  uGMLib.MapOptions;

type
  {** @abstract(Bloque de opciones del mapa enriquecido con tipos VCL.) }
  TGMVclMapOptions = class(TGMMapOptions)
  private
    function GetBackgroundColor: TColor;
    procedure SetBackgroundColor(const Value: TColor);
  published
    {** @abstract(Color de fondo VCL serializado a CSS para Google Maps.) }
    property BackgroundColor: TColor read GetBackgroundColor write SetBackgroundColor default clNone;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

{ TGMVclMapOptions }

function TGMVclMapOptions.GetBackgroundColor: TColor;
var
  CssValue: string;
  RgbValue: Integer;
begin
  CssValue := Trim(BackgroundColorCss);
  if CssValue = '' then
    Exit(clNone);

  if (Length(CssValue) = 7) and (CssValue[1] = '#') then
  begin
    RgbValue := StrToIntDef('$' + Copy(CssValue, 2, 6), -1);
    if RgbValue >= 0 then
      Exit(RGB(GetBValue(RgbValue), GetGValue(RgbValue), GetRValue(RgbValue)));
  end;

  Result := clNone;
end;

procedure TGMVclMapOptions.SetBackgroundColor(const Value: TColor);
var
  RgbColor: TColor;
begin
  if Value = clNone then
  begin
    BackgroundColorCss := '';
    Exit;
  end;

  RgbColor := ColorToRGB(Value);
  BackgroundColorCss := Format(
    '#%.2x%.2x%.2x',
    [GetRValue(RgbColor), GetGValue(RgbColor), GetBValue(RgbColor)]
  );
end;

end.

