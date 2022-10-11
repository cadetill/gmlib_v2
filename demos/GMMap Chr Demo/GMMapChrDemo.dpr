program GMMapChrDemo;

uses
  Vcl.Forms,
  uCEFApplication,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm},
  UMapFrame in '..\Common Frames\UMapFrame.pas' {MapFrame: TFrame};

{$R *.res}

begin
  GlobalCEFApp := TCefApplication.Create;

  if GlobalCEFApp.StartMainProcess then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
  end;

  GlobalCEFApp.Free;
  GlobalCEFApp := nil;
end.
