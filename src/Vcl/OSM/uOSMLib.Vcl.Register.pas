{**
  @abstract(Design-time registration for OSMLib VCL components.)
}
unit uOSMLib.Vcl.Register;

{$I ..\..\..\gmlib.inc}

interface

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  uOSMLib.Vcl.Map;

procedure Register;
begin
  RegisterComponents('MapLib', [TOSMLibVclMap]);
end;

end.
