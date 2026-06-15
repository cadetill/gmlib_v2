{**
  @abstract(Unidad @code(uMapLib.Offline.CompositeTileStore) para composición de stores offline.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Permite encadenar varias fuentes locales con prioridad de lectura y un único
  destino de escritura. Se usa para priorizar una región `MBTiles` activa y
  dejar la escritura remota en la caché SQLite oportunista.
}
unit uMapLib.Offline.CompositeTileStore;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  SysUtils,
{$ELSE}
  System.SysUtils,
{$ENDIF}
  uMapLib.Offline.TileStore;

type
  {** @abstract(Store compuesto con prioridad de lectura y escritura separada.) }
  TMapLibCompositeTileStore = class(TInterfacedObject, IMapLibTileStore)
  private
    FPrimaryStore: IMapLibTileStore;
    FSecondaryStore: IMapLibTileStore;
    FWritableStore: IMapLibTileStore;
  public
    constructor Create(const APrimaryStore, ASecondaryStore,
      AWritableStore: IMapLibTileStore);
    function TryGetTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
    procedure PutTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      const ATileData: TBytes; const AContentType, AContentEncoding: string);
  end;

implementation

constructor TMapLibCompositeTileStore.Create(const APrimaryStore,
  ASecondaryStore, AWritableStore: IMapLibTileStore);
begin
  inherited Create;
  FPrimaryStore := APrimaryStore;
  FSecondaryStore := ASecondaryStore;
  FWritableStore := AWritableStore;
end;

function TMapLibCompositeTileStore.TryGetTile(const ASourceId,
  ASourceVariant: string; AZ, AX, AY: Integer; out ATileData: TBytes;
  out AContentType, AContentEncoding: string): Boolean;
begin
  Result := Assigned(FPrimaryStore) and
    FPrimaryStore.TryGetTile(ASourceId, ASourceVariant, AZ, AX, AY, ATileData,
      AContentType, AContentEncoding);
  if Result then
    Exit;

  Result := Assigned(FSecondaryStore) and
    FSecondaryStore.TryGetTile(ASourceId, ASourceVariant, AZ, AX, AY, ATileData,
      AContentType, AContentEncoding);
end;

procedure TMapLibCompositeTileStore.PutTile(const ASourceId, ASourceVariant: string;
  AZ, AX, AY: Integer; const ATileData: TBytes; const AContentType,
  AContentEncoding: string);
begin
  if Assigned(FWritableStore) then
    FWritableStore.PutTile(ASourceId, ASourceVariant, AZ, AX, AY, ATileData,
      AContentType, AContentEncoding);
end;

end.
