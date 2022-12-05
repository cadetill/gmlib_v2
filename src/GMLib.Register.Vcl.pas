{
  @abstract(Register GMLib Vcl components.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 28, 2022)
  @lastmod(August 28, 2022)
}
unit GMLib.Register.Vcl;

{$I ..\gmlib.inc}

{$IFNDEF DELPHI2009}
{$R ..\Resources\gmlibres.res}
{$ENDIF}

interface

  // Registers GMLib components.
  procedure Register;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.Classes, Vcl.Controls,
  {$ELSE}
  Classes, Controls,
  {$ENDIF}

  GMLib.Map.Vcl;

procedure Register;
begin
  {$IFDEF DELPHIXE2}
//    {$IFDEF CEF4Delphi}
//  GroupDescendentsWith(TGMMapChrm, Vcl.Controls.TControl);
//    {$ENDIF}
//    {$IFDEF DELPHIALEXANDRIA}
//  GroupDescendentsWith(TGMMapEdge, Vcl.Controls.TControl);
//    {$ENDIF}
  {$ENDIF}

  {$IFDEF CEF4Delphi}
  RegisterComponents('GoogleMaps', [TGMMapChrm]);
  {$ENDIF}
  {$IFDEF DELPHIALEXANDRIA}
  RegisterComponents('GoogleMaps', [TGMMapEdge]);
  {$ENDIF}
end;

end.
