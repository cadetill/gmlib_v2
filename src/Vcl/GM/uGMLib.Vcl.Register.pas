{**
  @abstract(Registro design-time de los componentes VCL de GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad registra en la paleta del IDE los componentes VCL instalables de
  GMLib.
}
unit uGMLib.Vcl.Register;

{$I ..\..\..\gmlib.inc}

interface

procedure Register;

implementation

{$R ..\..\..\resources\GMLibMap.res}

uses
  System.Classes,
  Winapi.Windows,
  DesignIntf,
  ToolsAPI,
  uGMLib.Vcl.Map;

procedure AddBitmapToSplashScreen;
var
  SplashBitmap: HBITMAP;
  TempVersion : string;
begin
  if not Assigned(SplashScreenServices) then
    Exit;

  SplashBitmap := LoadBitmap(FindResourceHInstance(HInstance), 'GMLibSplashVcl');
  if SplashBitmap = 0 then
    Exit;

  TempVersion := '2.0.0.3';

  try
    SplashScreenServices.AddPluginBitmap(
      'GMLib VCL ' + TempVersion,
      SplashBitmap,
      False,
      'Google Maps JavaScript API wrapper'
    );
  finally
    DeleteObject(SplashBitmap);
  end;
end;

procedure Register;
begin
  RegisterComponents('MapLib', [TGMLibVclMap]);
  AddBitmapToSplashScreen;
end;

end.


