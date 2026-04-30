unit UCircleMainForm;

interface

uses
  Winapi.ActiveX,
  Winapi.WebView2,
  Winapi.Windows,
  System.Classes,
  System.Math,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Edge,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  uGMLib.Circle,
  uGMLib.Core.Types,
  uGMLib.Map,
  uGMLib.Vcl.Circle,
  uGMLib.Vcl.Map;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FApplyButton: TButton;
    FBrowser: TEdgeBrowser;
    FCenterLatEdit: TEdit;
    FCenterLngEdit: TEdit;
    FCenterMapButton: TButton;
    FClearButton: TButton;
    FClickableCheck: TCheckBox;
    FControlPanel: TPanel;
    FDraggableCheck: TCheckBox;
    FEditableCheck: TCheckBox;
    FLoadSampleButton: TButton;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FMapReady: Boolean;
    FRadiusEdit: TEdit;
    FStatusLabel: TLabel;
    FVisibleCheck: TCheckBox;
    FZoomToCircleButton: TButton;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure BuildLabUi;
    procedure CenterMapButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure FitCircleToView(const ACircle: TGMVclCircleItem);
    function GetOrCreatePrimaryCircle: TGMVclCircleItem;
    procedure HandleCircleCenterChanged(Sender: TObject);
    procedure HandleCircleClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleDrag(Sender: TObject);
    procedure HandleCircleDragEnd(Sender: TObject);
    procedure HandleCircleDragStart(Sender: TObject);
    procedure HandleCircleMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
    procedure HandleCircleRadiusChanged(Sender: TObject);
    procedure HandleCirclesChanged(Sender: TObject);
    procedure HandleMapReady(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    procedure PopulateSampleInputs;
    procedure SyncInputsFromCircle(const ACircle: TGMVclCircleItem);
    function TryReadFloat(const AEdit: TCustomEdit; out AValue: Double): Boolean;
    procedure UpdateStatus;
    procedure ZoomToCircleButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation
 
constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BuildLabUi;
  InitializeMap;
  InitializeDefaults;
  FBrowser.OnCreateWebViewCompleted := BrowserCreateWebViewCompleted;
  FApplyButton.OnClick := ApplyButtonClick;
  FClearButton.OnClick := ClearButtonClick;
  FActivateButton.OnClick := ActivateButtonClick;
  FCenterMapButton.OnClick := CenterMapButtonClick;
  FLoadSampleButton.OnClick := LoadSampleButtonClick;
  FZoomToCircleButton.OnClick := ZoomToCircleButtonClick;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FMap) then
    FMap.Active := False;
  FMap.Free;
  inherited;
end;

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  if not FMap.Active then
  begin
    FMap.Active := True;
    Log('Map activated');
  end
  else
    Log('Map already active');
end;

procedure TMainForm.ApplyButtonClick(Sender: TObject);
var
  Circle: TGMVclCircleItem;
  Center: TGMLibLatLng;
  CenterLat: Double;
  CenterLng: Double;
  Radius: Double;
  Command: string;
begin
  if not FMap.Active then
  begin
    Log('Map not active. Click Activate first.');
    Exit;
  end;

  if not TryReadFloat(FCenterLatEdit, CenterLat) then
  begin
    Log('Invalid center latitude value.');
    Exit;
  end;

  if not TryReadFloat(FCenterLngEdit, CenterLng) then
  begin
    Log('Invalid center longitude value.');
    Exit;
  end;

  if not TryReadFloat(FRadiusEdit, Radius) then
  begin
    Log('Invalid radius value.');
    Exit;
  end;

  FMap.Circles.BeginUpdate;
  try
    Circle := GetOrCreatePrimaryCircle;
    Circle.OnCenterChanged := HandleCircleCenterChanged;
    Circle.OnRadiusChanged := HandleCircleRadiusChanged;
    Circle.OnClick := HandleCircleClick;
    Circle.OnContextMenu := HandleCircleContextMenu;
    Circle.OnDblClick := HandleCircleDblClick;
    Circle.OnDragStart := HandleCircleDragStart;
    Circle.OnDrag := HandleCircleDrag;
    Circle.OnDragEnd := HandleCircleDragEnd;
    Circle.OnMouseDown := HandleCircleMouseDown;
    Circle.OnMouseMove := HandleCircleMouseMove;
    Circle.OnMouseOut := HandleCircleMouseOut;
    Circle.OnMouseOver := HandleCircleMouseOver;
    Circle.OnMouseUp := HandleCircleMouseUp;
    Circle.Options.Clickable := FClickableCheck.Checked;
    Circle.Options.Draggable := FDraggableCheck.Checked;
    Circle.Options.Editable := FEditableCheck.Checked;
    Circle.Options.Visible := FVisibleCheck.Checked;
    Circle.Options.FillColor := clRed;
    Circle.Options.StrokeColor := clBlack;
    Center := TGMLibLatLng.Create(CenterLat, CenterLng);
    try
      Circle.Options.Center := Center;
    finally
      Center.Free;
    end;
    Circle.Options.Radius := Radius;
  finally
    FMap.Circles.EndUpdate;
  end;

  FMap.CenterMapTo(Circle.Options.Center);
  Command := Circle.BuildApplyCommand;
  SyncInputsFromCircle(Circle);
  UpdateStatus;
  Log('Circle command: ' + Command);
  FLogMemo.Lines.Add(Format('Circle applied at %s, %s radius %.0f',
    [FloatToStr(Circle.Options.Center.Lat, TFormatSettings.Invariant),
     FloatToStr(Circle.Options.Center.Lng, TFormatSettings.Invariant),
     Circle.Options.Radius]));
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  Log('WebView created');
end;

procedure TMainForm.BuildLabUi;
begin
  Caption := 'GMLib VCL Circle Lab';
  ClientWidth := 1040;
  ClientHeight := 760;

  FControlPanel := TPanel.Create(Self);
  FControlPanel.Parent := Self;
  FControlPanel.Align := alTop;
  FControlPanel.Height := 340;
  FControlPanel.BevelOuter := bvNone;

  FLogMemo := TMemo.Create(Self);
  FLogMemo.Parent := Self;
  FLogMemo.Align := alBottom;
  FLogMemo.Height := 150;
  FLogMemo.ReadOnly := True;
  FLogMemo.ScrollBars := ssVertical;

  FBrowser := TEdgeBrowser.Create(Self);
  FBrowser.Parent := Self;
  FBrowser.Align := alClient;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlPanel;
  FActivateButton.SetBounds(16, 16, 110, 25);
  FActivateButton.Caption := 'Activate map';

  FApplyButton := TButton.Create(Self);
  FApplyButton.Parent := FControlPanel;
  FApplyButton.SetBounds(140, 16, 110, 25);
  FApplyButton.Caption := 'Apply circle';

  FCenterMapButton := TButton.Create(Self);
  FCenterMapButton.Parent := FControlPanel;
  FCenterMapButton.SetBounds(264, 16, 110, 25);
  FCenterMapButton.Caption := 'Center map';

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FControlPanel;
  FLoadSampleButton.SetBounds(388, 16, 110, 25);
  FLoadSampleButton.Caption := 'Load sample';

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FControlPanel;
  FClearButton.SetBounds(16, 52, 110, 25);
  FClearButton.Caption := 'Clear';

  FZoomToCircleButton := TButton.Create(Self);
  FZoomToCircleButton.Parent := FControlPanel;
  FZoomToCircleButton.SetBounds(140, 52, 130, 25);
  FZoomToCircleButton.Caption := 'Zoom to circle';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := FControlPanel;
  FCenterLatEdit.SetBounds(16, 118, 180, 23);

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := FControlPanel;
  FCenterLngEdit.SetBounds(214, 118, 180, 23);

  FRadiusEdit := TEdit.Create(Self);
  FRadiusEdit.Parent := FControlPanel;
  FRadiusEdit.SetBounds(16, 170, 180, 23);

  FClickableCheck := TCheckBox.Create(Self);
  FClickableCheck.Parent := FControlPanel;
  FClickableCheck.SetBounds(16, 210, 140, 21);
  FClickableCheck.Caption := 'Clickable';

  FDraggableCheck := TCheckBox.Create(Self);
  FDraggableCheck.Parent := FControlPanel;
  FDraggableCheck.SetBounds(16, 238, 140, 21);
  FDraggableCheck.Caption := 'Draggable';

  FEditableCheck := TCheckBox.Create(Self);
  FEditableCheck.Parent := FControlPanel;
  FEditableCheck.SetBounds(16, 266, 140, 21);
  FEditableCheck.Caption := 'Editable';

  FVisibleCheck := TCheckBox.Create(Self);
  FVisibleCheck.Parent := FControlPanel;
  FVisibleCheck.SetBounds(16, 294, 140, 21);
  FVisibleCheck.Caption := 'Visible';

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlPanel;
  FStatusLabel.SetBounds(214, 170, 360, 21);
  FStatusLabel.Caption := 'Circles: 0';
end;

procedure TMainForm.CenterMapButtonClick(Sender: TObject);
var
  CenterLat: Double;
  CenterLng: Double;
  Center: TGMLibLatLng;
begin
  if not TryReadFloat(FCenterLatEdit, CenterLat) then
  begin
    Log('Invalid center latitude value.');
    Exit;
  end;

  if not TryReadFloat(FCenterLngEdit, CenterLng) then
  begin
    Log('Invalid center longitude value.');
    Exit;
  end;

  Center := TGMLibLatLng.Create(CenterLat, CenterLng);
  try
    FMap.CenterMapTo(Center);
  finally
    Center.Free;
  end;

  Log('Map centered to the current circle center.');
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  FMap.Circles.BeginUpdate;
  try
    FMap.Circles.Clear;
  finally
    FMap.Circles.EndUpdate;
  end;
  Log('Circles cleared');
  UpdateStatus;
end;

procedure TMainForm.FitCircleToView(const ACircle: TGMVclCircleItem);
var
  CenterLat: Double;
  CenterLng: Double;
  CosLat: Double;
  LatDelta: Double;
  LngDelta: Double;
  Radius: Double;
begin
  Radius := Abs(ACircle.Options.Radius);
  CenterLat := ACircle.Options.Center.Lat;
  CenterLng := ACircle.Options.Center.Lng;
  LatDelta := Radius / 111320.0;
  CosLat := Abs(Cos(DegToRad(CenterLat)));
  if CosLat < 0.0001 then
    CosLat := 0.0001;
  LngDelta := Radius / (111320.0 * CosLat);
  FMap.CenterMapTo(ACircle.Options.Center);
  FMap.FitBounds(CenterLat + LatDelta, CenterLat - LatDelta,
    CenterLng + LngDelta, CenterLng - LngDelta);
  Log('Viewport fitted to circle.');
end;

function TMainForm.GetOrCreatePrimaryCircle: TGMVclCircleItem;
begin
  if FMap.Circles.Count = 0 then
    Result := TGMVclCircleItem(FMap.Circles.Add)
  else
    Result := TGMVclCircleItem(FMap.Circles[0]);
end;

procedure TMainForm.HandleCircleCenterChanged(Sender: TObject);
var
  Circle: TGMVclCircleItem;
begin
  if not (Sender is TGMVclCircleItem) then
    Exit;

  Circle := TGMVclCircleItem(Sender);
  SyncInputsFromCircle(Circle);
  Log(Format('Circle center changed to %s, %s',
    [FloatToStr(Circle.Options.Center.Lat, TFormatSettings.Invariant),
     FloatToStr(Circle.Options.Center.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle click at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleContextMenu(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle context menu at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleDblClick(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle double click at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleDrag(Sender: TObject);
begin
  Log('Circle dragging.');
end;

procedure TMainForm.HandleCircleDragEnd(Sender: TObject);
begin
  Log('Circle drag end.');
end;

procedure TMainForm.HandleCircleDragStart(Sender: TObject);
begin
  Log('Circle drag start.');
end;

procedure TMainForm.HandleCircleMouseDown(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle mouse down at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleMouseMove(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle mouse move at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleMouseOut(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle mouse out at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleMouseOver(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle mouse over at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleMouseUp(Sender: TObject; ALatLng: TGMLibLatLng);
begin
  Log(Format('Circle mouse up at %s, %s',
    [FloatToStr(ALatLng.Lat, TFormatSettings.Invariant),
     FloatToStr(ALatLng.Lng, TFormatSettings.Invariant)]));
end;

procedure TMainForm.HandleCircleRadiusChanged(Sender: TObject);
var
  Circle: TGMVclCircleItem;
begin
  if not (Sender is TGMVclCircleItem) then
    Exit;

  Circle := TGMVclCircleItem(Sender);
  SyncInputsFromCircle(Circle);
  Log(Format('Circle radius changed to %.0f', [Circle.Options.Radius]));
end;

procedure TMainForm.HandleCirclesChanged(Sender: TObject);
begin
  UpdateStatus;
  if FMap.Circles.Count > 0 then
    SyncInputsFromCircle(TGMVclCircleItem(FMap.Circles[0]));
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  FMapReady := True;
  Log('Map ready.');
  UpdateStatus;
end;

procedure TMainForm.InitializeDefaults;
var
  Center: TGMLibLatLng;
begin
  FMap.APIKey := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMap.Options.MapId := TGMMapId(GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID'));
  if FMap.Options.MapId = '' then
    FMap.Options.MapId := 'DEMO_MAP_ID';

  PopulateSampleInputs;
  Center := TGMLibLatLng.Create(33.678, -116.2425);
  try
    FMap.Options.Center := Center;
  finally
    Center.Free;
  end;
  FMap.Options.Zoom := 13;
  UpdateStatus;
  Log('Circle lab initialized');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
  FMap.Circles.OnChange := HandleCirclesChanged;
  FMap.OnMapReady := HandleMapReady;
  FMapReady := False;
end;

procedure TMainForm.LoadSampleButtonClick(Sender: TObject);
begin
  PopulateSampleInputs;
  Log('Sample circle inputs restored.');
end;

procedure TMainForm.Log(const AText: string);
begin
  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainForm.PopulateSampleInputs;
begin
  FCenterLatEdit.Text := FloatToStr(33.678, TFormatSettings.Invariant);
  FCenterLngEdit.Text := FloatToStr(-116.2425, TFormatSettings.Invariant);
  FRadiusEdit.Text := FloatToStr(1000, TFormatSettings.Invariant);
  FClickableCheck.Checked := True;
  FDraggableCheck.Checked := True;
  FEditableCheck.Checked := True;
  FVisibleCheck.Checked := True;
end;

procedure TMainForm.SyncInputsFromCircle(const ACircle: TGMVclCircleItem);
begin
  FCenterLatEdit.Text := FloatToStr(ACircle.Options.Center.Lat, TFormatSettings.Invariant);
  FCenterLngEdit.Text := FloatToStr(ACircle.Options.Center.Lng, TFormatSettings.Invariant);
  FRadiusEdit.Text := FloatToStr(ACircle.Options.Radius, TFormatSettings.Invariant);
  FClickableCheck.Checked := ACircle.Options.Clickable;
  FDraggableCheck.Checked := ACircle.Options.Draggable;
  FEditableCheck.Checked := ACircle.Options.Editable;
  FVisibleCheck.Checked := ACircle.Options.Visible;
end;

function TMainForm.TryReadFloat(const AEdit: TCustomEdit; out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(Trim(AEdit.Text), AValue, TFormatSettings.Invariant);
end;

procedure TMainForm.UpdateStatus;
begin
  FStatusLabel.Caption := Format('Circles: %d', [FMap.Circles.Count]);
end;

procedure TMainForm.ZoomToCircleButtonClick(Sender: TObject);
begin
  if FMap.Circles.Count = 0 then
  begin
    Log('There is no circle to zoom.');
    Exit;
  end;

  FitCircleToView(TGMVclCircleItem(FMap.Circles[0]));
end;

end.
