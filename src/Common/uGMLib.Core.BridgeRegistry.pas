{**
  @abstract(Registro de factorías de bridge opcionales.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad permite registrar transportes alternativos sin acoplar el paquete
  base a dependencias opcionales como CEF.
}
unit uGMLib.Core.BridgeRegistry;

{$I ..\..\gmlib.inc}

interface

uses
  {$IFDEF FPC}Classes,{$ELSE}System.Classes,{$ENDIF}
  {$IFDEF FPC}SysUtils,{$ELSE}System.SysUtils,{$ENDIF}
  {$IFDEF FPC}Generics.Collections{$ELSE}System.Generics.Collections{$ENDIF},
  uGMLib.Core.Bridge;

type
  {** @abstract(Factoría opcional de un bridge para un componente navegador.) }
  TGMBridgeFactory = function(const ABrowser: TComponent;
    const ACurrentBridge: IGMBridgeTransport): IGMBridgeTransport;

procedure RegisterBridgeFactory(const AFactory: TGMBridgeFactory);
function CreateRegisteredBridgeForBrowser(const ABrowser: TComponent;
  const ACurrentBridge: IGMBridgeTransport): IGMBridgeTransport;

implementation

var
  {$IFDEF FPC}
  GBridgeFactories: specialize TList<TGMBridgeFactory>;
  {$ELSE}
  GBridgeFactories: TList<TGMBridgeFactory>;
  {$ENDIF}

procedure RegisterBridgeFactory(const AFactory: TGMBridgeFactory);
begin
  if not Assigned(GBridgeFactories) then
  begin
    {$IFDEF FPC}
    GBridgeFactories := specialize TList<TGMBridgeFactory>.Create;
    {$ELSE}
    GBridgeFactories := TList<TGMBridgeFactory>.Create;
    {$ENDIF}
  end;

  { Factories are kept unique and are probed in registration order so optional
    backends can override the current bridge only when they really match. }
  if GBridgeFactories.IndexOf(AFactory) < 0 then
    GBridgeFactories.Add(AFactory);
end;

function CreateRegisteredBridgeForBrowser(const ABrowser: TComponent;
  const ACurrentBridge: IGMBridgeTransport): IGMBridgeTransport;
var
  Factory: TGMBridgeFactory;
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
  { Registry is created lazily when the first optional bridge is registered. }

finalization
  FreeAndNil(GBridgeFactories);

end.
