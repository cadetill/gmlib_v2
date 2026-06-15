{**
  @abstract(Unidad @code(uMapLib.Offline.MBTilesWriter) para construcción de regiones MBTiles.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Implementa un escritor simple de `MBTiles` para regiones generadas por la
  librería a partir de tiles XYZ descargados.
}
unit uMapLib.Offline.MBTilesWriter;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  SysUtils,
  DB,
  sqlite3conn,
  sqldb,
{$ELSE}
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  FireDAC.Phys.SQLiteWrapper.Stat,
{$ENDIF}
  FireDAC.Phys.SQLiteDef,
{$ENDIF}
  uMapLib.Offline.TileStore,
  uMapLib.Offline.Types;

type
  {** @abstract(Escritor de un archivo MBTiles con metadata y tabla de tiles.) }
  TMapLibMBTilesWriter = class
  private
    const cCommitBatchSize = 512;
  private
    FDatabaseFileName: string;
    FIndexesCreated: Boolean;
    FPendingTileWrites: Integer;
{$IFDEF FPC}
    FConnection: TSQLite3Connection;
    FMetadataQuery: TSQLQuery;
    FTileQuery: TSQLQuery;
    function CreateConnection: TSQLite3Connection;
    procedure ExecSql(AConnection: TSQLite3Connection; const ASql: string);
{$ELSE}
    FConnection: TFDConnection;
    FMetadataQuery: TFDQuery;
    FTileQuery: TFDQuery;
    function CreateConnection: TFDConnection;
{$ENDIF}
    procedure ApplyBulkInsertPragmas;
    procedure CreateIndexes;
    procedure InitializeSchema;
    procedure CommitPendingWrites;
    procedure EnsureWriteTransaction;
    procedure PrepareQueries;
    procedure SetMetadataValue(
{$IFDEF FPC}
      AConnection: TSQLite3Connection;
{$ELSE}
      AConnection: TFDConnection;
{$ENDIF}
      const AName, AValue: string);
  public
    constructor Create(const ADatabaseFileName: string);
    destructor Destroy; override;
    procedure InitializeRegion(const ARegionId: string;
      const ABounds: TMapLibOfflineRegionBounds; AMinZoom, AMaxZoom: Integer;
      const ADataVersion: string);
    procedure PutTile(AZoom, AX, AY: Integer; const ATileData: TBytes);

    property DatabaseFileName: string read FDatabaseFileName;
  end;

implementation

function BuildBoundsMetadataValue(
  const ABounds: TMapLibOfflineRegionBounds): string;
var
  formatSettings: TFormatSettings;
begin
{$IFDEF FPC}
  formatSettings := DefaultFormatSettings;
{$ELSE}
  formatSettings := TFormatSettings.Invariant;
{$ENDIF}
  formatSettings.DecimalSeparator := '.';
  Result := Format('%.8f,%.8f,%.8f,%.8f',
    [ABounds.West, ABounds.South, ABounds.East, ABounds.North],
    formatSettings);
end;

{$IFDEF FPC}
function TMapLibMBTilesWriter.CreateConnection: TSQLite3Connection;
var
  transaction: TSQLTransaction;
begin
  Result := TSQLite3Connection.Create(nil);
  try
    transaction := TSQLTransaction.Create(Result);
    transaction.DataBase := Result;
    Result.Transaction := transaction;
    Result.DatabaseName := FDatabaseFileName;
    Result.Open;
    transaction.Active := True;
  except
    Result.Free;
    raise;
  end;
end;

procedure TMapLibMBTilesWriter.ExecSql(AConnection: TSQLite3Connection;
  const ASql: string);
var
  query: TSQLQuery;
begin
  query := TSQLQuery.Create(nil);
  try
    query.DataBase := AConnection;
    query.Transaction := AConnection.Transaction;
    query.SQL.Text := ASql;
    query.ExecSQL;
    AConnection.Transaction.Commit;
    AConnection.Transaction.Active := True;
  finally
    query.Free;
  end;
end;
{$ELSE}
function TMapLibMBTilesWriter.CreateConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.ResourceOptions.SilentMode := True;
  Result.Params.Clear;
  Result.Params.Add('DriverID=SQLite');
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  Result.Params.Add('EngineLinkage=Static');
{$ENDIF}
  Result.Params.Add('Database=' + FDatabaseFileName);
  Result.Open;
end;
{$ENDIF}

constructor TMapLibMBTilesWriter.Create(const ADatabaseFileName: string);
begin
  inherited Create;
  FDatabaseFileName := ADatabaseFileName;
  FIndexesCreated := False;
  FPendingTileWrites := 0;
  FConnection := CreateConnection;
  FMetadataQuery := nil;
  FTileQuery := nil;
  ApplyBulkInsertPragmas;
  InitializeSchema;
  PrepareQueries;
end;

destructor TMapLibMBTilesWriter.Destroy;
begin
  CommitPendingWrites;
  CreateIndexes;
{$IFDEF FPC}
  FTileQuery.Free;
  FMetadataQuery.Free;
  if Assigned(FConnection) then
  begin
    if Assigned(FConnection.Transaction) then
    begin
      if FConnection.Transaction.Active then
        FConnection.Transaction.Commit;
      FConnection.Transaction.Free;
      FConnection.Transaction := nil;
    end;
    FConnection.Free;
  end;
{$ELSE}
  FTileQuery.Free;
  FMetadataQuery.Free;
  FConnection.Free;
{$ENDIF}
  inherited;
end;

procedure TMapLibMBTilesWriter.ApplyBulkInsertPragmas;
begin
{$IFDEF FPC}
  ExecSql(FConnection, 'PRAGMA journal_mode = MEMORY');
  ExecSql(FConnection, 'PRAGMA synchronous = OFF');
  ExecSql(FConnection, 'PRAGMA temp_store = MEMORY');
  ExecSql(FConnection, 'PRAGMA locking_mode = EXCLUSIVE');
  ExecSql(FConnection, 'PRAGMA cache_size = -65536');
{$ELSE}
  FConnection.ExecSQL('PRAGMA journal_mode = MEMORY');
  FConnection.ExecSQL('PRAGMA synchronous = OFF');
  FConnection.ExecSQL('PRAGMA temp_store = MEMORY');
  FConnection.ExecSQL('PRAGMA locking_mode = EXCLUSIVE');
  FConnection.ExecSQL('PRAGMA cache_size = -65536');
{$ENDIF}
end;

procedure TMapLibMBTilesWriter.InitializeSchema;
{$IFDEF FPC}
var
  databaseDir: string;
begin
  databaseDir := ExtractFileDir(FDatabaseFileName);
  if (databaseDir <> '') and not DirectoryExists(databaseDir) then
    ForceDirectories(databaseDir);

  ExecSql(FConnection,
    'CREATE TABLE IF NOT EXISTS metadata (' +
    '  name TEXT NOT NULL PRIMARY KEY,' +
    '  value TEXT' +
    ')');
  ExecSql(FConnection,
    'CREATE TABLE IF NOT EXISTS tiles (' +
    '  zoom_level INTEGER NOT NULL,' +
    '  tile_column INTEGER NOT NULL,' +
    '  tile_row INTEGER NOT NULL,' +
    '  tile_data BLOB NOT NULL' +
    ')');
end;
{$ELSE}
var
  databaseDir: string;
begin
  databaseDir := TPath.GetDirectoryName(FDatabaseFileName);
  if (databaseDir <> '') and not DirectoryExists(databaseDir) then
    TDirectory.CreateDirectory(databaseDir);

  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS metadata (' +
    '  name TEXT NOT NULL PRIMARY KEY,' +
    '  value TEXT' +
    ')');
  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS tiles (' +
    '  zoom_level INTEGER NOT NULL,' +
    '  tile_column INTEGER NOT NULL,' +
    '  tile_row INTEGER NOT NULL,' +
    '  tile_data BLOB NOT NULL' +
    ')');
end;
{$ENDIF}

procedure TMapLibMBTilesWriter.CreateIndexes;
begin
  if FIndexesCreated then
    Exit;

{$IFDEF FPC}
  ExecSql(FConnection,
    'CREATE UNIQUE INDEX IF NOT EXISTS tile_index ON tiles ' +
    '(zoom_level, tile_column, tile_row)');
{$ELSE}
  FConnection.ExecSQL(
    'CREATE UNIQUE INDEX IF NOT EXISTS tile_index ON tiles ' +
    '(zoom_level, tile_column, tile_row)');
{$ENDIF}
  FIndexesCreated := True;
end;

procedure TMapLibMBTilesWriter.EnsureWriteTransaction;
begin
{$IFDEF FPC}
  if Assigned(FConnection) and Assigned(FConnection.Transaction) and
    not FConnection.Transaction.Active then
    FConnection.Transaction.Active := True;
{$ELSE}
  if Assigned(FConnection) and not FConnection.InTransaction then
    FConnection.StartTransaction;
{$ENDIF}
end;

procedure TMapLibMBTilesWriter.CommitPendingWrites;
begin
  if FPendingTileWrites <= 0 then
    Exit;
{$IFDEF FPC}
  if Assigned(FConnection) and Assigned(FConnection.Transaction) and
    FConnection.Transaction.Active then
  begin
    FConnection.Transaction.Commit;
    FConnection.Transaction.Active := True;
  end;
{$ELSE}
  if Assigned(FConnection) and FConnection.InTransaction then
  begin
    FConnection.Commit;
    FConnection.StartTransaction;
  end;
{$ENDIF}
  FPendingTileWrites := 0;
end;

procedure TMapLibMBTilesWriter.PrepareQueries;
begin
{$IFDEF FPC}
  FMetadataQuery := TSQLQuery.Create(nil);
  FMetadataQuery.DataBase := FConnection;
  FMetadataQuery.Transaction := FConnection.Transaction;
  FMetadataQuery.SQL.Text :=
    'INSERT OR REPLACE INTO metadata (name, value) VALUES (:name, :value)';

  FTileQuery := TSQLQuery.Create(nil);
  FTileQuery.DataBase := FConnection;
  FTileQuery.Transaction := FConnection.Transaction;
  FTileQuery.SQL.Text :=
    'INSERT INTO tiles (zoom_level, tile_column, tile_row, tile_data) ' +
    'VALUES (:zoom_level, :tile_column, :tile_row, :tile_data)';
{$ELSE}
  FMetadataQuery := TFDQuery.Create(nil);
  FMetadataQuery.Connection := FConnection;
  FMetadataQuery.SQL.Text :=
    'INSERT OR REPLACE INTO metadata (name, value) VALUES (:name, :value)';
  FMetadataQuery.Params.ParamByName('name').DataType := ftString;
  FMetadataQuery.Params.ParamByName('value').DataType := ftString;
  FMetadataQuery.Prepare;

  FTileQuery := TFDQuery.Create(nil);
  FTileQuery.Connection := FConnection;
  FTileQuery.SQL.Text :=
    'INSERT INTO tiles (zoom_level, tile_column, tile_row, tile_data) ' +
    'VALUES (:zoom_level, :tile_column, :tile_row, :tile_data)';
  FTileQuery.Params.ParamByName('zoom_level').DataType := ftInteger;
  FTileQuery.Params.ParamByName('tile_column').DataType := ftInteger;
  FTileQuery.Params.ParamByName('tile_row').DataType := ftInteger;
  FTileQuery.Params.ParamByName('tile_data').DataType := ftBlob;
  FTileQuery.Prepare;
{$ENDIF}
end;

procedure TMapLibMBTilesWriter.SetMetadataValue(
{$IFDEF FPC}
  AConnection: TSQLite3Connection;
{$ELSE}
  AConnection: TFDConnection;
{$ENDIF}
  const AName, AValue: string);
{$IFDEF FPC}
begin
  if (AConnection = nil) or (FMetadataQuery = nil) then
    Exit;
  EnsureWriteTransaction;
  FMetadataQuery.Params.ParamByName('name').AsString := AName;
  FMetadataQuery.Params.ParamByName('value').AsString := AValue;
  FMetadataQuery.ExecSQL;
  AConnection.Transaction.Commit;
  AConnection.Transaction.Active := True;
end;
{$ELSE}
begin
  if (AConnection = nil) or (FMetadataQuery = nil) then
    Exit;
  EnsureWriteTransaction;
  FMetadataQuery.ParamByName('name').AsString := AName;
  FMetadataQuery.ParamByName('value').AsString := AValue;
  FMetadataQuery.ExecSQL;
  if AConnection.InTransaction then
    AConnection.Commit;
end;
{$ENDIF}

procedure TMapLibMBTilesWriter.InitializeRegion(const ARegionId: string;
  const ABounds: TMapLibOfflineRegionBounds; AMinZoom, AMaxZoom: Integer;
  const ADataVersion: string);
begin
  SetMetadataValue(FConnection, 'name', ARegionId);
  SetMetadataValue(FConnection, 'type', 'baselayer');
  SetMetadataValue(FConnection, 'format', 'pbf');
  SetMetadataValue(FConnection, 'version', ADataVersion);
  SetMetadataValue(FConnection, 'minzoom', IntToStr(AMinZoom));
  SetMetadataValue(FConnection, 'maxzoom', IntToStr(AMaxZoom));
  SetMetadataValue(FConnection, 'bounds', BuildBoundsMetadataValue(ABounds));
end;

procedure TMapLibMBTilesWriter.PutTile(AZoom, AX, AY: Integer;
  const ATileData: TBytes);
{$IFDEF FPC}
var
  tileStream: TBytesStream;
begin
  if FTileQuery = nil then
    Exit;
  EnsureWriteTransaction;
  tileStream := TBytesStream.Create(ATileData);
  try
    FTileQuery.Params.ParamByName('zoom_level').AsInteger := AZoom;
    FTileQuery.Params.ParamByName('tile_column').AsInteger := AX;
    FTileQuery.Params.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZoom, AY);
    tileStream.Position := 0;
    FTileQuery.Params.ParamByName('tile_data').LoadFromStream(tileStream, ftBlob);
    FTileQuery.ExecSQL;
    Inc(FPendingTileWrites);
    if FPendingTileWrites >= cCommitBatchSize then
      CommitPendingWrites;
  finally
    tileStream.Free;
  end;
end;
{$ELSE}
var
  tileStream: TBytesStream;
begin
  if FTileQuery = nil then
    Exit;
  EnsureWriteTransaction;
  tileStream := TBytesStream.Create(ATileData);
  try
    FTileQuery.ParamByName('zoom_level').AsInteger := AZoom;
    FTileQuery.ParamByName('tile_column').AsInteger := AX;
    FTileQuery.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZoom, AY);
    tileStream.Position := 0;
    FTileQuery.ParamByName('tile_data').LoadFromStream(tileStream, ftBlob);
    FTileQuery.ExecSQL;
    Inc(FPendingTileWrites);
    if FPendingTileWrites >= cCommitBatchSize then
      CommitPendingWrites;
  finally
    tileStream.Free;
  end;
end;
{$ENDIF}

end.
