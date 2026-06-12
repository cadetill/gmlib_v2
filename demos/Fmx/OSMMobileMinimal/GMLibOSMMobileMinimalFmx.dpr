program GMLibOSMMobileMinimalFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMainForm in 'src\UMainForm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
