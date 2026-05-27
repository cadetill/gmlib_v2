{**
  @abstract(Contratos de almacenamiento para tiles offline de MapLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Define la interfaz base para leer y escribir tiles desde un almacenamiento
  local, sin acoplar el runtime a una tecnologia concreta como SQLite.
}
unit uMapLib.Offline.TileStore;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  SysUtils;
{$ELSE}
  System.SysUtils;
{$ENDIF}

type
  {** @abstract(Contrato base para un almacen local de tiles.) }
  IMapLibTileStore = interface
    ['{95CF8104-F5E1-44E6-B485-D26D3E8A8A56}']
    {**
      @abstract(Intenta obtener un tile local.)
      @param(ASourceId Identificador logico de la fuente)
      @param(AZ Nivel de zoom XYZ)
      @param(AX Coordenada X XYZ)
      @param(AY Coordenada Y XYZ)
      @param(ATileData Bytes del tile encontrados)
      @param(AContentType Tipo MIME del tile)
      @param(AContentEncoding Codificacion HTTP del tile)
      @returns(@true si el tile existe en local)
    }
    function TryGetTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;

    {**
      @abstract(Guarda o reemplaza un tile local.)
      @param(ASourceId Identificador logico de la fuente)
      @param(AZ Nivel de zoom XYZ)
      @param(AX Coordenada X XYZ)
      @param(AY Coordenada Y XYZ)
      @param(ATileData Bytes del tile)
      @param(AContentType Tipo MIME del tile)
      @param(AContentEncoding Codificacion HTTP del tile)
    }
    procedure PutTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      const ATileData: TBytes; const AContentType, AContentEncoding: string);
  end;

{**
  @abstract(Convierte una coordenada Y en formato XYZ a fila TMS/MBTiles.)
  @param(AZoom Nivel de zoom)
  @param(AY Coordenada Y en formato XYZ)
  @returns(Fila TMS equivalente)
}
function MapLibTileRowFromXYZ(AZoom, AY: Integer): Integer;

implementation

function MapLibTileRowFromXYZ(AZoom, AY: Integer): Integer;
begin
  Result := (1 shl AZoom) - 1 - AY;
end;

end.
