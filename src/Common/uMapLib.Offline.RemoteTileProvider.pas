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
  Classes, SysUtils, StrUtils, fphttpclient;
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
var
  tileStream: TMemoryStream;
  tileUrl: string;
  httpClient: TFPHTTPClient;
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
