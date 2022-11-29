{
  @abstract(Events definition for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 21, 2022)

  The GMLib.Events unit provides access to all events fired for GMLib components.
}
unit GMLib.Events;

{$I ..\gmlib.inc}

interface

uses
  GMLib.LatLngBounds, GMLib.LatLng, GMLib.Sets;

type
  // @include(..\Help\docs\GMLib.Events.TGMPropertyChangesEvent.txt)
  TGMPropertyChangesEvent = procedure(Owner: TObject; PropName: string) of object;

  // @include(..\Help\docs\GMLib.Events.TGMBoundsChangedEvent.txt)
  TGMBoundsChangedEvent = procedure(Sender: TObject; NewBounds: TGMLatLngBounds) of object;

  // @include(..\Help\docs\GMLib.Events.TGMLatLngEvent.txt)
  TGMLatLngEvent = procedure(Sender: TObject; LatLng: TGMLatLng; X, Y: Double) of object;

  // @include(..\Help\docs\GMLib.Events.TGMMapTypeIdChangedEvent.txt)
  TGMMapTypeIdChangedEvent = procedure(Sender: TObject; NewMapTypeId: TGMMapTypeId) of object;

  // @include(..\Help\docs\GMLib.Events.TGMZoomChangedEvent.txt)
  TGMZoomChangedEvent = procedure(Sender: TObject; NewZoom: Integer) of object;

  // @include(..\Help\docs\GMLib.Events.TGMAfterPageLoaded.txt)
  TGMAfterPageLoaded = procedure(Sender: TObject; First: Boolean) of object;

implementation

end.
