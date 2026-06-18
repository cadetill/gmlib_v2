{**
  @abstract(Contratos del bridge Delphi <-> JavaScript.)
}
unit uMapLib.Core.Bridge;

{$I ..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes{$ELSE}System.Classes{$ENDIF},
  uMapLib.Core.Messages,
  uMapLib.Core.Types;

type
  TMapBridgeMessageReceivedEvent = procedure(Sender: TObject; const AEnvelope: TMapLibMessageEnvelope) of object;

  IMapBridgeJavaScriptNamespace = interface
    ['{5C7C8E8D-2A52-4C3A-8F3E-9CC2A6A9435C}']
    procedure SetJavaScriptNamespace(const ANamespace: string);
    function GetJavaScriptNamespace: string;
    property JavaScriptNamespace: string read GetJavaScriptNamespace write SetJavaScriptNamespace;
  end;

  IMapBridgeInterval = interface
    ['{B8956706-4BF6-4E03-84CA-CB721DD64A10}']
    procedure SetBridgeInterval(const Value: Integer);
    function GetBridgeInterval: Integer;
    property BridgeInterval: Integer read GetBridgeInterval write SetBridgeInterval;
  end;

  IMapBridgeDocumentBaseUrl = interface
    ['{D8010B30-5B56-4B74-937A-4C733C5FAF0D}']
    procedure SetDocumentBaseUrl(const AValue: string);
    function GetDocumentBaseUrl: string;
    property DocumentBaseUrl: string read GetDocumentBaseUrl write SetDocumentBaseUrl;
  end;

  IMapBridgeNavigation = interface
    ['{53A8D991-C8E7-40A5-93F6-BAA8F0F16D63}']
    procedure Navigate(const AUrl: string);
  end;

  IMapBridgeTransport = interface
    ['{0D8A77BD-5A15-4310-A8EE-88C1307AE7A3}']
    function GetBackend: TGMBridgeBackend;
    function GetIsReady: Boolean;
    procedure AttachBrowser(const ABrowser: TComponent);
    procedure LoadHtml(const AHtml: string);
    procedure ExecuteJavaScript(const AScript: string);
    procedure PostCommand(const AEnvelope: TMapLibMessageEnvelope);
    procedure SetOnMessageReceived(const AHandler: TMapBridgeMessageReceivedEvent);
    property Backend: TGMBridgeBackend read GetBackend;
    property IsReady: Boolean read GetIsReady;
  end;

implementation

end.

