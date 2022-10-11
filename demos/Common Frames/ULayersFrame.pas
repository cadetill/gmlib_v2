unit ULayersFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  GMLib.Map.Vcl, Vcl.CheckLst, Vcl.ComCtrls;

type
  TLayersFrame = class(TFrame)
    cbActive: TCheckBox;
    pcPages: TPageControl;
    tsGeneral: TTabSheet;
    lAPIKey: TLabel;
    Label1: TLabel;
    eAPIKey: TEdit;
    tsMapOptions: TTabSheet;
    pcObjects: TPageControl;
    tsTrafficLayer: TTabSheet;
    tsTransitLayer: TTabSheet;
    tsByciclingLayer: TTabSheet;
    tsKmlLayer: TTabSheet;
    cbTrafficAutoRefresh: TCheckBox;
    cbTransitShow: TCheckBox;
    cbByciclingShow: TCheckBox;
    cbKmlShow: TCheckBox;
    cbKmlClickable: TCheckBox;
    cbKmlPreserveViewport: TCheckBox;
    cbKmlScreenOverlays: TCheckBox;
    cbKmlSuppressInfoWindows: TCheckBox;
    lKmlUrl: TLabel;
    eKmlUrl: TEdit;
    cbTrafficShow: TCheckBox;
    procedure cbActiveClick(Sender: TObject);
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbTrafficAutoRefreshClick(Sender: TObject);
    procedure cbTransitShowClick(Sender: TObject);
    procedure cbByciclingShowClick(Sender: TObject);
    procedure cbKmlShowClick(Sender: TObject);
    procedure cbKmlClickableClick(Sender: TObject);
    procedure cbKmlPreserveViewportClick(Sender: TObject);
    procedure cbKmlScreenOverlaysClick(Sender: TObject);
    procedure cbKmlSuppressInfoWindowsClick(Sender: TObject);
    procedure eKmlUrlChange(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    FGMMap: TGMMap;
    procedure SetGMMap(const Value: TGMMap);
  protected
    procedure SetPropToComponents;
  public
    constructor Create(AOwner: TComponent); override;

    property GMMap: TGMMap read FGMMap write SetGMMap;
  end;

  // because GMMap property (from the frame) is an object from TGMMap class and this class has
  //  all properties protected, I need to define this class to do public all properties
  TGMPublic = class(TGMMap);

implementation

{$R *.dfm}

{ TFrame1 }

procedure TLayersFrame.cbActiveClick(Sender: TObject);
begin
  TGMPublic(GMMap).Active := cbActive.Checked;
end;

procedure TLayersFrame.cbByciclingShowClick(Sender: TObject);
begin
  TGMPublic(GMMap).ByciclingLayer.Show := cbByciclingShow.Checked;
end;

procedure TLayersFrame.cbKmlClickableClick(Sender: TObject);
begin
  TGMPublic(GMMap).KmlLayer.KmlLayerOptions.Clickable := cbKmlClickable.Checked;
end;

procedure TLayersFrame.cbKmlPreserveViewportClick(Sender: TObject);
begin
  TGMPublic(GMMap).KmlLayer.KmlLayerOptions.PreserveViewport := cbKmlPreserveViewport.Checked;
end;

procedure TLayersFrame.cbKmlScreenOverlaysClick(Sender: TObject);
begin
  TGMPublic(GMMap).KmlLayer.KmlLayerOptions.ScreenOverlays := cbKmlScreenOverlays.Checked;
end;

procedure TLayersFrame.cbKmlShowClick(Sender: TObject);
begin
  TGMPublic(GMMap).KmlLayer.Show := cbKmlShow.Checked;
end;

procedure TLayersFrame.cbKmlSuppressInfoWindowsClick(Sender: TObject);
begin
  TGMPublic(GMMap).KmlLayer.KmlLayerOptions.SuppressInfoWindows := cbKmlSuppressInfoWindows.Checked;
end;

procedure TLayersFrame.cbTrafficAutoRefreshClick(Sender: TObject);
begin
  TGMPublic(GMMap).TrafficLayer.TrafficLayerOptions.AutoRefresh := cbTrafficAutoRefresh.Checked;
end;

procedure TLayersFrame.cbTransitShowClick(Sender: TObject);
begin
  TGMPublic(GMMap).TransitLayer.Show := cbTransitShow.Checked;
end;

procedure TLayersFrame.CheckBox1Click(Sender: TObject);
begin
  TGMPublic(GMMap).TrafficLayer.Show := cbTrafficShow.Checked;
end;

constructor TLayersFrame.Create(AOwner: TComponent);
begin
  inherited;

  pcPages.ActivePage := tsGeneral;
  pcObjects.ActivePage := tsTrafficLayer;
end;

procedure TLayersFrame.eAPIKeyChange(Sender: TObject);
begin
  TGMPublic(GMMap).APIKey := eAPIKey.Text;
end;

procedure TLayersFrame.eKmlUrlChange(Sender: TObject);
begin
  TGMPublic(GMMap).KmlLayer.KmlLayerOptions.Url := eKmlUrl.Text;
end;

procedure TLayersFrame.SetGMMap(const Value: TGMMap);
begin
  if FGMMap = Value then
    Exit;

  FGMMap := Value;

  SetPropToComponents;
end;

procedure TLayersFrame.SetPropToComponents;
begin
  eAPIKey.Text := TGMPublic(GMMap).APIKey;
  cbActive.Checked := TGMPublic(GMMap).Active;

  cbTrafficShow.Checked := TGMPublic(GMMap).TrafficLayer.Show;
  cbTrafficAutoRefresh.Checked := TGMPublic(GMMap).TrafficLayer.TrafficLayerOptions.AutoRefresh;

  cbTransitShow.Checked := TGMPublic(GMMap).TransitLayer.Show;

  cbByciclingShow.Checked := TGMPublic(GMMap).ByciclingLayer.Show;

  cbKmlShow.Checked := TGMPublic(GMMap).KmlLayer.Show;
  cbKmlClickable.Checked := TGMPublic(GMMap).KmlLayer.KmlLayerOptions.Clickable;
  cbKmlPreserveViewport.Checked := TGMPublic(GMMap).KmlLayer.KmlLayerOptions.PreserveViewport;
  cbKmlScreenOverlays.Checked := TGMPublic(GMMap).KmlLayer.KmlLayerOptions.ScreenOverlays;
  cbKmlSuppressInfoWindows.Checked := TGMPublic(GMMap).KmlLayer.KmlLayerOptions.SuppressInfoWindows;
  eKmlUrl.Text := TGMPublic(GMMap).KmlLayer.KmlLayerOptions.Url;
end;

end.
