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
    class function BuildCssBlock(AMap: TOSMMap): string; static;
    class function BuildJsBlock(AMap: TOSMMap): string; static;
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

class function TOSMLibLclMapBootstrap.BuildCssBlock(AMap: TOSMMap): string;
var
  cssUrl: string;
begin
  cssUrl := AMap.ResolveMapLibreCssUrl;
  if (cssUrl <> '') and FileExists(cssUrl) then
    Result := '<style>' + TGMLibBootstrapAssets.LoadTextFile(cssUrl) + '</style>'
  else
    Result := '<link rel="stylesheet" href="' + GetOSMMapLibreCssUrl(AMap) + '">';
end;

class function TOSMLibLclMapBootstrap.BuildJsBlock(AMap: TOSMMap): string;
var
  jsUrl: string;
  jsText: string;
begin
  jsUrl := AMap.ResolveMapLibreJsUrl;
  if (jsUrl <> '') and FileExists(jsUrl) then
  begin
    jsText := TGMLibBootstrapAssets.LoadTextFile(jsUrl);
    Result := '<script>' + jsText + '</script>' +
      '<script>window.osmlibBootstrap();</script>';
  end
  else
    Result := '<script src="' + GetOSMMapLibreJsUrl(AMap) +
      '" onload="window.osmlibBootstrap()" onerror="window.osmlibBootstrapError && window.osmlibBootstrapError()"></script>';
end;

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
  Result := StringReplace(Result, '{{MAPLIBRE_CSS_BLOCK}}', BuildCssBlock(AMap), [rfReplaceAll]);
  Result := StringReplace(Result, '{{MAPLIBRE_JS_BLOCK}}', BuildJsBlock(AMap), [rfReplaceAll]);
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
    '  {{MAPLIBRE_CSS_BLOCK}}' +
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
    '  {{MAPLIBRE_JS_BLOCK}}' +
    '</body>' +
    '</html>';
end;

end.
