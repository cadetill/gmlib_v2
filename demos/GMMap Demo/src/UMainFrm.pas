unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Edge, GMLib.Classes, GMLib.Map, GMLib.Map.Vcl, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TMainFrm = class(TForm)
    Panel1: TPanel;
    lAPIKey: TLabel;
    cbActivate: TCheckBox;
    eAPIKey: TEdit;
    GMMapEdge1: TGMMapEdge;
    EdgeBrowser1: TEdgeBrowser;
    procedure eAPIKeyChange(Sender: TObject);
    procedure cbActivateClick(Sender: TObject);
    procedure EdgeBrowser1NavigationCompleted(Sender: TCustomEdgeBrowser;
      IsSuccess: Boolean; WebErrorStatus: TOleEnum);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

procedure TMainFrm.cbActivateClick(Sender: TObject);
begin
  GMMapEdge1.Active := cbActivate.Checked;
end;

procedure TMainFrm.eAPIKeyChange(Sender: TObject);
begin
  GMMapEdge1.APIKey := eAPIKey.Text;
end;

procedure TMainFrm.EdgeBrowser1NavigationCompleted(Sender: TCustomEdgeBrowser;
  IsSuccess: Boolean; WebErrorStatus: TOleEnum);
begin
Beep;
end;

end.
