{**
  @abstract(Descargador de regiones en segundo plano para MapLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
}
unit uMapLib.Offline.Downloader;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Net.HttpClient,
  System.IOUtils,
  uMapLib.Offline.Types;

type
  TMapLibDownloadJob = class;

  {** @abstract(Evento disparado para reportar el progreso del hilo al hilo principal.) }
  TMapLibDownloadProgressEvent = procedure(Sender: TMapLibDownloadJob;
    ABytesDone, ABytesTotal: Int64; APercent: Double) of object;

  {** @abstract(Evento disparado para notificar el fin del trabajo.) }
  TMapLibDownloadCompletedEvent = procedure(Sender: TMapLibDownloadJob;
    const AMetadata: TMapLibOfflineRegionMetadata; const AErrorMsg: string; ASuccess: Boolean) of object;

  {** @abstract(Hilo de segundo plano para la descarga asíncrona de archivos de mapa.) }
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

    // Variables locales para sincronización
    FSyncBytesDone: Int64;
    FSyncBytesTotal: Int64;
    FSyncPercent: Double;

    procedure DoReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
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

{ TMapLibDownloadJob }

constructor TMapLibDownloadJob.Create(const AJobId: string;
  const ARequest: TMapLibOfflineDownloadRequest; const AStorageBasePath: string;
  AOnProgress: TMapLibDownloadProgressEvent; AOnCompleted: TMapLibDownloadCompletedEvent);
begin
  // Creamos el hilo suspendido para poder configurar de forma segura sus propiedades
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

  // Encolamos el progreso en el hilo principal para no bloquear la descarga
  TThread.Queue(Self, SyncProgress);
end;

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
    FileExt := '.mbtiles'; // MBTiles por defecto si no hay extensión

  TempFilePath := TPath.Combine(FStorageBasePath, FRequest.RegionId + '.tmp');
  FinalFileName := FRequest.RegionId + FileExt;
  FinalFilePath := TPath.Combine(FStorageBasePath, FinalFileName);

  Client := THTTPClient.Create;
  try
    Client.OnReceiveData := DoReceiveData;

    try
      // Borramos el archivo temporal si ya existiera
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

      if FSuccess then
      begin
        if Terminated then
        begin
          FSuccess := False;
          FErrorMsg := 'Download cancelled.';
          if FileExists(TempFilePath) then
            TFile.Delete(TempFilePath);
        end;
      end;

      if FSuccess then
      begin
        // Borramos el archivo definitivo previo si ya existiera (Sobrescritura atómica)
        if FileExists(FinalFilePath) then
          TFile.Delete(FinalFilePath);

        TFile.Move(TempFilePath, FinalFilePath);

        // Poblamos la metadata resultante de la descarga con fecha local
        FResultMetadata.RegionId := FRequest.RegionId;
        FResultMetadata.MinZoom := FRequest.MinZoom;
        FResultMetadata.MaxZoom := FRequest.MaxZoom;
        FResultMetadata.Bounds := FRequest.Bounds;
        FResultMetadata.CreatedAtUtc := Now;
        FResultMetadata.UpdatedAtUtc := Now;
        FResultMetadata.DataVersion := FRequest.DataVersion;
        FResultMetadata.SizeBytes := TFile.GetSize(FinalFilePath);
        FResultMetadata.Checksum := ''; // En futuros hitos calcularemos un MD5 hash
        FResultMetadata.StoragePath := FinalFileName; // Guardamos la ruta relativa
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
            // ignore
          end;
        end;
      end;
    end;

  finally
    Client.Free;
  end;

  // Sincronizamos la finalización en el hilo principal
  TThread.Queue(Self, SyncCompleted);
end;

end.
