{**
  @abstract(Base común para componentes de GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define la clase base compartida por los componentes públicos de
  GMLib.
}
unit uGMLib.Core.Component;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes;
{$ELSE}
  System.Classes;
{$ENDIF}

type
  {** @abstract(Clase base común para componentes instalables de GMLib.) }
  TGMLibComponent = class(TComponent)
  private
    function GetAboutGMLib: string;
  protected
    function GetAPIUrl: string; virtual;
  public
    property APIUrl: string read GetAPIUrl;
  published
    {** @abstract(Información básica de la librería.) }
    property AboutGMLib: string read GetAboutGMLib stored False;
  end;

implementation

{ TGMLibComponent }

function TGMLibComponent.GetAboutGMLib: string;
begin
  Result := 'GMLib';
end;

function TGMLibComponent.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

end.
