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
  public
    // @include(..\Help\docs\GMLib.Marker.TGMPoint.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

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
  public
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

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
  public
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Marker.TGMSize.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

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


    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.FillColor.txt)
    //property FillColor: TColor;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.StrokeColor.txt)
    //property StrokeColor: TColor;
  public
    // @include(..\Help\docs\GMLib.Marker.TGMCustomSymbolOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
  end;

  TGMCustomIconOptions = class(TGMPersistentStr, IGMControlChanges)
  private
    FUrl: string;
    FIcon: TGMIconOptions;
    procedure SetUrl(const Value: string);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Url.txt)
    property Url: string read FUrl write SetUrl;
    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Icon.txt)
    property Icon: TGMIconOptions read FIcon write FIcon;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomIconOptions.Symbol.txt)
    //property Symbol: TGMSymbolOptions;
  end;

  TGMCustomMarker = class(TGMInterfacedCollectionItem)
  private
    FOpacity: Double;
    FLabelText: TGMLabelOptions;
    FAnimation: TGMAnimation;
    FShape: TGMMarkerShape;
    FDraggable: Boolean;
    FOptimized: Boolean;
    FTitle: string;
    FCursor: string;
    FAnchorPoint: TPoint;
    FVisible: Boolean;
    FCollisionBehavior: TGMCollisionBehavior;
    FCrossOnDrag: Boolean;
    FClickable: Boolean;
    FPosition: TGMLatLng;
    procedure SetAnchorPoint(const Value: TPoint);
    procedure SetAnimation(const Value: TGMAnimation);
    procedure SetClickable(const Value: Boolean);
    procedure SetCollisionBehavior(const Value: TGMCollisionBehavior);
    procedure SetCrossOnDrag(const Value: Boolean);
    procedure SetCursor(const Value: string);
    procedure SetDraggable(const Value: Boolean);
    procedure SetLabelText(const Value: TGMLabelOptions);
    procedure SetOpacity(const Value: Double);
    procedure SetOptimized(const Value: Boolean);
    procedure SetPosition(const Value: TGMLatLng);
    procedure SetShape(const Value: TGMMarkerShape);
    procedure SetTitle(const Value: string);
    procedure SetVisible(const Value: Boolean);
  protected
    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.AnchorPoint.txt)
    property AnchorPoint: TPoint read FAnchorPoint write SetAnchorPoint;
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

    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.Icon.txt)
    //property Icon: TGMIconOptions;

    // @include(..\Help\docs\GMLib.Marker.TGMCustomMarker.LabelText.txt)
    property LabelText: TGMLabelOptions read FLabelText write SetLabelText;
    property Opacity: Double read FOpacity write SetOpacity;
    property Optimized: Boolean read FOptimized write SetOptimized;
    property Position: TGMLatLng read FPosition write SetPosition;
    property Shape: TGMMarkerShape read FShape write SetShape;
    property Title: string read FTitle write SetTitle;
    property Visible: Boolean read FVisible write SetVisible;

  public
  end;

  TGMCustomMarkerList = class(TGMInterfacedCollection)
  private
  protected
  public
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
  FAnchor.X := 0;
  FAnchor.Y := 0;
  FFillOpacity := 0;
  FLabelOrigin.X := 0;
  FLabelOrigin.Y := 0;
  FRotation := 0;
  FScale := 1;
  FStrokeOpacity := 1;
  FStrokeWeight := FScale;
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

procedure TGMCustomIconOptions.PropertyChanged(Prop: TPersistent;
  PropName: string);
begin

end;

procedure TGMCustomIconOptions.SetUrl(const Value: string);
begin
  if FUrl = Value then Exit;

  FUrl := Value;
  ControlChanges('Url');
end;

{ TGMCustomMarker }

procedure TGMCustomMarker.SetAnchorPoint(const Value: TPoint);
begin
  FAnchorPoint := Value;
end;

procedure TGMCustomMarker.SetAnimation(const Value: TGMAnimation);
begin
  FAnimation := Value;
end;

procedure TGMCustomMarker.SetClickable(const Value: Boolean);
begin
  FClickable := Value;
end;

procedure TGMCustomMarker.SetCollisionBehavior(
  const Value: TGMCollisionBehavior);
begin
  FCollisionBehavior := Value;
end;

procedure TGMCustomMarker.SetCrossOnDrag(const Value: Boolean);
begin
  FCrossOnDrag := Value;
end;

procedure TGMCustomMarker.SetCursor(const Value: string);
begin
  FCursor := Value;
end;

procedure TGMCustomMarker.SetDraggable(const Value: Boolean);
begin
  FDraggable := Value;
end;

procedure TGMCustomMarker.SetLabelText(const Value: TGMLabelOptions);
begin
  FLabelText := Value;
end;

procedure TGMCustomMarker.SetOpacity(const Value: Double);
begin
  FOpacity := Value;
end;

procedure TGMCustomMarker.SetOptimized(const Value: Boolean);
begin
  FOptimized := Value;
end;

procedure TGMCustomMarker.SetPosition(const Value: TGMLatLng);
begin
  FPosition := Value;
end;

procedure TGMCustomMarker.SetShape(const Value: TGMMarkerShape);
begin
  FShape := Value;
end;

procedure TGMCustomMarker.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TGMCustomMarker.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
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
  Result := Format(Str, [
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
  Result := Format(Str, [
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
  Result := Format(Str, [
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

end.
