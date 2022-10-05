{
  @abstract(@code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 12, 2022)
  @lastmod(August 14, 2022)

  The GMMapVCL contains the implementation of TGMMap class that encapsulate the @code(google.maps.Map) class from Google Maps API and other related classes.
}
unit GMLib.Map.Vcl;

{$I ..\gmlib.inc}

interface

uses
  {$IFDEF DELPHIXE2}
  Vcl.Graphics, System.Classes, Vcl.ExtCtrls,
  {$ELSE}
  Graphics, Classes, ExtCtrls,
  {$ENDIF}

//  {$IFDEF CEF4Delphi}
  uCEFChromium, uCEFChromiumEvents, uCEFInterfaces, uCEFTypes,
//  {$ENDIF}

//  {$IFDEF DELPHIALEXANDRIA}
  Vcl.Edge, Vcl.OleCtrls, Winapi.WebView2,
//  {$ENDIF}

  GMLib.Map, GMLib.LatLng, GMLib.Sets;

type
  // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.txt)
  TGMMapOptions = class(TGMCustomMapOptions)
  private
    FBackgroundColor: TColor;
    procedure SetBackgroundColor(const Value: TColor);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Create.txt)
    constructor Create(AOwner: TPersistent); override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  published
    // @include(..\Help\docs\GMLib.Map.Vcl.TGMMapOptions.BackgroundColor.txt)
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clBlack;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Center.txt)
    property Center;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ClickableIcons.txt)
    property ClickableIcons;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.DisableDoubleClickZoom.txt)
    property DisableDoubleClickZoom;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.DraggableCursor.txt)
    property DraggableCursor;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.DraggingCursor.txt)
    property DraggingCursor;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.FullScreenControl.txt)
    property FullScreenControl;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.FullScreenControlOptions.txt)
    property FullScreenControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.GestureHandling.txt)
    property GestureHandling;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Heading.txt)
    property Heading;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.IsFractionalZoomEnabled.txt)
    property IsFractionalZoomEnabled;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.KeyboardShortcuts.txt)
    property KeyboardShortcuts;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MapTypeControl.txt)
    property MapTypeControl;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MapTypeControlOptions.txt)
    property MapTypeControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MapTypeId.txt)
    property MapTypeId;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MaxZoom.txt)
    property MaxZoom;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.MinZoom.txt)
    property MinZoom;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.NoClear.txt)
    property NoClear;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Restriction.txt)
    property Restriction;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.RotateControl.txt)
    property RotateControl;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.RotateControlOptions.txt)
    property RotateControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ScaleControl.txt)
    property ScaleControl;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ScaleControlOptions.txt)
    property ScaleControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.StreetViewControl.txt)
    property StreetViewControl;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.StreetViewControlOptions.txt)
    property StreetViewControlOptions;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Tilt.txt)
    property Tilt;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.Zoom.txt)
    property Zoom;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ZoomControl.txt)
    property ZoomControl;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.ZoomControlOptions.txt)
    property ZoomControlOptions;
  end;

  // @include(..\Help\docs\GMLib.Map.TGMCustomMap.txt)
  TGMMap = class(TGMCustomMap)
  private
    FTimer: TTimer;  // TTimer for map events control
    FMapOptions: TGMMapOptions;
  protected
    // @exclude
    FFieldValue: string;
    // @exclude
    FFieldName: string;
    // @exclude
    FReadedElem: Boolean;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetEnableTimer.txt)
    procedure SetEnableTimer(State: Boolean); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetIntervalTimer.txt)
    procedure SetIntervalTimer(Interval: Integer); override;
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.GetJsonFromHTMLForms.txt)
    function GetJsonFromHTMLForms: string; override;

    // @include(..\Help\docs\GMLib.Classes.IGMToStr.PropToString.txt)
    function PropToString: string; override;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetCenterProperty.txt)
    procedure SetCenterProperty(LatLng: TGMLatLng); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetMapTypeIdProperty.txt)
    procedure SetMapTypeIdProperty(MapTypeId: TGMMapTypeId); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetZoomProperty.txt)
    procedure SetZoomProperty(Zoom: Integer); override;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.txt)
    property MapOptions: TGMMapOptions read FMapOptions write FMapOptions;
  public
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Create.txt)
    constructor Create(AOwner: TComponent); override;
    // @include(..\Help\docs\GMLib.Map.Vcl.TGMMap.Destroy.txt)
    destructor Destroy; override;

    // @include(..\Help\docs\GMLib.Classes.TGMObject.Assign.txt)
    procedure Assign(Source: TPersistent); override;
  end;

//  {$IFDEF CEF4Delphi}
  // @include(..\Help\docs\GMLib.Map.TGMCustomMap.txt)
  TGMMapChrm = class(TGMMap)
  private
    FOldConsoleMessageEvent: TOnConsoleMessage;
    FOldLoadEndEvent: TOnLoadEnd;

    function GetWebBrowser: TChromium;
    procedure SetWebBrowser(const Value: TChromium);
    procedure ConsoleMessageEvent(Sender: TObject;
      const browser: ICefBrowser; level: Cardinal; const message,
      source: ustring; line: Integer; out Result: Boolean);
    procedure LoadEndEvent(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(FunctName, Params: string); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadMap.txt)
    procedure LoadMap; override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadBlankPage.txt)
    procedure LoadBlankPage; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Create.txt)
    constructor Create(AOwner: TComponent); override;
  published
    // @include(..\Help\docs\GMLib.Map.Vcl.TGMMap.Browser.txt)
    property Browser: TChromium read GetWebBrowser write SetWebBrowser;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.txt)
    property MapOptions;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Active.txt)
    property Active;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIVer.txt)
    property APIVer;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIKey.txt)
    property APIKey;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APILang.txt)
    property APILang;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIRegion.txt)
    property APIRegion;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.IntervalEvents.txt)
    property IntervalEvents;
    // @include(..\Help\docs\GMLib.Classes.TGMComponent.Language.txt)
    property Language;
    // @include(..\Help\docs\GMLib.Classes.TGMComponent.AboutGMLib.txt)
    property AboutGMLib;

    // @include(..\Help\docs\GMLib.Layers.TGMCustomMap.TrafficLayer.txt)
    property TrafficLayer;
    // @include(..\Help\docs\GMLib.Layers.TGMTransitLayer.txt)
    property TransitLayer;
    // @include(..\Help\docs\GMLib.Layers.TGMByciclingLayer.txt)
    property ByciclingLayer;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayer.txt)
    property KmlLayer;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnActiveChange.txt)
    property OnActiveChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnPrecisionChange.txt)
    property OnPrecisionChange;
    // @include(..\Help\docs\GMLib.Events.TGMPropertyChangesEvent.txt)
    property OnPropertyChanges;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnBoundsChanged.txt)
    property OnBoundsChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnCenterChanged.txt)
    property OnCenterChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnClick.txt)
    property OnClick;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDblClick.txt)
    property OnDblClick;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseMove.txt)
    property OnMouseMove;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseOut.txt)
    property OnMouseOut;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseOver.txt)
    property OnMouseOver;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnContextmenu.txt)
    property OnContextmenu;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDrag.txt)
    property OnDrag;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDragEnd.txt)
    property OnDragEnd;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDragStart.txt)
    property OnDragStart;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMapTypeIdChanged.txt)
    property OnMapTypeIdChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnZoomChanged.txt)
    property OnZoomChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.AfterPageLoaded.txt)
    property AfterPageLoaded;
  end;
//  {$ENDIF}

//  {$IFDEF DELPHIALEXANDRIA}
  // @include(..\Help\docs\GMLib.Map.TGMCustomMap.txt)
  TGMMapEdge = class(TGMMap)
  private
    FOldWebMessageReceivedEvent: TWebMessageReceivedEvent;
    FOldNavigationCompletedEvent: TNavigationCompletedEvent;

    function GetWebBrowser: TEdgeBrowser;
    procedure SetWebBrowser(const Value: TEdgeBrowser);
    procedure WebMessageReceivedEvent(Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
    procedure NavigationCompletedEvent(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: TOleEnum);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(FunctName, Params: string); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadMap.txt)
    procedure LoadMap; override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadBlankPage.txt)
    procedure LoadBlankPage; override;
  public
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Create.txt)
    constructor Create(AOwner: TComponent); override;
  published
    // @include(..\Help\docs\GMLib.Map.Vcl.TGMMap.Browser.txt)
    property Browser: TEdgeBrowser read GetWebBrowser write SetWebBrowser;

    // @include(..\Help\docs\GMLib.Classes.IGMAPIUrl.APIUrl.txt)
    property APIUrl;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMapOptions.txt)
    property MapOptions;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Active.txt)
    property Active;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIVer.txt)
    property APIVer;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIKey.txt)
    property APIKey;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APILang.txt)
    property APILang;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIRegion.txt)
    property APIRegion;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.IntervalEvents.txt)
    property IntervalEvents;
    // @include(..\Help\docs\GMLib.Classes.TGMComponent.Language.txt)
    property Language;
    // @include(..\Help\docs\GMLib.Classes.TGMComponent.AboutGMLib.txt)
    property AboutGMLib;

    // @include(..\Help\docs\GMLib.Layers.TGMCustomMap.TrafficLayer.txt)
    property TrafficLayer;
    // @include(..\Help\docs\GMLib.Layers.TGMTransitLayer.txt)
    property TransitLayer;
    // @include(..\Help\docs\GMLib.Layers.TGMByciclingLayer.txt)
    property ByciclingLayer;
    // @include(..\Help\docs\GMLib.Layers.TGMKmlLayer.txt)
    property KmlLayer;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnActiveChange.txt)
    property OnActiveChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnPrecisionChange.txt)
    property OnPrecisionChange;
    // @include(..\Help\docs\GMLib.Events.TGMPropertyChangesEvent.txt)
    property OnPropertyChanges;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnBoundsChanged.txt)
    property OnBoundsChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnCenterChanged.txt)
    property OnCenterChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnClick.txt)
    property OnClick;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDblClick.txt)
    property OnDblClick;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseMove.txt)
    property OnMouseMove;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseOut.txt)
    property OnMouseOut;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMouseOver.txt)
    property OnMouseOver;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnContextmenu.txt)
    property OnContextmenu;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDrag.txt)
    property OnDrag;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDragEnd.txt)
    property OnDragEnd;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnDragStart.txt)
    property OnDragStart;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnMapTypeIdChanged.txt)
    property OnMapTypeIdChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnZoomChanged.txt)
    property OnZoomChanged;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.AfterPageLoaded.txt)
    property AfterPageLoaded;
  end;
//  {$ENDIF}

implementation

uses
  {$IFDEF DELPHIXE2}
  System.SysUtils, System.DateUtils,
  {$ELSE}
  SysUtils, DataUtils,
  {$ENDIF}

  GMLib.Transform.Vcl, GMLib.Exceptions, GMLib.Functions.Vcl;

{ TGMMapOptions }

procedure TGMMapOptions.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMMapOptions then
  begin
    BackgroundColor := TGMMapOptions(Source).BackgroundColor;
  end;
end;

constructor TGMMapOptions.Create(AOwner: TPersistent);
begin
  inherited;

  FBackgroundColor := clBlack;
end;

function TGMMapOptions.PropToString: string;
const
  Str = '%s';
var
  TmpStr: string;
begin
  TmpStr := inherited PropToString;

  Result := Format(Str, [
                         QuotedStr(TGMTransform.TColorToStr(FBackgroundColor))
                        ]);
  Result := Result + ',' + TmpStr;
end;

procedure TGMMapOptions.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor = Value then Exit;

  FBackgroundColor := Value;
  ControlChanges('BackgroundColor');
end;

{ TGMMap }

procedure TGMMap.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TGMMap then
  begin
    MapOptions.Assign(TGMMap(Source).MapOptions);
  end;
end;

procedure TGMMap.SetCenterProperty(LatLng: TGMLatLng);
begin
  inherited;

  FMapOptions.Center.Assign(LatLng);
end;

constructor TGMMap.Create(AOwner: TComponent);
begin
  inherited;

  FMapOptions := TGMMapOptions.Create(Self);

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := IntervalEvents;
  FTimer.OnTimer := OnTimer;
end;

destructor TGMMap.Destroy;
begin
  if Assigned(FMapOptions) then FMapOptions.Free;
  if Assigned(FTimer) then FTimer.Free;

  inherited;
end;

function TGMMap.GetJsonFromHTMLForms: string;
var
  TmpNow: TDateTime;
begin
  if not Active then
    Exit;

  FReadedElem := False;

  ExecuteJavaScript('getFormToJson', '');

  TmpNow := Now;
  repeat
    Sleep(1);
    TGenFunc.ProcessMessages;
  until FReadedElem or (IncSecond(TmpNow, 2) < Now);

  if not FReadedElem then
    raise EGMTimeOut.Create(Language);                                          // A timeout occurred.

  Result := FFieldValue;
end;

function TGMMap.PropToString: string;
const
  StrParams = '%s';
begin
  Result := inherited;

  if Result <> '' then
    Result := Result + ',';

  Result := Result + Format(StrParams, [
                                        MapOptions.PropToString
                                       ]);
end;

procedure TGMMap.SetEnableTimer(State: Boolean);
begin
  inherited;

  FTimer.Enabled := State;
end;

procedure TGMMap.SetIntervalTimer(Interval: Integer);
begin
  inherited;

  FTimer.Interval := Interval;
end;

procedure TGMMap.SetMapTypeIdProperty(MapTypeId: TGMMapTypeId);
begin
  inherited;

  FMapOptions.MapTypeId := MapTypeId;
end;

procedure TGMMap.SetZoomProperty(Zoom: Integer);
begin
  inherited;

  FMapOptions.Zoom := Zoom;
end;

//{$IFDEF CEF4Delphi}
{ TGMMapChrm }

procedure TGMMapChrm.ConsoleMessageEvent(Sender: TObject;
  const browser: ICefBrowser; level: Cardinal; const message, source: ustring;
  line: Integer; out Result: Boolean);
begin
  if (Length(message) = 0) or (Pos('{', message) = 0) then
    Exit;

  //FFieldName := Copy(message, 1, Pos('|', message));
  FFieldValue := message; //Copy(message, Pos('|', message) + 1, Length(message));
  FReadedElem := True;

  if Assigned(FOldConsoleMessageEvent) then
    FOldConsoleMessageEvent(Sender, browser, level, message, source, line, Result);
end;

constructor TGMMapChrm.Create(AOwner: TComponent);
begin
  inherited;

  FFieldValue := '';
  FFieldName := '';
  FReadedElem := False;
  FOldConsoleMessageEvent := nil;
  FOldLoadEndEvent := nil;
end;

procedure TGMMapChrm.ExecuteJavaScript(FunctName, Params: string);
begin
  inherited;

  TChromium(FBrowser).Browser.MainFrame.ExecuteJavaScript(
    FunctName + '(' + Params + ')',
    TChromium(FBrowser).Browser.MainFrame.GetURL,
    0 );
end;

function TGMMapChrm.GetWebBrowser: TChromium;
begin
  Result := nil;
  if Assigned(FBrowser) and (FBrowser is TChromium) then
    Result := TChromium(FBrowser);
end;

procedure TGMMapChrm.LoadBlankPage;
begin
  inherited;

  if not Assigned(FBrowser) then
    raise EGMUnassignedObject.Create(['Browser'], Language);                    // Object %s unassigned.
  if not (FBrowser is TChromium) then
    raise EGMIncorrectBrowser.Create(Language);                                 // The browser is not of the correct class.

  FDocLoaded := False;
  TChromium(FBrowser).LoadURL('about:blank');
end;

procedure TGMMapChrm.LoadEndEvent(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if not FDocLoaded and browser.HasDocument then
    DoOpenMap;

  FDocLoaded := True;
  if not browser.HasDocument then
    FDocLoaded := False;

  if Active and Assigned(AfterPageLoaded) then
  begin
    if FDocLoaded then
      AfterPageLoaded(Self, False)
    else
      AfterPageLoaded(Self, True);
  end;

  if Assigned(FOldLoadEndEvent) then
    FOldLoadEndEvent(Sender, browser, frame, httpStatusCode);
end;

procedure TGMMapChrm.LoadMap;
begin
  inherited;

  if not Assigned(FBrowser) then
    raise EGMUnassignedObject.Create(['Browser'], Language);                    // Object %s unassigned.
  if not (FBrowser is TChromium) then
    raise EGMIncorrectBrowser.Create(Language);                                 // The browser is not of the correct class.

  TChromium(FBrowser).LoadURL(GetHTMLCode);
end;

procedure TGMMapChrm.SetWebBrowser(const Value: TChromium);
begin
  if FBrowser = Value then Exit;

  if Assigned(FBrowser) and not (FBrowser is TChromium) then
    raise EGMIncorrectBrowser.Create(Language);                                 // The browser is not of the correct class

  if (Value <> FBrowser) and Assigned(FBrowser) then
  begin
    TChromium(FBrowser).OnConsoleMessage := FOldConsoleMessageEvent;
    TChromium(FBrowser).OnLoadEnd := FOldLoadEndEvent;
  end;

  FBrowser := Value;

  if csDesigning in ComponentState then Exit;

  if Assigned(FBrowser) then
  begin
    FOldConsoleMessageEvent := TChromium(FBrowser).OnConsoleMessage;
    FOldLoadEndEvent := TChromium(FBrowser).OnLoadEnd;

    TChromium(FBrowser).OnConsoleMessage := ConsoleMessageEvent;
    TChromium(FBrowser).OnLoadEnd := LoadEndEvent;

    if Active then
      LoadMap
    else
      LoadBlankPage;
  end;
end;
//{$ENDIF}

//{$IFDEF DELPHIALEXANDRIA}
{ TGMMapEdge }

constructor TGMMapEdge.Create(AOwner: TComponent);
begin
  inherited;

  FFieldValue := '';
  FFieldName := '';
  FReadedElem := False;
  FOldWebMessageReceivedEvent := nil;
  FOldNavigationCompletedEvent := nil;
end;

procedure TGMMapEdge.ExecuteJavaScript(FunctName, Params: string);
begin
  inherited;

  TEdgeBrowser(FBrowser).ExecuteScript(FunctName + '(' + Params + ')');
end;

function TGMMapEdge.GetWebBrowser: TEdgeBrowser;
begin
  Result := nil;
  if Assigned(FBrowser) and (FBrowser is TEdgeBrowser) then
    Result := TEdgeBrowser(FBrowser);
end;

procedure TGMMapEdge.LoadBlankPage;
begin
  inherited;

  if not Assigned(FBrowser) then
    raise EGMUnassignedObject.Create(['Browser'], Language);                    // Object %s unassigned.
  if not (FBrowser is TEdgeBrowser) then
    raise EGMIncorrectBrowser.Create(Language);                                 // The browser is not of the correct class.

  FDocLoaded := False;
  TEdgeBrowser(FBrowser).Navigate('about:blank');
end;

procedure TGMMapEdge.LoadMap;
begin
  inherited;

  if not Assigned(FBrowser) then
    raise EGMUnassignedObject.Create(['Browser'], Language);                    // Object %s unassigned.
  if not (FBrowser is TEdgeBrowser) then
    raise EGMIncorrectBrowser.Create(Language);                                 // The browser is not of the correct class.

  TEdgeBrowser(FBrowser).Navigate(GetHTMLCode);
end;

procedure TGMMapEdge.NavigationCompletedEvent(Sender: TCustomEdgeBrowser;
  IsSuccess: Boolean; WebErrorStatus: TOleEnum);
begin
  if not FDocLoaded and (TEdgeBrowser(FBrowser).LocationURL <> '') then
    DoOpenMap;

  FDocLoaded := True;
  if TEdgeBrowser(FBrowser).LocationURL = '' then
    FDocLoaded := False;

  if Active and Assigned(AfterPageLoaded) then
  begin
    if FDocLoaded then
      AfterPageLoaded(Self, False)
    else
      AfterPageLoaded(Self, True);
  end;

  if Assigned(FOldNavigationCompletedEvent) then
    FOldNavigationCompletedEvent(Sender, IsSuccess, WebErrorStatus);
end;

procedure TGMMapEdge.SetWebBrowser(const Value: TEdgeBrowser);
begin
  if FBrowser = Value then Exit;

  if Assigned(FBrowser) and not (FBrowser is TEdgeBrowser) then
    raise EGMIncorrectBrowser.Create(Language);                                 // The browser is not of the correct class

  if (Value <> FBrowser) and Assigned(FBrowser) then
  begin
    TEdgeBrowser(FBrowser).OnWebMessageReceived := FOldWebMessageReceivedEvent;
    TEdgeBrowser(FBrowser).OnNavigationCompleted := FOldNavigationCompletedEvent;
  end;

  FBrowser := Value;

  if csDesigning in ComponentState then Exit;

  if Assigned(FBrowser) then
  begin
    FOldWebMessageReceivedEvent := TEdgeBrowser(FBrowser).OnWebMessageReceived;
    FOldNavigationCompletedEvent := TEdgeBrowser(FBrowser).OnNavigationCompleted;

    TEdgeBrowser(FBrowser).OnWebMessageReceived := WebMessageReceivedEvent;
    TEdgeBrowser(FBrowser).OnNavigationCompleted := NavigationCompletedEvent;

    if Active then
      LoadMap
    else
      LoadBlankPage;
  end;
end;

procedure TGMMapEdge.WebMessageReceivedEvent(Sender: TCustomEdgeBrowser;
  Args: TWebMessageReceivedEventArgs);
var
  TmpStr : PWideChar;
  Msg: ICoreWebView2WebMessageReceivedEventArgs;
begin
  Msg := Args as ICoreWebView2WebMessageReceivedEventArgs;
  Msg.TryGetWebMessageAsString(TmpStr);

  if (Length(TmpStr) = 0) or (Pos('{', TmpStr) = 0) then
    Exit;

  //FFieldName := Copy(TmpStr, 1, Pos('|', TmpStr));
  FFieldValue := TmpStr; // Copy(TmpStr, Pos('|', TmpStr) + 1, Length(TmpStr));
  FReadedElem := True;

  if Assigned(FOldWebMessageReceivedEvent) then
    FOldWebMessageReceivedEvent(Sender, Args);
end;

//{$ENDIF}

end.
