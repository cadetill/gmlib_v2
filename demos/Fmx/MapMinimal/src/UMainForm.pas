unit UMainForm;

interface

uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Forms,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  FMX.WebBrowser,
  uGMLib.Core.Types,
  uGMLib.Google.Types,
  uGMLib.Fmx.Map;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FAPIKeyEdit: TEdit;
    FAPIKeyLabel: TLabel;
    FApplyViewButton: TButton;
    FBrowser: TWebBrowser;
    FCenterLatEdit: TEdit;
    FCenterLatLabel: TLabel;
    FCenterLngEdit: TEdit;
    FCenterLngLabel: TLabel;
    FControlLayout: TLayout;
    FLastCenterLogAt: TDateTime;
    FLastCenterSignature: string;
    FLastMapTypeIdSignature: string;
    FLastZoomSignature: string;
    FLogMemo: TMemo;
    FLogLayout: TLayout;
    FMap: TGMLibMap;
    FStatusLabel: TLabel;
    FStatusValueLabel: TLabel;
    FZoomEdit: TEdit;
    FZoomLabel: TLabel;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyViewButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ConfigureBrowser;
    procedure HandleCenterChanged(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng; const APlaceId: string);
    procedure HandleMapTypeIdChanged(Sender: TObject; AMapTypeId: TGMMapTypeId);
    procedure HandleMapReady(Sender: TObject);
    procedure HandleZoomChanged(Sender: TObject; AZoom: Integer);
    procedure InitializeDefaultValues;
    procedure InitializeMap;
    procedure Log(const AText: string);
    procedure UpdateStatus(const AText: string);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  FMap.APIKey := Trim(FAPIKeyEdit.Text);

  ApplyViewButtonClick(nil);

  if not FMap.Active then
  begin
    FMap.Active := True;
    Log('Map activation requested.');
    if FMap.APIKey = '' then
      Log('Loading Google Maps API without API key.')
    else
      Log('Loading Google Maps API with API key.');
    UpdateStatus('Loading map...');
  end
  else
    Log('Map is already active.');
end;

procedure TMainForm.ApplyViewButtonClick(Sender: TObject);
var
  coordinate: TMapLibLatLng;
  latitude: Double;
  longitude: Double;
  zoomLevel: Integer;
begin
  if not TryStrToFloat(Trim(FCenterLatEdit.Text), latitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid latitude value.');
    Exit;
  end;

  if not TryStrToFloat(Trim(FCenterLngEdit.Text), longitude, TFormatSettings.Invariant) then
  begin
    Log('Invalid longitude value.');
    Exit;
  end;

  if not TryStrToInt(Trim(FZoomEdit.Text), zoomLevel) then
  begin
    Log('Invalid zoom value.');
    Exit;
  end;

  coordinate := TMapLibLatLng.Create(latitude, longitude);
  try
    FMap.Options.Center := coordinate;
  finally
    coordinate.Free;
  end;

  FMap.Options.Zoom := zoomLevel;
  Log(Format('View applied. Center=(%s, %s) Zoom=%d', [
    FloatToStr(latitude, TFormatSettings.Invariant),
    FloatToStr(longitude, TFormatSettings.Invariant),
    zoomLevel
  ]));
end;

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Map Minimal Demo';
  Width := 1200;
  Height := 760;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 84;
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
  FAPIKeyEdit.Width := 470;

  FCenterLatLabel := TLabel.Create(Self);
  FCenterLatLabel.Parent := FControlLayout;
  FCenterLatLabel.Position.X := 494;
  FCenterLatLabel.Position.Y := 4;
  FCenterLatLabel.Text := 'Latitude';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := FControlLayout;
  FCenterLatEdit.Position.X := 494;
  FCenterLatEdit.Position.Y := 28;
  FCenterLatEdit.Width := 100;

  FCenterLngLabel := TLabel.Create(Self);
  FCenterLngLabel.Parent := FControlLayout;
  FCenterLngLabel.Position.X := 610;
  FCenterLngLabel.Position.Y := 4;
  FCenterLngLabel.Text := 'Longitude';

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := FControlLayout;
  FCenterLngEdit.Position.X := 610;
  FCenterLngEdit.Position.Y := 28;
  FCenterLngEdit.Width := 110;

  FZoomLabel := TLabel.Create(Self);
  FZoomLabel.Parent := FControlLayout;
  FZoomLabel.Position.X := 736;
  FZoomLabel.Position.Y := 4;
  FZoomLabel.Text := 'Zoom';

  FZoomEdit := TEdit.Create(Self);
  FZoomEdit.Parent := FControlLayout;
  FZoomEdit.Position.X := 736;
  FZoomEdit.Position.Y := 28;
  FZoomEdit.Width := 70;

  FApplyViewButton := TButton.Create(Self);
  FApplyViewButton.Parent := FControlLayout;
  FApplyViewButton.Position.X := 824;
  FApplyViewButton.Position.Y := 26;
  FApplyViewButton.Width := 110;
  FApplyViewButton.Text := 'Apply view';
  FApplyViewButton.OnClick := ApplyViewButtonClick;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 948;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 120;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlLayout;
  FStatusLabel.Position.X := 1088;
  FStatusLabel.Position.Y := 8;
  FStatusLabel.Text := 'Status';

  FStatusValueLabel := TLabel.Create(Self);
  FStatusValueLabel.Parent := FControlLayout;
  FStatusValueLabel.Position.X := 1088;
  FStatusValueLabel.Position.Y := 30;
  FStatusValueLabel.Text := 'Ready';

  FLogLayout := TLayout.Create(Self);
  FLogLayout.Parent := Self;
  FLogLayout.Align := TAlignLayout.Bottom;
  FLogLayout.Height := 190;
  FLogLayout.Padding.Left := 12;
  FLogLayout.Padding.Top := 8;
  FLogLayout.Padding.Right := 12;
  FLogLayout.Padding.Bottom := 12;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := FLogLayout;
  FLogMemo.Align := TAlignLayout.Client;
  FLogMemo.ReadOnly := True;
  FLogMemo.WordWrap := False;
  FLogMemo.Lines.Clear;
  FLogMemo.ShowScrollBars := True;

  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := Self;
  FBrowser.Align := TAlignLayout.Client;
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
  InitializeDefaultValues;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;

  inherited;
end;

procedure TMainForm.HandleCenterChanged(Sender: TObject; ALatLng: TMapLibLatLng);
var
  centerSignature: string;
begin
  FCenterLatEdit.Text := FloatToStr(ALatLng.Lat, TFormatSettings.Invariant);
  FCenterLngEdit.Text := FloatToStr(ALatLng.Lng, TFormatSettings.Invariant);

  centerSignature := Format('%.6f,%.6f', [ALatLng.Lat, ALatLng.Lng], TFormatSettings.Invariant);
  if (centerSignature = FLastCenterSignature) and
     ((Now - FLastCenterLogAt) < EncodeTime(0, 0, 1, 0)) then
    Exit;

  FLastCenterSignature := centerSignature;
  FLastCenterLogAt := Now;
  Log(Format('Center changed from map: %s, %s', [
    FCenterLatEdit.Text,
    FCenterLngEdit.Text
  ]));
end;

procedure TMainForm.HandleMapClick(Sender: TObject; ALatLng: TMapLibLatLng;
  const APlaceId: string);
begin
  Log(Format('Map click at %s, %s (placeId=%s)', [
    FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
    FloatToStr(ALatLng.Lng, TFormatSettings.Invariant),
    IfThen(APlaceId <> '', APlaceId, '<none>')
  ]));
end;

procedure TMainForm.HandleMapTypeIdChanged(Sender: TObject;
  AMapTypeId: TGMMapTypeId);
const
  MapTypeIdNames: array[TGMMapTypeId] of string = ('roadmap', 'satellite', 'hybrid', 'terrain');
var
  signature: string;
begin
  signature := MapTypeIdNames[AMapTypeId];
  if signature = FLastMapTypeIdSignature then
    Exit;

  FLastMapTypeIdSignature := signature;
  Log(Format('MapTypeId changed from map: %s', [signature]));
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  Log('Map ready event received.');
  UpdateStatus('Map ready');
end;

procedure TMainForm.HandleZoomChanged(Sender: TObject; AZoom: Integer);
var
  zoomSignature: string;
begin
  FZoomEdit.Text := IntToStr(AZoom);
  zoomSignature := FZoomEdit.Text;
  if zoomSignature = FLastZoomSignature then
    Exit;

  FLastZoomSignature := zoomSignature;
  Log(Format('Zoom changed from map: %d', [AZoom]));
end;

procedure TMainForm.InitializeDefaultValues;
begin
  FAPIKeyEdit.Text := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FCenterLatEdit.Text := '41.3874';
  FCenterLngEdit.Text := '2.1686';
  FZoomEdit.Text := '12';
  UpdateStatus('Ready');
  Log('Demo initialized. Enter an API key and press Activate map.');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
  FMap.Options.MapTypeControl := True;
  FMap.Options.MapTypeControlOptions.MapTypeIds := [mtRoadmap, mtSatellite, mtHybrid, mtTerrain];
  FMap.Options.MapTypeControlOptions.Position := cpTopRight;
  FMap.Options.MapTypeControlOptions.Style := mtcsDropdownMenu;
  FMap.Options.ZoomControl := True;
  FMap.Options.ZoomControlOptions.Position := cpLeftCenter;
  FMap.OnCenterChanged := HandleCenterChanged;
  FMap.OnMapClick := HandleMapClick;
  FMap.OnMapTypeIdChanged := HandleMapTypeIdChanged;
  FMap.OnMapReady := HandleMapReady;
  FMap.OnZoomChanged := HandleZoomChanged;
end;

procedure TMainForm.Log(const AText: string);
begin
  while FLogMemo.Lines.Count >= 500 do
    FLogMemo.Lines.Delete(0);

  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainForm.UpdateStatus(const AText: string);
begin
  FStatusValueLabel.Text := AText;
end;

end.

