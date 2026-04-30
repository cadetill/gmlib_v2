{**
  @abstract(Modelo de capas auxiliares del mapa.)
}
unit uGMLib.Layers;

{$I ..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  Classes,
  Math,
  SysUtils,
{$ELSE}
  System.Classes,
  System.Math,
  System.SysUtils,
{$ENDIF}
  uGMLib.Core.Types,
  uGMLib.Core.ApiObject;

type
  TGMLayers = class;

  TGMTrafficLayer = class(TGMLibApiObject)
  private
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FAutoRefresh: Boolean;
    FVisible: Boolean;
    procedure SetAutoRefresh(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
  protected
    procedure Changed; override;
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    property APIUrl;
    property AutoRefresh: Boolean read FAutoRefresh write SetAutoRefresh default True;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  TGMTransitLayer = class(TGMLibApiObject)
  private
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
  protected
    procedure Changed; override;
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    property APIUrl;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  TGMBicyclingLayer = class(TGMLibApiObject)
  private
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
  protected
    procedure Changed; override;
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    property APIUrl;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  TGMKmlLayerClickEvent = procedure(Sender: TObject; ALatLng: TGMLibLatLng) of object;
  TGMKmlLayerStatusEvent = procedure(Sender: TObject; const AStatus: string) of object;

  TGMKmlLayer = class(TGMLibApiObject)
  private
    FUpdateCount: Integer;
    FUpdatePending: Boolean;
    FClickable: Boolean;
    FPreserveViewport: Boolean;
    FScreenOverlays: Boolean;
    FSuppressInfoWindows: Boolean;
    FStatus: string;
    FUrl: string;
    FVisible: Boolean;
    FZIndex: Integer;
    FOnClick: TGMKmlLayerClickEvent;
    FOnStatusChanged: TGMKmlLayerStatusEvent;
    procedure SetClickable(const Value: Boolean);
    procedure SetPreserveViewport(const Value: Boolean);
    procedure SetScreenOverlays(const Value: Boolean);
    procedure SetSuppressInfoWindows(const Value: Boolean);
    procedure SetUrl(const Value: string);
    procedure SetVisible(const Value: Boolean);
    procedure SetZIndex(const Value: Integer);
  protected
    procedure Changed; override;
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure SetStatus(const Value: string);
    property Status: string read FStatus;
  published
    property APIUrl;
    property Clickable: Boolean read FClickable write SetClickable default True;
    property PreserveViewport: Boolean read FPreserveViewport write SetPreserveViewport default False;
    property ScreenOverlays: Boolean read FScreenOverlays write SetScreenOverlays default True;
    property SuppressInfoWindows: Boolean read FSuppressInfoWindows write SetSuppressInfoWindows default False;
    property Url: string read FUrl write SetUrl;
    property Visible: Boolean read FVisible write SetVisible default True;
    property ZIndex: Integer read FZIndex write SetZIndex;
    property OnClick: TGMKmlLayerClickEvent read FOnClick write FOnClick;
    property OnStatusChanged: TGMKmlLayerStatusEvent read FOnStatusChanged write FOnStatusChanged;
  end;

  TGMLayers = class(TGMLibApiObject)
  private
    FTraffic: TGMTrafficLayer;
    FTransit: TGMTransitLayer;
    FBicycling: TGMBicyclingLayer;
    FKml: TGMKmlLayer;
    procedure ChildChanged(Sender: TObject);
    procedure SetBicycling(const Value: TGMBicyclingLayer);
    procedure SetKml(const Value: TGMKmlLayer);
    procedure SetTraffic(const Value: TGMTrafficLayer);
    procedure SetTransit(const Value: TGMTransitLayer);
  protected
    function GetAPIUrl: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    { Builds the JS command block that applies or removes each auxiliary
      layer in one shot. }
    function BuildApplyCommand: string;
  published
    property APIUrl;
    property Traffic: TGMTrafficLayer read FTraffic write SetTraffic;
    property Transit: TGMTransitLayer read FTransit write SetTransit;
    property Bicycling: TGMBicyclingLayer read FBicycling write SetBicycling;
    property Kml: TGMKmlLayer read FKml write SetKml;
  end;

implementation

function JsonQuotedStr(const AValue: string): string;
begin
  Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := '"' + Result + '"';
end;

function BoolToJs(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

function IntToJs(const AValue: Integer): string;
begin
  Result := IntToStr(AValue);
end;

{ TGMTrafficLayer }

procedure TGMTrafficLayer.Assign(Source: TPersistent);
begin
  if Source is TGMTrafficLayer then
  begin
    AutoRefresh := TGMTrafficLayer(Source).AutoRefresh;
    Visible := TGMTrafficLayer(Source).Visible;
  end
  else
    inherited;
end;

procedure TGMTrafficLayer.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGMTrafficLayer.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

constructor TGMTrafficLayer.Create;
begin
  inherited;
  FAutoRefresh := True;
  FVisible := False;
end;

procedure TGMTrafficLayer.EndUpdate;
begin
  if FUpdateCount <= 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FUpdatePending then
  begin
    FUpdatePending := False;
    Changed;
  end;
end;

function TGMTrafficLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#TrafficLayer';
end;

procedure TGMTrafficLayer.SetAutoRefresh(const Value: Boolean);
begin
  if FAutoRefresh = Value then
    Exit;

  FAutoRefresh := Value;
  Changed;
end;

procedure TGMTrafficLayer.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  Changed;
end;

{ TGMTransitLayer }

procedure TGMTransitLayer.Assign(Source: TPersistent);
begin
  if Source is TGMTransitLayer then
    Visible := TGMTransitLayer(Source).Visible
  else
    inherited;
end;

procedure TGMTransitLayer.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGMTransitLayer.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

constructor TGMTransitLayer.Create;
begin
  inherited;
  FVisible := False;
end;

procedure TGMTransitLayer.EndUpdate;
begin
  if FUpdateCount <= 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FUpdatePending then
  begin
    FUpdatePending := False;
    Changed;
  end;
end;

function TGMTransitLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#TransitLayer';
end;

procedure TGMTransitLayer.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  Changed;
end;

{ TGMBicyclingLayer }

procedure TGMBicyclingLayer.Assign(Source: TPersistent);
begin
  if Source is TGMBicyclingLayer then
    Visible := TGMBicyclingLayer(Source).Visible
  else
    inherited;
end;

procedure TGMBicyclingLayer.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGMBicyclingLayer.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

constructor TGMBicyclingLayer.Create;
begin
  inherited;
  FVisible := False;
end;

procedure TGMBicyclingLayer.EndUpdate;
begin
  if FUpdateCount <= 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FUpdatePending then
  begin
    FUpdatePending := False;
    Changed;
  end;
end;

function TGMBicyclingLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#BicyclingLayer';
end;

procedure TGMBicyclingLayer.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  Changed;
end;

{ TGMKmlLayer }

procedure TGMKmlLayer.Assign(Source: TPersistent);
begin
  if Source is TGMKmlLayer then
  begin
    Clickable := TGMKmlLayer(Source).Clickable;
    PreserveViewport := TGMKmlLayer(Source).PreserveViewport;
    ScreenOverlays := TGMKmlLayer(Source).ScreenOverlays;
    SuppressInfoWindows := TGMKmlLayer(Source).SuppressInfoWindows;
    Url := TGMKmlLayer(Source).Url;
    Visible := TGMKmlLayer(Source).Visible;
    ZIndex := TGMKmlLayer(Source).ZIndex;
  end
  else
    inherited;
end;

procedure TGMKmlLayer.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGMKmlLayer.Changed;
begin
  if FUpdateCount > 0 then
  begin
    FUpdatePending := True;
    Exit;
  end;

  inherited Changed;
end;

constructor TGMKmlLayer.Create;
begin
  inherited;
  FClickable := True;
  FPreserveViewport := False;
  FScreenOverlays := True;
  FSuppressInfoWindows := False;
  FStatus := '';
  FUrl := '';
  FVisible := True;
  FZIndex := 0;
end;

procedure TGMKmlLayer.EndUpdate;
begin
  if FUpdateCount <= 0 then
    Exit;

  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FUpdatePending then
  begin
    FUpdatePending := False;
    Changed;
  end;
end;

function TGMKmlLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/kml#KmlLayer';
end;

procedure TGMKmlLayer.SetClickable(const Value: Boolean);
begin
  if FClickable = Value then
    Exit;

  FClickable := Value;
  Changed;
end;

procedure TGMKmlLayer.SetPreserveViewport(const Value: Boolean);
begin
  if FPreserveViewport = Value then
    Exit;

  FPreserveViewport := Value;
  Changed;
end;

procedure TGMKmlLayer.SetScreenOverlays(const Value: Boolean);
begin
  if FScreenOverlays = Value then
    Exit;

  FScreenOverlays := Value;
  Changed;
end;

procedure TGMKmlLayer.SetSuppressInfoWindows(const Value: Boolean);
begin
  if FSuppressInfoWindows = Value then
    Exit;

  FSuppressInfoWindows := Value;
  Changed;
end;

procedure TGMKmlLayer.SetStatus(const Value: string);
begin
  if FStatus = Value then
    Exit;

  FStatus := Value;
  { Status is a runtime notification coming from the JS bridge, so it is
    delivered through the event instead of being treated as persistent state. }
  if Assigned(FOnStatusChanged) then
    FOnStatusChanged(Self, FStatus);
end;

procedure TGMKmlLayer.SetUrl(const Value: string);
begin
  if FUrl = Value then
    Exit;

  FUrl := Value;
  Changed;
end;

procedure TGMKmlLayer.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;

  FVisible := Value;
  Changed;
end;

procedure TGMKmlLayer.SetZIndex(const Value: Integer);
begin
  if FZIndex = Value then
    Exit;

  FZIndex := Value;
  Changed;
end;

{ TGMLayers }

procedure TGMLayers.Assign(Source: TPersistent);
begin
  if Source is TGMLayers then
  begin
    Traffic.Assign(TGMLayers(Source).Traffic);
    Transit.Assign(TGMLayers(Source).Transit);
    Bicycling.Assign(TGMLayers(Source).Bicycling);
    Kml.Assign(TGMLayers(Source).Kml);
  end
  else
    inherited;
end;

function TGMLayers.BuildApplyCommand: string;
begin
  Result := '';

  if Traffic.Visible then
    Result := Result + Format(
      'gmlib.layers.setTraffic({ visible: true, autoRefresh: %s });',
      [BoolToJs(Traffic.AutoRefresh)]
    )
  else
    Result := Result + 'gmlib.layers.removeTraffic();';

  if Transit.Visible then
    Result := Result + 'gmlib.layers.setTransit({ visible: true });'
  else
    Result := Result + 'gmlib.layers.removeTransit();';

  if Bicycling.Visible then
    Result := Result + 'gmlib.layers.setBicycling({ visible: true });'
  else
    Result := Result + 'gmlib.layers.removeBicycling();';

  if Kml.Visible and (Trim(Kml.Url) <> '') then
  begin
    Result := Result + Format(
      'gmlib.layers.setKml({ visible: true, url: %s, clickable: %s, preserveViewport: %s, screenOverlays: %s, suppressInfoWindows: %s, zIndex: %s });',
      [
        JsonQuotedStr(Trim(Kml.Url)),
        BoolToJs(Kml.Clickable),
        BoolToJs(Kml.PreserveViewport),
        BoolToJs(Kml.ScreenOverlays),
        BoolToJs(Kml.SuppressInfoWindows),
        IntToJs(Kml.ZIndex)
      ]
    );
  end
  else
    Result := Result + 'gmlib.layers.removeKml();';
end;

procedure TGMLayers.ChildChanged(Sender: TObject);
begin
  Changed;
end;

constructor TGMLayers.Create;
begin
  inherited;
  FTraffic := TGMTrafficLayer.Create;
  FTransit := TGMTransitLayer.Create;
  FBicycling := TGMBicyclingLayer.Create;
  FKml := TGMKmlLayer.Create;

  FTraffic.Owner := Self;
  FTransit.Owner := Self;
  FBicycling.Owner := Self;
  FKml.Owner := Self;

  FTraffic.OnChange := ChildChanged;
  FTransit.OnChange := ChildChanged;
  FBicycling.OnChange := ChildChanged;
  FKml.OnChange := ChildChanged;
end;

destructor TGMLayers.Destroy;
begin
  if Assigned(FTraffic) then
    FTraffic.OnChange := nil;
  if Assigned(FTransit) then
    FTransit.OnChange := nil;
  if Assigned(FBicycling) then
    FBicycling.OnChange := nil;
  if Assigned(FKml) then
    FKml.OnChange := nil;

  FKml.Free;
  FBicycling.Free;
  FTransit.Free;
  FTraffic.Free;
  inherited;
end;

function TGMLayers.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map';
end;

procedure TGMLayers.SetBicycling(const Value: TGMBicyclingLayer);
begin
  if not Assigned(Value) then
    Exit;

  FBicycling.Assign(Value);
end;

procedure TGMLayers.SetKml(const Value: TGMKmlLayer);
begin
  if not Assigned(Value) then
    Exit;

  FKml.Assign(Value);
end;

procedure TGMLayers.SetTraffic(const Value: TGMTrafficLayer);
begin
  if not Assigned(Value) then
    Exit;

  FTraffic.Assign(Value);
end;

procedure TGMLayers.SetTransit(const Value: TGMTransitLayer);
begin
  if not Assigned(Value) then
    Exit;

  FTransit.Assign(Value);
end;

end.
