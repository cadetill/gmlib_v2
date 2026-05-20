{**
  @abstract(Modelo de rutas del mapa.)
}
unit uGMLib.Routes;

{$I ..\..\..\gmlib.inc}

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
  uMapLib.Core.Component,
  uGMLib.Core.Types,
  uGMLib.Platform.Format,
  uGMLib.Polyline;

type
  TGMRouteTravelMode = (
    rtmDrive,
    rtmBicycle,
    rtmWalk,
    rtmTwoWheeler,
    rtmTransit
  );

  TGMRouteRoutingPreference = (
    rrpTrafficUnaware,
    rrpTrafficAware,
    rrpTrafficAwareOptimal
  );

  TGMRouteUnits = (
    ruUnspecified,
    ruMetric,
    ruImperial
  );

  TGMRouteWaypointLocationMode = (
    rwlmLatLng,
    rwlmAddress
  );

  TGMRouteResult = record
    DistanceMeters: Double;
    DurationMillis: Int64;
    StaticDurationMillis: Int64;
    LocalizedDistance: string;
    LocalizedDuration: string;
    LocalizedStaticDuration: string;
    RouteLabelsText: string;
    WarningsText: string;
    PathJson: string;
  end;

  TGMRouteResults = array of TGMRouteResult;

  TGMRouteWaypoint = class;
  TGMRouteWaypoints = class;

  TGMRouteWaypoint = class(TCollectionItem)
  private
    FAddress: string;
    FLocation: TMapLibLatLng;
    FLocationMode: TGMRouteWaypointLocationMode;
    FSideOfRoad: Boolean;
    FVehicleStopover: Boolean;
    FVia: Boolean;
    procedure LocationChanged(Sender: TObject);
    procedure SetAddress(const Value: string);
    procedure SetLocation(const Value: TMapLibLatLng);
    procedure SetLocationMode(const Value: TGMRouteWaypointLocationMode);
    procedure SetSideOfRoad(const Value: Boolean);
    procedure SetVehicleStopover(const Value: Boolean);
    procedure SetVia(const Value: Boolean);
  protected
{$IFNDEF FPC}
    function GetDisplayName: string; override;
{$ENDIF}
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function ToJsonObject: TJSONObject;
  published
    property Address: string read FAddress write SetAddress;
    property Location: TMapLibLatLng read FLocation write SetLocation;
    property LocationMode: TGMRouteWaypointLocationMode read FLocationMode write SetLocationMode default rwlmLatLng;
    property SideOfRoad: Boolean read FSideOfRoad write SetSideOfRoad default False;
    property VehicleStopover: Boolean read FVehicleStopover write SetVehicleStopover default False;
    property Via: Boolean read FVia write SetVia default False;
  end;

  TGMRouteWaypoints = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TGMRouteWaypoint;
    procedure SetItem(Index: Integer; const Value: TGMRouteWaypoint);
  protected
    procedure NotifyChange;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMRouteWaypoint; overload;
    function Add(const AAddress: string): TGMRouteWaypoint; overload;
    function Add(ALatitude, ALongitude: Double): TGMRouteWaypoint; overload;
    procedure Assign(Source: TPersistent); override;
    function IsEmpty: Boolean;
    function ToJsonArray: TJSONArray;
    property Items[Index: Integer]: TGMRouteWaypoint read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

{$IFDEF FPC}
  TGMRouteResponse = record
    RequestId: string;
    Status: string;
    ErrorMessage: string;
    Results: TGMRouteResults;
  end;
{$ELSE}
  TGMRouteResponse = record
  public
    RequestId: string;
    Status: string;
    ErrorMessage: string;
    Results: TGMRouteResults;

    class function FromJson(const AJson: string): TGMRouteResponse; static;
    function HasResults: Boolean;
  end;
{$ENDIF}

{$IFDEF FPC}
function GMLibRouteResponseFromJson(const AJson: string): TGMRouteResponse;
function GMLibRouteResponseHasResults(const AResponse: TGMRouteResponse): Boolean;
{$ENDIF}

function GMLibRouteResultPathToPolylinePath(const AResult: TGMRouteResult): TGMPolylinePath;
function TryGetRoutePathBounds(const APathJson: string; out ANorth, ASouth,
  AEast, AWest: Double): Boolean;

type
  TGMRouteQueryResult = class
  private
    FOwner: TObject;
    FPolylineObjectId: TGMObjectId;
    FPolylineOptions: TGMPolylineOptions;
    FResponseResult: TGMRouteResult;
    function GetMap: TComponent;
    function GetViewportHost: IGMMapViewportHost;
    function GetVisible: Boolean;
    procedure PolylineOptionsChanged(Sender: TObject);
    procedure RemoveRenderedPolylineFromMap(AMap: TComponent);
    procedure SetVisible(const Value: Boolean);
    procedure SyncRenderedPolyline;
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    procedure MapChanged(const AOldMap, ANewMap: TComponent);
    procedure ZoomToRoute;
    procedure SyncResponseResult(const AResult: TGMRouteResult; ADefaultVisible: Boolean);

    property Map: TComponent read GetMap;
    property Owner: TObject read FOwner;
    property PolylineOptions: TGMPolylineOptions read FPolylineOptions;
    property ResponseResult: TGMRouteResult read FResponseResult;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  TGMRouteQuery = class
  private
    FCompleted: Boolean;
    FOwner: TObject;
    FRequestId: string;
    FRequestLiteral: string;
    FResponse: TGMRouteResponse;
    {$IFDEF FPC}
    FResults: specialize TObjectList<TGMRouteQueryResult>;
    {$ELSE}
    FResults: TObjectList<TGMRouteQueryResult>;
    {$ENDIF}
    FVisible: Boolean;
    function GetCount: Integer;
    function GetErrorMessage: string;
    function GetResult(Index: Integer): TGMRouteResult;
    function GetResultItem(Index: Integer): TGMRouteQueryResult;
    function GetStatus: string;
    procedure SetVisible(const Value: Boolean);
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    procedure Clear;
    function HasResults: Boolean;
    procedure SyncResponse(const AResponse: TGMRouteResponse);
    procedure SyncMapState;

    property Completed: Boolean read FCompleted;
    property Count: Integer read GetCount;
    property ErrorMessage: string read GetErrorMessage;
    property Owner: TObject read FOwner;
    property RequestId: string read FRequestId write FRequestId;
    property RequestLiteral: string read FRequestLiteral write FRequestLiteral;
    property Response: TGMRouteResponse read FResponse;
    property Results[Index: Integer]: TGMRouteResult read GetResult; default;
    property ResultItems[Index: Integer]: TGMRouteQueryResult read GetResultItem;
    property Status: string read GetStatus;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TGMRouteCompletedEvent = procedure(Sender: TObject; const AResponse: TGMRouteResponse) of object;

  TGMRoutePendingRequest = class
  public
    RequestId: string;
    OnCompleted: TGMRouteCompletedEvent;
  end;

  TGMRoutes = class(TMapLibComponent)
  private
    FAvoidFerries: Boolean;
    FAvoidHighways: Boolean;
    FAvoidIndoor: Boolean;
    FAvoidTolls: Boolean;
    FCloseOthersBeforeVisible: Boolean;
    FClosingOthersBeforeVisible: Boolean;
    FComputeAlternativeRoutes: Boolean;
    FDestinationAddress: string;
    FDestinationLocation: TMapLibLatLng;
    FLastErrorMessage: string;
    FLastResponse: TGMRouteResponse;
    FLastStatus: string;
    FLanguageCode: string;
    FMap: TComponent;
    FOnChange: TNotifyEvent;
    FOnCompleted: TGMRouteCompletedEvent;
    FOriginAddress: string;
    FOriginLocation: TMapLibLatLng;
    FOptimizeWaypointOrder: Boolean;
    {$IFDEF FPC}
    FQueries: specialize TObjectList<TGMRouteQuery>;
    {$ELSE}
    FQueries: TObjectList<TGMRouteQuery>;
    {$ENDIF}
    FIntermediateWaypoints: TGMRouteWaypoints;
    FRequestFields: string;
    FRoutingPreference: TGMRouteRoutingPreference;
    FTravelMode: TGMRouteTravelMode;
    FUnits: TGMRouteUnits;
    FWaypoints: TGMPolylinePath;
    function FindQueryByRequestId(const ARequestId: string): TGMRouteQuery;
    procedure NotifyQueriesMapChanged(const AOldMap, ANewMap: TComponent);
    procedure HandleCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
    procedure NotifyChanged;
    procedure PathChanged(Sender: TObject);
    procedure HideOtherRoutes(AExcept: TGMRouteQueryResult);
    procedure SetAvoidFerries(const Value: Boolean);
    procedure SetAvoidHighways(const Value: Boolean);
    procedure SetAvoidIndoor(const Value: Boolean);
    procedure SetAvoidTolls(const Value: Boolean);
    procedure SetCloseOthersBeforeVisible(const Value: Boolean);
    procedure SetComputeAlternativeRoutes(const Value: Boolean);
    procedure SetDestinationAddress(const Value: string);
    procedure SetDestinationLocation(const Value: TMapLibLatLng);
    procedure SetLanguageCode(const Value: string);
    procedure SetMap(const Value: TComponent);
    procedure SetOptimizeWaypointOrder(const Value: Boolean);
    procedure SetOriginAddress(const Value: string);
    procedure SetOriginLocation(const Value: TMapLibLatLng);
    procedure SetRequestFields(const Value: string);
    procedure SetRoutingPreference(const Value: TGMRouteRoutingPreference);
    procedure SetTravelMode(const Value: TGMRouteTravelMode);
    procedure SetUnits(const Value: TGMRouteUnits);
    procedure SetWaypoints(const Value: TGMPolylinePath);
    function BuildRequestLiteral: string;
    function GetCount: Integer;
    function GetQuery(Index: Integer): TGMRouteQuery;
    function GetQueryCount: Integer;
  protected
    function GetDocumentationUrl: string; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SyncLastResponse(const AResponse: TGMRouteResponse);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure Execute;
    function ExecuteQuery: TGMRouteQuery;
    function GetResult(Index: Integer): TGMRouteResult;

    property Count: Integer read GetCount;
    property CloseOthersBeforeVisible: Boolean read FCloseOthersBeforeVisible write SetCloseOthersBeforeVisible default False;
    property LastErrorMessage: string read FLastErrorMessage;
    property LastResponse: TGMRouteResponse read FLastResponse;
    property LastStatus: string read FLastStatus;
    property Map: TComponent read FMap write SetMap;
    property Queries[Index: Integer]: TGMRouteQuery read GetQuery;
    property QueryCount: Integer read GetQueryCount;
    property Results[Index: Integer]: TGMRouteResult read GetResult; default;
    property Waypoints: TGMPolylinePath read FWaypoints write SetWaypoints;
  published
    property AvoidFerries: Boolean read FAvoidFerries write SetAvoidFerries default False;
    property AvoidHighways: Boolean read FAvoidHighways write SetAvoidHighways default False;
    property AvoidIndoor: Boolean read FAvoidIndoor write SetAvoidIndoor default False;
    property AvoidTolls: Boolean read FAvoidTolls write SetAvoidTolls default False;
    property ComputeAlternativeRoutes: Boolean read FComputeAlternativeRoutes write SetComputeAlternativeRoutes default False;
    property DestinationAddress: string read FDestinationAddress write SetDestinationAddress;
    property DestinationLocation: TMapLibLatLng read FDestinationLocation write SetDestinationLocation;
    property LanguageCode: string read FLanguageCode write SetLanguageCode;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCompleted: TGMRouteCompletedEvent read FOnCompleted write FOnCompleted;
    property OptimizeWaypointOrder: Boolean read FOptimizeWaypointOrder write SetOptimizeWaypointOrder default False;
    property OriginAddress: string read FOriginAddress write SetOriginAddress;
    property OriginLocation: TMapLibLatLng read FOriginLocation write SetOriginLocation;
    property RequestFields: string read FRequestFields write SetRequestFields;
    property RoutingPreference: TGMRouteRoutingPreference read FRoutingPreference write SetRoutingPreference default rrpTrafficUnaware;
    property TravelMode: TGMRouteTravelMode read FTravelMode write SetTravelMode default rtmDrive;
    property Units: TGMRouteUnits read FUnits write SetUnits default ruUnspecified;
    property IntermediateWaypoints: TGMRouteWaypoints read FIntermediateWaypoints;
  end;

implementation

uses
  uGMLib.Map;

{ TGMRouteQueryResult }

constructor TGMRouteQueryResult.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := AOwner;
  FPolylineOptions := TGMPolylineOptions.Create;
{$IFDEF FPC}
  FPolylineOptions.OnChange := @PolylineOptionsChanged;
{$ELSE}
  FPolylineOptions.OnChange := PolylineOptionsChanged;
{$ENDIF}
  FPolylineOptions.Visible := False;
end;

destructor TGMRouteQueryResult.Destroy;
begin
  RemoveRenderedPolylineFromMap(GetMap);
  FPolylineOptions.Free;
  inherited;
end;

function TGMRouteQueryResult.GetMap: TComponent;
begin
  Result := nil;
  if Assigned(FOwner) and (FOwner is TGMRouteQuery) and
     Assigned(TGMRouteQuery(FOwner).Owner) and
     (TGMRouteQuery(FOwner).Owner is TGMRoutes) then
    Result := TGMRoutes(TGMRouteQuery(FOwner).Owner).Map;
end;

function TGMRouteQueryResult.GetViewportHost: IGMMapViewportHost;
var
  MapComponent: TComponent;
  MapInstance: TGMCustomMap;
begin
  Result := nil;
  MapComponent := GetMap;
  if not Assigned(MapComponent) or not (MapComponent is TGMCustomMap) then
    Exit;

  MapInstance := TGMCustomMap(MapComponent);
  if not Supports(MapInstance, IGMMapViewportHost, Result) then
    Result := nil;
end;

function TGMRouteQueryResult.GetVisible: Boolean;
begin
  Result := FPolylineOptions.Visible;
end;

procedure TGMRouteQueryResult.MapChanged(const AOldMap, ANewMap: TComponent);
begin
  if Assigned(ANewMap) then
  begin
    // no-op: keeps both map parameters intentionally consumed in all compilers
  end;
  RemoveRenderedPolylineFromMap(AOldMap);
  SyncRenderedPolyline;
end;

procedure TGMRouteQueryResult.PolylineOptionsChanged(Sender: TObject);
begin
  SyncRenderedPolyline;
end;

procedure TGMRouteQueryResult.RemoveRenderedPolylineFromMap(AMap: TComponent);
var
  MapInstance: TGMCustomMap;
  Polyline: TGMPolylineItem;
begin
  if (FPolylineObjectId = '') or not Assigned(AMap) or not (AMap is TGMCustomMap) then
  begin
    FPolylineObjectId := '';
    Exit;
  end;

  MapInstance := TGMCustomMap(AMap);
  Polyline := MapInstance.Polylines.FindByObjectId(FPolylineObjectId);
  if Assigned(Polyline) then
    Polyline.Free;
  FPolylineObjectId := '';
end;

procedure TGMRouteQueryResult.SetVisible(const Value: Boolean);
var
  Routes: TGMRoutes;
begin
  if Value and Assigned(FOwner) and (FOwner is TGMRouteQuery) and
     Assigned(TGMRouteQuery(FOwner).Owner) and
     (TGMRouteQuery(FOwner).Owner is TGMRoutes) then
  begin
    Routes := TGMRoutes(TGMRouteQuery(FOwner).Owner);
    if Routes.CloseOthersBeforeVisible then
      Routes.HideOtherRoutes(Self);
  end;

  FPolylineOptions.Visible := Value;
end;

procedure TGMRouteQueryResult.ZoomToRoute;
var
  East: Double;
  North: Double;
  South: Double;
  ViewportHost: IGMMapViewportHost;
  West: Double;
begin
  if not TryGetRoutePathBounds(FResponseResult.PathJson, North, South, East, West) then
    Exit;

  ViewportHost := GetViewportHost;
  if not Assigned(ViewportHost) then
    Exit;

  ViewportHost.FitBounds(North, South, East, West);
end;

procedure TGMRouteQueryResult.SyncRenderedPolyline;
var
  MapInstance: TGMCustomMap;
  Polyline: TGMPolylineItem;
  CurrentMap: TComponent;
begin
  CurrentMap := GetMap;
  if not Assigned(CurrentMap) or not (CurrentMap is TGMCustomMap) then
  begin
    FPolylineObjectId := '';
    Exit;
  end;

  MapInstance := TGMCustomMap(CurrentMap);

  if FPolylineObjectId <> '' then
    Polyline := MapInstance.Polylines.FindByObjectId(FPolylineObjectId)
  else
    Polyline := nil;

  if not FPolylineOptions.Visible or FPolylineOptions.Path.IsEmpty then
  begin
    { When the result is hidden or empty we remove the rendered polyline so
      the map always reflects the current visibility state. }
    if Assigned(Polyline) then
      Polyline.Free;
    FPolylineObjectId := '';
    Exit;
  end;

  if not Assigned(Polyline) then
  begin
    Polyline := MapInstance.Polylines.Add;
    FPolylineObjectId := Polyline.ObjectId;
  end;

  Polyline.Options.Assign(FPolylineOptions);
end;

procedure TGMRouteQueryResult.SyncResponseResult(const AResult: TGMRouteResult;
  ADefaultVisible: Boolean);
var
  Path: TGMPolylinePath;
begin
  FResponseResult := AResult;
  Path := GMLibRouteResultPathToPolylinePath(AResult);
  try
    { Path and visibility are batched to avoid re-rendering the polyline on
      every intermediate property assignment. }
    FPolylineOptions.BeginUpdate;
    try
      FPolylineOptions.Visible := False;
      FPolylineOptions.Path.Assign(Path);
      FPolylineOptions.Visible := ADefaultVisible;
    finally
      FPolylineOptions.EndUpdate;
    end;
  finally
    Path.Free;
  end;
  SyncRenderedPolyline;
end;

{ TGMRouteQuery }

constructor TGMRouteQuery.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := AOwner;
  FVisible := True;
{$IFDEF FPC}
  FResults := specialize TObjectList<TGMRouteQueryResult>.Create(True);
{$ELSE}
  FResults := TObjectList<TGMRouteQueryResult>.Create(True);
{$ENDIF}
end;

destructor TGMRouteQuery.Destroy;
begin
  FResults.Free;
  inherited;
end;

procedure TGMRouteQuery.Clear;
begin
  FCompleted := False;
  FResponse := Default(TGMRouteResponse);
  FResults.Clear;
end;

function TGMRouteQuery.GetCount: Integer;
begin
  Result := FResults.Count;
end;

function TGMRouteQuery.GetErrorMessage: string;
begin
  Result := FResponse.ErrorMessage;
end;

function TGMRouteQuery.GetResult(Index: Integer): TGMRouteResult;
begin
  Result := Default(TGMRouteResult);
  if (Index < 0) or (Index >= FResults.Count) then
    Exit;
  Result := FResults[Index].ResponseResult;
end;

function TGMRouteQuery.GetResultItem(Index: Integer): TGMRouteQueryResult;
begin
  Result := nil;
  if (Index < 0) or (Index >= FResults.Count) then
    Exit;
  Result := FResults[Index];
end;

function TGMRouteQuery.GetStatus: string;
begin
  Result := FResponse.Status;
end;

procedure TGMRouteQuery.SetVisible(const Value: Boolean);
var
  i: Integer;
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  if not Value then
  begin
    for i := 0 to FResults.Count - 1 do
      FResults[i].Visible := False;
    Exit;
  end;

  if FResults.Count > 0 then
    FResults[0].Visible := True;
end;

function TGMRouteQuery.HasResults: Boolean;
begin
{$IFDEF FPC}
  Result := GMLibRouteResponseHasResults(FResponse);
{$ELSE}
  Result := FResponse.HasResults;
{$ENDIF}
end;

procedure TGMRouteQuery.SyncResponse(const AResponse: TGMRouteResponse);
var
  i: Integer;
  ResultItem: TGMRouteQueryResult;
begin
  FResponse := AResponse;
  FCompleted := True;
  FResults.Clear;

  { Every returned route result gets its own renderable wrapper so the UI can
    toggle and zoom each alternative independently. }
  for i := 0 to Length(AResponse.Results) - 1 do
  begin
    ResultItem := TGMRouteQueryResult.Create(Self);
    FResults.Add(ResultItem);
    ResultItem.SyncResponseResult(AResponse.Results[i], FVisible and (i = 0));
  end;
end;

procedure TGMRouteQuery.SyncMapState;
var
  i: Integer;
begin
  for i := 0 to FResults.Count - 1 do
    FResults[i].SyncRenderedPolyline;
end;

function RouteTravelModeToJs(const AValue: TGMRouteTravelMode): string;
begin
  case AValue of
    rtmDrive: Result := 'DRIVING';
    rtmBicycle: Result := 'BICYCLE';
    rtmWalk: Result := 'WALK';
    rtmTwoWheeler: Result := 'TWO_WHEELER';
    rtmTransit: Result := 'TRANSIT';
  end;
end;

function RouteRoutingPreferenceToJs(const AValue: TGMRouteRoutingPreference): string;
begin
  case AValue of
    rrpTrafficAware: Result := 'TRAFFIC_AWARE';
    rrpTrafficAwareOptimal: Result := 'TRAFFIC_AWARE_OPTIMAL';
  else
    Result := 'TRAFFIC_UNAWARE';
  end;
end;

function RouteUnitsToJs(const AValue: TGMRouteUnits): string;
begin
  case AValue of
    ruMetric: Result := 'METRIC';
    ruImperial: Result := 'IMPERIAL';
  else
    Result := 'UNITS_UNSPECIFIED';
  end;
end;

function JavaScriptQuotedStr(const AValue: string): string;
begin
  Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '\''', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := '''' + Result + '''';
end;

function AddJsonLocation(const AOwner: TJSONObject; const AName: string;
  const AAddress: string; const ALocation: TMapLibLatLng): Boolean;
var
  LocationObject: TJSONObject;
begin
  Result := False;
  if not Assigned(AOwner) then
    Exit;

  if AAddress <> '' then
  begin
{$IFDEF FPC}
    AOwner.Add(AName, AAddress);
{$ELSE}
    AOwner.AddPair(AName, AAddress);
{$ENDIF}
    Exit(True);
  end;

  if not Assigned(ALocation) then
    Exit;

  LocationObject := TJSONObject.Create;
{$IFDEF FPC}
  LocationObject.Add('lat', GetJSON(FloatToStr(ALocation.Lat, GMLibInvariantFormatSettings)));
  LocationObject.Add('lng', GetJSON(FloatToStr(ALocation.Lng, GMLibInvariantFormatSettings)));
  AOwner.Add(AName, LocationObject);
{$ELSE}
  LocationObject.AddPair('lat', TJSONNumber.Create(ALocation.Lat));
  LocationObject.AddPair('lng', TJSONNumber.Create(ALocation.Lng));
  AOwner.AddPair(AName, LocationObject);
{$ENDIF}
  Result := True;
end;

function AddJsonBool(const AOwner: TJSONObject; const AName: string; const AValue: Boolean): Boolean;
begin
  Result := Assigned(AOwner);
  if not Result then
    Exit;
{$IFDEF FPC}
  AOwner.Add(AName, TJSONBoolean.Create(AValue));
{$ELSE}
  AOwner.AddPair(AName, TJSONBool.Create(AValue));
{$ENDIF}
end;

function AddJsonWaypointLocation(const AOwner: TJSONObject; const AWaypoint: TGMRouteWaypoint): Boolean;
var
  LocationObject: TJSONObject;
begin
  Result := False;
  if not Assigned(AOwner) or not Assigned(AWaypoint) then
    Exit;

  if AWaypoint.LocationMode = rwlmAddress then
  begin
{$IFDEF FPC}
    AOwner.Add('location', AWaypoint.Address);
{$ELSE}
    AOwner.AddPair('location', AWaypoint.Address);
{$ENDIF}
    Exit(True);
  end;

  LocationObject := TJSONObject.Create;
{$IFDEF FPC}
  LocationObject.Add('lat', GetJSON(FloatToStr(AWaypoint.Location.Lat, GMLibInvariantFormatSettings)));
  LocationObject.Add('lng', GetJSON(FloatToStr(AWaypoint.Location.Lng, GMLibInvariantFormatSettings)));
  AOwner.Add('location', LocationObject);
{$ELSE}
  LocationObject.AddPair('lat', TJSONNumber.Create(AWaypoint.Location.Lat));
  LocationObject.AddPair('lng', TJSONNumber.Create(AWaypoint.Location.Lng));
  AOwner.AddPair('location', LocationObject);
{$ENDIF}
  Result := True;
end;

function BuildWaypointJsonObjectFromLatLng(const ALatitude, ALongitude: Double): TJSONObject;
var
  LocationObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  LocationObject := TJSONObject.Create;
{$IFDEF FPC}
  LocationObject.Add('lat', GetJSON(FloatToStr(ALatitude, GMLibInvariantFormatSettings)));
  LocationObject.Add('lng', GetJSON(FloatToStr(ALongitude, GMLibInvariantFormatSettings)));
  Result.Add('location', LocationObject);
{$ELSE}
  LocationObject.AddPair('lat', TJSONNumber.Create(ALatitude));
  LocationObject.AddPair('lng', TJSONNumber.Create(ALongitude));
  Result.AddPair('location', LocationObject);
{$ENDIF}
end;

function BuildJsonArrayFromCommaSeparatedText(const AText: string): TJSONArray;
var
  Items: TStringList;
  i: Integer;
  Item: string;
begin
  Result := TJSONArray.Create;
  if Trim(AText) = '' then
  begin
    Result.Add('*');
    Exit;
  end;

  Items := TStringList.Create;
  try
    Items.StrictDelimiter := True;
    Items.Delimiter := ',';
    Items.DelimitedText := StringReplace(AText, ';', ',', [rfReplaceAll]);
    for i := 0 to Items.Count - 1 do
    begin
      Item := Trim(Items[i]);
      if Item = '' then
        Continue;
      Result.Add(Item);
    end;
    if Result.Count = 0 then
      Result.Add('*');
  finally
    Items.Free;
  end;
end;

function TryGetRoutePathBounds(const APathJson: string; out ANorth, ASouth,
  AEast, AWest: Double): Boolean;
var
{$IFDEF FPC}
  JsonData: TJSONData;
  PointData: TJSONData;
  JsonParser: TJSONParser;
{$ELSE}
  JsonData: TJSONValue;
  PointData: TJSONValue;
{$ENDIF}
  PathArray: TJSONArray;
  i: Integer;
  PointObject: TJSONObject;
  LatValue: Double;
  LngValue: Double;
begin
  Result := False;
  ANorth := 0;
  ASouth := 0;
  AEast := 0;
  AWest := 0;

  if APathJson = '' then
    Exit;

{$IFDEF FPC}
  JsonParser := TJSONParser.Create(APathJson, []);
  try
    JsonData := JsonParser.Parse;
    try
      if not (JsonData is TJSONArray) then
        Exit;
      PathArray := TJSONArray(JsonData);
{$ELSE}
  JsonData := TJSONObject.ParseJSONValue(APathJson);
  try
    if not (JsonData is TJSONArray) then
      Exit;
    PathArray := TJSONArray(JsonData);
{$ENDIF}
      for i := 0 to PathArray.Count - 1 do
      begin
        PointData := PathArray.Items[i];
        if not (PointData is TJSONObject) then
          Continue;

        PointObject := TJSONObject(PointData);
{$IFDEF FPC}
        if Assigned(PointObject.Find('lat')) then
          LatValue := PointObject.Find('lat').AsFloat
        else
          Continue;
        if Assigned(PointObject.Find('lng')) then
          LngValue := PointObject.Find('lng').AsFloat
        else
          Continue;
{$ELSE}
        if not PointObject.TryGetValue<Double>('lat', LatValue) then
          Continue;
        if not PointObject.TryGetValue<Double>('lng', LngValue) then
          Continue;
{$ENDIF}

        if not Result then
        begin
          ANorth := LatValue;
          ASouth := LatValue;
          AEast := LngValue;
          AWest := LngValue;
          Result := True;
          Continue;
        end;

        ANorth := Max(ANorth, LatValue);
        ASouth := Min(ASouth, LatValue);
        AEast := Max(AEast, LngValue);
        AWest := Min(AWest, LngValue);
      end;
{$IFDEF FPC}
    finally
      JsonData.Free;
    end;
  finally
    JsonParser.Free;
  end;
{$ELSE}
  finally
    JsonData.Free;
  end;
{$ENDIF}
end;

{$IFDEF FPC}
function ParseRoutePath(const AValue: TJSONData): string;
{$ELSE}
function ParseRoutePath(const AValue: TJSONValue): string;
{$ENDIF}
begin
  Result := '';
  if Assigned(AValue) then
  {$IFDEF FPC}
    Result := AValue.AsJSON;
  {$ELSE}
    Result := AValue.ToJSON;
  {$ENDIF}
end;

{$IFDEF FPC}
function JsonArrayToText(const AValue: TJSONData): string;
{$ELSE}
function JsonArrayToText(const AValue: TJSONValue): string;
{$ENDIF}
var
  JsonArray: TJSONArray;
  i: Integer;
begin
  Result := '';
  if not (Assigned(AValue) and (AValue is TJSONArray)) then
    Exit;

  JsonArray := TJSONArray(AValue);
  for i := 0 to JsonArray.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ' | ';
  {$IFDEF FPC}
    Result := Result + JsonArray.Items[i].AsString;
  {$ELSE}
    Result := Result + JsonArray.Items[i].Value;
  {$ENDIF}
  end;
end;

function ParseRouteResult(const AJsonObject: TJSONObject): TGMRouteResult;
var
{$IFDEF FPC}
  LocalizedValues: TJSONData;
  PathValue: TJSONData;
  RouteLabelsValue: TJSONData;
  WarningsValue: TJSONData;
  LocalizedObject: TJSONObject;
{$ELSE}
  LocalizedValues: TJSONValue;
  PathValue: TJSONValue;
  RouteLabelsValue: TJSONValue;
  WarningsValue: TJSONValue;
  LocalizedObject: TJSONObject;
{$ENDIF}
begin
  Result := Default(TGMRouteResult);
  if not Assigned(AJsonObject) then
    Exit;

{$IFDEF FPC}
  if Assigned(AJsonObject.Find('distanceMeters')) then
    Result.DistanceMeters := AJsonObject.Find('distanceMeters').AsFloat;
  if Assigned(AJsonObject.Find('durationMillis')) then
    Result.DurationMillis := Trunc(AJsonObject.Find('durationMillis').AsFloat);
  if Assigned(AJsonObject.Find('staticDurationMillis')) then
    Result.StaticDurationMillis := Trunc(AJsonObject.Find('staticDurationMillis').AsFloat);
{$ELSE}
  Result.DistanceMeters := AJsonObject.GetValue<Double>('distanceMeters', 0);
  Result.DurationMillis := AJsonObject.GetValue<Int64>('durationMillis', 0);
  Result.StaticDurationMillis := AJsonObject.GetValue<Int64>('staticDurationMillis', 0);
{$ENDIF}

{$IFDEF FPC}
  LocalizedValues := AJsonObject.Find('localizedValues');
  RouteLabelsValue := AJsonObject.Find('routeLabels');
  WarningsValue := AJsonObject.Find('warnings');
  PathValue := AJsonObject.Find('path');
{$ELSE}
  LocalizedValues := AJsonObject.Values['localizedValues'];
  RouteLabelsValue := AJsonObject.Values['routeLabels'];
  WarningsValue := AJsonObject.Values['warnings'];
  PathValue := AJsonObject.Values['path'];
{$ENDIF}

  if Assigned(LocalizedValues) and (LocalizedValues is TJSONObject) then
  begin
    LocalizedObject := TJSONObject(LocalizedValues);
{$IFDEF FPC}
    if Assigned(LocalizedObject.Find('distance')) then
      Result.LocalizedDistance := LocalizedObject.Find('distance').AsString;
    if Assigned(LocalizedObject.Find('duration')) then
      Result.LocalizedDuration := LocalizedObject.Find('duration').AsString;
    if Assigned(LocalizedObject.Find('staticDuration')) then
      Result.LocalizedStaticDuration := LocalizedObject.Find('staticDuration').AsString;
{$ELSE}
    Result.LocalizedDistance := LocalizedObject.GetValue<string>('distance', '');
    Result.LocalizedDuration := LocalizedObject.GetValue<string>('duration', '');
    Result.LocalizedStaticDuration := LocalizedObject.GetValue<string>('staticDuration', '');
{$ENDIF}
  end;

  if Assigned(RouteLabelsValue) and (RouteLabelsValue is TJSONArray) then
    Result.RouteLabelsText := JsonArrayToText(RouteLabelsValue);

  if Assigned(WarningsValue) and (WarningsValue is TJSONArray) then
    Result.WarningsText := JsonArrayToText(WarningsValue);

  if Assigned(PathValue) then
    Result.PathJson := ParseRoutePath(PathValue);
end;

function ParseRouteResults(const AJsonObject: TJSONObject): TGMRouteResults;
var
{$IFDEF FPC}
  ResultsValue: TJSONData;
{$ELSE}
  ResultsValue: TJSONValue;
{$ENDIF}
  ResultsArray: TJSONArray;
  i: Integer;
begin
  Result := Default(TGMRouteResults);
  SetLength(Result, 0);
  if not Assigned(AJsonObject) then
    Exit;

{$IFDEF FPC}
  ResultsValue := AJsonObject.Find('results');
{$ELSE}
  ResultsValue := AJsonObject.Values['results'];
{$ENDIF}
  if not (ResultsValue is TJSONArray) then
    Exit;

  ResultsArray := TJSONArray(ResultsValue);
  SetLength(Result, ResultsArray.Count);
  for i := 0 to ResultsArray.Count - 1 do
    if ResultsArray.Items[i] is TJSONObject then
      Result[i] := ParseRouteResult(TJSONObject(ResultsArray.Items[i]));
end;

{$IFDEF FPC}
function GMLibRouteResponseFromJson(const AJson: string): TGMRouteResponse;
var
  JsonData: TJSONData;
  JsonParser: TJSONParser;
begin
  Result := Default(TGMRouteResponse);
  if AJson = '' then
    Exit;

  { The bridge may deliver large route payloads, so parsing stays isolated and
    failure-safe here instead of leaking JSON exceptions into the UI. }
  JsonParser := TJSONParser.Create(AJson, []);
  try
    JsonData := JsonParser.Parse;
    try
      if not (JsonData is TJSONObject) then
        Exit;

      Result.RequestId := TJSONObject(JsonData).Get('requestId', '');
      Result.Status := TJSONObject(JsonData).Get('status', '');
      Result.ErrorMessage := TJSONObject(JsonData).Get('errorMessage', '');
      Result.Results := ParseRouteResults(TJSONObject(JsonData));
    finally
      JsonData.Free;
    end;
  finally
    JsonParser.Free;
  end;
end;

function GMLibRouteResponseHasResults(const AResponse: TGMRouteResponse): Boolean;
begin
  Result := Length(AResponse.Results) > 0;
end;
{$ELSE}
class function TGMRouteResponse.FromJson(const AJson: string): TGMRouteResponse;
var
  JsonValue: TJSONValue;
  JsonObject: TJSONObject;
begin
  Result := Default(TGMRouteResponse);
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
      Result.Results := ParseRouteResults(JsonObject);
    finally
      JsonValue.Free;
    end;
  except
    Result := Default(TGMRouteResponse);
  end;
end;

function TGMRouteResponse.HasResults: Boolean;
begin
  Result := Length(Results) > 0;
end;
{$ENDIF}

function GMLibRouteResultPathToPolylinePath(const AResult: TGMRouteResult): TGMPolylinePath;
var
{$IFDEF FPC}
  JsonData: TJSONData;
  PointData: TJSONData;
{$ELSE}
  JsonData: TJSONValue;
  PointData: TJSONValue;
{$ENDIF}
{$IFDEF FPC}
  JsonParser: TJSONParser;
{$ENDIF}
  PathArray: TJSONArray;
  i: Integer;
  Step: Integer;
  LastIndex: Integer;
  PointObject: TJSONObject;
  LatValue: Double;
  LngValue: Double;
const
  MaxRenderedPoints = 2000;
begin
  Result := TGMPolylinePath.Create(nil);
  if AResult.PathJson = '' then
    Exit;

{$IFDEF FPC}
  JsonParser := TJSONParser.Create(AResult.PathJson, []);
  try
    JsonData := JsonParser.Parse;
    try
      if not (JsonData is TJSONArray) then
        Exit;

      PathArray := TJSONArray(JsonData);
      if PathArray.Count > MaxRenderedPoints then
        Step := Ceil(PathArray.Count / MaxRenderedPoints)
      else
        Step := 1;

      LastIndex := -1;
      i := 0;
      while i < PathArray.Count do
      begin
        PointData := PathArray.Items[i];
        if not (PointData is TJSONObject) then
        begin
          Inc(i, Step);
          Continue;
        end;

        PointObject := TJSONObject(PointData);
{$IFDEF FPC}
        if Assigned(PointObject.Find('lat')) then
          LatValue := PointObject.Find('lat').AsFloat
        else
          LatValue := 0;
        if Assigned(PointObject.Find('lng')) then
          LngValue := PointObject.Find('lng').AsFloat
        else
          LngValue := 0;
{$ELSE}
        PointObject.TryGetValue<Double>('lat', LatValue);
        PointObject.TryGetValue<Double>('lng', LngValue);
{$ENDIF}
        Result.Add(LatValue, LngValue);
        LastIndex := i;
        Inc(i, Step);
      end;

      if (PathArray.Count > 0) and (LastIndex <> PathArray.Count - 1) then
      begin
        PointData := PathArray.Items[PathArray.Count - 1];
        if PointData is TJSONObject then
        begin
          PointObject := TJSONObject(PointData);
{$IFDEF FPC}
          if Assigned(PointObject.Find('lat')) then
            LatValue := PointObject.Find('lat').AsFloat
          else
            LatValue := 0;
          if Assigned(PointObject.Find('lng')) then
            LngValue := PointObject.Find('lng').AsFloat
          else
            LngValue := 0;
{$ELSE}
          PointObject.TryGetValue<Double>('lat', LatValue);
          PointObject.TryGetValue<Double>('lng', LngValue);
{$ENDIF}
          Result.Add(LatValue, LngValue);
        end;
      end;
    finally
      JsonData.Free;
    end;
    finally
      JsonParser.Free;
    end;
{$ELSE}
  JsonData := TJSONObject.ParseJSONValue(AResult.PathJson);
  try
    if not (JsonData is TJSONArray) then
      Exit;

    PathArray := TJSONArray(JsonData);
    if PathArray.Count > MaxRenderedPoints then
      Step := Ceil(PathArray.Count / MaxRenderedPoints)
    else
      Step := 1;

    LastIndex := -1;
    i := 0;
    while i < PathArray.Count do
    begin
      PointData := PathArray.Items[i];
      if not (PointData is TJSONObject) then
      begin
        Inc(i, Step);
        Continue;
      end;

      PointObject := TJSONObject(PointData);
      PointObject.TryGetValue<Double>('lat', LatValue);
      PointObject.TryGetValue<Double>('lng', LngValue);
      Result.Add(LatValue, LngValue);
      LastIndex := i;
      Inc(i, Step);
    end;

    if (PathArray.Count > 0) and (LastIndex <> PathArray.Count - 1) then
    begin
      PointData := PathArray.Items[PathArray.Count - 1];
      if PointData is TJSONObject then
      begin
        PointObject := TJSONObject(PointData);
        PointObject.TryGetValue<Double>('lat', LatValue);
        PointObject.TryGetValue<Double>('lng', LngValue);
        Result.Add(LatValue, LngValue);
      end;
    end;
  finally
    JsonData.Free;
  end;
{$ENDIF}
end;

{ TGMRouteWaypoint }

procedure TGMRouteWaypoint.Assign(Source: TPersistent);
begin
  if Source is TGMRouteWaypoint then
  begin
    Address := TGMRouteWaypoint(Source).Address;
    LocationMode := TGMRouteWaypoint(Source).LocationMode;
    Location.Assign(TGMRouteWaypoint(Source).Location);
    SideOfRoad := TGMRouteWaypoint(Source).SideOfRoad;
    VehicleStopover := TGMRouteWaypoint(Source).VehicleStopover;
    Via := TGMRouteWaypoint(Source).Via;
    Exit;
  end;

  inherited;
end;

constructor TGMRouteWaypoint.Create(ACollection: TCollection);
begin
  inherited;
  FLocation := TMapLibLatLng.Create(0, 0);
  FLocation.OnChange := {$IFDEF FPC}@{$ENDIF}LocationChanged;
  FLocationMode := rwlmLatLng;
end;

destructor TGMRouteWaypoint.Destroy;
begin
  FLocation.Free;
  inherited;
end;

{$IFNDEF FPC}
function TGMRouteWaypoint.GetDisplayName: string;
begin
  if FLocationMode = rwlmAddress then
    Result := Address
  else
    Result := Format('%s,%s', [
      FloatToStr(FLocation.Lat, GMLibInvariantFormatSettings),
      FloatToStr(FLocation.Lng, GMLibInvariantFormatSettings)
    ]);
end;
{$ENDIF}

function TGMRouteWaypoint.ToJsonObject: TJSONObject;
var
  LocationObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FLocationMode = rwlmAddress then
  begin
{$IFDEF FPC}
    Result.Add('location', FAddress);
{$ELSE}
    Result.AddPair('location', FAddress);
{$ENDIF}
  end
  else
  begin
    LocationObject := TJSONObject.Create;
{$IFDEF FPC}
    LocationObject.Add('lat', GetJSON(FloatToStr(FLocation.Lat, GMLibInvariantFormatSettings)));
    LocationObject.Add('lng', GetJSON(FloatToStr(FLocation.Lng, GMLibInvariantFormatSettings)));
    Result.Add('location', LocationObject);
{$ELSE}
    LocationObject.AddPair('lat', TJSONNumber.Create(FLocation.Lat));
    LocationObject.AddPair('lng', TJSONNumber.Create(FLocation.Lng));
    Result.AddPair('location', LocationObject);
{$ENDIF}
  end;

  if FVia then
  begin
{$IFDEF FPC}
    Result.Add('via', TJSONBoolean.Create(True));
{$ELSE}
    Result.AddPair('via', TJSONBool.Create(True));
{$ENDIF}
  end;

  if FVehicleStopover then
  begin
{$IFDEF FPC}
    Result.Add('vehicleStopover', TJSONBoolean.Create(True));
{$ELSE}
    Result.AddPair('vehicleStopover', TJSONBool.Create(True));
{$ENDIF}
  end;

  if FSideOfRoad then
  begin
{$IFDEF FPC}
    Result.Add('sideOfRoad', TJSONBoolean.Create(True));
{$ELSE}
    Result.AddPair('sideOfRoad', TJSONBool.Create(True));
{$ENDIF}
  end;
end;

procedure TGMRouteWaypoint.SetAddress(const Value: string);
begin
  if FAddress = Value then
    Exit;

  FAddress := Value;
  if FLocationMode = rwlmAddress then
    Changed(False);
end;

procedure TGMRouteWaypoint.SetLocation(const Value: TMapLibLatLng);
begin
  if Assigned(Value) then
    FLocation.Assign(Value);
  if FLocationMode = rwlmLatLng then
    Changed(False);
end;

procedure TGMRouteWaypoint.SetLocationMode(const Value: TGMRouteWaypointLocationMode);
begin
  if FLocationMode = Value then
    Exit;

  FLocationMode := Value;
  Changed(False);
end;

procedure TGMRouteWaypoint.SetSideOfRoad(const Value: Boolean);
begin
  if FSideOfRoad = Value then
    Exit;

  FSideOfRoad := Value;
  Changed(False);
end;

procedure TGMRouteWaypoint.SetVehicleStopover(const Value: Boolean);
begin
  if FVehicleStopover = Value then
    Exit;

  FVehicleStopover := Value;
  Changed(False);
end;

procedure TGMRouteWaypoint.SetVia(const Value: Boolean);
begin
  if FVia = Value then
    Exit;

  FVia := Value;
  Changed(False);
end;

procedure TGMRouteWaypoint.LocationChanged(Sender: TObject);
begin
  if FLocationMode = rwlmLatLng then
    Changed(False);
end;

{ TGMRouteWaypoints }

function TGMRouteWaypoints.Add: TGMRouteWaypoint;
begin
  Result := TGMRouteWaypoint(inherited Add);
end;

function TGMRouteWaypoints.Add(const AAddress: string): TGMRouteWaypoint;
begin
{$IFDEF FPC}
  Result := nil;
{$ENDIF}
  Result := Add;
  if Assigned(Result) then
  begin
    Result.LocationMode := rwlmAddress;
    Result.Address := AAddress;
  end;
end;

function TGMRouteWaypoints.Add(ALatitude, ALongitude: Double): TGMRouteWaypoint;
begin
{$IFDEF FPC}
  Result := nil;
{$ENDIF}
  Result := Add;
  if Assigned(Result) then
  begin
    Result.LocationMode := rwlmLatLng;
    Result.Location.Lat := ALatitude;
    Result.Location.Lng := ALongitude;
  end;
end;

procedure TGMRouteWaypoints.Assign(Source: TPersistent);
var
  i: Integer;
  NewWaypoint: TGMRouteWaypoint;
  SourceWaypoints: TGMRouteWaypoints;
begin
  if Source is TGMRouteWaypoints then
  begin
    SourceWaypoints := TGMRouteWaypoints(Source);
    Clear;
    for i := 0 to SourceWaypoints.Count - 1 do
    begin
      NewWaypoint := Add;
      NewWaypoint.Assign(SourceWaypoints[i]);
    end;
    NotifyChange;
    Exit;
  end;

  inherited;
end;

constructor TGMRouteWaypoints.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMRouteWaypoint);
end;

function TGMRouteWaypoints.GetItem(Index: Integer): TGMRouteWaypoint;
begin
  Result := TGMRouteWaypoint(inherited Items[Index]);
end;

function TGMRouteWaypoints.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

procedure TGMRouteWaypoints.NotifyChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMRouteWaypoints.SetItem(Index: Integer; const Value: TGMRouteWaypoint);
begin
  inherited Items[Index].Assign(Value);
end;

function TGMRouteWaypoints.ToJsonArray: TJSONArray;
var
  i: Integer;
begin
  Result := TJSONArray.Create;
  for i := 0 to Count - 1 do
  {$IFDEF FPC}
    Result.Add(GetItem(i).ToJsonObject);
  {$ELSE}
    Result.AddElement(GetItem(i).ToJsonObject);
  {$ENDIF}
end;

procedure TGMRouteWaypoints.Update(Item: TCollectionItem);
begin
  inherited;
  NotifyChange;
end;

{ TGMRoutes }

procedure TGMRoutes.Assign(Source: TPersistent);
begin
  if Source is TGMRoutes then
  begin
    OriginAddress := TGMRoutes(Source).OriginAddress;
    OriginLocation.Assign(TGMRoutes(Source).OriginLocation);
    DestinationAddress := TGMRoutes(Source).DestinationAddress;
    DestinationLocation.Assign(TGMRoutes(Source).DestinationLocation);
    IntermediateWaypoints.Assign(TGMRoutes(Source).IntermediateWaypoints);
    Waypoints.Assign(TGMRoutes(Source).Waypoints);
    TravelMode := TGMRoutes(Source).TravelMode;
    RoutingPreference := TGMRoutes(Source).RoutingPreference;
    Units := TGMRoutes(Source).Units;
    RequestFields := TGMRoutes(Source).RequestFields;
    LanguageCode := TGMRoutes(Source).LanguageCode;
    ComputeAlternativeRoutes := TGMRoutes(Source).ComputeAlternativeRoutes;
    OptimizeWaypointOrder := TGMRoutes(Source).OptimizeWaypointOrder;
    AvoidHighways := TGMRoutes(Source).AvoidHighways;
    AvoidTolls := TGMRoutes(Source).AvoidTolls;
    AvoidFerries := TGMRoutes(Source).AvoidFerries;
    AvoidIndoor := TGMRoutes(Source).AvoidIndoor;
    CloseOthersBeforeVisible := TGMRoutes(Source).CloseOthersBeforeVisible;
    Exit;
  end;

  inherited;
end;

procedure TGMRoutes.Clear;
begin
  FQueries.Clear;
  FLastResponse := Default(TGMRouteResponse);
  FLastStatus := '';
  FLastErrorMessage := '';
  NotifyChanged;
end;

procedure TGMRoutes.HideOtherRoutes(AExcept: TGMRouteQueryResult);
var
  i: Integer;
  j: Integer;
begin
  if FClosingOthersBeforeVisible then
    Exit;

  FClosingOthersBeforeVisible := True;
  try
    for i := 0 to FQueries.Count - 1 do
      for j := 0 to FQueries[i].Count - 1 do
        if FQueries[i].ResultItems[j] <> AExcept then
          FQueries[i].ResultItems[j].Visible := False;
  finally
    FClosingOthersBeforeVisible := False;
  end;
end;

constructor TGMRoutes.Create(AOwner: TComponent);
begin
  inherited;
  FOriginLocation := TMapLibLatLng.Create(0, 0);
  FDestinationLocation := TMapLibLatLng.Create(0, 0);
{$IFDEF FPC}
  FQueries := specialize TObjectList<TGMRouteQuery>.Create(True);
  {$ELSE}
  FQueries := TObjectList<TGMRouteQuery>.Create(True);
{$ENDIF}
  FIntermediateWaypoints := TGMRouteWaypoints.Create(Self);
  FIntermediateWaypoints.OnChange := {$IFDEF FPC}@{$ENDIF}PathChanged;
  FWaypoints := TGMPolylinePath.Create(Self);
  FWaypoints.OnChange := {$IFDEF FPC}@{$ENDIF}PathChanged;
  FTravelMode := rtmDrive;
  FRoutingPreference := rrpTrafficUnaware;
  FUnits := ruUnspecified;
  FRequestFields := '*';
  FCloseOthersBeforeVisible := False;
end;

destructor TGMRoutes.Destroy;
begin
  Map := nil;
  FQueries.Free;
  FIntermediateWaypoints.Free;
  FWaypoints.Free;
  FDestinationLocation.Free;
  FOriginLocation.Free;
  inherited;
end;

function TGMRoutes.BuildRequestLiteral: string;
var
  Root: TJSONObject;
  Modifiers: TJSONObject;
  Intermediates: TJSONArray;
  i: Integer;
begin
  Root := TJSONObject.Create;
  try
    if not AddJsonLocation(Root, 'origin', FOriginAddress, FOriginLocation) then
    begin
{$IFDEF FPC}
      Root.Add('origin', '');
{$ELSE}
      Root.AddPair('origin', '');
{$ENDIF}
    end;

    if not AddJsonLocation(Root, 'destination', FDestinationAddress, FDestinationLocation) then
    begin
{$IFDEF FPC}
      Root.Add('destination', '');
{$ELSE}
      Root.AddPair('destination', '');
{$ENDIF}
    end;

    if Assigned(FIntermediateWaypoints) and not FIntermediateWaypoints.IsEmpty then
    begin
      Intermediates := FIntermediateWaypoints.ToJsonArray;
{$IFDEF FPC}
      Root.Add('intermediates', Intermediates);
{$ELSE}
      Root.AddPair('intermediates', Intermediates);
{$ENDIF}
    end
    else if Assigned(FWaypoints) and (FWaypoints.Count > 0) then
    begin
      Intermediates := TJSONArray.Create;
      for i := 0 to FWaypoints.Count - 1 do
        Intermediates.Add(BuildWaypointJsonObjectFromLatLng(FWaypoints[i].Lat, FWaypoints[i].Lng));
{$IFDEF FPC}
      Root.Add('intermediates', Intermediates);
{$ELSE}
      Root.AddPair('intermediates', Intermediates);
{$ENDIF}
    end;

{$IFDEF FPC}
    Root.Add('travelMode', RouteTravelModeToJs(FTravelMode));
    Root.Add('routingPreference', RouteRoutingPreferenceToJs(FRoutingPreference));
    Root.Add('fields', BuildJsonArrayFromCommaSeparatedText(FRequestFields));
    if FComputeAlternativeRoutes then
      Root.Add('computeAlternativeRoutes', TJSONBoolean.Create(True));
    if FOptimizeWaypointOrder then
      Root.Add('optimizeWaypointOrder', TJSONBoolean.Create(True));
    if FLanguageCode <> '' then
      Root.Add('language', FLanguageCode);
    if FUnits <> ruUnspecified then
      Root.Add('units', RouteUnitsToJs(FUnits));
    Modifiers := TJSONObject.Create;
    Modifiers.Add('avoidHighways', TJSONBoolean.Create(FAvoidHighways));
    Modifiers.Add('avoidTolls', TJSONBoolean.Create(FAvoidTolls));
    Modifiers.Add('avoidFerries', TJSONBoolean.Create(FAvoidFerries));
    Modifiers.Add('avoidIndoor', TJSONBoolean.Create(FAvoidIndoor));
    Root.Add('routeModifiers', Modifiers);
    Result := Root.AsJSON;
{$ELSE}
    Root.AddPair('travelMode', RouteTravelModeToJs(FTravelMode));
    Root.AddPair('routingPreference', RouteRoutingPreferenceToJs(FRoutingPreference));
    Root.AddPair('fields', BuildJsonArrayFromCommaSeparatedText(FRequestFields));
    if FComputeAlternativeRoutes then
      Root.AddPair('computeAlternativeRoutes', TJSONBool.Create(True));
    if FOptimizeWaypointOrder then
      Root.AddPair('optimizeWaypointOrder', TJSONBool.Create(True));
    if FLanguageCode <> '' then
      Root.AddPair('language', FLanguageCode);
    if FUnits <> ruUnspecified then
      Root.AddPair('units', RouteUnitsToJs(FUnits));
    Modifiers := TJSONObject.Create;
    Modifiers.AddPair('avoidHighways', TJSONBool.Create(FAvoidHighways));
    Modifiers.AddPair('avoidTolls', TJSONBool.Create(FAvoidTolls));
    Modifiers.AddPair('avoidFerries', TJSONBool.Create(FAvoidFerries));
    Modifiers.AddPair('avoidIndoor', TJSONBool.Create(FAvoidIndoor));
    Root.AddPair('routeModifiers', Modifiers);
    Result := Root.ToJSON;
{$ENDIF}
  finally
    Root.Free;
  end;
end;

function TGMRoutes.GetDocumentationUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/route';
end;

function TGMRoutes.GetCount: Integer;
begin
  Result := Length(FLastResponse.Results);
end;

function TGMRoutes.GetQuery(Index: Integer): TGMRouteQuery;
begin
  Result := nil;
  if (Index < 0) or (Index >= FQueries.Count) then
    Exit;
  Result := FQueries[Index];
end;

function TGMRoutes.GetQueryCount: Integer;
begin
  Result := FQueries.Count;
end;

function TGMRoutes.GetResult(Index: Integer): TGMRouteResult;
begin
  Result := Default(TGMRouteResult);
  if (Index < 0) or (Index >= Length(FLastResponse.Results)) then
    Exit;
  Result := FLastResponse.Results[Index];
end;

function TGMRoutes.FindQueryByRequestId(const ARequestId: string): TGMRouteQuery;
var
  i: Integer;
begin
  Result := nil;
  if ARequestId = '' then
    Exit;

  for i := 0 to FQueries.Count - 1 do
  begin
    if SameText(FQueries[i].RequestId, ARequestId) then
      Exit(FQueries[i]);
  end;
end;

procedure TGMRoutes.HandleCompleted(Sender: TObject; const AResponse: TGMRouteResponse);
var
  Query: TGMRouteQuery;
begin
  { Route requests are matched by request id because multiple requests can be
    in flight at the same time for the same map. }
  Query := FindQueryByRequestId(AResponse.RequestId);
  if not Assigned(Query) then
  begin
    Query := TGMRouteQuery.Create(Self);
    Query.RequestId := AResponse.RequestId;
    FQueries.Add(Query);
  end;

  Query.SyncResponse(AResponse);
  SyncLastResponse(AResponse);
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, AResponse);
  NotifyChanged;
end;

procedure TGMRoutes.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FMap) then
  begin
    NotifyQueriesMapChanged(FMap, nil);
    FMap := nil;
  end;
end;

procedure TGMRoutes.NotifyChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TGMRoutes.NotifyQueriesMapChanged(const AOldMap, ANewMap: TComponent);
var
  i: Integer;
  j: Integer;
begin
  for i := 0 to FQueries.Count - 1 do
    for j := 0 to FQueries[i].Count - 1 do
      FQueries[i].ResultItems[j].MapChanged(AOldMap, ANewMap);
end;

procedure TGMRoutes.PathChanged(Sender: TObject);
begin
  NotifyChanged;
end;

procedure TGMRoutes.SetCloseOthersBeforeVisible(const Value: Boolean);
begin
  if FCloseOthersBeforeVisible = Value then
    Exit;
  FCloseOthersBeforeVisible := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetAvoidFerries(const Value: Boolean);
begin
  if FAvoidFerries = Value then
    Exit;
  FAvoidFerries := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetAvoidHighways(const Value: Boolean);
begin
  if FAvoidHighways = Value then
    Exit;
  FAvoidHighways := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetAvoidIndoor(const Value: Boolean);
begin
  if FAvoidIndoor = Value then
    Exit;
  FAvoidIndoor := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetAvoidTolls(const Value: Boolean);
begin
  if FAvoidTolls = Value then
    Exit;
  FAvoidTolls := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetComputeAlternativeRoutes(const Value: Boolean);
begin
  if FComputeAlternativeRoutes = Value then
    Exit;
  FComputeAlternativeRoutes := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetDestinationAddress(const Value: string);
begin
  if FDestinationAddress = Value then
    Exit;
  FDestinationAddress := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetDestinationLocation(const Value: TMapLibLatLng);
begin
  if Assigned(Value) then
    FDestinationLocation.Assign(Value);
  NotifyChanged;
end;

procedure TGMRoutes.SetLanguageCode(const Value: string);
begin
  if FLanguageCode = Value then
    Exit;
  FLanguageCode := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetMap(const Value: TComponent);
var
  OldMap: TComponent;
begin
  if FMap = Value then
    Exit;
  OldMap := FMap;
  if Assigned(FMap) then
    FMap.RemoveFreeNotification(Self);
  FMap := Value;
  if Assigned(FMap) then
    FMap.FreeNotification(Self);
  NotifyQueriesMapChanged(OldMap, FMap);
end;

procedure TGMRoutes.SetOptimizeWaypointOrder(const Value: Boolean);
begin
  if FOptimizeWaypointOrder = Value then
    Exit;
  FOptimizeWaypointOrder := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetOriginAddress(const Value: string);
begin
  if FOriginAddress = Value then
    Exit;
  FOriginAddress := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetOriginLocation(const Value: TMapLibLatLng);
begin
  if Assigned(Value) then
    FOriginLocation.Assign(Value);
  NotifyChanged;
end;

procedure TGMRoutes.SetRequestFields(const Value: string);
begin
  if FRequestFields = Value then
    Exit;
  FRequestFields := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetRoutingPreference(const Value: TGMRouteRoutingPreference);
begin
  if FRoutingPreference = Value then
    Exit;
  FRoutingPreference := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetTravelMode(const Value: TGMRouteTravelMode);
begin
  if FTravelMode = Value then
    Exit;
  FTravelMode := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetUnits(const Value: TGMRouteUnits);
begin
  if FUnits = Value then
    Exit;
  FUnits := Value;
  NotifyChanged;
end;

procedure TGMRoutes.SetWaypoints(const Value: TGMPolylinePath);
begin
  if Assigned(Value) then
    FWaypoints.Assign(Value);
  NotifyChanged;
end;

procedure TGMRoutes.SyncLastResponse(const AResponse: TGMRouteResponse);
begin
  FLastResponse := AResponse;
  FLastStatus := AResponse.Status;
  FLastErrorMessage := AResponse.ErrorMessage;
end;

procedure TGMRoutes.Execute;
begin
  ExecuteQuery;
end;

function TGMRoutes.ExecuteQuery: TGMRouteQuery;
var
  RequestId: string;
  RequestLiteral: string;
begin
  Result := nil;
  if not Assigned(FMap) then
    Exit;

  RequestLiteral := BuildRequestLiteral;
{$IFDEF FPC}
  RequestId := TGMCustomMap(FMap).RoutesCompute(RequestLiteral, @HandleCompleted);
{$ELSE}
  RequestId := TGMCustomMap(FMap).RoutesCompute(RequestLiteral, HandleCompleted);
{$ENDIF}

  Result := TGMRouteQuery.Create(Self);
  Result.RequestId := RequestId;
  Result.RequestLiteral := RequestLiteral;
  { Store the request immediately so the response can be matched even if it
    arrives before the caller keeps the returned query reference. }
  FQueries.Add(Result);
  NotifyChanged;
end;

end.








