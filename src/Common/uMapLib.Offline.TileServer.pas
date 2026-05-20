{**
  @abstract(Servidor HTTP local embebido para assets offline de mapa.)
}
unit uMapLib.Offline.TileServer;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils,
{$ELSE}
  System.Classes, System.SysUtils,
  IdContext, IdCustomHTTPServer, IdHTTPServer,
{$ENDIF}
  uMapLib.Core.Offline;

type
  TMapLibOfflineTileServer = class(TInterfacedObject, IMapLibOfflineTileServer)
  private
    FRootPath: string;
    FPort: Integer;
    FToken: string;
    FBaseUrl: string;
    FLastError: string;
{$IFNDEF FPC}
    FServer: TIdHTTPServer;
    function TryParseRangeHeader(const ARangeHeader: string; AFileSize: Int64;
      out AStartPos, AEndPos: Int64): Boolean;
    procedure ApplyCorsHeaders(AResponseInfo: TIdHTTPResponseInfo);
    procedure ServeFile(const ALocalFileName: string; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo; AHeadOnly: Boolean);
    procedure HandleCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleCommandOther(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
{$ENDIF}
    function BuildContentType(const AFileName: string): string;
    function NormalizeDocumentPath(const ADocument: string): string;
    function TryBuildLocalFileName(const ARelativePath: string; out ALocalFileName: string): Boolean;
  public
    constructor Create(const ARootPath: string; APort: Integer = 0; const AToken: string = '');
    destructor Destroy; override;
    function Start: Boolean;
    procedure Stop;
    function IsRunning: Boolean;
    function GetBaseUrl: string;
    function GetLastError: string;
  end;

implementation

uses
  uMapLib.Core.Types,
  System.Math;

function BuildToken: string;
begin
{$IFDEF FPC}
  Result := IntToHex(Random(MaxInt), 8) + IntToHex(Random(MaxInt), 8);
{$ELSE}
  Result := StringReplace(TGUID.NewGuid.ToString, '-', '', [rfReplaceAll]);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
{$ENDIF}
end;

{ TMapLibOfflineTileServer }

{$IFNDEF FPC}
function TMapLibOfflineTileServer.TryParseRangeHeader(const ARangeHeader: string;
  AFileSize: Int64; out AStartPos, AEndPos: Int64): Boolean;
var
  headerValue: string;
  dashPos: Integer;
  startPart: string;
  endPart: string;
  suffixLen: Int64;
begin
  Result := False;
  AStartPos := 0;
  AEndPos := AFileSize - 1;
  headerValue := Trim(ARangeHeader);
  if (headerValue = '') or (AFileSize <= 0) then
    Exit;
  if not SameText(Copy(headerValue, 1, 6), 'bytes=') then
    Exit;

  headerValue := Trim(Copy(headerValue, 7, MaxInt));
  if Pos(',', headerValue) > 0 then
    Exit;

  dashPos := Pos('-', headerValue);
  if dashPos <= 0 then
    Exit;

  startPart := Trim(Copy(headerValue, 1, dashPos - 1));
  endPart := Trim(Copy(headerValue, dashPos + 1, MaxInt));

  if startPart = '' then
  begin
    if not TryStrToInt64(endPart, suffixLen) then
      Exit;
    if suffixLen <= 0 then
      Exit;
    suffixLen := Min(suffixLen, AFileSize);
    AStartPos := AFileSize - suffixLen;
    AEndPos := AFileSize - 1;
    Result := True;
    Exit;
  end;

  if not TryStrToInt64(startPart, AStartPos) then
    Exit;
  if (AStartPos < 0) or (AStartPos >= AFileSize) then
    Exit;

  if endPart = '' then
    AEndPos := AFileSize - 1
  else
  begin
    if not TryStrToInt64(endPart, AEndPos) then
      Exit;
    if AEndPos < AStartPos then
      Exit;
    if AEndPos >= AFileSize then
      AEndPos := AFileSize - 1;
  end;

  Result := True;
end;

procedure TMapLibOfflineTileServer.ApplyCorsHeaders(
  AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Origin'] := '*';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Methods'] := 'GET, HEAD, OPTIONS';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Headers'] := '*';
  AResponseInfo.CustomHeaders.Values['Access-Control-Expose-Headers'] :=
    'Accept-Ranges, Content-Range, Content-Length';
  AResponseInfo.CustomHeaders.Values['Access-Control-Max-Age'] := '86400';
end;

procedure TMapLibOfflineTileServer.ServeFile(const ALocalFileName: string;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo;
  AHeadOnly: Boolean);
var
  fileStream: TFileStream;
  fileSize: Int64;
  rangeHeader: string;
  startPos: Int64;
  endPos: Int64;
  rangeSize: Int64;
  partialStream: TMemoryStream;
begin
  fileStream := TFileStream.Create(ALocalFileName, fmOpenRead or fmShareDenyNone);
  try
    fileSize := fileStream.Size;
    AResponseInfo.ContentType := BuildContentType(ALocalFileName);
    AResponseInfo.CustomHeaders.Values['Accept-Ranges'] := 'bytes';

    rangeHeader := Trim(ARequestInfo.RawHeaders.Values['Range']);
    if TryParseRangeHeader(rangeHeader, fileSize, startPos, endPos) then
    begin
      rangeSize := (endPos - startPos) + 1;
      AResponseInfo.ResponseNo := 206;
      AResponseInfo.CustomHeaders.Values['Content-Range'] :=
        Format('bytes %d-%d/%d', [startPos, endPos, fileSize]);
      AResponseInfo.ContentLength := rangeSize;
      if AHeadOnly then
        Exit;

      partialStream := TMemoryStream.Create;
      try
        fileStream.Position := startPos;
        partialStream.CopyFrom(fileStream, rangeSize);
        partialStream.Position := 0;
        AResponseInfo.ContentStream := partialStream;
        AResponseInfo.FreeContentStream := True;
      except
        partialStream.Free;
        raise;
      end;
      Exit;
    end;

    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentLength := fileSize;
    if AHeadOnly then
      Exit;

    AResponseInfo.ContentStream := fileStream;
    AResponseInfo.FreeContentStream := True;
    fileStream := nil;
  finally
    fileStream.Free;
  end;
end;
{$ENDIF}

function TMapLibOfflineTileServer.BuildContentType(const AFileName: string): string;
var
  ext: string;
begin
  ext := LowerCase(ExtractFileExt(AFileName));
  if ext = '.json' then
    Result := 'application/json; charset=utf-8'
  else if ext = '.js' then
    Result := 'application/javascript; charset=utf-8'
  else if ext = '.css' then
    Result := 'text/css; charset=utf-8'
  else if ext = '.png' then
    Result := 'image/png'
  else if ext = '.jpg' then
    Result := 'image/jpeg'
  else if ext = '.jpeg' then
    Result := 'image/jpeg'
  else if ext = '.svg' then
    Result := 'image/svg+xml'
  else if ext = '.pbf' then
    Result := 'application/x-protobuf'
  else if ext = '.mvt' then
    Result := 'application/vnd.mapbox-vector-tile'
  else
    Result := 'application/octet-stream';
end;

constructor TMapLibOfflineTileServer.Create(const ARootPath: string; APort: Integer;
  const AToken: string);
begin
  inherited Create;
  FRootPath := Trim(ARootPath);
  FPort := APort;
  FToken := Trim(AToken);
  if FToken = '' then
    FToken := BuildToken;
end;

destructor TMapLibOfflineTileServer.Destroy;
begin
  Stop;
  inherited Destroy;
end;

function TMapLibOfflineTileServer.GetBaseUrl: string;
begin
  Result := FBaseUrl;
end;

function TMapLibOfflineTileServer.GetLastError: string;
begin
  Result := FLastError;
end;

{$IFNDEF FPC}
procedure TMapLibOfflineTileServer.HandleCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  documentPath: string;
  requestedToken: string;
  relativePath: string;
  localFileName: string;
begin
  ApplyCorsHeaders(AResponseInfo);

  if SameText(ARequestInfo.Document, '/health') then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'application/json; charset=utf-8';
    AResponseInfo.ContentText := '{"ok":true}';
    Exit;
  end;

  documentPath := NormalizeDocumentPath(ARequestInfo.Document);
  if documentPath = '' then
  begin
    AResponseInfo.ResponseNo := 404;
    Exit;
  end;

  requestedToken := Copy(documentPath, 1, Pos('/', documentPath + '/') - 1);
  if not SameText(requestedToken, FToken) then
  begin
    AResponseInfo.ResponseNo := 403;
    Exit;
  end;

  relativePath := Copy(documentPath, Length(requestedToken) + 2, MaxInt);
  if not TryBuildLocalFileName(relativePath, localFileName) then
  begin
    AResponseInfo.ResponseNo := 404;
    Exit;
  end;

  ServeFile(localFileName, ARequestInfo, AResponseInfo, False);
end;

procedure TMapLibOfflineTileServer.HandleCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  documentPath: string;
  requestedToken: string;
  relativePath: string;
  localFileName: string;
begin
  ApplyCorsHeaders(AResponseInfo);
  if SameText(ARequestInfo.Command, 'HEAD') then
  begin
    documentPath := NormalizeDocumentPath(ARequestInfo.Document);
    if documentPath = '' then
    begin
      AResponseInfo.ResponseNo := 404;
      Exit;
    end;

    requestedToken := Copy(documentPath, 1, Pos('/', documentPath + '/') - 1);
    if not SameText(requestedToken, FToken) then
    begin
      AResponseInfo.ResponseNo := 403;
      Exit;
    end;

    relativePath := Copy(documentPath, Length(requestedToken) + 2, MaxInt);
    if not TryBuildLocalFileName(relativePath, localFileName) then
    begin
      AResponseInfo.ResponseNo := 404;
      Exit;
    end;

    ServeFile(localFileName, ARequestInfo, AResponseInfo, True);
  end
  else if SameText(ARequestInfo.Command, 'OPTIONS') then
    AResponseInfo.ResponseNo := 204
  else
    AResponseInfo.ResponseNo := 405;
end;
{$ENDIF}

function TMapLibOfflineTileServer.IsRunning: Boolean;
begin
{$IFDEF FPC}
  Result := False;
{$ELSE}
  Result := Assigned(FServer) and FServer.Active;
{$ENDIF}
end;

function TMapLibOfflineTileServer.NormalizeDocumentPath(const ADocument: string): string;
begin
  Result := StringReplace(ADocument, '\', '/', [rfReplaceAll]);
  while (Result <> '') and (Result[1] = '/') do
    Delete(Result, 1, 1);
end;

function TMapLibOfflineTileServer.Start: Boolean;
{$IFNDEF FPC}
var
  effectivePort: Integer;
{$ENDIF}
begin
  Result := False;
  FLastError := '';
  FBaseUrl := '';

  if FRootPath = '' then
  begin
    FLastError := 'Offline root path is empty.';
    Exit;
  end;

  if not DirectoryExists(FRootPath) then
  begin
    FLastError := 'Offline root path does not exist: ' + FRootPath;
    Exit;
  end;

{$IFDEF FPC}
  FLastError := 'Embedded tile server is not implemented for FPC in this milestone.';
  Exit;
{$ELSE}
  if IsRunning then
  begin
    Result := True;
    Exit;
  end;

  FServer := TIdHTTPServer.Create(nil);
  try
    FServer.ParseParams := True;
    FServer.DefaultPort := FPort;
    FServer.KeepAlive := False;
    FServer.ListenQueue := 15;
    FServer.Bindings.Clear;
    with FServer.Bindings.Add do
    begin
      IP := '127.0.0.1';
      Port := FPort;
    end;
    FServer.OnCommandGet := HandleCommandGet;
    FServer.OnCommandOther := HandleCommandOther;
    FServer.Active := True;
  except
    on E: Exception do
    begin
      FLastError := E.Message;
      FreeAndNil(FServer);
      Exit;
    end;
  end;

  if (FServer.Bindings.Count > 0) and (FServer.Bindings[0].Port > 0) then
    effectivePort := FServer.Bindings[0].Port
  else
    effectivePort := FPort;

  FBaseUrl := Format('http://127.0.0.1:%d/%s/', [effectivePort, FToken]);
  Result := True;
{$ENDIF}
end;

procedure TMapLibOfflineTileServer.Stop;
begin
{$IFNDEF FPC}
  if Assigned(FServer) then
  begin
    try
      FServer.Active := False;
    finally
      FreeAndNil(FServer);
    end;
  end;
{$ENDIF}
  FBaseUrl := '';
end;

function TMapLibOfflineTileServer.TryBuildLocalFileName(const ARelativePath: string;
  out ALocalFileName: string): Boolean;
var
  expandedRoot: string;
  expandedFile: string;
begin
  Result := False;
  ALocalFileName := '';

  if (ARelativePath = '') or (Pos('..', ARelativePath) > 0) then
    Exit;

  expandedRoot := IncludeTrailingPathDelimiter(ExpandFileName(FRootPath));
  expandedFile := ExpandFileName(IncludeTrailingPathDelimiter(FRootPath) +
    StringReplace(ARelativePath, '/', PathDelim, [rfReplaceAll]));

  if not SameText(Copy(expandedFile, 1, Length(expandedRoot)), expandedRoot) then
    Exit;

  if not FileExists(expandedFile) then
    Exit;

  ALocalFileName := expandedFile;
  Result := True;
end;

end.
