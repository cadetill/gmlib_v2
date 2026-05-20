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
- Single public FMX design-time aggregator introduced: `MapLibDesign.Fmx`.
- Single public LCL design-time package introduced: `MapLibDesign.Lcl`.
- Legacy design package naming removed from active flow:
  - `GMLibDesign.Fmx`
  - `GMLibDesign.Lcl`
  - `OSMLibDesign.Vcl`
- JavaScript bridge namespace unified to `window.maplib` for both providers
  (`GMLib` and `OSMLib`).

## In progress

- OSM pilot backend (`OSMLib`, based on `MapLibre + OSM`):
  - map/bootstrap and map event flow are working in Delphi and Lazarus.
  - JSON payload handling has first defensive parsing pass (non-breaking error
    reporting via `OnError` on protocol exceptions).
  - first overlay slice closed: `Markers` with per-item events
    (`OnClick`, `OnDragStart`, `OnDrag`, `OnDragEnd`).
  - helper methods added in marker collection (`Add`, `Clear`,
    `DeleteByObjectId`, `ZoomToMarkers`).
  - offline pilot available with `MapMode` and style/tile source wiring.

- OSM offline native architecture (new focus):
- OSM offline runtime unification (current step):`r`n  - `OfflineTileProvider` added (`Auto/EmbeddedTileJson/ExternalPmtiles/NativePmtiles`).`r`n  - runtime now separates tile server and offline assets server (localhost).`r`n  - bootstrap consumes runtime-resolved offline URLs (style/tilejson/glyphs).`r`n
  - target runtime is embedded and mobile-ready (`Android/iOS`) with no external
    executables as mandatory runtime dependencies.
  - current external PMTiles process path is now considered transitional.
  - next step is a native `OfflineRegionManager` with internal localhost server.

## Next milestones

### Milestone 1: finish OSM pilot map core

- Validate and stabilize framework parity (`VCL`/`FMX`/`LCL`) for the current
  map + marker baseline.
- Keep OSM bootstrap asset pipeline aligned with the current
  embedded/file-switch strategy.

### Milestone 2: first OSM functional slice

- Extend marker options/events (draggable/visible/title/color and update path).
- Add popup parity policy vs Google InfoWindow behavior where applicable.
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

## OSM Offline Native Milestones (new track)

### Milestone A: offline API freeze

- define `OfflineRegionManager` high-level contract:
  - `DownloadRegion(...)`
  - `DeleteRegion(...)`
  - `ListRegions(...)`
  - `GetStorageUsage(...)`
- define hybrid policy enum:
  - `PreferOffline`
  - `PreferOnline`
  - `OfflineOnly`
- define first offline events/state surface (`OnOfflineError`, readiness/coverage).

### Milestone B: embedded local serving

- implement tiny embedded HTTP server (loopback only) to expose internal tile/style assets.
- no external listener and no dependency on external runtime binaries.
- secure-by-default flow for app-local use.

### Milestone C: region catalog and storage

- persistent region index (bbox, zoom range, size, version, checksum).
- active-region selection and storage usage query.

### Milestone D: download/update pipeline

- background/restartable downloads.
- integrity validation and transactional writes.
- update and cleanup policies (manual + size-based pruning).

### Milestone E: full hybrid behavior

- deterministic offline/online fallback behavior per policy.
- framework parity validation (`VCL/FMX/LCL/Android/iOS`).


