{**
  @abstract(Contratos base para ejecucion de mapas en modo offline/hibrido.)
}
unit uMapLib.Core.Offline;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes;
{$ELSE}
  System.Classes;
{$ENDIF}

type
  TMapLibMapMode = (
    omOnline,
    omOffline,
    omHybrid
  );

  IMapLibOfflineTileServer = interface
    ['{0F0D8AB1-11D0-4C18-9D2E-3A534A332A0C}']
    function Start: Boolean;
    procedure Stop;
    function IsRunning: Boolean;
    function GetBaseUrl: string;
    function GetLastError: string;

    property BaseUrl: string read GetBaseUrl;
    property LastError: string read GetLastError;
  end;

  IMapLibOfflineDataSource = interface
    ['{6B8D57B4-A068-48E5-B422-1BF0DB04C95D}']
    function Open(const AUri: string): Boolean;
    procedure Close;
    function IsOpen: Boolean;
    function GetSourceId: string;
    function GetLastError: string;

    property SourceId: string read GetSourceId;
    property LastError: string read GetLastError;
  end;

implementation

end.

