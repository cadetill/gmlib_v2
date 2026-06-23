{**
  @abstract(Proveedor remoto HTTP para tiles vectoriales o raster.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Encapsula la construccion de URL y la descarga remota de tiles sin mezclar
  esa responsabilidad con el resolvedor local/hibrido.
}
unit uMapLib.Offline.RemoteTileProvider;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils, StrUtils
  {$IFDEF MSWINDOWS}
  , Windows, WinInet
  {$ELSE}
  , fphttpclient, opensslsockets
  {$ENDIF}
  ;
{$ELSE}
  System.Classes, System.SysUtils, System.StrUtils, System.Net.HttpClient, System.NetConsts;
{$ENDIF}

type
  {** @abstract(Contrato para descargar tiles desde un proveedor remoto.) }
  IMapLibRemoteTileProvider = interface
    ['{AE910D28-566F-4AE7-A9E7-CBF8509A8F55}']
    {**
      @abstract(Construye la URL final de un tile remoto.)
      @param(ASourceId Identificador logico de la fuente)
      @param(AZ Nivel de zoom XYZ)
      @param(AX Coordenada X XYZ)
      @param(AY Coordenada Y XYZ)
      @returns(URL final a solicitar al proveedor remoto)
    }
    function BuildTileUrl(const ASourceId: string; AZ, AX, AY: Integer): string;
    {**
      @abstract(Intenta descargar un tile remoto.)
      @param(ASourceId Identificador logico de la fuente)
      @param(AZ Nivel de zoom XYZ)
      @param(AX Coordenada X XYZ)
      @param(AY Coordenada Y XYZ)
      @param(ATileData Bytes descargados del tile)
      @param(AContentType Tipo MIME devuelto por el proveedor)
      @param(AContentEncoding Codificacion HTTP asociada a la respuesta)
      @returns(@true si la descarga produce un tile usable)
    }
    function TryFetchTile(const ASourceId: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
  end;

  {** @abstract(Implementacion HTTP simple basada en una plantilla URL.) }
  TMapLibHttpRemoteTileProvider = class(TInterfacedObject, IMapLibRemoteTileProvider)
  private
    FTileUrlTemplate: string;
    FConnectTimeout: Integer;
    FResponseTimeout: Integer;
{$IFNDEF FPC}
    FHttpClient: THTTPClient;
{$ENDIF}
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create;
    destructor Destroy; override;
    {** @abstract(Construye la URL final del tile aplicando la plantilla actual.) }
    function BuildTileUrl(const ASourceId: string; AZ, AX, AY: Integer): string;
    {** @abstract(Descarga un tile remoto usando `THTTPClient`.) }
    function TryFetchTile(const ASourceId: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;

    property TileUrlTemplate: string read FTileUrlTemplate write FTileUrlTemplate;
    property ConnectTimeout: Integer read FConnectTimeout write FConnectTimeout;
    property ResponseTimeout: Integer read FResponseTimeout write FResponseTimeout;
  end;

implementation

{$IFNDEF FPC}
uses
  System.Net.URLClient;
{$ENDIF}

{$IFDEF FPC}
{$IFDEF MSWINDOWS}
function QueryHeaderString(AHandle: HINTERNET; AQuery: DWORD): string;
var
  bufferLength: DWORD;
  index: DWORD;
begin
  Result := '';
  bufferLength := 0;
  index := 0;
  HttpQueryInfo(AHandle, AQuery, nil, bufferLength, index);
  if GetLastError <> ERROR_INSUFFICIENT_BUFFER then
    Exit;

  SetLength(Result, bufferLength);
  if HttpQueryInfo(AHandle, AQuery, PChar(Result), bufferLength, index) then
  begin
    if bufferLength > 0 then
      SetLength(Result, Integer(bufferLength) - 1)
    else
      Result := '';
  end
  else
    Result := '';
end;

function TryFetchUrlWinInet(const AUrl: string; AConnectTimeout,
  AResponseTimeout: Integer; out AData: TBytes; out AContentType,
  AContentEncoding: string; out AStatusCode: Integer;
  out AErrorText: string): Boolean;
const
  cBufferSize = 16384;
var
  sessionHandle: HINTERNET;
  urlHandle: HINTERNET;
  optionValue: DWORD;
  headerText: string;
  statusCodeSize: DWORD;
  statusCodeIndex: DWORD;
  readBuffer: array[0..cBufferSize - 1] of Byte;
  bytesRead: DWORD;
  requestFlags: DWORD;
  outputStream: TMemoryStream;
begin
  Result := False;
  AData := nil;
  AContentType := '';
  AContentEncoding := '';
  AStatusCode := 0;
  AErrorText := '';
  sessionHandle := nil;
  urlHandle := nil;

  sessionHandle := InternetOpen('GMLib/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if sessionHandle = nil then
  begin
    AErrorText := 'InternetOpen failed: ' + SysErrorMessage(GetLastError);
    Exit;
  end;

  try
    optionValue := DWORD(AConnectTimeout);
    InternetSetOption(sessionHandle, INTERNET_OPTION_CONNECT_TIMEOUT, @optionValue, SizeOf(optionValue));
    optionValue := DWORD(AResponseTimeout);
    InternetSetOption(sessionHandle, INTERNET_OPTION_RECEIVE_TIMEOUT, @optionValue, SizeOf(optionValue));
    InternetSetOption(sessionHandle, INTERNET_OPTION_SEND_TIMEOUT, @optionValue, SizeOf(optionValue));

    headerText :=
      'Accept: application/vnd.mapbox-vector-tile, application/x-protobuf, */*' + #13#10 +
      'Accept-Encoding: identity' + #13#10;
    requestFlags := INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE or
      INTERNET_FLAG_PRAGMA_NOCACHE;
    if StartsText('https://', AUrl) then
      requestFlags := requestFlags or INTERNET_FLAG_SECURE;

    urlHandle := InternetOpenUrl(sessionHandle, PChar(AUrl), PChar(headerText),
      Length(headerText), requestFlags, 0);
    if urlHandle = nil then
    begin
      AErrorText := 'InternetOpenUrl failed: ' + SysErrorMessage(GetLastError);
      Exit;
    end;

    statusCodeSize := SizeOf(AStatusCode);
    statusCodeIndex := 0;
    if not HttpQueryInfo(urlHandle, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER,
      @AStatusCode, statusCodeSize, statusCodeIndex) then
      AStatusCode := 0;

    AContentType := QueryHeaderString(urlHandle, HTTP_QUERY_CONTENT_TYPE);
    AContentEncoding := QueryHeaderString(urlHandle, HTTP_QUERY_CONTENT_ENCODING);

    outputStream := TMemoryStream.Create;
    try
      repeat
        bytesRead := 0;
        if not InternetReadFile(urlHandle, @readBuffer[0], SizeOf(readBuffer), bytesRead) then
        begin
          AErrorText := 'InternetReadFile failed: ' + SysErrorMessage(GetLastError);
          Exit;
        end;
        if bytesRead > 0 then
          outputStream.WriteBuffer(readBuffer[0], bytesRead);
      until bytesRead = 0;

      if (AStatusCode = 200) and (outputStream.Size > 0) then
      begin
        SetLength(AData, outputStream.Size);
        outputStream.Position := 0;
        outputStream.ReadBuffer(AData[0], outputStream.Size);
        Result := True;
      end
      else if AStatusCode = 0 then
        AErrorText := 'HTTP status code unavailable.'
      else
        AErrorText := Format('HTTP Error %d', [AStatusCode]);
    finally
      outputStream.Free;
    end;
  finally
    if urlHandle <> nil then
      InternetCloseHandle(urlHandle);
    InternetCloseHandle(sessionHandle);
  end;
end;
{$ENDIF}
{$ENDIF}

procedure AppendRemoteTileProviderTrace(const AMessage: string);
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
      logLines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' [RemoteTileProvider] ' + AMessage);
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

{ TMapLibHttpRemoteTileProvider }

function TMapLibHttpRemoteTileProvider.BuildTileUrl(const ASourceId: string; AZ,
  AX, AY: Integer): string;
begin
  Result := FTileUrlTemplate;
  Result := StringReplace(Result, '{source}', ASourceId, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{z}', IntToStr(AZ), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{x}', IntToStr(AX), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{y}', IntToStr(AY), [rfReplaceAll, rfIgnoreCase]);
  if StartsText('http://tiles.openfreemap.org/', Result) then
    Result := 'https://' + Copy(Result, Length('http://') + 1, MaxInt);
end;

constructor TMapLibHttpRemoteTileProvider.Create;
begin
  inherited Create;
  FConnectTimeout := 15000;
  FResponseTimeout := 30000;
{$IFNDEF FPC}
  FHttpClient := THTTPClient.Create;
  FHttpClient.ConnectionTimeout := FConnectTimeout;
  FHttpClient.ResponseTimeout := FResponseTimeout;
{$ENDIF}
end;

destructor TMapLibHttpRemoteTileProvider.Destroy;
begin
{$IFNDEF FPC}
  FHttpClient.Free;
{$ENDIF}
  inherited Destroy;
end;

function TMapLibHttpRemoteTileProvider._AddRef: Integer; stdcall;
begin
  Result := -1;
end;

function TMapLibHttpRemoteTileProvider._Release: Integer; stdcall;
begin
  Result := -1;
end;

function TMapLibHttpRemoteTileProvider.TryFetchTile(const ASourceId: string; AZ,
  AX, AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
{$IFDEF FPC}
{$IFDEF MSWINDOWS}
var
  tileUrl: string;
  statusCode: Integer;
  errorText: string;
{$ELSE}
var
  tileStream: TMemoryStream;
  tileUrl: string;
  httpClient: TFPHTTPClient;
{$ENDIF}
{$ELSE}
var
  response: IHTTPResponse;
  tileUrl: string;
  tileStream: TMemoryStream;
{$ENDIF}
begin
  Result := False;
  ATileData := nil;
  AContentType := '';
  AContentEncoding := '';

{$IFDEF FPC}
{$IFDEF MSWINDOWS}
  tileUrl := BuildTileUrl(ASourceId, AZ, AX, AY);
  AppendRemoteTileProviderTrace(Format('Fetch start source=%s z=%d x=%d y=%d url=%s',
    [ASourceId, AZ, AX, AY, tileUrl]));
  Result := TryFetchUrlWinInet(tileUrl, FConnectTimeout, FResponseTimeout,
    ATileData, AContentType, AContentEncoding, statusCode, errorText);
  if Result then
    AppendRemoteTileProviderTrace(Format('Fetch success status=%d bytes=%d contentType=%s contentEncoding=%s',
      [statusCode, Length(ATileData), AContentType, AContentEncoding]))
  else if errorText <> '' then
    AppendRemoteTileProviderTrace('Fetch exception: ' + errorText)
  else
    AppendRemoteTileProviderTrace(Format('Fetch failed status=%d bytes=%d',
      [statusCode, Length(ATileData)]));
{$ELSE}
  httpClient := TFPHTTPClient.Create(nil);
  tileStream := TMemoryStream.Create;
  try
    tileUrl := BuildTileUrl(ASourceId, AZ, AX, AY);
    AppendRemoteTileProviderTrace(Format('Fetch start source=%s z=%d x=%d y=%d url=%s',
      [ASourceId, AZ, AX, AY, tileUrl]));
    httpClient.ConnectTimeout := FConnectTimeout;
    httpClient.IOTimeout := FResponseTimeout;
    httpClient.AllowRedirect := True;
    httpClient.AddHeader('Accept',
      'application/vnd.mapbox-vector-tile, application/x-protobuf, */*');
    httpClient.AddHeader('Accept-Encoding', 'identity');
    try
      httpClient.Get(tileUrl, tileStream);
      AppendRemoteTileProviderTrace(Format('Fetch completed status=%d bytes=%d',
        [httpClient.ResponseStatusCode, tileStream.Size]));
      if (httpClient.ResponseStatusCode <> 200) or (tileStream.Size <= 0) then
        Exit(False);

      SetLength(ATileData, tileStream.Size);
      tileStream.Position := 0;
      tileStream.ReadBuffer(ATileData[0], tileStream.Size);
      AContentType := httpClient.ResponseHeaders.Values['Content-Type'];
      AContentEncoding := httpClient.ResponseHeaders.Values['Content-Encoding'];
      AppendRemoteTileProviderTrace(Format('Fetch success contentType=%s contentEncoding=%s',
        [AContentType, AContentEncoding]));
      Result := True;
    except
      on E: Exception do
      begin
        AppendRemoteTileProviderTrace('Fetch exception: ' + E.Message);
        Result := False;
      end;
    end;
  finally
    tileStream.Free;
    httpClient.Free;
  end;
{$ENDIF}
{$ELSE}
  if not Assigned(FHttpClient) then
    Exit;

  FHttpClient.ConnectionTimeout := FConnectTimeout;
  FHttpClient.ResponseTimeout := FResponseTimeout;
  FHttpClient.Accept := 'application/vnd.mapbox-vector-tile, application/x-protobuf, */*';
  FHttpClient.AcceptEncoding := 'identity';
  tileUrl := BuildTileUrl(ASourceId, AZ, AX, AY);

  tileStream := TMemoryStream.Create;
  try
    try
      response := FHttpClient.Get(tileUrl, tileStream);
      if (response.StatusCode <> 200) or (tileStream.Size <= 0) then
        Exit;

      SetLength(ATileData, tileStream.Size);
      tileStream.Position := 0;
      tileStream.ReadBuffer(ATileData[0], tileStream.Size);
      AContentType := response.MimeType;
      AContentEncoding := response.HeaderValue['Content-Encoding'];
      Result := True;
    except
      on Exception do
        Result := False;
    end;
  finally
    tileStream.Free;
  end;
{$ENDIF}
end;

end.
