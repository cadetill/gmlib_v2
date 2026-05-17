# Roadmap

## Done (v3 baseline)

- Google backend (`GMLib`) is functional in:
  - `VCL` (`WebView2` + optional `CEF4Delphi`)
  - `FMX` (`TWebBrowser` + optional `CEF4Delphi`)
  - `LCL` (`CEF4Delphi`)
- Closed Google slices:
  - `Map`, `Markers`, `InfoWindows`
  - `Polyline`, `Polygon`, `Rectangle`, `Circle`, `GroundOverlay`
  - `GeoCode`, `Elevation`, `Routes`
  - `Layers` (`Traffic`, `Transit`, `Bicycling`, `Kml`)
- Shared bootstrap/runtime JS is integrated and working.
- Runtime asset packaging is implemented via embedded resources extracted to temp files.
- Core extraction completed:
  - `MapLibCore` created and integrated.
  - neutral units consolidated under `uMapLib.Core.*`.
  - legacy `uGMLib.Core.*` wrappers removed.
- Provider folder split completed:
  - `src/Common/{GM,OSM}`.
  - `src/Vcl/{GM,OSM}`.
  - `src/Fmx/{GM,OSM}`.
  - `src/Lcl/{GM,OSM}`.
- Single public VCL design-time aggregator introduced: `MapLibDesign.Vcl`.

## In progress

- OSM pilot backend (`OSMLib`, based on `MapLibre + OSM`):
  - package skeleton exists.
  - initial map/bootstrap placeholders exist.
  - full runtime behavior is still pending.

## Next milestones

### Milestone 1: finish OSM pilot map core

- Implement OSM browser bridge integration per framework.
- Complete first end-to-end `MapReady` flow.
- Complete OSM bootstrap asset pipeline (embedded resources + extraction).
- Add minimal map state flow:
  - activate/deactivate
  - center/zoom
  - bounds sync

### Milestone 2: first OSM functional slice

- Implement first overlay set for OSM pilot (recommended: markers + popups).
- Add at least one demo flow proving real usage in UI.
- Keep package boundaries stable (`MapLibCore` vs provider runtimes).

### Milestone 3: parity planning

- Decide practical parity targets between Google and OSM (do not force 1:1 API).
- Keep provider-specific features explicit instead of hidden fallback behavior.
- Define which shared abstractions can be elevated into `MapLibCore` safely.

## Cross-cutting

- Keep docs aligned with real implementation status (`README`, architecture, roadmap).
- Increase deterministic unit tests on shared/core behavior.
- Keep Delphi 11/12/13 and Lazarus compatibility validated during refactors.
- Keep optional `CEF4Delphi` bridge outside default mandatory runtime dependencies.
- `AirQualityMeterElement` remains future/experimental because Google documents it in `v=alpha`.
