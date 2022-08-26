{
  @abstract(Transform a data from Delphi to JS ans JS to Delphi.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 26, 2022)
  @lastmod(August 26, 2022)

  The GMLib.Transform unit contains all functions needed to transform a JavaScript value to Delphi value and viceversa.
}
unit GMLib.Transform.Vcl;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  Vcl.Graphics,
  {$ELSE}
  Graphics,
  {$ENDIF}

  GMLib.Transform;

type
  { -------------------------------------------------------------------------- }
  // @include(..\Help\docs\GMLib.Transform.TGMTransform.txt)
  TGMTransform = class(GMLib.Transform.TGMTransform)
  public
    // @include(..\Help\docs\GMLib.Transform.Vcl.TGMTransformVCL.TColorToStr.txt)
    class function TColorToStr(Color: TColor): string;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils, Winapi.Windows;
  {$ELSE}
  SysUtils, Windows;
  {$ENDIF}

{ TGMTransform }

class function TGMTransform.TColorToStr(Color: TColor): string;
  function GetRValue(rgb: LongWord): Byte;
  begin
    Result := Byte(rgb);
  end;

  function GetGValue(rgb: LongWord): Byte;
  begin
    Result := Byte(rgb shr 8);
  end;

  function GetBValue(rgb: LongWord): Byte;
  begin
    Result := Byte(rgb shr 16);
  end;
var
  tmpRGB: LongWord;
begin
  tmpRGB := ColorToRGB(Color);
  Result := Format('#%.2x%.2x%.2x',
                   [GetRValue(tmpRGB),
                    GetGValue(tmpRGB),
                    GetBValue(tmpRGB)]);
end;

end.
