{**
  @abstract(Tipos comunes para el runtime offline nativo de MapLib.)
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
  TMapLibOfflineTileProvider = (
    otpAuto,
    otpEmbeddedTileJson,
    otpExternalPmtiles,
    otpNativePmtiles
  );

  TMapLibOfflinePolicy = (
    opPreferOffline,
    opPreferOnline,
    opOfflineOnly
  );

  TMapLibOfflineCoverageState = (
    ocsUnknown,
    ocsCovered,
    ocsPartiallyCovered,
    ocsUncovered
  );

  TMapLibOfflineRegionId = string;

  TMapLibOfflineRegionBounds = record
    North: Double;
    South: Double;
    East: Double;
    West: Double;
  end;

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

  TMapLibOfflineStorageUsage = record
    UsedBytes: Int64;
    AvailableBytes: Int64;
  end;

  TMapLibOfflineCoverage = record
    State: TMapLibOfflineCoverageState;
    RegionId: TMapLibOfflineRegionId;
  end;

  TMapLibOfflineDownloadRequest = record
    RegionId: TMapLibOfflineRegionId;
    SourceUrl: string;
    MinZoom: Integer;
    MaxZoom: Integer;
    Bounds: TMapLibOfflineRegionBounds;
    DataVersion: string;
  end;

  TMapLibOfflineDownloadProgressEvent = procedure(Sender: TObject; const AJobId: string;
    APercent: Double; ABytesDone, ABytesTotal: Int64) of object;
  TMapLibOfflineRegionReadyEvent = procedure(Sender: TObject;
    const ARegionId: TMapLibOfflineRegionId) of object;
  TMapLibOfflineErrorEvent = procedure(Sender: TObject; AErrorCode: Integer;
    const AUserMessage, ATechnicalMessage: string) of object;
  TMapLibOfflineCoverageChangedEvent = procedure(Sender: TObject;
    const ACoverage: TMapLibOfflineCoverage) of object;

implementation

end.
