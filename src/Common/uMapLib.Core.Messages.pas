{**
  @abstract(Modelos de mensaje del bridge Delphi <-> JavaScript.)
}
unit uMapLib.Core.Messages;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  SysUtils, fpjson, jsonparser,
{$ELSE}
  System.SysUtils, System.JSON,
{$ENDIF}
  uMapLib.Core.Types;

type
{$IFDEF FPC}
  TMapLibMessageEnvelope = record
    MessageType: string;
    TargetId: TGMObjectId;
    Payload: string;
  end;

function MapLibMessageEnvelopeCreate(const AMessageType: string; const ATargetId: TGMObjectId;
  const APayload: string = ''): TMapLibMessageEnvelope;
function MapLibMessageEnvelopeFromJson(const AJson: string): TMapLibMessageEnvelope;
function MapLibMessageEnvelopePayloadAsString(const AEnvelope: TMapLibMessageEnvelope): string;
function MapLibMessageEnvelopeToJson(const AEnvelope: TMapLibMessageEnvelope): string;
{$ELSE}
  TMapLibMessageEnvelope = record
  public
    MessageType: string;
    TargetId: TGMObjectId;
    Payload: string;
    class function Create(const AMessageType: string; const ATargetId: TGMObjectId;
      const APayload: string = ''): TMapLibMessageEnvelope; static;
    class function FromJson(const AJson: string): TMapLibMessageEnvelope; static;
    function PayloadAsString: string;
    function ToJson: string;
  end;

{$ENDIF}

implementation

{$IFDEF FPC}
function MapLibMessageEnvelopeCreate(const AMessageType: string; const ATargetId: TGMObjectId;
  const APayload: string): TMapLibMessageEnvelope;
begin
  Result.MessageType := AMessageType;
  Result.TargetId := ATargetId;
  Result.Payload := APayload;
end;

function MapLibMessageEnvelopeFromJson(const AJson: string): TMapLibMessageEnvelope;
var
  JsonData: TJSONData;
  JsonParser: TJSONParser;
  PayloadData: TJSONData;
begin
  Result := Default(TMapLibMessageEnvelope);
  JsonParser := TJSONParser.Create(AJson, []);
  try
    JsonData := JsonParser.Parse;
    try
      if not (JsonData is TJSONObject) then
        Exit;
      Result.MessageType := TJSONObject(JsonData).Get('type', '');
      Result.TargetId := TGMObjectId(TJSONObject(JsonData).Get('targetId', ''));
      PayloadData := TJSONObject(JsonData).Find('payload');
      if Assigned(PayloadData) then
        Result.Payload := PayloadData.AsJSON
      else
        Result.Payload := '';
    finally
      JsonData.Free;
    end;
  finally
    JsonParser.Free;
  end;
end;

function MapLibMessageEnvelopePayloadAsString(const AEnvelope: TMapLibMessageEnvelope): string;
begin
  Result := Trim(AEnvelope.Payload);
  if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function MapLibMessageEnvelopeToJson(const AEnvelope: TMapLibMessageEnvelope): string;
var
  JsonData: TJSONObject;
  JsonParser: TJSONParser;
  JsonValue: TJSONData;
begin
  JsonData := TJSONObject.Create;
  try
    JsonData.Add('type', AEnvelope.MessageType);
    JsonData.Add('targetId', string(AEnvelope.TargetId));
    if AEnvelope.Payload <> '' then
    begin
      JsonParser := TJSONParser.Create(AEnvelope.Payload, []);
      try
        JsonValue := JsonParser.Parse;
        JsonData.Add('payload', JsonValue);
        JsonValue := nil;
      finally
        JsonParser.Free;
        JsonValue.Free;
      end;
    end;
    Result := JsonData.AsJSON;
  finally
    JsonData.Free;
  end;
end;
{$ELSE}
class function TMapLibMessageEnvelope.Create(const AMessageType: string;
  const ATargetId: TGMObjectId; const APayload: string): TMapLibMessageEnvelope;
begin
  Result.MessageType := AMessageType;
  Result.TargetId := ATargetId;
  Result.Payload := APayload;
end;

class function TMapLibMessageEnvelope.FromJson(const AJson: string): TMapLibMessageEnvelope;
var
  JsonObject: TJSONObject;
  JsonValue: TJSONValue;
begin
  Result := Default(TMapLibMessageEnvelope);
  try
    JsonValue := TJSONObject.ParseJSONValue(AJson);
    try
      if not (JsonValue is TJSONObject) then
        Exit;
      JsonObject := TJSONObject(JsonValue);
      Result.MessageType := JsonObject.GetValue<string>('type', '');
      Result.TargetId := TGMObjectId(JsonObject.GetValue<string>('targetId', ''));
      if Assigned(JsonObject.Values['payload']) then
        Result.Payload := JsonObject.Values['payload'].ToJSON
      else
        Result.Payload := '';
    finally
      JsonValue.Free;
    end;
  except
    Result := Default(TMapLibMessageEnvelope);
  end;
end;

function TMapLibMessageEnvelope.PayloadAsString: string;
begin
  Result := Payload.Trim;
  if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function TMapLibMessageEnvelope.ToJson: string;
var
  JsonObject: TJSONObject;
  JsonValue: TJSONValue;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('type', MessageType);
    JsonObject.AddPair('targetId', string(TargetId));
    if Payload <> '' then
    begin
      JsonValue := TJSONObject.ParseJSONValue(Payload);
      if Assigned(JsonValue) then
        JsonObject.AddPair('payload', JsonValue)
      else
        JsonObject.AddPair('payload', Payload);
    end;
    Result := JsonObject.ToJSON;
  finally
    JsonObject.Free;
  end;
end;
{$ENDIF}

end.

