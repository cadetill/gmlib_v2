{
  @abstract(Interfaces, base classes and support classes for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Septembre 30, 2015)
  @lastmod(Octobre 1, 2015)

  The GMClasses unit provides access to interfaces and base classes used into GMLib.
}
unit GMClasses;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils, System.Classes,
  {$ELSE}
  SysUtils, Classes,
  {$ENDIF}

  GMSets;

type
  { ************************************************************************** }
  { ***********************  Interfaces definition  ************************** }
  { ************************************************************************** }

  // @include(..\docs\GMClasses.IGMAPIUrl.txt)
  IGMAPIUrl = interface(IInterface)
    ['{BF91F436-B314-4128-ADA3-02147063A90C}']
    // @exclude
    function GetAPIUrl: string;
    // @include(..\docs\GMClasses.IGMAPIUrl.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;
  end;

  // @include(..\docs\GMClasses.IGMToStr.txt)
  IGMToStr = interface(IInterface)
    ['{314C6DAD-B258-4D0C-A275-229491430B65}']
    // @include(..\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string;
  end;

  // @include(..\docs\GMClasses.IGMControlChanges.txt)
  IGMControlChanges = interface(IInterface)
    ['{4731A754-4D4B-4AA2-978E-AF2838925A06}']
    // @include(..\docs\GMClasses.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent);
  end;

  // @include(..\docs\GMClasses.IGMOwnerLang.txt)
  IGMOwnerLang = interface(IInterface)
    ['{98DE1EC1-454C-494A-893A-2B57DC4C341F}']
    // @include(..\docs\GMClasses.IGMOwnerLang.GetOwnerLang.txt)
    function GetOwnerLang: TGMLang;
  end;

  // @include(..\docs\GMClasses.IGMExecJS.txt)
  IGMExecJS = interface(IInterface)
    ['{C1C87DC5-BDFD-4AA1-9BF7-C5FF01290339}']
    // @include(..\docs\GMClasses.IGMExecJS.ExecuteScript.txt)
    function ExecuteScript(NameFunct, Params: string): Boolean;
  end;

  { ************************************************************************** }
  { *************************  classes definition  *************************** }
  { ************************************************************************** }

  // @include(..\docs\GMClasses.EGMException.txt)
  EGMException = class(Exception)
  public
    // @include(..\docs\GMClasses.EGMException.Create_1.txt)
    constructor Create(const Msg: string; const Args: array of const; Lang: TGMLang); reintroduce; overload; virtual;
    // @include(..\docs\GMClasses.EGMException.Create_2.txt)
    constructor Create(const Idx: Integer; const Args: array of const; Lang: TGMLang); reintroduce; overload; virtual;
  end;

  // @include(..\docs\GMClasses.EGMNotValidRealNumber.txt)
  EGMNotValidRealNumber = class(EGMException);
  // @include(..\docs\GMClasses.EGMWithoutOwner.txt)
  EGMWithoutOwner = class(EGMException);
  // @include(..\docs\GMClasses.EGMOwnerWithoutJS.txt)
  EGMOwnerWithoutJS = class(EGMException);
  // @include(..\docs\GMClasses.EGMJSError.txt)
  EGMJSError = class(EGMException);
  // @include(..\docs\GMClasses.EGMUnassignedObject.txt)
  EGMUnassignedObject = class(EGMException);
  // @include(..\docs\GMClasses.EGMMapIsActive.txt)
  EGMMapIsActive = class(EGMException);

  { -------------------------------------------------------------------------- }
  // @include(..\docs\GMClasses.TGMObject.txt)
  TGMObject = class(TInterfacedObject, IGMAPIUrl)
  protected
    // @exclude
    function GetAPIUrl: string; virtual;

    // @include(..\docs\GMClasses.TGMObject.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;
  public
    // @include(..\docs\GMClasses.TGMObject.Assign.txt)
    procedure Assign(Source: TObject); virtual;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\docs\GMClasses.TGMInterfacedOwnedPersistent.txt)
  TGMInterfacedOwnedPersistent = class(TInterfacedPersistent)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
  protected
    // @include(..\docs\GMClasses.TGMInterfacedOwnedPersistent.GetOwner.txt)
    function GetOwner: TPersistent; override;
    // @exclude
    procedure ControlChanges; virtual;

    // Event triggered when a property changes.
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    // @abstract(Constructor class.)
    // @param AOwner Owner of object
    constructor Create(AOwner: TPersistent); virtual;
  end;

  { -------------------------------------------------------------------------- }
  {
    @abstract(Base class for all classes that inherit from @code(TGMInterfacedOwnedPersistent) into GMLib and implements @code(IGMAPIUrl) interface.)
  }
  TGMPersistent = class(TGMInterfacedOwnedPersistent, IGMAPIUrl)
  protected
    // @exclude
    function GetAPIUrl: string; virtual;

    // URL to Google Maps API class
    property APIUrl: string read GetAPIUrl;
  end;

  { -------------------------------------------------------------------------- }
  {
    @abstract(Base class for all classes that inherit from @code(TGMPersistent) into GMLib and implements @code(IGMToStr) and @code(IGMOwnerLang) interfaces.)
  }
  TGMPersistentStr = class(TGMPersistent, IGMToStr, IGMOwnerLang)
  protected
    // Converts all class properties values to a string separated by semicolon.
    // @return string with all properties.
    function PropToString: string; virtual; abstract;

    // Returns the Lang of the Owner.@br@br If Owner is not assigned or not supports IGMOwnerLang interface then returns @code(lnEnglish).)
    // @return TLang of the owner object.
    function GetOwnerLang: TGMLang; virtual;
  end;

  { -------------------------------------------------------------------------- }
  {
    @abstract(Base class for all classes that inherit from @code(TComponent) into GMLib.)
    Implements @code(IGMAPIUrl) interface.
  }
  TGMComponent = class(TComponent, IGMAPIUrl)
  private
    FLanguage: TGMLang;
    FAboutGMLib: string;
  protected
    // @exclude
    function GetAPIUrl: string; virtual;

    // URL to Google Maps API class
    property APIUrl: string read GetAPIUrl;

    // Language property specifies the language in which messages are displayed the exceptions shown by the class/component.
    property Language: TGMLang read FLanguage write FLanguage default lnEnglish;
    // This property shows an “About” form with info of the GMLib.
    property AboutGMLib: string read FAboutGMLib stored False;
  public
    // @abstract(Constructor class.)
    // @param AOwner Component owner.
    constructor Create(AOwner: TComponent); override;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);)@br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;
  end;

  { -------------------------------------------------------------------------- }
  {
    @abstract(Base class for all classes that inherit from @code(TCollectionItem) into GMLib.)
    Implements @code(IGMAPIUrl), @code(IGMOwnerLang) and @code(IGMAPIUrl) interfaces.
  }
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
    // Returns the name of the collection item as it appears in the collection editor. See Delphi documentation for more details.
    // @return String with the name
    function GetDisplayName: string; override;

    // @exclude
    function GetAPIUrl: string; virtual;

    // Converts all class properties values to a string separated by semicolon.
    // @return string with all properties.
    function PropToString: string; virtual; abstract;

    // Returns the Lang of the Owner.@br@br If Owner is not assigned or not supports IGMOwnerLang interface then returns @code(lnEnglish).)
    // @return TLang of the owner object.
    function GetOwnerLang: TGMLang; virtual;

    // @exclude
    procedure ControlChanges; virtual;

    // Event triggered when a property changes.
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);)@br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;

    // URL to Google Maps API class
    property APIUrl: string read GetAPIUrl;

    // Represents an object that is associated with the item.
    property FObject: TObject read FFObject write FFObject;
  published
    // Tag property has no predefined meaning. It can store any additional integer value for the convenience of developers.
    property Tag: Integer read FTag write FTag default 0;
    property Name: string read FName write FName;
  end;

  { -------------------------------------------------------------------------- }
  {
    @abstract(Base class for all classes that inherit from @code(TCollection) into GMLib.)
    Implements @code(IGMControlChanges) and @code(IGMOwnerLang) interfaces.
  }
  TGMInterfacedCollection = class(TCollection, IGMControlChanges, IGMOwnerLang)
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

    // Returns the Lang of the Owner.@br@br If Owner is not assigned or not supports IGMOwnerLang interface then returns @code(lnEnglish).)
    // @return TLang of the owner object.
    function GetOwnerLang: TGMLang; virtual;

    // Function that return the owner of object
    // @return Owner of object
    function GetOwner: TPersistent; override;

    // @exclude
    procedure ControlChanges; virtual;

    // Method to call of the owner object when changes a property of the object.
    // @param Prop Object property that has changed.
    procedure PropertyChanged(Prop: TPersistent);

    // Deletes a single item from the collection.
    // @param Index Position to delete
    procedure Delete(Index: Integer);
    // Moves a item to a new position into the collection.
    // @param CurIndex Index of Item to move
    // @param NewIndex Destination index
    procedure Move(CurIndex, NewIndex: Integer);
    // Deletes all items from the collection.
    procedure Clear;

    // Event triggered when a property changes.
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    // List of items from collection.
    property Items[I: Integer]: TGMInterfacedCollectionItem read GetItems write SetItems; default;
  public
    // @abstract(Constructor class.)
    // @param AOwner Object owner.
    // @param ItemClass Identifies the TCollectionItem descendants that must be used to represent the items in the collection.
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass); virtual;

    // Call @code(Assign) to copy the properties or other attributes of one object from another. The standard form of a call to @code(Assign) is@br @code(Destination.Assign(Source);)@br which tells the @code(Destination) object to copy the contents of the @code(Source) object to itself.
    // @param Source Object to copy the content.
    procedure Assign(Source: TPersistent); override;
  end;

  { -------------------------------------------------------------------------- }
  {
    @abstract(Contains methods of transformations.)
  }
  TGMTransform = record
  public
    // Returns a string that represents a boolean value. This function have sense since some people have localized the original Delphi function.
    // @param B Boolean value to convert.
    // @param UseBoolStrs If true, returns a string value with "true" or "false" values, else returns "0" or "-1".
    // @return string that represents the boolean value.
    class function GMBoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string; static;

    // Returns a string with the MapTypeId included into MapTypeIds.
    // @param MapTypeIds TGMMapTypeIds to convert to string
    // @param Delimiter Delimiter between MapTypeId
    // @return string with the MapTypeIds
    class function MapTypeIdsToStr(MapTypeIds: TGMMapTypeIds; Delimiter: Char = ';'): string; static;

    // Returns a string that represents the @code(Visibility).
    // @param Visibility TGMVisibility to convert to string.
    // @return string with the Visibility.
    class function VisibilityToStr(Visibility: TGMVisibility): string; static;
    // Returns the TGMVisibility represented by the string @code(Visibility).
    // @param Visibility String to convert to TGMVisibility
    // @return TGMVisibility that represents the string
    class function StrToVisibility(Visibility: string): TGMVisibility; static;
    // Returns a string that represents the Position.
    // @param Position TGMControlPosition to convert to string
    // @return string with the Position
    class function PositionToStr(Position: TGMControlPosition): string; static;
    // Returns a string that represents the MapTypeControlStyle.
    // @param MapTypeControlStyle TGMMapTypeControlStyle to convert to string
    // @return string with the MapTypeControlStyle
    class function MapTypeControlStyleToStr(MapTypeControlStyle: TGMMapTypeControlStyle): string; static;
    // Returns a string that represents the ScaleControlStyle.
    // @param ScaleControlStyle TGMScaleControlStyle to convert to string
    // @return string with the ScaleControlStyle
    class function ScaleControlStyleToStr(ScaleControlStyle: TGMScaleControlStyle): string; static;
    // Returns a string that represents the ZoomControlStyle.
    // @param ZoomControlStyle TGMZoomControlStyle to convert to string
    // @return string with the ZoomControlStyle
    class function ZoomControlStyleToStr(ZoomControlStyle: TGMZoomControlStyle): string; static;
    // Returns a string that represents the MapTypeStyleElementType.
    // @param MapTypeStyleElementType TGMMapTypeStyleElementType to convert to string
    // @return string with the MapTypeStyleElementType
    class function MapTypeStyleElementTypeToStr(MapTypeStyleElementType: TGMMapTypeStyleElementType): string; static;
    // Returns a string that represents the MapTypeStyleFeatureType.
    // @param MapTypeStyleFeatureType TGMMapTypeStyleFeatureType to convert to string
    // @return string with the MapTypeStyleFeatureType
    class function MapTypeStyleFeatureTypeToStr(MapTypeStyleFeatureType: TGMMapTypeStyleFeatureType): string; static;
    // Returns a string that represents the MapTypeId.
    // @param MapTypeId TMapTypeId to convert to string
    // @return string with the MapTypeId
    class function MapTypeIdToStr(MapTypeId: TGMMapTypeId): string; static;
  end;

implementation

uses
  {$IFDEF DELPHIXE2}
  System.TypInfo,
  {$ELSE}
  TypInfo,
  {$ENDIF}

  GMTranslations;

{ TGMObject }

procedure TGMObject.Assign(Source: TObject);
begin
  //
end;

function TGMObject.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

{ EGMException }

constructor EGMException.Create(const Msg: string; const Args: array of const;
  Lang: TGMLang);
begin
  inherited Create(GetTranslateText(Msg, Args, Lang));
end;

constructor EGMException.Create(const Idx: Integer; const Args: array of const;
  Lang: TGMLang);
begin
  inherited Create(GetTranslateText(Idx, Args, Lang));
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

function TGMComponent.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

{ TGMInterfacedOwnedPersistent }

procedure TGMInterfacedOwnedPersistent.ControlChanges;
var
  Intf: IGMControlChanges;
begin
  if (FOwner <> nil) and Supports(FOwner, IGMControlChanges, Intf) then
    Intf.PropertyChanged(Self)
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

{ TGMTransform }

class function TGMTransform.GMBoolToStr(B, UseBoolStrs: Boolean): string;
const
  cSimpleBoolStrs: array [boolean] of string = ('0', '-1');
begin
  if UseBoolStrs then
  begin
    if B then Result := 'true'
    else Result := 'false';
  end
  else
    Result := cSimpleBoolStrs[B];
end;

class function TGMTransform.MapTypeControlStyleToStr(
  MapTypeControlStyle: TGMMapTypeControlStyle): string;
begin
  Result := GetEnumName(TypeInfo(TGMMapTypeControlStyle), Ord(MapTypeControlStyle));
end;

class function TGMTransform.MapTypeIdsToStr(MapTypeIds: TGMMapTypeIds;
  Delimiter: Char): string;
begin
  Result := '';

  if mtHYBRID in MapTypeIds then
    Result := Result + 'mtHYBRID';

  if mtROADMAP in MapTypeIds then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + 'mtROADMAP';
  end;

  if mtSATELLITE in MapTypeIds then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + 'mtSATELLITE';
  end;

  if mtTERRAIN in MapTypeIds then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + 'mtTERRAIN';
  end;

  if mtOSM in MapTypeIds then
  begin
    if Result <> '' then Result := Result + Delimiter;
    Result := Result + 'mtOSM';
  end;
end;

class function TGMTransform.MapTypeIdToStr(MapTypeId: TGMMapTypeId): string;
begin
  Result := GetEnumName(TypeInfo(TGMMapTypeId), Ord(MapTypeId));
end;

class function TGMTransform.MapTypeStyleElementTypeToStr(
  MapTypeStyleElementType: TGMMapTypeStyleElementType): string;
begin
  Result := GetEnumName(TypeInfo(TGMMapTypeStyleElementType), Ord(MapTypeStyleElementType));
end;

class function TGMTransform.MapTypeStyleFeatureTypeToStr(
  MapTypeStyleFeatureType: TGMMapTypeStyleFeatureType): string;
begin
  Result := GetEnumName(TypeInfo(TGMMapTypeStyleFeatureType), Ord(MapTypeStyleFeatureType));
end;

class function TGMTransform.PositionToStr(Position: TGMControlPosition): string;
begin
  Result := GetEnumName(TypeInfo(TGMControlPosition), Ord(Position));
end;

class function TGMTransform.ScaleControlStyleToStr(
  ScaleControlStyle: TGMScaleControlStyle): string;
begin
  Result := GetEnumName(TypeInfo(TGMScaleControlStyle), Ord(ScaleControlStyle));
end;

class function TGMTransform.StrToVisibility(Visibility: string): TGMVisibility;
begin
  Result := TGMVisibility(GetEnumValue(TypeInfo(TGMVisibility), Visibility));
end;

class function TGMTransform.VisibilityToStr(Visibility: TGMVisibility): string;
begin
  Result := GetEnumName(TypeInfo(TGMVisibility), Ord(Visibility));
end;

class function TGMTransform.ZoomControlStyleToStr(
  ZoomControlStyle: TGMZoomControlStyle): string;
begin
  Result := GetEnumName(TypeInfo(TGMZoomControlStyle), Ord(ZoomControlStyle));
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

procedure TGMInterfacedCollectionItem.ControlChanges;
var
  Intf: IGMControlChanges;
begin
  if (GetOwner <> nil) and Supports(GetOwner, IGMControlChanges, Intf) then
    Intf.PropertyChanged(Self)
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

procedure TGMInterfacedCollection.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMInterfacedCollection then
    FOwner := TGMInterfacedCollection(Source).FOwner;
end;

procedure TGMInterfacedCollection.Clear;
begin
  inherited Clear;

  ControlChanges;
end;

procedure TGMInterfacedCollection.ControlChanges;
var
  Intf: IGMControlChanges;
begin
  if (GetOwner <> nil) and Supports(GetOwner, IGMControlChanges, Intf) then
    Intf.PropertyChanged(Self)
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

  ControlChanges;
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

procedure TGMInterfacedCollection.Move(CurIndex, NewIndex: Integer);
begin
  Items[CurIndex].Index := NewIndex;

  ControlChanges;
end;

procedure TGMInterfacedCollection.PropertyChanged(Prop: TPersistent);
begin
  ControlChanges;
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
