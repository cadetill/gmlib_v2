# Google Maps Library (GMLib) v3

Google Maps Library is an open source (MPL-2.0 license) cross-platform Delphi/Lazarus wrapper for the Google Maps JavaScript API.

The current codebase includes:

- a working Google backend (`TGMMap`) for `VCL`, `FMX`, and `LCL`
- a provider-neutral core (`uMapLib.Core.*`)
- provider-separated source layout (`Common/Vcl/Fmx/Lcl` split into `GM` and `OSM`)
- design-time packages and demos
- an `OSMLib` pilot backend (MapLibre + OSM) with working map/events and first marker slice

GMLib was developed and tested on Delphi 11, 12 and 13, and Lazarus 4.6.

GMLib demos have been tested in Windows 10 and Windows 11.

For more information about CEF4Delphi see [their repo](https://github.com/salvadordf/CEF4Delphi).

## Google Maps Requirements

Google Maps imposes several requirements for normal map usage:

- You need an `API Key` to show a map without a watermark.
- You need a `Map ID` for several components, such as `AdvancedMarkerElement`.

For more information and to create your `API Key` and `Map ID`, visit the [Google Cloud Console](https://console.cloud.google.com/).

You can put these credentials directly into the component or into environment variables called GOOGLE_MAPS_API_KEY and GOOGLE_MAPS_MAP_ID respectively.

*This is a Google Maps platform restriction, not a GMLib one.*

## OSM / MapLibre Requirements

`OSMLib` does not require a Google-style API key to show a map.

Its current runtime is based on `MapLibre GL JS` and an OSM-compatible style /
tiles setup. Depending on the provider you choose, you may still need:

- a valid `Style URL`
- a valid vector tile template in `RemoteTileTemplate`
- a provider API key if that provider requires one

For offline or hybrid runtime validation, the current codebase also expects:

- `maplibre-gl.css`
- `maplibre-gl.js`
- `resources/js/osm/offline/style.template.json`

*These are runtime/provider requirements of the current `OSMLib` implementation,
not a Google-style platform restriction.*

Bootstrap HTML/JS assets for both `GMLib` and `OSMLib` are expected to be
consumed from embedded resources extracted by the runtime. The
`MAP_BOOTSTRAP_FROM_FILES` switch in `gmlib.inc` is a development-only
override and should stay disabled for normal packaging, especially on
`Android/iOS`.

## Current Status

The following Google Maps API classes are currently implemented:

- [google.maps.Map](https://developers.google.com/maps/documentation/javascript/reference/map) and associated classes to display a map.
- Basic layers grouped under `TGMMap.Layers`
  - [google.maps.TrafficLayer](https://developers.google.com/maps/documentation/javascript/reference/map#TrafficLayer)
  - [google.maps.TransitLayer](https://developers.google.com/maps/documentation/javascript/reference/map#TransitLayer)
  - [google.maps.BicyclingLayer](https://developers.google.com/maps/documentation/javascript/reference/map#BicyclingLayer)
  - [google.maps.KmlLayer](https://developers.google.com/maps/documentation/javascript/reference/kml)
- [google.maps.marker.AdvancedMarkerElement](https://developers.google.com/maps/documentation/javascript/reference/advanced-markers) and associated classes to display a marker.
- [google.maps.InfoWindow](https://developers.google.com/maps/documentation/javascript/reference/info-window) and associated classes to display an info window.
- [google.maps.Polyline](https://developers.google.com/maps/documentation/javascript/reference/polygon#Polyline) and associated classes to display a polyline.
- [google.maps.Polygon](https://developers.google.com/maps/documentation/javascript/reference/polygon#Polygon) and associated classes to display a polygon.
- [google.maps.Rectangle](https://developers.google.com/maps/documentation/javascript/reference/polygon#Rectangle) and associated classes to display a rectangle.
- [google.maps.Circle](https://developers.google.com/maps/documentation/javascript/reference/polygon#Circle) and associated classes to display a circle.
- [google.maps.GroundOverlay](https://developers.google.com/maps/documentation/javascript/reference/image-overlay#GroundOverlay) and associated classes to display a GroundOverlay.
- [google.maps.Geocoder](https://developers.google.com/maps/documentation/javascript/reference/geocoder) and associated classes to convert an address to a `LatLng` and vice versa.
- [google.maps.ElevationService](https://developers.google.com/maps/documentation/javascript/reference/elevation) and associated classes for requesting elevation data.
- [google.maps.routes.Route](https://developers.google.com/maps/documentation/javascript/reference/route) and associated classes for route requests.

The following OSM / MapLibre runtime surface is currently implemented:

- [MapLibre GL JS `Map`](https://maplibre.org/maplibre-gl-js/docs/API/classes/Map/) and associated map lifecycle/bootstrap flow in `VCL`, `FMX`, and `LCL`.
- Overlay slice:
  - [MapLibre GL JS `Marker`](https://maplibre.org/maplibre-gl-js/docs/API/classes/Marker/)
  - [MapLibre GL JS `Popup`](https://maplibre.org/maplibre-gl-js/docs/API/classes/Popup/)

### Multi-provider status

- `MapLibCore` is already extracted and used by runtime packages.
- `GMLib` (Google provider) is functional and organized under provider folders.
- `OSMLib` (pilot provider) currently includes:
  - map activation/bootstrap + map event flow in `VCL`, `FMX`, and `LCL`
  - style switching + fit bounds + center/zoom/bearing/pitch sync
  - map restrictions/options:
    - `min/max zoom`
    - `min/max pitch`
    - `max bounds`
    - `renderWorldCopies`
  - marker collection with per-item events (`OnClick`, `OnDblClick`, `OnMouseEnter`, `OnMouseLeave`, `OnMouseDown`, `OnMouseUp`, `OnDragStart`, `OnDrag`, `OnDragEnd`)
  - marker kinds `Standard`, `Pin`, and `Dot` with per-kind options classes
  - `Pin` visual selectors now exposed as enums instead of free strings
  - `Pin.ShapeVariant` is now treated as a closed visual contract:
    - `Default/Classic`: rounded pin with tail
    - `Pill`: capsule body with tail
    - `Tag`: asymmetric tag-like body with tail
    - `Bubble`: rounded bubble without tail
  - `AnchorX/Y` are treated as fine visual offsets, not as a primary anchor API
  - legacy `PopupText` remains only as compatibility surface; active popup work
    should go through `TOSMMap.Popups`
  - advanced shadow surface is treated as `Pin`/`Dot`-specific; `Standard`
    keeps only a lightweight compatibility toggle
  - interaction toggles (`DragPan`, `DragRotate`, `DoubleClickZoom`, `ScrollZoom`, `Keyboard`, `TouchZoomRotate`, `TouchPitch`, `CooperativeGestures`)
  - `cooperativegestureprevented` routed to Delphi/Lazarus
  - validated `VCL` MegaDemo OSM marker/offline flow
  - design-time marker persistence restored after typed wrapper refactor
  - click-to-add marker flow stabilized after creation/update notification fixes
  - MegaDemo OSM marker editors now accept local or invariant decimal input for doubles
  - first dedicated OSM `Popup` slice added in core and JS runtime
  - validated OSM `Popup` slice with:
    - free-position popup
    - marker-anchored popup
    - `OnOpen` / `OnClose`
    - `CloseOnMove`
    - `ContentType` (`HTML` / plain text)
    - typed visual presets
    - closed anchor-loss rule (popup closes if the anchor marker disappears)
  - VCL MegaDemo includes an OSM `Popups` tab with CRUD/testing UI
  - FMX MegaDemo includes an OSM `Popups` tab with the same popup CRUD/testing
    surface
  - marker click in `VCL MegaDemo` opens an anchored popup showing the current
    marker coordinates
  - marker click in `FMX MegaDemo` also opens an anchored popup showing the
    current marker coordinates and refreshes it after `dragend`
  - popup creation lifecycle was hardened with the same batching approach used
    for markers to avoid premature bridge sync during `Add Popup`
  - the popup slice should now be treated as functionally closed at the current
    OSM validation level
  - marker core/runtime surface is currently ahead of MegaDemo UI coverage;
    part of the newly added marker options still needs to be exposed in the demo
  - current offline/hybrid runtime surface:
    - `MapMode`
    - `OfflinePolicy`
    - `OfflineStoragePath`
    - `RemoteTileTemplate`
    - `StyleTemplateFileName`
    - `GlyphsRootPath`
    - `MapLibreCssUrl`
    - `MapLibreJsUrl`
  - native offline pieces already implemented in shared code:
    - `OfflineRegionManager`
    - embedded localhost runtime server
    - `StyleProvider`
    - `TileResolver`
    - `VectorRuntime`
    - `SqliteTileStore`
  - embedded localhost serving and SQLite tile-cache persistence are now
    aligned across `VCL`, `FMX`, and `LCL/FPC`
  - `GMLibRuntime.Lcl` compile path is back in sync with the current shared
    runtime layer

### OSM hybrid/offline runtime notes

- The current vector runtime expects a direct XYZ template in `RemoteTileTemplate`.
- `OpenFreeMap` works for runtime validation with:
  `https://tiles.openfreemap.org/planet/latest/{z}/{x}/{y}.pbf`
- `MapTiler` has also been validated with:
  `https://api.maptiler.com/tiles/v3/{z}/{x}/{y}.pbf?key=YOUR_API_KEY`
- Not every vector tileset is suitable as a full basemap. Example: thematic
  sources such as `landform` may legitimately return sparse or empty tiles for
  many coordinates.

## Demos

- VCL includes broad feature demos and the full-library `MegaDemo`.
- FMX includes runtime demos for the implemented Google slices, and the OSM
  `MegaDemo` is available as the active OSM validation surface too.
- `demos/Fmx/OSMMobileMinimal` now acts as the minimal online validation demo
  for `OSMLib` on `FMX` mobile (`Android/iOS`), using the embedded bootstrap
  asset pipeline.
- OSM visual validation is currently centered on `demos/Vcl/MegaDemo` and
  `demos/Fmx/MegaDemo`, which are the reference baselines for
  online/offline/hybrid behavior and for the current camera/interaction surface.
- LCL also exposes the OSM offline/hybrid surface, including the embedded
  localhost runtime path and SQLite tile-cache persistence in the shared layer.

## How to install

In Delphi:
- Open `GMLibGroup`.
- Compile `MapLibCore`, `GMLibRuntime`, `GMLibRuntime.Vcl` and `GMLibRuntime.FMX`.
- Compile and install design packages:
  - `MapLibDesign.Vcl`
  - `MapLibDesign.Fmx`
- Put the corresponding path for each platform in the library path:
  `...\lib\$(ProductVersion)\$(Platform)\Delphi`
- Put the corresponding source paths in the library path.

In Lazarus:
- Use the package files under `dpk/` as the canonical ones:
  - `dpk/GMLibRuntime.Lcl.lpk`
  - `dpk/MapLibDesign.Lcl.lpk`
- Compile/install in this order:
  1. Open and compile `GMLibRuntime.Lcl.lpk`
  2. Open and install `MapLibDesign.Lcl.lpk`
- If Lazarus generates `.lpk` files under `src/`, treat them as local/temporary artifacts (do not version them).
- If package links get out of sync, ensure Lazarus points to `dpk/*.lpk` (not `src/**` copies).

## Docs

- Architecture: [`docs/ARCHITECTURE.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/ARCHITECTURE.md)
- CEF integration: [`docs/CEF.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/CEF.md)
- Roadmap: [`docs/ROADMAP.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/ROADMAP.md)
- Multi-provider plan: [`docs/MULTI_PROVIDER_PLAN.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/MULTI_PROVIDER_PLAN.md)
- Shared core start: [`docs/MAPLIB_CORE_START.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/MAPLIB_CORE_START.md)

## Links

* [CEF4Delphi](https://github.com/salvadordf/CEF4Delphi)
* [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/)
* [PasDoc](https://github.com/pasdoc/pasdoc/)
