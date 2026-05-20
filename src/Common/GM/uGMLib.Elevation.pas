{**
  @abstract(Modelo de elevaciones del mapa.)
}
unit uGMLib.Elevation;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  fpjson,
  jsonparser,
  Math,
  SysUtils,
{$ELSE}
  System.Classes,
  System.JSON,
  System.Math,
  System.SysUtils,
{$ENDIF}
  uMapLib.Core.Component,
  uGMLib.Core.Types,
  uGMLib.Polyline;

type
  TGMElevationType = (
    etAlongPath,
    etForLocations
  );

  TGMElevationResult = record
    Latitude: Double;
    Longitude: Double;
    Elevation: Double;
    Resolution: Double;
  end;

  TGMElevationResults = array of TGMElevationResult;

{$IFDEF FPC}
  TGMElevationResponse = record
    RequestId: string;
    Status: string;
    ErrorMessage: string;
    Results: TGMElevationResults;
  end;
{$ELSE}
  TGMElevationResponse = record
  public
    RequestId: string;
    Status: string;
    ErrorMessage: string;
    Results: TGMElevationResults;

    class function FromJson(const AJson: string): TGMElevationResponse; static;
    function HasResults: Boolean;
    function TryGetFirstLocation(out ALatLng: TMapLibLatLng): Boolean;
    function TryGetFirstResult(out AResult: TGMElevationResult): Boolean;
  end;
{$ENDIF}

{$IFDEF FPC}
function GMLibElevationResponseFromJson(const AJson: string): TGMElevationResponse;
function GMLibElevationResponseHasResults(const AResponse: TGMElevationResponse): Boolean;
function GMLibElevationResponseTryGetFirstLocation(const AResponse: TGMElevationResponse;
  out ALatLng: TMapLibLatLng): Boolean;
function GMLibElevationResponseTryGetFirstResult(const AResponse: TGMElevationResponse;
  out AResult: TGMElevationResult): Boolean;
{$ENDIF}

type
  TGMElevationCompletedEvent = procedure(Sender: TObject; const AResponse: TGMElevationResponse) of object;

  TGMElevationPendingRequest = class
  public
    RequestId: string;
    OnCompleted: TGMElevationCompletedEvent;
  end;

  TGMElevations = class(TMapLibComponent)
  private
    FElevationType: TGMElevationType;
    FLastErrorMessage: string;
    FLastResponse: TGMElevationResponse;
    FLastStatus: string;
    FPendingExecute: Boolean;
    FMap: TComponent;
    FOnChange: TNotifyEvent;
    FOnCompleted: TGMElevationCompletedEvent;
    FPath: TGMPolylinePath;
    FSamples: Integer;
    procedure HandleCompleted(Sender: TObject; const AResponse: TGMElevationResponse);
    function CanExecuteNow: Boolean;
    procedure ExecuteInternal;
    procedure PathChanged(Sender: TObject);
    procedure SetElevationType(const Value: TGMElevationType);
    procedure SetMap(const Value: TComponent);
    procedure SetPath(const Value: TGMPolylinePath);
    procedure SetSamples(const Value: Integer);
    function GetCount: Integer;
  protected
    function GetDocumentationUrl: string; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure NotifyChanged; virtual;
    procedure SyncLastResponse(const AResponse: TGMElevationResponse);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure AddLatLng(const ALatLng: TMapLibLatLng); overload;
    procedure AddLatLng(const ALat, ALng: Double); overload;
    procedure AddLatLngFromPath(const APath: TGMPolylinePath; DeleteBeforeLoad: Boolean = True);
    procedure AddLatLngFromPolyline(const APolyline: TGMPolylineItem; DeleteBeforeLoad: Boolean = True);
    procedure Execute;
    procedure FlushPendingExecute;
    function GetResult(Index: Integer): TGMElevationResult;
    function TryGetFirstLocation(out ALatLng: TMapLibLatLng): Boolean;

    property Count: Integer read GetCount;
    property LastErrorMessage: string read FLastErrorMessage;
    property LastResponse: TGMElevationResponse read FLastResponse;
    property LastStatus: string read FLastStatus;
    property Map: TComponent read FMap write SetMap;
    property Path: TGMPolylinePath read FPath write SetPath;
    property Results[Index: Integer]: TGMElevationResult read GetResult; default;
  published
    property ElevationType: TGMElevationType read FElevationType write SetElevationType default etForLocations;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCompleted: TGMElevationCompletedEvent read FOnCompleted write FOnCompleted;
    property Samples: Integer read FSamples write SetSamples default 2;
  end;

implementation

uses
  uGMLib.Map;

const
  ELEVATION_MIN_SAMPLES = 2;
  ELEVATION_MAX_SAMPLES = 512;

function ParseElevationResult(const AJsonObject: TJSONObject): TGMElevationResult;
var
  LocationObj: TJSONObject;
{$IFDEF FPC}
  LocationValue: TJSONData;
{$ELSE}
  LocationValue: TJSONValue;
{$ENDIF}
begin
  Result := Default(TGMElevationResult);
  if not Assigned(AJsonObject) then
    Exit;

{$IFDEF FPC}
  if Assigned(AJsonObject.Find('latitude')) then
    Result.Latitude := AJsonObject.Find('latitude').AsFloat;
  if Assigned(AJsonObject.Find('longitude')) then
    Result.Longitude := AJsonObject.Find('longitude').AsFloat;
  if Assigned(AJsonObject.Find('elevation')) then
    Result.Elevation := AJsonObject.Find('elevation').AsFloat;
  if Assigned(AJsonObject.Find('resolution')) then
    Result.Resolution := AJsonObject.Find('resolution').AsFloat;
{$ELSE}
  Result.Latitude := AJsonObject.GetValue<Double>('latitude', 0);
  Result.Longitude := AJsonObject.GetValue<Double>('longitude', 0);
  Result.Elevation := AJsonObject.GetValue<Double>('elevation', 0);
  Result.Resolution := AJsonObject.GetValue<Double>('resolution', 0);
{$ENDIF}

{$IFDEF FPC}
  LocationValue := AJsonObject.Find('location');
  if LocationValue is TJSONObject then
  begin
    LocationObj := TJSONObject(LocationValue);
    if Assigned(LocationObj.Find('lat')) then
      Result.Latitude := LocationObj.Find('lat').AsFloat;
    if Assigned(LocationObj.Find('lng')) then
      Result.Longitude := LocationObj.Find('lng').AsFloat;
  end;
{$ELSE}
  LocationValue := AJsonObject.Values['location'];
  if LocationValue is TJSONObject then
  begin
    LocationObj := TJSONObject(LocationValue);
    LocationObj.TryGetValue<Double>('lat', Result.Latitude);
    LocationObj.TryGetValue<Double>('lng', Result.Longitude);
  end;
{$ENDIF}
end;

function ParseElevationResults(const AJsonObject: TJSONObject): TGMElevationResults;
var
{$IFDEF FPC}
  ResultsValue: TJSONData;
{$ELSE}
  ResultsValue: TJSONValue;
{$ENDIF}
  ResultsArray: TJSONArray;
  i: Integer;
begin
  Result := Default(TGMElevationResults);
  SetLength(Result, 0);
  if not Assigned(AJsonObject) then
    Exit;

{$IFDEF FPC}
  ResultsValue := AJsonObject.Find('results');
  if not (ResultsValue is TJSONArray) then
    Exit;
  ResultsArray := TJSONArray(ResultsValue);
{$ELSE}
  ResultsValue := AJsonObject.Values['results'];
  if not (ResultsValue is TJSONArray) then
    Exit;
  ResultsArray := TJSONArray(ResultsValue);
{$ENDIF}

  SetLength(Result, ResultsArray.Count);
  for i := 0 to ResultsArray.Count - 1 do
    if ResultsArray.Items[i] is TJSONObject then
      Result[i] := ParseElevationResult(TJSONObject(ResultsArray.Items[i]));
end;

{$IFDEF FPC}
function GMLibElevationResponseFromJson(const AJson: string): TGMElevationResponse;
var
  JsonData: TJSONData;
  JsonParser: TJSONParser;
begin
  Result := Default(TGMElevationResponse);
  if AJson = '' then
    Exit;

  JsonParser := TJSONParser.Create(AJson, []);
  try
    JsonData := JsonParser.Parse;
    try
      if not (JsonData is TJSONObject) then
        Exit;

      Result.RequestId := TJSONObject(JsonData).Get('requestId', '');
      Result.Status := TJSONObject(JsonData).Get('status', '');
      Result.ErrorMessage := TJSONObject(JsonData).Get('errorMessage', '');
      Result.Results := ParseElevationResults(TJSONObject(JsonData));
    finally
      JsonData.Free;
    end;
  finally
    JsonParser.Free;
  end;
end;

function GMLibElevationResponseHasResults(const AResponse: TGMElevationResponse): Boolean;
begin
  Result := Length(AResponse.Results) > 0;
end;

function GMLibElevationResponseTryGetFirstLocation(const AResponse: TGMElevationResponse;
  out ALatLng: TMapLibLatLng): Boolean;
var
  FirstResult: TGMElevationResult;
begin
  ALatLng := nil;
  Result := GMLibElevationResponseTryGetFirstResult(AResponse, FirstResult);
  if not Result then
    Exit;

  ALatLng := TMapLibLatLng.Create(FirstResult.Latitude, FirstResult.Longitude);
end;

function GMLibElevationResponseTryGetFirstResult(const AResponse: TGMElevationResponse;
  out AResult: TGMElevationResult): Boolean;
begin
  Result := Length(AResponse.Results) > 0;
  if not Result then
  begin
    AResult := Default(TGMElevationResult);
    Exit;
  end;

  AResult := AResponse.Results[0];
end;
{$ELSE}
class function TGMElevationResponse.FromJson(const AJson: string): TGMElevationResponse;
var
  JsonValue: TJSONValue;
  JsonObject: TJSONObject;
begin
  Result := Default(TGMElevationResponse);
  if AJson = '' then
    Exit;

  try
    JsonValue := TJSONObject.ParseJSONValue(AJson);
    try
      if not (JsonValue is TJSONObject) then
        Exit;

      JsonObject := TJSONObject(JsonValue);
      Result.RequestId := JsonObject.GetValue<string>('requestId', '');
      Result.Status := JsonObject.GetValue<string>('status', '');
      Result.ErrorMessage := JsonObject.GetValue<string>('errorMessage', '');
      Result.Results := ParseElevationResults(JsonObject);
    finally
      JsonValue.Free;
    end;
  except
    Result := Default(TGMElevationResponse);
  end;
end;

function TGMElevationResponse.HasResults: Boolean;
begin
  Result := Length(Results) > 0;
end;

function TGMElevationResponse.TryGetFirstLocation(out ALatLng: TMapLibLatLng): Boolean;
var
  FirstResult: TGMElevationResult;
begin
  ALatLng := nil;
  Result := TryGetFirstResult(FirstResult);
  if not Result then
    Exit;

  ALatLng := TMapLibLatLng.Create(FirstResult.Latitude, FirstResult.Longitude);
end;

function TGMElevationResponse.TryGetFirstResult(out AResult: TGMElevationResult): Boolean;
begin
  Result := Length(Results) > 0;
  if not Result then
  begin
    AResult := Default(TGMElevationResult);
    Exit;
  end;

  AResult := Results[0];
end;
{$ENDIF}

{ TGMElevations }

procedure TGMElevations.AddLatLng(const ALatLng: TMapLibLatLng);
begin
  if not Assigned(ALatLng) then
    Exit;

  Path.Add(ALatLng.Lat, ALatLng.Lng);
end;

procedure TGMElevations.AddLatLng(const ALat, ALng: Double);
begin
  Path.Add(ALat, ALng);
end;

procedure TGMElevations.AddLatLngFromPath(const APath: TGMPolylinePath; DeleteBeforeLoad: Boolean);
var
  i: Integer;
  NewPoint: TGMPolylinePoint;
begin
  if DeleteBeforeLoad then
    Path.Clear;

  if not Assigned(APath) then
    Exit;

  for i := 0 to APath.Count - 1 do
  begin
    NewPoint := Path.Add;
    NewPoint.Assign(APath[i]);
  end;
end;

procedure TGMElevations.AddLatLngFromPolyline(const APolyline: TGMPolylineItem;
  DeleteBeforeLoad: Boolean);
begin
  if not Assigned(APolyline) then
  begin
    if DeleteBeforeLoad then
      Path.Clear;
    Exit;
  end;

  AddLatLngFromPath(APolyline.Options.Path, DeleteBeforeLoad);
end;

procedure TGMElevations.Assign(Source: TPersistent);
begin
  if Source is TGMElevations then
  begin
    ElevationType := TGMElevations(Source).ElevationType;
    Path.Assign(TGMElevations(Source).Path);
    Samples := TGMElevations(Source).Samples;
    Exit;
  end;

  inherited;
end;

procedure TGMElevations.Clear;
begin
  Path.Clear;
  FLastResponse := Default(TGMElevationResponse);
  FLastStatus := '';
  FLastErrorMessage := '';
  NotifyChanged;
end;

constructor TGMElevations.Create(AOwner: TComponent);
begin
  inherited;

  FPath := TGMPolylinePath.Create(Self);
{$IFDEF FPC}
  FPath.OnChange := @PathChanged;
{$ELSE}
  FPath.OnChange := PathChanged;
{$ENDIF}
  FElevationType := etForLocations;
  FSamples := 2;
  FPendingExecute := False;
end;

destructor TGMElevations.Destroy;
begin
  Map := nil;
  FPath.Free;
  inherited;
end;

procedure TGMElevations.Execute;
begin
  if not CanExecuteNow then
  begin
    FPendingExecute := True;
    Exit;
  end;

  ExecuteInternal;
end;

procedure TGMElevations.FlushPendingExecute;
begin
  if not FPendingExecute then
    Exit;

  if not CanExecuteNow then
    Exit;

  ExecuteInternal;
end;

function TGMElevations.CanExecuteNow: Boolean;
begin
  Result := Assigned(FMap) and (FMap is TGMCustomMap) and TGMCustomMap(FMap).HasMapIdle;
end;

procedure TGMElevations.ExecuteInternal;
begin
  FPendingExecute := False;

  if not Assigned(FMap) or not (FMap is TGMCustomMap) then
    Exit;

  if Path.Count = 0 then
    Exit;

  if ElevationType = etAlongPath then
{$IFDEF FPC}
    TGMCustomMap(FMap).ElevationAlongPath(Path, Samples, @HandleCompleted)
{$ELSE}
    TGMCustomMap(FMap).ElevationAlongPath(Path, Samples, HandleCompleted)
{$ENDIF}
  else
{$IFDEF FPC}
    TGMCustomMap(FMap).ElevationForLocations(Path, @HandleCompleted);
{$ELSE}
    TGMCustomMap(FMap).ElevationForLocations(Path, HandleCompleted);
{$ENDIF}
end;

function TGMElevations.GetDocumentationUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/elevation';
end;

function TGMElevations.GetCount: Integer;
begin
  Result := Length(FLastResponse.Results);
end;

function TGMElevations.GetResult(Index: Integer): TGMElevationResult;
begin
  Result := Default(TGMElevationResult);
  if (Index < 0) or (Index >= Length(FLastResponse.Results)) then
    Exit;
  Result := FLastResponse.Results[Index];
end;

procedure TGMElevations.HandleCompleted(Sender: TObject; const AResponse: TGMElevationResponse);
begin
  SyncLastResponse(AResponse);
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, AResponse);
  NotifyChanged;
end;

procedure TGMElevations.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FMap) then
    FMap := nil;
end;

procedure TGMElevations.NotifyChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMElevations.PathChanged(Sender: TObject);
begin
  NotifyChanged;
end;

procedure TGMElevations.SetElevationType(const Value: TGMElevationType);
begin
  if FElevationType = Value then
    Exit;
  FElevationType := Value;
  NotifyChanged;
end;

procedure TGMElevations.SetMap(const Value: TComponent);
begin
  if FMap = Value then
    Exit;

  if Assigned(FMap) then
    FMap.RemoveFreeNotification(Self);

  FMap := Value;

  if Assigned(FMap) then
    FMap.FreeNotification(Self);
end;

procedure TGMElevations.SetPath(const Value: TGMPolylinePath);
begin
  if Value = FPath then
    Exit;

  if Assigned(Value) then
    Path.Assign(Value)
  else
    Path.Clear;

  NotifyChanged;
end;

procedure TGMElevations.SetSamples(const Value: Integer);
var
  NewValue: Integer;
begin
  // Google ElevationService only accepts values in the range 2..512.
  // Clamp here so callers can set any integer safely and the component
  // keeps a valid request shape before it reaches JavaScript.
  NewValue := EnsureRange(Value, ELEVATION_MIN_SAMPLES, ELEVATION_MAX_SAMPLES);
  if FSamples = NewValue then
    Exit;

  FSamples := NewValue;
  NotifyChanged;
end;

procedure TGMElevations.SyncLastResponse(const AResponse: TGMElevationResponse);
begin
  FLastResponse := AResponse;
  FLastStatus := AResponse.Status;
  FLastErrorMessage := AResponse.ErrorMessage;
end;

function TGMElevations.TryGetFirstLocation(out ALatLng: TMapLibLatLng): Boolean;
begin
{$IFDEF FPC}
  Result := GMLibElevationResponseTryGetFirstLocation(FLastResponse, ALatLng);
{$ELSE}
  Result := FLastResponse.TryGetFirstLocation(ALatLng);
{$ENDIF}
end;

end.








