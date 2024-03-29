program MarkerChromium;

uses
  Vcl.Forms,
  uCEFApplication,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm},
  UMarkerFrame in '..\Common Frames\UMarkerFrame.pas' {MarkerFrame: TFrame};

{$R *.res}

begin
{$ifdef DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$endif}

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
