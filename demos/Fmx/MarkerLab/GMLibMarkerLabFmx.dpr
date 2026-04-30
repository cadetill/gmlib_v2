program GMLibMarkerLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMainForm in 'src\UMainForm.pas';

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
