{**
  @abstract(Gestor real del catálogo de regiones offline de MapLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
}
unit uMapLib.Offline.RegionManager;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
{$ELSE}
  System.Generics.Collections,
{$ENDIF}
  uMapLib.Offline.RegionCatalog,
  uMapLib.Offline.Types,
  uMapLib.Offline.Downloader;

type
  {** @abstract(Contrato de alto nivel para gestionar regiones offline.) }
  IMapLibOfflineRegionManager = interface(IMapLibOfflineCatalog)
    ['{A9E6F87A-DC3B-479A-A7A8-A4B2640B10D0}']
    {** @abstract(Inicia la descarga de una region offline.) }
    function DownloadRegion(const ARequest: TMapLibOfflineDownloadRequest): string;
    {** @abstract(Cancela una descarga activa si el trabajo existe.) }
    function CancelDownload(const AJobId: string): Boolean;
    {** @abstract(Resuelve la cobertura offline para una posicion y zoom.) }
    function ResolveCoverage(ALat, ALng: Double; AZoom: Double): TMapLibOfflineCoverage;

    // Métodos para suscripción de eventos desde el componente TOSMMap
    procedure SetOnDownloadProgress(const AValue: TMapLibOfflineDownloadProgressEvent);
    procedure SetOnRegionReady(const AValue: TMapLibOfflineRegionReadyEvent);
    procedure SetOnOfflineError(const AValue: TMapLibOfflineErrorEvent);
    function GetOnDownloadProgress: TMapLibOfflineDownloadProgressEvent;
    function GetOnRegionReady: TMapLibOfflineRegionReadyEvent;
    function GetOnOfflineError: TMapLibOfflineErrorEvent;
    procedure SetStorageBasePath(const AValue: string);

    property OnDownloadProgress: TMapLibOfflineDownloadProgressEvent read GetOnDownloadProgress write SetOnDownloadProgress;
    property OnRegionReady: TMapLibOfflineRegionReadyEvent read GetOnRegionReady write SetOnRegionReady;
    property OnOfflineError: TMapLibOfflineErrorEvent read GetOnOfflineError write SetOnOfflineError;
    property StorageBasePath: string write SetStorageBasePath;
  end;

  {** @abstract(Implementacion concreta del gestor de regiones offline.) }
  TMapLibOfflineRegionManager = class(TInterfacedObject, IMapLibOfflineRegionManager)
  private
    FStorageBasePath: string;
    FActiveRegion: TMapLibOfflineRegionId;
{$IFDEF FPC}
    FDownloadJobs: TStringList;
{$ELSE}
    FDownloadJobs: TDictionary<string, TMapLibDownloadJob>;
{$ENDIF}

    // Eventos públicos
    FOnDownloadProgress: TMapLibOfflineDownloadProgressEvent;
    FOnRegionReady: TMapLibOfflineRegionReadyEvent;
    FOnOfflineError: TMapLibOfflineErrorEvent;

    function GetCatalogFileName: string;
    function ResolveAbsoluteStoragePath(const APath: string): string;
    function HasDownloadJob(const AJobId: string): Boolean;
    function TryGetDownloadJob(const AJobId: string; out AJob: TMapLibDownloadJob): Boolean;
    procedure AddDownloadJob(const AJobId: string; AJob: TMapLibDownloadJob);
    procedure RemoveDownloadJob(const AJobId: string);

    // Callbacks internos del hilo descargador
    procedure HandleDownloadProgress(Sender: TMapLibDownloadJob; ABytesDone, ABytesTotal: Int64; APercent: Double);
    procedure HandleDownloadCompleted(Sender: TMapLibDownloadJob; const AMetadata: TMapLibOfflineRegionMetadata; const AErrorMsg: string; ASuccess: Boolean);
  public
    constructor Create(const AStorageBasePath: string = '');
    destructor Destroy; override;

    // IMapLibOfflineCatalog
    function ListRegions: TMapLibOfflineRegionMetadataArray;
    function DeleteRegion(const ARegionId: TMapLibOfflineRegionId): Boolean;
    function GetStorageUsage: TMapLibOfflineStorageUsage;
    procedure SetActiveRegion(const ARegionId: TMapLibOfflineRegionId);
    function GetActiveRegionId: TMapLibOfflineRegionId;

    // IMapLibOfflineRegionManager
    function DownloadRegion(const ARequest: TMapLibOfflineDownloadRequest): string;
    function CancelDownload(const AJobId: string): Boolean;
    function ResolveCoverage(ALat, ALng: Double; AZoom: Double): TMapLibOfflineCoverage;

    // Eventos de interfaz getters y setters
    procedure SetOnDownloadProgress(const AValue: TMapLibOfflineDownloadProgressEvent);
    procedure SetOnRegionReady(const AValue: TMapLibOfflineRegionReadyEvent);
    procedure SetOnOfflineError(const AValue: TMapLibOfflineErrorEvent);
    function GetOnDownloadProgress: TMapLibOfflineDownloadProgressEvent;
    function GetOnRegionReady: TMapLibOfflineRegionReadyEvent;
    function GetOnOfflineError: TMapLibOfflineErrorEvent;
    procedure SetStorageBasePath(const AValue: string);

    property StorageBasePath: string read FStorageBasePath write FStorageBasePath;
  end;

implementation

uses
{$IFDEF FPC}
  SysUtils,
{$ELSE}
  System.Classes, System.SysUtils, System.IOUtils,
{$ENDIF}
  uMapLib.Offline.Storage;

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

function IsAbsolutePath(const APath: string): Boolean;
begin
{$IFDEF FPC}
  Result := (ExtractFileDrive(APath) <> '') or
    ((Length(APath) >= 2) and (APath[1] = PathDelim) and (APath[2] = PathDelim));
{$ELSE}
  Result := TPath.IsPathRooted(APath);
{$ENDIF}
end;

function DeleteFileSafe(const AFileName: string): Boolean;
begin
{$IFDEF FPC}
  Result := SysUtils.DeleteFile(AFileName);
{$ELSE}
  TFile.Delete(AFileName);
  Result := True;
{$ENDIF}
end;

function GetFileSizeSafe(const AFileName: string): Int64;
{$IFDEF FPC}
var
  fileStream: TFileStream;
{$ENDIF}
begin
{$IFDEF FPC}
  fileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := fileStream.Size;
  finally
    fileStream.Free;
  end;
{$ELSE}
  Result := TFile.GetSize(AFileName);
{$ENDIF}
end;

{ TMapLibOfflineRegionManager }

constructor TMapLibOfflineRegionManager.Create(const AStorageBasePath: string);
begin
  inherited Create;
  FStorageBasePath := AStorageBasePath;
  FActiveRegion := '';
{$IFDEF FPC}
  FDownloadJobs := TStringList.Create;
  FDownloadJobs.CaseSensitive := False;
{$ELSE}
  FDownloadJobs := TDictionary<string, TMapLibDownloadJob>.Create;
{$ENDIF}
  FOnDownloadProgress := nil;
  FOnRegionReady := nil;
  FOnOfflineError := nil;
end;

destructor TMapLibOfflineRegionManager.Destroy;
var
{$IFDEF FPC}
  I: Integer;
{$ELSE}
  Job: TMapLibDownloadJob;
{$ENDIF}
begin
  // Detener y liberar hilos activos para evitar fugas de memoria o fallos de ejecución
{$IFDEF FPC}
  for I := 0 to FDownloadJobs.Count - 1 do
  begin
    TMapLibDownloadJob(FDownloadJobs.Objects[I]).Terminate;
    TMapLibDownloadJob(FDownloadJobs.Objects[I]).WaitFor;
    TMapLibDownloadJob(FDownloadJobs.Objects[I]).Free;
  end;
{$ELSE}
  for Job in FDownloadJobs.Values do
  begin
    Job.Terminate;
    Job.WaitFor;
    Job.Free;
  end;
{$ENDIF}
  FDownloadJobs.Free;
  inherited;
end;

function TMapLibOfflineRegionManager.GetCatalogFileName: string;
begin
  if FStorageBasePath = '' then
    Result := ''
  else
    Result := CombinePath(FStorageBasePath, 'regions.json');
end;

function TMapLibOfflineRegionManager.ResolveAbsoluteStoragePath(const APath: string): string;
begin
  if IsAbsolutePath(APath) or (FStorageBasePath = '') then
    Result := APath
  else
    Result := CombinePath(FStorageBasePath, APath);
end;

function TMapLibOfflineRegionManager.HasDownloadJob(const AJobId: string): Boolean;
begin
{$IFDEF FPC}
  Result := FDownloadJobs.IndexOf(AJobId) >= 0;
{$ELSE}
  Result := FDownloadJobs.ContainsKey(AJobId);
{$ENDIF}
end;

function TMapLibOfflineRegionManager.TryGetDownloadJob(const AJobId: string;
  out AJob: TMapLibDownloadJob): Boolean;
{$IFDEF FPC}
var
  index: Integer;
{$ENDIF}
begin
{$IFDEF FPC}
  index := FDownloadJobs.IndexOf(AJobId);
  Result := index >= 0;
  if Result then
    AJob := TMapLibDownloadJob(FDownloadJobs.Objects[index])
  else
    AJob := nil;
{$ELSE}
  Result := FDownloadJobs.TryGetValue(AJobId, AJob);
{$ENDIF}
end;

procedure TMapLibOfflineRegionManager.AddDownloadJob(const AJobId: string;
  AJob: TMapLibDownloadJob);
begin
{$IFDEF FPC}
  FDownloadJobs.AddObject(AJobId, AJob);
{$ELSE}
  FDownloadJobs.Add(AJobId, AJob);
{$ENDIF}
end;

procedure TMapLibOfflineRegionManager.RemoveDownloadJob(const AJobId: string);
{$IFDEF FPC}
var
  index: Integer;
{$ENDIF}
begin
{$IFDEF FPC}
  index := FDownloadJobs.IndexOf(AJobId);
  if index >= 0 then
    FDownloadJobs.Delete(index);
{$ELSE}
  FDownloadJobs.Remove(AJobId);
{$ENDIF}
end;

function TMapLibOfflineRegionManager.ListRegions: TMapLibOfflineRegionMetadataArray;
var
  CatalogFile: string;
begin
  CatalogFile := GetCatalogFileName;
  if CatalogFile = '' then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  Result := TMapLibOfflineCatalogStorage.LoadFromFile(CatalogFile);
end;

function TMapLibOfflineRegionManager.DeleteRegion(
  const ARegionId: TMapLibOfflineRegionId): Boolean;
var
  Regions: TMapLibOfflineRegionMetadataArray;
  NewRegions: TMapLibOfflineRegionMetadataArray;
  I, idx: Integer;
  TargetFile: string;
begin
  Result := False;
  Regions := ListRegions;
  if Length(Regions) = 0 then
    Exit;

  idx := -1;
  for I := Low(Regions) to High(Regions) do
  begin
    if SameText(Regions[I].RegionId, ARegionId) then
    begin
      idx := I;
      Break;
    end;
  end;

  if idx < 0 then
    Exit;

  // Intentamos borrar el archivo físico si está especificado y no hay descarga activa
  if Regions[idx].StoragePath <> '' then
  begin
    TargetFile := ResolveAbsoluteStoragePath(Regions[idx].StoragePath);
    if FileExists(TargetFile) then
    begin
        try
          DeleteFileSafe(TargetFile);
        except
          // Continuamos borrando del catálogo aunque falle la eliminación física parcial
        end;
    end;
  end;

  // Reconstruimos el array de regiones omitiendo la eliminada
  SetLength(NewRegions, Length(Regions) - 1);
  idx := 0;
  for I := Low(Regions) to High(Regions) do
  begin
    if not SameText(Regions[I].RegionId, ARegionId) then
    begin
      NewRegions[idx] := Regions[I];
      Inc(idx);
    end;
  end;

  // Guardamos el catálogo actualizado
  TMapLibOfflineCatalogStorage.SaveToFile(GetCatalogFileName, NewRegions);
  Result := True;
end;

function TMapLibOfflineRegionManager.GetStorageUsage: TMapLibOfflineStorageUsage;
var
  Regions: TMapLibOfflineRegionMetadataArray;
  I: Integer;
  TargetFile: string;
begin
  Result.UsedBytes := 0;
  Result.AvailableBytes := Int64(1024) * 1024 * 1024 * 100; // 100 GB simulado por defecto en DCC32/LCL

  Regions := ListRegions;
  for I := Low(Regions) to High(Regions) do
  begin
    if Regions[I].StoragePath <> '' then
    begin
      TargetFile := ResolveAbsoluteStoragePath(Regions[I].StoragePath);
      if FileExists(TargetFile) then
      begin
        try
          Result.UsedBytes := Result.UsedBytes + GetFileSizeSafe(TargetFile);
        except
          Result.UsedBytes := Result.UsedBytes + Regions[I].SizeBytes;
        end;
      end
      else
        Result.UsedBytes := Result.UsedBytes + Regions[I].SizeBytes;
    end
    else
      Result.UsedBytes := Result.UsedBytes + Regions[I].SizeBytes;
  end;
end;

procedure TMapLibOfflineRegionManager.SetActiveRegion(
  const ARegionId: TMapLibOfflineRegionId);
begin
  FActiveRegion := ARegionId;
end;

function TMapLibOfflineRegionManager.GetActiveRegionId: TMapLibOfflineRegionId;
begin
  Result := FActiveRegion;
end;

function TMapLibOfflineRegionManager.DownloadRegion(
  const ARequest: TMapLibOfflineDownloadRequest): string;
var
  JobId: string;
  Job: TMapLibDownloadJob;
begin
  Result := '';
  if ARequest.RegionId = '' then
    Exit;

  // Validamos si ya existe una descarga activa para esta región
  if HasDownloadJob(ARequest.RegionId) then
    Exit;

  // Usamos el ID de la región como identificador del trabajo
  JobId := ARequest.RegionId;

  // Creamos el directorio base si no existe
  if (FStorageBasePath <> '') and not DirectoryExists(FStorageBasePath) then
{$IFDEF FPC}
    ForceDirectories(FStorageBasePath);
{$ELSE}
    TDirectory.CreateDirectory(FStorageBasePath);
{$ENDIF}

  Job := TMapLibDownloadJob.Create(
    JobId,
    ARequest,
    FStorageBasePath,
{$IFDEF FPC}
    @HandleDownloadProgress,
    @HandleDownloadCompleted
{$ELSE}
    HandleDownloadProgress,
    HandleDownloadCompleted
{$ENDIF}
  );

  AddDownloadJob(JobId, Job);
  Job.Start;
  Result := JobId;
end;

function TMapLibOfflineRegionManager.CancelDownload(const AJobId: string): Boolean;
var
  Job: TMapLibDownloadJob;
begin
  Result := False;
  if TryGetDownloadJob(AJobId, Job) then
  begin
    Job.Terminate;
    Result := True;
  end;
end;

function TMapLibOfflineRegionManager.ResolveCoverage(ALat, ALng: Double;
  AZoom: Double): TMapLibOfflineCoverage;
var
  Regions: TMapLibOfflineRegionMetadataArray;
  I: Integer;
  InZoom, InBounds: Boolean;
begin
  Result.State := ocsUncovered;
  Result.RegionId := '';

  Regions := ListRegions;
  for I := Low(Regions) to High(Regions) do
  begin
    InZoom := (AZoom >= Regions[I].MinZoom) and (AZoom <= Regions[I].MaxZoom);
    InBounds := (ALat <= Regions[I].Bounds.North) and (ALat >= Regions[I].Bounds.South) and
                (ALng <= Regions[I].Bounds.East) and (ALng >= Regions[I].Bounds.West);

    if InZoom and InBounds then
    begin
      Result.State := ocsCovered;
      Result.RegionId := Regions[I].RegionId;
      Exit;
    end;
  end;
end;

procedure TMapLibOfflineRegionManager.HandleDownloadProgress(Sender: TMapLibDownloadJob;
  ABytesDone, ABytesTotal: Int64; APercent: Double);
begin
  if Assigned(FOnDownloadProgress) then
    FOnDownloadProgress(Self, Sender.JobId, APercent, ABytesDone, ABytesTotal);
end;

procedure TMapLibOfflineRegionManager.HandleDownloadCompleted(Sender: TMapLibDownloadJob;
  const AMetadata: TMapLibOfflineRegionMetadata; const AErrorMsg: string; ASuccess: Boolean);
var
  Regions: TMapLibOfflineRegionMetadataArray;
  NewList: TMapLibOfflineRegionMetadataArray;
  I: Integer;
  IsNew: Boolean;
begin
  try
    if ASuccess then
    begin
      Regions := ListRegions;
      IsNew := True;

      // Verificamos si la región ya existía para actualizarla
      for I := Low(Regions) to High(Regions) do
      begin
        if SameText(Regions[I].RegionId, AMetadata.RegionId) then
        begin
          Regions[I] := AMetadata;
          IsNew := False;
          Break;
        end;
      end;

      if IsNew then
      begin
        SetLength(NewList, Length(Regions) + 1);
        for I := Low(Regions) to High(Regions) do
          NewList[I] := Regions[I];
        NewList[High(NewList)] := AMetadata;
        Regions := NewList;
      end;

      // Guardamos la nueva lista en el catálogo
      TMapLibOfflineCatalogStorage.SaveToFile(GetCatalogFileName, Regions);

      if Assigned(FOnRegionReady) then
        FOnRegionReady(Self, AMetadata.RegionId);
    end
    else
    begin
      if Assigned(FOnOfflineError) then
        FOnOfflineError(Self, 400, 'Error downloading offline region.', AErrorMsg);
    end;

  finally
    // Removemos y liberamos el hilo
    RemoveDownloadJob(Sender.JobId);
    Sender.Free;
  end;
end;

procedure TMapLibOfflineRegionManager.SetOnDownloadProgress(
  const AValue: TMapLibOfflineDownloadProgressEvent);
begin
  FOnDownloadProgress := AValue;
end;

procedure TMapLibOfflineRegionManager.SetOnRegionReady(
  const AValue: TMapLibOfflineRegionReadyEvent);
begin
  FOnRegionReady := AValue;
end;

procedure TMapLibOfflineRegionManager.SetOnOfflineError(
  const AValue: TMapLibOfflineErrorEvent);
begin
  FOnOfflineError := AValue;
end;

function TMapLibOfflineRegionManager.GetOnDownloadProgress: TMapLibOfflineDownloadProgressEvent;
begin
  Result := FOnDownloadProgress;
end;

function TMapLibOfflineRegionManager.GetOnRegionReady: TMapLibOfflineRegionReadyEvent;
begin
  Result := FOnRegionReady;
end;

function TMapLibOfflineRegionManager.GetOnOfflineError: TMapLibOfflineErrorEvent;
begin
  Result := FOnOfflineError;
end;

procedure TMapLibOfflineRegionManager.SetStorageBasePath(const AValue: string);
begin
  FStorageBasePath := AValue;
end;

end.
