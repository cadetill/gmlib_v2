program MegaDemo;

uses
  Vcl.Forms,
  UMainFrm in 'UMainFrm.pas' {MainFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
