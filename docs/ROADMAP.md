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
- Embedded bootstrap extraction is now validated on `FMX` mobile for both
  `GMLib` and `OSMLib`; `MAP_BOOTSTRAP_FROM_FILES` remains development-only.
- The next mobile offline step is no longer "make bootstrap work", but
  "validate real cache/offline behavior" because the embedded asset path is now
  also in place for offline `MapLibre CSS/JS` and style-template resolution.
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
  - map/bootstrap and map event flow are working in `VCL`, `FMX`, and `LCL`.
  - runtime command coverage is no longer limited to bootstrap + click path:
    `map.set_view`, `map.set_style`, `map.fit_bounds`, and `map.set_options`
    are now implemented end-to-end.
  - current map core now includes:
    - `Bearing`
    - `Pitch`
    - `MinZoom`
    - `MaxZoom`
    - `MinPitch`
    - `MaxPitch`
    - `MaxBounds`
    - `RenderWorldCopies`
    - interaction flags for drag/zoom/keyboard/touch/cooperative gestures
  - map event forwarding now includes the main view/runtime families
    (`move*`, `drag*`, `zoom*`, `rotate*`, `pitch*`, `load`, `idle`,
    `render`, `data*`, `styledata*`, `boundschanged`, etc.).
  - map event surface now also exposes `OnCooperativeGesturePrevented`.
  - JS -> Delphi view synchronization now keeps `CenterLat`, `CenterLng`,
    `Zoom`, `Bearing`, and `Pitch` updated even when no Delphi event handler is
    attached.
  - JSON payload handling has first defensive parsing pass (non-breaking error
    reporting via `OnError` on protocol exceptions).
  - first overlay slice closed: `Markers` with per-item events
    (`OnClick`, `OnDragStart`, `OnDrag`, `OnDragEnd`).
  - next overlay slice now also closed at the current validation level:
    `Popups` with:
    - free-position popup
    - marker-anchored popup
    - `OnOpen`
    - `OnClose`
    - `CloseOnMove`
    - `ContentType` (`HTML` / plain text)
    - typed visual presets
    - closed anchor-loss behavior (popup closes if the anchor marker disappears)
  - helper methods added in marker collection (`Add`, `Clear`,
    `DeleteByObjectId`, `ZoomToMarkers`).
  - offline/hybrid runtime validated in `VCL`.
  - `FMX` and `LCL` bootstraps now accept local MapLibre CSS/JS assets through
    the same embedded/file-switch strategy used in `VCL`.
  - `GMLibRuntime.Lcl` compile path is back to green after the latest FPC
    compatibility fixes in the common offline/runtime layer.
  - `MegaDemo LCL` also compiles again and now exposes the same practical
    offline validation surface needed to test regions/runtime.
  - the LCL offline/hybrid bootstrap path has moved from `LoadString(...)` to
    a real runtime-served `/bootstrap` URL under the same localhost origin.
  - the localhost runtime itself now starts without freezing the UI in `LCL`
    because `TFPHTTPServer` activation runs on a worker thread.
  - `VCL MegaDemo` now exposes:
    - camera + restrictions (`min/max zoom`, `min/max pitch`, `max bounds`)
    - interaction flags
    - `RenderWorldCopies`
    - online style presets for OpenFreeMap
    - popup CRUD/testing UI
  - `FMX MegaDemo` now also exposes popup CRUD/testing UI plus marker-click
    popup validation flow
- `demos/Fmx/OSMMobileMinimal` is now the minimal `FMX` mobile validation demo
  for `OSMLib` on `Android/iOS`, with explicit `Online/Hybrid/Offline` mode
  switching.
  - latest round compiles cleanly according to manual validation.
  - current decision: mobile `Offline` is treated as an emergency/fallback
    mode, not as a full replacement for online rendering quality.
  - current glyph policy: keep only `Noto Sans Regular` as the embedded local
    corpus for labels unless a concrete product/runtime need justifies more.

- Google LCL framework parity:
  - `MapOptions`, `Circle`, `Polygon`, and `Rectangle` already exposed `TColor`.
  - `Marker` and `Polyline` LCL wrappers were added to complete the same native
    color policy used by `VCL` and `FMX`.

- OSM offline native architecture (current focus):
  - target runtime is embedded and mobile-ready (`Android/iOS`) with no external
    executables as mandatory runtime dependencies.
  - current runtime direction is `MapLibre + localhost + SQLite cache`.
  - the shared layer already includes:
    - `OfflineRegionManager`
    - embedded localhost runtime serving
    - `StyleProvider`
    - `TileResolver`
    - `VectorRuntime`
    - `SqliteTileStore`
  - embedded localhost serving and SQLite tile-cache persistence are now
    aligned in the shared runtime for `VCL`, `FMX`, and `LCL/FPC`.
  - `OfflineRegionManager`, `StyleProvider`, `TileResolver`, and related units
    are now covered by deterministic unit tests.
  - first `BuildRegion` viewport -> `MBTiles` flow is now working in
    `FMX MegaDemo`, including:
    - tile-count estimation
    - v1 limits (`<=5000` normal, `<=10000` warning, `>10000` blocked)
    - auto coverage lookup between downloaded regions
    - `Go To Region` for disconnected offline areas
  - the offline region manager/runtime contract was hardened for `v1`:
    - early request validation
    - duplicate `RegionId` blocked until the old region is deleted
    - stale `*.tmp` / `*.building.mbtiles` cleanup on re-entry
    - explicit cancel action exposed in `FMX MegaDemo`
    - cancellation now reported separately from real download/build failures
  - current build performance is considered sufficient for `v1`; no extra
    download concurrency is planned for now.
  - current `CEF4Delphi` hybrid/offline blocker is no longer
    compile/bootstrap/runtime startup:
    runtime `/bootstrap` and `/asset/...` requests work, but even a minimal
    external `probe.js` served by the embedded localhost runtime is downloaded
    and still not executed afterwards in the current host flow.
  - this means the active problem is no longer best framed as a pure
    `MapLibre` worker issue; it currently looks like a `CEF4Delphi`
    localhost-script bootstrap limitation/integration gap.
  - this line is parked for now until a different `CEF4Delphi` bootstrap
    strategy is selected.
  - the separate `LCL` online regression discovered during this investigation
    is now closed:
    it was caused by the diagnostic logger itself (`gmlib_lcl_hybrid_trace.log`
    file locking), not by `OSM` online rendering.

## Next milestones

### Milestone 1: finish OSM pilot map core

- Finish validation/stabilization of the current OSM map core across
  `VCL`/`FMX`/`LCL`.
- Revisit the parked `CEF4Delphi` hybrid/offline line with a different
  bootstrap strategy; the current localhost external-script path is requested
  correctly but not executed by the host, so more worker-only debugging is not
  the right next step.
- Visible bounds stay event-only through `OnBoundsChanged`; no extra read-only
  Delphi property is planned for the current map layer.
- Decide whether any extra map-only interaction flags are still needed for v1,
  or whether the current surface is enough to freeze the map layer.
- Keep OSM bootstrap asset pipeline aligned with the current
  embedded/file-switch strategy across all wrappers.
- Keep `VCL` and `FMX MegaDemo` as the validation baseline before opening new
  slices or refactors.

### Milestone 2: expand OSM overlay surface after popup closure

- Extend marker options/events (draggable/visible/title/color and update path).
- Finish marker visual surface investigation in this order:
  - keep `Standard` marker as the baseline
  - validate `Color`
  - validate `Scale`
  - validate `GlyphText` without disturbing native marker anchoring
- Treat `Pin.ShapeVariant` as closed visual contract:
  - `Default/Classic`: rounded pin with tail
  - `Pill`: capsule body with tail
  - `Tag`: asymmetric tag-like body with tail
  - `Bubble`: rounded bubble without tail
- Keep `AnchorX/Y` documented as fine visual offsets only.
- Keep legacy `PopupText` out of active demo editing and route new popup work
  through `TOSMMap.Popups`.
- Treat advanced shadow options as `Pin`/`Dot`-specific.
- Add marker style variants:
  - `Standard`
  - `Pin`
  - `Dot`
- Add first marker-specific visual options:
  - `GlyphTextColor`
  - `HideDefaultCenterDot`
- Keep popup API frozen unless a concrete parity or runtime gap appears.
- Keep package boundaries stable (`MapLibCore` vs provider runtimes).

### Milestone 3: parity planning

- Decide practical parity targets between Google and OSM (do not force 1:1 API).
- Keep provider-specific features explicit instead of hidden fallback behavior.
- Define which shared abstractions can be elevated into `MapLibCore` safely.

## Cross-cutting

- Keep docs aligned with real implementation status (`README`, architecture, roadmap).
- Increase deterministic unit tests on shared/core behavior, especially around
  `OSMLib` and the offline runtime.
- Keep Delphi 11/12/13 and Lazarus compatibility validated during refactors.
- Keep optional `CEF4Delphi` bridge outside default mandatory runtime dependencies.
- `AirQualityMeterElement` remains future/experimental because Google documents it in `v=alpha`.

## OSM Offline Native Milestones (new track)

### Milestone A: offline API freeze

- `OfflineRegionManager` high-level contract is already in place:
  - `DownloadRegion(...)`
  - `DeleteRegion(...)`
  - `ListRegions(...)`
  - `GetStorageUsage(...)`
- hybrid policy enum is already in place:
  - `PreferOffline`
  - `PreferOnline`
  - `OfflineOnly`
- first offline events/state surface is already exposed (`OnOfflineError`,
  readiness/progress/coverage).

### Milestone B: embedded local serving

- embedded loopback HTTP server is already implemented in the shared runtime.
- no external listener and no dependency on external runtime binaries remain in
  the active path.
- current follow-up is validation hardening, not initial implementation.

### Milestone C: region catalog and storage

- persistent region index (bbox, zoom range, size, version, checksum).
- active-region selection and storage usage query.
- keep SQLite cache/runtime validation aligned across `VCL`, `FMX`, and `LCL`.

### Milestone D: download/update pipeline

- background/restartable downloads.
- integrity validation and transactional writes.
- update and cleanup policies (manual + size-based pruning).

### Milestone E: full hybrid behavior

- deterministic offline/online fallback behavior per policy.
- framework parity validation (`VCL/FMX/LCL/Android/iOS`).
- keep mobile offline pragmatic:
  - enough labels to remain usable in emergencies
  - avoid large glyph bundles by default


