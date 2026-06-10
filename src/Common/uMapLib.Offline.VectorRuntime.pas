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
    FSourceId: string;
    FMapMode: TMapLibMapMode;
    FOfflinePolicy: TMapLibOfflinePolicy;
    FOfflineStoragePath: string;
    FStyleTemplateFileName: string;
    FGlyphsRootPath: string;
    FTileStore: IMapLibTileStore;
    FTileStoreDatabaseFileName: string;
    FLocalHttpServer: TMapLibLocalHttpServer;
    FStyleProvider: TMapLibStyleProvider;
    FTileResolver: TMapLibTileResolver;
    FRemoteTileProvider: TMapLibHttpRemoteTileProvider;
    procedure ConfigureTileStore;
    function ResolveTileStoreDatabaseFileName: string;
    function BuildGlyphsUrlTemplate: string;
    function DetectContentEncoding(const AData: TBytes): string;
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

    property SourceId: string read FSourceId write FSourceId;
    property MapMode: TMapLibMapMode read FMapMode write FMapMode;
    property OfflinePolicy: TMapLibOfflinePolicy read FOfflinePolicy write FOfflinePolicy;
    property OfflineStoragePath: string read FOfflineStoragePath write FOfflineStoragePath;
    property StyleTemplateFileName: string read FStyleTemplateFileName write FStyleTemplateFileName;
    property GlyphsRootPath: string read FGlyphsRootPath write FGlyphsRootPath;
    property LocalHttpServer: TMapLibLocalHttpServer read FLocalHttpServer;
    property RemoteTileProvider: TMapLibHttpRemoteTileProvider read FRemoteTileProvider;
    property StyleProvider: TMapLibStyleProvider read FStyleProvider write FStyleProvider;
    property TileResolver: TMapLibTileResolver read FTileResolver;
  end;

implementation

{$IFDEF FPC}
uses
  uMapLib.Offline.SqliteTileStore;
{$ELSE}
uses
  uMapLib.Offline.SqliteTileStore;
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
begin
  effectiveSourceId := FSourceId;
  if effectiveSourceId = '' then
    effectiveSourceId := 'osm';

  if Assigned(FStyleProvider) then
  begin
    if (Trim(FStyleProvider.TemplateJson) = '') and
      (Trim(FStyleTemplateFileName) = '') then
      FStyleProvider.TemplateJson := cDefaultVectorStyleTemplate;
    if Trim(FStyleTemplateFileName) <> '' then
      FStyleProvider.TemplateJson := '';
    FStyleProvider.TemplateFileName := FStyleTemplateFileName;
    FStyleProvider.TileUrlTemplate := BuildTileUrlTemplate(effectiveSourceId);
    FStyleProvider.GlyphsUrlTemplate := BuildGlyphsUrlTemplate;
    Result := FStyleProvider.BuildStyleJson;
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
begin
  databaseFileName := ResolveTileStoreDatabaseFileName;
  if databaseFileName = '' then
  begin
    FTileStore := nil;
    FTileStoreDatabaseFileName := '';
    FTileResolver.TileStore := nil;
    Exit;
  end;

  if (FTileStore <> nil) and SameText(FTileStoreDatabaseFileName, databaseFileName) then
  begin
    FTileResolver.TileStore := FTileStore;
    Exit;
  end;

  FTileStore := TMapLibSqliteTileStore.Create(databaseFileName);
  FTileStoreDatabaseFileName := databaseFileName;
  FTileResolver.TileStore := FTileStore;
end;

function TMapLibVectorRuntime.ResolveTileStoreDatabaseFileName: string;
{$IFDEF FPC}
var
  storagePath: string;
begin
  storagePath := Trim(FOfflineStoragePath);
  if storagePath = '' then
    storagePath := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'GMLib' + PathDelim + 'OSM';

  Result := IncludeTrailingPathDelimiter(storagePath) + 'vector-runtime-cache.sqlite3';
end;
{$ELSE}
var
  storagePath: string;
begin
  storagePath := Trim(FOfflineStoragePath);
  if storagePath = '' then
    storagePath := TPath.Combine(TPath.GetTempPath, 'GMLib\OSM');

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
  tileData: TBytes;
  contentType: string;
  contentEncoding: string;
  resolveStatus: TMapLibTileResolveStatus;
  tileSource: string;
  tileZ: Integer;
  tileX: Integer;
  tileY: Integer;
begin
  if TryServeGlyphRequest(ARequest, AResponse) then
  begin
    AHandled := True;
    Exit;
  end;

  if not SameText(ARequest.Document, '/tile') then
    Exit;

  AHandled := True;

  if not ParseRequestInteger(ARequest.Params, 'z', tileZ) or
     not ParseRequestInteger(ARequest.Params, 'x', tileX) or
     not ParseRequestInteger(ARequest.Params, 'y', tileY) then
  begin
    AResponse.StatusCode := 400;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.ContentText := BuildJsonError('Invalid tile coordinates.');
    Exit;
  end;

  tileSource := Trim(ARequest.Params.Values['source']);
  if tileSource = '' then
    tileSource := FSourceId;

  FTileResolver.MapMode := FMapMode;
  FTileResolver.OfflinePolicy := FOfflinePolicy;
  FTileResolver.SourceVariant := FRemoteTileProvider.TileUrlTemplate;
  resolveStatus := FTileResolver.ResolveTile(tileSource, tileZ, tileX, tileY,
    tileData, contentType, contentEncoding);

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

function TMapLibVectorRuntime.Start: Boolean;
begin
  ConfigureTileStore;
  Result := FLocalHttpServer.Start;
end;

procedure TMapLibVectorRuntime.Stop;
begin
  FLocalHttpServer.Stop;
end;

end.
