{**
  @abstract(Unidad @code(uMapLib.Offline.TileCoverage) para estimación de cobertura XYZ.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Reúne utilidades puras para calcular cuántos tiles XYZ cubren un `bbox`
  geográfico para uno o varios niveles de zoom. Se usa como base del futuro
  flujo de descarga de regiones desde viewport.
}
unit uMapLib.Offline.TileCoverage;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Math,
  SysUtils,
{$ELSE}
  System.Math,
  System.SysUtils,
{$ENDIF}
  uMapLib.Offline.Types;

type
  {** @abstract(Coordenada XYZ individual dentro de una región offline.) }
  TMapLibOfflineTileCoordinate = record
    ZoomLevel: Integer;
    TileX: Integer;
    TileY: Integer;
  end;

  {** @abstract(Callback de enumeración de tiles XYZ.) }
  TMapLibOfflineTileCoordinateProc = procedure(
    const ATile: TMapLibOfflineTileCoordinate) of object;

  {** @abstract(Resumen de cobertura XYZ calculado para una región offline.) }
  TMapLibOfflineTileCoverageSummary = record
    MinZoom: Integer;
    MaxZoom: Integer;
    TileCount: Int64;
  end;

{**
  @abstract(Devuelve un `bbox` normalizado para cálculos XYZ.)
  @param(ABounds Bounds originales)
  @returns(Bounds con norte/sur y oeste/este ordenados)
}
function MapLibNormalizeOfflineBounds(
  const ABounds: TMapLibOfflineRegionBounds): TMapLibOfflineRegionBounds;

{**
  @abstract(Calcula el número de tiles XYZ necesarios para un `bbox` y rango de zoom.)
  @param(ABounds Bounds geográficos)
  @param(AMinZoom Zoom mínimo inclusivo)
  @param(AMaxZoom Zoom máximo inclusivo)
  @returns(Resumen con rango aplicado y total de tiles)
}
function MapLibBuildTileCoverageSummary(const ABounds: TMapLibOfflineRegionBounds;
  AMinZoom, AMaxZoom: Integer): TMapLibOfflineTileCoverageSummary;

{**
  @abstract(Enumera todos los tiles XYZ que cubren un `bbox` y rango de zoom.)
  @param(ABounds Bounds geográficos)
  @param(AMinZoom Zoom mínimo inclusivo)
  @param(AMaxZoom Zoom máximo inclusivo)
  @param(ACallback Método llamado por cada tile resultante)
}
procedure MapLibEnumerateBoundsTiles(const ABounds: TMapLibOfflineRegionBounds;
  AMinZoom, AMaxZoom: Integer; const ACallback: TMapLibOfflineTileCoordinateProc);

implementation

function ClampLatitude(ALatitude: Double): Double;
begin
  Result := EnsureRange(ALatitude, -85.05112878, 85.05112878);
end;

function LongitudeToTileX(ALongitude: Double; AZoom: Integer): Integer;
var
  tileCount: Integer;
  normalized: Double;
begin
  tileCount := 1 shl AZoom;
  normalized := (ALongitude + 180.0) / 360.0;
  Result := EnsureRange(Floor(normalized * tileCount), 0, tileCount - 1);
end;

function LatitudeToTileY(ALatitude: Double; AZoom: Integer): Integer;
var
  latitudeRad: Double;
  mercatorValue: Double;
  tileCount: Integer;
begin
  tileCount := 1 shl AZoom;
  latitudeRad := DegToRad(ClampLatitude(ALatitude));
  mercatorValue := (1 - Ln(Tan(latitudeRad) + (1 / Cos(latitudeRad))) / PI) / 2;
  Result := EnsureRange(Floor(mercatorValue * tileCount), 0, tileCount - 1);
end;

function MapLibNormalizeOfflineBounds(
  const ABounds: TMapLibOfflineRegionBounds): TMapLibOfflineRegionBounds;
var
  tempValue: Double;
begin
  Result := ABounds;
  if Result.North < Result.South then
  begin
    tempValue := Result.North;
    Result.North := Result.South;
    Result.South := tempValue;
  end;
  if Result.East < Result.West then
  begin
    tempValue := Result.East;
    Result.East := Result.West;
    Result.West := tempValue;
  end;
end;

function MapLibBuildTileCoverageSummary(const ABounds: TMapLibOfflineRegionBounds;
  AMinZoom, AMaxZoom: Integer): TMapLibOfflineTileCoverageSummary;
var
  bounds: TMapLibOfflineRegionBounds;
  tempZoom: Integer;
  tileCountForZoom: Int64;
  tileXMax: Integer;
  tileXMin: Integer;
  tileYMax: Integer;
  tileYMin: Integer;
  zoomLevel: Integer;
begin
  Result.MinZoom := EnsureRange(AMinZoom, 0, 30);
  Result.MaxZoom := EnsureRange(AMaxZoom, 0, 30);
  if Result.MaxZoom < Result.MinZoom then
  begin
    tempZoom := Result.MaxZoom;
    Result.MaxZoom := Result.MinZoom;
    Result.MinZoom := tempZoom;
  end;
  Result.TileCount := 0;

  bounds := MapLibNormalizeOfflineBounds(ABounds);
  for zoomLevel := Result.MinZoom to Result.MaxZoom do
  begin
    tileXMin := LongitudeToTileX(bounds.West, zoomLevel);
    tileXMax := LongitudeToTileX(bounds.East, zoomLevel);
    tileYMin := LatitudeToTileY(bounds.North, zoomLevel);
    tileYMax := LatitudeToTileY(bounds.South, zoomLevel);
    tileCountForZoom :=
      Int64(tileXMax - tileXMin + 1) * Int64(tileYMax - tileYMin + 1);
    if tileCountForZoom > 0 then
      Result.TileCount := Result.TileCount + tileCountForZoom;
  end;
end;

procedure MapLibEnumerateBoundsTiles(const ABounds: TMapLibOfflineRegionBounds;
  AMinZoom, AMaxZoom: Integer; const ACallback: TMapLibOfflineTileCoordinateProc);
var
  bounds: TMapLibOfflineRegionBounds;
  tileX: Integer;
  tile: TMapLibOfflineTileCoordinate;
  tileXMax: Integer;
  tileXMin: Integer;
  tileY: Integer;
  tileYMax: Integer;
  tileYMin: Integer;
  zoomLevel: Integer;
begin
  if not Assigned(ACallback) then
    Exit;

  bounds := MapLibNormalizeOfflineBounds(ABounds);
  if AMaxZoom < AMinZoom then
  begin
    zoomLevel := AMinZoom;
    AMinZoom := AMaxZoom;
    AMaxZoom := zoomLevel;
  end;

  for zoomLevel := EnsureRange(AMinZoom, 0, 30) to EnsureRange(AMaxZoom, 0, 30) do
  begin
    tile.ZoomLevel := zoomLevel;
    tileXMin := LongitudeToTileX(bounds.West, zoomLevel);
    tileXMax := LongitudeToTileX(bounds.East, zoomLevel);
    tileYMin := LatitudeToTileY(bounds.North, zoomLevel);
    tileYMax := LatitudeToTileY(bounds.South, zoomLevel);
    for tileX := tileXMin to tileXMax do
      for tileY := tileYMin to tileYMax do
      begin
        tile.TileX := tileX;
        tile.TileY := tileY;
        ACallback(tile);
      end;
  end;
end;

end.
