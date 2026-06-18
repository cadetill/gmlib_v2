program MegaDemo;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms,
  Classes,
  SysUtils,
  uCEFApplication,
  UMainFrm in 'src\UMainFrm.pas' {MainFrm};

procedure AppendFatalStartupLog(const AMessage: string);
var
  logLines: TStringList;
  logFileName: string;
begin
  try
    logFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'gmlib_lcl_fatal.log';
    logLines := TStringList.Create;
    try
      if FileExists(logFileName) then
        logLines.LoadFromFile(logFileName);
      logLines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ' + AMessage);
      logLines.SaveToFile(logFileName);
    finally
      logLines.Free;
    end;
  except
    // Fatal logging must never mask the original exception.
  end;
end;

begin
  try
    if not Assigned(GlobalCEFApp) then
      GlobalCEFApp := TCefApplication.Create;

    if GlobalCEFApp.StartMainProcess then
    begin
      Application.Initialize;
      Application.CreateForm(TMainFrm, MainFrm);
      Application.Run;
    end;
  except
    on E: Exception do
    begin
      AppendFatalStartupLog(E.ClassName + ': ' + E.Message);
      AppendFatalStartupLog('Address=' + IntToHex(PtrUInt(ExceptAddr), SizeOf(Pointer) * 2));
      raise;
    end;
  end;
end.
