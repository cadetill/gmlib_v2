{**
  @abstract(Provider-neutral core types shared by map backends.)
}
unit uMapLib.Core.Types;

{$I ..\..\gmlib.inc}

interface

type
  { Unique object identifier used by the JS bridge envelope. }
  TGMObjectId = type string;

  { Logical transport backend used by the bridge. }
  TGMBridgeBackend = (
    bbUnknown,
    bbWebView2,
    bbCEF,
    bbFMX
  );

implementation

end.
