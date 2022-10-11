{
  @abstract(@code(google.maps.Marker) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(October 7, 2022)
  @lastmod(October 7, 2022)

  The GMLib.Marker contains the implementation of TGMMarker class that encapsulate the @code(google.maps.Marker) class from Google Maps API.
}
unit GMLib.Marker;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Types,
  {$ELSE}
  Types,
  {$ENDIF}

  GMLib.Classes, GMLib.LatLng;

type
  TGMCustomMarker = class(TGMInterfacedCollectionItem)
  private
  protected
    property AnchorPoint: TPoint;
    property Animation: TGMAnimation;
    property Clickable: Boolean;
    property CollisionBehavior: TGMCollisionBehavior;
    property CrossOnDrag: Boolean;
    property Cursor: string;
    property Draggable: Boolean;
    property Icon: TGMIconOptions;
    property Label: TGMLabelOptions;
    property Opacity: Double;
    property Optimized: Boolean;
    property Position: TGMLatLng;
    property Shape: TGMMarkerShape;
    property Title: string;
    property Visible: Boolean;
  public
  end;

  TGMCustomMarkerList = class(TGMInterfacedCollection)
  private
  protected
  public
  end;

implementation

end.
