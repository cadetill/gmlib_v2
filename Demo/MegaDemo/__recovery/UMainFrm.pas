unit UMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GMClasses, GMMap,
  GMMap.VCL, Vcl.OleCtrls, SHDocVw, Vcl.ExtCtrls;

type
  TMainFrm = class(TForm)
    GMMap1: TGMMap;
    WebBrowser1: TWebBrowser;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  GMSets;

{$R *.dfm}

procedure TMainFrm.Button1Click(Sender: TObject);
begin
  try
    GMMap1.Active := not GMMap1.Active;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

end.
