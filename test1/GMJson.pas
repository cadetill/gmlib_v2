unit GMJson;

interface

type
  IJson = interface
    ['{EA6737C1-4C53-44D5-BC98-5C13A590E084}']
    function Serialize(aObject: TObject{; ExcludeProp: array of string}): string;
    function Deserialize(aClass: TClass; Json: string): TObject;
  end;

  TGMJson = class(TInterfacedObject, IJson)
  public
    function Serialize(aObject: TObject{; ExcludeProp: array of string}): string;
    function Deserialize(aClass: TClass; Json: string): TObject;
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

end.
