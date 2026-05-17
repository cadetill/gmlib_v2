{**
  @abstract(Helpers de formato compartidos entre compiladores.)
}
unit uGMLib.Platform.Format;

{$I ..\..\..\gmlib.inc}

interface

uses
{$IFDEF FPC}
  SysUtils;
{$ELSE}
  System.SysUtils;
{$ENDIF}

function GMLibInvariantFormatSettings: TFormatSettings;

implementation

function GMLibInvariantFormatSettings: TFormatSettings;
begin
{$IFDEF FPC}
  Result := DefaultFormatSettings;
  Result.DecimalSeparator := '.';
  Result.ThousandSeparator := #0;
{$ELSE}
  Result := TFormatSettings.Invariant;
{$ENDIF}
end;

end.
