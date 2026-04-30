program GMLibElevationLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UElevationMainForm in 'src\UElevationMainForm.pas';

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
