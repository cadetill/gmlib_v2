program GMLibPolygonLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPolygonMainForm in 'src\UPolygonMainForm.pas';

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
