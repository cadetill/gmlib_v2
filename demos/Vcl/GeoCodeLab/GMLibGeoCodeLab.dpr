program GMLibGeoCodeLab;

uses
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Winapi.WebView2,
  uGMLib.Core.Types,
  uGMLib.GeoCode,
  uGMLib.Map,
  uGMLib.Vcl.Map,
  UGeoCodeMainForm in 'src\UGeoCodeMainForm.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
