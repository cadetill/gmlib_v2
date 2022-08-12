{
  @abstract(@code(google.maps.Map) class from Google Maps API.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)
  @created(August 12, 2022)
  @lastmod(August 12, 2022)

  The GMLib.Map contains the implementation of TGMCustomMap class that encapsulate the @code(google.maps.Map) class from Google Maps API and others related classes.
}
unit GMLib.Map;

{$I ..\gmlib.inc}
//{$R ..\Resources\gmmapres.RES}

interface

uses
  {$IFDEF DELPHIXE2}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}

  GMLib.Classes, GMLib.Sets;

type
  // @include(..\Help\docs\GMLib.Map.TGMCustomMap.txt)
  TGMCustomMap = class(TGMComponent, IGMExecJS, IGMControlChanges)
  private
    FIntervalEvents: Integer;
    FAPILang: TGMAPILang;
    FPrecision: Integer;
    FAPIKey: string;
    FAPIVer: TGMAPIVer;
    FActive: Boolean;
    FAPIRegion: TGMAPIRegion;
    FOnPrecisionChange: TNotifyEvent;
    FOnPropertyChanges: TPropertyChanges;
    FOnActiveChange: TNotifyEvent;
    FOnIntervalEventsChange: TNotifyEvent;
    procedure SetActive(const Value: Boolean);
    procedure SetAPILang(const Value: TGMAPILang);
    procedure SetAPIKey(const Value: string);
    procedure SetAPIVer(const Value: TGMAPIVer);
    procedure SetAPIRegion(const Value: TGMAPIRegion);
    procedure SetIntervalEvents(const Value: Integer);
    procedure SetPrecision(const Value: Integer);
  protected
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.FBrowser.txt)
    FBrowser: TComponent;

    // @include(..\Help\docs\GMLib.Classes.IGMControlChanges.PropertyChanged.txt)
    procedure PropertyChanged(Prop: TPersistent; PropName: string);

    // @exclude
    function GetAPIUrl: string; override;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadMap.txt)
    procedure LoadMap; virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.LoadBlankPage.txt)
    procedure LoadBlankPage; virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetEnableTimer.txt)
    procedure SetEnableTimer(State: Boolean); virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.SetIntervalTimer.txt)
    procedure SetIntervalTimer(Interval: Integer); virtual; abstract;
    // @include(..\Help\docs\GMLib.Classes.IGMExecJS.ExecuteJavaScript.txt)
    procedure ExecuteJavaScript(FunctName, Params: string); virtual; abstract;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.GetHTMLCode.txt)
    function GetHTMLCode: string;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Active.txt)
    property Active: Boolean read FActive write SetActive default False;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIVer.txt)
    property APIVer: TGMAPIVer read FAPIVer write SetAPIVer default avWeekly;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIKey.txt)
    property APIKey: string read FAPIKey write SetAPIKey;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APILang.txt)
    property APILang: TGMAPILang read FAPILang write SetAPILang default lUndefined;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.APIRegion.txt)
    property APIRegion: TGMAPIRegion read FAPIRegion write SetAPIRegion default rUndefined;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.IntervalEvents.txt)
    property IntervalEvents: Integer read FIntervalEvents write SetIntervalEvents default 200;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.Precision.txt)
    property Precision: Integer read FPrecision write SetPrecision default 0;

    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnActiveChange.txt)
    property OnActiveChange: TNotifyEvent read FOnActiveChange write FOnActiveChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnIntervalEventsChange.txt)
    property OnIntervalEventsChange: TNotifyEvent read FOnIntervalEventsChange write FOnIntervalEventsChange;
    // @include(..\Help\docs\GMLib.Map.TGMCustomMap.OnPrecisionChange.txt)
    property OnPrecisionChange: TNotifyEvent read FOnPrecisionChange write FOnPrecisionChange;
    // @include(..\Help\docs\GMLib.Classes.TPropertyChanges.txt)
    property OnPropertyChanges: TPropertyChanges read FOnPropertyChanges write FOnPropertyChanges;
  end;

implementation

uses
  {$IFDEF DELPHI2010}
  System.IOUtils,
  {$ENDIF}
  {$IFDEF DELPHIXE2}
  System.Types, System.SysUtils,
  {$ELSE}
  Windows, SysUtils,
  {$ENDIF}

  GMLib.Exceptions, GMLib.Constants, GMLib.Transform;

{ TGMCustomMap }

function TGMCustomMap.GetAPIUrl: string;
begin
  Result := 'https://developers.google.com/maps/documentation/javascript/reference/map#Map';
end;

function TGMCustomMap.GetHTMLCode: string;
var
  List: TStringList;
  Stream: TResourceStream;
  StrTmp: string;
begin
  if not Assigned(FBrowser) then
    raise EGMUnassignedObject.Create(['Browser'], Language);                    // Object %s unassigned.

  Result := '';

  List := TStringList.Create;
  try
    try
      Stream := TResourceStream.Create(HInstance, ct_RES_MAPA_CODE, RT_RCDATA);
    except
      raise EGMCanLoadResource.Create(Language);                                // Can't load map resource.
    end;

    List.LoadFromStream(Stream);

    // replaces API_KEY variable
    List.Text := StringReplace(List.Text, ct_API_KEY, FAPIKey, []);

    // replaces API_VER variable
    StrTmp := TGMTransform.APIVerToStr(FAPIVer);
    List.Text := StringReplace(List.Text, ct_API_VER, StrTmp, []);

    // replaces API_REGION variable
    StrTmp := LowerCase(TGMTransform.APIRegionToStr(FAPIRegion));
    List.Text := StringReplace(List.Text, ct_API_REGION, StrTmp, []);

    // replaces API_LAN variable
    StrTmp := LowerCase(TGMTransform.APILangToStr(FAPILang));
    List.Text := StringReplace(List.Text, ct_API_LAN, StrTmp, []);

    {$IFDEF DELPHI2010}
    StrTmp := TPath.GetTempPath + TPath.DirectorySeparatorChar + ct_FILE_NAME;
    {$ELSE}
    StrTmp := IncludeTrailingPathDelimiter(GetTempPath) + ct_FILE_NAME;
    {$ENDIF}
    List.SaveToFile(StrTmp);

    Result := StrTmp;
  finally
    if Assigned(Stream) then Stream.Free;
    if Assigned(List) then List.Free;
  end;
end;

procedure TGMCustomMap.PropertyChanged(Prop: TPersistent; PropName: string);
(*
const
  Str1 = '%s';
  Str2 = '%s,%s';
*)
begin
  if not FActive then Exit;
  if csDesigning in ComponentState then Exit;

(*
  if (Prop is TGMCustomMapOptions) and SameText(PropName, 'Zoom') then
    ExecuteJavaScript('MapChangeProperty', Format(Str2, [
                                                         QuotedStr(PropName),
                                                         IntToStr(TGMCustomMapOptions(Prop).Zoom)
                                                        ]));
  if (Prop is TGMLatLng) then
    ExecuteJavaScript('MapChangeCenter', Format(Str1, [
                                                       TGMLatLng(Prop).PropToString
                                                      ]));
*)

  if Assigned(FOnPropertyChanges) then FOnPropertyChanges(Prop, PropName);
end;

procedure TGMCustomMap.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;

  FActive := Value;

  if csDesigning in ComponentState then Exit;

  if not Assigned(FBrowser) then Exit;

  if FActive then
    LoadMap
  else
    LoadBlankPage;

  SetEnableTimer(FActive);

  if Assigned(FOnActiveChange) then FOnActiveChange(Self);
end;

procedure TGMCustomMap.SetAPILang(const Value: TGMAPILang);
begin
  if FAPILang = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPILang := Value;
end;

procedure TGMCustomMap.SetAPIRegion(const Value: TGMAPIRegion);
begin
  if FAPIRegion = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPIRegion := Value;
end;

procedure TGMCustomMap.SetAPIKey(const Value: string);
begin
  if FAPIKey = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPIKey := Value;
end;

procedure TGMCustomMap.SetAPIVer(const Value: TGMAPIVer);
begin
  if FAPIVer = Value then Exit;

  if FActive and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    raise EGMMapIsActive.Create(Language);                                      // The map is active. To change this property you must to deactivate it first.

  FAPIVer := Value;
end;

procedure TGMCustomMap.SetIntervalEvents(const Value: Integer);
begin
  if FIntervalEvents = Value then Exit;

  FIntervalEvents := Value;
  SetIntervalTimer(FIntervalEvents);

  if csDesigning in ComponentState then Exit;

  if Assigned(FOnIntervalEventsChange) then FOnIntervalEventsChange(Self);
end;

procedure TGMCustomMap.SetPrecision(const Value: Integer);
begin
  if FPrecision = Value then Exit;

  FPrecision := Value;

  if FPrecision < 0 then FPrecision := 0;
  if FPrecision > 17 then FPrecision := 17;

  if csDesigning in ComponentState then Exit;

  if Assigned(FOnPrecisionChange) then FOnPrecisionChange(Self);
end;

end.
