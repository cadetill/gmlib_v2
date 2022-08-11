{
  @abstract(Interfaces, base classes and support classes for GMLib.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 2, 2022)
  @lastmod(August 2, 2022)

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
  { *************************  Events definition  **************************** }
  { ************************************************************************** }

  // @include(..\Help\docs\GMLib.Classes.TPropertyChanges.txt)
  TPropertyChanges = procedure(Owner: TObject; PropName: string) of object;

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
  TGMComponent = class(TComponent, IGMAPIUrl)
  private
    FLanguage: TGMLang;
    FAboutGMLib: string;
  protected
    // @exclude
    function GetAPIUrl: string; virtual;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl: string read GetAPIUrl;

    // @include(..\Help\docs\GMLib.Classes.TGMComponent.Language.txt)
    property Language: TGMLang read FLanguage write FLanguage default lnEnglish;
    // @include(..\Help\docs\GMLib.Classes.TGMComponent.AboutGMLib.txt)
    property AboutGMLib: string read FAboutGMLib stored False;
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

    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Delete.txt)
    procedure Delete(Index: Integer);
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Move.txt)
    procedure Move(CurIndex, NewIndex: Integer);
    // @include(..\Help\docs\GMLib.Classes.TGMInterfacedCollection.Clear.txt)
    procedure Clear;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; virtual;

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
(*
  // @include(..\Help\docs\GMClasses.TGMTransform.txt)
  TGMTransform = record
  public
    // @include(..\Help\docs\GMClasses.TGMTransform.GoogleAPIVerToStr.txt)
    class function GoogleAPIVerToStr(GoogleAPIVer: TGoogleAPIVer): string; static;
    // @include(..\Help\docs\GMClasses.TGMTransform.APILangToStr.txt)
    class function APILangToStr(APILang: TGMAPILang): string; static;
    // @include(..\Help\docs\GMClasses.TGMTransform.VisibilityToStr.txt)
    class function VisibilityToStr(Visibility: TGMVisibility): string; static;
    // @include(..\Help\docs\GMClasses.TGMTransform.StrToVisibility.txt)
    class function StrToVisibility(Visibility: string): TGMVisibility; static;
    // @include(..\Help\docs\GMClasses.TGMTransform.MapTypeControlStyleToStr.txt)
    class function MapTypeControlStyleToStr(MapTypeControlStyle: TGMMapTypeControlStyle): string; static;
    // @include(..\Help\docs\GMClasses.TGMTransform.MapTypeStyleElementTypeToStr.txt)
    class function MapTypeStyleElementTypeToStr(MapTypeStyleElementType: TGMMapTypeStyleElementType): string; static;
    // @include(..\Help\docs\GMClasses.TGMTransform.MapTypeStyleFeatureTypeToStr.txt)
    class function MapTypeStyleFeatureTypeToStr(MapTypeStyleFeatureType: TGMMapTypeStyleFeatureType): string; static;
    // @include(..\Help\docs\GMClasses.TGMTransform.MapTypeIdToStr.txt)
    class function MapTypeIdToStr(MapTypeId: TGMMapTypeId): string; static;

    // @include(..\Help\docs\GMClasses.TGMTransform.StrToPosition.txt)
    class function StrToPosition(Position: string): TGMControlPosition; static;
  end;
*)
implementation

uses
  {$IFDEF DELPHIXE2}
  System.TypInfo
  {$ELSE}
  TypInfo
  {$ENDIF}
  ;

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

function TGMComponent.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference';
end;

{ TGMInterfacedOwnedPersistent }

procedure TGMInterfacedOwnedPersistent.ControlChanges(PropName: string);
var
  Intf: IGMControlChanges;
begin
  if (FOwner <> nil) and Supports(FOwner, IGMControlChanges, Intf) then
    Intf.PropertyChanged(Self, PropName)
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

(*
{ TGMTransform }

class function TGMTransform.APILangToStr(APILang: TGMAPILang): string;
begin
  Result := GetEnumName(TypeInfo(TGMAPILang), Ord(APILang));

  case APILang of
    lArabic: Result := 'ar';
    lBulgarian: Result := 'bg';
    lBengali: Result := 'bn';
    lCatalan: Result := 'ca';
    lCzech: Result := 'cs';
    lDanish: Result := 'da';
    lGerman: Result := 'de';
    lGreek: Result := 'el';
    lEnglish: Result := 'en';
    lEnglish_Aust: Result := 'en-AU';
    lEnglish_GB: Result := 'en-GB';
    lSpanish: Result := 'es';
    lBasque: Result := 'eu';
    lFarsi: Result := 'fa';
    lFinnish: Result := 'fi';
    lFilipino: Result := 'fil';
    lFrench: Result := 'fr';
    lGalician: Result := 'gl';
    lGujarati: Result := 'gu';
    lHindi: Result := 'hi';
    lCroatian: Result := 'hr';
    lHungarian: Result := 'hu';
    lIndonesian: Result := 'id';
    lItalian: Result := 'it';
    lHebrew: Result := 'iw';
    lJapanese: Result := 'ja';
    lKannada: Result := 'kn';
    lKorean: Result := 'ko';
    lLithuanian: Result := 'lt';
    lLatvian: Result := 'lv';
    lMalayalam: Result := 'ml';
    lMarathi: Result := 'mr';
    lDutch: Result := 'nl';
    lNorwegian: Result := 'no';
    lPolish: Result := 'pl';
    lPortuguese: Result := 'pt';
    lPortuguese_Br: Result := 'pt-BR';
    lPortuguese_Ptg: Result := 'pt-PT';
    lRomanian: Result := 'ro';
    lRussian: Result := 'ru';
    lSlovak: Result := 'sk';
    lSlovenian: Result := 'sl';
    lSerbian: Result := 'sr';
    lSwedish: Result := 'sv';
    lTamil: Result := 'ta';
    lTelugu: Result := 'te';
    lThai: Result := 'th';
    lTagalog: Result := 'tl';
    lTurkish: Result := 'tr';
    lUkrainian: Result := 'uk';
    lVietnamese: Result := 'vi';
    lChinese_Simp: Result := 'zh-CN';
    lChinese_Trad: Result := 'zh-TW';
    lUndefined: Result := '';
  end;
end;

class function TGMTransform.GoogleAPIVerToStr(
  GoogleAPIVer: TGoogleAPIVer): string;
begin
  case GoogleAPIVer of
    api348: Result := '3.48';
    apiNewest: Result := '3.x';
  end;
end;

class function TGMTransform.MapTypeControlStyleToStr(
  MapTypeControlStyle: TGMMapTypeControlStyle): string;
begin
  Result := GetEnumName(TypeInfo(TGMMapTypeControlStyle), Ord(MapTypeControlStyle));
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

class function TGMTransform.StrToPosition(Position: string): TGMControlPosition;
begin
  Result := TGMControlPosition(GetEnumValue(TypeInfo(TGMControlPosition), Position));
end;

class function TGMTransform.StrToVisibility(Visibility: string): TGMVisibility;
begin
  Result := TGMVisibility(GetEnumValue(TypeInfo(TGMVisibility), Visibility));
end;

class function TGMTransform.VisibilityToStr(Visibility: TGMVisibility): string;
begin
  Result := GetEnumName(TypeInfo(TGMVisibility), Ord(Visibility));
end;
*)

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

procedure TGMInterfacedCollection.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMInterfacedCollection then
    FOwner := TGMInterfacedCollection(Source).FOwner;
end;

procedure TGMInterfacedCollection.Clear;
begin
  inherited Clear;

  ControlChanges('');
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

  ControlChanges('');
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

  ControlChanges('');
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
