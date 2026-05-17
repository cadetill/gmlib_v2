{**
  @abstract(Registro design-time de los componentes LCL de GMLib.)
}
unit uGMLib.Lcl.Register;

{$I ..\..\..\gmlib.inc}

interface

procedure Register;

implementation

{$R ..\..\..\resources\GMLibMap.res}

uses
  Classes,
  uGMLib.Lcl.Map;

procedure Register;
begin
  RegisterComponents('MapLib', [TGMLibLclMap]);
end;

end.
