# CEF Integration

CEF support in GMLib is optional.

It is not part of the base `GMLibRuntime.Vcl` or `GMLibRuntime.Fmx` packages because not every user has CEF4Delphi installed. The CEF bridges live as opt-in source units:

- `src/Vcl/GM/uGMLib.Vcl.Bridge.Cef.pas`
- `src/Fmx/uGMLib.Fmx.Bridge.Cef.pas`

The base VCL package keeps the native WebView2 bridge only and the base FMX package keeps the native `TWebBrowser` bridge only. If you want CEF, you add the corresponding CEF bridge unit to your own project, together with the CEF4Delphi runtime packages.

## What you need

- CEF4Delphi installed and built in your Delphi environment
- the CEF4Delphi runtime package available to the IDE
- a CEF browser host component, typically `TChromiumWindow` for VCL or `TFMXChromium` for FMX
- `uGMLib.Vcl.Bridge.Cef.pas` or `uGMLib.Fmx.Bridge.Cef.pas` linked into your app or package

The bridge registers itself at initialization time through `uGMLib.Core.BridgeRegistry`.

## How it works

- `TGMLibVclMap.Browser` and `TGMLibFmxMap.Browser` are typed as `TComponent`
- each map selects a bridge based on the browser component passed in
- if the browser is a `TChromiumWindow` or `TFMXChromium`, the registered CEF bridge is selected
- if the browser is a `TEdgeBrowser`, the native VCL WebView2 bridge is selected
- if the browser is a `TWebBrowser`, the native FMX bridge is selected

The map does not need a public `BrowserBackend` property.

## Minimal VCL usage

```pascal
uses
  uGMLib.Vcl.Map,
  uGMLib.Vcl.Bridge.Cef,
  uCEFChromiumWindow;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GMLibMap1.Browser := ChromiumWindow1;
  GMLibMap1.APIKey := '...';
  GMLibMap1.Options.MapId := '...';
  GMLibMap1.Activate;
end;
```

## Minimal FMX usage

```pascal
uses
  uGMLib.Fmx.Map,
  uGMLib.Fmx.Bridge.Cef,
  uCEFFMXChromium;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GMLibMap1.Browser := Chromium1;
  GMLibMap1.APIKey := '...';
  GMLibMap1.Options.MapId := '...';
  GMLibMap1.Activate;
end;
```

## Notes

- The CEF bridge is optional by design.
- It is not included in the standard runtime package build.
- If you do not use `uGMLib.Vcl.Bridge.Cef.pas` or `uGMLib.Fmx.Bridge.Cef.pas`, nothing in the base VCL/FMX packages depends on CEF.
- The same registry-based approach is intended for future backend variants.

