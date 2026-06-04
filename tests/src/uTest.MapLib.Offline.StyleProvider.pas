{**
  @abstract(Pruebas automáticas del constructor de estilos offline de MapLib.)
}
unit uTest.MapLib.Offline.StyleProvider;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestMapLibOfflineStyleProvider = class
  public
    [Test]
    procedure BuildStyleJson_ReplacesConfiguredPlaceholders;

    [Test]
    procedure BuildStyleJson_LoadsTemplateFromFileWhenInlineTemplateIsEmpty;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  uMapLib.Offline.StyleProvider;

procedure TTestMapLibOfflineStyleProvider.BuildStyleJson_LoadsTemplateFromFileWhenInlineTemplateIsEmpty;
var
  FileName: string;
  Provider: TMapLibStyleProvider;
  StyleJson: string;
begin
  FileName := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName + '.json');
  Provider := TMapLibStyleProvider.Create;
  try
    TFile.WriteAllText(
      FileName,
      '{"tiles":["{{VECTOR_TILE_URL}}"],"glyphs":"{{GLYPHS_URL}}","sprite":"{{SPRITE_URL}}"}',
      TEncoding.UTF8
    );

    Provider.TemplateFileName := FileName;
    Provider.TileUrlTemplate := 'http://localhost/tile';
    Provider.GlyphsUrlTemplate := 'http://localhost/glyphs/{fontstack}/{range}.pbf';
    Provider.SpriteUrl := 'http://localhost/sprites/sprite';

    StyleJson := Provider.BuildStyleJson;

    Assert.IsTrue(Pos('http://localhost/tile', StyleJson) > 0);
    Assert.IsTrue(Pos('http://localhost/glyphs/{fontstack}/{range}.pbf', StyleJson) > 0);
    Assert.IsTrue(Pos('http://localhost/sprites/sprite', StyleJson) > 0);
  finally
    Provider.Free;
    if FileExists(FileName) then
      TFile.Delete(FileName);
  end;
end;

procedure TTestMapLibOfflineStyleProvider.BuildStyleJson_ReplacesConfiguredPlaceholders;
var
  Provider: TMapLibStyleProvider;
  StyleJson: string;
begin
  Provider := TMapLibStyleProvider.Create;
  try
    Provider.TemplateJson :=
      '{"tiles":["{{VECTOR_TILE_URL}}"],"glyphs":"{{GLYPHS_URL}}","sprite":"{{SPRITE_URL}}"}';
    Provider.TileUrlTemplate := 'http://127.0.0.1:8123/tile/source/{z}/{x}/{y}.pbf';
    Provider.GlyphsUrlTemplate := 'http://127.0.0.1:8123/glyphs/{fontstack}/{range}.pbf';
    Provider.SpriteUrl := 'http://127.0.0.1:8123/sprites/basic';

    StyleJson := Provider.BuildStyleJson;

    Assert.IsTrue(Pos('{{VECTOR_TILE_URL}}', StyleJson) = 0);
    Assert.IsTrue(Pos('{{GLYPHS_URL}}', StyleJson) = 0);
    Assert.IsTrue(Pos('{{SPRITE_URL}}', StyleJson) = 0);
    Assert.IsTrue(Pos('http://127.0.0.1:8123/tile/source/{z}/{x}/{y}.pbf', StyleJson) > 0);
    Assert.IsTrue(Pos('http://127.0.0.1:8123/glyphs/{fontstack}/{range}.pbf', StyleJson) > 0);
    Assert.IsTrue(Pos('http://127.0.0.1:8123/sprites/basic', StyleJson) > 0);
  finally
    Provider.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMapLibOfflineStyleProvider);

end.
