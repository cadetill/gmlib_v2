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

initialization
  TDUnitX.RegisterTestFixture(TTestMapLibOfflineRegionManager);

end.
