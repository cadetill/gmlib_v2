program MegaDemoFmx;

uses
  FMX.Forms,
  FMX.Skia,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
