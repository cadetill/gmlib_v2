program GMLibRectangleLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  URectangleMainForm in 'src\URectangleMainForm.pas';

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.