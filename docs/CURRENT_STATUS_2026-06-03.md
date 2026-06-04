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
- `DragPanEnabled`
- `DragRotateEnabled`
- `DoubleClickZoomEnabled`
- `ScrollZoomEnabled`
- `KeyboardEnabled`
- `TouchZoomRotateEnabled`
- `TouchPitchEnabled`
- `CooperativeGesturesEnabled`
- `LastEventName`

### MegaDemo status

`Vcl/MegaDemo` and `Fmx/MegaDemo` were extended to validate:

- `bearing`
- `pitch`
- `minZoom`
- `maxZoom`
- main interaction flags
- filtered logging for move/render/data event families

The demos now use `LastEventName` to log the actual runtime event received.

### Important note

This round was done at code/documentation level only.

- No compilation was run in this session.
- No visual validation was run in this session.

### Re-entry checklist

1. Compile `VCL MegaDemo`.
2. Compile `FMX MegaDemo`.
3. Validate:
   - `Apply View`
   - `Fit Bounds`
   - `Apply Style`
   - interaction checkboxes
   - move/render/data logs

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
