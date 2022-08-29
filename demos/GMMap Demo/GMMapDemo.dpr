program GMMapDemo;

uses
  Vcl.Forms,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
