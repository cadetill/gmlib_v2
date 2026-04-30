{**
  @abstract(Tipos de apoyo para la geocodificación del mapa.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define el modelo de respuesta y el contrato de callback para las
  operaciones de geocodificación y geocodificación inversa.
}
unit uGMLib.GeoCode;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  fpjson,
  jsonparser,
  Math,
  SysUtils,
  Generics.Collections,
{$ELSE}
  System.Classes,
  System.JSON,
  System.Math,
  System.SysUtils,
  System.Generics.Collections,
{$ENDIF}
  uGMLib.Core.Component,
  uGMLib.Core.Types,
  uGMLib.MapOptions;

type
  {** @abstract(Una coincidencia devuelta por el geocoder.) }
  TGMGeocodeResult = record
    FormattedAddress: string;
    PlaceId: string;
    Latitude: Double;
    Longitude: Double;
    LocationType: string;
    PartialMatch: Boolean;
    TypesText: string;
  end;

  TGMGeocodeResults = array of TGMGeocodeResult;

  {** @abstract(Respuesta normalizada devuelta por el geocoder.) }
{$IFDEF FPC}
  TGMGeocodeResponse = record
    RequestId: string;
    Status: string;
    ErrorMessage: string;
    Results: TGMGeocodeResults;
  end;
{$ELSE}
  TGMGeocodeResponse = record
    RequestId: string;
    Status: string;
    ErrorMessage: string;
    Results: TGMGeocodeResults;

    class function FromJson(const AJson: string): TGMGeocodeResponse; static;
    function HasResults: Boolean;
    function TryGetFirstLocation(out ALatLng: TGMLibLatLng): Boolean;
    function TryGetFirstResult(out AResult: TGMGeocodeResult): Boolean;
  end;
{$ENDIF}

{$IFDEF FPC}
function GMLibGeocodeResponseFromJson(const AJson: string): TGMGeocodeResponse;
function GMLibGeocodeResponseHasResults(const AResponse: TGMGeocodeResponse): Boolean;
function GMLibGeocodeResponseTryGetFirstLocation(const AResponse: TGMGeocodeResponse;
  out ALatLng: TGMLibLatLng): Boolean;
function GMLibGeocodeResponseTryGetFirstResult(const AResponse: TGMGeocodeResponse;
  out AResult: TGMGeocodeResult): Boolean;
{$ENDIF}

type
  {** @abstract(Callback de completado para operaciones de geocodificación.) }
  TGMGeocodeCompletedEvent = procedure(Sender: TObject; const AResponse: TGMGeocodeResponse) of object;

  {** @abstract(Registro interno de una petición de geocodificación pendiente.) }
  TGMGeocodePendingRequest = class
  public
    RequestId: string;
    OnCompleted: TGMGeocodeCompletedEvent;
  end;

  {** @abstract(Componente de geocodificación ligado a un mapa.) }
  TGMGeoCode = class(TGMLibComponent)
  private
    FAddress: string;
    FBounds: TGMLatLngBounds;
    FLanguage: string;
    FLastErrorMessage: string;
    FLastResponse: TGMGeocodeResponse;
    FLastStatus: string;
    FLocation: TGMLibLatLng;
    FMap: TComponent;
    FOnCompleted: TGMGeocodeCompletedEvent;
    FOnChange: TNotifyEvent;
    FPlaceId: string;
    FRegion: string;
    procedure HandleCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
    procedure SetAddress(const Value: string);
    procedure SetBounds(const Value: TGMLatLngBounds);
    procedure SetLanguage(const Value: string);
    procedure SetLocation(const Value: TGMLibLatLng);
    procedure SetMap(const Value: TComponent);
    procedure SetPlaceId(const Value: string);
    procedure SetRegion(const Value: string);
    function GetCount: Integer;
  protected
    function GetAPIUrl: string; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure NotifyChanged; virtual;
    procedure SyncLastResponse(const AResponse: TGMGeocodeResponse);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure Geocode(const AAddress: string); overload;
    procedure Geocode(const ALatLng: TGMLibLatLng); overload;
    procedure Geocode(const ALat: Double; const ALng: Double); overload;
    procedure GeocodePlaceId(const APlaceId: string);
    procedure ReverseGeocode(const ALatLng: TGMLibLatLng);
    function GetResult(Index: Integer): TGMGeocodeResult;
    function TryGetFirstLocation(out ALatLng: TGMLibLatLng): Boolean;

    property Count: Integer read GetCount;
    property LastErrorMessage: string read FLastErrorMessage;
    property LastResponse: TGMGeocodeResponse read FLastResponse;
    property LastStatus: string read FLastStatus;
    property Map: TComponent read FMap write SetMap;
    property Results[Index: Integer]: TGMGeocodeResult read GetResult; default;
  published
    property AboutGMLib;
    property APIUrl;
    property Address: string read FAddress write SetAddress;
    property Bounds: TGMLatLngBounds read FBounds write SetBounds;
    property Language: string read FLanguage write SetLanguage;
    property Location: TGMLibLatLng read FLocation write SetLocation;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCompleted: TGMGeocodeCompletedEvent read FOnCompleted write FOnCompleted;
    property PlaceId: string read FPlaceId write SetPlaceId;
    property Region: string read FRegion write SetRegion;
  end;

implementation

uses
  uGMLib.Map;

function JoinStringArray(const AArray: TJSONArray): string;
var
  i: Integer;
begin
  Result := '';
  if not Assigned(AArray) then
    Exit;

  for i := 0 to AArray.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + '|';
{$IFDEF FPC}
    Result := Result + AArray.Items[i].AsString;
{$ELSE}
    Result := Result + AArray.Items[i].Value;
{$ENDIF}
  end;
end;

function ParseGeocodeResult(const AJsonObject: TJSONObject): TGMGeocodeResult;
var
  LocationObj: TJSONObject;
{$IFDEF FPC}
  LocationValue: TJSONData;
  TypesValue: TJSONData;
{$ELSE}
  LocationValue: TJSONValue;
  TypesValue: TJSONValue;
{$ENDIF}
begin
  Result := Default(TGMGeocodeResult);
  if not Assigned(AJsonObject) then
    Exit;

  { The response is flattened into a record so consumers can work with plain
    Delphi fields instead of navigating the JSON tree on every callback. }
{$IFDEF FPC}
  if Assigned(AJsonObject.Find('formattedAddress')) then
    Result.FormattedAddress := AJsonObject.Find('formattedAddress').AsString;
  if Assigned(AJsonObject.Find('placeId')) then
    Result.PlaceId := AJsonObject.Find('placeId').AsString;
  if Assigned(AJsonObject.Find('locationType')) then
    Result.LocationType := AJsonObject.Find('locationType').AsString;
  if Assigned(AJsonObject.Find('partialMatch')) then
    Result.PartialMatch := AJsonObject.Find('partialMatch').AsBoolean;
  if Assigned(AJsonObject.Find('typesText')) then
    Result.TypesText := AJsonObject.Find('typesText').AsString;
{$ELSE}
  Result.FormattedAddress := AJsonObject.GetValue<string>('formattedAddress', '');
  Result.PlaceId := AJsonObject.GetValue<string>('placeId', '');
  Result.LocationType := AJsonObject.GetValue<string>('locationType', '');
  Result.PartialMatch := AJsonObject.GetValue<Boolean>('partialMatch', False);
  Result.TypesText := AJsonObject.GetValue<string>('typesText', '');
{$ENDIF}

{$IFDEF FPC}
  LocationValue := AJsonObject.Find('location');
  if LocationValue is TJSONObject then
  begin
    LocationObj := TJSONObject(LocationValue);
{$IFDEF FPC}
    if Assigned(LocationObj.Find('lat')) then
      Result.Latitude := LocationObj.Find('lat').AsFloat;
    if Assigned(LocationObj.Find('lng')) then
      Result.Longitude := LocationObj.Find('lng').AsFloat;
{$ELSE}
    LocationObj.TryGetValue<Double>('lat', Result.Latitude);
    LocationObj.TryGetValue<Double>('lng', Result.Longitude);
{$ENDIF}
  end;

  TypesValue := AJsonObject.Find('types');
  if TypesValue is TJSONArray then
    Result.TypesText := JoinStringArray(TJSONArray(TypesValue));
{$ELSE}
  LocationValue := AJsonObject.Values['location'];
  if LocationValue is TJSONObject then
  begin
    LocationObj := TJSONObject(LocationValue);
    LocationObj.TryGetValue<Double>('lat', Result.Latitude);
    LocationObj.TryGetValue<Double>('lng', Result.Longitude);
  end;

  TypesValue := AJsonObject.Values['types'];
  if TypesValue is TJSONArray then
    Result.TypesText := JoinStringArray(TJSONArray(TypesValue));
{$ENDIF}
end;

{ TGMGeoCode }

procedure TGMGeoCode.Assign(Source: TPersistent);
begin
  if Source is TGMGeoCode then
  begin
    Address := TGMGeoCode(Source).Address;
    Bounds.Assign(TGMGeoCode(Source).Bounds);
    Language := TGMGeoCode(Source).Language;
    Location.Assign(TGMGeoCode(Source).Location);
    PlaceId := TGMGeoCode(Source).PlaceId;
    Region := TGMGeoCode(Source).Region;
    Exit;
  end;

  inherited;
end;

procedure TGMGeoCode.Clear;
begin
  FLastResponse := Default(TGMGeocodeResponse);
  FLastStatus := '';
  FLastErrorMessage := '';
  NotifyChanged;
end;

constructor TGMGeoCode.Create(AOwner: TComponent);
begin
  inherited;

  FBounds := TGMLatLngBounds.Create;
  FLocation := TGMLibLatLng.Create(0, 0);
  FLanguage := '';
  FRegion := '';
end;

destructor TGMGeoCode.Destroy;
begin
  Map := nil;
  FLocation.Free;
  FBounds.Free;
  inherited;
end;

procedure TGMGeoCode.Geocode(const AAddress: string);
begin
  Address := AAddress;
  PlaceId := '';
  if Assigned(FMap) then
{$IFDEF FPC}
    TGMCustomMap(FMap).GeocodeAddress(AAddress, @HandleCompleted);
{$ELSE}
    TGMCustomMap(FMap).GeocodeAddress(AAddress, HandleCompleted);
{$ENDIF}
end;

procedure TGMGeoCode.Geocode(const ALatLng: TGMLibLatLng);
begin
  if not Assigned(ALatLng) then
    Exit;

  Location.Assign(ALatLng);
  PlaceId := '';
  Address := '';
  if Assigned(FMap) then
{$IFDEF FPC}
    TGMCustomMap(FMap).ReverseGeocode(ALatLng, @HandleCompleted);
{$ELSE}
    TGMCustomMap(FMap).ReverseGeocode(ALatLng, HandleCompleted);
{$ENDIF}
end;

procedure TGMGeoCode.Geocode(const ALat: Double; const ALng: Double);
begin
  Location.Lat := ALat;
  Location.Lng := ALng;
  Geocode(Location);
end;

procedure TGMGeoCode.GeocodePlaceId(const APlaceId: string);
begin
  PlaceId := APlaceId;
  Address := '';
  if Assigned(FMap) then
{$IFDEF FPC}
    TGMCustomMap(FMap).GeocodePlaceId(APlaceId, @HandleCompleted);
{$ELSE}
    TGMCustomMap(FMap).GeocodePlaceId(APlaceId, HandleCompleted);
{$ENDIF}
end;

function TGMGeoCode.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/geocoder';
end;

function TGMGeoCode.GetCount: Integer;
begin
  Result := Length(FLastResponse.Results);
end;

function TGMGeoCode.GetResult(Index: Integer): TGMGeocodeResult;
begin
  Result := Default(TGMGeocodeResult);
  if (Index < 0) or (Index >= Length(FLastResponse.Results)) then
    Exit;
  Result := FLastResponse.Results[Index];
end;

procedure TGMGeoCode.HandleCompleted(Sender: TObject; const AResponse: TGMGeocodeResponse);
begin
  { Cache first, notify second: UI code can read LastResponse immediately from
    the event handler without depending on the callback payload alone. }
  SyncLastResponse(AResponse);
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, AResponse);
  NotifyChanged;
end;

procedure TGMGeoCode.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FMap) then
    FMap := nil;
end;

procedure TGMGeoCode.NotifyChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMGeoCode.ReverseGeocode(const ALatLng: TGMLibLatLng);
begin
  if not Assigned(ALatLng) then
    Exit;

  Geocode(ALatLng);
end;

procedure TGMGeoCode.SetAddress(const Value: string);
begin
  if FAddress = Value then
    Exit;
  FAddress := Value;
  NotifyChanged;
end;

procedure TGMGeoCode.SetBounds(const Value: TGMLatLngBounds);
begin
  if Assigned(Value) then
    FBounds.Assign(Value);
  NotifyChanged;
end;

procedure TGMGeoCode.SetLanguage(const Value: string);
begin
  if FLanguage = Value then
    Exit;
  FLanguage := Value;
  NotifyChanged;
end;

procedure TGMGeoCode.SetLocation(const Value: TGMLibLatLng);
begin
  if Assigned(Value) then
    FLocation.Assign(Value);
  NotifyChanged;
end;

procedure TGMGeoCode.SetMap(const Value: TComponent);
begin
  if FMap = Value then
    Exit;

  if Assigned(FMap) then
    FMap.RemoveFreeNotification(Self);

  FMap := Value;

  if Assigned(FMap) then
    FMap.FreeNotification(Self);
end;

procedure TGMGeoCode.SetPlaceId(const Value: string);
begin
  if FPlaceId = Value then
    Exit;
  FPlaceId := Value;
  NotifyChanged;
end;

procedure TGMGeoCode.SetRegion(const Value: string);
begin
  if FRegion = Value then
    Exit;
  FRegion := Value;
  NotifyChanged;
end;

procedure TGMGeoCode.SyncLastResponse(const AResponse: TGMGeocodeResponse);
begin
  FLastResponse := AResponse;
  FLastStatus := AResponse.Status;
  FLastErrorMessage := AResponse.ErrorMessage;
end;

function TGMGeoCode.TryGetFirstLocation(out ALatLng: TGMLibLatLng): Boolean;
begin
{$IFDEF FPC}
  Result := GMLibGeocodeResponseTryGetFirstLocation(FLastResponse, ALatLng);
{$ELSE}
  Result := FLastResponse.TryGetFirstLocation(ALatLng);
{$ENDIF}
end;

{$IFNDEF FPC}
class function TGMGeocodeResponse.FromJson(const AJson: string): TGMGeocodeResponse;
var
  JsonValue: TJSONValue;
  JsonObject: TJSONObject;
  ResultsValue: TJSONValue;
  ResultsArray: TJSONArray;
  i: Integer;
begin
  Result := Default(TGMGeocodeResponse);
  if AJson = '' then
    Exit;

  { Parsing stays isolated here so the bridge can stay small and exceptions do
    not leak into the map event loop. }
  try
    JsonValue := TJSONObject.ParseJSONValue(AJson);
    try
      if not (JsonValue is TJSONObject) then
        Exit;

      JsonObject := TJSONObject(JsonValue);
      Result.RequestId := JsonObject.GetValue<string>('requestId', '');
      Result.Status := JsonObject.GetValue<string>('status', '');
      Result.ErrorMessage := JsonObject.GetValue<string>('errorMessage', '');

      ResultsValue := JsonObject.Values['results'];
      if ResultsValue is TJSONArray then
      begin
        ResultsArray := TJSONArray(ResultsValue);
        SetLength(Result.Results, ResultsArray.Count);
        for i := 0 to ResultsArray.Count - 1 do
          if ResultsArray.Items[i] is TJSONObject then
            Result.Results[i] := ParseGeocodeResult(TJSONObject(ResultsArray.Items[i]));
      end;
    finally
      JsonValue.Free;
    end;
  except
    Result := Default(TGMGeocodeResponse);
  end;
end;

function TGMGeocodeResponse.HasResults: Boolean;
begin
  Result := Length(Results) > 0;
end;

function TGMGeocodeResponse.TryGetFirstLocation(out ALatLng: TGMLibLatLng): Boolean;
var
  FirstResult: TGMGeocodeResult;
begin
  ALatLng := nil;
  Result := TryGetFirstResult(FirstResult);
  if not Result then
    Exit;

  ALatLng := TGMLibLatLng.Create(FirstResult.Latitude, FirstResult.Longitude);
end;

function TGMGeocodeResponse.TryGetFirstResult(out AResult: TGMGeocodeResult): Boolean;
begin
  Result := Length(Results) > 0;
  if not Result then
  begin
    AResult := Default(TGMGeocodeResult);
    Exit;
  end;

  AResult := Results[0];
end;
{$ENDIF}
{$IFDEF FPC}
function GMLibGeocodeResponseFromJson(const AJson: string): TGMGeocodeResponse;
var
  JsonValue: TJSONData;
  JsonObject: TJSONObject;
  ResultsValue: TJSONData;
  ResultsArray: TJSONArray;
  i: Integer;
begin
  Result := Default(TGMGeocodeResponse);
  if AJson = '' then
    Exit;

  JsonValue := GetJSON(AJson);
  try
    if not (JsonValue is TJSONObject) then
      Exit;

    JsonObject := TJSONObject(JsonValue);
    if Assigned(JsonObject.Find('requestId')) then
      Result.RequestId := JsonObject.Find('requestId').AsString;
    if Assigned(JsonObject.Find('status')) then
      Result.Status := JsonObject.Find('status').AsString;
    if Assigned(JsonObject.Find('errorMessage')) then
      Result.ErrorMessage := JsonObject.Find('errorMessage').AsString;

    ResultsValue := JsonObject.Find('results');
    if ResultsValue is TJSONArray then
    begin
      ResultsArray := TJSONArray(ResultsValue);
      SetLength(Result.Results, ResultsArray.Count);
      for i := 0 to ResultsArray.Count - 1 do
        if ResultsArray.Items[i] is TJSONObject then
          Result.Results[i] := ParseGeocodeResult(TJSONObject(ResultsArray.Items[i]));
    end;
  finally
    JsonValue.Free;
  end;
end;

function GMLibGeocodeResponseHasResults(const AResponse: TGMGeocodeResponse): Boolean;
begin
  Result := Length(AResponse.Results) > 0;
end;

function GMLibGeocodeResponseTryGetFirstResult(const AResponse: TGMGeocodeResponse;
  out AResult: TGMGeocodeResult): Boolean;
begin
  Result := Length(AResponse.Results) > 0;
  if not Result then
  begin
    AResult := Default(TGMGeocodeResult);
    Exit;
  end;

  AResult := AResponse.Results[0];
end;

function GMLibGeocodeResponseTryGetFirstLocation(const AResponse: TGMGeocodeResponse;
  out ALatLng: TGMLibLatLng): Boolean;
var
  FirstResult: TGMGeocodeResult;
begin
  ALatLng := nil;
  Result := GMLibGeocodeResponseTryGetFirstResult(AResponse, FirstResult);
  if not Result then
    Exit;

  ALatLng := TGMLibLatLng.Create(FirstResult.Latitude, FirstResult.Longitude);
end;
{$ENDIF}

end.
