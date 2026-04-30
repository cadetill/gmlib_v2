program GMLibCircleLab;

uses
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.WebView2,
  uGMLib.Circle,
  uGMLib.Core.Types,
  uGMLib.Map,
  uGMLib.Vcl.Circle,
  uGMLib.Vcl.Map,
  UCircleMainForm in 'src\UCircleMainForm.pas' {MainForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
