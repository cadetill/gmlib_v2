{**
  @abstract(Pruebas automáticas del gestor de regiones offline de MapLib.)
}
unit uTest.MapLib.Offline.RegionManager;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestMapLibOfflineRegionManager = class
  public
    [Test]
    procedure ResolveCoverage_ReturnsCoveredForMatchingRegion;

    [Test]
    procedure DeleteRegion_RemovesCatalogEntryAndStorageFile;

    [Test]
    procedure GetStorageUsage_SumsRegionSizes;

    [Test]
    procedure DeleteRegion_ClearsActiveRegionWhenItMatchesDeletedRegion;

    [Test]
    procedure BuildRegion_RejectsInvalidZoomRange;

    [Test]
    procedure DownloadRegion_RejectsEmptySourceUrl;

    [Test]
    procedure Create_RemovesStaleTemporaryArtifacts;

    [Test]
    procedure DownloadRegion_RaisesWhenRegionAlreadyExists;

    [Test]
    procedure BuildRegion_RaisesWhenRegionAlreadyExists;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  uMapLib.Offline.RegionManager,
  uMapLib.Offline.Storage,
  uMapLib.Offline.Types;

function BuildRegionMetadata(const ARegionId, AStoragePath: string;
  AMinZoom, AMaxZoom: Integer; ANorth, ASouth, AEast, AWest: Double;
  ASizeBytes: Int64): TMapLibOfflineRegionMetadata;
begin
  Result.RegionId := ARegionId;
  Result.MinZoom := AMinZoom;
  Result.MaxZoom := AMaxZoom;
  Result.Bounds.North := ANorth;
  Result.Bounds.South := ASouth;
  Result.Bounds.East := AEast;
  Result.Bounds.West := AWest;
  Result.CreatedAtUtc := EncodeDate(2026, 5, 28);
  Result.UpdatedAtUtc := Result.CreatedAtUtc;
  Result.DataVersion := 'v1';
  Result.SizeBytes := ASizeBytes;
  Result.Checksum := 'checksum';
  Result.StoragePath := AStoragePath;
end;

procedure TTestMapLibOfflineRegionManager.DeleteRegion_RemovesCatalogEntryAndStorageFile;
var
  CatalogFileName: string;
  Manager: TMapLibOfflineRegionManager;
  RegionFileName: string;
  Regions: TMapLibOfflineRegionMetadataArray;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    RegionFileName := TPath.Combine(StoragePath, 'region-a.mbtiles');
    TFile.WriteAllText(RegionFileName, 'dummy', TEncoding.UTF8);

    Regions := [
      BuildRegionMetadata('region-a', 'region-a.mbtiles', 1, 10, 50, 40, 5, -5, 5),
      BuildRegionMetadata('region-b', 'region-b.mbtiles', 1, 10, 60, 30, 10, -10, 7)
    ];

    CatalogFileName := TPath.Combine(StoragePath, 'regions.json');
    TMapLibOfflineCatalogStorage.SaveToFile(CatalogFileName, Regions);

    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Assert.IsTrue(Manager.DeleteRegion('region-a'));
      Assert.IsFalse(FileExists(RegionFileName));
      Assert.AreEqual(1, Length(Manager.ListRegions));
      Assert.AreEqual('region-b', Manager.ListRegions[0].RegionId);
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.GetStorageUsage_SumsRegionSizes;
var
  CatalogFileName: string;
  Manager: TMapLibOfflineRegionManager;
  RegionAFileName: string;
  RegionBFileName: string;
  Regions: TMapLibOfflineRegionMetadataArray;
  StoragePath: string;
  Usage: TMapLibOfflineStorageUsage;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    RegionAFileName := TPath.Combine(StoragePath, 'region-a.mbtiles');
    RegionBFileName := TPath.Combine(StoragePath, 'region-b.mbtiles');
    TFile.WriteAllBytes(RegionAFileName, TBytes.Create($01, $02, $03, $04));
    TFile.WriteAllBytes(RegionBFileName, TBytes.Create($01, $02, $03));

    Regions := [
      BuildRegionMetadata('region-a', 'region-a.mbtiles', 1, 10, 50, 40, 5, -5, 4),
      BuildRegionMetadata('region-b', 'region-b.mbtiles', 1, 10, 60, 30, 10, -10, 3)
    ];

    CatalogFileName := TPath.Combine(StoragePath, 'regions.json');
    TMapLibOfflineCatalogStorage.SaveToFile(CatalogFileName, Regions);

    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Usage := Manager.GetStorageUsage;
      Assert.AreEqual(Int64(7), Usage.UsedBytes);
      Assert.IsTrue(Usage.AvailableBytes > 0);
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.DeleteRegion_ClearsActiveRegionWhenItMatchesDeletedRegion;
var
  CatalogFileName: string;
  Manager: TMapLibOfflineRegionManager;
  Regions: TMapLibOfflineRegionMetadataArray;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    Regions := [
      BuildRegionMetadata('region-a', 'region-a.mbtiles', 1, 10, 50, 40, 5, -5, 5)
    ];

    CatalogFileName := TPath.Combine(StoragePath, 'regions.json');
    TMapLibOfflineCatalogStorage.SaveToFile(CatalogFileName, Regions);

    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Manager.SetActiveRegion('region-a');
      Assert.AreEqual('region-a', string(Manager.GetActiveRegionId));

      Assert.IsTrue(Manager.DeleteRegion('region-a'));
      Assert.AreEqual('', string(Manager.GetActiveRegionId));
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.ResolveCoverage_ReturnsCoveredForMatchingRegion;
var
  CatalogFileName: string;
  Coverage: TMapLibOfflineCoverage;
  Manager: TMapLibOfflineRegionManager;
  Regions: TMapLibOfflineRegionMetadataArray;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    Regions := [
      BuildRegionMetadata('iberia', 'iberia.mbtiles', 4, 12, 45, 35, 5, -10, 1234)
    ];

    CatalogFileName := TPath.Combine(StoragePath, 'regions.json');
    TMapLibOfflineCatalogStorage.SaveToFile(CatalogFileName, Regions);

    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Coverage := Manager.ResolveCoverage(41.3874, 2.1686, 8);

      Assert.AreEqual(Integer(ocsCovered), Integer(Coverage.State));
      Assert.AreEqual('iberia', Coverage.RegionId);
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.BuildRegion_RejectsInvalidZoomRange;
var
  Manager: TMapLibOfflineRegionManager;
  Request: TMapLibOfflineBuildRegionRequest;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Request.RegionId := 'invalid-zoom';
      Request.SourceId := 'osm';
      Request.RemoteTileTemplate := 'https://tiles.example/{z}/{x}/{y}.pbf';
      Request.MinZoom := 10;
      Request.MaxZoom := 5;
      Request.Bounds.North := 45;
      Request.Bounds.South := 40;
      Request.Bounds.East := 5;
      Request.Bounds.West := 0;
      Request.DataVersion := 'v1';

      Assert.AreEqual('', Manager.BuildRegion(Request));
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.DownloadRegion_RejectsEmptySourceUrl;
var
  Manager: TMapLibOfflineRegionManager;
  Request: TMapLibOfflineDownloadRequest;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Request.RegionId := 'missing-source';
      Request.SourceUrl := '';
      Request.MinZoom := 1;
      Request.MaxZoom := 5;
      Request.Bounds.North := 45;
      Request.Bounds.South := 40;
      Request.Bounds.East := 5;
      Request.Bounds.West := 0;
      Request.DataVersion := 'v1';

      Assert.AreEqual('', Manager.DownloadRegion(Request));
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.Create_RemovesStaleTemporaryArtifacts;
var
  BuildingFileName: string;
  DownloadTempFileName: string;
  Manager: TMapLibOfflineRegionManager;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    DownloadTempFileName := TPath.Combine(StoragePath, 'region-a.tmp');
    BuildingFileName := TPath.Combine(StoragePath, 'region-b.building.mbtiles');
    TFile.WriteAllText(DownloadTempFileName, 'partial-download', TEncoding.UTF8);
    TFile.WriteAllText(BuildingFileName, 'partial-build', TEncoding.UTF8);

    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Assert.IsFalse(FileExists(DownloadTempFileName));
      Assert.IsFalse(FileExists(BuildingFileName));
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.DownloadRegion_RaisesWhenRegionAlreadyExists;
var
  CatalogFileName: string;
  Manager: TMapLibOfflineRegionManager;
  Request: TMapLibOfflineDownloadRequest;
  Regions: TMapLibOfflineRegionMetadataArray;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    Regions := [
      BuildRegionMetadata('region-a', 'region-a.mbtiles', 1, 10, 50, 40, 5, -5, 5)
    ];

    CatalogFileName := TPath.Combine(StoragePath, 'regions.json');
    TMapLibOfflineCatalogStorage.SaveToFile(CatalogFileName, Regions);

    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Request.RegionId := 'region-a';
      Request.SourceUrl := 'https://example.invalid/region-a.mbtiles';
      Request.MinZoom := 1;
      Request.MaxZoom := 10;
      Request.Bounds.North := 50;
      Request.Bounds.South := 40;
      Request.Bounds.East := 5;
      Request.Bounds.West := -5;
      Request.DataVersion := 'v1';

      Assert.WillRaise(
        procedure
        begin
          Manager.DownloadRegion(Request);
        end,
        EInvalidOpException
      );
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

procedure TTestMapLibOfflineRegionManager.BuildRegion_RaisesWhenRegionAlreadyExists;
var
  CatalogFileName: string;
  Manager: TMapLibOfflineRegionManager;
  Request: TMapLibOfflineBuildRegionRequest;
  Regions: TMapLibOfflineRegionMetadataArray;
  StoragePath: string;
begin
  StoragePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  ForceDirectories(StoragePath);
  try
    Regions := [
      BuildRegionMetadata('region-a', 'region-a.mbtiles', 1, 10, 50, 40, 5, -5, 5)
    ];

    CatalogFileName := TPath.Combine(StoragePath, 'regions.json');
    TMapLibOfflineCatalogStorage.SaveToFile(CatalogFileName, Regions);

    Manager := TMapLibOfflineRegionManager.Create(StoragePath);
    try
      Request.RegionId := 'region-a';
      Request.SourceId := 'osm';
      Request.RemoteTileTemplate := 'https://tiles.example/{z}/{x}/{y}.pbf';
      Request.MinZoom := 1;
      Request.MaxZoom := 10;
      Request.Bounds.North := 50;
      Request.Bounds.South := 40;
      Request.Bounds.East := 5;
      Request.Bounds.West := -5;
      Request.DataVersion := 'v1';

      Assert.WillRaise(
        procedure
        begin
          Manager.BuildRegion(Request);
        end,
        EInvalidOpException
      );
    finally
      Manager.Free;
    end;
  finally
    if DirectoryExists(StoragePath) then
      TDirectory.Delete(StoragePath, True);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMapLibOfflineRegionManager);

end.
