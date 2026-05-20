{**
  @abstract(OSMLib MapLibre bootstrap for LCL.)
}
unit uOSMLib.Lcl.MapBootstrap;

{$I ..\..\..\gmlib.inc}

interface

uses
  uGMLib.BootstrapAssets,
  uOSMLib.Map;

type
  TOSMLibLclMapBootstrap = class
  private
    class function BuildTemplateFallback: string; static;
  public
    class function BuildHtml(AMap: TOSMMap): string; static;
  end;

implementation

uses
{$IFDEF FPC}
  SysUtils;
{$ELSE}
  System.SysUtils;
{$ENDIF}

class function TOSMLibLclMapBootstrap.BuildHtml(AMap: TOSMMap): string;
var
  htmlTemplatePath: string;
  htmlTemplate: string;
  mapScriptPath: string;
  mapScript: string;
begin
  htmlTemplatePath := TGMLibBootstrapAssets.EnsureAssetFile('osmlib.map.html',
    'OSMLIB_MAP_HTML', 'resources\js\osm\osmlib.map.html');
  if htmlTemplatePath <> '' then
    htmlTemplate := TGMLibBootstrapAssets.LoadTextFile(htmlTemplatePath)
  else
    htmlTemplate := BuildTemplateFallback;

  mapScriptPath := TGMLibBootstrapAssets.EnsureAssetFile('osmlib.map.js',
    'OSMLIB_MAP_JS', 'resources\js\osm\osmlib.map.js');
  if mapScriptPath <> '' then
    mapScript := TGMLibBootstrapAssets.LoadTextFile(mapScriptPath)
  else
    mapScript := '';
  if mapScript = '' then
    raise Exception.Create('Map JavaScript resource "resources\js\osm\osmlib.map.js" was not found.');

  Result := htmlTemplate;
  Result := StringReplace(Result, '{{OSMLIB_MAP_SCRIPT}}', mapScript, [rfReplaceAll]);
  Result := StringReplace(Result, '{{OSMLIB_BOOTSTRAP_CONFIG}}', AMap.BuildJsBootstrapConfig, [rfReplaceAll]);
  Result := StringReplace(Result, '{{MAPLIBRE_CSS_URL}}', GetOSMMapLibreCssUrl(AMap), [rfReplaceAll]);
  Result := StringReplace(Result, '{{MAPLIBRE_JS_URL}}', GetOSMMapLibreJsUrl(AMap), [rfReplaceAll]);
end;

class function TOSMLibLclMapBootstrap.BuildTemplateFallback: string;
begin
  Result :=
    '<!DOCTYPE html>' +
    '<html lang="en">' +
    '<head>' +
    '  <meta charset="utf-8">' +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' +
    '  <title>OSMLib Map</title>' +
    '  <link rel="stylesheet" href="{{MAPLIBRE_CSS_URL}}">' +
    '  <style>html, body, #osmlib-map { width: 100%; height: 100%; margin: 0; padding: 0; }</style>' +
    '</head>' +
    '<body>' +
    '  <div id="osmlib-map"></div>' +
    '  <script>{{OSMLIB_MAP_SCRIPT}}</script>' +
    '  <script>' +
    '    window.osmlibBootstrap = function () {' +
    '      window.osmlib.bootstrap({{OSMLIB_BOOTSTRAP_CONFIG}});' +
    '    };' +
    '  </script>' +
    '  <script src="{{MAPLIBRE_JS_URL}}" onload="window.osmlibBootstrap()"></script>' +
    '</body>' +
    '</html>';
end;

end.
