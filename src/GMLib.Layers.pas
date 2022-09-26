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

end.
