{**
  @abstract(Unidad @code(uMapLib.Offline.MBTilesTileStore) para lectura local de regiones MBTiles.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Implementa un almacén de solo lectura sobre un fichero `MBTiles` estándar.
  Está pensado para servir una región offline activa dentro del runtime
  vectorial sin mezclar sus escrituras con la caché SQLite oportunista.
  @br@br
  @bold(Dependencias):
  @unorderedList(
    @item(@code(uMapLib.Offline.TileStore) - Contrato base de almacén de tiles)
    @item(@code(FireDAC.Phys.SQLite/sqlite3conn) - Acceso SQLite según plataforma)
  )
}
unit uMapLib.Offline.MBTilesTileStore;

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
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  FireDAC.Phys.SQLiteWrapper.Stat,
{$ENDIF}
  FireDAC.Phys.SQLiteDef,
{$ENDIF}
  uMapLib.Offline.TileStore;

type
  {** @abstract(Almacén MBTiles de solo lectura para una región offline activa.) }
  TMapLibMBTilesTileStore = class(TInterfacedObject, IMapLibTileStore)
  private
    FDatabaseFileName: string;
    FFormat: string;
{$IFDEF FPC}
    function CreateConnection: TSQLite3Connection;
    function TableExists(AConnection: TSQLite3Connection; const ATableName: string): Boolean;
    function ReadMetadataValue(AConnection: TSQLite3Connection; const AName: string): string;
{$ELSE}
    function CreateConnection: TFDConnection;
    function TableExists(AConnection: TFDConnection; const ATableName: string): Boolean;
    function ReadMetadataValue(AConnection: TFDConnection; const AName: string): string;
{$ENDIF}
    function ResolveContentType: string;
    function DetectContentEncoding(const ATileData: TBytes): string;
    procedure LoadMetadata;
  public
    constructor Create(const ADatabaseFileName: string);
    function TryGetTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
    procedure PutTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      const ATileData: TBytes; const AContentType, AContentEncoding: string);

    property DatabaseFileName: string read FDatabaseFileName;
    property Format: string read FFormat;
  end;

implementation

{$IFDEF FPC}
function TMapLibMBTilesTileStore.CreateConnection: TSQLite3Connection;
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

function TMapLibMBTilesTileStore.TableExists(AConnection: TSQLite3Connection;
  const ATableName: string): Boolean;
var
  query: TSQLQuery;
begin
  Result := False;
  query := TSQLQuery.Create(nil);
  try
    query.DataBase := AConnection;
    query.Transaction := AConnection.Transaction;
    query.SQL.Text :=
      'SELECT 1 FROM sqlite_master ' +
      'WHERE lower(name) = lower(:table_name) AND type IN (''table'', ''view'')';
    query.Params.ParamByName('table_name').AsString := ATableName;
    query.Open;
    Result := not query.EOF;
  finally
    query.Free;
  end;
end;

function TMapLibMBTilesTileStore.ReadMetadataValue(AConnection: TSQLite3Connection;
  const AName: string): string;
var
  query: TSQLQuery;
begin
  Result := '';
  if not TableExists(AConnection, 'metadata') then
    Exit;

  query := TSQLQuery.Create(nil);
  try
    query.DataBase := AConnection;
    query.Transaction := AConnection.Transaction;
    query.SQL.Text := 'SELECT value FROM metadata WHERE lower(name) = lower(:name)';
    query.Params.ParamByName('name').AsString := AName;
    query.Open;
    if not query.EOF then
      Result := Trim(query.Fields[0].AsString);
  finally
    query.Free;
  end;
end;
{$ELSE}
function TMapLibMBTilesTileStore.CreateConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.ResourceOptions.SilentMode := True;
  Result.Params.Clear;
  Result.Params.Add('DriverID=SQLite');
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  Result.Params.Add('EngineLinkage=Static');
{$ENDIF}
  Result.Params.Add('OpenMode=ReadOnly');
  Result.Params.Add('Database=' + FDatabaseFileName);
  Result.Open;
end;

function TMapLibMBTilesTileStore.TableExists(AConnection: TFDConnection;
  const ATableName: string): Boolean;
var
  query: TFDQuery;
begin
  query := TFDQuery.Create(nil);
  try
    query.Connection := AConnection;
    query.SQL.Text :=
      'SELECT 1 FROM sqlite_master ' +
      'WHERE lower(name) = lower(:table_name) AND type IN (''table'', ''view'')';
    query.ParamByName('table_name').AsString := ATableName;
    query.Open;
    Result := not query.Eof;
  finally
    query.Free;
  end;
end;

function TMapLibMBTilesTileStore.ReadMetadataValue(AConnection: TFDConnection;
  const AName: string): string;
var
  query: TFDQuery;
begin
  Result := '';
  if not TableExists(AConnection, 'metadata') then
    Exit;

  query := TFDQuery.Create(nil);
  try
    query.Connection := AConnection;
    query.SQL.Text := 'SELECT value FROM metadata WHERE lower(name) = lower(:name)';
    query.ParamByName('name').AsString := AName;
    query.Open;
    if not query.Eof then
      Result := Trim(query.Fields[0].AsString);
  finally
    query.Free;
  end;
end;
{$ENDIF}

constructor TMapLibMBTilesTileStore.Create(const ADatabaseFileName: string);
begin
  inherited Create;
  FDatabaseFileName := ADatabaseFileName;
  FFormat := '';
  LoadMetadata;
end;

procedure TMapLibMBTilesTileStore.LoadMetadata;
{$IFDEF FPC}
var
  connection: TSQLite3Connection;
{$ELSE}
var
  connection: TFDConnection;
{$ENDIF}
begin
  if (Trim(FDatabaseFileName) = '') or not FileExists(FDatabaseFileName) then
    Exit;

  connection := CreateConnection;
  try
    FFormat := LowerCase(ReadMetadataValue(connection, 'format'));
  finally
    connection.Free;
  end;
end;

function TMapLibMBTilesTileStore.ResolveContentType: string;
begin
  if (FFormat = 'png') then
    Exit('image/png');
  if (FFormat = 'jpg') or (FFormat = 'jpeg') then
    Exit('image/jpeg');
  if (FFormat = 'webp') then
    Exit('image/webp');
  Result := 'application/x-protobuf';
end;

function TMapLibMBTilesTileStore.DetectContentEncoding(
  const ATileData: TBytes): string;
begin
  Result := '';
  if (Length(ATileData) >= 2) and (ATileData[0] = $1F) and (ATileData[1] = $8B) then
    Result := 'gzip';
end;

function TMapLibMBTilesTileStore.TryGetTile(const ASourceId, ASourceVariant: string;
  AZ, AX, AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
{$IFDEF FPC}
var
  connection: TSQLite3Connection;
  query: TSQLQuery;
  tileStream: TStream;
{$ELSE}
var
  connection: TFDConnection;
  query: TFDQuery;
{$ENDIF}
begin
  Result := False;
  SetLength(ATileData, 0);
  AContentType := '';
  AContentEncoding := '';

  if (Trim(FDatabaseFileName) = '') or not FileExists(FDatabaseFileName) then
    Exit;

  connection := CreateConnection;
  try
    if not TableExists(connection, 'tiles') then
      Exit;

{$IFDEF FPC}
    query := TSQLQuery.Create(nil);
    try
      query.DataBase := connection;
      query.Transaction := connection.Transaction;
      query.SQL.Text :=
        'SELECT tile_data FROM tiles ' +
        'WHERE zoom_level = :zoom_level AND tile_column = :tile_column AND tile_row = :tile_row';
      query.Params.ParamByName('zoom_level').AsInteger := AZ;
      query.Params.ParamByName('tile_column').AsInteger := AX;
      query.Params.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZ, AY);
      query.Open;
      if not query.EOF then
      begin
        tileStream := query.CreateBlobStream(query.Fields[0], bmRead);
        try
          SetLength(ATileData, tileStream.Size);
          if Length(ATileData) > 0 then
            tileStream.ReadBuffer(ATileData[0], Length(ATileData));
        finally
          tileStream.Free;
        end;
        AContentType := ResolveContentType;
        AContentEncoding := DetectContentEncoding(ATileData);
        Result := True;
      end;
    finally
      query.Free;
    end;
{$ELSE}
    query := TFDQuery.Create(nil);
    try
      query.Connection := connection;
      query.SQL.Text :=
        'SELECT tile_data FROM tiles ' +
        'WHERE zoom_level = :zoom_level AND tile_column = :tile_column AND tile_row = :tile_row';
      query.ParamByName('zoom_level').AsInteger := AZ;
      query.ParamByName('tile_column').AsInteger := AX;
      query.ParamByName('tile_row').AsInteger := MapLibTileRowFromXYZ(AZ, AY);
      query.Open;
      if not query.Eof then
      begin
        ATileData := query.Fields[0].AsBytes;
        AContentType := ResolveContentType;
        AContentEncoding := DetectContentEncoding(ATileData);
        Result := True;
      end;
    finally
      query.Free;
    end;
{$ENDIF}
  finally
    connection.Free;
  end;
end;

procedure TMapLibMBTilesTileStore.PutTile(const ASourceId, ASourceVariant: string;
  AZ, AX, AY: Integer; const ATileData: TBytes; const AContentType,
  AContentEncoding: string);
begin
  // Las regiones MBTiles descargadas se tratan como artefactos inmutables.
end;

end.
