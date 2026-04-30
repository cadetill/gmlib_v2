{**
  @abstract(Registro design-time de los componentes VCL de GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad registra en la paleta del IDE los componentes VCL instalables de
  GMLib.
}
unit uGMLib.Vcl.Register;

{$I ..\..\gmlib.inc}

interface

procedure Register;

implementation

{$R ..\..\resources\GMLibMap.res}

uses
  System.Classes,
  DesignIntf,
  uGMLib.Vcl.Map;

procedure Register;
begin
  RegisterComponents('GMLib', [TGMLibVclMap]);
end;

end.
