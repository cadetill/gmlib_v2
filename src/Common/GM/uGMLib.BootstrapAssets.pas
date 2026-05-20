{**
  @abstract(Helpers para extraer los recursos de bootstrap del mapa a un directorio temporal.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad centraliza el acceso a los recursos embebidos que componen el
  bootstrap HTML/JavaScript del mapa y los materializa en el directorio
  temporal de la plataforma cuando se necesitan.
}
unit uGMLib.BootstrapAssets;

{$I ..\..\..\gmlib.inc}

{$R ..\..\..\resources\GMLibBootstrap.res}

interface

uses
{$IFDEF FPC}
  Classes,
  SysUtils;
{$ELSE}
  System.Classes,
  System.IOUtils,
  System.SysUtils
  {$IFDEF MSWINDOWS},
  Winapi.Windows
  {$ENDIF};
{$ENDIF}

type
  {** @abstract(Helper para extraer los recursos del bootstrap a disco temporal.) }
  TGMLibBootstrapAssets = class
  private
    class function BuildTempBootstrapDir: string; static;
    class function FindResourceFile(const ARelativePath: string): string; static;
    class function LoadEmbeddedText(const AResourceName: string): string; static;
    class procedure SaveTextToFile(const AFileName, AText: string); static;
  public
    class function EnsureAssetFile(const ATargetFileName, AResourceName,
      ARelativePath: string): string; static;
    class function LoadTextFile(const AFileName: string): string; static;
    class function PathToFileUrl(const AFileName: string): string; static;
    class function ResolveResourceFile(const ARelativePath: string): string; static;
  end;

implementation

const
  cBootstrapResourceType = 'RCDATA';

class function TGMLibBootstrapAssets.BuildTempBootstrapDir: string;
begin
{$IFDEF FPC}
  Result := IncludeTrailingPathDelimiter(GetTempDir(False));
{$ELSE}
  Result := IncludeTrailingPathDelimiter(TPath.GetTempPath);
{$ENDIF}
  Result := IncludeTrailingPathDelimiter(Result + 'GMLib');
  Result := IncludeTrailingPathDelimiter(Result + 'Bootstrap');
  ForceDirectories(Result);
end;

class function TGMLibBootstrapAssets.EnsureAssetFile(const ATargetFileName,
  AResourceName, ARelativePath: string): string;
var
  targetPath: string;
  sourcePath: string;
  resourceText: string;
begin
  Result := '';
  if ATargetFileName = '' then
    Exit;

  targetPath := IncludeTrailingPathDelimiter(BuildTempBootstrapDir) + ATargetFileName;

  resourceText := LoadEmbeddedText(AResourceName);
  if resourceText <> '' then
  begin
    SaveTextToFile(targetPath, resourceText);
    Exit(targetPath);
  end;

  sourcePath := FindResourceFile(ARelativePath);
  if sourcePath = '' then
    Exit('');

  SaveTextToFile(targetPath, LoadTextFile(sourcePath));

  Result := targetPath;
end;

class function TGMLibBootstrapAssets.FindResourceFile(
  const ARelativePath: string): string;
var
  basePath: string;

  function SearchFromBase(const ABasePath: string): string;
  var
    candidatePath: string;
    searchBasePath: string;
    i: Integer;
  begin
    Result := '';
    searchBasePath := ExcludeTrailingPathDelimiter(ABasePath);

    for i := 0 to 8 do
    begin
{$IFDEF FPC}
      candidatePath := IncludeTrailingPathDelimiter(searchBasePath) + ARelativePath;
{$ELSE}
      candidatePath := TPath.Combine(searchBasePath, ARelativePath);
{$ENDIF}
      if FileExists(candidatePath) then
        Exit(candidatePath);

{$IFDEF FPC}
      searchBasePath := ExtractFileDir(searchBasePath);
{$ELSE}
      searchBasePath := TPath.GetDirectoryName(searchBasePath);
{$ENDIF}
      if searchBasePath = '' then
        Break;
    end;
  end;

begin
  Result := '';
{$IFDEF FPC}
  basePath := ExcludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
{$ELSE}
  basePath := ExcludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
{$ENDIF}

  if basePath <> '' then
  begin
    Result := SearchFromBase(basePath);
    if Result <> '' then
      Exit;
  end;

  basePath := ExcludeTrailingPathDelimiter(GetCurrentDir);
  if basePath <> '' then
    Result := SearchFromBase(basePath);
end;

class function TGMLibBootstrapAssets.LoadEmbeddedText(
  const AResourceName: string): string;
{$IFDEF FPC}
var
  resourceStream: TResourceStream;
  resourceBytes: TBytes;
{$ELSE}
{$IFDEF MSWINDOWS}
var
  moduleHandle: HMODULE;
  resourceHandle: HRSRC;
  resourceData: HGLOBAL;
  resourcePtr: Pointer;
  resourceBytes: TBytes;
{$ENDIF}
{$IFNDEF MSWINDOWS}
var
  resourceStream: TResourceStream;
  resourceBytes: TBytes;
{$ENDIF}
{$ENDIF}
begin
  Result := '';
{$IFDEF FPC}
  try
    resourceStream := TResourceStream.Create(
      HInstance,
      AResourceName,
      PChar(cBootstrapResourceType)
    );
  except
    Exit;
  end;

  try
    SetLength(resourceBytes, resourceStream.Size);
    if resourceStream.Size > 0 then
      resourceStream.ReadBuffer(resourceBytes[0], Length(resourceBytes));
    Result := TEncoding.UTF8.GetString(resourceBytes);
  finally
    resourceStream.Free;
  end;
{$ELSE}
{$IFDEF MSWINDOWS}
  moduleHandle := FindResourceHInstance(FindClassHInstance(TGMLibBootstrapAssets));
  if moduleHandle = 0 then
    moduleHandle := HInstance;

  resourceHandle := FindResource(moduleHandle, PChar(AResourceName), RT_RCDATA);
  if resourceHandle = 0 then
    Exit;

  resourceData := LoadResource(moduleHandle, resourceHandle);
  if resourceData = 0 then
    Exit;

  resourcePtr := LockResource(resourceData);
  if resourcePtr = nil then
    Exit;

  SetLength(resourceBytes, SizeofResource(moduleHandle, resourceHandle));
  if Length(resourceBytes) = 0 then
    Exit;

  Move(resourcePtr^, resourceBytes[0], Length(resourceBytes));
  Result := TEncoding.UTF8.GetString(resourceBytes);
{$ENDIF}
{$IFNDEF MSWINDOWS}
  try
    resourceStream := TResourceStream.Create(
      HInstance,
      AResourceName,
      PChar(cBootstrapResourceType)
    );
  except
    Exit;
  end;

  try
    SetLength(resourceBytes, resourceStream.Size);
    if resourceStream.Size > 0 then
      resourceStream.ReadBuffer(resourceBytes[0], Length(resourceBytes));
    Result := TEncoding.UTF8.GetString(resourceBytes);
  finally
    resourceStream.Free;
  end;
{$ENDIF}
{$ENDIF}
end;

class function TGMLibBootstrapAssets.LoadTextFile(const AFileName: string): string;
var
  fileStream: TFileStream;
  bytes: TBytes;
begin
  Result := '';
  if (AFileName = '') or not FileExists(AFileName) then
    Exit;

  fileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(bytes, fileStream.Size);
    if fileStream.Size > 0 then
      fileStream.ReadBuffer(bytes[0], Length(bytes));
    Result := TEncoding.UTF8.GetString(bytes);
  finally
    fileStream.Free;
  end;
end;

class function TGMLibBootstrapAssets.PathToFileUrl(const AFileName: string): string;
var
  filePath: string;
begin
  filePath := ExpandFileName(AFileName);
  filePath := StringReplace(filePath, '\', '/', [rfReplaceAll]);
  filePath := StringReplace(filePath, ' ', '%20', [rfReplaceAll]);
  filePath := StringReplace(filePath, '#', '%23', [rfReplaceAll]);
  Result := 'file:///' + filePath;
end;

class function TGMLibBootstrapAssets.ResolveResourceFile(
  const ARelativePath: string): string;
begin
  Result := FindResourceFile(ARelativePath);
end;

class procedure TGMLibBootstrapAssets.SaveTextToFile(const AFileName,
  AText: string);
var
  fileStream: TFileStream;
  bytes: TBytes;
begin
  try
    ForceDirectories(ExtractFileDir(AFileName));
    bytes := TEncoding.UTF8.GetBytes(AText);
    fileStream := TFileStream.Create(AFileName, fmCreate);
    try
      if Length(bytes) > 0 then
        fileStream.WriteBuffer(bytes[0], Length(bytes));
    finally
      fileStream.Free;
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('Unable to write bootstrap asset "%s": %s',
        [AFileName, E.Message]);
  end;
end;

end.
