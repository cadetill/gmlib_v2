{**
  @abstract(Contratos del bridge Delphi <-> JavaScript.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define las interfaces mínimas del transporte usado entre Delphi y
  el código JavaScript del mapa.
}
unit uGMLib.Core.Bridge;

{$I ..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes{$ELSE}System.Classes{$ENDIF},
  uGMLib.Core.Messages,
  uGMLib.Core.Types;

type
  TGMBridgeMessageReceivedEvent = procedure(Sender: TObject; const AEnvelope: TGMMessageEnvelope) of object;

  {** @abstract(Contrato mínimo del transporte del bridge.) }
  IGMBridgeTransport = interface
    ['{6C149D4C-13C7-4633-9EFE-84FFCF933A4B}']
    function GetBackend: TGMBridgeBackend;
    function GetIsReady: Boolean;
    procedure AttachBrowser(const ABrowser: TComponent);
    procedure LoadHtml(const AHtml: string);
    procedure ExecuteJavaScript(const AScript: string);
    procedure PostCommand(const AEnvelope: TGMMessageEnvelope);
    procedure SetOnMessageReceived(const AHandler: TGMBridgeMessageReceivedEvent);

    property Backend: TGMBridgeBackend read GetBackend;
    property IsReady: Boolean read GetIsReady;
  end;

implementation

end.
