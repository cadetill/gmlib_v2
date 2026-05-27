{**
  @abstract(Constructor centralizado del style JSON para MapLibre.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad encapsula la construccion del style final para evitar que el
  bootstrap, el mapa y el runtime repliquen logica de sustitucion de rutas.
}
unit uMapLib.Offline.StyleProvider;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils;
{$ELSE}
  System.Classes, System.SysUtils;
{$ENDIF}

type
  {** @abstract(Contrato base para construir el style final.) }
  IMapLibStyleProvider = interface
    ['{4CB5F5C8-87DB-482F-A25D-FC60BFC92F7E}']
    {**
      @abstract(Devuelve el style final listo para inyectar en HTML o servir por HTTP.)
      @returns(Documento Style JSON final con placeholders ya resueltos)
    }
    function BuildStyleJson: string;
  end;

  {**
    @abstract(Implementacion simple basada en plantilla de texto.)

    Soporta sustitucion por placeholders para mantener barata la transicion
    futura entre style embebido y style servido por localhost.
  }
  TMapLibStyleProvider = class(TInterfacedObject, IMapLibStyleProvider)
  private
    FTemplateJson: string;
    FTemplateFileName: string;
    FTileUrlTemplate: string;
    FGlyphsUrlTemplate: string;
    FSpriteUrl: string;
    function LoadTemplateJson: string;
  public
    {**
      @abstract(Construye el style final a partir de plantilla y placeholders.)
      @returns(Style JSON listo para consumo por MapLibre)
    }
    function BuildStyleJson: string;

    property TemplateJson: string read FTemplateJson write FTemplateJson;
    property TemplateFileName: string read FTemplateFileName write FTemplateFileName;
    property TileUrlTemplate: string read FTileUrlTemplate write FTileUrlTemplate;
    property GlyphsUrlTemplate: string read FGlyphsUrlTemplate write FGlyphsUrlTemplate;
    property SpriteUrl: string read FSpriteUrl write FSpriteUrl;
  end;

implementation

function LoadTextFileUtf8(const AFileName: string): string;
var
  textLines: TStringList;
begin
  textLines := TStringList.Create;
  try
{$IFDEF FPC}
    textLines.LoadFromFile(AFileName);
{$ELSE}
    textLines.LoadFromFile(AFileName, TEncoding.UTF8);
{$ENDIF}
    Result := textLines.Text;
  finally
    textLines.Free;
  end;
end;

{ TMapLibStyleProvider }

function TMapLibStyleProvider.BuildStyleJson: string;
begin
  Result := LoadTemplateJson;
  Result := StringReplace(Result, '{{VECTOR_TILE_URL}}', FTileUrlTemplate, [rfReplaceAll]);
  Result := StringReplace(Result, '{{GLYPHS_URL}}', FGlyphsUrlTemplate, [rfReplaceAll]);
  Result := StringReplace(Result, '{{SPRITE_URL}}', FSpriteUrl, [rfReplaceAll]);
end;

function TMapLibStyleProvider.LoadTemplateJson: string;
begin
  if Trim(FTemplateJson) <> '' then
    Exit(FTemplateJson);

  if (Trim(FTemplateFileName) <> '') and FileExists(FTemplateFileName) then
    Exit(LoadTextFileUtf8(FTemplateFileName));

  Result := '';
end;

end.
