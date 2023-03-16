unit GMJson;

interface

uses
  System.JSON.Serializers, System.Rtti, System.TypInfo;

type
  IJson = interface
    ['{EA6737C1-4C53-44D5-BC98-5C13A590E084}']
    function Serialize(aObject: TObject): string; overload;
    function Serialize(aObject: TObject; ExcludeProp: array of string): string; overload;
    function Deserialize(aClass: TClass; Json: string): TObject;
  end;

  TGMJson = class(TInterfacedObject, IJson)
  public
    function Serialize(aObject: TObject): string; overload;
    function Serialize(aObject: TObject; ExcludeProp: array of string): string; overload;
    function Deserialize(aClass: TClass; Json: string): TObject;
  end;

  TMyJsonDynamicContractResolver = class(TJsonDynamicContractResolver)
  protected
    function CreateObjectContract(ATypeInf: PTypeInfo): TJsonObjectContract; override;
  end;

implementation

uses
  System.SysUtils,
  Rest.Json, System.JSON, System.JSONConsts, REST.JsonReflect;

{ TGMJson }

function TGMJson.Deserialize(aClass: TClass; Json: string): TObject;
var
  JSONValue: TJsonValue;
  JSONObject: TJSONObject;
begin
  Result := aClass.Create;

  JSONValue := TJSONObject.ParseJSONValue(Json);
  try
    if not Assigned(JSONValue) then
      Exit;

    if (JSONValue is TJSONArray) then
    begin
      with TJSONUnMarshal.Create do
        try
          SetFieldArray(Result, 'Items', (JSONValue as TJSONArray));
        finally
          Free;
        end;

      Exit;
    end;

    if (JSONValue is TJSONObject) then
      JSONObject := JSONValue as TJSONObject
    else
    begin
      Json := Json.Trim;
      if (Json = '') and not Assigned(JSONValue) or (Json <> '') and Assigned(JSONValue) and JSONValue.Null then
        Exit
      else
        raise EConversionError.Create(SCannotCreateObject);
    end;

    TJson.JsonToObject(Result, JSONObject, []);
  finally
    JSONValue.Free;
  end;
end;

function TGMJson.Serialize(aObject: TObject{; ExcludeProp: array of string}): string;
begin
  Result := TJson.ObjectToJsonString(aObject, []);
end;

function TGMJson.Serialize(aObject: TObject;
  ExcludeProp: array of string): string;
var
  Serializer: TJsonSerializer;
  Resolver: TMyJsonDynamicContractResolver;
begin
  Resolver := nil;
  Serializer := nil;
  try
    Resolver := TMyJsonDynamicContractResolver.Create;
    Serializer := TJsonSerializer.Create;

    Serializer.ContractResolver := Resolver;
    Result := Serializer.Serialize(aObject);
  finally
    //if Assigned(Resolver) then Resolver.Free;
    if Assigned(Serializer) then Serializer.Free;
  end;
end;

{ TMyJsonDynamicContractResolver }

function TMyJsonDynamicContractResolver.CreateObjectContract(
  ATypeInf: PTypeInfo): TJsonObjectContract;
var
  LContract: TJsonObjectContract;
  LProperty: TJsonProperty;
begin
  LContract := inherited CreateObjectContract(ATypeInf);

  // Iterate through the properties of the object
  for LProperty in LContract.Properties do
  begin
    // If the property is part of the TPerson class and its name is 'Age', exclude it
    if (LProperty.Name = 'FOwner') then
      LProperty.Ignored := True;
  end;

  Result := LContract;
end;

end.
