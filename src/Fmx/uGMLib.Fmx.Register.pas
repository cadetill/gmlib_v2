{**
  @abstract(Registro design-time de los componentes FMX de GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad registra en la paleta del IDE los componentes FMX instalables de
  GMLib.
}
unit uGMLib.Fmx.Register;

{$I ..\..\gmlib.inc}

interface

procedure Register;

implementation

{$R ..\..\resources\GMLibMap.res}

uses
  System.Classes,
  DesignIntf,
  uGMLib.Fmx.Map;

procedure Register;
begin
  RegisterComponents('GMLib', [TGMLibFmxMap]);
end;

end.
