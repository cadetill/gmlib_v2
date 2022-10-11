{
  @abstract(Interfaces, base classes and support classes for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 21, 2022)

  The GMLib.Classes unit provides access to interfaces and base classes used into GMLib.
}
unit GMLib.Classes;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils, System.Classes,
  {$ELSE}
  SysUtils, Classes,
  {$ENDIF}

  GMLib.Sets;

type
  { ************************************************************************** }
  { ***********************  Interfaces definition  ************************** }
  { ************************************************************************** }

  // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.txt)
  IGMAPIUrl = interface(IInterface)
    ['{BF91F436-B314-4128-ADA3-02147063A90C}']
    // @exclude
    function GetAPIUrl: string;
    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;
  end;

  // @include(..\Help\docs\GMLib.Classes.IGMToStr.txt)
  IGMToStr = interface(IInterface)
    ['{314C6DAD-B258-4D0C-A275-229491430B65}']
    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string;
  end;

  // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.txt)
  IGMControlChanges = interface(IInterface)
    ['{4731A754-4D4B-4AA2-978E-AF2838925A06}']
    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);
  end;

  // @include(..\Help\docs\GMLib.Classes.IGMOwnerLang.txt)
  IGMOwnerLang = interface(IInterface)
    ['{98DE1EC1-454C-494A-893A-2B57DC4C341F}']
    // @include(..\Help\docs\GMLib.Classes.IGMOwnerLang.GetOwnerLang.txt)
    function GetOwnerLang: TGMLang;
  end;

  // @include(..\Help\docs\GMLib.Classes.IGMExecJS.txt)
  IGMExecJS = interface(IInterface)
    ['{C1C87DC5-BDFD-4AA1-9BF7-C5FF01290339}']
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(FunctName, Params: string);
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.GetJsonFromHTMLForms.txt)
    function GetJsonFromHTMLForms: string;
  end;

  { ************************************************************************** }
  { *************************  classes definition  *************************** }
  { ************************************************************************** }

  // @include(..\Help\docs\GMLib.Classes.TGMObject.txt)
  TGMObject = class(TInterfacedObject, IGMAPIUrl)
  protected
    // @exclude
    function GetAPIUrl: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;
  public
    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TObject); virtual;
  end;

  // @include(..\Help\docs\GMLib.Classes.TGMInterfacedOwnedPersistent.txt)
  TGMInterfacedOwnedPersistent = class(TInterfacedPersistent)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
  protected
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedOwnedPersistent.GetOwner.txt)
    function GetOwner: TPersistent; override;
    // @exclude
    procedure ControlChanges(PropName: string); virtual;

    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedOwnedPersistent.OnChange.txt)
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedOwnedPersistent.Create.txt)
    constructor Create(AOwner: TPersistent); virtual;
  end;

  // @include(..\Help\docs\GMLib.Classes.TGMPersistent.txt)
  TGMPersistent = class(TGMInterfacedOwnedPersistent, IGMAPIUrl)
  protected
    // @exclude
    function GetAPIUrl: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;
  end;

  // @include(..\Help\docs\GMLib.Classes.TGMPersistentStr.txt)
  TGMPersistentStr = class(TGMPersistent, IGMToStr, IGMOwnerLang)
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMOwnerLang.GetOwnerLang.txt)
    function GetOwnerLang: TGMLang; virtual;
  end;

  // @include(..\Help\docs\GMLib.Classes.TGMComponent.txt)
  TGMComponent = class(TComponent, IGMAPIUrl, IGMToStr)
  private
    FLanguage: TGMLang;
    function GetAboutGMLib: string;
  protected
    // @exclude
    function GetAPIUrl: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;

    // @include(..\Help\docs\GMLib.Classes.TGMComponent.Language.txt)
    property Language: TGMLang read FLanguage write FLanguage default lnEnglish;
    // @include(..\Help\docs\GMLib.Classes.TGMComponent.AboutGMLib.txt)
    property AboutGMLib: string read GetAboutGMLib stored False;
  public
    // @include(..\Help\docs\GMLib.Classes.TGMComponent.Create.txt)
    constructor Create(AOwner: TComponent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  end;

  // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollectionItem.txt)
  TGMInterfacedCollectionItem = class(TCollectionItem, IGMToStr, IGMOwnerLang, IGMAPIUrl)
  private
    FOnChange: TNotifyEvent;
    FFObject: TObject;
    FTag: Integer;
    FName: string;
  protected
    // @exclude
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    // @exclude
    function _AddRef: Integer; virtual; stdcall;
    // @exclude
    function _Release: Integer; virtual; stdcall;
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollectionItem.GetDisplayName.txt)
    function GetDisplayName: string; override;

    // @exclude
    function GetAPIUrl: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMOwnerLang.GetOwnerLang.txt)
    function GetOwnerLang: TGMLang; virtual;

    // @exclude
    procedure ControlChanges(PropName: string); virtual;

    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollectionItem.OnChange.txt)
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;

    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollectionItem.FObject.txt)
    property FObject: TObject read FFObject write FFObject;
  published
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollectionItem.Tag.txt)
    property Tag: Integer read FTag write FTag default 0;
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollectionItem.Name.txt)
    property Name: string read FName write FName;
  end;

  // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.txt)
  TGMInterfacedCollection = class(TCollection, IGMControlChanges, IGMOwnerLang, IGMToStr)
  private
    FOnChange: TNotifyEvent;
    FOwner: TPersistent;
  protected
    // @exclude
    function GetItems(I: Integer): TGMInterfacedCollectionItem;
    // @exclude
    procedure SetItems(I: Integer; const Value: TGMInterfacedCollectionItem);

    // @exclude
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    // @exclude
    function _AddRef: Integer; virtual; stdcall;
    // @exclude
    function _Release: Integer; virtual; stdcall;

    // @include(..\Help\docs\GMLib.Classes.IGMOwnerLang.GetOwnerLang.txt)
    function GetOwnerLang: TGMLang; virtual;

    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.GetOwner.txt)
    function GetOwner: TPersistent; override;

    // @exclude
    procedure ControlChanges(PropName: string); virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; virtual;

    function Add: TGMInterfacedCollectionItem;
    function Insert(Index: Integer): TGMInterfacedCollectionItem;
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Delete.txt)
    procedure Delete(Index: Integer);
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Move.txt)
    procedure Move(CurIndex, NewIndex: Integer);
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Clear.txt)
    procedure Clear;

    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.OnChange.txt)
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Items.txt)
    property Items[I: Integer]: TGMInterfacedCollectionItem read GetItems write SetItems; default;
  public
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Create.txt)
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass); virtual;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.TypInfo,
  {$ELSE}
  TypInfo,
  {$ENDIF}

  GMLib.Constants;

{ TGMObject }

procedure TGMObject.Assign(Source: TObject);
begin
  //
end;

function TGMObject.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

{ TGMComponent }

procedure TGMComponent.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMComponent then
  begin
    Language := TGMComponent(Source).Language;
  end;
end;

constructor TGMComponent.Create(AOwner: TComponent);
begin
  inherited;

  FLanguage := lnEnglish;
end;

function TGMComponent.GetAboutGMLib: string;
begin
  Result := ctGMLib_Version;
end;

function TGMComponent.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

function TGMComponent.PropToString: string;
begin
  Result := '';
end;

{ TGMInterfacedOwnedPersistent }

procedure TGMInterfacedOwnedPersistent.ControlChanges(PropName: string);
var
  Intf: IGMControlChanges;
begin
  if (FOwner <> nil) and Supports(FOwner, IGMControlChanges, Intf) then
    Intf.PropertyChanged(Self, Self.ClassName + '_' + PropName)
  else
    if Assigned(FOnChange) then FOnChange(Self);
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
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

{ TGMPersistentStr }

function TGMPersistentStr.GetOwnerLang: TGMLang;
var
  Intf: IGMOwnerLang;
begin
  Result := lnEnglish;

  if not Assigned(GetOwner()) then Exit;
  if not Supports(GetOwner(), IGMOwnerLang, Intf) then Exit;

  Result := Intf.GetOwnerLang;
end;

function TGMPersistentStr.PropToString: string;
begin
  Result := '';
end;

{ TGMInterfacedCollectionItem }

procedure TGMInterfacedCollectionItem.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMInterfacedCollectionItem then
  begin
    Name := TGMInterfacedCollectionItem(Source).Name;
    Tag := TGMInterfacedCollectionItem(Source).Tag;
    FObject := TGMInterfacedCollectionItem(Source).FObject;
  end;
end;

procedure TGMInterfacedCollectionItem.ControlChanges(PropName: string);
var
  Intf: IGMControlChanges;
begin
  if (GetOwner <> nil) and Supports(GetOwner, IGMControlChanges, Intf) then
    Intf.PropertyChanged(Self, PropName)
  else
    if Assigned(FOnChange) then FOnChange(Self);
end;

function TGMInterfacedCollectionItem.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

function TGMInterfacedCollectionItem.GetDisplayName: string;
begin
  if Length(FName) > 0 then
  begin
    if Length(FName) > 15 then
      Result := Copy(FName, 0, 15) + '...'
    else
      Result := FName;
  end
  else
  begin
    Result := inherited GetDisplayName;
    FName := Result;
  end;
end;

function TGMInterfacedCollectionItem.GetOwnerLang: TGMLang;
var
  Intf: IGMOwnerLang;
begin
  Result := lnEnglish;

  if not Assigned(Collection) then Exit;
  if not Supports(Collection, IGMOwnerLang, Intf) then Exit;

  Result := Intf.GetOwnerLang;
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

{ TGMInterfacedCollection }

function TGMInterfacedCollection.Add: TGMInterfacedCollectionItem;
begin
  Result := TGMInterfacedCollectionItem(inherited Add);

  ControlChanges('Items');
end;

procedure TGMInterfacedCollection.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMInterfacedCollection then
    FOwner := TGMInterfacedCollection(Source).FOwner;
end;

procedure TGMInterfacedCollection.Clear;
begin
  inherited Clear;

  ControlChanges('Items');
end;

procedure TGMInterfacedCollection.ControlChanges(PropName: string);
var
  Intf: IGMControlChanges;
begin
  if (GetOwner <> nil) and Supports(GetOwner, IGMControlChanges, Intf) then
    Intf.PropertyChanged(Self, PropName)
  else
    if Assigned(FOnChange) then FOnChange(Self);
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

function TGMInterfacedCollection.GetOwnerLang: TGMLang;
var
  Intf: IGMOwnerLang;
begin
  Result := lnEnglish;

  if not Assigned(FOwner) then Exit;
  if not Supports(FOwner, IGMOwnerLang, Intf) then Exit;

  Result := Intf.GetOwnerLang;
end;

function TGMInterfacedCollection.Insert(Index: Integer): TGMInterfacedCollectionItem;
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
  ControlChanges(PropName);
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

end.
