program GMLibRoutesLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  URoutesMainForm in 'src\URoutesMainForm.pas';

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;
  MainForm := TMainForm.CreateNew(nil);
  try
    MainForm.Show;
    Application.Run;
  finally
    MainForm.Free;
  end;
end.
