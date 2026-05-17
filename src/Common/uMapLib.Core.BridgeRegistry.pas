{**
  @abstract(Registro de factorias de bridge opcionales.)
}
unit uMapLib.Core.BridgeRegistry;

{$I ..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes,{$ELSE}System.Classes,{$ENDIF}
  {$IFDEF FPC}SysUtils,{$ELSE}System.SysUtils,{$ENDIF}
  {$IFDEF FPC}Generics.Collections{$ELSE}System.Generics.Collections{$ENDIF},
  uMapLib.Core.Bridge;

type
  TMapBridgeFactory = function(const ABrowser: TComponent;
    const ACurrentBridge: IMapBridgeTransport): IMapBridgeTransport;

procedure RegisterBridgeFactory(const AFactory: TMapBridgeFactory);
function CreateRegisteredBridgeForBrowser(const ABrowser: TComponent;
  const ACurrentBridge: IMapBridgeTransport): IMapBridgeTransport;

implementation

var
  {$IFDEF FPC}
  GBridgeFactories: specialize TList<TMapBridgeFactory>;
  {$ELSE}
  GBridgeFactories: TList<TMapBridgeFactory>;
  {$ENDIF}

procedure RegisterBridgeFactory(const AFactory: TMapBridgeFactory);
begin
  if not Assigned(GBridgeFactories) then
  begin
    {$IFDEF FPC}
    GBridgeFactories := specialize TList<TMapBridgeFactory>.Create;
    {$ELSE}
    GBridgeFactories := TList<TMapBridgeFactory>.Create;
    {$ENDIF}
  end;

  if GBridgeFactories.IndexOf(AFactory) < 0 then
    GBridgeFactories.Add(AFactory);
end;

function CreateRegisteredBridgeForBrowser(const ABrowser: TComponent;
  const ACurrentBridge: IMapBridgeTransport): IMapBridgeTransport;
var
  Factory: TMapBridgeFactory;
begin
  Result := nil;
  if not Assigned(GBridgeFactories) then
    Exit;

  for Factory in GBridgeFactories do
  begin
    Result := Factory(ABrowser, ACurrentBridge);
    if Assigned(Result) then
      Exit;
  end;
end;

initialization

finalization
  FreeAndNil(GBridgeFactories);

end.

