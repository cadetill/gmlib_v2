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
  Vcl.Edge, Winapi.WebView2,
//  {$ENDIF}

  GMLib.Map;

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
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetEnableTimer.txt)
    procedure SetEnableTimer(State: Boolean); override;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetIntervalTimer.txt)
    procedure SetIntervalTimer(Interval: Integer); override;

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
    FFieldValue: string;
    FFieldName: string;
    FReadedElem: Boolean;
    FConsoleMessageEvent: TOnConsoleMessage;

    function GetWebBrowser: TChromium;
    procedure SetWebBrowser(const Value: TChromium);
    procedure ConsoleMessageEvent(Sender: TObject;
      const browser: ICefBrowser; level: Cardinal; const message,
      source: ustring; line: Integer; out Result: Boolean);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(FunctName, Params: string); override;
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.GetValueFromHTML.txt)
    function GetValueFromHTML(FieldNameId: string): string; override;
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

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnActiveChange.txt)
    property OnActiveChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnPrecisionChange.txt)
    property OnPrecisionChange;
    // @include(..\Help\docs\GMLib.Classes.TPropertyChanges.txt)
    property OnPropertyChanges;
  end;
//  {$ENDIF}

//  {$IFDEF DELPHIALEXANDRIA}
  // @include(..\Help\docs\GMLib.Map.TGMCustomMap.txt)
  TGMMapEdge = class(TGMMap)
  private
    FFieldValue: string;
    FFieldName: string;
    FReadedElem: Boolean;
    FWebMessageReceivedEvent: TWebMessageReceivedEvent;

    function GetWebBrowser: TEdgeBrowser;
    procedure SetWebBrowser(const Value: TEdgeBrowser);
    procedure WebMessageReceived(Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
  protected
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(FunctName, Params: string); override;
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.GetValueFromHTML.txt)
    function GetValueFromHTML(FieldNameId: string): string; override;
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

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnActiveChange.txt)
    property OnActiveChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnPrecisionChange.txt)
    property OnPrecisionChange;
    // @include(..\Help\docs\GMLib.Classes.TPropertyChanges.txt)
    property OnPropertyChanges;
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
begin
  Result := inherited PropToString;
  if Result <> '' then Result := Result + ',';
  Result := Result +
            Format(Str, [
                         QuotedStr(TGMTransform.TColorToStr(FBackgroundColor))
                        ]);
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
  if Assigned(FMapOptions) then FMapOptions.Free;
  if Assigned(FTimer) then FTimer.Free;

  inherited;
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

//{$IFDEF CEF4Delphi}
{ TGMMapChrm }

procedure TGMMapChrm.ConsoleMessageEvent(Sender: TObject;
  const browser: ICefBrowser; level: Cardinal; const message, source: ustring;
  line: Integer; out Result: Boolean);
begin
  if (Length(message) = 0) or (Pos('|', message) = 0) then
    Exit;

  FFieldName := Copy(message, 1, Pos('|', message));
  FFieldValue := Copy(message, Pos('|', message) + 1, Length(message));
  FReadedElem := True;

  if Assigned(FConsoleMessageEvent) then
    FConsoleMessageEvent(Sender, browser, level, message, source, line, Result);
end;

constructor TGMMapChrm.Create(AOwner: TComponent);
begin
  inherited;

  FFieldValue := '';
  FFieldName := '';
  FReadedElem := False;
end;

procedure TGMMapChrm.ExecuteJavaScript(FunctName, Params: string);
begin
  inherited;

  TChromium(FBrowser).Browser.MainFrame.ExecuteJavaScript(
    FunctName + '(' + Params + ')',
    TChromium(FBrowser).Browser.MainFrame.GetURL,
    0 );
end;

function TGMMapChrm.GetValueFromHTML(FieldNameId: string): string;
var
  TempJSCode: string;
  TmpNow: TDateTime;
begin
  FReadedElem := False;

  TempJSCode  := 'console.log("' + FieldNameId + '|" + ' + 'document.getElementById("' + FieldNameId + '").value' + ');';
  TChromium(FBrowser).ExecuteJavaScript(TempJSCode, 'about:blank');
  TmpNow := Now;
  repeat
    Sleep(5);
    TGenFunc.ProcessMessages;
  until FReadedElem or (IncSecond(TmpNow, 2) < Now);

  if not FReadedElem then
    raise EGMTimeOut.Create(Language);                                          // A timeout occurred.

  Result := FFieldValue;
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

  TChromium(FBrowser).LoadURL('about:blank');
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
    TChromium(FBrowser).OnConsoleMessage := FConsoleMessageEvent;
  end;

  FBrowser := Value;

  if csDesigning in ComponentState then Exit;

  if Assigned(FBrowser) then
  begin
    FConsoleMessageEvent := TChromium(FBrowser).OnConsoleMessage;

    TChromium(FBrowser).OnConsoleMessage := ConsoleMessageEvent;

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
end;

procedure TGMMapEdge.ExecuteJavaScript(FunctName, Params: string);
begin
  inherited;

  TEdgeBrowser(FBrowser).ExecuteScript(FunctName + '(' + Params + ')');
end;

function TGMMapEdge.GetValueFromHTML(FieldNameId: string): string;
var
  TempJSCode: string;
  TmpNow: TDateTime;
begin
  FReadedElem := False;

  TempJSCode := 'results = document.getElementById("' + FieldNameId + '").value; ' +
                'console.log("' + FieldNameId + '|" + results); ' +
                'if (results.length >= 1) {window.chrome.webview.postMessage("' + FieldNameId + '|" + results);} ' +
                'else {window.chrome.webview.postMessage("");}';
  TEdgeBrowser(FBrowser).ExecuteScript(TempJSCode);
  TmpNow := Now;
  repeat
    Sleep(5);
    TGenFunc.ProcessMessages;
  until FReadedElem or (IncSecond(TmpNow, 2) < Now);

  if not FReadedElem then
    raise EGMTimeOut.Create(Language);                                          // A timeout occurred.

  Result := FFieldValue;
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

procedure TGMMapEdge.SetWebBrowser(const Value: TEdgeBrowser);
begin
  if FBrowser = Value then Exit;

  if Assigned(FBrowser) and not (FBrowser is TEdgeBrowser) then
    raise EGMIncorrectBrowser.Create(Language);                                 // The browser is not of the correct class

  if (Value <> FBrowser) and Assigned(FBrowser) then
  begin
    TEdgeBrowser(FBrowser).OnWebMessageReceived := FWebMessageReceivedEvent;
  end;

  FBrowser := Value;

  if csDesigning in ComponentState then Exit;

  if Assigned(FBrowser) then
  begin
    FWebMessageReceivedEvent := TEdgeBrowser(FBrowser).OnWebMessageReceived;

    TEdgeBrowser(FBrowser).OnWebMessageReceived := WebMessageReceived;

    if Active then
      LoadMap
    else
      LoadBlankPage;
  end;
end;

procedure TGMMapEdge.WebMessageReceived(Sender: TCustomEdgeBrowser;
  Args: TWebMessageReceivedEventArgs);
var
  TmpStr : PWideChar;
  Msg: ICoreWebView2WebMessageReceivedEventArgs;
begin
  Msg := Args as ICoreWebView2WebMessageReceivedEventArgs;
  Msg.TryGetWebMessageAsString(TmpStr);

  if (Length(TmpStr) = 0) or (Pos('|', TmpStr) = 0) then
    Exit;

  FFieldName := Copy(TmpStr, 1, Pos('|', TmpStr));
  FFieldValue := Copy(TmpStr, Pos('|', TmpStr) + 1, Length(TmpStr));
  FReadedElem := True;

  if Assigned(FWebMessageReceivedEvent) then
    FWebMessageReceivedEvent(Sender, Args);
end;

//{$ENDIF}

end.
