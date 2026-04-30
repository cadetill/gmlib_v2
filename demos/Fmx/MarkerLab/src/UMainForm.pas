unit UMainForm;

interface

uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.Types,
  FMX.WebBrowser,
  uGMLib.Core.Types,
  uGMLib.Fmx.Map,
  uGMLib.InfoWindow,
  uGMLib.Marker;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAddClickMarkersCheck: TCheckBox;
    FAddSampleButton: TButton;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FBrowser: TWebBrowser;
    FCenterLatEdit: TEdit;
    FCenterLatLabel: TLabel;
    FCenterLngEdit: TEdit;
    FCenterLngLabel: TLabel;
    FClearMarkersButton: TButton;
    FControlLayout: TLayout;
    FLogMemo: TMemo;
    FLogLayout: TLayout;
    FMap: TGMLibMap;
    FMapIdEdit: TEdit;
    FMapIdLabel: TLabel;
    FInfoHeaderDisabledCheck: TCheckBox;
    FInfoShouldFocusCheck: TCheckBox;
    FBridgeIntervalEdit: TEdit;
    FBridgeIntervalLabel: TLabel;
    FNextMarkerIndex: Integer;
    FStatusLabel: TLabel;
    FStatusValueLabel: TLabel;
    FMarkersValueLabel: TLabel;
    FMarkersCaptionLabel: TLabel;
    FZoomEdit: TEdit;
    FZoomLabel: TLabel;
    procedure ActivateButtonClick(Sender: TObject);
    procedure AddSampleButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ClearMarkersButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandleInfoWindowClose(Sender: TObject);
    procedure HandleInfoWindowCloseClick(Sender: TObject);
    procedure HandleInfoWindowDomReady(Sender: TObject);
    procedure HandleInfoWindowVisible(Sender: TObject);
    procedure HandleMarkerClick(Sender: TObject);
    procedure HandleMarkerDrag(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleMarkerDragStart(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleMarkerDragEnd(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleMarkerMouseDown(Sender: TObject);
    procedure HandleMarkerMouseEnter(Sender: TObject);
    procedure HandleMarkerMouseLeave(Sender: TObject);
    procedure HandleMarkerMouseUp(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure Log(const AText: string);
    procedure PopulateDefaultMarkers;
    procedure PopulateDefaultInfoWindows;
    procedure ShowMarkerInfoWindow(AMarker: TGMMarkerItem);
    procedure SetInitialView;
    procedure UpdateMarkerCount;
    procedure UpdateStatus(const AText: string);
    procedure AddMarker(const ALatLng: TGMLibLatLng; const ATitle: string);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

procedure TMainForm.ActivateButtonClick(Sender: TObject);
var
  BridgeInterval: Integer;
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
  if TryStrToInt(Trim(FBridgeIntervalEdit.Text), BridgeInterval) then
    FMap.BridgeInterval := BridgeInterval
  else
    FMap.BridgeInterval := 100;
  SetInitialView;

  if not FMap.Active then
  begin
    FMap.Active := True;
    Log('Map activation requested.');
    if FMap.APIKey = '' then
      Log('Loading Google Maps API without API key.')
    else
      Log('Loading Google Maps API with API key.');
    if FMap.Options.MapId = '' then
      Log('Loading markers without Map ID. Advanced markers will not be available.')
    else
      Log('Loading markers with Map ID.');
    UpdateStatus('Loading map...');
  end
  else
    Log('Map is already active.');
end;

procedure TMainForm.AddMarker(const ALatLng: TGMLibLatLng; const ATitle: string);
var
  MarkerItem: TGMMarkerItem;
begin
  FMap.Markers.BeginUpdate;
  try
    MarkerItem := FMap.Markers.Add;
    MarkerItem.Options.Position.Lat := ALatLng.Lat;
    MarkerItem.Options.Position.Lng := ALatLng.Lng;
    MarkerItem.Options.Title := ATitle;
    MarkerItem.Options.Clickable := True;
    MarkerItem.Options.Draggable := True;
    MarkerItem.Options.Visible := True;
    MarkerItem.OnClick := HandleMarkerClick;
    MarkerItem.OnDrag := HandleMarkerDrag;
    MarkerItem.OnDragStart := HandleMarkerDragStart;
    MarkerItem.OnDragEnd := HandleMarkerDragEnd;
    MarkerItem.OnMouseDown := HandleMarkerMouseDown;
    MarkerItem.OnMouseEnter := HandleMarkerMouseEnter;
    MarkerItem.OnMouseLeave := HandleMarkerMouseLeave;
    MarkerItem.OnMouseUp := HandleMarkerMouseUp;
  finally
    FMap.Markers.EndUpdate;
  end;

  Log(Format('Marker added: "%s" at %s, %s', [
    ATitle,
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));

  UpdateMarkerCount;
end;

procedure TMainForm.AddSampleButtonClick(Sender: TObject);
var
  Coordinate: TGMLibLatLng;
  Latitude: Double;
  Longitude: Double;
  MarkerItem: TGMMarkerItem;
  MarkerTitle: string;
begin
  if not TryStrToFloat(Trim(FCenterLatEdit.Text), Latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(FCenterLngEdit.Text), Longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  Coordinate := TGMLibLatLng.Create(Latitude, Longitude);
  try
    Inc(FNextMarkerIndex);
    MarkerTitle := Format('Marker %d', [FNextMarkerIndex]);
    AddMarker(Coordinate, MarkerTitle);
    if FMap.Markers.Count > 0 then
    begin
      MarkerItem := FMap.Markers[FMap.Markers.Count - 1];
      case FNextMarkerIndex mod 4 of
        1:
        begin
          MarkerItem.Options.ContentMode := mcmDefault;
          Log('Sample marker uses default content.');
        end;
        2:
        begin
          MarkerItem.Options.ContentMode := mcmHtml;
          MarkerItem.Options.HtmlOptions.CssClassName := 'gm-marker-price';
          MarkerItem.Options.HtmlOptions.Html :=
            '<div style="padding:8px 10px;border-radius:999px;background:#111827;color:#f9fafb;' +
            'border:2px solid #f59e0b;font:600 13px Segoe UI,sans-serif;box-shadow:0 8px 20px rgba(0,0,0,.22)">$' +
            IntToStr(20 + FNextMarkerIndex) + '</div>';
          Log('Sample marker uses HTML content.');
        end;
        3:
        begin
          MarkerItem.Options.ContentMode := mcmPin;
          MarkerItem.Options.PinOptions.BackgroundCss := '#0f766e';
          MarkerItem.Options.PinOptions.BorderColorCss := '#134e4a';
          MarkerItem.Options.PinOptions.GlyphColorCss := '#ffffff';
          MarkerItem.Options.PinOptions.GlyphText := Copy(MarkerTitle, 1, 1);
          MarkerItem.Options.PinOptions.Scale := 1.2;
          Log('Sample marker uses PinElement content.');
        end;
      else
      begin
        MarkerItem.Options.ContentMode := mcmLabel;
        MarkerItem.Options.LabelOptions.CssClassName := 'gm-marker-badge';
        MarkerItem.Options.LabelOptions.Text := MarkerTitle;
        MarkerItem.Options.LabelOptions.BackgroundCss := '#7c3aed';
        MarkerItem.Options.LabelOptions.BorderColorCss := '#c4b5fd';
        MarkerItem.Options.LabelOptions.TextColorCss := '#faf5ff';
        MarkerItem.Options.LabelOptions.PaddingHorizontal := 14;
        MarkerItem.Options.LabelOptions.PaddingVertical := 8;
        MarkerItem.Options.LabelOptions.CornerRadius := 999;
        MarkerItem.Options.LabelOptions.FontSize := 13;
        MarkerItem.Options.LabelOptions.FontBold := True;
        Log('Sample marker uses Label content.');
      end;
      end;
    end;
  finally
    Coordinate.Free;
  end;
end;

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Marker Lab';
  Width := 1280;
  Height := 860;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 88;
  FControlLayout.Padding.Left := 12;
  FControlLayout.Padding.Top := 10;
  FControlLayout.Padding.Right := 12;
  FControlLayout.Padding.Bottom := 8;

  FAPIKeyLabel := TLabel.Create(Self);
  FAPIKeyLabel.Parent := FControlLayout;
  FAPIKeyLabel.Position.X := 4;
  FAPIKeyLabel.Position.Y := 4;
  FAPIKeyLabel.Text := 'API key';

  FAPIKeyEdit := TEdit.Create(Self);
  FAPIKeyEdit.Parent := FControlLayout;
  FAPIKeyEdit.Position.X := 4;
  FAPIKeyEdit.Position.Y := 28;
  FAPIKeyEdit.Width := 280;

  FMapIdLabel := TLabel.Create(Self);
  FMapIdLabel.Parent := FControlLayout;
  FMapIdLabel.Position.X := 300;
  FMapIdLabel.Position.Y := 4;
  FMapIdLabel.Text := 'Map ID';

  FMapIdEdit := TEdit.Create(Self);
  FMapIdEdit.Parent := FControlLayout;
  FMapIdEdit.Position.X := 300;
  FMapIdEdit.Position.Y := 28;
  FMapIdEdit.Width := 170;

  FBridgeIntervalLabel := TLabel.Create(Self);
  FBridgeIntervalLabel.Parent := FControlLayout;
  FBridgeIntervalLabel.Position.X := 490;
  FBridgeIntervalLabel.Position.Y := 4;
  FBridgeIntervalLabel.Text := 'Bridge interval (ms)';

  FBridgeIntervalEdit := TEdit.Create(Self);
  FBridgeIntervalEdit.Parent := FControlLayout;
  FBridgeIntervalEdit.Position.X := 490;
  FBridgeIntervalEdit.Position.Y := 28;
  FBridgeIntervalEdit.Width := 120;

  FCenterLatLabel := TLabel.Create(Self);
  FCenterLatLabel.Parent := FControlLayout;
  FCenterLatLabel.Position.X := 486;
  FCenterLatLabel.Position.Y := 4;
  FCenterLatLabel.Text := 'Latitude';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := FControlLayout;
  FCenterLatEdit.Position.X := 486;
  FCenterLatEdit.Position.Y := 28;
  FCenterLatEdit.Width := 90;

  FCenterLngLabel := TLabel.Create(Self);
  FCenterLngLabel.Parent := FControlLayout;
  FCenterLngLabel.Position.X := 592;
  FCenterLngLabel.Position.Y := 4;
  FCenterLngLabel.Text := 'Longitude';

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := FControlLayout;
  FCenterLngEdit.Position.X := 592;
  FCenterLngEdit.Position.Y := 28;
  FCenterLngEdit.Width := 90;

  FZoomLabel := TLabel.Create(Self);
  FZoomLabel.Parent := FControlLayout;
  FZoomLabel.Position.X := 698;
  FZoomLabel.Position.Y := 4;
  FZoomLabel.Text := 'Zoom';

  FZoomEdit := TEdit.Create(Self);
  FZoomEdit.Parent := FControlLayout;
  FZoomEdit.Position.X := 698;
  FZoomEdit.Position.Y := 28;
  FZoomEdit.Width := 60;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 778;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 110;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FAddSampleButton := TButton.Create(Self);
  FAddSampleButton.Parent := FControlLayout;
  FAddSampleButton.Position.X := 902;
  FAddSampleButton.Position.Y := 26;
  FAddSampleButton.Width := 130;
  FAddSampleButton.Text := 'Add sample marker';
  FAddSampleButton.OnClick := AddSampleButtonClick;

  FClearMarkersButton := TButton.Create(Self);
  FClearMarkersButton.Parent := FControlLayout;
  FClearMarkersButton.Position.X := 1046;
  FClearMarkersButton.Position.Y := 26;
  FClearMarkersButton.Width := 110;
  FClearMarkersButton.Text := 'Clear markers';
  FClearMarkersButton.OnClick := ClearMarkersButtonClick;

  FAddClickMarkersCheck := TCheckBox.Create(Self);
  FAddClickMarkersCheck.Parent := FControlLayout;
  FAddClickMarkersCheck.Position.X := 1170;
  FAddClickMarkersCheck.Position.Y := 30;
  FAddClickMarkersCheck.Width := 170;
  FAddClickMarkersCheck.Text := 'Add marker on map click';

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlLayout;
  FStatusLabel.Position.X := 4;
  FStatusLabel.Position.Y := 62;
  FStatusLabel.Text := 'Status';

  FStatusValueLabel := TLabel.Create(Self);
  FStatusValueLabel.Parent := FControlLayout;
  FStatusValueLabel.Position.X := 52;
  FStatusValueLabel.Position.Y := 62;
  FStatusValueLabel.Text := 'Ready';

  FMarkersCaptionLabel := TLabel.Create(Self);
  FMarkersCaptionLabel.Parent := FControlLayout;
  FMarkersCaptionLabel.Position.X := 180;
  FMarkersCaptionLabel.Position.Y := 62;
  FMarkersCaptionLabel.Text := 'Markers';

  FMarkersValueLabel := TLabel.Create(Self);
  FMarkersValueLabel.Parent := FControlLayout;
  FMarkersValueLabel.Position.X := 240;
  FMarkersValueLabel.Position.Y := 62;
  FMarkersValueLabel.Text := '0';

  FInfoShouldFocusCheck := TCheckBox.Create(Self);
  FInfoShouldFocusCheck.Parent := FControlLayout;
  FInfoShouldFocusCheck.Position.X := 320;
  FInfoShouldFocusCheck.Position.Y := 58;
  FInfoShouldFocusCheck.Width := 120;
  FInfoShouldFocusCheck.Text := 'Info focus';

  FInfoHeaderDisabledCheck := TCheckBox.Create(Self);
  FInfoHeaderDisabledCheck.Parent := FControlLayout;
  FInfoHeaderDisabledCheck.Position.X := 450;
  FInfoHeaderDisabledCheck.Position.Y := 58;
  FInfoHeaderDisabledCheck.Width := 150;
  FInfoHeaderDisabledCheck.Text := 'Hide info header';

  FLogLayout := TLayout.Create(Self);
  FLogLayout.Parent := Self;
  FLogLayout.Align := TAlignLayout.Bottom;
  FLogLayout.Height := 220;
  FLogLayout.Padding.Left := 12;
  FLogLayout.Padding.Top := 8;
  FLogLayout.Padding.Right := 12;
  FLogLayout.Padding.Bottom := 12;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := FLogLayout;
  FLogMemo.Align := TAlignLayout.Client;
  FLogMemo.ReadOnly := True;
  FLogMemo.WordWrap := False;
  FLogMemo.ShowScrollBars := True;

  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := Self;
  FBrowser.Align := TAlignLayout.Client;
end;

procedure TMainForm.ClearMarkersButtonClick(Sender: TObject);
begin
  FMap.Markers.Clear;
  UpdateMarkerCount;
  Log('All markers cleared.');
end;

procedure TMainForm.ConfigureBrowser;
begin
  {$IFDEF MSWINDOWS}
  FBrowser.WindowsEngine := TWindowsEngine.EdgeOnly;
  {$ENDIF}
end;

constructor TMainForm.CreateNew(AOwner: TComponent; Dummy: NativeInt);
begin
  inherited;
  BuildUi;
  ConfigureBrowser;
  InitializeMap;
  InitializeDefaults;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;

  inherited;
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TGMLibLatLng;
  const APlaceId: string);
begin
  Log(Format('Map click at %s, %s (placeId=%s)', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant),
    IfThen(APlaceId <> '', APlaceId, '<none>')
  ]));

  if FAddClickMarkersCheck.IsChecked then
  begin
    Inc(FNextMarkerIndex);
    AddMarker(ALatLng, Format('Marker %d', [FNextMarkerIndex]));
  end;
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  PopulateDefaultMarkers;
  PopulateDefaultInfoWindows;
  Log('Map ready event received.');
  UpdateStatus('Map ready');
end;

procedure TMainForm.HandleInfoWindowCloseClick(Sender: TObject);
begin
  Log('InfoWindow close click.');
end;

procedure TMainForm.HandleInfoWindowClose(Sender: TObject);
begin
  Log('InfoWindow closed.');
end;

procedure TMainForm.HandleInfoWindowDomReady(Sender: TObject);
begin
  Log('InfoWindow DOM ready.');
end;

procedure TMainForm.HandleInfoWindowVisible(Sender: TObject);
begin
  Log('InfoWindow visible.');
end;

procedure TMainForm.HandleMarkerClick(Sender: TObject);
var
  InfoWindow: TGMInfoWindowItem;
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker click: "%s" at %s, %s', [
    MarkerItem.Options.Title,
    FloatToStr(MarkerItem.Options.Position.Lat, TFormatSettings.Invariant),
    FloatToStr(MarkerItem.Options.Position.Lng, TFormatSettings.Invariant)
  ]));

  ShowMarkerInfoWindow(MarkerItem);

  InfoWindow := FMap.InfoWindows[0];
  Log(Format('InfoWindow opened for marker "%s" (anchor=%s).', [
    MarkerItem.Options.Title,
    string(InfoWindow.AnchorObjectId)
  ]));
end;

procedure TMainForm.HandleMarkerDrag(Sender: TObject; ALatLng: TGMLibLatLng);
var
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker drag: "%s" at %s, %s', [
    MarkerItem.Options.Title,
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMarkerDragStart(Sender: TObject; ALatLng: TGMLibLatLng);
var
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker drag start: "%s" at %s, %s', [
    MarkerItem.Options.Title,
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMarkerDragEnd(Sender: TObject; ALatLng: TGMLibLatLng);
var
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker drag end: "%s" moved to %s, %s', [
    MarkerItem.Options.Title,
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));
end;

procedure TMainForm.HandleMarkerMouseDown(Sender: TObject);
var
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker mouse down: "%s"', [MarkerItem.Options.Title]));
end;

procedure TMainForm.HandleMarkerMouseEnter(Sender: TObject);
var
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker mouse enter: "%s"', [MarkerItem.Options.Title]));
end;

procedure TMainForm.HandleMarkerMouseLeave(Sender: TObject);
var
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker mouse leave: "%s"', [MarkerItem.Options.Title]));
end;

procedure TMainForm.HandleMarkerMouseUp(Sender: TObject);
var
  MarkerItem: TGMMarkerItem;
begin
  if not (Sender is TGMMarkerItem) then
    Exit;

  MarkerItem := TGMMarkerItem(Sender);
  Log(Format('Marker mouse up: "%s"', [MarkerItem.Options.Title]));
end;

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMapIdEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID');
  if FMapIdEdit.Text = '' then
    FMapIdEdit.Text := 'DEMO_MAP_ID';
  FBridgeIntervalEdit.Text := '100';
  FCenterLatEdit.Text := '41.3874';
  FCenterLngEdit.Text := '2.1686';
  FZoomEdit.Text := '12';
  FAddClickMarkersCheck.IsChecked := True;
  FInfoShouldFocusCheck.IsChecked := False;
  FInfoHeaderDisabledCheck.IsChecked := False;
  FNextMarkerIndex := 0;
  UpdateStatus('Ready');
  UpdateMarkerCount;
  Log('Marker lab initialized.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
  FMap.InfoWindows.CloseOthersBeforeOpen := True;
  FMap.OnMapClick := HandleMapClick;
  FMap.OnMapReady := HandleMapReady;
end;

procedure TMainForm.Log(const AText: string);
begin
  while FLogMemo.Lines.Count >= 500 do
    FLogMemo.Lines.Delete(0);

  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainForm.PopulateDefaultMarkers;
var
  DefaultMarkerPosition: TGMLibLatLng;
  HtmlMarker: TGMMarkerItem;
  HtmlMarkerPosition: TGMLibLatLng;
  LabelMarker: TGMMarkerItem;
  LabelMarkerPosition: TGMLibLatLng;
  PinMarker: TGMMarkerItem;
  PinMarkerPosition: TGMLibLatLng;
begin
  if FMap.Markers.Count > 0 then
    Exit;

  DefaultMarkerPosition := TGMLibLatLng.Create(41.3874, 2.1686);
  try
    AddMarker(DefaultMarkerPosition, 'mcmDefault');
  finally
    DefaultMarkerPosition.Free;
  end;

  HtmlMarkerPosition := TGMLibLatLng.Create(41.3892, 2.1701);
  try
    AddMarker(HtmlMarkerPosition, 'mcmHtml');
  finally
    HtmlMarkerPosition.Free;
  end;
  HtmlMarker := FMap.Markers[FMap.Markers.Count - 1];
  HtmlMarker.Options.ContentMode := mcmHtml;
  HtmlMarker.Options.HtmlOptions.CssClassName := 'gm-marker-demo-html';
  HtmlMarker.Options.HtmlOptions.Html :=
    '<div style="padding:8px 12px;border-radius:14px;background:#1d4ed8;color:#eff6ff;' +
    'border:2px solid #93c5fd;font:600 13px Segoe UI,sans-serif;box-shadow:0 10px 24px rgba(30,64,175,.28)">mcmHtml</div>';

  LabelMarkerPosition := TGMLibLatLng.Create(41.3883, 2.1660);
  try
    AddMarker(LabelMarkerPosition, 'mcmLabel');
  finally
    LabelMarkerPosition.Free;
  end;
  LabelMarker := FMap.Markers[FMap.Markers.Count - 1];
  LabelMarker.Options.ContentMode := mcmLabel;
  LabelMarker.Options.LabelOptions.CssClassName := 'gm-marker-demo-label';
  LabelMarker.Options.LabelOptions.Text := 'mcmLabel';
  LabelMarker.Options.LabelOptions.BackgroundCss := '#7c3aed';
  LabelMarker.Options.LabelOptions.BorderColorCss := '#c4b5fd';
  LabelMarker.Options.LabelOptions.TextColorCss := '#faf5ff';
  LabelMarker.Options.LabelOptions.PaddingHorizontal := 14;
  LabelMarker.Options.LabelOptions.PaddingVertical := 8;
  LabelMarker.Options.LabelOptions.CornerRadius := 999;
  LabelMarker.Options.LabelOptions.FontSize := 13;
  LabelMarker.Options.LabelOptions.FontBold := True;

  PinMarkerPosition := TGMLibLatLng.Create(41.3857, 2.1669);
  try
    AddMarker(PinMarkerPosition, 'mcmPin');
  finally
    PinMarkerPosition.Free;
  end;
  PinMarker := FMap.Markers[FMap.Markers.Count - 1];
  PinMarker.Options.ContentMode := mcmPin;
  PinMarker.Options.PinOptions.BackgroundCss := '#0f766e';
  PinMarker.Options.PinOptions.BorderColorCss := '#134e4a';
  PinMarker.Options.PinOptions.GlyphColorCss := '#ffffff';
  PinMarker.Options.PinOptions.GlyphText := 'P';
  PinMarker.Options.PinOptions.Scale := 1.25;

  FNextMarkerIndex := FMap.Markers.Count;
  Log('Default markers added: mcmDefault, mcmHtml, mcmLabel, mcmPin.');
end;

procedure TMainForm.PopulateDefaultInfoWindows;
var
  InfoWindow: TGMInfoWindowItem;
begin
  if FMap.InfoWindows.Count > 0 then
    Exit;

  if FMap.Markers.Count = 0 then
  begin
    Log('Default InfoWindow skipped because no markers are available yet.');
    Exit;
  end;

  InfoWindow := FMap.InfoWindows.Add;
  InfoWindow.Options.Content :=
    '<div style="min-width:220px;padding:6px 4px 2px 4px;font:13px Segoe UI,sans-serif">' +
    '<div style="font-weight:700;color:#0f172a;margin-bottom:6px">InfoWindow slice</div>' +
    '<div style="color:#334155">Colección <b>TGMMap.InfoWindows</b> operativa.</div>' +
    '</div>';
  InfoWindow.Options.HeaderContent := 'Default InfoWindow';
  InfoWindow.Options.HeaderDisabled := FInfoHeaderDisabledCheck.IsChecked;
  InfoWindow.Options.AriaLabel := 'Default marker details';
  InfoWindow.Options.PixelOffset.Height := -8;
  InfoWindow.Options.MaxWidth := 280;
  InfoWindow.OnClose := HandleInfoWindowClose;
  InfoWindow.OnCloseClick := HandleInfoWindowCloseClick;
  InfoWindow.OnDomReady := HandleInfoWindowDomReady;
  InfoWindow.OnVisible := HandleInfoWindowVisible;
  InfoWindow.Open(FMap.Markers[0], FInfoShouldFocusCheck.IsChecked);
  Log('Default InfoWindow added.');
end;

procedure TMainForm.ShowMarkerInfoWindow(AMarker: TGMMarkerItem);
var
  InfoWindow: TGMInfoWindowItem;
begin
  if not Assigned(AMarker) then
    Exit;

  if FMap.InfoWindows.Count = 0 then
    InfoWindow := FMap.InfoWindows.Add
  else
    InfoWindow := FMap.InfoWindows[0];

  InfoWindow.OnClose := HandleInfoWindowClose;
  InfoWindow.OnCloseClick := HandleInfoWindowCloseClick;
  InfoWindow.OnDomReady := HandleInfoWindowDomReady;
  InfoWindow.OnVisible := HandleInfoWindowVisible;
  InfoWindow.Options.AriaLabel := 'Marker details';
  InfoWindow.Options.HeaderContent := AMarker.Options.Title;
  InfoWindow.Options.HeaderDisabled := FInfoHeaderDisabledCheck.IsChecked;
  InfoWindow.Options.Content :=
    '<div style="min-width:220px;padding:6px 4px 2px 4px;font:13px Segoe UI,sans-serif">' +
    '<div style="font-weight:700;color:#0f172a;margin-bottom:6px">' + AMarker.Options.Title + '</div>' +
    '<div style="color:#334155">Lat ' +
      FloatToStr(AMarker.Options.Position.Lat, TFormatSettings.Invariant) +
      ' / Lng ' +
      FloatToStr(AMarker.Options.Position.Lng, TFormatSettings.Invariant) +
    '</div>' +
    '</div>';
  InfoWindow.Options.Position.Assign(AMarker.Options.Position);
  InfoWindow.Options.MaxWidth := 320;
  InfoWindow.Options.PixelOffset.Height := -8;
  InfoWindow.Open(AMarker, FInfoShouldFocusCheck.IsChecked);
end;

procedure TMainForm.SetInitialView;
var
  Coordinate: TGMLibLatLng;
  Latitude: Double;
  Longitude: Double;
  ZoomLevel: Integer;
begin
  if not TryStrToFloat(Trim(FCenterLatEdit.Text), Latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(FCenterLngEdit.Text), Longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  if not TryStrToInt(Trim(FZoomEdit.Text), ZoomLevel) then
  begin
    Log('Invalid zoom value.');
    Exit;
  end;

  Coordinate := TGMLibLatLng.Create(Latitude, Longitude);
  try
    FMap.Options.Center := Coordinate;
  finally
    Coordinate.Free;
  end;

  FMap.Options.Zoom := ZoomLevel;
  Log(Format('View applied. Center=(%s, %s) Zoom=%d', [
    FloatToStr(Latitude, TFormatSettings.Invariant),
    FloatToStr(Longitude, TFormatSettings.Invariant),
    ZoomLevel
  ]));
end;

procedure TMainForm.UpdateMarkerCount;
begin
  FMarkersValueLabel.Text := IntToStr(FMap.Markers.Count);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusValueLabel.Text := AText;
end;

end.
