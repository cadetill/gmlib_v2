{**
  @abstract(Implementacion SQLite para cache local de tiles.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad proporciona una primera implementacion de `IMapLibTileStore`
  apoyada en SQLite. Se mantiene fuera de `MapLibCore` por ahora para no fijar
  todavia las dependencias de paquete de FireDAC en este primer paso.
}
unit uMapLib.Offline.SqliteTileStore;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  SysUtils,
  Classes,
  DB,
  sqlite3conn,
  sqldb,
{$ELSE}
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  System.SyncObjs,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.DatS,
  FireDAC.DApt,
{$ENDIF}
  uMapLib.Offline.TileStore;

type
{$IFNDEF FPC}
  TMapLibPendingTileWrite = class
  public
    SourceId: string;
    SourceVariant: string;
    ZoomLevel: Integer;
    TileColumn: Integer;
    TileRow: Integer;
    TileData: TBytes;
    ContentType: string;
    ContentEncoding: string;
  end;

  TMapLibSqliteTileStore = class;

  TMapLibSqliteTileStoreWorker = class(TThread)
  private
    FOwner: TMapLibSqliteTileStore;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TMapLibSqliteTileStore);
  end;
{$ENDIF}

  {** @abstract(Almacen SQLite de tiles con una conexion por operacion.) }
  TMapLibSqliteTileStore = class(TInterfacedObject, IMapLibTileStore)
  private
    FDatabaseFileName: string;
{$IFDEF FPC}
    function CreateConnection: TSQLite3Connection;
    function HasColumn(AConnection: TSQLite3Connection; const ATableName,
      AColumnName: string): Boolean;
    procedure ExecSql(AConnection: TSQLite3Connection; const ASql: string);
{$ELSE}
    FQueueLock: TObject;
    FQueueEvent: TEvent;
    FPendingWrites: TQueue<TMapLibPendingTileWrite>;
    FWorker: TMapLibSqliteTileStoreWorker;
    function CreateConnection: TFDConnection;
    function HasColumn(AConnection: TFDConnection; const ATableName,
      AColumnName: string): Boolean;
    function DequeuePendingWrite: TMapLibPendingTileWrite;
    procedure EnqueuePendingWrite(AWriteRequest: TMapLibPendingTileWrite);
{$ENDIF}
    procedure MigrateSchemaForSourceVariant(
{$IFDEF FPC}
      AConnection: TSQLite3Connection);
{$ELSE}
      AConnection: TFDConnection);
{$ENDIF}
    procedure InitializeSchema;
    procedure PutTileImmediate(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      const ATileData: TBytes; const AContentType, AContentEncoding: string);
  public
    constructor Create(const ADatabaseFileName: string);
    destructor Destroy; override;
    function TryGetTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
    procedure PutTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      const ATileData: TBytes; const AContentType, AContentEncoding: string);

    property DatabaseFileName: string read FDatabaseFileName;
  end;

implementation

{$IFNDEF FPC}
{ TMapLibSqliteTileStoreWorker }

constructor TMapLibSqliteTileStoreWorker.Create(AOwner: TMapLibSqliteTileStore);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;
end;

procedure TMapLibSqliteTileStoreWorker.Execute;
var
  writeRequest: TMapLibPendingTileWrite;
begin
  while not Terminated do
  begin
    if FOwner.FQueueEvent.WaitFor(250) = wrSignaled then
    begin
      repeat
        writeRequest := FOwner.DequeuePendingWrite;
        if writeRequest = nil then
          Break;
        try
          try
            FOwner.PutTileImmediate(writeRequest.SourceId, writeRequest.SourceVariant,
              writeRequest.ZoomLevel, writeRequest.TileColumn, writeRequest.TileRow,
              writeRequest.TileData, writeRequest.ContentType, writeRequest.ContentEncoding);
          except
          end;
        finally
          writeRequest.Free;
        end;
      until Terminated;
    end;
  end;

  repeat
    writeRequest := FOwner.DequeuePendingWrite;
    if writeRequest = nil then
      Break;
    try
      try
        FOwner.PutTileImmediate(writeRequest.SourceId, writeRequest.SourceVariant,
          writeRequest.ZoomLevel, writeRequest.TileColumn, writeRequest.TileRow,
          writeRequest.TileData, writeRequest.ContentType, writeRequest.ContentEncoding);
      except
      end;
    finally
      writeRequest.Free;
    end;
  until False;
end;
{$ENDIF}

{ TMapLibSqliteTileStore }

constructor TMapLibSqliteTileStore.Create(const ADatabaseFileName: string);
begin
  inherited Create;
  FDatabaseFileName := ADatabaseFileName;
{$IFDEF FPC}
  InitializeSchema;
{$ELSE}
  FQueueLock := TObject.Create;
  FQueueEvent := TEvent.Create(nil, False, False, '');
  FPendingWrites := TQueue<TMapLibPendingTileWrite>.Create;
  InitializeSchema;
  FWorker := TMapLibSqliteTileStoreWorker.Create(Self);
{$ENDIF}
end;

destructor TMapLibSqliteTileStore.Destroy;
{$IFNDEF FPC}
var
  writeRequest: TMapLibPendingTileWrite;
{$ENDIF}
begin
{$IFNDEF FPC}
  if Assigned(FWorker) then
  begin
    FWorker.Terminate;
    FQueueEvent.SetEvent;
    FWorker.WaitFor;
    FWorker.Free;
  end;

  while True do
  begin
    writeRequest := DequeuePendingWrite;
    if writeRequest = nil then
      Break;
    writeRequest.Free;
  end;

  FPendingWrites.Free;
  FQueueEvent.Free;
  FQueueLock.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF FPC}
function TMapLibSqliteTileStore.CreateConnection: TSQLite3Connection;
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

procedure TMapLibSqliteTileStore.ExecSql(AConnection: TSQLite3Connection;
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

function TMapLibSqliteTileStore.HasColumn(AConnection: TSQLite3Connection;
  const ATableName, AColumnName: string): Boolean;
var
  query: TSQLQuery;
begin
  Result := False;
  query := TSQLQuery.Create(nil);
  try
    query.DataBase := AConnection;
    query.Transaction := AConnection.Transaction;
    query.SQL.Text := Format('PRAGMA table_info(%s)', [ATableName]);
    query.Open;
    while not query.EOF do
    begin
      if SameText(query.FieldByName('name').AsString, AColumnName) then
        Exit(True);
      query.Next;
    end;
  finally
    query.Free;
  end;
end;
{$ELSE}
function TMapLibSqliteTileStore.CreateConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.ResourceOptions.SilentMode := True;
  Result.Params.Clear;
  Result.Params.Add('DriverID=SQLite');
  Result.Params.Add('Database=' + FDatabaseFileName);
  Result.Params.Add('LockingMode=Normal');
  Result.Params.Add('Synchronous=Off');
  Result.Open;
end;

function TMapLibSqliteTileStore.HasColumn(AConnection: TFDConnection;
  const ATableName, AColumnName: string): Boolean;
var
  query: TFDQuery;
begin
  Result := False;
  query := TFDQuery.Create(nil);
  try
    query.Connection := AConnection;
    query.SQL.Text := Format('PRAGMA table_info(%s)', [ATableName]);
    query.Open;
    while not query.Eof do
    begin
      if SameText(query.FieldByName('name').AsString, AColumnName) then
        Exit(True);
      query.Next;
    end;
  finally
    query.Free;
  end;
end;
{$ENDIF}

procedure TMapLibSqliteTileStore.InitializeSchema;
{$IFDEF FPC}
var
  connection: TSQLite3Connection;
  databaseDir: string;
begin
  databaseDir := ExtractFileDir(FDatabaseFileName);
  if (databaseDir <> '') and not DirectoryExists(databaseDir) then
    ForceDirectories(databaseDir);

  connection := CreateConnection;
  try
    ExecSql(connection,
      'CREATE TABLE IF NOT EXISTS tiles (' +
      '  source_id TEXT NOT NULL,' +
      '  source_variant TEXT NOT NULL DEFAULT '''',' +
      '  zoom_level INTEGER NOT NULL,' +
      '  tile_column INTEGER NOT NULL,' +
      '  tile_row INTEGER NOT NULL,' +
      '  tile_data BLOB NOT NULL,' +
      '  content_type TEXT,' +
      '  content_encoding TEXT,' +
      '  updated_at_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      '  PRIMARY KEY (source_id, source_variant, zoom_level, tile_column, tile_row)' +
      ')'
    );
    MigrateSchemaForSourceVariant(connection);
    if not HasColumn(connection, 'tiles', 'updated_at_utc') then
      ExecSql(connection,
        'ALTER TABLE tiles ADD COLUMN updated_at_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP'
      );
  finally
    connection.Free;
  end;
end;
{$ELSE}
var
  connection: TFDConnection;
  databaseDir: string;
begin
  databaseDir := TPath.GetDirectoryName(FDatabaseFileName);
  if (databaseDir <> '') and not DirectoryExists(databaseDir) then
    TDirectory.CreateDirectory(databaseDir);

  connection := CreateConnection;
  try
    connection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS tiles (' +
      '  source_id TEXT NOT NULL,' +
      '  source_variant TEXT NOT NULL DEFAULT '''',' +
      '  zoom_level INTEGER NOT NULL,' +
      '  tile_column INTEGER NOT NULL,' +
      '  tile_row INTEGER NOT NULL,' +
      '  tile_data BLOB NOT NULL,' +
      '  content_type TEXT,' +
      '  content_encoding TEXT,' +
      '  updated_at_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      '  PRIMARY KEY (source_id, source_variant, zoom_level, tile_column, tile_row)' +
      ')'
    );
    MigrateSchemaForSourceVariant(connection);
    if not HasColumn(connection, 'tiles', 'updated_at_utc') then
      connection.ExecSQL(
        'ALTER TABLE tiles ADD COLUMN updated_at_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP'
      );
  finally
    connection.Free;
  end;
end;
{$ENDIF}

procedure TMapLibSqliteTileStore.MigrateSchemaForSourceVariant(
{$IFDEF FPC}
  AConnection: TSQLite3Connection);
{$ELSE}
  AConnection: TFDConnection);
{$ENDIF}
var
  copySql: string;
begin
  if HasColumn(AConnection, 'tiles', 'source_variant') then
    Exit;

{$IFDEF FPC}
  ExecSql(AConnection, 'ALTER TABLE tiles RENAME TO tiles_legacy');
{$ELSE}
  AConnection.ExecSQL('ALTER TABLE tiles RENAME TO tiles_legacy');
{$ENDIF}
  try
{$IFDEF FPC}
    ExecSql(AConnection,
{$ELSE}
    AConnection.ExecSQL(
{$ENDIF}
      'CREATE TABLE tiles (' +
      '  source_id TEXT NOT NULL,' +
      '  source_variant TEXT NOT NULL DEFAULT '''',' +
      '  zoom_level INTEGER NOT NULL,' +
      '  tile_column INTEGER NOT NULL,' +
      '  tile_row INTEGER NOT NULL,' +
      '  tile_data BLOB NOT NULL,' +
      '  content_type TEXT,' +
      '  content_encoding TEXT,' +
      '  updated_at_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
      '  PRIMARY KEY (source_id, source_variant, zoom_level, tile_column, tile_row)' +
      ')'
    );
    if HasColumn(AConnection, 'tiles_legacy', 'updated_at_utc') then
      copySql :=
        'INSERT INTO tiles ' +
        '(source_id, source_variant, zoom_level, tile_column, tile_row, tile_data, content_type, content_encoding, updated_at_utc) ' +
        'SELECT source_id, '''', zoom_level, tile_column, tile_row, tile_data, content_type, content_encoding, ' +
        'COALESCE(updated_at_utc, CURRENT_TIMESTAMP) ' +
        'FROM tiles_legacy'
    else
      copySql :=
        'INSERT INTO tiles ' +
        '(source_id, source_variant, zoom_level, tile_column, tile_row, tile_data, content_type, content_encoding, updated_at_utc) ' +
        'SELECT source_id, '''', zoom_level, tile_column, tile_row, tile_data, content_type, content_encoding, ' +
        'CURRENT_TIMESTAMP ' +
        'FROM tiles_legacy';

{$IFDEF FPC}
    ExecSql(AConnection, copySql);
{$ELSE}
    AConnection.ExecSQL(copySql);
{$ENDIF}
  finally
{$IFDEF FPC}
    ExecSql(AConnection, 'DROP TABLE IF EXISTS tiles_legacy');
{$ELSE}
    AConnection.ExecSQL('DROP TABLE IF EXISTS tiles_legacy');
{$ENDIF}
  end;
end;

{$IFNDEF FPC}
function TMapLibSqliteTileStore.DequeuePendingWrite: TMapLibPendingTileWrite;
begin
  Result := nil;
  TMonitor.Enter(FQueueLock);
  try
    if FPendingWrites.Count > 0 then
      Result := FPendingWrites.Dequeue;
  finally
    TMonitor.Exit(FQueueLock);
  end;
end;

procedure TMapLibSqliteTileStore.EnqueuePendingWrite(
  AWriteRequest: TMapLibPendingTileWrite);
begin
  TMonitor.Enter(FQueueLock);
  try
    FPendingWrites.Enqueue(AWriteRequest);
  finally
    TMonitor.Exit(FQueueLock);
  end;
  FQueueEvent.SetEvent;
end;
{$ENDIF}

procedure TMapLibSqliteTileStore.PutTile(const ASourceId, ASourceVariant: string;
  AZ, AX, AY: Integer; const ATileData: TBytes; const AContentType,
  AContentEncoding: string);
{$IFDEF FPC}
begin
  PutTileImmediate(ASourceId, ASourceVariant, AZ, AX, AY, Copy(ATileData),
    AContentType, AContentEncoding);
end;
{$ELSE}
var
  writeRequest: TMapLibPendingTileWrite;
begin
  writeRequest := TMapLibPendingTileWrite.Create;
  writeRequest.SourceId := ASourceId;
  writeRequest.SourceVariant := ASourceVariant;
  writeRequest.ZoomLevel := AZ;
  writeRequest.TileColumn := AX;
  writeRequest.TileRow := AY;
  writeRequest.TileData := Copy(ATileData);
  writeRequest.ContentType := AContentType;
  writeRequest.ContentEncoding := AContentEncoding;
  EnqueuePendingWrite(writeRequest);
end;
{$ENDIF}

procedure TMapLibSqliteTileStore.PutTileImmediate(const ASourceId,
  ASourceVariant: string; AZ, AX, AY: Integer; const ATileData: TBytes;
  const AContentType, AContentEncoding: string);
{$IFDEF FPC}
var
  connection: TSQLite3Connection;
  query: TSQLQuery;
  tileStream: TBytesStream;
begin
  connection := CreateConnection;
  try
    query := TSQLQuery.Create(nil);
    try
      tileStream := TBytesStream.Create(ATileData);
      try
        query.DataBase := connection;
        query.Transaction := connection.Transaction;
        query.SQL.Text :=
          'INSERT OR REPLACE INTO tiles ' +
          '(source_id, source_variant, zoom_level, tile_column, tile_row, tile_data, content_type, content_encoding, updated_at_utc) ' +
          'VALUES (:source_id, :source_variant, :zoom_level, :tile_column, :tile_row, :tile_data, :content_type, :content_encoding, CURRENT_TIMESTAMP)';
        query.Params.ParamByName('source_id').AsString := ASourceId;
        query.Params.ParamByName('source_variant').AsString := ASourceVariant;
        query.Params.ParamByName('zoom_level').AsInteger := AZ;
        query.Params.ParamByName('tile_column').AsInteger := AX;
        query.Params.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZ, AY);
        tileStream.Position := 0;
        query.Params.ParamByName('tile_data').LoadFromStream(tileStream, ftBlob);
        query.Params.ParamByName('content_type').AsString := AContentType;
        query.Params.ParamByName('content_encoding').AsString := AContentEncoding;
        query.ExecSQL;
        connection.Transaction.Commit;
      finally
        tileStream.Free;
      end;
    finally
      query.Free;
    end;
  finally
    connection.Free;
  end;
end;
{$ELSE}
var
  connection: TFDConnection;
  query: TFDQuery;
  tileStream: TBytesStream;
begin
  connection := CreateConnection;
  try
    query := TFDQuery.Create(nil);
    try
      tileStream := TBytesStream.Create(ATileData);
      try
        query.Connection := connection;
        query.SQL.Text :=
          'INSERT OR REPLACE INTO tiles ' +
          '(source_id, source_variant, zoom_level, tile_column, tile_row, tile_data, content_type, content_encoding, updated_at_utc) ' +
          'VALUES (:source_id, :source_variant, :zoom_level, :tile_column, :tile_row, :tile_data, :content_type, :content_encoding, CURRENT_TIMESTAMP)';
        query.ParamByName('source_id').AsString := ASourceId;
        query.ParamByName('source_variant').AsString := ASourceVariant;
        query.ParamByName('zoom_level').AsInteger := AZ;
        query.ParamByName('tile_column').AsInteger := AX;
        query.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZ, AY);
        tileStream.Position := 0;
        query.ParamByName('tile_data').LoadFromStream(tileStream, ftBlob);
        query.ParamByName('content_type').AsString := AContentType;
        query.ParamByName('content_encoding').AsString := AContentEncoding;
        query.ExecSQL;
      finally
        tileStream.Free;
      end;
    finally
      query.Free;
    end;
  finally
    connection.Free;
  end;
end;
{$ENDIF}

function TMapLibSqliteTileStore.TryGetTile(const ASourceId, ASourceVariant: string;
  AZ, AX, AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
{$IFDEF FPC}
var
  connection: TSQLite3Connection;
  query: TSQLQuery;
  tileStream: TStream;
begin
  Result := False;
  SetLength(ATileData, 0);
  AContentType := '';
  AContentEncoding := '';

  connection := CreateConnection;
  try
    query := TSQLQuery.Create(nil);
    try
      query.DataBase := connection;
      query.Transaction := connection.Transaction;
      query.SQL.Text :=
        'SELECT tile_data, content_type, content_encoding ' +
        'FROM tiles ' +
        'WHERE source_id = :source_id AND source_variant = :source_variant AND zoom_level = :zoom_level AND ' +
        'tile_column = :tile_column AND tile_row = :tile_row';
      query.Params.ParamByName('source_id').AsString := ASourceId;
      query.Params.ParamByName('source_variant').AsString := ASourceVariant;
      query.Params.ParamByName('zoom_level').AsInteger := AZ;
      query.Params.ParamByName('tile_column').AsInteger := AX;
      query.Params.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZ, AY);
      query.Open;
      if not query.EOF then
      begin
        tileStream := query.CreateBlobStream(query.FieldByName('tile_data'), bmRead);
        try
          SetLength(ATileData, tileStream.Size);
          if Length(ATileData) > 0 then
            tileStream.ReadBuffer(ATileData[0], Length(ATileData));
        finally
          tileStream.Free;
        end;
        AContentType := query.FieldByName('content_type').AsString;
        AContentEncoding := query.FieldByName('content_encoding').AsString;
        Result := True;
      end;
    finally
      query.Free;
    end;
  finally
    connection.Free;
  end;
end;
{$ELSE}
var
  connection: TFDConnection;
  query: TFDQuery;
begin
  Result := False;
  SetLength(ATileData, 0);
  AContentType := '';
  AContentEncoding := '';

  connection := CreateConnection;
  try
    query := TFDQuery.Create(nil);
    try
      query.Connection := connection;
      query.SQL.Text :=
        'SELECT tile_data, content_type, content_encoding ' +
        'FROM tiles ' +
        'WHERE source_id = :source_id AND source_variant = :source_variant AND zoom_level = :zoom_level AND ' +
        'tile_column = :tile_column AND tile_row = :tile_row';
      query.ParamByName('source_id').AsString := ASourceId;
      query.ParamByName('source_variant').AsString := ASourceVariant;
      query.ParamByName('zoom_level').AsInteger := AZ;
      query.ParamByName('tile_column').AsInteger := AX;
      query.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZ, AY);
      query.Open;
      if not query.Eof then
      begin
        ATileData := query.FieldByName('tile_data').AsBytes;
        AContentType := query.FieldByName('content_type').AsString;
        AContentEncoding := query.FieldByName('content_encoding').AsString;
        Result := True;
      end;
    finally
      query.Free;
    end;
  finally
    connection.Free;
  end;
end;
{$ENDIF}

end.
