program GMLibRectangleLab;

uses
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.WebView2,
  uGMLib.Map,
  uGMLib.Vcl.Map,
  uGMLib.Rectangle,
  uGMLib.Vcl.Rectangle,
  URectangleMainForm in 'src\URectangleMainForm.pas' {MainForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.