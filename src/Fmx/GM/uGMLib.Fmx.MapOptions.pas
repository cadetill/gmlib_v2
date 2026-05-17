{**
  @abstract(Especializaciones FMX de las opciones del mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad añade propiedades visuales específicas de `FMX` sobre el bloque
  común de opciones del mapa.
}
unit uGMLib.Fmx.MapOptions;

{$I ..\..\gmlib.inc}

interface

uses
  System.UITypes,
  uGMLib.MapOptions;

type
  {** @abstract(Bloque de opciones del mapa enriquecido con tipos FMX.) }
  TGMFmxMapOptions = class(TGMMapOptions)
  private
    function GetBackgroundColor: TAlphaColor;
    procedure SetBackgroundColor(const Value: TAlphaColor);
  published
    {** @abstract(Color de fondo FMX serializado a CSS para Google Maps.) }
    property BackgroundColor: TAlphaColor read GetBackgroundColor write SetBackgroundColor default 0;
  end;

implementation

uses
  System.SysUtils;

{ TGMFmxMapOptions }

function TGMFmxMapOptions.GetBackgroundColor: TAlphaColor;
var
  cssValue: string;
  rgbValue: Integer;
begin
  cssValue := Trim(BackgroundColorCss);
  if cssValue = '' then
    Exit(0);

  if (Length(cssValue) = 7) and (cssValue[1] = '#') then
  begin
    rgbValue := StrToIntDef('$' + Copy(cssValue, 2, 6), -1);
    if rgbValue >= 0 then
      Exit($FF000000 or Cardinal(rgbValue));
  end;

  Result := 0;
end;

procedure TGMFmxMapOptions.SetBackgroundColor(const Value: TAlphaColor);
var
  red: Byte;
  green: Byte;
  blue: Byte;
begin
  if Value = 0 then
  begin
    BackgroundColorCss := '';
    Exit;
  end;

  red := (Value shr 16) and $FF;
  green := (Value shr 8) and $FF;
  blue := Value and $FF;
  BackgroundColorCss := Format('#%.2x%.2x%.2x', [red, green, blue]);
end;

end.
