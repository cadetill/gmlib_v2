{**
  @abstract(Gestor real del catálogo de regiones offline de MapLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
}
unit uMapLib.Offline.RegionManager;

{$I ..\..\gmlib.inc}

interface

uses
  System.Generics.Collections,
  uMapLib.Offline.RegionCatalog,
  uMapLib.Offline.Types,
  uMapLib.Offline.Downloader;

type
  IMapLibOfflineRegionManager = interface(IMapLibOfflineCatalog)
    ['{A9E6F87A-DC3B-479A-A7A8-A4B2640B10D0}']
    function DownloadRegion(const ARequest: TMapLibOfflineDownloadRequest): string;
    function CancelDownload(const AJobId: string): Boolean;
    function ResolveCoverage(ALat, ALng: Double; AZoom: Double): TMapLibOfflineCoverage;

    // Métodos para suscripción de eventos desde el componente TOSMMap
    procedure SetOnDownloadProgress(const AValue: TMapLibOfflineDownloadProgressEvent);
    procedure SetOnRegionReady(const AValue: TMapLibOfflineRegionReadyEvent);
    procedure SetOnOfflineError(const AValue: TMapLibOfflineErrorEvent);
    function GetOnDownloadProgress: TMapLibOfflineDownloadProgressEvent;
    function GetOnRegionReady: TMapLibOfflineRegionReadyEvent;
    function GetOnOfflineError: TMapLibOfflineErrorEvent;

    property OnDownloadProgress: TMapLibOfflineDownloadProgressEvent read GetOnDownloadProgress write SetOnDownloadProgress;
    property OnRegionReady: TMapLibOfflineRegionReadyEvent read GetOnRegionReady write SetOnRegionReady;
    property OnOfflineError: TMapLibOfflineErrorEvent read GetOnOfflineError write SetOnOfflineError;
  end;

  TMapLibOfflineRegionManager = class(TInterfacedObject, IMapLibOfflineRegionManager)
  private
    FStorageBasePath: string;
    FActiveRegion: TMapLibOfflineRegionId;
    FDownloadJobs: TDictionary<string, TMapLibDownloadJob>;

    // Eventos públicos
    FOnDownloadProgress: TMapLibOfflineDownloadProgressEvent;
    FOnRegionReady: TMapLibOfflineRegionReadyEvent;
    FOnOfflineError: TMapLibOfflineErrorEvent;

    function GetCatalogFileName: string;
    function ResolveAbsoluteStoragePath(const APath: string): string;

    // Callbacks internos del hilo descargador
    procedure HandleDownloadProgress(Sender: TMapLibDownloadJob; ABytesDone, ABytesTotal: Int64; APercent: Double);
    procedure HandleDownloadCompleted(Sender: TMapLibDownloadJob; const AMetadata: TMapLibOfflineRegionMetadata; const AErrorMsg: string; ASuccess: Boolean);
  public
    constructor Create(const AStorageBasePath: string = '');
    destructor Destroy; override;

    // IMapLibOfflineCatalog
    function ListRegions: TArray<TMapLibOfflineRegionMetadata>;
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

    property StorageBasePath: string read FStorageBasePath write FStorageBasePath;
  end;

implementation

uses
{$IFDEF FPC}
  Classes, SysUtils,
{$ELSE}
  System.Classes, System.SysUtils, System.IOUtils,
{$ENDIF}
  uMapLib.Offline.Storage;

{ TMapLibOfflineRegionManager }

constructor TMapLibOfflineRegionManager.Create(const AStorageBasePath: string);
begin
  inherited Create;
  FStorageBasePath := AStorageBasePath;
  FActiveRegion := '';
  FDownloadJobs := TDictionary<string, TMapLibDownloadJob>.Create;
  FOnDownloadProgress := nil;
  FOnRegionReady := nil;
  FOnOfflineError := nil;
end;

destructor TMapLibOfflineRegionManager.Destroy;
var
  Job: TMapLibDownloadJob;
begin
  // Detener y liberar hilos activos para evitar fugas de memoria o fallos de ejecución
  for Job in FDownloadJobs.Values do
  begin
    Job.Terminate;
    Job.WaitFor;
    Job.Free;
  end;
  FDownloadJobs.Free;
  inherited;
end;

function TMapLibOfflineRegionManager.GetCatalogFileName: string;
begin
  if FStorageBasePath = '' then
    Result := ''
  else
    Result := TPath.Combine(FStorageBasePath, 'regions.json');
end;

function TMapLibOfflineRegionManager.ResolveAbsoluteStoragePath(const APath: string): string;
begin
  if TPath.IsPathRooted(APath) or (FStorageBasePath = '') then
    Result := APath
  else
    Result := TPath.Combine(FStorageBasePath, APath);
end;

function TMapLibOfflineRegionManager.ListRegions: TArray<TMapLibOfflineRegionMetadata>;
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
  Regions: TArray<TMapLibOfflineRegionMetadata>;
  NewRegions: TArray<TMapLibOfflineRegionMetadata>;
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
        TFile.Delete(TargetFile);
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
  Regions: TArray<TMapLibOfflineRegionMetadata>;
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
          Result.UsedBytes := Result.UsedBytes + TFile.GetSize(TargetFile);
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
  if FDownloadJobs.ContainsKey(ARequest.RegionId) then
    Exit;

  // Usamos el ID de la región como identificador del trabajo
  JobId := ARequest.RegionId;

  // Creamos el directorio base si no existe
  if (FStorageBasePath <> '') and not DirectoryExists(FStorageBasePath) then
    TDirectory.CreateDirectory(FStorageBasePath);

  Job := TMapLibDownloadJob.Create(
    JobId,
    ARequest,
    FStorageBasePath,
    HandleDownloadProgress,
    HandleDownloadCompleted
  );

  FDownloadJobs.Add(JobId, Job);
  Job.Start;
  Result := JobId;
end;

function TMapLibOfflineRegionManager.CancelDownload(const AJobId: string): Boolean;
var
  Job: TMapLibDownloadJob;
begin
  Result := False;
  if FDownloadJobs.TryGetValue(AJobId, Job) then
  begin
    Job.Terminate;
    Result := True;
  end;
end;

function TMapLibOfflineRegionManager.ResolveCoverage(ALat, ALng: Double;
  AZoom: Double): TMapLibOfflineCoverage;
var
  Regions: TArray<TMapLibOfflineRegionMetadata>;
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
  Regions: TArray<TMapLibOfflineRegionMetadata>;
  NewList: TArray<TMapLibOfflineRegionMetadata>;
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
    FDownloadJobs.Remove(Sender.JobId);
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

end.
