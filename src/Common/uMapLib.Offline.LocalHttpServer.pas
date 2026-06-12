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
  Classes, SysUtils, fphttpserver, httpdefs,
{$ELSE}
  System.Classes, System.SysUtils, System.TypInfo,
  IdContext, IdCustomHTTPServer, IdHTTPServer, IdExceptionCore, IdException, IdStack
  {$IFDEF MSWINDOWS}, Winapi.Winsock2{$ENDIF},
{$ENDIF}
  uMapLib.Core.Offline;

type
  TMapLibHttpRequestData = class
  public
    Method: string;
    Document: string;
    Params: TStringList;
    constructor Create;
    destructor Destroy; override;
  end;

  TMapLibHttpResponseData = class
  public
    StatusCode: Integer;
    ContentType: string;
    ContentText: string;
    ContentStream: TStream;
    FreeContentStream: Boolean;
    Headers: TStringList;
    constructor Create;
    destructor Destroy; override;
  end;

  TMapLibHttpRequestEvent = procedure(Sender: TObject; ARequest: TMapLibHttpRequestData;
    AResponse: TMapLibHttpResponseData; var AHandled: Boolean) of object;

{$IFDEF FPC}
  TMapLibFPHTTPServer = class(TFPHTTPServer)
  published
    property Address;
  end;
{$ENDIF}

  {** @abstract(Servidor localhost generico para rutas del runtime.) }
  TMapLibLocalHttpServer = class(TInterfacedObject, IMapLibOfflineTileServer)
  private
    FPort: Integer;
    FToken: string;
    FBaseUrl: string;
    FLastError: string;
    FOnCommand: TMapLibHttpRequestEvent;
{$IFDEF FPC}
    FServer: TMapLibFPHTTPServer;
    procedure ApplyCorsHeaders(AResponse: TResponse);
    procedure ApplyResponseData(AResponse: TResponse;
      AResponseData: TMapLibHttpResponseData);
    procedure HandleRequest(Sender: TObject; var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
{$ELSE}
    FServer: TIdHTTPServer;
    procedure ApplyCorsHeaders(AResponseInfo: TIdHTTPResponseInfo);
    procedure ApplyResponseData(AResponseInfo: TIdHTTPResponseInfo;
      AResponseData: TMapLibHttpResponseData);
{$ENDIF}
    procedure DispatchRequest(const AMethod, ADocument: string; AParams: TStrings;
      AResponseData: TMapLibHttpResponseData);
{$IFNDEF FPC}
    function IsExpectedSocketDisconnect(AException: Exception): Boolean;
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
    property OnCommand: TMapLibHttpRequestEvent read FOnCommand write FOnCommand;
  end;

implementation

{ TMapLibHttpRequestData }

constructor TMapLibHttpRequestData.Create;
begin
  inherited Create;
  Params := TStringList.Create;
end;

destructor TMapLibHttpRequestData.Destroy;
begin
  Params.Free;
  inherited Destroy;
end;

{ TMapLibHttpResponseData }

constructor TMapLibHttpResponseData.Create;
begin
  inherited Create;
  StatusCode := 200;
  Headers := TStringList.Create;
end;

destructor TMapLibHttpResponseData.Destroy;
begin
  if FreeContentStream then
    FreeAndNil(ContentStream);
  Headers.Free;
  inherited Destroy;
end;

{ TMapLibLocalHttpServer }

procedure TMapLibLocalHttpServer.ApplyCorsHeaders(
{$IFDEF FPC}
  AResponse: TResponse);
begin
  AResponse.CustomHeaders.Values['Access-Control-Allow-Origin'] := '*';
  AResponse.CustomHeaders.Values['Access-Control-Allow-Methods'] := 'GET, HEAD, OPTIONS';
  AResponse.CustomHeaders.Values['Access-Control-Allow-Headers'] := '*';
end;
{$ELSE}
  AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Origin'] := '*';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Methods'] := 'GET, HEAD, OPTIONS';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Headers'] := '*';
end;
{$ENDIF}

procedure TMapLibLocalHttpServer.ApplyResponseData(
{$IFDEF FPC}
  AResponse: TResponse; AResponseData: TMapLibHttpResponseData);
var
  I: Integer;
begin
  AResponse.Code := AResponseData.StatusCode;
  if AResponseData.ContentType <> '' then
    AResponse.ContentType := AResponseData.ContentType;
  for I := 0 to AResponseData.Headers.Count - 1 do
    AResponse.CustomHeaders.Values[AResponseData.Headers.Names[I]] :=
      AResponseData.Headers.ValueFromIndex[I];

  if Assigned(AResponseData.ContentStream) then
  begin
    AResponse.ContentStream := AResponseData.ContentStream;
    AResponse.FreeContentStream := AResponseData.FreeContentStream;
    AResponseData.ContentStream := nil;
    AResponseData.FreeContentStream := False;
  end
  else if AResponseData.ContentText <> '' then
    AResponse.Content := RawByteString(AResponseData.ContentText);
end;
{$ELSE}
  AResponseInfo: TIdHTTPResponseInfo; AResponseData: TMapLibHttpResponseData);
var
  I: Integer;
begin
  AResponseInfo.ResponseNo := AResponseData.StatusCode;
  if AResponseData.ContentType <> '' then
    AResponseInfo.ContentType := AResponseData.ContentType;
  for I := 0 to AResponseData.Headers.Count - 1 do
    AResponseInfo.CustomHeaders.Values[AResponseData.Headers.Names[I]] :=
      AResponseData.Headers.ValueFromIndex[I];

  if Assigned(AResponseData.ContentStream) then
  begin
    AResponseInfo.ContentStream := AResponseData.ContentStream;
    AResponseInfo.FreeContentStream := AResponseData.FreeContentStream;
    AResponseData.ContentStream := nil;
    AResponseData.FreeContentStream := False;
  end
  else if AResponseData.ContentText <> '' then
    AResponseInfo.ContentText := AResponseData.ContentText;
end;
{$ENDIF}

procedure TMapLibLocalHttpServer.DispatchRequest(const AMethod, ADocument: string;
  AParams: TStrings; AResponseData: TMapLibHttpResponseData);
var
  handled: Boolean;
  requestData: TMapLibHttpRequestData;
  tokenValue: string;
begin
  if SameText(ADocument, '/health') then
  begin
    AResponseData.StatusCode := 200;
    AResponseData.ContentType := 'application/json; charset=utf-8';
    AResponseData.ContentText := '{"ok":true}';
    Exit;
  end;

  if Assigned(AParams) then
    tokenValue := Trim(AParams.Values['token'])
  else
    tokenValue := '';

  if not SameText(AMethod, 'OPTIONS') and
     not SameText(tokenValue, FToken) then
  begin
    AResponseData.StatusCode := 403;
    Exit;
  end;

  if SameText(AMethod, 'OPTIONS') then
  begin
    AResponseData.StatusCode := 204;
    Exit;
  end;

  if not SameText(AMethod, 'GET') and not SameText(AMethod, 'HEAD') then
  begin
    AResponseData.StatusCode := 405;
    Exit;
  end;

  handled := False;
  requestData := TMapLibHttpRequestData.Create;
  try
    requestData.Method := AMethod;
    requestData.Document := ADocument;
    if Assigned(AParams) then
      requestData.Params.Assign(AParams);
    if Assigned(FOnCommand) then
      FOnCommand(Self, requestData, AResponseData, handled);
    if not handled then
      AResponseData.StatusCode := 404;
  finally
    requestData.Free;
  end;
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

{$IFDEF FPC}
procedure TMapLibLocalHttpServer.HandleRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
var
  responseData: TMapLibHttpResponseData;
  documentPath: string;
begin
  ApplyCorsHeaders(AResponse);
  responseData := TMapLibHttpResponseData.Create;
  try
    documentPath := ARequest.PathInfo;
    if documentPath = '' then
      documentPath := ARequest.URI;
    if Pos('?', documentPath) > 0 then
      documentPath := Copy(documentPath, 1, Pos('?', documentPath) - 1);
    DispatchRequest(ARequest.Method, documentPath, ARequest.QueryFields, responseData);
    ApplyResponseData(AResponse, responseData);
  finally
    responseData.Free;
  end;
end;
{$ENDIF}

{$IFNDEF FPC}
procedure TMapLibLocalHttpServer.HandleCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  responseData: TMapLibHttpResponseData;
begin
  ApplyCorsHeaders(AResponseInfo);
  responseData := TMapLibHttpResponseData.Create;
  try
    DispatchRequest(ARequestInfo.Command, ARequestInfo.Document, ARequestInfo.Params, responseData);
    ApplyResponseData(AResponseInfo, responseData);
  finally
    responseData.Free;
  end;
end;

procedure TMapLibLocalHttpServer.HandleCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  responseData: TMapLibHttpResponseData;
begin
  ApplyCorsHeaders(AResponseInfo);
  responseData := TMapLibHttpResponseData.Create;
  try
    DispatchRequest(ARequestInfo.Command, ARequestInfo.Document, ARequestInfo.Params, responseData);
    ApplyResponseData(AResponseInfo, responseData);
  finally
    responseData.Free;
  end;
end;

function TMapLibLocalHttpServer.IsExpectedSocketDisconnect(
  AException: Exception): Boolean;
begin
  Result := AException is EIdConnClosedGracefully;
  if Result then
    Exit;

  if AException is EIdSocketError then
  begin
{$IFDEF MSWINDOWS}
    Result := (EIdSocketError(AException).LastError = WSAECONNABORTED) or
      (EIdSocketError(AException).LastError = WSAECONNRESET);
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

{$ENDIF}

function TMapLibLocalHttpServer.IsRunning: Boolean;
begin
{$IFDEF FPC}
  Result := Assigned(FServer) and FServer.Active;
{$ELSE}
  Result := Assigned(FServer) and FServer.Active;
{$ENDIF}
end;

function TMapLibLocalHttpServer.Start: Boolean;
{$IFDEF FPC}
var
  effectivePort: Integer;
  attempts: Integer;
{$ELSE}
var
  effectivePort: Integer;
  propInfo: PPropInfo;
  allocatedPort: Integer;
{$ENDIF}
begin
  FLastError := '';

{$IFDEF FPC}
  if IsRunning then
    Exit(True);

  FBaseUrl := '';
  attempts := 0;
  repeat
    if FPort <= 0 then
      effectivePort := 49152 + Random(12000)
    else
      effectivePort := FPort;

    FServer := TMapLibFPHTTPServer.Create(nil);
    try
      FServer.Address := '127.0.0.1';
      FServer.Port := effectivePort;
      FServer.Threaded := True;
      FServer.OnRequest := @HandleRequest;
      FServer.Active := True;
      FPort := effectivePort;
      FBaseUrl := Format('http://127.0.0.1:%d/', [effectivePort]);
      Exit(True);
    except
      on E: Exception do
      begin
        FLastError := E.Message;
        FreeAndNil(FServer);
        Inc(attempts);
        if FPort > 0 then
          Break;
      end;
    end;
  until attempts >= 8;

  Result := False;
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

  effectivePort := FPort;
  if FServer.Bindings.Count > 0 then
  begin
    if FServer.Bindings[0].Port > 0 then
      effectivePort := FServer.Bindings[0].Port
    else
    begin
      propInfo := GetPropInfo(FServer.Bindings[0], 'AllocatedPort');
      if Assigned(propInfo) then
      begin
        allocatedPort := GetOrdProp(FServer.Bindings[0], propInfo);
        if allocatedPort > 0 then
          effectivePort := allocatedPort;
      end;
    end;
  end;

  FBaseUrl := Format('http://127.0.0.1:%d/', [effectivePort]);
  Result := True;
{$ENDIF}
end;

procedure TMapLibLocalHttpServer.Stop;
begin
{$IFDEF FPC}
  if Assigned(FServer) then
  begin
    try
      FServer.Active := False;
    finally
      FreeAndNil(FServer);
    end;
  end;
{$ELSE}
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
