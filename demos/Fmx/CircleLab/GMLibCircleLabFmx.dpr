program GMLibCircleLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UCircleMainForm in 'src\UCircleMainForm.pas';

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.