{**
  @abstract(Descargador de regiones en segundo plano para MapLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
}
unit uMapLib.Offline.Downloader;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  SysUtils,
  {$IFDEF MSWINDOWS}
  Windows,
  WinInet,
  {$ELSE}
  fphttpclient,
  opensslsockets,
  {$ENDIF}
{$ELSE}
  System.Classes,
  System.SysUtils,
  System.Net.HttpClient,
  System.IOUtils,
{$ENDIF}
  uMapLib.Offline.Types;

type
  TMapLibDownloadJob = class;

  {** @abstract(Evento disparado para reportar el progreso del hilo al hilo principal.) }
  TMapLibDownloadProgressEvent = procedure(Sender: TMapLibDownloadJob;
    ABytesDone, ABytesTotal: Int64; APercent: Double) of object;

  {** @abstract(Evento disparado para notificar el fin del trabajo.) }
  TMapLibDownloadCompletedEvent = procedure(Sender: TMapLibDownloadJob;
    const AMetadata: TMapLibOfflineRegionMetadata; const AErrorMsg: string; ASuccess: Boolean) of object;

  {** @abstract(Hilo de segundo plano para la descarga asincrona de archivos de mapa.) }
  TMapLibDownloadJob = class(TThread)
  private
    FJobId: string;
    FRequest: TMapLibOfflineDownloadRequest;
    FStorageBasePath: string;
    FOnProgress: TMapLibDownloadProgressEvent;
    FOnCompleted: TMapLibDownloadCompletedEvent;
    FSuccess: Boolean;
    FErrorMsg: string;
    FResultMetadata: TMapLibOfflineRegionMetadata;
    FSyncBytesDone: Int64;
    FSyncBytesTotal: Int64;
    FSyncPercent: Double;
{$IFDEF FPC}
    procedure DoReceiveData(Sender: TObject; const ContentLength, CurrentPos: Int64);
{$ELSE}
    procedure DoReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
{$ENDIF}
    procedure SyncProgress;
    procedure SyncCompleted;
  protected
    procedure Execute; override;
  public
    constructor Create(const AJobId: string; const ARequest: TMapLibOfflineDownloadRequest;
      const AStorageBasePath: string; AOnProgress: TMapLibDownloadProgressEvent;
      AOnCompleted: TMapLibDownloadCompletedEvent);

    property JobId: string read FJobId;
    property Request: TMapLibOfflineDownloadRequest read FRequest;
    property StorageBasePath: string read FStorageBasePath;
  end;

implementation

{$IFDEF FPC}
{$IFDEF MSWINDOWS}
function QueryHeaderInteger(AHandle: HINTERNET; AQuery: DWORD;
  out AValue: Int64): Boolean;
var
  rawValue: DWORD;
  rawSize: DWORD;
  index: DWORD;
begin
  rawValue := 0;
  rawSize := SizeOf(rawValue);
  index := 0;
  Result := HttpQueryInfo(AHandle, AQuery or HTTP_QUERY_FLAG_NUMBER,
    @rawValue, rawSize, index);
  if Result then
    AValue := rawValue
  else
    AValue := 0;
end;
{$ENDIF}
{$ENDIF}

function CombinePath(const ALeft, ARight: string): string;
begin
{$IFDEF FPC}
  if ALeft = '' then
    Result := ARight
  else
    Result := IncludeTrailingPathDelimiter(ALeft) + ARight;
{$ELSE}
  Result := TPath.Combine(ALeft, ARight);
{$ENDIF}
end;

{ TMapLibDownloadJob }

constructor TMapLibDownloadJob.Create(const AJobId: string;
  const ARequest: TMapLibOfflineDownloadRequest; const AStorageBasePath: string;
  AOnProgress: TMapLibDownloadProgressEvent; AOnCompleted: TMapLibDownloadCompletedEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;

  FJobId := AJobId;
  FRequest := ARequest;
  FStorageBasePath := AStorageBasePath;
  FOnProgress := AOnProgress;
  FOnCompleted := AOnCompleted;
  FSuccess := False;
  FErrorMsg := '';
  FillChar(FResultMetadata, SizeOf(FResultMetadata), 0);
end;

{$IFDEF FPC}
procedure TMapLibDownloadJob.DoReceiveData(Sender: TObject; const ContentLength,
  CurrentPos: Int64);
begin
  FSyncBytesDone := CurrentPos;
  FSyncBytesTotal := ContentLength;
  if ContentLength > 0 then
    FSyncPercent := (CurrentPos / ContentLength) * 100
  else
    FSyncPercent := 0;

  TThread.Queue(Self, @SyncProgress);
end;
{$ELSE}
procedure TMapLibDownloadJob.DoReceiveData(const Sender: TObject; AContentLength,
  AReadCount: Int64; var AAbort: Boolean);
begin
  if Terminated then
  begin
    AAbort := True;
    Exit;
  end;

  FSyncBytesDone := AReadCount;
  FSyncBytesTotal := AContentLength;
  if AContentLength > 0 then
    FSyncPercent := (AReadCount / AContentLength) * 100
  else
    FSyncPercent := 0;

  TThread.Queue(Self, SyncProgress);
end;
{$ENDIF}

procedure TMapLibDownloadJob.SyncProgress;
begin
  if Assigned(FOnProgress) and not Terminated then
    FOnProgress(Self, FSyncBytesDone, FSyncBytesTotal, FSyncPercent);
end;

procedure TMapLibDownloadJob.SyncCompleted;
begin
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, FResultMetadata, FErrorMsg, FSuccess);
end;

procedure TMapLibDownloadJob.Execute;
{$IFDEF FPC}
{$IFDEF MSWINDOWS}
var
  TempFilePath: string;
  FinalFileName: string;
  FinalFilePath: string;
  FileExt: string;
  FileStream: TFileStream;
  fileSizeStream: TFileStream;
  sessionHandle: HINTERNET;
  urlHandle: HINTERNET;
  optionValue: DWORD;
  headerText: string;
  requestFlags: DWORD;
  readBuffer: array[0..16383] of Byte;
  bytesRead: DWORD;
  totalBytes: Int64;
  totalDone: Int64;
  statusCode: Integer;
  statusCodeSize: DWORD;
  statusCodeIndex: DWORD;
{$ELSE}
var
  Client: TFPHTTPClient;
  TempFilePath: string;
  FinalFileName: string;
  FinalFilePath: string;
  FileExt: string;
  FileStream: TFileStream;
  fileSizeStream: TFileStream;
{$ENDIF}
{$ELSE}
var
  Client: THTTPClient;
  TempFilePath: string;
  FinalFileName: string;
  FinalFilePath: string;
  FileExt: string;
  FileStream: TFileStream;
  Response: IHTTPResponse;
{$ENDIF}
begin
  FSuccess := False;
  FErrorMsg := '';

  if (FStorageBasePath = '') or (not DirectoryExists(FStorageBasePath)) then
  begin
    FErrorMsg := 'Base storage path does not exist.';
{$IFDEF FPC}
    TThread.Queue(Self, @SyncCompleted);
{$ELSE}
    TThread.Queue(Self, SyncCompleted);
{$ENDIF}
    Exit;
  end;

  FileExt := LowerCase(ExtractFileExt(FRequest.SourceUrl));
  if FileExt = '' then
    FileExt := '.mbtiles';

  TempFilePath := CombinePath(FStorageBasePath, FRequest.RegionId + '.tmp');
  FinalFileName := FRequest.RegionId + FileExt;
  FinalFilePath := CombinePath(FStorageBasePath, FinalFileName);

{$IFDEF FPC}
{$IFDEF MSWINDOWS}
  sessionHandle := nil;
  urlHandle := nil;
{$ELSE}
  Client := TFPHTTPClient.Create(nil);
{$ENDIF}
{$ELSE}
  Client := THTTPClient.Create;
{$ENDIF}
  try
{$IFDEF FPC}
{$IFNDEF MSWINDOWS}
    Client.AllowRedirect := True;
    Client.OnDataReceived := @DoReceiveData;
{$ENDIF}
{$ELSE}
    Client.OnReceiveData := DoReceiveData;
{$ENDIF}

    try
      if FileExists(TempFilePath) then
{$IFDEF FPC}
        SysUtils.DeleteFile(TempFilePath);
{$ELSE}
        TFile.Delete(TempFilePath);
{$ENDIF}

      FileStream := TFileStream.Create(TempFilePath, fmCreate);
      try
{$IFDEF FPC}
{$IFDEF MSWINDOWS}
        sessionHandle := InternetOpen('GMLib/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
        if sessionHandle = nil then
          raise Exception.Create('InternetOpen failed: ' + SysErrorMessage(GetLastError));

        optionValue := 15000;
        InternetSetOption(sessionHandle, INTERNET_OPTION_CONNECT_TIMEOUT, @optionValue, SizeOf(optionValue));
        optionValue := 30000;
        InternetSetOption(sessionHandle, INTERNET_OPTION_RECEIVE_TIMEOUT, @optionValue, SizeOf(optionValue));
        InternetSetOption(sessionHandle, INTERNET_OPTION_SEND_TIMEOUT, @optionValue, SizeOf(optionValue));

        headerText := 'Accept-Encoding: identity' + #13#10;
        requestFlags := INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_PRAGMA_NOCACHE;
        if Pos('https://', LowerCase(FRequest.SourceUrl)) = 1 then
          requestFlags := requestFlags or INTERNET_FLAG_SECURE;

        urlHandle := InternetOpenUrl(sessionHandle, PChar(FRequest.SourceUrl), PChar(headerText),
          Length(headerText), requestFlags, 0);
        if urlHandle = nil then
          raise Exception.Create('InternetOpenUrl failed: ' + SysErrorMessage(GetLastError));

        totalBytes := 0;
        QueryHeaderInteger(urlHandle, HTTP_QUERY_CONTENT_LENGTH, totalBytes);

        statusCode := 0;
        statusCodeSize := SizeOf(statusCode);
        statusCodeIndex := 0;
        if not HttpQueryInfo(urlHandle, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER,
          @statusCode, statusCodeSize, statusCodeIndex) then
          statusCode := 0;

        totalDone := 0;
        repeat
          bytesRead := 0;
          if not InternetReadFile(urlHandle, @readBuffer[0], SizeOf(readBuffer), bytesRead) then
            raise Exception.Create('InternetReadFile failed: ' + SysErrorMessage(GetLastError));
          if bytesRead > 0 then
          begin
            FileStream.WriteBuffer(readBuffer[0], bytesRead);
            Inc(totalDone, bytesRead);
            FSyncBytesDone := totalDone;
            FSyncBytesTotal := totalBytes;
            if totalBytes > 0 then
              FSyncPercent := (totalDone / totalBytes) * 100
            else
              FSyncPercent := 0;
            TThread.Queue(Self, @SyncProgress);
            if Terminated then
              Break;
          end;
        until bytesRead = 0;

        FSuccess := (statusCode = 200) or (statusCode = 206);
        if not FSuccess then
          FErrorMsg := Format('HTTP Error %d', [statusCode]);
{$ELSE}
        Client.Get(FRequest.SourceUrl, FileStream);
        FSuccess := (Client.ResponseStatusCode = 200) or
          (Client.ResponseStatusCode = 206);
        if not FSuccess then
          FErrorMsg := Format('HTTP Error %d: %s',
            [Client.ResponseStatusCode, Client.ResponseStatusText]);
{$ENDIF}
{$ELSE}
        Response := Client.Get(FRequest.SourceUrl, FileStream);
        FSuccess := (Response.StatusCode = 200) or (Response.StatusCode = 206);
        if not FSuccess then
          FErrorMsg := Format('HTTP Error %d: %s', [Response.StatusCode, Response.StatusText]);
{$ENDIF}
      finally
{$IFDEF FPC}
{$IFDEF MSWINDOWS}
        if urlHandle <> nil then
        begin
          InternetCloseHandle(urlHandle);
          urlHandle := nil;
        end;
        if sessionHandle <> nil then
        begin
          InternetCloseHandle(sessionHandle);
          sessionHandle := nil;
        end;
{$ENDIF}
{$ENDIF}
        FileStream.Free;
      end;

      if FSuccess and Terminated then
      begin
        FSuccess := False;
        FErrorMsg := 'Download cancelled.';
        if FileExists(TempFilePath) then
{$IFDEF FPC}
          SysUtils.DeleteFile(TempFilePath);
{$ELSE}
          TFile.Delete(TempFilePath);
{$ENDIF}
      end;

      if FSuccess then
      begin
        if FileExists(FinalFilePath) then
{$IFDEF FPC}
          SysUtils.DeleteFile(FinalFilePath);

        if not RenameFile(TempFilePath, FinalFilePath) then
          raise Exception.CreateFmt('Could not rename "%s" to "%s".',
            [TempFilePath, FinalFilePath]);
{$ELSE}
          TFile.Delete(FinalFilePath);

        TFile.Move(TempFilePath, FinalFilePath);
{$ENDIF}

        FResultMetadata.RegionId := FRequest.RegionId;
        FResultMetadata.MinZoom := FRequest.MinZoom;
        FResultMetadata.MaxZoom := FRequest.MaxZoom;
        FResultMetadata.Bounds := FRequest.Bounds;
        FResultMetadata.CreatedAtUtc := Now;
        FResultMetadata.UpdatedAtUtc := Now;
        FResultMetadata.DataVersion := FRequest.DataVersion;
{$IFDEF FPC}
        fileSizeStream := TFileStream.Create(FinalFilePath, fmOpenRead or fmShareDenyNone);
        try
          FResultMetadata.SizeBytes := fileSizeStream.Size;
        finally
          fileSizeStream.Free;
        end;
{$ELSE}
        FResultMetadata.SizeBytes := TFile.GetSize(FinalFilePath);
{$ENDIF}
        FResultMetadata.Checksum := '';
        FResultMetadata.StoragePath := FinalFileName;
      end;

    except
      on E: Exception do
      begin
        FSuccess := False;
        FErrorMsg := E.Message;
        if FileExists(TempFilePath) then
        begin
          try
{$IFDEF FPC}
            SysUtils.DeleteFile(TempFilePath);
{$ELSE}
            TFile.Delete(TempFilePath);
{$ENDIF}
          except
          end;
        end;
      end;
    end;

  finally
{$IFDEF FPC}
{$IFNDEF MSWINDOWS}
    Client.Free;
{$ENDIF}
{$ELSE}
    Client.Free;
{$ENDIF}
  end;

{$IFDEF FPC}
  TThread.Queue(Self, @SyncCompleted);
{$ELSE}
  TThread.Queue(Self, SyncCompleted);
{$ENDIF}
end;

end.
