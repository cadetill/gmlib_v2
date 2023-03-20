{
  @abstract(@code(google.maps.Marker) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(October 25, 2022)
  @lastmod(October 25, 2022)

  The GMLib.Marker.Vcl contains the implementation of TGMMarker class that encapsulate the @code(google.maps.Marker) class from Google Maps API for Vcl framework.
}
unit GMLib.Marker.Vcl;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  Vcl.Graphics, System.Classes,
  {$ELSE}
  Graphics, Classes,
  {$ENDIF}

  GMLib.Marker, GMLib.Classes;

type
  // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.txt)
  TGMSymbolOptions = class(TGMCustomSymbolOptions)
  private
    FFillColor: TColor;
    FStrokeColor: TColor;
    procedure SetFillColor(const Value: TColor);
    procedure SetStrokeColor(const Value: TColor);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMSymbolOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  published
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMSymbolOptions.FillColor.txt)
    property FillColor: TColor read FFillColor write SetFillColor;
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMSymbolOptions.StrokeColor.txt)
    property StrokeColor: TColor read FStrokeColor write SetStrokeColor;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Path.txt)
    property Path;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Anchor.txt)
    property Anchor;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.FillOpacity.txt)
    property FillOpacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.LabelOrigin.txt)
    property LabelOrigin;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Rotation.txt)
    property Rotation;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Scale.txt)
    property Scale;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.StrokeOpacity.txt)
    property StrokeOpacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.StrokeWeight.txt)
    property StrokeWeight;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.txt)
  TGMIconOptions = class(TGMCustomIconOptions)
  private
    FSymbol: TGMSymbolOptions;
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMIconOptions.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  published
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMIconOptions.Symbol.txt)
    property Symbol: TGMSymbolOptions read FSymbol write FSymbol;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Url.txt)
    property Url;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Icon.txt)
    property Icon;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.txt)
  TGMLabelOptions = class(TGMCustomLabelOptions)
  private
    FColor: TColor;
    procedure SetColor(const Value: TColor);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMLabelOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  published
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMLabelOptions.Color.txt)
    property Color: TColor read FColor write SetColor;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.Text.txt)
    property Text;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.ClassName.txt)
    property LabelClassName;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.FontFamily.txt)
    property FontFamily;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.FontSize.txt)
    property FontSize;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.FontWeight.txt)
    property FontWeight;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.txt)
  TGMMarker = class(TGMCustomMarker)
  private
    FLabelText: TGMLabelOptions;
    FIcon: TGMIconOptions;
  protected
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMMarker.Icon.txt)
    property Icon: TGMIconOptions read FIcon write FIcon;
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMMarker.LabelText.txt)
    property LabelText: TGMLabelOptions read FLabelText write FLabelText;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.AnchorPoint.txt)
    property AnchorPoint;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Animation.txt)
    property Animation;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Clickable.txt)
    property Clickable;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.CollisionBehavior.txt)
    property CollisionBehavior;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.CrossOnDrag.txt)
    property CrossOnDrag;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Cursor.txt)
    property Cursor;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Draggable.txt)
    property Draggable;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Opacity.txt)
    property Opacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Optimized.txt)
    property Optimized;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Position.txt)
    property Position;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Title.txt)
    property Title;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Visible.txt)
    property Visible;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.ZIndex.txt)
    property ZIndex;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMMarkerItem.txt)
  TGMMarkerItem = class(TGMInterfacedCollectionItem, IGMControlChanges)
  private
    FMarker: TGMMarker;
  protected
    // @exclude
    function GetDisplayName: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Marker: TGMMarker read FMarker write FMarker;
  end;

  // @include(..\Help\docs\GMLib.Marker.Vcl.TGMMarkerList.txt)
  TGMMarkerList = class(TGMInterfacedCollection)
  private
    function GetItems(I: Integer): TGMMarkerItem;
    procedure SetItems(I: Integer; const Value: TGMMarkerItem);
  public
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMMarkerList.Add.txt)
    function Add: TGMMarkerItem;
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMMarkerList.Insert.txt)
    function Insert(Index: Integer): TGMMarkerItem;

    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMMarkerList.Items.txt)
    property Items[I: Integer]: TGMMarkerItem read GetItems write SetItems; default;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomMarkers.txt)
  TGMMarkers = class(TGMCustomMarkers)
  private
    FMarkersList: TGMMarkerList;
  protected
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarkers.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.Vcl.TGMMarkers.TGMMarkers.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  published
    // @include(..\Help\docs\GMLib.Marker.TGMMarkers.Vcl.Markers.txt)
    property MarkersList: TGMMarkerList read FMarkersList write FMarkersList;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarkers.AutoUpdate.txt)
    property AutoUpdate;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  GMLib.Transform.Vcl;

{ TGMSymbolOptions }

procedure TGMSymbolOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMSymbolOptions then
  begin
    FillColor := TGMSymbolOptions(Source).FillColor;
    StrokeColor := TGMSymbolOptions(Source).StrokeColor;
  end;
end;

constructor TGMSymbolOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FFillColor := clBlack;
  FStrokeColor := clBlack;
end;

function TGMSymbolOptions.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(TGMTransform.TColorToStr(FFillColor)),
                         QuotedStr(TGMTransform.TColorToStr(FStrokeColor))
                        ]);
end;

procedure TGMSymbolOptions.SetFillColor(const Value: TColor);
begin
  if FFillColor = Value then Exit;

  FFillColor := Value;
  ControlChanges('FillColor');
end;

procedure TGMSymbolOptions.SetStrokeColor(const Value: TColor);
begin
  if FStrokeColor = Value then Exit;

  FStrokeColor := Value;
  ControlChanges('StrokeColor');
end;

{ TGMIconOptions }

procedure TGMIconOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMIconOptions then
  begin
    Symbol.Assign(TGMIconOptions(Source).Symbol);
  end;
end;

constructor TGMIconOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FSymbol := TGMSymbolOptions.Create(Self);
end;

destructor TGMIconOptions.Destroy;
begin
  if Assigned(FSymbol) then FSymbol.Free;

  inherited;
end;

function TGMIconOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         FSymbol.PropToString
                        ]);
end;

{ TGMLabelOptions }

procedure TGMLabelOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMLabelOptions then
  begin
    Color := TGMLabelOptions(Source).Color;
  end;
end;

constructor TGMLabelOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FColor := clBlack;
end;

function TGMLabelOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(TGMTransform.TColorToStr(FColor))
                        ]);
end;

procedure TGMLabelOptions.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit;

  FColor := Value;
  ControlChanges('Color');
end;

{ TGMMarker }

procedure TGMMarker.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMMarker then
  begin
    Icon.Assign(TGMMarker(Source).Icon);
    LabelText.Assign(TGMMarker(Source).LabelText);
  end;
end;

constructor TGMMarker.Create(AOwner: TPersistent);
begin
  inherited;

  FIcon := TGMIconOptions.Create(Self);
  FLabelText := TGMLabelOptions.Create(Self);
end;

destructor TGMMarker.Destroy;
begin
  if Assigned(FIcon) then FIcon.Free;
  if Assigned(FLabelText) then FLabelText.Free;

  inherited;
end;

function TGMMarker.PropToString: string;
begin
  Result := inherited;
end;

{ TGMMarkerList }

function TGMMarkerList.Add: TGMMarkerItem;
begin
  Result := TGMMarkerItem(inherited Add);
end;

function TGMMarkerList.GetItems(I: Integer): TGMMarkerItem;
begin
  Result := TGMMarkerItem(inherited Items[I]);
end;

function TGMMarkerList.Insert(Index: Integer): TGMMarkerItem;
begin
  Result := TGMMarkerItem(inherited Insert(Index));
end;

procedure TGMMarkerList.SetItems(I: Integer; const Value: TGMMarkerItem);
begin
  inherited SetItem(I, Value);
end;

{ TGMMarkers }

procedure TGMMarkers.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMMarkers then
  begin
    MarkersList.Assign(TGMMarkers(Source).MarkersList);
  end;
end;

constructor TGMMarkers.Create(AOwner: TPersistent);
begin
  inherited;

  FMarkersList := TGMMarkerList.Create(Self, TGMMarkerItem);
end;

destructor TGMMarkers.Destroy;
begin
  if Assigned(FMarkersList) then FMarkersList.Free;

  inherited;
end;

function TGMMarkers.PropToString: string;
const
  Str = '%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         FMarkersList.PropToString
                        ]);
end;

{ TGMMarkerItem }

constructor TGMMarkerItem.Create(Collection: TCollection);
begin
  inherited;

  FMarker := TGMMarker.Create(Self);
end;

destructor TGMMarkerItem.Destroy;
begin
  if Assigned(FMarker) then
    FMarker.Free;

  inherited;
end;

function TGMMarkerItem.GetDisplayName: string;
begin
  if Length(Marker.Title) > 0 then
  begin
    if Length(Marker.Title) > 15 then
      Result := Copy(Marker.Title, 0, 12) + '...'
    else
      Result := Marker.Title;
  end
  else
  begin
    Result := inherited GetDisplayName + Index.ToString;
    Marker.Title := Result;
    Name := Result;
  end;
end;

procedure TGMMarkerItem.PropertyChanged(Prop: TPersistent; PropName: string);
var
  Intf: IGMControlChanges;
begin
  if (GetOwner <> nil) and Supports(GetOwner, IGMControlChanges, Intf) then
  begin
    if Assigned(Prop) then
      Intf.PropertyChanged(Prop, Self.ClassName + '_' + PropName)
    else
      Intf.PropertyChanged(Self, Self.ClassName + '_' + PropName);
  end
  else
    if Assigned(OnChange) then OnChange(Self);
end;

end.
