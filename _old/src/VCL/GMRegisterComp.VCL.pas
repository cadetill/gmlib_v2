{
  @abstract(Registration VCL components.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(January 2, 2016)
  @lastmod(January 2, 2016)
}
unit GMRegisterComp.VCL;

{$I ..\gmlib.inc}

{$IFNDEF DELPHI2009}
{$R ..\Resources\gmlibres.res}
{$ENDIF}

interface

  {
    Register procedure register the components.
  }
  procedure Register;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.Classes, Vcl.Controls,
  {$ELSE}
  Classes, Controls,
  {$ENDIF}

  GMMap.VCL;

procedure Register;
begin
  {$IFDEF DELPHIXE2}
  GroupDescendentsWith(TGMMap, Vcl.Controls.TControl);
  {$ENDIF}

  RegisterComponents('GoogleMaps', [TGMMap]);
end;

end.

