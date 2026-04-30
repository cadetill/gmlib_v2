{**
  @abstract(Especializaciones VCL del modelo de info windows.)
}
unit uGMLib.Vcl.InfoWindow;

{$I ..\..\gmlib.inc}

interface

uses
  System.Classes,
  uGMLib.InfoWindow;

type
  TGMVclInfoWindowOptions = class(TGMInfoWindowOptions)
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

  TGMVclInfoWindowItem = class(TGMInfoWindowItem)
  private
    function GetOptions: TGMVclInfoWindowOptions;
    procedure SetOptions(const Value: TGMVclInfoWindowOptions);
  protected
    function CreateInfoWindowOptions: TGMInfoWindowOptions; override;
  published
    property APIUrl;
    property Options: TGMVclInfoWindowOptions read GetOptions write SetOptions;
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

  TGMVclInfoWindows = class(TGMInfoWindows)
  private
    function GetItem(Index: Integer): TGMVclInfoWindowItem;
    procedure SetItem(Index: Integer; const Value: TGMVclInfoWindowItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TGMVclInfoWindowItem;
  published
    property APIUrl;
    property CloseOthersBeforeOpen;
  public
    property Items[Index: Integer]: TGMVclInfoWindowItem read GetItem write SetItem; default;
  end;

implementation

{ TGMVclInfoWindowItem }

function TGMVclInfoWindowItem.CreateInfoWindowOptions: TGMInfoWindowOptions;
begin
  Result := TGMVclInfoWindowOptions.Create;
end;

function TGMVclInfoWindowItem.GetOptions: TGMVclInfoWindowOptions;
begin
  Result := TGMVclInfoWindowOptions(inherited Options);
end;

procedure TGMVclInfoWindowItem.SetOptions(const Value: TGMVclInfoWindowOptions);
begin
  inherited Options := Value;
end;

{ TGMVclInfoWindows }

function TGMVclInfoWindows.Add: TGMVclInfoWindowItem;
begin
  Result := TGMVclInfoWindowItem(inherited Add);
end;

constructor TGMVclInfoWindows.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TGMVclInfoWindowItem);
end;

function TGMVclInfoWindows.GetItem(Index: Integer): TGMVclInfoWindowItem;
begin
  Result := TGMVclInfoWindowItem(inherited Items[Index]);
end;

procedure TGMVclInfoWindows.SetItem(Index: Integer; const Value: TGMVclInfoWindowItem);
begin
  if Assigned(Value) then
    inherited Items[Index].Assign(Value);
end;

end.
