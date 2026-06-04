program MegaDemo;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms,
  uCEFApplication,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm};

{$R *.res}

begin
  GlobalCEFApp.StartMainProcess;
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
