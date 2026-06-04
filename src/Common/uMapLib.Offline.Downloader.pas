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
{$IFNDEF FPC}
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

{$IFNDEF FPC}
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
begin
  FSuccess := False;
  FErrorMsg := 'Offline downloader is not implemented for FPC in this milestone.';
  TThread.Queue(Self, @SyncCompleted);
end;
{$ELSE}
var
  Client: THTTPClient;
  TempFilePath: string;
  FinalFileName: string;
  FinalFilePath: string;
  FileExt: string;
  FileStream: TFileStream;
  Response: IHTTPResponse;
begin
  FSuccess := False;
  FErrorMsg := '';

  if (FStorageBasePath = '') or (not DirectoryExists(FStorageBasePath)) then
  begin
    FErrorMsg := 'Base storage path does not exist.';
    TThread.Queue(Self, SyncCompleted);
    Exit;
  end;

  FileExt := LowerCase(ExtractFileExt(FRequest.SourceUrl));
  if FileExt = '' then
    FileExt := '.mbtiles';

  TempFilePath := CombinePath(FStorageBasePath, FRequest.RegionId + '.tmp');
  FinalFileName := FRequest.RegionId + FileExt;
  FinalFilePath := CombinePath(FStorageBasePath, FinalFileName);

  Client := THTTPClient.Create;
  try
    Client.OnReceiveData := DoReceiveData;

    try
      if FileExists(TempFilePath) then
        TFile.Delete(TempFilePath);

      FileStream := TFileStream.Create(TempFilePath, fmCreate);
      try
        Response := Client.Get(FRequest.SourceUrl, FileStream);
        FSuccess := (Response.StatusCode = 200) or (Response.StatusCode = 206);
        if not FSuccess then
          FErrorMsg := Format('HTTP Error %d: %s', [Response.StatusCode, Response.StatusText]);
      finally
        FileStream.Free;
      end;

      if FSuccess and Terminated then
      begin
        FSuccess := False;
        FErrorMsg := 'Download cancelled.';
        if FileExists(TempFilePath) then
          TFile.Delete(TempFilePath);
      end;

      if FSuccess then
      begin
        if FileExists(FinalFilePath) then
          TFile.Delete(FinalFilePath);

        TFile.Move(TempFilePath, FinalFilePath);

        FResultMetadata.RegionId := FRequest.RegionId;
        FResultMetadata.MinZoom := FRequest.MinZoom;
        FResultMetadata.MaxZoom := FRequest.MaxZoom;
        FResultMetadata.Bounds := FRequest.Bounds;
        FResultMetadata.CreatedAtUtc := Now;
        FResultMetadata.UpdatedAtUtc := Now;
        FResultMetadata.DataVersion := FRequest.DataVersion;
        FResultMetadata.SizeBytes := TFile.GetSize(FinalFilePath);
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
            TFile.Delete(TempFilePath);
          except
          end;
        end;
      end;
    end;

  finally
    Client.Free;
  end;

  TThread.Queue(Self, SyncCompleted);
end;
{$ENDIF}

end.
