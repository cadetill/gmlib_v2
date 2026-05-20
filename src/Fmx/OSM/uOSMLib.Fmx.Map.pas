{**
  @abstract(FMX wrapper for OSM/MapLibre map component.)
}
unit uOSMLib.Fmx.Map;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  FMX.WebBrowser,
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uGMLib.Fmx.Bridge.WebBrowser,
  uOSMLib.Map,
  uOSMLib.Fmx.MapBootstrap;

type
  TOSMLibFmxMap = class(TOSMMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    FBridgeInterval: Integer;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    procedure SetBrowser(const Value: TComponent);
    procedure SetBridgeInterval(const Value: Integer);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Activate; override;
  published
    property Browser: TComponent read FBrowser write SetBrowser;
    property BridgeInterval: Integer read FBridgeInterval write SetBridgeInterval default 100;
  end;

  TOSMLibMap = TOSMLibFmxMap;

implementation

uses
  System.SysUtils;

constructor TOSMLibFmxMap.Create(AOwner: TComponent);
begin
  inherited;
  FBridgeInterval := 100;
end;

procedure TOSMLibFmxMap.Activate;
var
  NamespacedBridge: IMapBridgeJavaScriptNamespace;
begin
  if Active then
    Exit;
  if not Assigned(FBrowser) then
    raise Exception.Create('Browser is not assigned.');

  FBridgeImpl := CreateBridgeForBrowser(FBrowser);
  if Supports(FBridgeImpl, IMapBridgeJavaScriptNamespace, NamespacedBridge) then
    NamespacedBridge.JavaScriptNamespace := 'maplib';
  Bridge := FBridgeImpl;
  if FBridgeImpl is TGMLibFmxWebBrowserBridge then
    TGMLibFmxWebBrowserBridge(FBridgeImpl).PollInterval := FBridgeInterval;
  // EnsureOfflineTileSourceReady;
  FBridgeImpl.LoadHtml(TOSMLibFmxMapBootstrap.BuildHtml(Self));
  inherited;
end;

function TOSMLibFmxMap.CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
begin
  Result := CreateRegisteredBridgeForBrowser(ABrowser, FBridgeImpl);
  if Assigned(Result) then
  begin
    FBridgeImpl := Result;
    Exit;
  end;

  if ABrowser is TWebBrowser then
  begin
    if not Assigned(FBridgeImpl) then
      FBridgeImpl := TGMLibFmxWebBrowserBridge.Create(TWebBrowser(ABrowser))
    else
      FBridgeImpl.AttachBrowser(TWebBrowser(ABrowser));
    Result := FBridgeImpl;
    Exit;
  end;

  raise Exception.Create('Unsupported browser component for FMX OSM map.');
end;

destructor TOSMLibFmxMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

procedure TOSMLibFmxMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TOSMLibFmxMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);
  FBrowser := Value;
  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

procedure TOSMLibFmxMap.SetBridgeInterval(const Value: Integer);
begin
  if Value < 10 then
    FBridgeInterval := 10
  else
    FBridgeInterval := Value;
end;

end.
