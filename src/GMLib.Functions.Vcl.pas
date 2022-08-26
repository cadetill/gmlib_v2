{
  @abstract(General functions for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 21, 2022)
  @lastmod(August 21, 2022)

  The GMLib.Functions unit provides access to general functions used by GMLib.
}
unit GMLib.Functions.Vcl;

{$I ..\gmlib.inc}

interface

uses
  GMLib.Functions;

type
  // @include(..\Help\docs\GMLib.Functions.TGenFunc.txt)
  TGenFunc = class(GMLib.Functions.TGenFunc)
  public
    class procedure ProcessMessages;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  Winapi.Windows;
  {$ELSE}
  Windows;
  {$ENDIF}

{ TGenFunc }

class procedure TGenFunc.ProcessMessages;
var
  Msg: TMsg;
begin
  Sleep(1);
  while PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
    DispatchMessage(msg);
end;

end.
