{
  @abstract(Layers for @code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 12, 2022)
  @lastmod(September 14, 2022)

  The GMLib.Layers contains all classes needed to manege all layers classes.
}
unit GMLib.Layers;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}

  GMLib.Classes;

type
  // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayerOptions.txt)
  TGMTrafficLayerOptions = class(TGMPersistentStr)
  private
    FAutoRefresh: Boolean;
    procedure SetAutoRefresh(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayerOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayerOptions.AutoRefresh.txt)
    property AutoRefresh: Boolean read FAutoRefresh write SetAutoRefresh;
  end;

  // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayer.txt)
  TGMTrafficLayer = class(TGMPersistentStr)
  private
    FTrafficLayerOptions: TGMTrafficLayerOptions;
    FShow: Boolean;
    procedure SetShow(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayer.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayer.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayer.Show.txt)
    property Show: Boolean read FShow write SetShow;
    // @include(..\Help\docs\GMLib.Layers.TGMTrafficLayer.TrafficLayerOptions.txt)
    property TrafficLayerOptions: TGMTrafficLayerOptions read FTrafficLayerOptions write FTrafficLayerOptions;
  end;

  // @include(..\Help\docs\GMLib.Layers.TGMTransitLayer.txt)
  TGMTransitLayer = class(TGMPersistentStr)
  private
    FShow: Boolean;
    procedure SetShow(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Layers.TGMTransitLayer.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Layers.TGMTransitLayer.Show.txt)
    property Show: Boolean read FShow write SetShow;
  end;

  // @include(..\Help\docs\GMLib.Layers.TGMByciclingLayer.txt)
  TGMByciclingLayer = class(TGMPersistentStr)
  private
    FShow: Boolean;
    procedure SetShow(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Layers.TGMByciclingLayer.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Layers.TGMByciclingLayer.Show.txt)
    property Show: Boolean read FShow write SetShow;
  end;

  // @include(..\Help\docs\GMLib.Layers.TGMKmlLayerOptions.txt)
  TGMKmlLayerOptions = class(TGMPersistentStr)
  private
    FScreenOverlays: Boolean;
    FSuppressInfoWindows: Boolean;
    FUrl: string;
    FClickable: Boolean;
    FPreserveViewport: Boolean;
    procedure SetClickable(const Value: Boolean);
    procedure SetPreserveViewport(const Value: Boolean);
    procedure SetScreenOverlays(const Value: Boolean);
    procedure SetSuppressInfoWindows(const Value: Boolean);
    procedure SetUrl(const Value: string);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayerOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayerOptions.Clickable.txt)
    property Clickable: Boolean read FClickable write SetClickable default True;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayerOptions.PreserveViewport.txt)
    property PreserveViewport: Boolean read FPreserveViewport write SetPreserveViewport default False;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayerOptions.ScreenOverlays.txt)
    property ScreenOverlays: Boolean read FScreenOverlays write SetScreenOverlays default True;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayerOptions.SuppressInfoWindows.txt)
    property SuppressInfoWindows: Boolean read FSuppressInfoWindows write SetSuppressInfoWindows default False;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayerOptions.Url.txt)
    property Url: string read FUrl write SetUrl;
  end;

  // @include(..\Help\docs\GMLib.Layers.TGMKmlLayer.txt)
  TGMKmlLayer = class(TGMPersistentStr)
  private
    FShow: Boolean;
    FKmlLayerOptions: TGMKmlLayerOptions;
    procedure SetShow(const Value: Boolean);
  protected
    // @exclude
    function GetAPIUrl: string; override;
  public
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayer.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayer.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
  published
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayer.Show.txt)
    property Show: Boolean read FShow write SetShow;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayer.KmlLayerOptions.txt)
    property KmlLayerOptions: TGMKmlLayerOptions read FKmlLayerOptions write FKmlLayerOptions;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  GMLib.Transform;

{ TGMTrafficLayerOptions }

procedure TGMTrafficLayerOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMTrafficLayerOptions then
  begin
    AutoRefresh := TGMTrafficLayerOptions(Source).AutoRefresh;
  end;
end;

constructor TGMTrafficLayerOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FAutoRefresh := True;
end;

function TGMTrafficLayerOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#TrafficLayerOptions';
end;

function TGMTrafficLayerOptions.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FAutoRefresh, True))
                        ]);
end;

procedure TGMTrafficLayerOptions.SetAutoRefresh(const Value: Boolean);
begin
  if FAutoRefresh = Value then Exit;

  FAutoRefresh := Value;
  ControlChanges('AutoRefresh');
end;

{ TGMTrafficLayer }

procedure TGMTrafficLayer.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMTrafficLayer then
  begin
    Show := TGMTrafficLayer(Source).Show;
    TrafficLayerOptions.Assign(TGMTrafficLayer(Source).TrafficLayerOptions);
  end;
end;

constructor TGMTrafficLayer.Create(AOwner: TPersistent);
begin
  inherited;

  FShow := False;
  FTrafficLayerOptions := TGMTrafficLayerOptions.Create(Self);
end;

destructor TGMTrafficLayer.Destroy;
begin
  if Assigned(FTrafficLayerOptions) then
    FTrafficLayerOptions.Free;

  inherited;
end;

function TGMTrafficLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#TrafficLayer';
end;

function TGMTrafficLayer.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FShow, True)),
                         FTrafficLayerOptions.PropToString
                        ]);
end;

procedure TGMTrafficLayer.SetShow(const Value: Boolean);
begin
  if FShow = Value then Exit;

  FShow := Value;
  ControlChanges('Show');
end;

{ TGMTransitLayer }

procedure TGMTransitLayer.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMTransitLayer then
  begin
    Show := TGMTransitLayer(Source).Show;
  end;
end;

constructor TGMTransitLayer.Create(AOwner: TPersistent);
begin
  inherited;

  FShow := False;
end;

function TGMTransitLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#TransitLayer';
end;

function TGMTransitLayer.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FShow, True))
                        ]);
end;

procedure TGMTransitLayer.SetShow(const Value: Boolean);
begin
  if FShow = Value then Exit;

  FShow := Value;
  ControlChanges('Show');
end;

{ TGMByciclingLayer }

procedure TGMByciclingLayer.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMByciclingLayer then
  begin
    Show := TGMByciclingLayer(Source).Show;
  end;
end;

constructor TGMByciclingLayer.Create(AOwner: TPersistent);
begin
  inherited;

  FShow := False;
end;

function TGMByciclingLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#BicyclingLayer';
end;

function TGMByciclingLayer.PropToString: string;
const
  Str = '%s';
begin
  Result := Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FShow, True))
                        ]);
end;

procedure TGMByciclingLayer.SetShow(const Value: Boolean);
begin
  if FShow = Value then Exit;

  FShow := Value;
  ControlChanges('Show');
end;

{ TGMKmlLayer }

procedure TGMKmlLayer.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMKmlLayer then
  begin
    Show := TGMKmlLayer(Source).Show;
    KmlLayerOptions.Assign(TGMKmlLayer(Source).KmlLayerOptions);
  end;
end;

constructor TGMKmlLayer.Create(AOwner: TPersistent);
begin
  inherited;

  FShow := False;
  FKmlLayerOptions := TGMKmlLayerOptions.Create(Self);
end;

destructor TGMKmlLayer.Destroy;
begin
  if Assigned(FKmlLayerOptions) then
    FKmlLayerOptions.Free;

  inherited;
end;

function TGMKmlLayer.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/kml';
end;

function TGMKmlLayer.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FShow, True)),
                         FKmlLayerOptions.PropToString
                        ]);
end;

procedure TGMKmlLayer.SetShow(const Value: Boolean);
begin
  if FShow = Value then Exit;

  FShow := Value;
  ControlChanges('Show');
end;

{ TGMKmlLayerOptions }

procedure TGMKmlLayerOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMKmlLayerOptions then
  begin
    Clickable := TGMKmlLayerOptions(Source).Clickable;
    PreserveViewport := TGMKmlLayerOptions(Source).PreserveViewport;
    ScreenOverlays := TGMKmlLayerOptions(Source).ScreenOverlays;
    SuppressInfoWindows := TGMKmlLayerOptions(Source).SuppressInfoWindows;
    Url := TGMKmlLayerOptions(Source).Url;
  end;
end;

constructor TGMKmlLayerOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FClickable := True;
  FPreserveViewport := False;
  FScreenOverlays := True;
  FSuppressInfoWindows := False;
  FUrl := '';
end;

function TGMKmlLayerOptions.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/kml#KmlLayerOptions';
end;

function TGMKmlLayerOptions.PropToString: string;
const
  Str = '%s,%s,%s,%s,%s';
begin
  Result := Format(Str, [
                         LowerCase(TGMTransform.GMBoolToStr(FClickable, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FPreserveViewport, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FScreenOverlays, True)),
                         LowerCase(TGMTransform.GMBoolToStr(FSuppressInfoWindows, True)),
                         QuotedStr(FUrl)
                        ]);
end;

procedure TGMKmlLayerOptions.SetClickable(const Value: Boolean);
begin
  if FClickable = Value then Exit;

  FClickable := Value;
  ControlChanges('Clickable');
end;

procedure TGMKmlLayerOptions.SetPreserveViewport(const Value: Boolean);
begin
  if FPreserveViewport = Value then Exit;

  FPreserveViewport := Value;
  ControlChanges('PreserveViewport');
end;

procedure TGMKmlLayerOptions.SetScreenOverlays(const Value: Boolean);
begin
  if FScreenOverlays = Value then Exit;

  FScreenOverlays := Value;
  ControlChanges('ScreenOverlays');
end;

procedure TGMKmlLayerOptions.SetSuppressInfoWindows(const Value: Boolean);
begin
  if FSuppressInfoWindows = Value then Exit;

  FSuppressInfoWindows := Value;
  ControlChanges('SuppressInfoWindows');
end;

procedure TGMKmlLayerOptions.SetUrl(const Value: string);
begin
  if FUrl = Value then Exit;

  FUrl := Value;
  ControlChanges('Url');
end;

end.
