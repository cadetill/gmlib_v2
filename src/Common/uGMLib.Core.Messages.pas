{**
  @abstract(Modelos de mensaje del bridge Delphi <-> JavaScript.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define el sobre de mensajes base usado para intercambiar eventos
  y comandos serializados en JSON.
}
unit uGMLib.Core.Messages;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  SysUtils, fpjson, jsonparser,
{$ELSE}
  System.SysUtils, System.JSON,
{$ENDIF}

  uGMLib.Core.Types;

  type
  {** @abstract(Sobre de mensaje JSON del bridge.) }
{$IFDEF FPC}
  TGMMessageEnvelope = record
    { Payload is kept as raw JSON text so callers can pass either structured
      data or a literal string without losing the original shape. }
    MessageType: string;
    TargetId: TGMObjectId;
    Payload: string;
  end;

function GMLibMessageEnvelopeCreate(const AMessageType: string; const ATargetId: TGMObjectId;
  const APayload: string = ''): TGMMessageEnvelope;
function GMLibMessageEnvelopeFromJson(const AJson: string): TGMMessageEnvelope;
function GMLibMessageEnvelopePayloadAsString(const AEnvelope: TGMMessageEnvelope): string;
function GMLibMessageEnvelopeToJson(const AEnvelope: TGMMessageEnvelope): string;
{$ELSE}
  TGMMessageEnvelope = record
  public
    { Payload is kept as raw JSON text so callers can pass either structured
      data or a literal string without losing the original shape. }
    MessageType: string;
    TargetId: TGMObjectId;
    Payload: string;

    class function Create(const AMessageType: string; const ATargetId: TGMObjectId;
      const APayload: string = ''): TGMMessageEnvelope; static;
    class function FromJson(const AJson: string): TGMMessageEnvelope; static;

    function PayloadAsString: string;
    function ToJson: string;
  end;
{$ENDIF}

implementation

{$IFDEF FPC}
function GMLibMessageEnvelopeCreate(const AMessageType: string; const ATargetId: TGMObjectId;
  const APayload: string): TGMMessageEnvelope;
begin
  Result.MessageType := AMessageType;
  Result.TargetId := ATargetId;
  Result.Payload := APayload;
end;

function GMLibMessageEnvelopeFromJson(const AJson: string): TGMMessageEnvelope;
var
  JsonData: TJSONData;
  JsonParser: TJSONParser;
  PayloadData: TJSONData;
begin
  Result := Default(TGMMessageEnvelope);

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

function GMLibMessageEnvelopePayloadAsString(const AEnvelope: TGMMessageEnvelope): string;
begin
  Result := Trim(AEnvelope.Payload);

  if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function GMLibMessageEnvelopeToJson(const AEnvelope: TGMMessageEnvelope): string;
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
class function TGMMessageEnvelope.Create(const AMessageType: string;
  const ATargetId: TGMObjectId; const APayload: string): TGMMessageEnvelope;
begin
  Result.MessageType := AMessageType;
  Result.TargetId := ATargetId;
  Result.Payload := APayload;
end;

class function TGMMessageEnvelope.FromJson(const AJson: string): TGMMessageEnvelope;
var
  JsonObject: TJSONObject;
  JsonValue: TJSONValue;
begin
  Result := Default(TGMMessageEnvelope);

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
    Result := Default(TGMMessageEnvelope);
  end;
end;

function TGMMessageEnvelope.PayloadAsString: string;
begin
  Result := Payload.Trim;

  if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function TGMMessageEnvelope.ToJson: string;
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
