program LayersEdge;

uses
  Vcl.Forms,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm},
  ULayersFrame in '..\Common Frames\ULayersFrame.pas' {LayersFrame: TFrame};

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
