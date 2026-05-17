{**
  @abstract(Especializaciones FMX del modelo de info windows.)
}
unit uGMLib.Fmx.InfoWindow;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  uGMLib.InfoWindow;

type
  TGMFmxInfoWindowOptions = class(TGMInfoWindowOptions)
  published
    property APIUrl;
    property Content;
    property DisableAutoPan;
    property HeaderContent;
    property HeaderDisabled;
    property MaxWidth;
    property MinWidth;
    property Position;
    property Visible;
    property ZIndex;
  end;

  TGMFmxInfoWindowItem = class(TGMInfoWindowItem)
  private
    function GetOptions: TGMFmxInfoWindowOptions;
    procedure SetOptions(const Value: TGMFmxInfoWindowOptions);
  protected
    function CreateInfoWindowOptions: TGMInfoWindowOptions; override;
  published
    property APIUrl;
    property Options: TGMFmxInfoWindowOptions read GetOptions write SetOptions;
    property OnContentChanged;
    property OnClose;
    property OnCloseClick;
    property OnDomReady;
    property OnHeaderContentChanged;
    property OnHeaderDisabledChanged;
    property OnPositionChanged;
    property OnVisible;
    property OnZIndexChanged;
  end;

  TGMFmxInfoWindows = class(TGMInfoWindows)
  private
    function GetItem(Index: Integer): TGMFmxInfoWindowItem;
    procedure SetItem(Index: Integer; const Value: TGMFmxInfoWindowItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMFmxInfoWindowItem;
  published
    property APIUrl;
    property CloseOthersBeforeOpen;
  public
    property Items[Index: Integer]: TGMFmxInfoWindowItem read GetItem write SetItem; default;
  end;

implementation

{ TGMFmxInfoWindowItem }

function TGMFmxInfoWindowItem.CreateInfoWindowOptions: TGMInfoWindowOptions;
begin
  Result := TGMFmxInfoWindowOptions.Create;
end;

function TGMFmxInfoWindowItem.GetOptions: TGMFmxInfoWindowOptions;
begin
  Result := TGMFmxInfoWindowOptions(inherited Options);
end;

procedure TGMFmxInfoWindowItem.SetOptions(const Value: TGMFmxInfoWindowOptions);
begin
  inherited Options := Value;
end;

{ TGMFmxInfoWindows }

function TGMFmxInfoWindows.Add: TGMFmxInfoWindowItem;
begin
  Result := TGMFmxInfoWindowItem(inherited Add);
end;

constructor TGMFmxInfoWindows.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMFmxInfoWindowItem);
end;

function TGMFmxInfoWindows.GetItem(Index: Integer): TGMFmxInfoWindowItem;
begin
  Result := TGMFmxInfoWindowItem(inherited Items[Index]);
end;

procedure TGMFmxInfoWindows.SetItem(Index: Integer; const Value: TGMFmxInfoWindowItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
