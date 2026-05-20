unit UCircleMainForm;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  System.UITypes,
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
  uGMLib.Circle,
  uGMLib.Core.Types,
  uGMLib.Fmx.Circle,
  uGMLib.Fmx.Map,
  FMX.ScrollBox;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FApplyCircleButton: TButton;
    FBrowser: TWebBrowser;
    FCenterLatEdit: TEdit;
    FCenterLatLabel: TLabel;
    FCenterLngEdit: TEdit;
    FCenterLngLabel: TLabel;
    FClearCircleButton: TButton;
    FClickableCheck: TCheckBox;
    FControlLayout: TLayout;
    FDraggableCheck: TCheckBox;
    FEditableCheck: TCheckBox;
    FLoadSampleButton: TButton;
    FLogLayout: TLayout;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FRadiusEdit: TEdit;
    FRadiusLabel: TLabel;
    FStatusLabel: TLabel;
    FVisibleCheck: TCheckBox;
    FCenterMapButton: TButton;
    FZoomToCircleButton: TButton;
    FMapReady: Boolean;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyCircleButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ClearCircleButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    function GetOrCreatePrimaryCircle: TGMFmxCircleItem;
    procedure HandleCircleCenterChanged(Sender: TObject);
    procedure HandleCircleClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleContextMenu(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleDrag(Sender: TObject);
    procedure HandleCircleDragEnd(Sender: TObject);
    procedure HandleCircleDragStart(Sender: TObject);
    procedure HandleCircleMouseDown(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleMouseOut(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleMouseOver(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleMouseUp(Sender: TObject; ALatLng: TMapLibLatLng);
    procedure HandleCircleRadiusChanged(Sender: TObject);
    procedure HandleCirclesChanged(Sender: TObject);
    procedure HandleMapReady(Sender: TObject);
    procedure CenterMapButtonClick(Sender: TObject);
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure LoadSampleButtonClick(Sender: TObject);
    procedure Log(const AText: string);
    procedure PopulateSampleInputs;
    procedure SyncInputsFromCircle(const ACircle: TGMFmxCircleItem);
    function TryReadFloat(const AEdit: TEdit; out AValue: Double): Boolean;
    procedure UpdateStatus;
    procedure FitCircleToView(const ACircle: TGMFmxCircleItem);
    procedure ZoomToCircleButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}
{$HINTS OFF}

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

procedure TMainForm.ApplyCircleButtonClick(Sender: TObject);
var
  Center: TMapLibLatLng;
  Circle: TGMFmxCircleItem;
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
    Circle.Options.Clickable := FClickableCheck.IsChecked;
    Circle.Options.Draggable := FDraggableCheck.IsChecked;
    Circle.Options.Editable := FEditableCheck.IsChecked;
    Circle.Options.Visible := FVisibleCheck.IsChecked;
    Circle.Options.FillColor := $FF0000FF;
    Circle.Options.StrokeColor := $FF0F172A;
    Center := TMapLibLatLng.Create(CenterLat, CenterLng);
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
  Log(Format('Circle applied at %.3f, %.3f radius %.0f',
    [Circle.Options.Center.Lat, Circle.Options.Center.Lng, Circle.Options.Radius]));
end;

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Circle Lab';
  Width := 1280;
  Height := 760;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 340;
  FControlLayout.Padding.Left := 12;
  FControlLayout.Padding.Top := 10;
  FControlLayout.Padding.Right := 12;
  FControlLayout.Padding.Bottom := 8;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 16;
  FActivateButton.Position.Y := 18;
  FActivateButton.Width := 110;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FApplyCircleButton := TButton.Create(Self);
  FApplyCircleButton.Parent := FControlLayout;
  FApplyCircleButton.Position.X := 140;
  FApplyCircleButton.Position.Y := 18;
  FApplyCircleButton.Width := 110;
  FApplyCircleButton.Text := 'Apply circle';
  FApplyCircleButton.OnClick := ApplyCircleButtonClick;

  FCenterMapButton := TButton.Create(Self);
  FCenterMapButton.Parent := FControlLayout;
  FCenterMapButton.Position.X := 264;
  FCenterMapButton.Position.Y := 18;
  FCenterMapButton.Width := 110;
  FCenterMapButton.Text := 'Center map';
  FCenterMapButton.OnClick := CenterMapButtonClick;

  FLoadSampleButton := TButton.Create(Self);
  FLoadSampleButton.Parent := FControlLayout;
  FLoadSampleButton.Position.X := 388;
  FLoadSampleButton.Position.Y := 18;
  FLoadSampleButton.Width := 110;
  FLoadSampleButton.Text := 'Load sample';
  FLoadSampleButton.OnClick := LoadSampleButtonClick;

  FClearCircleButton := TButton.Create(Self);
  FClearCircleButton.Parent := FControlLayout;
  FClearCircleButton.Position.X := 16;
  FClearCircleButton.Position.Y := 52;
  FClearCircleButton.Width := 110;
  FClearCircleButton.Text := 'Clear';
  FClearCircleButton.OnClick := ClearCircleButtonClick;

  FZoomToCircleButton := TButton.Create(Self);
  FZoomToCircleButton.Parent := FControlLayout;
  FZoomToCircleButton.Position.X := 140;
  FZoomToCircleButton.Position.Y := 52;
  FZoomToCircleButton.Width := 130;
  FZoomToCircleButton.Text := 'Zoom to circle';
  FZoomToCircleButton.OnClick := ZoomToCircleButtonClick;

  FCenterLatLabel := TLabel.Create(Self);
  FCenterLatLabel.Parent := FControlLayout;
  FCenterLatLabel.Position.X := 16;
  FCenterLatLabel.Position.Y := 96;
  FCenterLatLabel.Text := 'Center lat';

  FCenterLatEdit := TEdit.Create(Self);
  FCenterLatEdit.Parent := FControlLayout;
  FCenterLatEdit.Position.X := 16;
  FCenterLatEdit.Position.Y := 118;
  FCenterLatEdit.Width := 180;

  FCenterLngLabel := TLabel.Create(Self);
  FCenterLngLabel.Parent := FControlLayout;
  FCenterLngLabel.Position.X := 214;
  FCenterLngLabel.Position.Y := 96;
  FCenterLngLabel.Text := 'Center lng';

  FCenterLngEdit := TEdit.Create(Self);
  FCenterLngEdit.Parent := FControlLayout;
  FCenterLngEdit.Position.X := 214;
  FCenterLngEdit.Position.Y := 118;
  FCenterLngEdit.Width := 180;

  FRadiusLabel := TLabel.Create(Self);
  FRadiusLabel.Parent := FControlLayout;
  FRadiusLabel.Position.X := 16;
  FRadiusLabel.Position.Y := 156;
  FRadiusLabel.Text := 'Radius (m)';

  FRadiusEdit := TEdit.Create(Self);
  FRadiusEdit.Parent := FControlLayout;
  FRadiusEdit.Position.X := 16;
  FRadiusEdit.Position.Y := 178;
  FRadiusEdit.Width := 180;

  FClickableCheck := TCheckBox.Create(Self);
  FClickableCheck.Parent := FControlLayout;
  FClickableCheck.Position.X := 16;
  FClickableCheck.Position.Y := 214;
  FClickableCheck.Text := 'Clickable';

  FDraggableCheck := TCheckBox.Create(Self);
  FDraggableCheck.Parent := FControlLayout;
  FDraggableCheck.Position.X := 16;
  FDraggableCheck.Position.Y := 242;
  FDraggableCheck.Text := 'Draggable';

  FEditableCheck := TCheckBox.Create(Self);
  FEditableCheck.Parent := FControlLayout;
  FEditableCheck.Position.X := 16;
  FEditableCheck.Position.Y := 270;
  FEditableCheck.Text := 'Editable';

  FVisibleCheck := TCheckBox.Create(Self);
  FVisibleCheck.Parent := FControlLayout;
  FVisibleCheck.Position.X := 16;
  FVisibleCheck.Position.Y := 298;
  FVisibleCheck.Text := 'Visible';

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := FControlLayout;
  FStatusLabel.Position.X := 214;
  FStatusLabel.Position.Y := 180;
  FStatusLabel.Text := 'Circles: 0';

  FLogLayout := TLayout.Create(Self);
  FLogLayout.Parent := Self;
  FLogLayout.Align := TAlignLayout.Bottom;
  FLogLayout.Height := 150;
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

procedure TMainForm.ClearCircleButtonClick(Sender: TObject);
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

procedure TMainForm.ConfigureBrowser;
begin
  {$IFDEF MSWINDOWS}
  FBrowser.WindowsEngine := TWindowsEngine.EdgeOnly;
  {$ENDIF}
end;

constructor TMainForm.Create(AOwner: TComponent);
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

procedure TMainForm.FitCircleToView(const ACircle: TGMFmxCircleItem);
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

function TMainForm.GetOrCreatePrimaryCircle: TGMFmxCircleItem;
begin
  if FMap.Circles.Count = 0 then
    Result := TGMFmxCircleItem(FMap.Circles.Add)
  else
    Result := TGMFmxCircleItem(FMap.Circles[0]);
end;

procedure TMainForm.HandleCircleCenterChanged(Sender: TObject);
var
  Circle: TGMFmxCircleItem;
begin
  if not (Sender is TGMFmxCircleItem) then
    Exit;

  Circle := TGMFmxCircleItem(Sender);
  SyncInputsFromCircle(Circle);
  Log(Format('Circle center changed to %.3f, %.3f',
    [Circle.Options.Center.Lat, Circle.Options.Center.Lng]));
end;

procedure TMainForm.HandleCircleClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle click at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleCircleContextMenu(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle context menu at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleCircleDblClick(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle double click at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
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

procedure TMainForm.HandleCircleMouseDown(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle mouse down at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleCircleMouseMove(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle mouse move at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleCircleMouseOut(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle mouse out at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleCircleMouseOver(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle mouse over at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleCircleMouseUp(Sender: TObject; ALatLng: TMapLibLatLng);
begin
  Log(Format('Circle mouse up at %.3f, %.3f', [ALatLng.Lat, ALatLng.Lng]));
end;

procedure TMainForm.HandleCircleRadiusChanged(Sender: TObject);
var
  Circle: TGMFmxCircleItem;
begin
  if not (Sender is TGMFmxCircleItem) then
    Exit;

  Circle := TGMFmxCircleItem(Sender);
  SyncInputsFromCircle(Circle);
  Log(Format('Circle radius changed to %.0f', [Circle.Options.Radius]));
end;

procedure TMainForm.HandleCirclesChanged(Sender: TObject);
begin
  UpdateStatus;
  if FMap.Circles.Count > 0 then
    SyncInputsFromCircle(TGMFmxCircleItem(FMap.Circles[0]));
end;

procedure TMainForm.HandleMapReady(Sender: TObject);
begin
  FMapReady := True;
  Log('Map ready.');
  UpdateStatus;
end;

procedure TMainForm.CenterMapButtonClick(Sender: TObject);
var
  CenterLat: Double;
  CenterLng: Double;
  Center: TMapLibLatLng;
begin
  if not FMapReady then
  begin
    Log('Map not ready yet. Wait for the ready event before centering.');
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

  Center := TMapLibLatLng.Create(CenterLat, CenterLng);
  try
    FMap.CenterMapTo(Center);
  finally
    Center.Free;
  end;

  Log('Map centered to the current circle center.');
end;

procedure TMainForm.InitializeDefaults;
var
  Center: TMapLibLatLng;
begin
  FMap.APIKey := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMap.Options.MapId := TGMMapId(GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID'));
  if FMap.Options.MapId = '' then
    FMap.Options.MapId := 'DEMO_MAP_ID';

  PopulateSampleInputs;
  Center := TMapLibLatLng.Create(33.678, -116.2425);
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
  FClickableCheck.IsChecked := True;
  FDraggableCheck.IsChecked := True;
  FEditableCheck.IsChecked := True;
  FVisibleCheck.IsChecked := True;
end;

procedure TMainForm.SyncInputsFromCircle(const ACircle: TGMFmxCircleItem);
begin
  FCenterLatEdit.Text := FloatToStr(ACircle.Options.Center.Lat, TFormatSettings.Invariant);
  FCenterLngEdit.Text := FloatToStr(ACircle.Options.Center.Lng, TFormatSettings.Invariant);
  FRadiusEdit.Text := FloatToStr(ACircle.Options.Radius, TFormatSettings.Invariant);
  FClickableCheck.IsChecked := ACircle.Options.Clickable;
  FDraggableCheck.IsChecked := ACircle.Options.Draggable;
  FEditableCheck.IsChecked := ACircle.Options.Editable;
  FVisibleCheck.IsChecked := ACircle.Options.Visible;
end;

function TMainForm.TryReadFloat(const AEdit: TEdit; out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(Trim(AEdit.Text), AValue, TFormatSettings.Invariant);
end;

procedure TMainForm.UpdateStatus;
begin
  FStatusLabel.Text := Format('Circles: %d', [FMap.Circles.Count]);
end;

procedure TMainForm.ZoomToCircleButtonClick(Sender: TObject);
begin
  if FMap.Circles.Count = 0 then
  begin
    Log('There is no circle to zoom.');
    Exit;
  end;

  if not FMapReady then
  begin
    Log('Map not ready yet. Wait for the ready event before zooming.');
    Exit;
  end;
  FitCircleToView(TGMFmxCircleItem(FMap.Circles[0]));
end;

end.

