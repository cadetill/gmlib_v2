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
  fphttpclient,
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
var
  Client: TFPHTTPClient;
  TempFilePath: string;
  FinalFileName: string;
  FinalFilePath: string;
  FileExt: string;
  FileStream: TFileStream;
  fileSizeStream: TFileStream;
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
  Client := TFPHTTPClient.Create(nil);
{$ELSE}
  Client := THTTPClient.Create;
{$ENDIF}
  try
{$IFDEF FPC}
    Client.AllowRedirect := True;
    Client.OnDataReceived := @DoReceiveData;
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
        Client.Get(FRequest.SourceUrl, FileStream);
        FSuccess := (Client.ResponseStatusCode = 200) or
          (Client.ResponseStatusCode = 206);
        if not FSuccess then
          FErrorMsg := Format('HTTP Error %d: %s',
            [Client.ResponseStatusCode, Client.ResponseStatusText]);
{$ELSE}
        Response := Client.Get(FRequest.SourceUrl, FileStream);
        FSuccess := (Response.StatusCode = 200) or (Response.StatusCode = 206);
        if not FSuccess then
          FErrorMsg := Format('HTTP Error %d: %s', [Response.StatusCode, Response.StatusText]);
{$ENDIF}
      finally
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
    Client.Free;
  end;

{$IFDEF FPC}
  TThread.Queue(Self, @SyncCompleted);
{$ELSE}
  TThread.Queue(Self, SyncCompleted);
{$ENDIF}
end;

end.
