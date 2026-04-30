{**
  @abstract(Soporte de carga y composición del bootstrap LCL del mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad centraliza la composición del bootstrap HTML/JavaScript del mapa
  para LCL, materializando los recursos embebidos en una carpeta temporal y
  usando recursos de disco solo como fallback de desarrollo.
}
unit uGMLib.Lcl.MapBootstrap;

{$I ..\..\gmlib.inc}

interface

uses
  uGMLib.BootstrapAssets,
  uGMLib.Map;

type
  {** @abstract(Helper para construir el HTML de arranque del mapa LCL.) }
  TGMLibLclMapBootstrap = class
  private
    class function BuildMapsApiScriptUrl(AMap: TGMCustomMap): string; static;
    class function BuildTemplateFallback: string; static;
  public
    class function BuildHtml(AMap: TGMCustomMap): string; static;
  end;

implementation

uses
  System.SysUtils;

class function TGMLibLclMapBootstrap.BuildHtml(AMap: TGMCustomMap): string;
var
  htmlTemplatePath: string;
  htmlTemplate: string;
  mapScriptPath: string;
  mapScript: string;
begin
  htmlTemplatePath := TGMLibBootstrapAssets.EnsureAssetFile('gmlib.map.html',
    'GMLIB_MAP_HTML', 'resources\js\common\gmlib.map.html');
  if htmlTemplatePath <> '' then
    htmlTemplate := TGMLibBootstrapAssets.LoadTextFile(htmlTemplatePath)
  else
    htmlTemplate := BuildTemplateFallback;

  mapScriptPath := TGMLibBootstrapAssets.EnsureAssetFile('gmlib.map.js',
    'GMLIB_MAP_JS', 'resources\js\common\gmlib.map.js');
  if mapScriptPath <> '' then
    mapScript := TGMLibBootstrapAssets.LoadTextFile(mapScriptPath)
  else
    mapScript := '';
  if mapScript = '' then
    raise Exception.Create('Map JavaScript resource "resources\js\common\gmlib.map.js" was not found.');

  Result := htmlTemplate;
  Result := StringReplace(Result, '{{GMLIB_MAP_SCRIPT}}', mapScript, [rfReplaceAll]);
  if AMap.Options.MapId <> '' then
    Result := StringReplace(Result, '{{MAP_ID}}', QuotedStr(string(AMap.Options.MapId)), [rfReplaceAll])
  else
    Result := StringReplace(Result, '{{MAP_ID}}', QuotedStr(string(AMap.MapId)), [rfReplaceAll]);
  Result := StringReplace(Result, '{{MAP_OPTIONS}}', AMap.Options.ToJavaScriptLiteral, [rfReplaceAll]);
  Result := StringReplace(Result, '{{MAPS_API_SCRIPT_URL}}', BuildMapsApiScriptUrl(AMap), [rfReplaceAll]);
end;

class function TGMLibLclMapBootstrap.BuildMapsApiScriptUrl(AMap: TGMCustomMap): string;
var
  MapIdParam: string;
begin
  if AMap.Options.MapId <> '' then
    MapIdParam := AMap.Options.MapId
  else
    MapIdParam := AMap.MapId;

  if MapIdParam <> '' then
  begin
    if Trim(AMap.APIKey) = '' then
      Result := Format(
        'https://maps.googleapis.com/maps/api/js?loading=async&callback=gmlibInitMap&map_ids=%s',
        [MapIdParam]
      )
    else
      Result := Format(
        'https://maps.googleapis.com/maps/api/js?key=%s&loading=async&callback=gmlibInitMap&map_ids=%s',
        [AMap.APIKey, MapIdParam]
      );
    Exit;
  end;

  if Trim(AMap.APIKey) = '' then
    Result := 'https://maps.googleapis.com/maps/api/js?loading=async&callback=gmlibInitMap'
  else
    Result := Format(
      'https://maps.googleapis.com/maps/api/js?key=%s&loading=async&callback=gmlibInitMap',
      [AMap.APIKey]
    );
end;

class function TGMLibLclMapBootstrap.BuildTemplateFallback: string;
begin
  Result :=
    '<!DOCTYPE html>' +
    '<html lang="en">' +
    '<head>' +
    '  <meta charset="utf-8">' +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' +
    '  <title>GMLib Map</title>' +
    '  <style>html, body, #gmlib-map { width: 100%; height: 100%; margin: 0; padding: 0; }</style>' +
    '</head>' +
    '<body>' +
    '  <div id="gmlib-map"></div>' +
    '  <script>{{GMLIB_MAP_SCRIPT}}</script>' +
    '  <script>' +
    '    window.gmlibInitMap = function () {' +
    '      window.gmlib.bootstrapMapId = {{MAP_ID}};' +
    '      window.gmlib.map.initialize({' +
    '        mapId: {{MAP_ID}},' +
    '        options: {{MAP_OPTIONS}}' +
    '      });' +
    '    };' +
    '  </script>' +
    '  <script async src="{{MAPS_API_SCRIPT_URL}}" onerror="window.gmlib && window.gmlib.reportBootstrapError && window.gmlib.reportBootstrapError(''Failed to load Google Maps script'')"></script>' +
    '</body>' +
    '</html>';
end;

end.
