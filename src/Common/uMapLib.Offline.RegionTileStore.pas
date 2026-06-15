{**
  @abstract(Unidad @code(uMapLib.Offline.RegionTileStore) para resolución automática de regiones MBTiles.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Implementa un almacén local que selecciona automáticamente qué archivo
  `MBTiles` consultar en función del tile pedido (`z/x/y`) y de la cobertura
  persistida en `regions.json`.
}
unit uMapLib.Offline.RegionTileStore;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  Math,
  SysUtils,
{$ELSE}
  System.Classes,
  System.Math,
  System.SysUtils,
  System.IOUtils,
{$ENDIF}
  uMapLib.Offline.TileStore,
  uMapLib.Offline.Types;

type
  TMapLibRegionTileStoreCacheEntry = class
  public
    TileStore: IMapLibTileStore;
  end;

  {** @abstract(Store de solo lectura que elige automáticamente la región MBTiles adecuada.) }
  TMapLibOfflineRegionTileStore = class(TInterfacedObject, IMapLibTileStore)
  private
    FStorageBasePath: string;
    FPreferredRegionFileName: string;
    FStoreCache: TStringList;
    function BuildCatalogFileName: string;
    function LongitudeFromTileX(AZoom, AX: Integer): Double;
    function LatitudeFromTileY(AZoom, AY: Integer): Double;
    function RegionContainsTileCenter(const ARegion: TMapLibOfflineRegionMetadata;
      AZ, AX, AY: Integer): Boolean;
    function ResolveAbsoluteStoragePath(const APath: string): string;
    function ResolvePreferredRegionId(const ARegions: TMapLibOfflineRegionMetadataArray): string;
    function GetOrCreateTileStore(const AFileName: string): IMapLibTileStore;
  public
    constructor Create(const AStorageBasePath, APreferredRegionFileName: string);
    destructor Destroy; override;
    function TryGetTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
    procedure PutTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      const ATileData: TBytes; const AContentType, AContentEncoding: string);
  end;

implementation

uses
  uMapLib.Offline.MBTilesTileStore,
  uMapLib.Offline.Storage;

function BuildCombinedPath(const ABasePath, AChild: string): string;
begin
{$IFDEF FPC}
  Result := IncludeTrailingPathDelimiter(ABasePath) + AChild;
{$ELSE}
  Result := TPath.Combine(ABasePath, AChild);
{$ENDIF}
end;

constructor TMapLibOfflineRegionTileStore.Create(const AStorageBasePath,
  APreferredRegionFileName: string);
begin
  inherited Create;
  FStorageBasePath := AStorageBasePath;
  FPreferredRegionFileName := APreferredRegionFileName;
  FStoreCache := TStringList.Create;
  FStoreCache.CaseSensitive := False;
end;

destructor TMapLibOfflineRegionTileStore.Destroy;
var
  index: Integer;
begin
  for index := 0 to FStoreCache.Count - 1 do
    FStoreCache.Objects[index].Free;
  FStoreCache.Free;
  inherited Destroy;
end;

function TMapLibOfflineRegionTileStore.BuildCatalogFileName: string;
begin
  if Trim(FStorageBasePath) = '' then
    Result := ''
  else
    Result := BuildCombinedPath(FStorageBasePath, 'regions.json');
end;

function TMapLibOfflineRegionTileStore.ResolveAbsoluteStoragePath(
  const APath: string): string;
begin
{$IFDEF FPC}
  if (ExtractFileDrive(APath) <> '') or ((APath <> '') and (APath[1] = PathDelim)) then
    Result := APath
  else
    Result := BuildCombinedPath(FStorageBasePath, APath);
{$ELSE}
  if TPath.IsPathRooted(APath) then
    Result := APath
  else
    Result := TPath.Combine(FStorageBasePath, APath);
{$ENDIF}
end;

function TMapLibOfflineRegionTileStore.LongitudeFromTileX(AZoom,
  AX: Integer): Double;
var
  tileCount: Double;
begin
  tileCount := Power(2, AZoom);
  Result := (AX / tileCount) * 360.0 - 180.0;
end;

function TMapLibOfflineRegionTileStore.LatitudeFromTileY(AZoom,
  AY: Integer): Double;
var
  mercatorValue: Double;
begin
  mercatorValue := PI * (1 - 2 * (AY / Power(2, AZoom)));
  Result := RadToDeg(ArcTan(Sinh(mercatorValue)));
end;

function TMapLibOfflineRegionTileStore.RegionContainsTileCenter(
  const ARegion: TMapLibOfflineRegionMetadata; AZ, AX, AY: Integer): Boolean;
var
  centerLat: Double;
  centerLng: Double;
begin
  if (AZ < ARegion.MinZoom) or (AZ > ARegion.MaxZoom) then
    Exit(False);

  centerLng := LongitudeFromTileX(AZ, AX) +
    ((LongitudeFromTileX(AZ, AX + 1) - LongitudeFromTileX(AZ, AX)) / 2);
  centerLat := LatitudeFromTileY(AZ, AY + 1) +
    ((LatitudeFromTileY(AZ, AY) - LatitudeFromTileY(AZ, AY + 1)) / 2);

  Result :=
    (centerLat <= ARegion.Bounds.North) and
    (centerLat >= ARegion.Bounds.South) and
    (centerLng <= ARegion.Bounds.East) and
    (centerLng >= ARegion.Bounds.West);
end;

function TMapLibOfflineRegionTileStore.ResolvePreferredRegionId(
  const ARegions: TMapLibOfflineRegionMetadataArray): string;
var
  absolutePreferredFileName: string;
  absoluteRegionFileName: string;
  index: Integer;
begin
  Result := '';
  absolutePreferredFileName := Trim(FPreferredRegionFileName);
  if absolutePreferredFileName = '' then
    Exit;

  for index := Low(ARegions) to High(ARegions) do
  begin
    absoluteRegionFileName := ResolveAbsoluteStoragePath(ARegions[index].StoragePath);
    if SameText(absoluteRegionFileName, absolutePreferredFileName) then
      Exit(ARegions[index].RegionId);
  end;
end;

function TMapLibOfflineRegionTileStore.GetOrCreateTileStore(
  const AFileName: string): IMapLibTileStore;
var
  cacheEntry: TMapLibRegionTileStoreCacheEntry;
  index: Integer;
begin
  Result := nil;
  index := FStoreCache.IndexOf(AFileName);
  if index >= 0 then
  begin
    cacheEntry := TMapLibRegionTileStoreCacheEntry(FStoreCache.Objects[index]);
    Exit(cacheEntry.TileStore);
  end;

  cacheEntry := TMapLibRegionTileStoreCacheEntry.Create;
  cacheEntry.TileStore := TMapLibMBTilesTileStore.Create(AFileName);
  FStoreCache.AddObject(AFileName, cacheEntry);
  Result := cacheEntry.TileStore;
end;

function TMapLibOfflineRegionTileStore.TryGetTile(const ASourceId,
  ASourceVariant: string; AZ, AX, AY: Integer; out ATileData: TBytes;
  out AContentType, AContentEncoding: string): Boolean;
var
  preferredRegionId: string;
  regions: TMapLibOfflineRegionMetadataArray;
  resolvedFileName: string;
  tileStore: IMapLibTileStore;
  index: Integer;
begin
  Result := False;
  SetLength(ATileData, 0);
  AContentType := '';
  AContentEncoding := '';

  if Trim(FStorageBasePath) = '' then
    Exit;

  regions := TMapLibOfflineCatalogStorage.LoadFromFile(BuildCatalogFileName);
  if Length(regions) = 0 then
    Exit;

  preferredRegionId := ResolvePreferredRegionId(regions);
  if preferredRegionId <> '' then
  begin
    for index := Low(regions) to High(regions) do
      if SameText(regions[index].RegionId, preferredRegionId) and
        RegionContainsTileCenter(regions[index], AZ, AX, AY) then
      begin
        resolvedFileName := ResolveAbsoluteStoragePath(regions[index].StoragePath);
        if FileExists(resolvedFileName) then
        begin
          tileStore := GetOrCreateTileStore(resolvedFileName);
          Exit(tileStore.TryGetTile(ASourceId, ASourceVariant, AZ, AX, AY,
            ATileData, AContentType, AContentEncoding));
        end;
      end;
  end;

  for index := Low(regions) to High(regions) do
  begin
    if (preferredRegionId <> '') and SameText(regions[index].RegionId, preferredRegionId) then
      Continue;
    if not RegionContainsTileCenter(regions[index], AZ, AX, AY) then
      Continue;

    resolvedFileName := ResolveAbsoluteStoragePath(regions[index].StoragePath);
    if not FileExists(resolvedFileName) then
      Continue;

    tileStore := GetOrCreateTileStore(resolvedFileName);
    if tileStore.TryGetTile(ASourceId, ASourceVariant, AZ, AX, AY,
      ATileData, AContentType, AContentEncoding) then
      Exit(True);
  end;
end;

procedure TMapLibOfflineRegionTileStore.PutTile(const ASourceId,
  ASourceVariant: string; AZ, AX, AY: Integer; const ATileData: TBytes;
  const AContentType, AContentEncoding: string);
begin
  // Las regiones descargadas se tratan como artefactos inmutables.
end;

end.
