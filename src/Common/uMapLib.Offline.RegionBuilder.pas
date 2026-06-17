{**
  @abstract(Constructor en segundo plano de regiones MBTiles desde tiles XYZ remotos.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
}
unit uMapLib.Offline.RegionBuilder;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  SysUtils,
{$ELSE}
  System.Classes,
  System.SysUtils,
  System.IOUtils,
{$ENDIF}
  uMapLib.Offline.TileCoverage,
  uMapLib.Offline.RemoteTileProvider,
  uMapLib.Offline.MBTilesWriter,
  uMapLib.Offline.Types;

const
  cProgressNotifyEveryTiles = 16;

type
  TMapLibRegionBuildJob = class;

  TMapLibRegionBuildProgressEvent = procedure(Sender: TMapLibRegionBuildJob;
    ABytesDone, ABytesTotal: Int64; APercent: Double) of object;

  TMapLibRegionBuildCompletedEvent = procedure(Sender: TMapLibRegionBuildJob;
    const AMetadata: TMapLibOfflineRegionMetadata; const AErrorMsg: string; ASuccess: Boolean) of object;

  TMapLibRegionBuildJob = class(TThread)
  private
    FJobId: string;
    FRequest: TMapLibOfflineBuildRegionRequest;
    FStorageBasePath: string;
    FOnProgress: TMapLibRegionBuildProgressEvent;
    FOnCompleted: TMapLibRegionBuildCompletedEvent;
    FSuccess: Boolean;
    FErrorMsg: string;
    FResultMetadata: TMapLibOfflineRegionMetadata;
    FSyncBytesDone: Int64;
    FSyncBytesTotal: Int64;
    FSyncPercent: Double;
    FSuccessfulTileCount: Int64;
    FFailedTileCount: Int64;
{$IFNDEF FPC}
    FProvider: TMapLibHttpRemoteTileProvider;
    FWriter: TMapLibMBTilesWriter;
{$ENDIF}
    procedure SyncProgress;
    procedure SyncCompleted;
    procedure HandleTileEnumerated(const ATile: TMapLibOfflineTileCoordinate);
    procedure HandleBuildTile(const ATile: TMapLibOfflineTileCoordinate);
  protected
    procedure Execute; override;
  public
    constructor Create(const AJobId: string; const ARequest: TMapLibOfflineBuildRegionRequest;
      const AStorageBasePath: string; AOnProgress: TMapLibRegionBuildProgressEvent;
      AOnCompleted: TMapLibRegionBuildCompletedEvent);

    property JobId: string read FJobId;
  end;

implementation

function CombinePath(const ALeft, ARight: string): string;
begin
{$IFDEF FPC}
  if ALeft = '' then
    Result := ARight
  else
    Result := IncludeTrailingPathDelimiter(ALeft) + ARight;
{$ELSE}
  Result := TPath.Combine(ALeft, ARight);
{$ENDIF}
end;

function BuildTemporaryRegionFileName(const ARegionId: string): string;
begin
  Result := ARegionId + '.building.mbtiles';
end;

constructor TMapLibRegionBuildJob.Create(const AJobId: string;
  const ARequest: TMapLibOfflineBuildRegionRequest; const AStorageBasePath: string;
  AOnProgress: TMapLibRegionBuildProgressEvent;
  AOnCompleted: TMapLibRegionBuildCompletedEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FJobId := AJobId;
  FRequest := ARequest;
  FStorageBasePath := AStorageBasePath;
  FOnProgress := AOnProgress;
  FOnCompleted := AOnCompleted;
  FSuccess := False;
  FErrorMsg := '';
  FResultMetadata := Default(TMapLibOfflineRegionMetadata);
end;

procedure TMapLibRegionBuildJob.SyncProgress;
begin
  if Assigned(FOnProgress) and not Terminated then
    FOnProgress(Self, FSyncBytesDone, FSyncBytesTotal, FSyncPercent);
end;

procedure TMapLibRegionBuildJob.SyncCompleted;
begin
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, FResultMetadata, FErrorMsg, FSuccess);
end;

procedure TMapLibRegionBuildJob.HandleTileEnumerated(
  const ATile: TMapLibOfflineTileCoordinate);
begin
  if (ATile.ZoomLevel = 0) and (ATile.TileX < 0) then ;
  if Terminated then
    Exit;
  Inc(FSyncBytesTotal);
end;

procedure TMapLibRegionBuildJob.HandleBuildTile(
  const ATile: TMapLibOfflineTileCoordinate);
{$IFDEF FPC}
begin
  if (ATile.ZoomLevel = 0) and (ATile.TileX < 0) then ;
end;
{$ELSE}
var
  contentEncoding: string;
  contentType: string;
  tileData: TBytes;
begin
  if Terminated then
    Exit;

  if FProvider.TryFetchTile(FRequest.SourceId, ATile.ZoomLevel, ATile.TileX,
    ATile.TileY, tileData, contentType, contentEncoding) then
  begin
    FWriter.PutTile(ATile.ZoomLevel, ATile.TileX, ATile.TileY, tileData);
    Inc(FSuccessfulTileCount);
  end
  else
    Inc(FFailedTileCount);

  Inc(FSyncBytesDone);
  if FSyncBytesTotal > 0 then
    FSyncPercent := (FSyncBytesDone / FSyncBytesTotal) * 100
  else
    FSyncPercent := 0;
  if ((FSyncBytesDone mod cProgressNotifyEveryTiles) = 0) or
    (FSyncBytesDone >= FSyncBytesTotal) then
    TThread.Queue(Self, SyncProgress);
end;
{$ENDIF}

procedure TMapLibRegionBuildJob.Execute;
{$IFDEF FPC}
begin
  FSuccess := False;
  FErrorMsg := 'Offline region build is not implemented for FPC in this milestone.';
  TThread.Queue(Self, @SyncCompleted);
end;
{$ELSE}
var
  finalFileName: string;
  finalFilePath: string;
  shouldDeleteTempFile: Boolean;
  tempFileName: string;
  tempFilePath: string;
begin
  FSuccess := False;
  FErrorMsg := '';
  FSyncBytesDone := 0;
  FSyncBytesTotal := 0;
  FSyncPercent := 0;
  FSuccessfulTileCount := 0;
  FFailedTileCount := 0;
  shouldDeleteTempFile := False;

  if Trim(FStorageBasePath) = '' then
  begin
    FErrorMsg := 'Base storage path does not exist.';
    TThread.Queue(Self, SyncCompleted);
    Exit;
  end;

  if not DirectoryExists(FStorageBasePath) then
    TDirectory.CreateDirectory(FStorageBasePath);

  if Trim(FRequest.RemoteTileTemplate) = '' then
  begin
    FErrorMsg := 'Remote tile template is required.';
    TThread.Queue(Self, SyncCompleted);
    Exit;
  end;

  MapLibEnumerateBoundsTiles(FRequest.Bounds, FRequest.MinZoom, FRequest.MaxZoom,
    HandleTileEnumerated);
  if FSyncBytesTotal <= 0 then
  begin
    FErrorMsg := 'The selected bounds do not produce any tiles for the requested zoom range.';
    TThread.Queue(Self, SyncCompleted);
    Exit;
  end;

  finalFileName := FRequest.RegionId + '.mbtiles';
  finalFilePath := CombinePath(FStorageBasePath, finalFileName);
  tempFileName := BuildTemporaryRegionFileName(FRequest.RegionId);
  tempFilePath := CombinePath(FStorageBasePath, tempFileName);
  if FileExists(tempFilePath) then
    TFile.Delete(tempFilePath);

  FProvider := TMapLibHttpRemoteTileProvider.Create;
  FWriter := nil;
  try
    FProvider.TileUrlTemplate := FRequest.RemoteTileTemplate;
    FWriter := TMapLibMBTilesWriter.Create(tempFilePath);
    FWriter.InitializeRegion(FRequest.RegionId, FRequest.Bounds, FRequest.MinZoom,
      FRequest.MaxZoom, FRequest.DataVersion);

    MapLibEnumerateBoundsTiles(FRequest.Bounds, FRequest.MinZoom, FRequest.MaxZoom,
      HandleBuildTile);

    if Terminated then
    begin
      FSuccess := False;
      FErrorMsg := 'Region build cancelled.';
      shouldDeleteTempFile := True;
    end
    else if FSuccessfulTileCount <= 0 then
    begin
      FSuccess := False;
      if FFailedTileCount > 0 then
        FErrorMsg := 'Region build did not download any usable tiles.'
      else
        FErrorMsg := 'Region build finished without storing any tiles.';
      shouldDeleteTempFile := True;
    end
    else
    begin
      FWriter.Free;
      FWriter := nil;
      if FileExists(finalFilePath) then
        TFile.Delete(finalFilePath);
      TFile.Move(tempFilePath, finalFilePath);
      FResultMetadata.RegionId := FRequest.RegionId;
      FResultMetadata.MinZoom := FRequest.MinZoom;
      FResultMetadata.MaxZoom := FRequest.MaxZoom;
      FResultMetadata.Bounds := FRequest.Bounds;
      FResultMetadata.CreatedAtUtc := Now;
      FResultMetadata.UpdatedAtUtc := Now;
      FResultMetadata.DataVersion := FRequest.DataVersion;
      FResultMetadata.SizeBytes := TFile.GetSize(finalFilePath);
      FResultMetadata.Checksum := '';
      FResultMetadata.StoragePath := finalFileName;
      FSuccess := True;
    end;
  except
    on E: Exception do
    begin
      FSuccess := False;
      FErrorMsg := E.Message;
      shouldDeleteTempFile := True;
    end;
  end;
  FWriter.Free;
  FWriter := nil;
  FProvider.Free;
  FProvider := nil;

  if shouldDeleteTempFile and FileExists(tempFilePath) then
  begin
    try
      TFile.Delete(tempFilePath);
    except
    end;
  end;

  TThread.Queue(Self, SyncCompleted);
end;
{$ENDIF}

end.
