program GMLibTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.XML.NUnit,
  DUnitX.TestFramework,
  uTest.InfoWindow.Model in 'src\uTest.InfoWindow.Model.pas',
  uTest.GeoCode.Model in 'src\uTest.GeoCode.Model.pas',
  uTest.MapOptions.Serialization in 'src\uTest.MapOptions.Serialization.pas',
  uTest.Marker.Model in 'src\uTest.Marker.Model.pas',
  uTest.Geometry.Model in 'src\uTest.Geometry.Model.pas',
  uTest.GroundOverlay.Model in 'src\uTest.GroundOverlay.Model.pas',
  uTest.Rectangle.Model in 'src\uTest.Rectangle.Model.pas',
  uTest.Polygon.Model in 'src\uTest.Polygon.Model.pas',
  uTest.Polyline.Model in 'src\uTest.Polyline.Model.pas',
  uTest.Routes.Model in 'src\uTest.Routes.Model.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
begin
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Runner.FailsOnNoAsserts := False;
    Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
    Runner.AddLogger(TDUnitXXMLNUnitFileLogger.Create);
    Results := Runner.Execute;

    if not Results.AllPassed then
      ExitCode := 1
    else
      ExitCode := 0;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
