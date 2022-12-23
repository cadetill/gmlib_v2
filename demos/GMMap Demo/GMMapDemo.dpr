program GMMapDemo;

uses
  Vcl.Forms,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm},
  UMapFrame in '..\Common Frames\UMapFrame.pas' {MapFrame: TFrame};

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
