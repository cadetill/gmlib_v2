{**
  @abstract(Contrato de catalogo para regiones offline.)
}
unit uMapLib.Offline.RegionCatalog;

{$I ..\..\gmlib.inc}

interface

uses
  uMapLib.Offline.Types;

type
  IMapLibOfflineCatalog = interface
    ['{F3C8AB56-A0A4-4864-BD66-4FCF7F7D13B1}']
    function ListRegions: TMapLibOfflineRegionMetadataArray;
    function DeleteRegion(const ARegionId: TMapLibOfflineRegionId): Boolean;
    function GetStorageUsage: TMapLibOfflineStorageUsage;
    procedure SetActiveRegion(const ARegionId: TMapLibOfflineRegionId);
    function GetActiveRegionId: TMapLibOfflineRegionId;

    property ActiveRegionId: TMapLibOfflineRegionId read GetActiveRegionId;
  end;

implementation

end.
