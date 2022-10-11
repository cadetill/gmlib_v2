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
  System.Types, System.Classes,
  {$ELSE}
  Types, Classes,
  {$ENDIF}

  GMLib.Classes, GMLib.LatLng, GMLib.Sets;

type
  TGMCustomSymbolOptions = class(TGMPersistentStr)
  protected
    property Path: TGMSymbolPath;
    property Anchor: TPoint;
    property FillOpacity: Double;
    property LabelOrigin: TPoint;
    property Rotation: Integer;
    property Scale: Integer;
    property StrokeOpacity: Double;
    property StrokeWeight: Integer;
    //property FillColor: TColor;
    //property StrokeColor: TColor;
  end;

  TGMCustomIconOptions = class(TGMPersistentStr, IGMControlChanges)
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    property Url: string;
    //property Symbol: TGMSymbolOptions;
  end;

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
    //property Icon: TGMIconOptions;
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
