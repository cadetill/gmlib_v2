unit Father;

interface

uses
  System.Classes, REST.Json.Types;

type
  IHola = interface(IInterface)
    ['{CC4A100F-199E-43B2-B95E-BA7233A3C935}']
    function GetAPIUrl: string;
    property APIUrl: string read GetAPIUrl;
  end;

  IBye = interface
    ['{314C6DAD-B258-4D0C-A275-229491430B65}']
    function PropToString: string;
  end;

  IBrother = interface
    ['{98DE1EC1-454C-494A-893A-2B57DC4C341F}']
    function GetOwnerLang: string;
  end;

  IMother = interface(IInterface)
    ['{4731A754-4D4B-4AA2-978E-AF2838925A06}']
    procedure PropertyChanged(Prop: TPersistent; PropName: string);
  end;

  TFather = class(TInterfacedPersistent)
  private
    [JSONMarshalled(False)]
    FOwner: TPersistent;
    [JSONMarshalled(False)]
    FOnChange: TNotifyEvent;
  public
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AOwner: TPersistent); virtual;
  end;

  TFirst = class(TFather)
  protected
    function GetAPIUrl: string; virtual;
    property APIUrl: string read GetAPIUrl;
  end;

  TSecond = class(TFirst, IBye, IBrother)
  protected
    function PropToString: string; virtual;
    function GetOwnerLang: string; virtual;
  end;


  TGMInterfacedOwnedPersistent = class(TInterfacedPersistent)
  private
    [JSONMarshalled(False)]
    FOwner: TPersistent;
    [JSONMarshalled(False)]
    FOnChange: TNotifyEvent;
  protected
    function GetOwner: TPersistent; override;
    procedure ControlChanges(PropName: string); virtual;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AOwner: TPersistent); virtual;
  end;

  TGMPersistent = class(TGMInterfacedOwnedPersistent, IHola)
  protected
    function GetAPIUrl: string; virtual;

    property APIUrl: string read GetAPIUrl;
  end;

  TGMPersistentStr = class(TGMPersistent, IBye, IBrother)
  protected
    function PropToString: string; virtual;
    function GetOwnerLang: string; virtual;
  end;

  TGMCustomLabelOptions = class(TGMPersistentStr)
  private
    FFontFamily: string;
    FFontWeight: Integer;
    FFontSize: Integer;
    FLabelClassName: string;
    FText: string;
  protected
    function GetAPIUrl: string; override;
    function PropToString: string; override;

    property Text: string read FText write FText;
    property LabelClassName: string read FLabelClassName write FLabelClassName;
    property FontFamily: string read FFontFamily write FFontFamily;
    property FontSize: Integer read FFontSize write FFontSize;
    property FontWeight: Integer read FFontWeight write FFontWeight;
  public
    property APIUrl;
  end;

  TGMInterfacedCollectionItem = class(TCollectionItem, IHola, IBye, IBrother)
  private
    [JSONMarshalled(False)]
    FOnChange: TNotifyEvent;
    [JSONMarshalled(False)]
    FFObject: TObject;
    [JSONMarshalled(False)]
    FTag: Integer;
    FName: string;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;

    function GetAPIUrl: string; virtual;
    function PropToString: string; virtual;
    function GetOwnerLang: string; virtual;

    function GetDisplayName: string; override;
    procedure ControlChanges(PropName: string); virtual;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    procedure Assign(Source: TPersistent); override;

    property APIUrl: string read GetAPIUrl;

    property FObject: TObject read FFObject write FFObject;
  published
    property Tag: Integer read FTag write FTag default 0;
    property Name: string read FName write FName;
  end;

  TGMCustomMarker = class(TGMInterfacedCollectionItem)
  private
    FOpacity: Double;
    FDraggable: Boolean;
    FOptimized: Boolean;
    FTitle: string;
    FCursor: string;
    FVisible: Boolean;
    FCrossOnDrag: Boolean;
    FClickable: Boolean;
    FLabelText: TGMCustomLabelOptions;
  protected
    function GetDisplayName: string; override;
    function GetAPIUrl: string; override;
    procedure PropertyChanged(Prop: TPersistent; PropName: string);
    function PropToString: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property APIUrl;
    property Clickable: Boolean read FClickable write FClickable;
    property CrossOnDrag: Boolean read FCrossOnDrag write FCrossOnDrag;
    property Cursor: string read FCursor write FCursor;
    property Draggable: Boolean read FDraggable write FDraggable;
    property Opacity: Double read FOpacity write FOpacity;
    property Optimized: Boolean read FOptimized write FOptimized;
    property Title: string read FTitle write FTitle;
    property Visible: Boolean read FVisible write FVisible;
    property LabelText: TGMCustomLabelOptions read FLabelText write FLabelText;
  end;

  TGMInterfacedCollection = class(TCollection, IBrother, IBye, IMother)
  private
    [JSONMarshalled(False)]
    FOnChange: TNotifyEvent;
    [JSONMarshalled(False)]
    FOwner: TPersistent;

    function GetItems(I: Integer): TGMInterfacedCollectionItem;
    procedure SetItems(I: Integer; const Value: TGMInterfacedCollectionItem);
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;

    function GetOwnerLang: string; virtual;
    function GetOwner: TPersistent; override;
    procedure ControlChanges(PropName: string); virtual;
    procedure PropertyChanged(Prop: TPersistent; PropName: string);
    function PropToString: string; virtual;

    function Add: TGMInterfacedCollectionItem;
    function Insert(Index: Integer): TGMInterfacedCollectionItem;
    procedure Delete(Index: Integer);
    procedure Move(CurIndex, NewIndex: Integer);
    procedure Clear;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Items[I: Integer]: TGMInterfacedCollectionItem read GetItems write SetItems; default;
  public
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass); virtual;
  end;

  TGMMarkerList = class(TGMInterfacedCollection)
  private
    function GetItems(I: Integer): TGMCustomMarker;
    procedure SetItems(I: Integer; const Value: TGMCustomMarker);
  public
    function Add: TGMCustomMarker;
    function Insert(Index: Integer): TGMCustomMarker;

    property Items[I: Integer]: TGMCustomMarker read GetItems write SetItems; default;
  end;

implementation

{ TFather }

constructor TFather.Create(AOwner: TPersistent);
begin
  FOwner := AOwner;
end;

{ TFirst }

function TFirst.GetAPIUrl: string;
begin
  Result := '';
end;

{ TSecond }

function TSecond.GetOwnerLang: string;
begin
  Result := '';
end;

function TSecond.PropToString: string;
begin
  Result := '';
end;

{ TGMInterfacedCollectionItem }

procedure TGMInterfacedCollectionItem.Assign(Source: TPersistent);
begin
  inherited;

end;

procedure TGMInterfacedCollectionItem.ControlChanges(PropName: string);
begin

end;

function TGMInterfacedCollectionItem.GetAPIUrl: string;
begin
  Result := '';
end;

function TGMInterfacedCollectionItem.GetDisplayName: string;
begin
  Result := '';
end;

function TGMInterfacedCollectionItem.GetOwnerLang: string;
begin
  Result := '';
end;

function TGMInterfacedCollectionItem.PropToString: string;
begin
  Result := '';
end;

function TGMInterfacedCollectionItem.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := S_OK
  else Result := E_NOINTERFACE;
end;

function TGMInterfacedCollectionItem._AddRef: Integer;
begin
  Result := -1;
end;

function TGMInterfacedCollectionItem._Release: Integer;
begin
  Result := -1;
end;

{ TGMCustomMarker }

constructor TGMCustomMarker.Create(Collection: TCollection);
begin
  inherited;

  FLabelText := TGMCustomLabelOptions.Create(Self);
end;

destructor TGMCustomMarker.Destroy;
begin
  FLabelText.Free;
  inherited;
end;

function TGMCustomMarker.GetAPIUrl: string;
begin
  Result := '';
end;

function TGMCustomMarker.GetDisplayName: string;
begin
  Result := '';
end;

procedure TGMCustomMarker.PropertyChanged(Prop: TPersistent; PropName: string);
begin

end;

function TGMCustomMarker.PropToString: string;
begin
  Result := '';
end;

{ TGMInterfacedOwnedPersistent }

procedure TGMInterfacedOwnedPersistent.ControlChanges(PropName: string);
begin
end;

constructor TGMInterfacedOwnedPersistent.Create(AOwner: TPersistent);
begin
  FOwner := AOwner;
end;

function TGMInterfacedOwnedPersistent.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

{ TGMPersistent }

function TGMPersistent.GetAPIUrl: string;
begin
  Result := '';
end;

{ TGMPersistentStr }

function TGMPersistentStr.GetOwnerLang: string;
begin
  Result := '';
end;

function TGMPersistentStr.PropToString: string;
begin
  Result := '';
end;

{ TGMCustomLabelOptions }

function TGMCustomLabelOptions.GetAPIUrl: string;
begin

end;

function TGMCustomLabelOptions.PropToString: string;
begin

end;

{ TGMInterfacedCollection }

function TGMInterfacedCollection.Add: TGMInterfacedCollectionItem;
begin
  Result := TGMInterfacedCollectionItem(inherited Add);

  ControlChanges('Items');
end;

procedure TGMInterfacedCollection.Clear;
begin
  inherited Clear;

  ControlChanges('Items');
end;

procedure TGMInterfacedCollection.ControlChanges(PropName: string);
begin

end;

constructor TGMInterfacedCollection.Create(AOwner: TPersistent;
  ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);

  FOwner := AOwner;
end;

procedure TGMInterfacedCollection.Delete(Index: Integer);
begin
  inherited Delete(Index);

  ControlChanges('Items');
end;

function TGMInterfacedCollection.GetItems(
  I: Integer): TGMInterfacedCollectionItem;
begin
  Result := TGMInterfacedCollectionItem(inherited Items[I]);
end;

function TGMInterfacedCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TGMInterfacedCollection.GetOwnerLang: string;
begin
  Result := '';
end;

function TGMInterfacedCollection.Insert(
  Index: Integer): TGMInterfacedCollectionItem;
begin
  Result := TGMInterfacedCollectionItem(inherited Insert(Index));

  ControlChanges('Items');
end;

procedure TGMInterfacedCollection.Move(CurIndex, NewIndex: Integer);
begin
  Items[CurIndex].Index := NewIndex;

  ControlChanges('Items');
end;

procedure TGMInterfacedCollection.PropertyChanged(Prop: TPersistent;
  PropName: string);
begin

end;

function TGMInterfacedCollection.PropToString: string;
begin
  Result := '';
end;

function TGMInterfacedCollection.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := S_OK
  else Result := E_NOINTERFACE;
end;

procedure TGMInterfacedCollection.SetItems(I: Integer;
  const Value: TGMInterfacedCollectionItem);
begin
  inherited SetItem(I, Value);
end;

function TGMInterfacedCollection._AddRef: Integer;
begin
  Result := -1;
end;

function TGMInterfacedCollection._Release: Integer;
begin
  Result := -1;
end;

{ TGMMarkerList }

function TGMMarkerList.Add: TGMCustomMarker;
begin
  Result := TGMCustomMarker(inherited Add);
end;

function TGMMarkerList.GetItems(I: Integer): TGMCustomMarker;
begin
  Result := TGMCustomMarker(inherited Items[I]);
end;

function TGMMarkerList.Insert(Index: Integer): TGMCustomMarker;
begin
  Result := TGMCustomMarker(inherited Insert(Index));
end;

procedure TGMMarkerList.SetItems(I: Integer; const Value: TGMCustomMarker);
begin
  inherited SetItem(I, Value);
end;

end.
