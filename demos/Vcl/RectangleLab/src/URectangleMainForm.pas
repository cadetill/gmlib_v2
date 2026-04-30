unit URectangleMainForm;

interface

uses
  Winapi.WebView2,
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Edge,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  uGMLib.Core.Types,
  uGMLib.Map,
  uGMLib.Vcl.Map,
  uGMLib.Rectangle,
  uGMLib.Vcl.Rectangle, Winapi.ActiveX;

type
  TMainForm = class(TForm)
    Browser: TEdgeBrowser;
    ControlPanel: TPanel;
    ApplyButton: TButton;
    ClearButton: TButton;
    ActivateButton: TButton;
    ZoomToRectangleButton: TButton;
    LogMemo: TMemo;
  private
    FMap: TGMLibMap;
    procedure BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure ApplyButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ActivateButtonClick(Sender: TObject);
    procedure FitSampleRectangle;
    procedure InitializeDefaults;
    procedure InitializeMap;
    procedure ZoomToRectangleButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  InitializeMap;
  InitializeDefaults;
  Browser.OnCreateWebViewCompleted := BrowserCreateWebViewCompleted;
  ApplyButton.OnClick := ApplyButtonClick;
  ClearButton.OnClick := ClearButtonClick;
  ActivateButton.OnClick := ActivateButtonClick;
  ZoomToRectangleButton.OnClick := ZoomToRectangleButtonClick;
end;

destructor TMainForm.Destroy;
begin
  FMap.Free;
  inherited;
end;

procedure TMainForm.BrowserCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  LogMemo.Lines.Add('WebView created');
end;

procedure TMainForm.ActivateButtonClick(Sender: TObject);
begin
  if not FMap.Active then
  begin
    FMap.Active := True;
    LogMemo.Lines.Add('Map activated');
  end
  else
    LogMemo.Lines.Add('Map already active');
end;

procedure TMainForm.ApplyButtonClick(Sender: TObject);
var
  Rectangle: TGMVclRectangleItem;
begin
  if not FMap.Active then
  begin
    LogMemo.Lines.Add('Map not active. Click Activate first.');
    Exit;
  end;
  Rectangle := FMap.Rectangles.Add;
  Rectangle.Options.FillColor := clRed;
  Rectangle.Options.StrokeColor := clBlack;
  Rectangle.Options.Bounds.BeginUpdate;
  try
    Rectangle.Options.Bounds.North := 33.685;
    Rectangle.Options.Bounds.South := 33.671;
    Rectangle.Options.Bounds.East := -116.234;
    Rectangle.Options.Bounds.West := -116.251;
  finally
    Rectangle.Options.Bounds.EndUpdate;
  end;
  LogMemo.Lines.Add('Rectangle added with bounds: N=' + FloatToStr(Rectangle.Options.Bounds.North) +
    ', S=' + FloatToStr(Rectangle.Options.Bounds.South) +
    ', E=' + FloatToStr(Rectangle.Options.Bounds.East) +
    ', W=' + FloatToStr(Rectangle.Options.Bounds.West));
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  FMap.Rectangles.Clear;
  LogMemo.Lines.Add('Rectangles cleared');
end;

procedure TMainForm.FitSampleRectangle;
begin
  if FMap.Rectangles.Count = 0 then
    Exit;

  FMap.FitBounds(33.685, 33.671, -116.234, -116.251);
  LogMemo.Lines.Add('Viewport fitted to rectangle.');
end;

procedure TMainForm.InitializeDefaults;
var
  Center: TGMLibLatLng;
begin
  FMap.APIKey := GetEnvironmentVariable('GOOGLE_MAPS_API_KEY');
  FMap.Options.MapId := TGMMapId(GetEnvironmentVariable('GOOGLE_MAPS_MAP_ID'));
  if FMap.Options.MapId = '' then
    FMap.Options.MapId := 'DEMO_MAP_ID';

  Center := TGMLibLatLng.Create(33.678, -116.2425);
  try
    FMap.Options.Center := Center;
  finally
    Center.Free;
  end;

  FMap.Options.Zoom := 11;
  LogMemo.Lines.Add('Rectangle lab initialized');
end;

procedure TMainForm.InitializeMap;
begin
  FMap := TGMLibMap.Create(Self);
  FMap.Browser := Browser;
end;

procedure TMainForm.ZoomToRectangleButtonClick(Sender: TObject);
begin
  if FMap.Rectangles.Count = 0 then
  begin
    LogMemo.Lines.Add('There is no rectangle to zoom.');
    Exit;
  end;
  FitSampleRectangle;
end;

end.
