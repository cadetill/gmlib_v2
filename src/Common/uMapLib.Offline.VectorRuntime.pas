{**
  @abstract(Runtime coordinador para navegacion vectorial por localhost.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Compone servidor local, resolvedor de tiles y proveedor de estilo para que
  `TOSMMap` pueda consumir el runtime como una sola pieza.
}
unit uMapLib.Offline.VectorRuntime;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils, StrUtils, URIParser,
{$ELSE}
  System.Classes, System.SysUtils, System.StrUtils, System.IOUtils,
  IdURI,
{$ENDIF}
  uMapLib.Core.Offline,
  uMapLib.Offline.LocalHttpServer,
  uMapLib.Offline.RemoteTileProvider,
  uMapLib.Offline.TileStore,
  uMapLib.Offline.StyleProvider,
  uMapLib.Offline.TileResolver,
  uMapLib.Offline.Types;

type
  {** @abstract(Coordinador principal del runtime vectorial local.) }
  TMapLibVectorRuntime = class
  private
    FBootstrapHtml: string;
    FSourceId: string;
    FMapMode: TMapLibMapMode;
    FOfflinePolicy: TMapLibOfflinePolicy;
    FOfflineStoragePath: string;
    FActiveRegionFileName: string;
    FStyleTemplateFileName: string;
    FGlyphsRootPath: string;
    FTileStore: IMapLibTileStore;
    FCacheTileStore: IMapLibTileStore;
    FRegionTileStore: IMapLibTileStore;
    FTileStoreDatabaseFileName: string;
    FRegionTileStoreFileName: string;
    FLocalHttpServer: TMapLibLocalHttpServer;
    FStyleProvider: TMapLibStyleProvider;
    FTileResolver: TMapLibTileResolver;
    FRemoteTileProvider: TMapLibHttpRemoteTileProvider;
    procedure ConfigureTileStore;
    function ResolveTileStoreDatabaseFileName: string;
    function BuildGlyphsUrlTemplate: string;
    function DetectContentEncoding(const AData: TBytes): string;
    function TryServeAssetRequest(ARequest: TMapLibHttpRequestData;
      AResponse: TMapLibHttpResponseData): Boolean;
    function TryServeGlyphRequest(ARequest: TMapLibHttpRequestData;
      AResponse: TMapLibHttpResponseData): Boolean;
    procedure HandleServerCommand(Sender: TObject; ARequest: TMapLibHttpRequestData;
      AResponse: TMapLibHttpResponseData;
      var AHandled: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    {** @abstract(Arranca el runtime local y prepara sus colaboradores.) }
    function Start: Boolean;
    {** @abstract(Detiene el runtime local y libera sus recursos vivos.) }
    procedure Stop;
    {** @abstract(Devuelve la base URL efectiva del runtime local.) }
    function GetBaseUrl: string;
    {** @abstract(Construye la plantilla localhost para tiles de una fuente logica.) }
    function BuildTileUrlTemplate(const ASourceId: string = ''): string;
    {** @abstract(Construye el style JSON final para MapLibre.) }
    function BuildStyleJson: string;
    function BuildBootstrapUrl: string;

    property SourceId: string read FSourceId write FSourceId;
    property MapMode: TMapLibMapMode read FMapMode write FMapMode;
    property OfflinePolicy: TMapLibOfflinePolicy read FOfflinePolicy write FOfflinePolicy;
    property OfflineStoragePath: string read FOfflineStoragePath write FOfflineStoragePath;
    property ActiveRegionFileName: string read FActiveRegionFileName write FActiveRegionFileName;
    property StyleTemplateFileName: string read FStyleTemplateFileName write FStyleTemplateFileName;
    property GlyphsRootPath: string read FGlyphsRootPath write FGlyphsRootPath;
    property BootstrapHtml: string read FBootstrapHtml write FBootstrapHtml;
    property LocalHttpServer: TMapLibLocalHttpServer read FLocalHttpServer;
    property RemoteTileProvider: TMapLibHttpRemoteTileProvider read FRemoteTileProvider;
    property StyleProvider: TMapLibStyleProvider read FStyleProvider write FStyleProvider;
    property TileResolver: TMapLibTileResolver read FTileResolver;
  end;

implementation

{$IFDEF FPC}
uses
  uMapLib.Offline.SqliteTileStore,
  uMapLib.Offline.RegionTileStore,
  uMapLib.Offline.CompositeTileStore,
  fphttpclient;
{$ELSE}
uses
  uMapLib.Offline.SqliteTileStore,
  uMapLib.Offline.RegionTileStore,
  uMapLib.Offline.CompositeTileStore;
{$ENDIF}

const
  cDefaultVectorStyleTemplate =
    '{' +
    '"version":8,' +
    '"name":"OSMLib Local Vector Runtime",' +
    '"glyphs":"{{GLYPHS_URL}}",' +
    '"sources":{"osm":{"type":"vector","tiles":["{{VECTOR_TILE_URL}}"],"minzoom":0,"maxzoom":14}},' +
    '"layers":[' +
      '{"id":"background","type":"background","paint":{"background-color":"#eef2f6"}},' +
      '{"id":"landcover","type":"fill","source":"osm","source-layer":"landcover","paint":{"fill-color":"#dce9d1","fill-opacity":0.7}},' +
      '{"id":"landuse","type":"fill","source":"osm","source-layer":"landuse","paint":{"fill-color":"#e8eddc","fill-opacity":0.45}},' +
      '{"id":"park","type":"fill","source":"osm","source-layer":"park","paint":{"fill-color":"#d9ead3","fill-opacity":0.8}},' +
      '{"id":"water","type":"fill","source":"osm","source-layer":"water","paint":{"fill-color":"#9ec9ff","fill-opacity":0.95}},' +
      '{"id":"waterway","type":"line","source":"osm","source-layer":"waterway","paint":{"line-color":"#7eb6f5","line-width":["interpolate",["linear"],["zoom"],6,0.4,10,1.1,14,2.2]}},' +
      '{"id":"boundary","type":"line","source":"osm","source-layer":"boundary","paint":{"line-color":"#8f98a6","line-width":["interpolate",["linear"],["zoom"],3,0.3,8,0.8,14,1.4],"line-dasharray":[2,2]}},' +
      '{"id":"transportation-casing","type":"line","source":"osm","source-layer":"transportation","paint":{"line-color":"#c8c2b8","line-width":["interpolate",["linear"],["zoom"],3,0.4,8,1.6,12,3.8,15,8.5],"line-opacity":0.85}},' +
      '{"id":"transportation-fill","type":"line","source":"osm","source-layer":"transportation","paint":{"line-color":"#ffffff","line-width":["interpolate",["linear"],["zoom"],3,0.2,8,1.0,12,2.6,15,6.2],"line-opacity":0.95}},' +
      '{"id":"building","type":"fill","source":"osm","source-layer":"building","minzoom":11,"paint":{"fill-color":"#d7d0c4","fill-outline-color":"#c1b9ad","fill-opacity":0.85}},' +
      '{"id":"place-dots","type":"circle","source":"osm","source-layer":"place","paint":{"circle-color":"#3f4d63","circle-radius":["interpolate",["linear"],["zoom"],3,1.2,8,2.4,12,3.4],"circle-opacity":0.8}},' +
      '{"id":"poi-dots","type":"circle","source":"osm","source-layer":"poi","minzoom":10,"paint":{"circle-color":"#8b5a2b","circle-radius":1.8,"circle-opacity":0.65}},' +
      '{"id":"place-labels","type":"symbol","source":"osm","source-layer":"place","layout":{"text-field":["coalesce",["get","name:es"],["get","name"],["get","name_en"]],"text-font":["Noto Sans Regular"],"text-size":["interpolate",["linear"],["zoom"],4,10,8,12,12,14],"text-variable-anchor":["center","top","bottom","left","right"],"text-radial-offset":0.5,"text-justify":"auto"},"paint":{"text-color":"#263248","text-halo-color":"#f6f8fb","text-halo-width":1.2}},' +
      '{"id":"transportation-labels","type":"symbol","source":"osm","source-layer":"transportation_name","minzoom":10,"layout":{"symbol-placement":"line","text-field":["coalesce",["get","name:es"],["get","name"],["get","name_en"]],"text-font":["Noto Sans Regular"],"text-size":10,"text-letter-spacing":0.02},"paint":{"text-color":"#51607a","text-halo-color":"#ffffff","text-halo-width":1}}' +
    ']'+
    '}';

  cDefaultVectorStyleTemplateNoGlyphs =
    '{' +
    '"version":8,' +
    '"name":"OSMLib Local Vector Runtime",' +
    '"sources":{"osm":{"type":"vector","tiles":["{{VECTOR_TILE_URL}}"],"minzoom":0,"maxzoom":14}},' +
    '"layers":[' +
      '{"id":"background","type":"background","paint":{"background-color":"#eef2f6"}},' +
      '{"id":"landcover","type":"fill","source":"osm","source-layer":"landcover","paint":{"fill-color":"#dce9d1","fill-opacity":0.7}},' +
      '{"id":"landuse","type":"fill","source":"osm","source-layer":"landuse","paint":{"fill-color":"#e8eddc","fill-opacity":0.45}},' +
      '{"id":"park","type":"fill","source":"osm","source-layer":"park","paint":{"fill-color":"#d9ead3","fill-opacity":0.8}},' +
      '{"id":"water","type":"fill","source":"osm","source-layer":"water","paint":{"fill-color":"#9ec9ff","fill-opacity":0.95}},' +
      '{"id":"waterway","type":"line","source":"osm","source-layer":"waterway","paint":{"line-color":"#7eb6f5","line-width":["interpolate",["linear"],["zoom"],6,0.4,10,1.1,14,2.2]}},' +
      '{"id":"boundary","type":"line","source":"osm","source-layer":"boundary","paint":{"line-color":"#8f98a6","line-width":["interpolate",["linear"],["zoom"],3,0.3,8,0.8,14,1.4],"line-dasharray":[2,2]}},' +
      '{"id":"transportation-casing","type":"line","source":"osm","source-layer":"transportation","paint":{"line-color":"#c8c2b8","line-width":["interpolate",["linear"],["zoom"],3,0.4,8,1.6,12,3.8,15,8.5],"line-opacity":0.85}},' +
      '{"id":"transportation-fill","type":"line","source":"osm","source-layer":"transportation","paint":{"line-color":"#ffffff","line-width":["interpolate",["linear"],["zoom"],3,0.2,8,1.0,12,2.6,15,6.2],"line-opacity":0.95}},' +
      '{"id":"building","type":"fill","source":"osm","source-layer":"building","minzoom":11,"paint":{"fill-color":"#d7d0c4","fill-outline-color":"#c1b9ad","fill-opacity":0.85}},' +
      '{"id":"place-dots","type":"circle","source":"osm","source-layer":"place","paint":{"circle-color":"#3f4d63","circle-radius":["interpolate",["linear"],["zoom"],3,1.2,8,2.4,12,3.4],"circle-opacity":0.8}},' +
      '{"id":"poi-dots","type":"circle","source":"osm","source-layer":"poi","minzoom":10,"paint":{"circle-color":"#8b5a2b","circle-radius":1.8,"circle-opacity":0.65}}' +
    ']'+
    '}';

procedure AppendVectorRuntimeTrace(const AMessage: string);
{$IFDEF FPC}
var
  logLines: TStringList;
  logFileName: string;
begin
  try
    logFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'gmlib_lcl_hybrid_trace.log';
    logLines := TStringList.Create;
    try
      if FileExists(logFileName) then
        logLines.LoadFromFile(logFileName);
      logLines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' [VectorRuntime] ' + AMessage);
      logLines.SaveToFile(logFileName);
    finally
      logLines.Free;
    end;
  except
    // Logging must never break the runtime.
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

{$IFDEF FPC}
function TryReadRuntimeHealth(const AUrl: string; out AResponseText, AErrorText: string): Boolean;
var
  httpClient: TFPHTTPClient;
  responseStream: TStringStream;
begin
  Result := False;
  AResponseText := '';
  AErrorText := '';
  httpClient := TFPHTTPClient.Create(nil);
  responseStream := TStringStream.Create('');
  try
    httpClient.ConnectTimeout := 2000;
    httpClient.IOTimeout := 2000;
    try
      httpClient.Get(AUrl, responseStream);
      AResponseText := responseStream.DataString;
      Result := httpClient.ResponseStatusCode = 200;
      if not Result then
        AErrorText := Format('status=%d body=%s', [httpClient.ResponseStatusCode, AResponseText]);
    except
      on E: Exception do
        AErrorText := E.Message;
    end;
  finally
    responseStream.Free;
    httpClient.Free;
  end;
end;
{$ENDIF}

{ TMapLibVectorRuntime }

function ParseRequestInteger(AParams: TStrings; const AName: string;
  out AValue: Integer): Boolean;
begin
  Result := Assigned(AParams) and TryStrToInt(Trim(AParams.Values[AName]), AValue);
end;

function DecodeUrlComponent(const AValue: string): string;
{$IFDEF FPC}
var
  index: Integer;
  hexValue: string;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := '';
  index := 1;
  while index <= Length(AValue) do
  begin
    case AValue[index] of
      '+':
        Result := Result + ' ';
      '%':
        begin
          if index + 2 <= Length(AValue) then
          begin
            hexValue := '$' + Copy(AValue, index + 1, 2);
            Result := Result + Chr(StrToIntDef(hexValue, Ord('?')));
            Inc(index, 2);
          end
          else
            Result := Result + AValue[index];
        end;
    else
      Result := Result + AValue[index];
    end;
    Inc(index);
  end;
{$ELSE}
  Result := TIdURI.URLDecode(AValue);
{$ENDIF}
end;

function CombinePath(const ABasePath, AChild: string): string;
begin
{$IFDEF FPC}
  Result := IncludeTrailingPathDelimiter(ABasePath) + AChild;
{$ELSE}
  Result := TPath.Combine(ABasePath, AChild);
{$ENDIF}
end;

function ReadAllBytesFromFile(const AFileName: string): TBytes;
{$IFDEF FPC}
var
  stream: TFileStream;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := nil;
  stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, stream.Size);
    if Length(Result) > 0 then
      stream.ReadBuffer(Result[0], Length(Result));
  finally
    stream.Free;
  end;
{$ELSE}
  Result := TFile.ReadAllBytes(AFileName);
{$ENDIF}
end;

function BuildJsonError(const AMessage: string): string;
begin
  Result := '{"error":"' + StringReplace(AMessage, '"', '\"', [rfReplaceAll]) + '"}';
end;

function TMapLibVectorRuntime.BuildStyleJson: string;
var
  effectiveSourceId: string;
  tileUrlTemplate: string;
  glyphsUrlTemplate: string;
begin
  effectiveSourceId := FSourceId;
  if effectiveSourceId = '' then
    effectiveSourceId := 'osm';

  if Assigned(FStyleProvider) then
  begin
    if (Trim(FStyleProvider.TemplateJson) = '') and
      (Trim(FStyleTemplateFileName) = '') then
    begin
      // When no glyph corpus is configured we still want a functional offline
      // style on mobile, even if that means rendering without text labels.
      if Trim(FGlyphsRootPath) <> '' then
        FStyleProvider.TemplateJson := cDefaultVectorStyleTemplate
      else
        FStyleProvider.TemplateJson := cDefaultVectorStyleTemplateNoGlyphs;
    end;
    if Trim(FStyleTemplateFileName) <> '' then
      FStyleProvider.TemplateJson := '';
    FStyleProvider.TemplateFileName := FStyleTemplateFileName;
    tileUrlTemplate := BuildTileUrlTemplate(effectiveSourceId);
    glyphsUrlTemplate := BuildGlyphsUrlTemplate;
    FStyleProvider.TileUrlTemplate := tileUrlTemplate;
    FStyleProvider.GlyphsUrlTemplate := glyphsUrlTemplate;
    Result := FStyleProvider.BuildStyleJson;
    AppendVectorRuntimeTrace(
      'BuildStyleJson sourceId=' + effectiveSourceId +
      ' tileUrl=' + tileUrlTemplate +
      ' glyphsUrl=' + glyphsUrlTemplate +
      ' styleLength=' + IntToStr(Length(Result))
    );
  end
  else
    Result := '';
end;

function TMapLibVectorRuntime.BuildTileUrlTemplate(const ASourceId: string): string;
var
  effectiveSourceId: string;
begin
  effectiveSourceId := ASourceId;
  if effectiveSourceId = '' then
    effectiveSourceId := FSourceId;
  if effectiveSourceId = '' then
    effectiveSourceId := 'osm';
  Result := FLocalHttpServer.BuildRuntimeUrl(Format(
    'tile?source=%s&z={z}&x={x}&y={y}', [effectiveSourceId]));
end;

procedure TMapLibVectorRuntime.ConfigureTileStore;
var
  databaseFileName: string;
  preferredRegionFileName: string;
begin
  databaseFileName := ResolveTileStoreDatabaseFileName;
  preferredRegionFileName := Trim(FActiveRegionFileName);

  if databaseFileName = '' then
  begin
    FCacheTileStore := nil;
    FTileStoreDatabaseFileName := '';
  end;
  if (databaseFileName <> '') and
    ((FCacheTileStore = nil) or not SameText(FTileStoreDatabaseFileName, databaseFileName)) then
  begin
    try
      FCacheTileStore := TMapLibSqliteTileStore.Create(databaseFileName);
      FTileStoreDatabaseFileName := databaseFileName;
    except
      on E: Exception do
      begin
        // On some mobile deployments the native SQLite library may be missing.
        // The runtime must keep working without persistent cache instead of
        // failing the whole map activation path.
        FCacheTileStore := nil;
        FTileStoreDatabaseFileName := '';
      end;
    end;
  end;

  if Trim(FOfflineStoragePath) = '' then
  begin
    FRegionTileStore := nil;
    FRegionTileStoreFileName := '';
  end
  else if (FRegionTileStore = nil) or
    not SameText(FRegionTileStoreFileName,
      FOfflineStoragePath + '|' + preferredRegionFileName) then
  begin
    try
      FRegionTileStore := TMapLibOfflineRegionTileStore.Create(
        FOfflineStoragePath,
        preferredRegionFileName
      );
      FRegionTileStoreFileName := FOfflineStoragePath + '|' + preferredRegionFileName;
    except
      on E: Exception do
      begin
        FRegionTileStore := nil;
        FRegionTileStoreFileName := '';
      end;
    end;
  end;

  if Assigned(FRegionTileStore) and Assigned(FCacheTileStore) then
    FTileStore := TMapLibCompositeTileStore.Create(FRegionTileStore, FCacheTileStore, FCacheTileStore)
  else if Assigned(FRegionTileStore) then
    FTileStore := FRegionTileStore
  else
    FTileStore := FCacheTileStore;

  FTileResolver.TileStore := FTileStore;
end;

function TMapLibVectorRuntime.ResolveTileStoreDatabaseFileName: string;
{$IFDEF FPC}
var
  storagePath: string;
begin
  storagePath := Trim(FOfflineStoragePath);
  if storagePath = '' then
    storagePath := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) + 'GMLib' + PathDelim + 'OSM';

  Result := IncludeTrailingPathDelimiter(storagePath) + 'vector-runtime-cache.sqlite3';
end;
{$ELSE}
var
  storagePath: string;
begin
  storagePath := Trim(FOfflineStoragePath);
  if storagePath = '' then
    storagePath := TPath.Combine(TPath.Combine(TPath.GetDocumentsPath, 'GMLib'), 'OSM');

  Result := TPath.Combine(storagePath, 'vector-runtime-cache.sqlite3');
end;
{$ENDIF}

constructor TMapLibVectorRuntime.Create;
begin
  inherited Create;
  FSourceId := 'osm';
  FMapMode := omOnline;
  FOfflinePolicy := opPreferOffline;
  FOfflineStoragePath := '';
  FActiveRegionFileName := '';
  FStyleTemplateFileName := '';
  FGlyphsRootPath := '';
  FLocalHttpServer := TMapLibLocalHttpServer.Create(0);
  FTileResolver := TMapLibTileResolver.Create;
  FStyleProvider := TMapLibStyleProvider.Create;
  FRemoteTileProvider := TMapLibHttpRemoteTileProvider.Create;
  FTileResolver.RemoteTileProvider := FRemoteTileProvider;
{$IFDEF FPC}
  FLocalHttpServer.OnCommand := @HandleServerCommand;
{$ELSE}
  FLocalHttpServer.OnCommand := HandleServerCommand;
{$ENDIF}
end;

destructor TMapLibVectorRuntime.Destroy;
begin
  Stop;
  if Assigned(FTileResolver) then
  begin
    FTileResolver.RemoteTileProvider := nil;
    FTileResolver.TileStore := nil;
  end;
  FRegionTileStore := nil;
  FCacheTileStore := nil;
  FTileStore := nil;
  FRemoteTileProvider.Free;
  FStyleProvider.Free;
  FTileResolver.Free;
  FLocalHttpServer.Free;
  inherited Destroy;
end;

function TMapLibVectorRuntime.GetBaseUrl: string;
begin
  Result := FLocalHttpServer.GetBaseUrl;
end;

function TMapLibVectorRuntime.BuildGlyphsUrlTemplate: string;
begin
  Result := FLocalHttpServer.BuildRuntimeUrl('glyphs/{fontstack}/{range}.pbf');
end;

function TMapLibVectorRuntime.DetectContentEncoding(const AData: TBytes): string;
begin
  Result := '';
  if (Length(AData) >= 2) and (AData[0] = $1F) and (AData[1] = $8B) then
    Result := 'gzip';
end;

procedure TMapLibVectorRuntime.HandleServerCommand(Sender: TObject;
  ARequest: TMapLibHttpRequestData; AResponse: TMapLibHttpResponseData;
  var AHandled: Boolean);
var
  clientLogMessage: string;
  tileData: TBytes;
  contentType: string;
  contentEncoding: string;
  resolveStatus: TMapLibTileResolveStatus;
  tileSource: string;
  tileZ: Integer;
  tileX: Integer;
  tileY: Integer;
begin
  AppendVectorRuntimeTrace('HandleServerCommand document=' + ARequest.Document);
  if TryServeGlyphRequest(ARequest, AResponse) then
  begin
    AppendVectorRuntimeTrace('Glyph request served');
    AHandled := True;
    Exit;
  end;

  if TryServeAssetRequest(ARequest, AResponse) then
  begin
    AppendVectorRuntimeTrace('Asset request served');
    AHandled := True;
    Exit;
  end;

  if SameText(ARequest.Document, '/clientlog') then
  begin
    AHandled := True;
    clientLogMessage := Trim(ARequest.Params.Values['msg']);
    AppendVectorRuntimeTrace('ClientLog ' + clientLogMessage);
    AResponse.StatusCode := 204;
    Exit;
  end;

  if SameText(ARequest.Document, '/bootstrap') then
  begin
    AHandled := True;
    if Trim(FBootstrapHtml) = '' then
    begin
      AResponse.StatusCode := 404;
      AResponse.ContentType := 'application/json; charset=utf-8';
      AResponse.ContentText := BuildJsonError('Bootstrap HTML is not configured.');
    end
    else
    begin
      AResponse.StatusCode := 200;
      AResponse.ContentType := 'text/html; charset=utf-8';
      AResponse.ContentText := FBootstrapHtml;
    end;
    Exit;
  end;

  if not SameText(ARequest.Document, '/tile') then
    Exit;

  AHandled := True;

  if not ParseRequestInteger(ARequest.Params, 'z', tileZ) or
     not ParseRequestInteger(ARequest.Params, 'x', tileX) or
     not ParseRequestInteger(ARequest.Params, 'y', tileY) then
  begin
    AppendVectorRuntimeTrace('Invalid tile coordinates');
    AResponse.StatusCode := 400;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.ContentText := BuildJsonError('Invalid tile coordinates.');
    Exit;
  end;

  tileSource := Trim(ARequest.Params.Values['source']);
  if tileSource = '' then
    tileSource := FSourceId;
  AppendVectorRuntimeTrace(Format('Tile request source=%s z=%d x=%d y=%d mode=%d policy=%d variant=%s',
    [tileSource, tileZ, tileX, tileY, Ord(FMapMode), Ord(FOfflinePolicy),
     FRemoteTileProvider.TileUrlTemplate]));

  FTileResolver.MapMode := FMapMode;
  FTileResolver.OfflinePolicy := FOfflinePolicy;
  FTileResolver.SourceVariant := FRemoteTileProvider.TileUrlTemplate;
  resolveStatus := FTileResolver.ResolveTile(tileSource, tileZ, tileX, tileY,
    tileData, contentType, contentEncoding);
  AppendVectorRuntimeTrace(Format('Resolve status=%d bytes=%d contentType=%s contentEncoding=%s',
    [Ord(resolveStatus), Length(tileData), contentType, contentEncoding]));

  case resolveStatus of
    trsLocal, trsRemote:
      begin
        AResponse.StatusCode := 200;
        if contentType <> '' then
          AResponse.ContentType := contentType
        else
          AResponse.ContentType := 'application/x-protobuf';
        if contentEncoding <> '' then
          AResponse.Headers.Values['Content-Encoding'] := contentEncoding;
        AResponse.ContentStream := TBytesStream.Create(tileData);
        AResponse.FreeContentStream := True;
      end;
    trsBlocked:
      begin
        AResponse.StatusCode := 404;
        AResponse.ContentType := 'application/json; charset=utf-8';
        AResponse.ContentText := BuildJsonError('Tile is unavailable in offline mode.');
      end;
  else
    begin
      AResponse.StatusCode := 404;
      AResponse.ContentType := 'application/json; charset=utf-8';
      AResponse.ContentText := BuildJsonError('Tile not found.');
    end;
  end;
end;

function TMapLibVectorRuntime.TryServeGlyphRequest(
  ARequest: TMapLibHttpRequestData; AResponse: TMapLibHttpResponseData): Boolean;
var
  documentPath: string;
  glyphRelativePath: string;
  pathParts: TStringList;
  fileName: string;
  fontStack: string;
  glyphFileName: string;
  glyphFilePath: string;
  glyphData: TBytes;
  contentEncoding: string;
begin
  Result := False;

  documentPath := Trim(ARequest.Document);
  if not StartsText('/glyphs/', documentPath) then
    Exit;

  Result := True;
  if Trim(FGlyphsRootPath) = '' then
  begin
    AResponse.StatusCode := 404;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.ContentText := BuildJsonError('Glyphs root path is not configured.');
    Exit;
  end;

  glyphRelativePath := Copy(documentPath, Length('/glyphs/') + 1, MaxInt);
  pathParts := TStringList.Create;
  try
    pathParts.StrictDelimiter := True;
    pathParts.Delimiter := '/';
    pathParts.DelimitedText := glyphRelativePath;
    if pathParts.Count <> 2 then
    begin
      AResponse.StatusCode := 400;
      AResponse.ContentType := 'application/json; charset=utf-8';
      AResponse.ContentText := BuildJsonError('Invalid glyph request.');
      Exit;
    end;

    fontStack := DecodeUrlComponent(pathParts[0]);
    fileName := DecodeUrlComponent(pathParts[1]);
  finally
    pathParts.Free;
  end;

  glyphFileName := ExtractFileName(fileName);
  glyphFilePath := CombinePath(CombinePath(FGlyphsRootPath, fontStack), glyphFileName);

  if not FileExists(glyphFilePath) then
  begin
    AResponse.StatusCode := 404;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.ContentText := BuildJsonError('Glyph file not found.');
    Exit;
  end;

  glyphData := ReadAllBytesFromFile(glyphFilePath);
  contentEncoding := DetectContentEncoding(glyphData);
  AResponse.StatusCode := 200;
  AResponse.ContentType := 'application/x-protobuf';
  if contentEncoding <> '' then
    AResponse.Headers.Values['Content-Encoding'] := contentEncoding;
  AResponse.ContentStream := TBytesStream.Create(glyphData);
  AResponse.FreeContentStream := True;
end;

function TMapLibVectorRuntime.TryServeAssetRequest(
  ARequest: TMapLibHttpRequestData; AResponse: TMapLibHttpResponseData): Boolean;
var
  assetRelativePath: string;
  assetFileName: string;
  assetFilePath: string;
  assetData: TBytes;
  assetText: string;
{$IFDEF FPC}
  assetLines: TStringList;
{$ENDIF}
begin
  Result := False;

  if not StartsText('/asset/', Trim(ARequest.Document)) then
    Exit;

  Result := True;
  if Trim(FGlyphsRootPath) = '' then
  begin
    AppendVectorRuntimeTrace('Asset request rejected: GlyphsRootPath is empty');
    AResponse.StatusCode := 404;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.ContentText := BuildJsonError('Asset root path is not configured.');
    Exit;
  end;

  assetRelativePath := Copy(Trim(ARequest.Document), Length('/asset/') + 1, MaxInt);
  assetFileName := ExtractFileName(DecodeUrlComponent(assetRelativePath));
  AppendVectorRuntimeTrace('Asset request relativePath=' + assetRelativePath +
    ' fileName=' + assetFileName + ' root=' + FGlyphsRootPath);
  if assetFileName = '' then
  begin
    AppendVectorRuntimeTrace('Asset request rejected: empty asset file name');
    AResponse.StatusCode := 400;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.ContentText := BuildJsonError('Invalid asset request.');
    Exit;
  end;

  assetFilePath := CombinePath(FGlyphsRootPath, assetFileName);

  if SameText(assetFileName, 'probe.js') then
  begin
    assetText :=
      '(function(){' +
      'try{' +
      'var base=String(window.__osmlibRuntimeBaseUrl||"");' +
      'if(base){(new Image()).src=base+"clientlog?msg="+encodeURIComponent("probe loaded");}' +
      '}catch(e){}' +
      'window.__osmlibProbeLoaded=true;' +
      '})();';
    AppendVectorRuntimeTrace('Asset request serving probe.js chars=' + IntToStr(Length(assetText)));
    AResponse.StatusCode := 200;
    AResponse.ContentType := 'text/javascript; charset=utf-8';
    AResponse.ContentText := assetText;
    Exit;
  end;

  if not FileExists(assetFilePath) then
  begin
    AppendVectorRuntimeTrace('Asset request file not found path=' + assetFilePath);
    AResponse.StatusCode := 404;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.ContentText := BuildJsonError('Asset file not found.');
    Exit;
  end;

  if SameText(assetFileName, 'osmlib.map.js') or
     SameText(assetFileName, 'maplibre-gl.js') then
  begin
    AppendVectorRuntimeTrace('Asset request entering JS text path=' + assetFilePath);
    try
{$IFDEF FPC}
      assetLines := TStringList.Create;
      try
        assetLines.LoadFromFile(assetFilePath);
        assetText := assetLines.Text;
      finally
        assetLines.Free;
      end;
{$ELSE}
      assetText := TFile.ReadAllText(assetFilePath, TEncoding.UTF8);
{$ENDIF}
      AppendVectorRuntimeTrace(Format(
        'Asset request serving JS text path=%s chars=%d',
        [assetFilePath, Length(assetText)]));
      AResponse.StatusCode := 200;
      AResponse.ContentType := 'text/javascript; charset=utf-8';
      AResponse.ContentText := assetText;
      AppendVectorRuntimeTrace('Asset request JS text response prepared for ' + assetFileName);
      Exit;
    except
      on E: Exception do
      begin
        AppendVectorRuntimeTrace('Asset request JS text exception: ' + E.Message);
        AResponse.StatusCode := 500;
        AResponse.ContentType := 'application/json; charset=utf-8';
        AResponse.ContentText := BuildJsonError('Asset JS text error: ' + E.Message);
        Exit;
      end;
    end;
  end;

  assetData := ReadAllBytesFromFile(assetFilePath);
  AppendVectorRuntimeTrace(Format('Asset request serving path=%s bytes=%d',
    [assetFilePath, Length(assetData)]));
  AResponse.StatusCode := 200;
  if SameText(ExtractFileExt(assetFileName), '.js') then
    AResponse.ContentType := 'application/javascript; charset=utf-8'
  else if SameText(ExtractFileExt(assetFileName), '.css') then
    AResponse.ContentType := 'text/css; charset=utf-8'
  else
    AResponse.ContentType := 'application/octet-stream';
  AResponse.ContentStream := TBytesStream.Create(assetData);
  AResponse.FreeContentStream := True;
end;

function TMapLibVectorRuntime.Start: Boolean;
{$IFDEF FPC}
var
  healthText: string;
  healthError: string;
{$ENDIF}
begin
  AppendVectorRuntimeTrace(Format(
    'Start mapMode=%d policy=%d storage=%s activeRegion=%s styleTemplate=%s glyphs=%s remoteTemplate=%s',
    [Ord(FMapMode), Ord(FOfflinePolicy), FOfflineStoragePath, FActiveRegionFileName,
     FStyleTemplateFileName, FGlyphsRootPath, FRemoteTileProvider.TileUrlTemplate]));
  ConfigureTileStore;
  AppendVectorRuntimeTrace('Start after ConfigureTileStore');
  Result := FLocalHttpServer.Start;
  AppendVectorRuntimeTrace('Start result=' + BoolToStr(Result, True) +
    ' baseUrl=' + FLocalHttpServer.GetBaseUrl + ' lastError=' + FLocalHttpServer.GetLastError);
{$IFDEF FPC}
  if Result then
  begin
    if TryReadRuntimeHealth(FLocalHttpServer.BuildRuntimeUrl('health'), healthText, healthError) then
      AppendVectorRuntimeTrace('Health check ok body=' + healthText)
    else
      AppendVectorRuntimeTrace('Health check failed error=' + healthError);
  end;
{$ENDIF}
end;

procedure TMapLibVectorRuntime.Stop;
begin
  FLocalHttpServer.Stop;
end;

function TMapLibVectorRuntime.BuildBootstrapUrl: string;
begin
  Result := FLocalHttpServer.BuildRuntimeUrl('bootstrap');
end;

end.
