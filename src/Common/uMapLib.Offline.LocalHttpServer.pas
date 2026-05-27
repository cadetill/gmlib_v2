{**
  @abstract(Servidor HTTP local generico para runtime offline/hibrido.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Proporciona un servidor localhost ligero y reutilizable para exponer rutas de
  runtime como tiles, glyphs, sprites o chequeos de salud.
}
unit uMapLib.Offline.LocalHttpServer;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils,
{$ELSE}
  System.Classes, System.SysUtils,
  IdContext, IdCustomHTTPServer, IdHTTPServer, IdExceptionCore, IdException, IdStack
  {$IFDEF MSWINDOWS}, Winapi.Winsock2{$ENDIF},
{$ENDIF}
  uMapLib.Core.Offline;

type
{$IFNDEF FPC}
  TMapLibHttpRequestEvent = procedure(Sender: TObject; AContext: TIdContext;
    ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo;
    var AHandled: Boolean) of object;
{$ENDIF}

  {** @abstract(Servidor localhost generico para rutas del runtime.) }
  TMapLibLocalHttpServer = class(TInterfacedObject, IMapLibOfflineTileServer)
  private
    FPort: Integer;
    FToken: string;
    FBaseUrl: string;
    FLastError: string;
{$IFNDEF FPC}
    FServer: TIdHTTPServer;
    FOnCommand: TMapLibHttpRequestEvent;
    procedure ApplyCorsHeaders(AResponseInfo: TIdHTTPResponseInfo);
    function IsExpectedSocketDisconnect(AException: Exception): Boolean;
    function HasValidToken(ARequestInfo: TIdHTTPRequestInfo): Boolean;
    procedure HandleCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleCommandOther(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure HandleServerException(AContext: TIdContext; AException: Exception);
{$ENDIF}
    function BuildToken: string;
  public
    constructor Create(APort: Integer = 0; const AToken: string = '');
    destructor Destroy; override;
    {** @abstract(Arranca el servidor localhost y reserva un puerto si hace falta.) }
    function Start: Boolean;
    {** @abstract(Detiene el servidor localhost si estaba activo.) }
    procedure Stop;
    {** @abstract(Indica si el servidor esta escuchando peticiones.) }
    function IsRunning: Boolean;
    {** @abstract(Devuelve la base URL efectiva del runtime local.) }
    function GetBaseUrl: string;
    {** @abstract(Devuelve el ultimo error funcional del arranque.) }
    function GetLastError: string;
    {** @abstract(Construye una URL completa del runtime a partir de una ruta relativa.) }
    function BuildRuntimeUrl(const APathAndQuery: string): string;
{$IFNDEF FPC}
    property OnCommand: TMapLibHttpRequestEvent read FOnCommand write FOnCommand;
{$ENDIF}
  end;

implementation

uses
  uMapLib.Core.Types;

{ TMapLibLocalHttpServer }

procedure TMapLibLocalHttpServer.ApplyCorsHeaders(
  AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Origin'] := '*';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Methods'] := 'GET, HEAD, OPTIONS';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Headers'] := '*';
end;

function TMapLibLocalHttpServer.BuildRuntimeUrl(const APathAndQuery: string): string;
var
  normalized: string;
  separator: string;
begin
  normalized := APathAndQuery.Trim;
  while (normalized <> '') and (normalized[1] = '/') do
    Delete(normalized, 1, 1);

  if Pos('?', normalized) > 0 then
    separator := '&'
  else
    separator := '?';

  Result := FBaseUrl + normalized + separator + 'token=' + FToken;
end;

function TMapLibLocalHttpServer.BuildToken: string;
begin
{$IFDEF FPC}
  Result := IntToHex(Random(MaxInt), 8) + IntToHex(Random(MaxInt), 8);
{$ELSE}
  Result := StringReplace(TGUID.NewGuid.ToString, '-', '', [rfReplaceAll]);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
{$ENDIF}
end;

constructor TMapLibLocalHttpServer.Create(APort: Integer; const AToken: string);
begin
  inherited Create;
  FPort := APort;
  FToken := Trim(AToken);
  if FToken = '' then
    FToken := BuildToken;
end;

destructor TMapLibLocalHttpServer.Destroy;
begin
  Stop;
  inherited Destroy;
end;

function TMapLibLocalHttpServer.GetBaseUrl: string;
begin
  Result := FBaseUrl;
end;

function TMapLibLocalHttpServer.GetLastError: string;
begin
  Result := FLastError;
end;

{$IFNDEF FPC}
procedure TMapLibLocalHttpServer.HandleCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  handled: Boolean;
begin
  ApplyCorsHeaders(AResponseInfo);

  if SameText(ARequestInfo.Document, '/health') then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'application/json; charset=utf-8';
    AResponseInfo.ContentText := '{"ok":true}';
    Exit;
  end;

  if not HasValidToken(ARequestInfo) then
  begin
    AResponseInfo.ResponseNo := 403;
    Exit;
  end;

  handled := False;
  if Assigned(FOnCommand) then
    FOnCommand(Self, AContext, ARequestInfo, AResponseInfo, handled);

  if not handled then
    AResponseInfo.ResponseNo := 404;
end;

procedure TMapLibLocalHttpServer.HandleCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  ApplyCorsHeaders(AResponseInfo);
  if SameText(ARequestInfo.Command, 'OPTIONS') then
    AResponseInfo.ResponseNo := 204
  else if SameText(ARequestInfo.Command, 'HEAD') then
    HandleCommandGet(AContext, ARequestInfo, AResponseInfo)
  else
    AResponseInfo.ResponseNo := 405;
end;

function TMapLibLocalHttpServer.IsExpectedSocketDisconnect(
  AException: Exception): Boolean;
var
  socketError: EIdSocketError;
begin
  Result := AException is EIdConnClosedGracefully;
  if Result then
    Exit;

  if AException is EIdSocketError then
  begin
    socketError := EIdSocketError(AException);
{$IFDEF MSWINDOWS}
    Result := (socketError.LastError = WSAECONNABORTED) or (socketError.LastError = WSAECONNRESET);
{$ELSE}
    Result := False;
{$ENDIF}
  end;
end;

procedure TMapLibLocalHttpServer.HandleServerException(AContext: TIdContext;
  AException: Exception);
begin
  if IsExpectedSocketDisconnect(AException) then
    Exit;

  FLastError := AException.Message;
end;

function TMapLibLocalHttpServer.HasValidToken(
  ARequestInfo: TIdHTTPRequestInfo): Boolean;
begin
  Result := SameText(ARequestInfo.Params.Values['token'], FToken);
end;
{$ENDIF}

function TMapLibLocalHttpServer.IsRunning: Boolean;
begin
{$IFDEF FPC}
  Result := False;
{$ELSE}
  Result := Assigned(FServer) and FServer.Active;
{$ENDIF}
end;

function TMapLibLocalHttpServer.Start: Boolean;
{$IFNDEF FPC}
var
  effectivePort: Integer;
{$ENDIF}
begin
  FLastError := '';

{$IFDEF FPC}
  FBaseUrl := '';
  Result := False;
  FLastError := 'Embedded localhost server is not implemented for FPC in this milestone.';
  Exit;
{$ELSE}
  if IsRunning then
    Exit(True);

  FBaseUrl := '';

  FServer := TIdHTTPServer.Create(nil);
  try
    FServer.ParseParams := True;
    FServer.KeepAlive := False;
    FServer.ListenQueue := 15;
    FServer.DefaultPort := FPort;
    FServer.Bindings.Clear;
    with FServer.Bindings.Add do
    begin
      IP := '127.0.0.1';
      Port := FPort;
    end;
    FServer.OnCommandGet := HandleCommandGet;
    FServer.OnCommandOther := HandleCommandOther;
    FServer.OnException := HandleServerException;
    FServer.Active := True;
  except
    on E: Exception do
    begin
      FLastError := E.Message;
      FreeAndNil(FServer);
      Exit(False);
    end;
  end;

  if (FServer.Bindings.Count > 0) and (FServer.Bindings[0].Port > 0) then
    effectivePort := FServer.Bindings[0].Port
  else
    effectivePort := FPort;

  FBaseUrl := Format('http://127.0.0.1:%d/', [effectivePort]);
  Result := True;
{$ENDIF}
end;

procedure TMapLibLocalHttpServer.Stop;
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

end.
