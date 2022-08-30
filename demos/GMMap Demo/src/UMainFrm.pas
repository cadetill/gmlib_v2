unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Edge, GMLib.Classes, GMLib.Map, GMLib.Map.Vcl, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin;

type
  TMainFrm = class(TForm)
    Panel1: TPanel;
    lAPIKey: TLabel;
    cbActivate: TCheckBox;
    eAPIKey: TEdit;
    GMMapEdge1: TGMMapEdge;
    EdgeBrowser1: TEdgeBrowser;
    lAPILang: TLabel;
    cbAPILang: TComboBox;
    lAPIRegion: TLabel;
    cbAPIRegion: TComboBox;
    cbAPIVersion: TComboBox;
    lAPIVersion: TLabel;
    lIntervalEvents: TLabel;
    eIntervalEvents: TSpinEdit;
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbActivateClick(Sender: TObject);
  private
    procedure GetAPILang;
    procedure GetAPIRegion;
    procedure GetAPIVersion;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  System.TypInfo,
  GMLib.Sets;

{$R *.dfm}

procedure TMainFrm.cbActivateClick(Sender: TObject);
begin
  GMMapEdge1.Active := cbActivate.Checked;
end;

constructor TMainFrm.Create(AOwner: TComponent);
begin
  inherited;

  GetAPILang;
  GetAPIRegion;
  GetAPIVersion;
end;

procedure TMainFrm.eAPIKeyChange(Sender: TObject);
begin
  GMMapEdge1.APIKey := eAPIKey.Text;
end;

procedure TMainFrm.GetAPILang;
var
  Value: TGMAPILang;
begin
  cbAPILang.Items.Clear;
  for Value := Low(TGMAPILang) to High(TGMAPILang) do
    cbAPILang.Items.Add( GetEnumName(TypeInfo(TGMAPILang), Ord(Value)) );
  cbAPILang.ItemIndex := cbAPILang.Items.IndexOf('lEnglish');
end;

procedure TMainFrm.GetAPIRegion;
var
  Value: TGMAPIRegion;
begin
  cbAPIRegion.Items.Clear;
  for Value := Low(TGMAPIRegion) to High(TGMAPIRegion) do
    cbAPIRegion.Items.Add( GetEnumName(TypeInfo(TGMAPIRegion), Ord(Value)) );
  cbAPIRegion.ItemIndex := cbAPIRegion.Items.IndexOf('rAndorra');
end;

procedure TMainFrm.GetAPIVersion;
var
  Value: TGMAPIVer;
begin
  cbAPIVersion.Items.Clear;
  for Value := Low(TGMAPIVer) to High(TGMAPIVer) do
    cbAPIVersion.Items.Add( GetEnumName(TypeInfo(TGMAPIVer), Ord(Value)) );
  cbAPIVersion.ItemIndex := cbAPIVersion.Items.IndexOf('avWeekly');
end;

end.
