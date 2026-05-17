{**
  @abstract(Initial VCL wrapper for the OSM/MapLibre map component.)
}
unit uOSMLib.Vcl.Map;

{$I ..\..\..\gmlib.inc}

interface

uses
  System.Classes,
  uOSMLib.Map;

type
  TOSMLibVclMap = class(TOSMMap)
  end;

  TOSMLibMap = TOSMLibVclMap;

implementation

end.
