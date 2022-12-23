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
  // @include(..\Help\docs\GMLib.Marker.TGMPoint.txt)
  TGMPoint = class(TGMPersistentStr)
  private
    FX: Double;
    FY: Double;
    procedure SetX(const Value: Double);
    procedure SetY(const Value: Double);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMPoint.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Marker.TGMPoint.x.txt)
    property X: Double read FX write SetX;
    // @include(..\Help\docs\GMLib.Marker.TGMPoint.y.txt)
    property Y: Double read FY write SetY;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMSize.txt)
  TGMSize = class(TGMPersistentStr)
  private
    FHeight: Double;
    FWidth: Double;
    procedure SetHeight(const Value: Double);
    procedure SetWidth(const Value: Double);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Height.txt)
    property Height: Double read FHeight write SetHeight;
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Width.txt)
    property Width: Double read FWidth write SetWidth;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMIconOptions.txt)
  TGMIconOptions = class(TGMPersistentStr, IGMControlChanges)
  private
    FScaledSize: Integer;
    FOrigin: TGMPoint;
    FAnchor: TGMPoint;
    FSize: TGMSize;
    FLabelOrigin: TGMPoint;
    FUrl: string;
    procedure SetScaledSize(const Value: Integer);
    procedure SetUrl(const Value: string);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Marker.TGMIconOptions.Url.txt)
    property Url: string read FUrl write SetUrl;
    // @include(..\Help\docs\GMLib.Marker.TGMIconOptions.Anchor.txt)
    property Anchor: TGMPoint read FAnchor write FAnchor;
    // @include(..\Help\docs\GMLib.Marker.TGMIconOptions.LabelOrigin.txt)
    property LabelOrigin: TGMPoint read FLabelOrigin write FLabelOrigin;
    // @include(..\Help\docs\GMLib.Marker.TGMIconOptions.Origin.txt)
    property Origin: TGMPoint read FOrigin write FOrigin;
    // @include(..\Help\docs\GMLib.Marker.TGMIconOptions.ScaledSize.txt)
    property ScaledSize: Integer read FScaledSize write SetScaledSize;
    // @include(..\Help\docs\GMLib.Marker.TGMIconOptions.Size.txt)
    property Size: TGMSize read FSize write FSize;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.txt)
  TGMCustomSymbolOptions = class(TGMPersistentStr, IGMControlChanges)
  private
    FPath: TGMSymbolPath;
    FRotation: Integer;
    FAnchor: TGMPoint;
    FStrokeWeight: Integer;
    FLabelOrigin: TGMPoint;
    FFillOpacity: Double;
    FScale: Integer;
    FStrokeOpacity: Double;
    procedure SetFillOpacity(const Value: Double);
    procedure SetPath(const Value: TGMSymbolPath);
    procedure SetRotation(const Value: Integer);
    procedure SetScale(const Value: Integer);
    procedure SetStrokeOpacity(const Value: Double);
    procedure SetStrokeWeight(const Value: Integer);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Path.txt)
    property Path: TGMSymbolPath read FPath write SetPath;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Anchor.txt)
    property Anchor: TGMPoint read FAnchor write FAnchor;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.FillOpacity.txt)
    property FillOpacity: Double read FFillOpacity write SetFillOpacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.LabelOrigin.txt)
    property LabelOrigin: TGMPoint read FLabelOrigin write FLabelOrigin;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Rotation.txt)
    property Rotation: Integer read FRotation write SetRotation;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Scale.txt)
    property Scale: Integer read FScale write SetScale;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.StrokeOpacity.txt)
    property StrokeOpacity: Double read FStrokeOpacity write SetStrokeOpacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.StrokeWeight.txt)
    property StrokeWeight: Integer read FStrokeWeight write SetStrokeWeight;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Destroy.txt)
    destructor Destroy; override;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.txt)
  TGMCustomIconOptions = class(TGMPersistentStr, IGMControlChanges)
  private
    FUrl: string;
    FIcon: TGMIconOptions;
    procedure SetUrl(const Value: string);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Url.txt)
    property Url: string read FUrl write SetUrl;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Icon.txt)
    property Icon: TGMIconOptions read FIcon write FIcon;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Destroy.txt)
    destructor Destroy; override;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.txt)
  TGMCustomLabelOptions = class(TGMPersistentStr)
  private
    FFontFamily: string;
    FFontWeight: Integer;
    FFontSize: Integer;
    FLabelClassName: string;
    FText: string;
    procedure SetLabelClassName(const Value: string);
    procedure SetFontFamily(const Value: string);
    procedure SetFontSize(const Value: Integer);
    procedure SetFontWeight(const Value: Integer);
    procedure SetText(const Value: string);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.Text.txt)
    property Text: string read FText write SetText;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.ClassName.txt)
    property LabelClassName: string read FLabelClassName write SetLabelClassName;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.FontFamily.txt)
    property FontFamily: string read FFontFamily write SetFontFamily;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.FontSize.txt)
    property FontSize: Integer read FFontSize write SetFontSize;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.FontWeight.txt)
    property FontWeight: Integer read FFontWeight write SetFontWeight;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomLabelOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.txt)
  TGMCustomMarker = class(TGMInterfacedCollectionItem, IGMControlChanges)
  private
    FOpacity: Double;
    FAnimation: TGMAnimation;
    FDraggable: Boolean;
    FOptimized: Boolean;
    FTitle: string;
    FCursor: string;
    FAnchorPoint: TGMPoint;
    FVisible: Boolean;
    FCollisionBehavior: TGMCollisionBehavior;
    FCrossOnDrag: Boolean;
    FClickable: Boolean;
    FPosition: TGMLatLng;
    procedure SetAnimation(const Value: TGMAnimation);
    procedure SetClickable(const Value: Boolean);
    procedure SetCollisionBehavior(const Value: TGMCollisionBehavior);
    procedure SetCrossOnDrag(const Value: Boolean);
    procedure SetCursor(const Value: string);
    procedure SetDraggable(const Value: Boolean);
    procedure SetOpacity(const Value: Double);
    procedure SetOptimized(const Value: Boolean);
    procedure SetPosition(const Value: TGMLatLng);
    procedure SetTitle(const Value: string);
    procedure SetVisible(const Value: Boolean);
    function GetZIndex: Integer;
  protected
    // @exclude
    function GetDisplayName: string; override;

    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.AnchorPoint.txt)
    property AnchorPoint: TGMPoint read FAnchorPoint write FAnchorPoint;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Animation.txt)
    property Animation: TGMAnimation read FAnimation write SetAnimation;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Clickable.txt)
    property Clickable: Boolean read FClickable write SetClickable;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.CollisionBehavior.txt)
    property CollisionBehavior: TGMCollisionBehavior read FCollisionBehavior write SetCollisionBehavior;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.CrossOnDrag.txt)
    property CrossOnDrag: Boolean read FCrossOnDrag write SetCrossOnDrag;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Cursor.txt)
    property Cursor: string read FCursor write SetCursor;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Draggable.txt)
    property Draggable: Boolean read FDraggable write SetDraggable;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Opacity.txt)
    property Opacity: Double read FOpacity write SetOpacity;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Optimized.txt)
    property Optimized: Boolean read FOptimized write SetOptimized;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Position.txt)
    property Position: TGMLatLng read FPosition write SetPosition;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Title.txt)
    property Title: string read FTitle write SetTitle;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Visible.txt)
    property Visible: Boolean read FVisible write SetVisible;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.ZIndex.txt)
    property ZIndex: Integer read GetZIndex;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Create.txt)
    constructor Create(Collection: TCollection); override;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  end;

  // @include(..\Help\docs\GMLib.Marker.TGMCustomMarkers.txt)
  TGMCustomMarkers = class(TGMPersistentStr, IGMControlChanges)
  private
    FAutoUpdate: Boolean;
    procedure SetAutoUpdate(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarkers.AutoUpdate.txt)
    property AutoUpdate: Boolean read FAutoUpdate write SetAutoUpdate;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  GMLib.Transform;

{ TGMCustomSymbolOptions }

constructor TGMCustomSymbolOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FPath := spFORWARD_OPEN_ARROW;
  FAnchor := TGMPoint.Create(Self);
  FFillOpacity := 0;
  FLabelOrigin := TGMPoint.Create(Self);
  FRotation := 0;
  FScale := 1;
  FStrokeOpacity := 1;
  FStrokeWeight := FScale;
end;

destructor TGMCustomSymbolOptions.Destroy;
begin
  if Assigned(FAnchor) then FAnchor.Free;
  if Assigned(FLabelOrigin) then FLabelOrigin.Free;

  inherited;
end;

function TGMCustomSymbolOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/marker#Symbol';
end;

procedure TGMCustomSymbolOptions.PropertyChanged(Prop: TPersistent;
  PropName: string);
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

function TGMCustomSymbolOptions.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s,%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(TGMTransform.SymbolPathToStr(FPath)),
                         FAnchor.PropToString,
                         TGMTransform.GetDoubleToStr(FFillOpacity),
                         FLabelOrigin.PropToString,
                         IntToStr(FRotation),
                         IntToStr(FScale),
                         TGMTransform.GetDoubleToStr(FStrokeOpacity),
                         IntToStr(FStrokeWeight)
                        ]);
end;

procedure TGMCustomSymbolOptions.SetFillOpacity(const Value: Double);
begin
  if FFillOpacity = Value then Exit;

  FFillOpacity := Value;

  if FFillOpacity < 0 then FFillOpacity := 0;
  if FFillOpacity > 1 then FFillOpacity := 1;
  FFillOpacity := Trunc(FFillOpacity * 100) / 100;

  ControlChanges('FillOpacity');
end;

procedure TGMCustomSymbolOptions.SetPath(const Value: TGMSymbolPath);
begin
  if FPath = Value then Exit;

  FPath := Value;
  ControlChanges('Path');
end;

procedure TGMCustomSymbolOptions.SetRotation(const Value: Integer);
begin
  if FRotation = Value then Exit;

  FRotation := Value;
  ControlChanges('Rotation');
end;

procedure TGMCustomSymbolOptions.SetScale(const Value: Integer);
begin
  if FScale = Value then Exit;

  FScale := Value;
  ControlChanges('Scale');
end;

procedure TGMCustomSymbolOptions.SetStrokeOpacity(const Value: Double);
begin
  if FStrokeOpacity = Value then Exit;

  FStrokeOpacity := Value;
  ControlChanges('StrokeOpacity');
end;

procedure TGMCustomSymbolOptions.SetStrokeWeight(const Value: Integer);
begin
  if FStrokeWeight = Value then Exit;

  FStrokeWeight := Value;
  ControlChanges('StrokeWeight');
end;

{ TGMCustomIconOptions }

constructor TGMCustomIconOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FUrl := '';
  FIcon := TGMIconOptions.Create(Self);
end;

destructor TGMCustomIconOptions.Destroy;
begin
  if Assigned(FIcon) then FIcon.Free;

  inherited;
end;

function TGMCustomIconOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/marker#MarkerOptions.icon';
end;

procedure TGMCustomIconOptions.PropertyChanged(Prop: TPersistent;
  PropName: string);
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

function TGMCustomIconOptions.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(FUrl),
                         FIcon.PropToString
                        ]);
end;

procedure TGMCustomIconOptions.SetUrl(const Value: string);
begin
  if FUrl = Value then Exit;

  FUrl := Value;
  ControlChanges('Url');
end;

{ TGMCustomMarker }

procedure TGMCustomMarker.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomMarker then
  begin
    AnchorPoint := TGMCustomMarker(Source).AnchorPoint;
    Animation := TGMCustomMarker(Source).Animation;
    Clickable := TGMCustomMarker(Source).Clickable;
    CollisionBehavior := TGMCustomMarker(Source).CollisionBehavior;
    CrossOnDrag := TGMCustomMarker(Source).CrossOnDrag;
    Cursor := TGMCustomMarker(Source).Cursor;
    Draggable := TGMCustomMarker(Source).Draggable;
    Opacity := TGMCustomMarker(Source).Opacity;
    Optimized := TGMCustomMarker(Source).Optimized;
    Position.Assign(TGMCustomMarker(Source).Position);
    Title := TGMCustomMarker(Source).Title;
    Visible := TGMCustomMarker(Source).Visible;
  end;
end;

constructor TGMCustomMarker.Create(Collection: TCollection);
begin
  inherited;

  FAnchorPoint := TGMPoint.Create(Self);
  FAnimation := aniNONE;
  FClickable := True;
  FCollisionBehavior := cbNONE;
  FCrossOnDrag := True;
  FCursor := '';
  FDraggable := False;
  FOpacity := 1;
  FOptimized := True;
  FPosition := TGMLatLng.Create(Self, 0, 0, False);
  FTitle := '';
  FVisible := True;
  Name := GetDisplayName;
end;

destructor TGMCustomMarker.Destroy;
begin
  if Assigned(FAnchorPoint) then FAnchorPoint.Free;
  if Assigned(FPosition) then FPosition.Free;

  inherited;
end;

function TGMCustomMarker.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/marker';
end;

function TGMCustomMarker.GetDisplayName: string;
begin
  if Length(FTitle) > 0 then
  begin
    if Length(FTitle) > 15 then
      Result := Copy(FTitle, 0, 12) + '...'
    else
      Result := FTitle;
  end
  else
  begin
    Result := inherited GetDisplayName;
    FTitle := Result;
  end;
end;

function TGMCustomMarker.GetZIndex: Integer;
begin
  Result := Index;
end;

procedure TGMCustomMarker.PropertyChanged(Prop: TPersistent; PropName: string);
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

function TGMCustomMarker.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         FAnchorPoint.PropToString,
                         QuotedStr(TGMTransform.AnimationToStr(FAnimation)),
                         LowerCase(TGMTransform.GMBoolToStr(FClickable, True)),
                         QuotedStr(TGMTransform.CollisionBehaviorToStr(FCollisionBehavior)),
                         LowerCase(TGMTransform.GMBoolToStr(FCrossOnDrag, True)),
                         QuotedStr(FCursor),
                         LowerCase(TGMTransform.GMBoolToStr(FDraggable, True)),
                         TGMTransform.GetDoubleToStr(FOpacity),
                         LowerCase(TGMTransform.GMBoolToStr(FOptimized, True)),
                         Position.PropToString,
                         QuotedStr(FTitle),
                         LowerCase(TGMTransform.GMBoolToStr(FVisible, True)),
                         IntToStr(ZIndex)
                        ]);
end;

procedure TGMCustomMarker.SetAnimation(const Value: TGMAnimation);
begin
  if FAnimation = Value then Exit;

  FAnimation := Value;
  ControlChanges('Animation');
end;

procedure TGMCustomMarker.SetClickable(const Value: Boolean);
begin
  if FClickable = Value then Exit;

  FClickable := Value;
  ControlChanges('Clickable');
end;

procedure TGMCustomMarker.SetCollisionBehavior(
  const Value: TGMCollisionBehavior);
begin
  if FCollisionBehavior = Value then Exit;

  FCollisionBehavior := Value;
  ControlChanges('CollisionBehavior');
end;

procedure TGMCustomMarker.SetCrossOnDrag(const Value: Boolean);
begin
  if FCrossOnDrag = Value then Exit;

  FCrossOnDrag := Value;
  ControlChanges('CrossOnDrag');
end;

procedure TGMCustomMarker.SetCursor(const Value: string);
begin
  if FCursor = Value then Exit;

  FCursor := Value;
  ControlChanges('Cursor');
end;

procedure TGMCustomMarker.SetDraggable(const Value: Boolean);
begin
  if FDraggable = Value then Exit;

  FDraggable := Value;
  ControlChanges('Draggable');
end;

procedure TGMCustomMarker.SetOpacity(const Value: Double);
begin
  if FOpacity = Value then Exit;

  FOpacity := Value;

  if FOpacity < 0 then FOpacity := 0;
  if FOpacity > 1 then FOpacity := 1;
  FOpacity := Trunc(FOpacity * 100) / 100;

  ControlChanges('Opacity');
end;

procedure TGMCustomMarker.SetOptimized(const Value: Boolean);
begin
  if FOptimized = Value then Exit;

  FOptimized := Value;
  ControlChanges('Optimized');
end;

procedure TGMCustomMarker.SetPosition(const Value: TGMLatLng);
begin
  if FPosition = Value then Exit;

  FPosition := Value;
  ControlChanges('Position');
end;

procedure TGMCustomMarker.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit;

  FTitle := Value;
  ControlChanges('Title');
end;

procedure TGMCustomMarker.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit;

  FVisible := Value;
  ControlChanges('Visible');
end;

{ TGMPoint }

procedure TGMPoint.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMPoint then
  begin
    X := TGMPoint(Source).X;
    Y := TGMPoint(Source).Y;
  end;
end;

constructor TGMPoint.Create(AOwner: TPersistent);
begin
  inherited;

  FX := 0;
  FY := 0;
end;

function TGMPoint.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/coordinates#Point';
end;

function TGMPoint.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         TGMTransform.GetDoubleToStr(FX),
                         TGMTransform.GetDoubleToStr(FY)
                        ]);
end;

procedure TGMPoint.SetX(const Value: Double);
begin
  if FX = Value then Exit;

  FX := Value;
  ControlChanges('X');
end;

procedure TGMPoint.SetY(const Value: Double);
begin
  if FY = Value then Exit;

  FY := Value;
  ControlChanges('Y');
end;

{ TGMSize }

procedure TGMSize.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMSize then
  begin
    Height := TGMSize(Source).Height;
    Width := TGMSize(Source).Width;
  end;
end;

constructor TGMSize.Create(AOwner: TPersistent);
begin
  inherited;

  FHeight := 0;
  FWidth := 0;
end;

function TGMSize.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/coordinates#Size';
end;

function TGMSize.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         TGMTransform.GetDoubleToStr(FHeight),
                         TGMTransform.GetDoubleToStr(FWidth)
                        ]);
end;

procedure TGMSize.SetHeight(const Value: Double);
begin
  if FHeight = Value then Exit;

  FHeight := Value;
  ControlChanges('Height');
end;

procedure TGMSize.SetWidth(const Value: Double);
begin
  if FWidth = Value then Exit;

  FWidth := Value;
  ControlChanges('Width');
end;

{ TGMIconOptions }

procedure TGMIconOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMIconOptions then
  begin
    Url := TGMIconOptions(Source).Url;
    ScaledSize := TGMIconOptions(Source).ScaledSize;
    Anchor.Assign(TGMIconOptions(Source).Anchor);
    LabelOrigin.Assign(TGMIconOptions(Source).LabelOrigin);
    Origin.Assign(TGMIconOptions(Source).Origin);
    Size.Assign(TGMIconOptions(Source).Size);
  end;
end;

constructor TGMIconOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FUrl := '';
  FAnchor := TGMPoint.Create(Self);
  FLabelOrigin := TGMPoint.Create(Self);
  FOrigin := TGMPoint.Create(Self);
  FScaledSize := 0;
  FSize := TGMSize.Create(Self);
end;

destructor TGMIconOptions.Destroy;
begin
  if Assigned(FAnchor) then FAnchor.Free;
  if Assigned(FLabelOrigin) then FLabelOrigin.Free;
  if Assigned(FOrigin) then FOrigin.Free;
  if Assigned(FSize) then FSize.Free;

  inherited;
end;

function TGMIconOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/marker#Icon';
end;

procedure TGMIconOptions.PropertyChanged(Prop: TPersistent; PropName: string);
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

function TGMIconOptions.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(FUrl),
                         FAnchor.PropToString,
                         FLabelOrigin.PropToString,
                         FOrigin.PropToString,
                         TGMTransform.GetDoubleToStr(FScaledSize),
                         FSize.PropToString
                        ]);
end;

procedure TGMIconOptions.SetScaledSize(const Value: Integer);
begin
  if FScaledSize = Value then Exit;

  FScaledSize := Value;
  ControlChanges('ScaledSize');
end;

procedure TGMIconOptions.SetUrl(const Value: string);
begin
  if FUrl = Value then Exit;

  FUrl := Value;
  ControlChanges('Url');
end;

{ TGMCustomLabelOptions }

procedure TGMCustomLabelOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMCustomLabelOptions then
  begin
    LabelClassName := TGMCustomLabelOptions(Source).LabelClassName;
    FontFamily := TGMCustomLabelOptions(Source).FontFamily;
    FontSize := TGMCustomLabelOptions(Source).FontSize;
    FFontWeight := TGMCustomLabelOptions(Source).FFontWeight;
    Text := TGMCustomLabelOptions(Source).Text;
  end;
end;

constructor TGMCustomLabelOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FLabelClassName := '';
  FFontFamily := 'Arial';
  FFontSize := 14;
  FFontWeight := 0;
  FText := '';
end;

function TGMCustomLabelOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/marker#MarkerLabel';
end;

function TGMCustomLabelOptions.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(FLabelClassName),
                         QuotedStr(FFontFamily),
                         QuotedStr(IntToStr(FFontSize) + 'px'),
                         QuotedStr(IntToStr(FFontWeight) + 'px'),
                         QuotedStr(FText)
                        ]);
end;

procedure TGMCustomLabelOptions.SetLabelClassName(const Value: string);
begin
  if FLabelClassName = Value then Exit;

  FLabelClassName := Value;
  ControlChanges('LabelClassName');
end;

procedure TGMCustomLabelOptions.SetFontFamily(const Value: string);
begin
  if FFontFamily = Value then Exit;

  FFontFamily := Value;
  ControlChanges('FontFamily');
end;

procedure TGMCustomLabelOptions.SetFontSize(const Value: Integer);
begin
  if FFontSize = Value then Exit;

  FFontSize := Value;
  ControlChanges('FontSize');
end;

procedure TGMCustomLabelOptions.SetFontWeight(const Value: Integer);
begin
  if FFontWeight = Value then Exit;

  FFontWeight := Value;
  ControlChanges('FontWeight');
end;

procedure TGMCustomLabelOptions.SetText(const Value: string);
begin
  if FText = Value then Exit;

  FText := Value;
  ControlChanges('Text');
end;

{ TGMCustomMarkers }

constructor TGMCustomMarkers.Create(AOwner: TPersistent);
begin
  inherited;

  FAutoUpdate := False;
end;

function TGMCustomMarkers.GetAPIUrl: string;
begin
  Result := inherited;
end;

procedure TGMCustomMarkers.PropertyChanged(Prop: TPersistent; PropName: string);
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

function TGMCustomMarkers.PropToString: string;
const
  Str = '%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FAutoUpdate, True))
                        ]);
end;

procedure TGMCustomMarkers.SetAutoUpdate(const Value: Boolean);
begin
  if FAutoUpdate = Value then Exit;

  FAutoUpdate := Value;
  ControlChanges('Text');
end;

end.
