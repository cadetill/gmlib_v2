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
  Classes, SysUtils;
{$ELSE}
  System.Classes, System.SysUtils, System.Net.HttpClient, System.NetConsts;
{$ENDIF}

type
  {** @abstract(Contrato para descargar tiles desde un proveedor remoto.) }
  IMapLibRemoteTileProvider = interface
    ['{AE910D28-566F-4AE7-A9E7-CBF8509A8F55}']
    function BuildTileUrl(const ASourceId: string; AZ, AX, AY: Integer): string;
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
    function BuildTileUrl(const ASourceId: string; AZ, AX, AY: Integer): string;
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

{ TMapLibHttpRemoteTileProvider }

function TMapLibHttpRemoteTileProvider.BuildTileUrl(const ASourceId: string; AZ,
  AX, AY: Integer): string;
begin
  Result := FTileUrlTemplate;
  Result := StringReplace(Result, '{source}', ASourceId, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{z}', IntToStr(AZ), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{x}', IntToStr(AX), [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '{y}', IntToStr(AY), [rfReplaceAll, rfIgnoreCase]);
end;

constructor TMapLibHttpRemoteTileProvider.Create;
begin
  inherited Create;
  FConnectTimeout := 4000;
  FResponseTimeout := 8000;
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

function TMapLibHttpRemoteTileProvider._AddRef: Integer;
begin
  Result := -1;
end;

function TMapLibHttpRemoteTileProvider._Release: Integer;
begin
  Result := -1;
end;

function TMapLibHttpRemoteTileProvider.TryFetchTile(const ASourceId: string; AZ,
  AX, AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
{$IFNDEF FPC}
var
  response: IHTTPResponse;
  tileUrl: string;
  tileStream: TMemoryStream;
{$ENDIF}
begin
  Result := False;
  SetLength(ATileData, 0);
  AContentType := '';
  AContentEncoding := '';

{$IFDEF FPC}
  Exit;
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
