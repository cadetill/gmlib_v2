{
  @abstract(@code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(Septembre 30, 2015)
  @lastmod(October 1, 2015)

  The GMMapVCL contains the implementation of TGMMap class that encapsulate the @code(google.maps.Map) class from Google Maps API and other related classes.
}
unit GMMap.VCL;

{$I ..\..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  Vcl.Graphics, System.Classes, SHDocVw, Vcl.ExtCtrls,
  {$ELSE}
  Graphics, Classes, SHDocVw, ExtCtrls,
  {$ENDIF}

  GMMap, GMClasses;

type
  { -------------------------------------------------------------------------- }
  // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.txt)
  TGMMapTypeStyler = class(TGMCustomMapTypeStyler)
  private
    FColor: TColor;
    FHue: TColor;
    procedure SetColor(const Value: TColor);
    procedure SetHue(const Value: TColor);
  protected
    // @include(..\..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  published
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.Color.txt)
    property Color: TColor read FColor write SetColor default clBlack;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.Hue.txt)
    property Hue: TColor read FHue write SetHue default clBlack;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.Gamma.txt)
    property Gamma;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.InvertLightness.txt)
    property InvertLightness;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.Lightness.txt)
    property Lightness;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.Saturation.txt)
    property Saturation;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.Visibility.txt)
    property Visibility;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyler.Weight.txt)
    property Weight;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStylers.txt)
  TGMMapTypeStylers = class(TGMInterfacedCollection)
  private
    function GetItems(I: Integer): TGMMapTypeStyler;
    procedure SetItems(I: Integer; const Value: TGMMapTypeStyler);
  protected
    // @include(..\..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStylers.Add.txt)
    function Add: TGMMapTypeStyler;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStylers.Insert.txt)
    function Insert(Index: Integer): TGMMapTypeStyler;

    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStylers.Items.txt)
    property Items[I: Integer]: TGMMapTypeStyler read GetItems write SetItems; default;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyle.txt)
  TGMMapTypeStyle = class(TGMCustomMapTypeStyle)
  private
    FStylers: TGMMapTypeStylers;
  protected
    // @include(..\..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyle.Create.txt)
    constructor Create(Collection: TCollection); override;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyle.Destroy.txt)
    destructor Destroy; override;
  published
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyle.ElementType.txt)
    property ElementType;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyle.FeatureType.txt)
    property FeatureType;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyle.Stylers.txt)
    property Stylers: TGMMapTypeStylers read FStylers write FStylers;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyles.txt)
  TGMMapTypeStyles = class(TGMInterfacedCollection)
  private
    function GetItems(I: Integer): TGMMapTypeStyle;
    procedure SetItems(I: Integer; const Value: TGMMapTypeStyle);
  protected
    // @include(..\..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyles.Add.txt)
    function Add: TGMMapTypeStyle;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyles.Insert.txt)
    function Insert(Index: Integer): TGMMapTypeStyle;

    // @include(..\..\Help\docs\GMMap.VCL.TGMMapTypeStyles.Items.txt)
    property Items[I: Integer]: TGMMapTypeStyle read GetItems write SetItems; default;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.txt)
  TGMMapOptions = class(TGMCustomMapOptions)
  private
    FBackgroundColor: TColor;
    FStyles: TGMMapTypeStyles;
    procedure SetBackgroundColor(const Value: TColor);
    function GetCountStyles: Integer;
  protected
    // @include(..\..\Help\docs\GMClasses.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.Destroy.txt)
    destructor Destroy; override;

    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.CountStyles.txt)
    property CountStyles: Integer read GetCountStyles;
  published
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.BackgroundColor.txt)
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clBlack;

    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.Center.txt)
    property Center;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.DisableDefaultUI.txt)
    property DisableDefaultUI;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.DisableDoubleClickZoom.txt)
    property DisableDoubleClickZoom;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.Draggable.txt)
    property Draggable;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.DraggableCursor.txt)
    property DraggableCursor;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.DraggingCursor.txt)
    property DraggingCursor;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.FullScreenControl.txt)
    property FullScreenControl;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.FullScreenControlOptions.txt)
    property FullScreenControlOptions;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.Heading.txt)
    property Heading;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.KeyboardShortcuts.txt)
    property KeyboardShortcuts;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.MapTypeControl.txt)
    property MapTypeControl;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.MapTypeControlOptions.txt)
    property MapTypeControlOptions;
    // @include(..\..\Help\docs\GMMap.TGMCustomMapOptions.MapTypeId.txt)
    property MapTypeId;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.MaxZoom.txt)
    property MaxZoom;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.MinZoom.txt)
    property MinZoom;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.NoClear.txt)
    property NoClear;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.RotateControl.txt)
    property RotateControl;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.RotateControlOptions.txt)
    property RotateControlOptions;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.ScaleControl.txt)
    property ScaleControl;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.ScaleControlOptions.txt)
    property ScaleControlOptions;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.Scrollwheel.txt)
    property Scrollwheel;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.StreetView.txt)
    property StreetView;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.StreetViewControl.txt)
    property StreetViewControl;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.StreetViewControlOptions.txt)
    property StreetViewControlOptions;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.Styles.txt)
    property Styles: TGMMapTypeStyles read FStyles write FStyles;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.Tilt.txt)
    property Tilt;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.Zoom.txt)
    property Zoom;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.ZoomControl.txt)
    property ZoomControl;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMapOptions.ZoomControlOptions.txt)
    property ZoomControlOptions;
  end;

  { -------------------------------------------------------------------------- }
  // @include(..\..\Help\docs\GMMap.VCL.TGMMap.txt)
  TGMMap = class(TGMCustomGMMap)
  private
    FMapOptions: TGMMapOptions;
    FTimer: TTimer;    // TTimer for map events control
    FDocLoaded: Boolean;  // Indicates if the map.html page is fully loaded.
    CurDispatch: IDispatch;  // variable for control of load web page
    OldBeforeNavigate2: TWebBrowserBeforeNavigate2;     // old TWebBrowser's event
    OldDocumentComplete: TWebBrowserDocumentComplete;   // old TWebBrowser's event
    OldNavigateComplete2: TWebBrowserNavigateComplete2; // old TWebBrowser's event

    // ES: eventos del TWebBrowser para el control de la carga de la página
    // EN: events of TWebBrowser to control the load page
    {$IFDEF DELPHIXE2}
    procedure BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    {$ELSE}
    procedure BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    {$ENDIF}

    function GetWebBrowser: TWebBrowser;
    procedure SetWebBrowser(const Value: TWebBrowser); (*1 *)
  protected
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.GetTempPath.txt)
    function GetTempPath: string; override;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.SetIntervalTimer.txt)
    procedure SetIntervalTimer(Interval: Integer); override;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.LoadMap.txt)
    procedure LoadMap; override;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.LoadBlankPage.txt)
    procedure LoadBlankPage; override;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(NameFunct, Params: string); override; (*1 *)
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.DoMap.txt)
    procedure DoMap;
  public
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.Create.txt)
    constructor Create(AOwner: TComponent); override;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.Destroy.txt)
    destructor Destroy; override;

    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.GetAPIUrl.txt)
    function GetAPIUrl: string; override;
  published
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.MapOptions.txt)
    property MapOptions: TGMMapOptions read FMapOptions write FMapOptions;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.Active.txt)
    property Active;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.GoogleAPIVer.txt)
    property GoogleAPIVer;
    // @include(..\..\Help\docs\GMClasses.TGMComponent.Language.txt)
    property Language;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.AboutGMLib.txt)
    property AboutGMLib;
    // @include(..\..\Help\docs\GMClasses.IGMAPIUrl.APIUrl.txt)
    property APIUrl;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.GoogleAPIKey.txt)
    property GoogleAPIKey;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.IntervalEvents.txt)
    property IntervalEvents;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.APILang.txt)
    property APILang;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.Precision.txt)
    property Precision;
    // @include(..\..\Help\docs\GMMap.VCL.TGMMap.WebBrowser.txt)
    property WebBrowser: TWebBrowser read GetWebBrowser write SetWebBrowser;

    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.OnActiveChange.txt)
    property OnActiveChange;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.OnPrecisionChange.txt)
    property OnPrecisionChange;
    // @include(..\..\Help\docs\GMMap.TGMCustomGMMap.OnPropertyChanges.txt)
    property OnPropertyChanges;
  end;

implementation

uses
  MSHTML,
  {$IFDEF DELPHIXE2}
  System.SysUtils, Winapi.ActiveX, system.DateUtils, Winapi.Windows,
  {$ELSE}
  SysUtils, ActiveX, DateUtils, Windows,
  {$ENDIF}

  GMClasses.VCL;

{ TGMMapOptions }

constructor TGMMapOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FBackgroundColor := clBlack;
  FStyles := TGMMapTypeStyles.Create(Self, TGMMapTypeStyle);
end;

destructor TGMMapOptions.Destroy;
begin
  if Assigned(FStyles) then FreeAndNil(FStyles);

  inherited;
end;

function TGMMapOptions.GetCountStyles: Integer;
begin
  Result := FStyles.Count;
end;

function TGMMapOptions.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(TGMTransformVCL.TColorToStr(FBackgroundColor)),
                         FStyles.PropToString
                         ]);
end;

procedure TGMMapOptions.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor = Value then Exit;

  FBackgroundColor := Value;
  ControlChanges('BackgroundColor');
end;

{ TGMMapTypeStyler }

function TGMMapTypeStyler.PropToString: string;
const
  Str = '%s,%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         TGMTransformVCL.TColorToStr(FColor),
                         TGMTransformVCL.TColorToStr(FHue)
                         ]);
end;

procedure TGMMapTypeStyler.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit;

  FColor := Value;
  ControlChanges('Color');
end;

procedure TGMMapTypeStyler.SetHue(const Value: TColor);
begin
  if FHue = Value then Exit;

  FHue := Value;
  ControlChanges('Hue');
end;

{ TGMMap }

{$IFDEF DELPHIXE2}
procedure TGMMap.BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
{$ELSE}
procedure TGMMap.BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
{$ENDIF}
begin
  if Assigned(OldBeforeNavigate2) then
    OldBeforeNavigate2(ASender, pDisp, URL, Flags, TargetFrameName, PostData, Headers, Cancel);

  CurDispatch := nil;
  FDocLoaded := False;
end;

{$IFDEF DELPHIXE2}
procedure TGMMap.DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
{$ELSE}
procedure TGMMap.DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  var URL: OleVariant);
{$ENDIF}
begin
  if Assigned(OldDocumentComplete) then
    OldDocumentComplete(ASender, pDisp, URL);

  if (pDisp = CurDispatch) then  // if equals, page loaded
  begin
    FDocLoaded := True;
    if Active then DoMap;
    CurDispatch := nil;
  end;
end;

procedure TGMMap.DoMap;
var
  Params: string;
begin
  Params := FMapOptions.PropToString;

  ExecuteJavaScript('DoMap', Params);
end;

procedure TGMMap.ExecuteJavaScript(NameFunct, Params: string);
var
  Doc2: IHTMLDocument2;
  Win2: IHTMLWindow2;
begin
  if not Assigned(FWebBrowser) then
    raise EGMUnassignedObject.Create(['WebBrowser'], Language);  // Unassigned %s object.

  if not Active then
    raise EGMNotActive.Create(Language);  // Map is not active.

  if not (FWebBrowser is TWebBrowser) then
    raise EGMIncorrectBrowser.Create(Language);  // The browser is not of the desired type.

  Doc2 := TWebBrowser(FWebBrowser).Document as IHTMLDocument2;
  Win2 := Doc2.parentWindow;

  try
    Win2.execScript(NameFunct + '(' + Params + ')', 'JavaScript');
  except
    on E: Exception do
      raise EGMJSError.Create([NameFunct, E.Message], Language);
  end;

  //if MapIsNull then
  //  raise Exception.Create(GetTranslateText('El mapa todavía no ha sido creado', Language));
end;

{$IFDEF DELPHIXE2}
procedure TGMMap.NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
{$ELSE}
procedure TGMMap.NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
  var URL: OleVariant);
{$ENDIF}
begin
  if Assigned(OldNavigateComplete2) then
    OldNavigateComplete2(ASender, pDisp, URL);

  if CurDispatch = nil then
    CurDispatch := pDisp;
end;

constructor TGMMap.Create(AOwner: TComponent);
begin
  inherited;

  FMapOptions := TGMMapOptions.Create(Self);

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 200;
  FTimer.OnTimer := OnTimer;
end;

destructor TGMMap.Destroy;
begin
  if Assigned(FMapOptions) then FreeAndNil(FMapOptions);
  if Assigned(FTimer) then FreeAndNil(FTimer);

  inherited;
end;

function TGMMap.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference#Map';
end;

function TGMMap.GetTempPath: string;
var
  Len: Integer;
begin
  SetLastError(ERROR_SUCCESS);

  SetLength(Result, MAX_PATH);
  Len := Winapi.Windows.GetTempPath(MAX_PATH, PChar(Result));
  if Len <> 0 then
  begin
    Len := GetLongPathName(PChar(Result), nil, 0);
    GetLongPathName(PChar(Result), PChar(Result), Len);
    SetLength(Result, Len - 1);
  end
  else
    Result := '';
end;

function TGMMap.GetWebBrowser: TWebBrowser;
begin
  Result := nil;
  if FWebBrowser is TWebBrowser then
    Result := TWebBrowser(FWebBrowser);
end;

procedure TGMMap.LoadBlankPage;
begin
  inherited;

  if not (FWebBrowser is TWebBrowser) then
    raise EGMIncorrectBrowser.Create(Language);  // The browser is not of the desired type.

  TWebBrowser(FWebBrowser).Navigate('about:blank');
end;

procedure TGMMap.LoadMap;
begin
  inherited;

  if not Assigned(FWebBrowser) then
    raise EGMUnassignedObject.Create(['WebBrowser'], Language); // Object %s unassigned.
  if not (FWebBrowser is TWebBrowser) then
    raise EGMIncorrectBrowser.Create(Language);  // The browser is not of the desired type.

  TWebBrowser(FWebBrowser).Navigate(GetBaseHTMLCode);
end;

procedure TGMMap.SetIntervalTimer(Interval: Integer);
begin
  inherited;

  if Assigned(FTimer) then FTimer.Interval := Interval;
end;

procedure TGMMap.SetWebBrowser(const Value: TWebBrowser);
begin
  if FWebBrowser = Value then Exit;

  if (Value <> FWebBrowser) and Assigned(FWebBrowser) then
  begin
    TWebBrowser(FWebBrowser).OnBeforeNavigate2 := OldBeforeNavigate2;
    TWebBrowser(FWebBrowser).OnDocumentComplete := OldDocumentComplete;
    TWebBrowser(FWebBrowser).OnNavigateComplete2 := OldNavigateComplete2;
  end;

  FWebBrowser := Value;
{
  TWebControl(FWC).SetBrowser(TWebBrowser(FWebBrowser));
}
  if csDesigning in ComponentState then Exit;

  if Assigned(FWebBrowser) then
  begin
    OldBeforeNavigate2 := TWebBrowser(FWebBrowser).OnBeforeNavigate2;
    OldDocumentComplete := TWebBrowser(FWebBrowser).OnDocumentComplete;
    OldNavigateComplete2 := TWebBrowser(FWebBrowser).OnNavigateComplete2;

    TWebBrowser(FWebBrowser).OnBeforeNavigate2 := BeforeNavigate2;
    TWebBrowser(FWebBrowser).OnDocumentComplete := DocumentComplete;
    TWebBrowser(FWebBrowser).OnNavigateComplete2 := NavigateComplete2;

    if Active then
      LoadMap
    else
      LoadBlankPage;
  end;
end;

{ TGMMapTypeStyles }

function TGMMapTypeStyles.Add: TGMMapTypeStyle;
begin
  Result := TGMMapTypeStyle(inherited Add);
end;

function TGMMapTypeStyles.GetItems(I: Integer): TGMMapTypeStyle;
begin
  Result := TGMMapTypeStyle(inherited Items[I]);
end;

function TGMMapTypeStyles.Insert(Index: Integer): TGMMapTypeStyle;
begin
  Result := TGMMapTypeStyle(inherited Insert(Index));
end;

function TGMMapTypeStyles.PropToString: string;
var
  i: Integer;
begin
  Result := inherited PropToString;

  for i := 0 to Count - 1 do
  begin
    if Result <> '' then Result := Result + '¬';

    Result := Result + Items[i].PropToString;
  end;
  Result := QuotedStr(Result);
end;

procedure TGMMapTypeStyles.SetItems(I: Integer; const Value: TGMMapTypeStyle);
begin
  inherited SetItem(I, Value);
end;

{ TGMMapTypeStylers }

function TGMMapTypeStylers.Add: TGMMapTypeStyler;
begin
  Result := TGMMapTypeStyler(inherited Add);
end;

function TGMMapTypeStylers.GetItems(I: Integer): TGMMapTypeStyler;
begin
  Result := TGMMapTypeStyler(inherited Items[I]);
end;

function TGMMapTypeStylers.Insert(Index: Integer): TGMMapTypeStyler;
begin
  Result := TGMMapTypeStyler(inherited Insert(Index));
end;

function TGMMapTypeStylers.PropToString: string;
var
  i: Integer;
begin
  Result := inherited PropToString;

  for i := 0 to Count - 1 do
  begin
    if Result <> '' then Result := Result + '&';

    Result := Result + Items[i].PropToString;
  end;
end;

procedure TGMMapTypeStylers.SetItems(I: Integer; const Value: TGMMapTypeStyler);
begin
  inherited SetItem(I, Value);
end;

{ TGMMapTypeStyle }

constructor TGMMapTypeStyle.Create(Collection: TCollection);
begin
  inherited;

  FStylers := TGMMapTypeStylers.Create(Self, TGMMapTypeStyler);
end;

destructor TGMMapTypeStyle.Destroy;
begin
  if Assigned(FStylers) then FreeAndNil(FStylers);

  inherited;
end;

function TGMMapTypeStyle.PropToString: string;
const
  Str = '%s';
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + '&';
  Result := Result +
            Format(Str, [
                         FStylers.PropToString
                         ]);
end;

end.
