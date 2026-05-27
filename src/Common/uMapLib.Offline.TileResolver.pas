{**
  @abstract(Resolvedor de tiles para modo local, online e hibrido.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Centraliza la decision de servir un tile desde cache local o descargarlo
  desde un proveedor remoto segun el modo y la politica configurados.
}
unit uMapLib.Offline.TileResolver;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  SysUtils,
{$ELSE}
  System.SysUtils,
{$ENDIF}
  uMapLib.Core.Offline,
  uMapLib.Offline.TileStore,
  uMapLib.Offline.RemoteTileProvider,
  uMapLib.Offline.Types;

type
  TMapLibTileResolveStatus = (
    trsNotFound,
    trsLocal,
    trsRemote,
    trsBlocked,
    trsError
  );

  {** @abstract(Resolvedor principal de tiles para runtime vectorial/raster.) }
  TMapLibTileResolver = class
  private
    FMapMode: TMapLibMapMode;
    FOfflinePolicy: TMapLibOfflinePolicy;
    FSourceVariant: string;
    FTileStore: IMapLibTileStore;
    FRemoteTileProvider: IMapLibRemoteTileProvider;
    function TryResolveLocal(const ASourceId: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
    function TryResolveRemote(const ASourceId: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
  public
    constructor Create;
    {**
      @abstract(Resuelve un tile segun modo, politica y cache disponibles.)
      @param(ASourceId Identificador logico de la fuente)
      @param(AZ Nivel de zoom XYZ)
      @param(AX Coordenada X XYZ)
      @param(AY Coordenada Y XYZ)
      @param(ATileData Bytes del tile resuelto)
      @param(AContentType Tipo MIME del tile resuelto)
      @param(AContentEncoding Codificacion HTTP del tile resuelto)
      @returns(Estado final de la resolucion)
    }
    function ResolveTile(const ASourceId: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): TMapLibTileResolveStatus;

    property MapMode: TMapLibMapMode read FMapMode write FMapMode;
    property OfflinePolicy: TMapLibOfflinePolicy read FOfflinePolicy write FOfflinePolicy;
    property SourceVariant: string read FSourceVariant write FSourceVariant;
    property TileStore: IMapLibTileStore read FTileStore write FTileStore;
    property RemoteTileProvider: IMapLibRemoteTileProvider read FRemoteTileProvider write FRemoteTileProvider;
  end;

implementation

{ TMapLibTileResolver }

constructor TMapLibTileResolver.Create;
begin
  inherited Create;
  FMapMode := omOnline;
  FOfflinePolicy := opPreferOffline;
  FSourceVariant := '';
end;

function TMapLibTileResolver.ResolveTile(const ASourceId: string; AZ, AX,
  AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): TMapLibTileResolveStatus;
begin
  SetLength(ATileData, 0);
  AContentType := '';
  AContentEncoding := '';

  if FOfflinePolicy = opOfflineOnly then
  begin
    if TryResolveLocal(ASourceId, AZ, AX, AY, ATileData, AContentType,
      AContentEncoding) then
      Exit(trsLocal);

    if FMapMode = omOffline then
      Exit(trsBlocked);

    Exit(trsNotFound);
  end;

  if FOfflinePolicy = opPreferOnline then
  begin
    if (FMapMode <> omOffline) and TryResolveRemote(ASourceId, AZ, AX, AY,
      ATileData, AContentType, AContentEncoding) then
      Exit(trsRemote);

    if TryResolveLocal(ASourceId, AZ, AX, AY, ATileData, AContentType,
      AContentEncoding) then
      Exit(trsLocal);
  end
  else
  begin
    if TryResolveLocal(ASourceId, AZ, AX, AY, ATileData, AContentType,
      AContentEncoding) then
      Exit(trsLocal);

    if (FMapMode <> omOffline) and TryResolveRemote(ASourceId, AZ, AX, AY,
      ATileData, AContentType, AContentEncoding) then
      Exit(trsRemote);
  end;

  if FMapMode = omOffline then
    Result := trsBlocked
  else
    Result := trsNotFound;
end;

function TMapLibTileResolver.TryResolveLocal(const ASourceId: string; AZ, AX,
  AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
begin
  Result := Assigned(FTileStore) and FTileStore.TryGetTile(ASourceId,
    FSourceVariant, AZ, AX, AY, ATileData, AContentType, AContentEncoding);
end;

function TMapLibTileResolver.TryResolveRemote(const ASourceId: string; AZ, AX,
  AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
begin
  Result := Assigned(FRemoteTileProvider) and
    FRemoteTileProvider.TryFetchTile(ASourceId, AZ, AX, AY, ATileData,
      AContentType, AContentEncoding);
  if Result and Assigned(FTileStore) then
  begin
    try
      FTileStore.PutTile(ASourceId, FSourceVariant, AZ, AX, AY, ATileData,
        AContentType, AContentEncoding);
    except
      // Un fallo de persistencia no debe impedir servir el tile remoto ya descargado.
    end;
  end;
end;

end.
