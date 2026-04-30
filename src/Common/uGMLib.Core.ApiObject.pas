{**
  @abstract(Base común para objetos Delphi que envuelven elementos de la API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define una clase base ligera con soporte de `APIUrl` y notificación
  de cambios para el nuevo núcleo.
}
unit uGMLib.Core.ApiObject;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes;
{$ELSE}
  System.Classes;
{$ENDIF}

type
  {** @abstract(Clase base con metadatos comunes de la API de Google Maps.) }
  TGMLibApiObject = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FOwner: TPersistent;
  protected
    function GetAPIUrl: string; virtual;
    function GetOwner: TPersistent; override;
    procedure Changed; virtual;
  public
    constructor Create; virtual;

    procedure Assign(Source: TPersistent); override;

    {** @abstract(URL de referencia de la API de Google Maps.) }
    property APIUrl: string read GetAPIUrl;

    {** @abstract(Notificación de cambio del objeto.) }
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Owner: TPersistent read FOwner write FOwner;
  end;

implementation

{ TGMLibApiObject }

constructor TGMLibApiObject.Create;
begin
  inherited Create;
end;

procedure TGMLibApiObject.Assign(Source: TPersistent);
begin
  if Source = Self then
    Exit;

  // This base class intentionally has no copyable value state.
  // Descendants are expected to implement their own Assign logic.
  if Source is TGMLibApiObject then
    Exit;

  inherited;
end;

procedure TGMLibApiObject.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TGMLibApiObject.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TGMLibApiObject.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

end.
