{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit GMLibDesign.Lcl;

{$warn 5023 off : no warning about unused units}
interface

uses
  uGMLib.Lcl.Register, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uGMLib.Lcl.Register', @uGMLib.Lcl.Register.Register);
end;

initialization
  RegisterPackage('GMLibDesign.Lcl', @Register);
end.
