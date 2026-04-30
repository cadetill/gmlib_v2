program GMLibPolylineLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMainForm in 'src\UMainForm.pas';

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
