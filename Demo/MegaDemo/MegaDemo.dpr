program MegaDemo;

uses
  Vcl.Forms,
  UMainFrm in 'UMainFrm.pas' {MainFrm},
  GMMap in '..\..\src\GMMap.pas',
  GMSets in '..\..\src\GMSets.pas',
  GMClasses in '..\..\src\GMClasses.pas',
  GMTranslations in '..\..\src\GMTranslations.pas',
  GMLatLng in '..\..\src\GMLatLng.pas',
  GMLatLngBounds in '..\..\src\GMLatLngBounds.pas',
  GMMap.VCL in '..\..\src\VCL\GMMap.VCL.pas',
  GMClasses.VCL in '..\..\src\VCL\GMClasses.VCL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
