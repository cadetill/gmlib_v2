{**
  @abstract(Demo VCL para validar la colección `TGMMap.Markers`.)
  @author(Xavier Martinez (cadetill) <cadetill@gmail.com>)

  Esta unidad define un formulario construido por código para probar la
  creación, interacción y limpieza de marcadores gestionados desde
  `TGMMap.Markers`.
}
unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.StrUtils, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Edge,
   uGMLib.Core.Types, uGMLib.Google.Types, uGMLib.Marker, uGMLib.Vcl.Map;

const
  WM_ADD_CLICK_MARKER = WM_APP + 42;

type
  {** @abstract(Formulario principal de la demo `MarkerLab`.) }
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAddClickMarkersCheck: TCheckBox;
    FAddSampleButton: TButton;
    FAPIKeyEdit: TEdit;
    FBrowser: TEdgeBrowser;
    FCenterLatEdit: TEdit;
    FCenterLngEdit: TEdit;
    FClearMarkersButton: TButton;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapIdEdit: TEdit;
    FMapPanel: TPanel;
    FMapTypeStatusLabel: TLabel;
    FPendingClickLatLng: TMapLibLatLng;
    FPendingClickTitle: string;
    FRootPanel: TPanel;
    FStatusLabel: TLabel;
    FTopPanel: TPanel;
    FZoomEdit: TEdit;
    FNextMarkerIndex: Integer;
    procedure ActivateButtonClick(Sender: TObject);
    procedure AddSampleButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure BuildLayout;
    procedure ClearMarkersButtonClick(Sender: TObject);
    procedure CreateEdit(AParent: TWinControl; const ACaption, AValue: string;
      ALeft, ATop, AWidth: Integer; out AEdit: TEdit);
    procedure HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure HandleMapReady(Sender: TObject);
    procedure HandleMarkerClick(Sender: TObject);
    procedure HandleMarkerDrag(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMarkerDragStart(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMarkerDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure Log(const AText: string);
    procedure ApplyMarkerStyle(AMarker: TGMMarkerItem; const ATitle: string; AVariantIndex: Integer);
    procedure PopulateDefaultMarkers;
    procedure SetInitialView;
    procedure UpdateStatus(const AText: string);
    procedure AddMarker(const ALatLng: TMapLibLatLng; const ATitle: string;
      AVariantIndex: Integer = -1);
    procedure WMAddClickMarker(var AMsg: TMessage); message WM_ADD_CLICK_MARKER;
  public
    {** @abstract(Crea el formulario y construye la UI de la demo.) }
    constructor Create(AOwner: TComponent); override;
    {** @abstract(Libera recursos asociados al mapa y al navegador embebido.) }
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

uses
  Winapi.ActiveX, System.TypInfo;

procedure SetBooleanPropertyIfPublished(AInstance: TObject;
  const APropertyName: string; const AValue: Boolean);
var
  PropInfo: PPropInfo;
begin
  if not Assigned(AInstance) then
    Exit;

  PropInfo := GetPropInfo(AInstance, APropertyName);
  if Assigned(PropInfo) then
    SetOrdProp(AInstance, PropInfo, Ord(AValue));
end;

procedure SetStringPropertyIfPublished(AInstance: TObject;
  const APropertyName, AValue: string);
var
  PropInfo: PPropInfo;
begin
  if not Assigned(AInstance) then
    Exit;

  PropInfo := GetPropInfo(AInstance, APropertyName);
  if Assigned(PropInfo) then
    SetStrProp(AInstance, PropInfo, AValue);
end;

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);
  FMap.Options.MapId := Trim(FMapIdEdit.Text);
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

procedure TMainForm.AddMarker(const ALatLng: TMapLibLatLng; const ATitle: string;
  AVariantIndex: Integer);
var
  MarkerItem: TGMMarkerItem;
begin
  FMap.Markers.BeginUpdate;
  try
    MarkerItem := FMap.Markers.Add;
    MarkerItem.Options.BeginUpdate;
    try
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
      if AVariantIndex >= 0 then
        ApplyMarkerStyle(MarkerItem, ATitle, AVariantIndex);
    finally
      MarkerItem.Options.EndUpdate;
    end;
  finally
    FMap.Markers.EndUpdate;
  end;

  Log(Format('Marker added: "%s" at %s, %s', [
    ATitle,
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)
  ]));

  FMapTypeStatusLabel.Caption := Format('Markers: %d', [FMap.Markers.Count]);
end;

procedure TMainForm.ApplyMarkerStyle(AMarker: TGMMarkerItem; const ATitle: string;
  AVariantIndex: Integer);
begin
  if not Assigned(AMarker) then
    Exit;

  case AVariantIndex mod 4 of
    1:
    begin
      AMarker.Options.ContentMode := mcmDefault;
      Log(Format('Marker "%s" uses default content.', [ATitle]));
    end;
    2:
    begin
      AMarker.Options.ContentMode := mcmHtml;
      AMarker.Options.HtmlOptions.CssClassName := 'gm-marker-price';
      AMarker.Options.HtmlOptions.Html :=
        '<div style="padding:8px 10px;border-radius:999px;background:#111827;color:#f9fafb;' +
        'border:2px solid #f59e0b;font:600 13px Segoe UI,sans-serif;box-shadow:0 8px 20px rgba(0,0,0,.22)">$' +
        IntToStr(20 + AVariantIndex) + '</div>';
      Log(Format('Marker "%s" uses HTML content.', [ATitle]));
    end;
    3:
    begin
      AMarker.Options.ContentMode := mcmPin;
      AMarker.Options.PinOptions.BackgroundCss := '#0f766e';
      AMarker.Options.PinOptions.BorderColorCss := '#134e4a';
      AMarker.Options.PinOptions.GlyphColorCss := '#ffffff';
      AMarker.Options.PinOptions.GlyphText := Copy(ATitle, 1, 1);
      AMarker.Options.PinOptions.Scale := 1.2;
      Log(Format('Marker "%s" uses PinElement content.', [ATitle]));
    end;
  else
    AMarker.Options.ContentMode := mcmLabel;
    AMarker.Options.LabelOptions.CssClassName := 'gm-marker-badge';
    AMarker.Options.LabelOptions.Text := ATitle;
    AMarker.Options.LabelOptions.BackgroundCss := '#7c3aed';
    AMarker.Options.LabelOptions.BorderColorCss := '#c4b5fd';
    AMarker.Options.LabelOptions.TextColorCss := '#faf5ff';
    AMarker.Options.LabelOptions.PaddingHorizontal := 14;
    AMarker.Options.LabelOptions.PaddingVertical := 8;
    AMarker.Options.LabelOptions.CornerRadius := 999;
    AMarker.Options.LabelOptions.FontSize := 13;
    AMarker.Options.LabelOptions.FontBold := True;
    Log(Format('Marker "%s" uses Label content.', [ATitle]));
  end;
end;

procedure TMainForm.AddSampleButtonClick(Sender: TObject);
var
  Coordinate: TMapLibLatLng;
  Latitude: Double;
  Longitude: Double;
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

  Inc(FNextMarkerIndex);
  MarkerTitle := Format('Marker %d', [FNextMarkerIndex]);
  Coordinate := TMapLibLatLng.Create(Latitude, Longitude);
  try
    AddMarker(Coordinate, MarkerTitle, FNextMarkerIndex);
  finally
    Coordinate.Free;
  end;
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Log('WebView created.')
  else
    Log(Format('WebView creation failed. HRESULT=0x%.8x', [Cardinal(AResult)]));
end;

procedure TMainForm.BuildLayout;
begin
  Caption := 'GMLib VCL Marker Lab';
  Width := 1280;
  Height := 860;
  Position := poScreenCenter;
  Font.Name := 'Segoe UI';
  Font.Height := -12;

  FTopPanel := TPanel.Create(Self);
  FTopPanel.Parent := Self;
  FTopPanel.Align := alTop;
  FTopPanel.Height := 92;
  FTopPanel.BevelOuter := bvNone;

  CreateEdit(FTopPanel, 'API key', '', 16, 28, 280, FAPIKeyEdit);
  CreateEdit(FTopPanel, 'Map ID', '', 312, 28, 170, FMapIdEdit);
  CreateEdit(FTopPanel, 'Latitude', '41.3874', 498, 28, 90, FCenterLatEdit);
  CreateEdit(FTopPanel, 'Longitude', '2.1686', 604, 28, 90, FCenterLngEdit);
  CreateEdit(FTopPanel, 'Zoom', '12', 710, 28, 60, FZoomEdit);

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FTopPanel;
  FActivateButton.Left := 790;
  FActivateButton.Top := 26;
  FActivateButton.Width := 110;
  FActivateButton.Caption := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FAddSampleButton := TButton.Create(Self);
  FAddSampleButton.Parent := FTopPanel;
  FAddSampleButton.Left := 914;
  FAddSampleButton.Top := 26;
  FAddSampleButton.Width := 130;
  FAddSampleButton.Caption := 'Add sample marker';
  FAddSampleButton.OnClick := AddSampleButtonClick;

  FClearMarkersButton := TButton.Create(Self);
  FClearMarkersButton.Parent := FTopPanel;
  FClearMarkersButton.Left := 1058;
  FClearMarkersButton.Top := 26;
  FClearMarkersButton.Width := 110;
  FClearMarkersButton.Caption := 'Clear markers';
  FClearMarkersButton.OnClick := ClearMarkersButtonClick;

  FAddClickMarkersCheck := TCheckBox.Create(Self);
  FAddClickMarkersCheck.Parent := FTopPanel;
  FAddClickMarkersCheck.Left := 1186;
  FAddClickMarkersCheck.Top := 30;
  FAddClickMarkersCheck.Width := 170;
  FAddClickMarkersCheck.Caption := 'Add marker on map click';

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FTopPanel;
  FStatusLabel.Left := 16;
  FStatusLabel.Top := 64;
  FStatusLabel.Caption := 'Ready';

  FMapTypeStatusLabel := TLabel.Create(Self);
  FMapTypeStatusLabel.Parent := FTopPanel;
  FMapTypeStatusLabel.Left := 160;
  FMapTypeStatusLabel.Top := 64;
  FMapTypeStatusLabel.Caption := 'Markers: 0';

  FRootPanel := TPanel.Create(Self);
  FRootPanel.Parent := Self;
  FRootPanel.Align := alClient;
  FRootPanel.BevelOuter := bvNone;

  FMapPanel := TPanel.Create(Self);
  FMapPanel.Parent := FRootPanel;
  FMapPanel.Align := alClient;
  FMapPanel.BevelOuter := bvNone;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := FRootPanel;
  FLogMemo.Align := alBottom;
  FLogMemo.Height := 200;
  FLogMemo.ReadOnly := True;
  FLogMemo.ScrollBars := ssVertical;
  FLogMemo.WordWrap := False;

  FBrowser := TEdgeBrowser.Create(Self);
  FBrowser.Parent := FMapPanel;
  FBrowser.Align := alClient;
  SetBooleanPropertyIfPublished(FBrowser, 'AllowSingleSignOnUsingOSPrimaryAccount', False);
  SetStringPropertyIfPublished(FBrowser, 'TargetCompatibleBrowserVersion', '117.0.2045.28');
  SetStringPropertyIfPublished(FBrowser, 'UserDataFolder', '%LOCALAPPDATA%\bds.exe.WebView2');
  FBrowser.OnCreateWebViewCompleted := BrowserCreateWebViewCompleted;
end;

procedure TMainForm.ClearMarkersButtonClick(Sender: TObject);
begin
  FMap.Markers.Clear;
  FMapTypeStatusLabel.Caption := 'Markers: 0';
  Log('All markers cleared.');
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BuildLayout;
  InitializeMap;
  InitializeDefaults;
  FBrowser.Navigate('about:black');
end;

procedure TMainForm.CreateEdit(AParent: TWinControl; const ACaption,
  AValue: string; ALeft, ATop, AWidth: Integer; out AEdit: TEdit);
var
  LabelControl: TLabel;
begin
  LabelControl := TLabel.Create(Self);
  LabelControl.Parent := AParent;
  LabelControl.Left := ALeft;
  LabelControl.Top := 10;
  LabelControl.Caption := ACaption;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := AParent;
  AEdit.Left := ALeft;
  AEdit.Top := ATop;
  AEdit.Width := AWidth;
  AEdit.Text := AValue;
end;

destructor TMainForm.Destroy;
begin
  FreeAndNil(FPendingClickLatLng);

  if Assigned(FMap) then
    FMap.Active := False;

  if Assigned(FBrowser) then
    FBrowser.CloseWebView;
  inherited;
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng;
  const APlaceId: string);
begin
  Log(Format('Map click at %s, %s (placeId=%s)', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant),
    IfThen(APlaceId <> '', APlaceId, '<none>')
  ]));

  if FAddClickMarkersCheck.Checked then
  begin
    Inc(FNextMarkerIndex);
    FreeAndNil(FPendingClickLatLng);
    FPendingClickLatLng := TMapLibLatLng.Create(ALatLng.Lat, ALatLng.Lng);
    FPendingClickTitle := Format('Marker %d', [FNextMarkerIndex]);
    PostMessage(Handle, WM_ADD_CLICK_MARKER, 0, 0);
  end;
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  PopulateDefaultMarkers;
  Log('Map ready event received.');
  UpdateStatus('Map ready');
end;

procedure TMainForm.WMAddClickMarker(var AMsg: TMessage);
var
  ClickLatLng: TMapLibLatLng;
  ClickMarkerTitle: string;
begin
  if not Assigned(FPendingClickLatLng) then
    Exit;

  ClickLatLng := FPendingClickLatLng;
  ClickMarkerTitle := FPendingClickTitle;
  FPendingClickLatLng := nil;
  FPendingClickTitle := '';

  try
    AddMarker(ClickLatLng, ClickMarkerTitle);
  finally
    ClickLatLng.Free;
  end;
end;

procedure TMainForm.HandleMarkerClick(Sender: TObject);
var
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
end;

procedure TMainForm.HandleMarkerDrag(Sender: TObject; ALatLng: TMapLibLatLng);
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

procedure TMainForm.HandleMarkerDragStart(Sender: TObject; ALatLng: TMapLibLatLng);
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

procedure TMainForm.HandleMarkerDragEnd(Sender: TObject; ALatLng: TMapLibLatLng);
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

procedure TMainForm.InitializeDefaults;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMapIdEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID');
  if FMapIdEdit.Text = '' then
    FMapIdEdit.Text := 'DEMO_MAP_ID';
  FAddClickMarkersCheck.Checked := True;
  FNextMarkerIndex := 0;
  UpdateStatus('Ready');
  Log('Marker lab initialized.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
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
  DefaultMarkerPosition: TMapLibLatLng;
  HtmlMarkerPosition: TMapLibLatLng;
  LabelMarkerPosition: TMapLibLatLng;
  PinMarkerPosition: TMapLibLatLng;
begin
  if FMap.Markers.Count > 0 then
    Exit;

  DefaultMarkerPosition := TMapLibLatLng.Create(41.3874, 2.1686);
  try
    AddMarker(DefaultMarkerPosition, 'mcmDefault', 1);
  finally
    DefaultMarkerPosition.Free;
  end;

  HtmlMarkerPosition := TMapLibLatLng.Create(41.3892, 2.1701);
  try
    AddMarker(HtmlMarkerPosition, 'mcmHtml', 2);
  finally
    HtmlMarkerPosition.Free;
  end;

  LabelMarkerPosition := TMapLibLatLng.Create(41.3883, 2.1660);
  try
    AddMarker(LabelMarkerPosition, 'mcmLabel', 4);
  finally
    LabelMarkerPosition.Free;
  end;

  PinMarkerPosition := TMapLibLatLng.Create(41.3857, 2.1669);
  try
    AddMarker(PinMarkerPosition, 'mcmPin', 3);
  finally
    PinMarkerPosition.Free;
  end;

  FNextMarkerIndex := FMap.Markers.Count;
  Log('Default markers added.');
end;

procedure TMainForm.SetInitialView;
var
  Coordinate: TMapLibLatLng;
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

  Coordinate := TMapLibLatLng.Create(Latitude, Longitude);
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

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusLabel.Caption := AText;
  FMapTypeStatusLabel.Caption := Format('Markers: %d', [FMap.Markers.Count]);
end;

end.

