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
  GMLib.LatLngBounds;

type
  // @include(..\Help\docs\GMLib.Events.TPropertyChanges.txt)
  TPropertyChanges = procedure(Owner: TObject; PropName: string) of object;

  // @include(..\Help\docs\GMLib.Events.TGMBoundsChanged.txt)
  TGMBoundsChanged = procedure(Sender: TObject; NewBounds: TGMLatLngBounds) of object;

implementation

end.
