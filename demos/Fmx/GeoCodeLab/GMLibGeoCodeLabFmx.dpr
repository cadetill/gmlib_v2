program GMLibGeoCodeLabFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  UGeoCodeMainForm in 'src\UGeoCodeMainForm.pas';

begin
  Application.Initialize;
  MainForm := TMainForm.CreateNew(nil);
  try
    MainForm.Show;
    Application.Run;
  finally
    MainForm.Free;
  end;
end.
