{**
  @abstract(Contrato y no-op inicial para gestion de regiones offline.)
}
unit uMapLib.Offline.RegionManager;

{$I ..\..\gmlib.inc}

interface

uses
  uMapLib.Offline.RegionCatalog,
  uMapLib.Offline.Types;

type
  IMapLibOfflineRegionManager = interface(IMapLibOfflineCatalog)
    ['{A9E6F87A-DC3B-479A-A7A8-A4B2640B10D0}']
    function DownloadRegion(const ARequest: TMapLibOfflineDownloadRequest): string;
    function CancelDownload(const AJobId: string): Boolean;
    function ResolveCoverage(ALat, ALng: Double; AZoom: Double): TMapLibOfflineCoverage;
  end;

  TMapLibOfflineRegionManager = class(TInterfacedObject, IMapLibOfflineRegionManager)
  private
    FActiveRegion: TMapLibOfflineRegionId;
  public
    function DownloadRegion(const ARequest: TMapLibOfflineDownloadRequest): string;
    function CancelDownload(const AJobId: string): Boolean;
    function DeleteRegion(const ARegionId: TMapLibOfflineRegionId): Boolean;
    function ListRegions: TArray<TMapLibOfflineRegionMetadata>;
    function GetStorageUsage: TMapLibOfflineStorageUsage;
    procedure SetActiveRegion(const ARegionId: TMapLibOfflineRegionId);
    function GetActiveRegionId: TMapLibOfflineRegionId;
    function ResolveCoverage(ALat, ALng: Double; AZoom: Double): TMapLibOfflineCoverage;
  end;

implementation

{ TMapLibOfflineRegionManager }

function TMapLibOfflineRegionManager.CancelDownload(const AJobId: string): Boolean;
begin
  Result := False;
end;

function TMapLibOfflineRegionManager.DeleteRegion(
  const ARegionId: TMapLibOfflineRegionId): Boolean;
begin
  Result := False;
end;

function TMapLibOfflineRegionManager.DownloadRegion(
  const ARequest: TMapLibOfflineDownloadRequest): string;
begin
  Result := '';
end;

function TMapLibOfflineRegionManager.GetActiveRegionId: TMapLibOfflineRegionId;
begin
  Result := FActiveRegion;
end;

function TMapLibOfflineRegionManager.GetStorageUsage: TMapLibOfflineStorageUsage;
begin
  Result.UsedBytes := 0;
  Result.AvailableBytes := 0;
end;

function TMapLibOfflineRegionManager.ListRegions: TArray<TMapLibOfflineRegionMetadata>;
begin
  SetLength(Result, 0);
end;

function TMapLibOfflineRegionManager.ResolveCoverage(ALat, ALng: Double;
  AZoom: Double): TMapLibOfflineCoverage;
begin
  Result.State := ocsUnknown;
  Result.RegionId := '';
end;

procedure TMapLibOfflineRegionManager.SetActiveRegion(
  const ARegionId: TMapLibOfflineRegionId);
begin
  FActiveRegion := ARegionId;
end;

end.
