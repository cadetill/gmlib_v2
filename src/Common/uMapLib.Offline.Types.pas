{**
  @abstract(Tipos comunes para el runtime offline nativo de MapLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Reune enumerados, records y firmas de eventos compartidos por el runtime
  offline, el gestor de regiones y las capas de integracion con componentes.
}
unit uMapLib.Offline.Types;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils;
{$ELSE}
  System.Classes, System.SysUtils;
{$ENDIF}

type
  {** @abstract(Politica de preferencia entre cache local y proveedor remoto.) }
  TMapLibOfflinePolicy = (
    opPreferOffline,
    opPreferOnline,
    opOfflineOnly
  );

  {** @abstract(Estado de cobertura offline para una posicion dada.) }
  TMapLibOfflineCoverageState = (
    ocsUnknown,
    ocsCovered,
    ocsPartiallyCovered,
    ocsUncovered
  );

  TMapLibOfflineRegionId = string;

  {** @abstract(Bounds geograficos asociados a una region offline.) }
  TMapLibOfflineRegionBounds = record
    North: Double;
    South: Double;
    East: Double;
    West: Double;
  end;

  {** @abstract(Metadatos persistidos para una region offline descargada.) }
  TMapLibOfflineRegionMetadata = record
    RegionId: TMapLibOfflineRegionId;
    MinZoom: Integer;
    MaxZoom: Integer;
    Bounds: TMapLibOfflineRegionBounds;
    CreatedAtUtc: TDateTime;
    UpdatedAtUtc: TDateTime;
    DataVersion: string;
    SizeBytes: Int64;
    Checksum: string;
    StoragePath: string;
  end;

  {** @abstract(Array tipado de metadatos offline compatible con Delphi y FPC.) }
  TMapLibOfflineRegionMetadataArray = array of TMapLibOfflineRegionMetadata;

  {** @abstract(Uso de almacenamiento reportado por el subsistema offline.) }
  TMapLibOfflineStorageUsage = record
    UsedBytes: Int64;
    AvailableBytes: Int64;
  end;

  {** @abstract(Resultado de resolver cobertura offline para una posicion.) }
  TMapLibOfflineCoverage = record
    State: TMapLibOfflineCoverageState;
    RegionId: TMapLibOfflineRegionId;
  end;

  {** @abstract(Solicitud de descarga de una region offline.) }
  TMapLibOfflineDownloadRequest = record
    RegionId: TMapLibOfflineRegionId;
    SourceUrl: string;
    MinZoom: Integer;
    MaxZoom: Integer;
    Bounds: TMapLibOfflineRegionBounds;
    DataVersion: string;
  end;

  {** @abstract(Solicitud para construir una región MBTiles desde un bbox y zooms.) }
  TMapLibOfflineBuildRegionRequest = record
    RegionId: TMapLibOfflineRegionId;
    SourceId: string;
    RemoteTileTemplate: string;
    MinZoom: Integer;
    MaxZoom: Integer;
    Bounds: TMapLibOfflineRegionBounds;
    DataVersion: string;
  end;

  {** @abstract(Evento de progreso de una descarga offline.) }
  TMapLibOfflineDownloadProgressEvent = procedure(Sender: TObject; const AJobId: string;
    APercent: Double; ABytesDone, ABytesTotal: Int64) of object;
  {** @abstract(Evento emitido cuando una region queda disponible.) }
  TMapLibOfflineRegionReadyEvent = procedure(Sender: TObject;
    const ARegionId: TMapLibOfflineRegionId) of object;
  {** @abstract(Evento de error funcional del subsistema offline.) }
  TMapLibOfflineErrorEvent = procedure(Sender: TObject; AErrorCode: Integer;
    const AUserMessage, ATechnicalMessage: string) of object;
  {** @abstract(Evento emitido cuando cambia la cobertura offline activa.) }
  TMapLibOfflineCoverageChangedEvent = procedure(Sender: TObject;
    const ACoverage: TMapLibOfflineCoverage) of object;

implementation

end.
