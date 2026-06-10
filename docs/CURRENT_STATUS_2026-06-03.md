# Current Status - June 3, 2026

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

### Re-entry checklist

1. Decide whether weak marker properties should stay exposed in v1 or be
   trimmed from demos.
2. If the map layer is considered closed, continue with homogeneous offline
   runtime validation in `VCL`, `FMX`, and `LCL`.

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
