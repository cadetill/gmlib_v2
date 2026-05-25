{**
  @abstract(Capa de persistencia en formato JSON para el catálogo de regiones offline.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
}
unit uMapLib.Offline.Storage;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes, SysUtils, fpjson, jsonparser, uMapLib.Offline.Types;
{$ELSE}
  System.Classes, System.SysUtils, System.JSON, System.IOUtils, uMapLib.Offline.Types;
{$ENDIF}

type
  {** @abstract(Maneja la persistencia en disco de los metadatos del catálogo.) }
  TMapLibOfflineCatalogStorage = class
  private
    class function RegionMetadataToJson(const AMetadata: TMapLibOfflineRegionMetadata): TJSONObject; static;
    class function JsonToRegionMetadata(AJson: TJSONObject): TMapLibOfflineRegionMetadata; static;
  public
    class function LoadFromFile(const AFileName: string): TArray<TMapLibOfflineRegionMetadata>; static;
    class procedure SaveToFile(const AFileName: string; const ARegions: TArray<TMapLibOfflineRegionMetadata>); static;
  end;

implementation

{ TMapLibOfflineCatalogStorage }

class function TMapLibOfflineCatalogStorage.RegionMetadataToJson(
  const AMetadata: TMapLibOfflineRegionMetadata): TJSONObject;
var
  BoundsObj: TJSONObject;
begin
  Result := TJSONObject.Create;
  BoundsObj := TJSONObject.Create;

{$IFDEF FPC}
  BoundsObj.Add('north', AMetadata.Bounds.North);
  BoundsObj.Add('south', AMetadata.Bounds.South);
  BoundsObj.Add('east', AMetadata.Bounds.East);
  BoundsObj.Add('west', AMetadata.Bounds.West);

  Result.Add('regionId', AMetadata.RegionId);
  Result.Add('minZoom', AMetadata.MinZoom);
  Result.Add('maxZoom', AMetadata.MaxZoom);
  Result.Add('bounds', BoundsObj);
  Result.Add('createdAtUtc', DateTimeToStr(AMetadata.CreatedAtUtc));
  Result.Add('updatedAtUtc', DateTimeToStr(AMetadata.UpdatedAtUtc));
  Result.Add('dataVersion', AMetadata.DataVersion);
  Result.Add('sizeBytes', AMetadata.SizeBytes);
  Result.Add('checksum', AMetadata.Checksum);
  Result.Add('storagePath', AMetadata.StoragePath);
{$ELSE}
  BoundsObj.AddPair('north', TJSONNumber.Create(AMetadata.Bounds.North));
  BoundsObj.AddPair('south', TJSONNumber.Create(AMetadata.Bounds.South));
  BoundsObj.AddPair('east', TJSONNumber.Create(AMetadata.Bounds.East));
  BoundsObj.AddPair('west', TJSONNumber.Create(AMetadata.Bounds.West));

  Result.AddPair('regionId', AMetadata.RegionId);
  Result.AddPair('minZoom', TJSONNumber.Create(AMetadata.MinZoom));
  Result.AddPair('maxZoom', TJSONNumber.Create(AMetadata.MaxZoom));
  Result.AddPair('bounds', BoundsObj);
  Result.AddPair('createdAtUtc', TJSONNumber.Create(AMetadata.CreatedAtUtc));
  Result.AddPair('updatedAtUtc', TJSONNumber.Create(AMetadata.UpdatedAtUtc));
  Result.AddPair('dataVersion', AMetadata.DataVersion);
  Result.AddPair('sizeBytes', TJSONNumber.Create(AMetadata.SizeBytes));
  Result.AddPair('checksum', AMetadata.Checksum);
  Result.AddPair('storagePath', AMetadata.StoragePath);
{$ENDIF}
end;

class function TMapLibOfflineCatalogStorage.JsonToRegionMetadata(
  AJson: TJSONObject): TMapLibOfflineRegionMetadata;
var
  BoundsObj: TJSONObject;
  BoundsVal: TJSONValue;
begin
  FillChar(Result, SizeOf(Result), 0);
  if not Assigned(AJson) then
    Exit;

{$IFDEF FPC}
  Result.RegionId := AJson.Strings['regionId'];
  Result.MinZoom := AJson.Integers['minZoom'];
  Result.MaxZoom := AJson.Integers['maxZoom'];
  
  BoundsObj := AJson.Objects['bounds'];
  if Assigned(BoundsObj) then
  begin
    Result.Bounds.North := BoundsObj.Floats['north'];
    Result.Bounds.South := BoundsObj.Floats['south'];
    Result.Bounds.East := BoundsObj.Floats['east'];
    Result.Bounds.West := BoundsObj.Floats['west'];
  end;

  Result.CreatedAtUtc := StrToDateTimeDef(AJson.Strings['createdAtUtc'], 0);
  Result.UpdatedAtUtc := StrToDateTimeDef(AJson.Strings['updatedAtUtc'], 0);
  Result.DataVersion := AJson.Strings['dataVersion'];
  Result.SizeBytes := AJson.Int64s['sizeBytes'];
  Result.Checksum := AJson.Strings['checksum'];
  Result.StoragePath := AJson.Strings['storagePath'];
{$ELSE}
  Result.RegionId := AJson.GetValue<string>('regionId', '');
  Result.MinZoom := AJson.GetValue<Integer>('minZoom', 0);
  Result.MaxZoom := AJson.GetValue<Integer>('maxZoom', 0);

  BoundsVal := AJson.GetValue('bounds');
  if (BoundsVal is TJSONObject) then
  begin
    BoundsObj := TJSONObject(BoundsVal);
    Result.Bounds.North := BoundsObj.GetValue<Double>('north', 0);
    Result.Bounds.South := BoundsObj.GetValue<Double>('south', 0);
    Result.Bounds.East := BoundsObj.GetValue<Double>('east', 0);
    Result.Bounds.West := BoundsObj.GetValue<Double>('west', 0);
  end;

  Result.CreatedAtUtc := AJson.GetValue<Double>('createdAtUtc', 0);
  Result.UpdatedAtUtc := AJson.GetValue<Double>('updatedAtUtc', 0);
  Result.DataVersion := AJson.GetValue<string>('dataVersion', '');
  Result.SizeBytes := AJson.GetValue<Int64>('sizeBytes', 0);
  Result.Checksum := AJson.GetValue<string>('checksum', '');
  Result.StoragePath := AJson.GetValue<string>('storagePath', '');
{$ENDIF}
end;

class function TMapLibOfflineCatalogStorage.LoadFromFile(
  const AFileName: string): TArray<TMapLibOfflineRegionMetadata>;
var
  Content: string;
  JsonArr: TJSONArray;
  JsonVal: TJSONValue;
  I: Integer;
begin
  SetLength(Result, 0);
  if not FileExists(AFileName) then
    Exit;

  try
    Content := TFile.ReadAllText(AFileName, TEncoding.UTF8);
    if Trim(Content) = '' then
      Exit;

    JsonVal := TJSONObject.ParseJSONValue(Content);
    try
      if JsonVal is TJSONArray then
      begin
        JsonArr := TJSONArray(JsonVal);
        SetLength(Result, JsonArr.Count);
        for I := 0 to JsonArr.Count - 1 do
        begin
          if JsonArr.Items[I] is TJSONObject then
            Result[I] := JsonToRegionMetadata(TJSONObject(JsonArr.Items[I]));
        end;
      end;
    finally
      JsonVal.Free;
    end;
  except
    // Silent fail returning empty array
  end;
end;

class procedure TMapLibOfflineCatalogStorage.SaveToFile(
  const AFileName: string; const ARegions: TArray<TMapLibOfflineRegionMetadata>);
var
  JsonArr: TJSONArray;
  I: Integer;
  Content: string;
  DirName: string;
begin
  JsonArr := TJSONArray.Create;
  try
    for I := Low(ARegions) to High(ARegions) do
      JsonArr.AddElement(RegionMetadataToJson(ARegions[I]));

    DirName := TPath.GetDirectoryName(AFileName);
    if (DirName <> '') and not DirectoryExists(DirName) then
      TDirectory.CreateDirectory(DirName);

    Content := JsonArr.ToJSON;
    TFile.WriteAllText(AFileName, Content, TEncoding.UTF8);
  finally
    JsonArr.Free;
  end;
end;

end.
