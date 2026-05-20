{**
  @abstract(Tipos base compartidos del nuevo núcleo de GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define tipos simples y reutilizables para el arranque del núcleo
  de GMLib.
}
unit uGMLib.Core.Types;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
{$ELSE}
  System.Classes,
{$ENDIF}

  uMapLib.Core.Types,
  uMapLib.Core.LatLng;

type
  TMapLibLatLng = uMapLib.Core.LatLng.TMapLibLatLng;
  TGMObjectId = uMapLib.Core.Types.TGMObjectId;

  {** @abstract(Contrato mínimo para que una colección pueda hacer zoom al mapa
      sin conocer la clase concreta del host.) }
  IGMMapViewportHost = interface
    ['{2B20E9B0-10C9-49E7-950E-5D9154AA42A0}']
    procedure CenterMapTo(const ALatLng: TMapLibLatLng);
    procedure FitBounds(ANorth, ASouth, AEast, AWest: Double);
  end;

  TGMBridgeBackend = uMapLib.Core.Types.TGMBridgeBackend;

  {** @abstract(Origen lógico de un cambio de estado en el mapa.) }
  TGMChangeOrigin = (
    coDelphi,
    coJavaScript
  );

implementation

end.



