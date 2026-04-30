program GMLibPolygonLab;

uses
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.WebView2,
  uGMLib.Map,
  uGMLib.Vcl.Map,
  uGMLib.Polygon,
  uGMLib.Vcl.Polygon,
  UPolygonMainForm in 'src\UPolygonMainForm.pas' {MainForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
