program MarkerEdge;

uses
  Vcl.Forms,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm},
  UMarkerFrame in '..\Common Frames\UMarkerFrame.pas' {MarkerFrame: TFrame};

{$R *.res}

begin
{$ifdef DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$endif}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
