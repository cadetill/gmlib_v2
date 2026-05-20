{**
  @abstract(LCL wrapper for OSM/MapLibre map component.)
}
unit uOSMLib.Lcl.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes{$ELSE}System.Classes{$ENDIF},
  uMapLib.Core.Bridge,
  uMapLib.Core.BridgeRegistry,
  uOSMLib.Map,
  uOSMLib.Lcl.MapBootstrap;

type
  TOSMLibLclMap = class(TOSMMap)
  private
    FBrowser: TComponent;
    FBridgeImpl: IMapBridgeTransport;
    function CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
    procedure SetBrowser(const Value: TComponent);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    destructor Destroy; override;
    procedure Activate; override;
  published
    property Browser: TComponent read FBrowser write SetBrowser;
  end;

  TOSMLibMap = TOSMLibLclMap;

implementation

uses
  SysUtils;

procedure TOSMLibLclMap.Activate;
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
  // EnsureOfflineTileSourceReady;
  FBridgeImpl.LoadHtml(TOSMLibLclMapBootstrap.BuildHtml(Self));
  inherited;
end;

function TOSMLibLclMap.CreateBridgeForBrowser(const ABrowser: TComponent): IMapBridgeTransport;
begin
  Result := CreateRegisteredBridgeForBrowser(ABrowser, FBridgeImpl);
  if Assigned(Result) then
  begin
    FBridgeImpl := Result;
    Exit;
  end;

  raise Exception.Create(
    'No bridge factory registered for the configured LCL browser component. ' +
    'Include the corresponding bridge unit/package (for example CEF4Delphi) before activating the OSM map.'
  );
end;

destructor TOSMLibLclMap.Destroy;
begin
  Bridge := nil;
  FBridgeImpl := nil;
  inherited;
end;

procedure TOSMLibLclMap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FBrowser) then
    FBrowser := nil;
end;

procedure TOSMLibLclMap.SetBrowser(const Value: TComponent);
begin
  if FBrowser = Value then
    Exit;

  if Assigned(FBrowser) then
    FBrowser.RemoveFreeNotification(Self);

  FBrowser := Value;

  if Assigned(FBrowser) then
    FBrowser.FreeNotification(Self);
end;

end.
