unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Edge, GMLib.Classes, GMLib.Map, GMLib.Map.Vcl, Vcl.StdCtrls, Vcl.ExtCtrls,
  UMarkerFrame;

type
  TMainFrm = class(TForm)
    GMMapEdge1: TGMMapEdge;
    EdgeBrowser1: TEdgeBrowser;
    MakerFrame1: TMakerFrame;
  private
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

{ TMainFrm }

constructor TMainFrm.Create(AOwner: TComponent);
begin
  inherited;

  MakerFrame1.GMMap := GMMapEdge1;
end;

end.
