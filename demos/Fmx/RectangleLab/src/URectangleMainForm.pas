unit URectangleMainForm;

interface

uses
  System.Classes,
  System.StrUtils,
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
  uGMLib.Core.Types,
  uGMLib.Rectangle,
  uGMLib.Fmx.Map,
  uGMLib.Fmx.Rectangle, FMX.ScrollBox;

type
  TMainForm = class(TForm)
  private
    FActivateButton: TButton;
    FApplyRectangleButton: TButton;
    FBrowser: TWebBrowser;
    FClearRectangleButton: TButton;
    FControlLayout: TLayout;
    FEditableCheck: TCheckBox;
    FDraggableCheck: TCheckBox;
    FLogLayout: TLayout;
    FLogMemo: TMemo;
    FMap: TGMLibMap;
    FZoomToRectangleButton: TButton;
    procedure ActivateButtonClick(Sender: TObject);
    procedure ApplyRectangleButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure ClearRectangleButtonClick(Sender: TObject);
    procedure ConfigureBrowser;
    procedure InitializeMap;
    procedure InitializeDefaults;
    procedure Log(const AText: string);
    procedure ZoomToRectangleButtonClick(Sender: TObject);
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

procedure TMainForm.ApplyRectangleButtonClick(Sender: TObject);
var
  Rectangle: TGMFmxRectangleItem;
begin
  if not FMap.Active then
  begin
    Log('Map not active. Click Activate first.');
    Exit;
  end;
  Rectangle := FMap.Rectangles.Add;
  Rectangle.Options.FillColor := $FF0000FF;
  Rectangle.Options.StrokeColor := $FF0F172A;
  Rectangle.Options.Bounds.BeginUpdate;
  try
    Rectangle.Options.Bounds.North := 33.685;
    Rectangle.Options.Bounds.South := 33.671;
    Rectangle.Options.Bounds.East := -116.234;
    Rectangle.Options.Bounds.West := -116.251;
  finally
    Rectangle.Options.Bounds.EndUpdate;
  end;
  Log(Format('Rectangle added with bounds: N=%.3f, S=%.3f, E=%.3f, W=%.3f',
    [Rectangle.Options.Bounds.North, Rectangle.Options.Bounds.South,
     Rectangle.Options.Bounds.East, Rectangle.Options.Bounds.West]));
  Log('Rectangle applied.');
end;

procedure TMainForm.BuildUi;
begin
  Caption := 'GMLib FMX Rectangle Lab';
  Width := 1280;
  Height := 900;

  FControlLayout := TLayout.Create(Self);
  FControlLayout.Parent := Self;
  FControlLayout.Align := TAlignLayout.Top;
  FControlLayout.Height := 94;
  FControlLayout.Padding.Left := 12;
  FControlLayout.Padding.Top := 10;
  FControlLayout.Padding.Right := 12;
  FControlLayout.Padding.Bottom := 8;

  FActivateButton := TButton.Create(Self);
  FActivateButton.Parent := FControlLayout;
  FActivateButton.Position.X := 16;
  FActivateButton.Position.Y := 26;
  FActivateButton.Width := 110;
  FActivateButton.Text := 'Activate map';
  FActivateButton.OnClick := ActivateButtonClick;

  FApplyRectangleButton := TButton.Create(Self);
  FApplyRectangleButton.Parent := FControlLayout;
  FApplyRectangleButton.Position.X := 140;
  FApplyRectangleButton.Position.Y := 26;
  FApplyRectangleButton.Width := 130;
  FApplyRectangleButton.Text := 'Apply rectangle';
  FApplyRectangleButton.OnClick := ApplyRectangleButtonClick;

  FClearRectangleButton := TButton.Create(Self);
  FClearRectangleButton.Parent := FControlLayout;
  FClearRectangleButton.Position.X := 284;
  FClearRectangleButton.Position.Y := 26;
  FClearRectangleButton.Width := 100;
  FClearRectangleButton.Text := 'Clear';
  FClearRectangleButton.OnClick := ClearRectangleButtonClick;

  FZoomToRectangleButton := TButton.Create(Self);
  FZoomToRectangleButton.Parent := FControlLayout;
  FZoomToRectangleButton.Position.X := 398;
  FZoomToRectangleButton.Position.Y := 26;
  FZoomToRectangleButton.Width := 130;
  FZoomToRectangleButton.Text := 'Zoom to rectangle';
  FZoomToRectangleButton.OnClick := ZoomToRectangleButtonClick;

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

procedure TMainForm.ClearRectangleButtonClick(Sender: TObject);
begin
  FMap.Rectangles.Clear;
  Log('Rectangles cleared');
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

procedure TMainForm.InitializeDefaults;
var
  Center: TMapLibLatLng;
begin
  FMap.APIKey := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMap.Options.MapId := TGMMapId(GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID'));
  if FMap.Options.MapId = '' then
    FMap.Options.MapId := 'DEMO_MAP_ID';

  Center := TMapLibLatLng.Create(33.678, -116.2425);
  try
    FMap.Options.Center := Center;
  finally
    Center.Free;
  end;

  FMap.Options.Zoom := 11;
  Log('Rectangle lab initialized');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := FBrowser;
end;

procedure TMainForm.Log(const AText: string);
begin
  FLogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

procedure TMainForm.ZoomToRectangleButtonClick(Sender: TObject);
begin
  if FMap.Rectangles.Count = 0 then
  begin
    Log('There is no rectangle to zoom.');
    Exit;
  end;
  FMap.FitBounds(33.685, 33.671, -116.234, -116.251);
  Log('Viewport fitted to rectangle.');
end;

end.

