{
  @abstract(Interfaces and support VCL classes for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Novembre 18, 2015)
  @lastmod(Novembre 18, 2015)

  The GMClasses.VCL unit provides access to VCL interfaces and VCL base classes used into GMLib.
}
unit GMClasses.VCL;

{$I ..\..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  Vcl.Graphics;
  {$ELSE}
  Graphics;
  {$ENDIF}

type
  { -------------------------------------------------------------------------- }
  // @include(..\..\Help\docs\GMClasses.VCL.TGMTransformVCL.txt)
  TGMTransformVCL = record
  public
    // @include(..\..\Help\docs\GMClasses.VCL.TGMTransformVCL.TColorToStr.txt)
    class function TColorToStr(Color: TColor): string; static;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils, Winapi.Windows;
  {$ELSE}
  SysUtils, Windows;
  {$ENDIF}

{ TGMTransformVCL }

class function TGMTransformVCL.TColorToStr(Color: TColor): string;
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
