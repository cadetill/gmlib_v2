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
  System.SysUtils,
  System.Types,
  System.Zip
  {$IFDEF MSWINDOWS},
  Winapi.Windows
  {$ENDIF};
{$ENDIF}

type
  {** @abstract(Helper para extraer los recursos del bootstrap a disco temporal.) }
  TGMLibBootstrapAssets = class
  strict private class var
    FLastDiagnostic: string;
  private
    class function BuildTempBootstrapDir: string; static;
    class function FindResourceFile(const ARelativePath: string): string; static;
    class function LoadEmbeddedBytes(const AResourceName: string): TBytes; static;
    class function LoadEmbeddedText(const AResourceName: string): string; static;
    class procedure SaveBytesToFile(const AFileName: string; const ABytes: TBytes); static;
    class procedure SaveTextToFile(const AFileName, AText: string); static;
  public
    class function EnsureAssetFile(const ATargetFileName, AResourceName,
      ARelativePath: string): string; static;
    class function EnsureBinaryAssetFile(const ATargetFileName, AResourceName,
      ARelativePath: string): string; static;
{$IFNDEF FPC}
    class function EnsureZipExpandedDirectory(const ATargetRootPath,
      AExpectedDirectoryName, AZipFileName, AResourceName,
      ARelativePath: string): string; static;
{$ENDIF}
    class function GetLastDiagnostic: string; static;
    class function LoadTextFile(const AFileName: string): string; static;
    class function PathToFileUrl(const AFileName: string): string; static;
    class function ResolveResourceFile(const ARelativePath: string): string; static;
    class property LastDiagnostic: string read GetLastDiagnostic;
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
  FLastDiagnostic := '';
  if ATargetFileName = '' then
  begin
    FLastDiagnostic := 'ATargetFileName is empty.';
    Exit;
  end;

  targetPath := IncludeTrailingPathDelimiter(BuildTempBootstrapDir) + ATargetFileName;

  resourceText := LoadEmbeddedText(AResourceName);
  if resourceText <> '' then
  begin
    SaveTextToFile(targetPath, resourceText);
    FLastDiagnostic := Format('Embedded resource "%s" extracted to "%s".',
      [AResourceName, targetPath]);
    Exit(targetPath);
  end;

  sourcePath := FindResourceFile(ARelativePath);
  if sourcePath = '' then
  begin
    if FLastDiagnostic = '' then
      FLastDiagnostic := Format(
        'Embedded resource "%s" was not found and repository fallback "%s" was not resolved.',
        [AResourceName, ARelativePath]
      );
    Exit('');
  end;

  SaveTextToFile(targetPath, LoadTextFile(sourcePath));
  FLastDiagnostic := Format('Repository fallback "%s" copied to "%s".',
    [sourcePath, targetPath]);

  Result := targetPath;
end;

class function TGMLibBootstrapAssets.EnsureBinaryAssetFile(
  const ATargetFileName, AResourceName, ARelativePath: string): string;
var
  targetPath: string;
  sourcePath: string;
  resourceBytes: TBytes;
{$IFDEF FPC}
  sourceStream: TFileStream;
{$ENDIF}
begin
  Result := '';
  FLastDiagnostic := '';
  if ATargetFileName = '' then
  begin
    FLastDiagnostic := 'ATargetFileName is empty.';
    Exit;
  end;

  targetPath := IncludeTrailingPathDelimiter(BuildTempBootstrapDir) + ATargetFileName;

  resourceBytes := LoadEmbeddedBytes(AResourceName);
  if Length(resourceBytes) > 0 then
  begin
    SaveBytesToFile(targetPath, resourceBytes);
    FLastDiagnostic := Format('Embedded binary resource "%s" extracted to "%s".',
      [AResourceName, targetPath]);
    Exit(targetPath);
  end;

  sourcePath := FindResourceFile(ARelativePath);
  if sourcePath = '' then
  begin
    if FLastDiagnostic = '' then
      FLastDiagnostic := Format(
        'Embedded binary resource "%s" was not found and repository fallback "%s" was not resolved.',
        [AResourceName, ARelativePath]
      );
    Exit('');
  end;

  ForceDirectories(ExtractFileDir(targetPath));
{$IFDEF FPC}
  if FileExists(targetPath) then
    SysUtils.DeleteFile(targetPath);
  sourceStream := TFileStream.Create(sourcePath, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(resourceBytes, sourceStream.Size);
    if Length(resourceBytes) > 0 then
      sourceStream.ReadBuffer(resourceBytes[0], Length(resourceBytes));
  finally
    sourceStream.Free;
  end;
  SaveBytesToFile(targetPath, resourceBytes);
{$ELSE}
  TFile.Copy(sourcePath, targetPath, True);
{$ENDIF}
  FLastDiagnostic := Format('Repository fallback "%s" copied to "%s".',
    [sourcePath, targetPath]);
  Result := targetPath;
end;

{$IFNDEF FPC}
class function TGMLibBootstrapAssets.EnsureZipExpandedDirectory(
  const ATargetRootPath, AExpectedDirectoryName, AZipFileName, AResourceName,
  ARelativePath: string): string;
var
  expandedDirectory: string;
  zipFilePath: string;
begin
  Result := '';
  FLastDiagnostic := '';

  if (ATargetRootPath = '') or (AExpectedDirectoryName = '') then
  begin
    FLastDiagnostic := 'Zip target root path or expected directory name is empty.';
    Exit;
  end;

  expandedDirectory := TPath.Combine(ATargetRootPath, AExpectedDirectoryName);
  if DirectoryExists(expandedDirectory) then
  begin
    FLastDiagnostic := Format('Expanded zip directory "%s" already exists.',
      [expandedDirectory]);
    Exit(ATargetRootPath);
  end;

  zipFilePath := EnsureBinaryAssetFile(AZipFileName, AResourceName, ARelativePath);
  if zipFilePath = '' then
    Exit('');

  ForceDirectories(ATargetRootPath);
  TZipFile.ExtractZipFile(zipFilePath, ATargetRootPath);
  if not DirectoryExists(expandedDirectory) then
  begin
    FLastDiagnostic := Format(
      'Zip "%s" was extracted to "%s" but expected directory "%s" was not created.',
      [zipFilePath, ATargetRootPath, expandedDirectory]
    );
    Exit('');
  end;

  FLastDiagnostic := Format('Zip "%s" extracted to "%s".',
    [zipFilePath, ATargetRootPath]);
  Result := ATargetRootPath;
end;
{$ENDIF}

class function TGMLibBootstrapAssets.GetLastDiagnostic: string;
begin
  Result := FLastDiagnostic;
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
var
  resourceBytes: TBytes;
{$IFDEF FPC}
  utf8Text: UTF8String;
{$ENDIF}
begin
  Result := '';
  resourceBytes := LoadEmbeddedBytes(AResourceName);
  if Length(resourceBytes) > 0 then
  begin
{$IFDEF FPC}
    SetString(utf8Text, PAnsiChar(@resourceBytes[0]), Length(resourceBytes));
    Result := string(utf8Text);
{$ELSE}
    Result := TEncoding.UTF8.GetString(resourceBytes);
{$ENDIF}
  end;
end;

class function TGMLibBootstrapAssets.LoadEmbeddedBytes(
  const AResourceName: string): TBytes;
{$IFDEF FPC}
var
  resourceStream: TResourceStream;
{$ELSE}
{$IFDEF MSWINDOWS}
var
  moduleHandle: HMODULE;
  resourceHandle: HRSRC;
  resourceData: HGLOBAL;
  resourcePtr: Pointer;
{$ENDIF}
{$IFNDEF MSWINDOWS}
var
  moduleHandle: NativeUInt;
  resourceStream: TResourceStream;
{$ENDIF}
{$ENDIF}
begin
  Result := nil;
{$IFDEF FPC}
  try
    resourceStream := TResourceStream.Create(
      HInstance,
      AResourceName,
      PChar(cBootstrapResourceType)
    );
  except
    on E: Exception do
    begin
      FLastDiagnostic := Format(
        'FPC resource "%s" could not be opened from HInstance=%p: %s',
        [AResourceName, Pointer(HInstance), E.Message]
      );
      Exit;
    end;
  end;

  try
    SetLength(Result, resourceStream.Size);
    if resourceStream.Size > 0 then
      resourceStream.ReadBuffer(Result[0], Length(Result));
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
  begin
    FLastDiagnostic := Format(
      'Windows resource "%s" not found in module handle %p.',
      [AResourceName, Pointer(moduleHandle)]
    );
    Exit;
  end;

  resourceData := LoadResource(moduleHandle, resourceHandle);
  if resourceData = 0 then
  begin
    FLastDiagnostic := Format(
      'Windows resource "%s" found but LoadResource failed for module handle %p.',
      [AResourceName, Pointer(moduleHandle)]
    );
    Exit;
  end;

  resourcePtr := LockResource(resourceData);
  if resourcePtr = nil then
  begin
    FLastDiagnostic := Format(
      'Windows resource "%s" found but LockResource returned nil for module handle %p.',
      [AResourceName, Pointer(moduleHandle)]
    );
    Exit;
  end;

  SetLength(Result, SizeofResource(moduleHandle, resourceHandle));
  if Length(Result) = 0 then
  begin
    FLastDiagnostic := Format(
      'Windows resource "%s" resolved with zero bytes in module handle %p.',
      [AResourceName, Pointer(moduleHandle)]
    );
    Exit;
  end;

  Move(resourcePtr^, Result[0], Length(Result));
  FLastDiagnostic := Format(
    'Windows resource "%s" loaded from module handle %p (%d bytes).',
    [AResourceName, Pointer(moduleHandle), Length(Result)]
  );
{$ENDIF}
{$IFNDEF MSWINDOWS}
  moduleHandle := FindClassHInstance(TGMLibBootstrapAssets);
  if moduleHandle = 0 then
    moduleHandle := HInstance;

  try
    resourceStream := TResourceStream.Create(
      moduleHandle,
      AResourceName,
      RT_RCDATA
    );
  except
    on E: Exception do
    begin
      FLastDiagnostic := Format(
        'Non-Windows resource "%s" could not be opened from module handle %p: %s',
        [AResourceName, Pointer(moduleHandle), E.Message]
      );
      Exit;
    end;
  end;

  try
    SetLength(Result, resourceStream.Size);
    if resourceStream.Size > 0 then
      resourceStream.ReadBuffer(Result[0], Length(Result));
    FLastDiagnostic := Format(
      'Non-Windows resource "%s" loaded from module handle %p (%d bytes).',
      [AResourceName, Pointer(moduleHandle), Length(Result)]
    );
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
{$IFDEF FPC}
  utf8Text: UTF8String;
{$ENDIF}
begin
  Result := '';
  bytes := nil;
  if (AFileName = '') or not FileExists(AFileName) then
    Exit;

  fileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(bytes, fileStream.Size);
    if fileStream.Size > 0 then
    begin
      fileStream.ReadBuffer(bytes[0], Length(bytes));
{$IFDEF FPC}
      SetString(utf8Text, PAnsiChar(@bytes[0]), Length(bytes));
      Result := string(utf8Text);
{$ELSE}
      Result := TEncoding.UTF8.GetString(bytes);
{$ENDIF}
    end;
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
begin
  try
{$IFDEF FPC}
    SaveBytesToFile(AFileName, BytesOf(UTF8Encode(AText)));
{$ELSE}
    SaveBytesToFile(AFileName, TEncoding.UTF8.GetBytes(AText));
{$ENDIF}
  except
    on E: Exception do
      raise Exception.CreateFmt('Unable to write bootstrap asset "%s": %s',
        [AFileName, E.Message]);
  end;
end;

class procedure TGMLibBootstrapAssets.SaveBytesToFile(const AFileName: string;
  const ABytes: TBytes);
var
  fileStream: TFileStream;
begin
  ForceDirectories(ExtractFileDir(AFileName));
  fileStream := TFileStream.Create(AFileName, fmCreate);
  try
    if Length(ABytes) > 0 then
      fileStream.WriteBuffer(ABytes[0], Length(ABytes));
  finally
    fileStream.Free;
  end;
end;

end.
