# Current Status - June 3, 2026

## Update - June 16, 2026

The offline-region v1 flow was hardened after the first usable `BuildRegion`
round.

- `OfflineRegionManager` now validates requests before starting a job:
  - required `RegionId`
  - required `SourceUrl` / `RemoteTileTemplate`
  - coherent zoom range
  - coherent bounds
- region id collisions are now treated as a hard precondition failure:
  - if a region already exists in the catalog, callers must delete it first
  - `DownloadRegion(...)` / `BuildRegion(...)` now raise
    `EInvalidOpException` synchronously in that case
- `DeleteRegion(...)` no longer removes a region while a download/build job for
  that same region is active
- stale `*.tmp` and `*.building.mbtiles` files are now cleaned when the manager
  is created or when its storage base path changes
- `MegaDemo FMX` now exposes an explicit `Cancel Job` action for the active
  offline job
- cancellation is now reported distinctly from operational failures:
  - `402`: offline region download cancelled
  - `403`: offline region build cancelled
- the previous build-cancel SQLite lock issue was fixed by releasing the
  `MBTiles` writer before deleting the temporary `.building.mbtiles` file

Manual validation reported on June 16, 2026:

- rebuilding an existing region: correctly blocked
- redownloading an existing region: correctly blocked
- cancelling `BuildRegion` from `MegaDemo FMX`: now ends as clean `403`
  cancellation instead of a spurious file-lock `401`

## Update - June 15, 2026

The shared OSM offline/native work is now beyond cache warm-up only. A first
usable `MBTiles` region-building flow is working in `FMX`.

- `OfflineRegionManager.BuildRegion(...)` now builds a real `.mbtiles` region
  from the current viewport plus a zoom range.
- `MegaDemo FMX` now supports:
  - viewport tile-count estimation
  - v1 guard rails:
    - `<= 5000` normal
    - `5001..10000` warning
    - `> 10000` blocked
  - region build start from `Current viewport`
  - `Go To Region` for jumping to disconnected offline regions
  - delete/list flows validated manually
- offline region resolution now works by automatic coverage lookup rather than
  only by a single manually active region.

### V1 decisions

- region format is now `MBTiles` only
- mobile/desktop offline remains positioned as an emergency/fallback feature
- disconnected regions are acceptable in v1; UX is handled by `Go To Region`
- the default generated region id is based on viewport center, e.g.
  `region-n42_50-e1_51-z12`

### Build performance status

The `MBTiles` writer was reworked for bulk insert behavior:

- persistent SQLite connection
- reusable prepared queries
- batched commits
- bulk-insert pragmas
- throttled UI progress notifications
- temporary `.building.mbtiles` file with final rename on success
- tiles inserted without key/index maintenance during load
- unique tile index created at the end

Manual reference measurement reported in `FMX Win32`:

- region: `region-n42_50-e1_51-z12`
- zoom range: `8..18`
- estimated tiles: `5995`
- total time: `03:22`

This is considered sufficient for v1 even though some slowdown still appears
toward the end of the build.

No extra download concurrency is planned for `v1`; the current sequential
builder is considered acceptable for the emergency/fallback offline scope.

## Mobile bootstrap validation update

The shared bootstrap asset pipeline is now also validated on `FMX` mobile.

- `GMLib` and `OSMLib` both load bootstrap HTML/JS from embedded `RCDATA`
  resources extracted by `uGMLib.BootstrapAssets`.
- The Delphi non-Windows resource-loading path now uses `RT_RCDATA`, which was
  the missing piece for `Android/iOS`.
- `MAP_BOOTSTRAP_FROM_FILES` should be treated as a development-only switch and
  stays disabled in normal builds.
- `demos/Fmx/OSMMobileMinimal` now works as the minimal online validation demo
  for `OSMLib` on `FMX` mobile.
- `OSMLib` mobile offline/hybrid now also resolves `MapLibre CSS/JS` and the
  offline style template from embedded resources when those paths are not
  provided explicitly.
- default offline storage now points to a persistent app/user location instead
  of a temp folder.
- when no glyph corpus is configured, the shared vector runtime falls back to a
  no-label built-in style so that a first offline/mobile activation path still
  works without repo-local font folders.
- the `FMX Android` localhost runtime path also requires
  `android:usesCleartextTraffic="true"` so the embedded `WebView` can consume
  `http://127.0.0.1:...` tile/style requests.
- the mobile SQLite cache path now uses native path composition
  (`.../GMLib/OSM`) instead of passing `GMLib\OSM` as a single literal
  segment, which was creating an incorrect folder name on Android.
- the FireDAC SQLite path for `Android/iOS` now needs static linkage
  (`FireDAC.Phys.SQLiteWrapper.Stat` / `EngineLinkage=Static`) instead of
  relying on a dynamic `libsqlite.so` load.

## OSM map runtime

This session aligned the public Delphi surface of `TOSMMap` with the actual
runtime behavior in `resources/js/osm/osmlib.map.js`.

### Implemented Delphi -> JS commands

- `map.set_view`
- `map.set_style`
- `map.fit_bounds`
- `map.set_options`

### Implemented JS -> Delphi event flow

- View events:
  - `movestart`
  - `move`
  - `moveend`
  - `dragstart`
  - `drag`
  - `dragend`
  - `zoomstart`
  - `zoom`
  - `zoomend`
  - `rotatestart`
  - `rotate`
  - `rotateend`
  - `pitchstart`
  - `pitch`
  - `pitchend`
- Runtime/simple events:
  - `load`
  - `idle`
  - `render`
  - `resize`
  - `touch*`
  - `boxzoom*`
  - `wheel`
  - `data*`
  - `sourcedata*`
  - `styledata*`
  - `styleimagemissing`
  - `terrain`
  - `projectiontransition`
  - `webglcontextlost`
  - `webglcontextrestored`
- Extra event:
  - `boundschanged`

### New `TOSMMap` public surface

- `Bearing`
- `Pitch`
- `MinZoom`
- `MaxZoom`
- `MinPitch`
- `MaxPitch`
- `MaxBounds`
- `RenderWorldCopies`
- `DragPanEnabled`
- `DragRotateEnabled`
- `DoubleClickZoomEnabled`
- `ScrollZoomEnabled`
- `KeyboardEnabled`
- `TouchZoomRotateEnabled`
- `TouchPitchEnabled`
- `CooperativeGesturesEnabled`
- `OnCooperativeGesturePrevented`
- `LastEventName`

### State synchronization

The map now keeps Delphi-side view state synchronized from JS runtime view
events even when no Delphi event handler is assigned.

This applies to:

- `CenterLat`
- `CenterLng`
- `Zoom`
- `Bearing`
- `Pitch`

### MegaDemo status

`Vcl/MegaDemo` and `Fmx/MegaDemo` were extended to validate:

- `bearing`
- `pitch`
- `minZoom`
- `maxZoom`
- `minPitch`
- `maxPitch`
- `maxBounds`
- `renderWorldCopies`
- main interaction flags
- filtered logging for move/render/data event families

The demos now use `LastEventName` to log the actual runtime event received.

`Vcl/MegaDemo` also now includes:

- OpenFreeMap online style presets
- automatic disable of style presets / `Apply Style` in `Offline` and `Hybrid`
  mode
- `Use MaxBounds` toggle reusing the current north/south/east/west editors

### Important note

This document started as a code/documentation-only snapshot, but the current
state has since been manually compiled and validated in follow-up work.

- The latest reported status is: compile OK.
- Online OpenFreeMap presets were manually checked in `VCL`.
- `OSMMobileMinimal` has now also been manually validated again in
  `Android` for:
  - `Online`
  - `Hybrid`
  - `Offline` after cache warm-up

### Offline/native note

- the shared offline/native stack already includes a real
  `OfflineRegionManager`
- the shared vector runtime already includes an embedded localhost server for
  tiles/glyphs/style routing
- `VCL`, `FMX`, and `LCL` all expose the same public offline/hybrid OSM
  surface at wrapper level
- the shared runtime now also includes SQLite tile-cache persistence on the
  `FPC/LCL` path, so the main offline infrastructure gap is closed across the
  three desktop frameworks
- the first mobile-oriented offline/hybrid activation path no longer depends on
  repo-relative MapLibre/style assets

### Re-entry checklist

1. Decide whether weak marker properties should stay exposed in v1 or be
   trimmed from demos.
2. Continue with real mobile offline/hybrid validation in `FMX Android/iOS`,
   especially cache-warm (`Hybrid`) -> cache-only (`Offline`) behavior.

## OSM Markers snapshot

The active OSM slice is still `Markers`, but it is no longer only a first
baseline. The 2026-06-05 round moved it to a much more stable state.

### Current working state

- marker add/delete/clear remains functional
- map click can create markers
- `Draggable` works end-to-end
- `Visible` is applied in JS
- single-marker updates use `marker.set_options`
- drag events now refresh the Delphi-side marker position
- design-time marker persistence has been restored
- click-to-add no longer raises the previous bridge-side AV
- `Opacity` now works again in `Standard`, `Pin`, and `Dot`

### Current marker surface

- marker `Kind`:
  - `Standard`
  - `Pin`
  - `Dot`
- kind-specific options:
  - `StandardOptions`
  - `PinOptions`
  - `DotOptions`
- `Pin` typed enums:
  - `CornerStyle`
  - `ShapeVariant`
- current per-item events:
  - `OnClick`
  - `OnDblClick`
  - `OnMouseEnter`
  - `OnMouseLeave`
  - `OnMouseDown`
  - `OnMouseUp`
  - `OnDragStart`
  - `OnDrag`
  - `OnDragEnd`
- helper loading already exists through:
  - `LoadFromArray`
  - `LoadFromCSV`
  - `LoadFromDataSet`
- the core/runtime surface has already grown beyond the current MegaDemo UI:
  - advanced common visual options
  - expanded `StandardOptions`
  - expanded `PinOptions`
  - expanded `DotOptions`

### Wrapper status

- wrapper-level native colors already exist:
  - `VCL`: `TColor`
  - `FMX`: `TAlphaColor`
  - `LCL`: `TColor`
- CSS color storage remains internal to the common OSM model
- wrapper defaults now resolve to black for empty/invalid CSS:
  - `VCL/LCL`: `clBlack`
  - `FMX`: `TAlphaColorRec.Black`

### Recent fixes already applied

- marker `dragend` now updates Delphi-side state correctly
- marker `Title` is applied to the marker DOM as tooltip/`aria-label`
- FMX/VCL wrapper units for OSM markers were added and registered in runtime
  packages
- the previous `OSMMarkerKindToString` blocker is no longer relevant for the
  current branch state
- marker creation now avoids premature bridge sync while the collection item is
  still initializing
- MegaDemo VCL now accepts both local and invariant decimal formats for OSM
  marker `Double` editors
- `Pin.ShapeVariant` now has a stable first visual contract in JS:
  - `Default/Classic`: rounded pin with tail
  - `Pill`: capsule body with tail
  - `Tag`: asymmetric tag-like body with tail
  - `Bubble`: rounded bubble without tail

### Current weak spots

- `AnchorX/AnchorY` stay exposed as fine visual offsets, not as a primary
  anchor API
- `PopupText` is now legacy-facing convenience surface; the dedicated OSM
  `Popup` slice is the real popup API, and `PopupText` is no longer part of
  the active MegaDemo editing flow
- advanced shadow surface is now considered `Pin`/`Dot`-specific; `Standard`
  keeps only a lightweight compatibility toggle

### Suggested next step

1. Continue with marker-surface stabilization only if a real runtime or UX gap
   appears.
2. Otherwise move back to the offline/native OSM roadmap.

## OSM Popup status

The OSM provider now has a validated dedicated `Popup` slice.

### Current surface

- `TOSMMap.Popups`
- `TOSMPopupItem`
- `TOSMPopupOptions`
- current popup properties:
  - `Content`
  - `ContentType`
  - `Position`
  - `Visible`
  - `CloseButton`
  - `CloseOnClick`
  - `CloseOnMove`
  - `MaxWidth`
  - `AnchorObjectId`
- current popup methods:
  - `Open`
  - `OpenByObjectId`
  - `Close`
- current popup event:
  - `OnOpen`
  - `OnClose`

### Runtime coverage

- JS bridge commands already exist for:
  - `popup.add`
  - `popup.set_options`
  - `popup.remove`
  - `popup.clear`
- popups can currently work:
  - by explicit position
  - anchored to an existing marker by `AnchorObjectId`
- anchored popups are refreshed when the target marker is created, updated, or
  dragged
- anchored popups now close automatically if the anchor marker disappears
- popup visual presets are now exposed through typed Delphi options:
  - `ppsDefault`
  - `ppsNote`
  - `ppsWarning`
  - `ppsDark`
  - `ppsSuccess`
- popup content can now be sent either as trusted HTML or as plain text
  through typed Delphi options instead of always forcing HTML

### MegaDemo status

- VCL MegaDemo already includes a dedicated OSM `Popups` tab with CRUD and the
  editable popup surface
- FMX MegaDemo now also includes a dedicated OSM `Popups` tab with the same
  editable popup surface
- `Add Popup`, anchored popup behavior, close propagation, and
  `CloseOthersBeforeOpen` were manually validated in `VCL`
- the same popup CRUD and marker-click flow has now also been validated in
  `FMX`
- marker click in `VCL MegaDemo` now opens an anchored popup showing marker
  coordinates, following the same validation goal as the Google-side
  marker/InfoWindow flow
- marker click in `FMX MegaDemo` now opens an anchored popup showing marker
  coordinates and refreshes it after marker `dragend`
- popup creation/update remains batched in the core to avoid premature bridge
  synchronization during item initialization

### Current status

- popup free-position and anchored flows are validated in `VCL` and `FMX`
- anchor-loss behavior is now closed: when the anchor marker disappears, the
  popup closes
- `OnOpen` and `OnClose` are both routed from JS to Delphi
- popup API and MegaDemo coverage should now be treated as closed at the
  current OSM validation level

## OSM map core decision

- visible bounds stay event-only through `OnBoundsChanged`
- no read-only Delphi bounds property is planned for the current OSM map layer

## GM LCL color wrappers

The LCL Google Maps layer was completed to follow the same framework-native
color policy already used in `VCL` and `FMX`.

### New units

- `src/Lcl/GM/uGMLib.Lcl.Marker.pas`
- `src/Lcl/GM/uGMLib.Lcl.Polyline.pas`

### What they add

- `Marker` wrappers expose `TColor` for:
  - `PinOptions.BackgroundColor`
  - `PinOptions.BorderColor`
  - `PinOptions.GlyphColor`
  - `LabelOptions.BackgroundColor`
  - `LabelOptions.BorderColor`
  - `LabelOptions.TextColor`
- `Polyline` wrapper exposes `TColor` for:
  - `StrokeColor`

### Map integration updated

`src/Lcl/GM/uGMLib.Lcl.Map.pas` now uses:

- `TGMLclMarkers`
- `TGMLclPolylines`

and the Lazarus package files were updated:

- `dpk/GMLibRuntime.Lcl.pas`
- `dpk/GMLibRuntime.Lcl.lpk`

### Current policy

- `Common`: CSS `string`
- `VCL`: `TColor`
- `FMX`: `TAlphaColor`
- `LCL`: `TColor`

### Re-entry checklist

1. Compile `GMLibRuntime.Lcl`.
2. If something fails, review first:
   - `uGMLib.Lcl.Marker`
   - `uGMLib.Lcl.Polyline`
   - factory/cast changes in `uGMLib.Lcl.Map`
