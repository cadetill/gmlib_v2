program LayersChromium;

uses
  Vcl.Forms,
  uCEFApplication,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm},
  ULayersFrame in '..\Common Frames\ULayersFrame.pas' {LayersFrame: TFrame};

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
