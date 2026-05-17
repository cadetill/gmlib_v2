# MapLib core start

This document defines the **first practical cut** to begin a shared core for a future provider family such as:

- `GMLib` for Google Maps
- `OSMLib` for OSM / MapLibre
- later providers if they become worth supporting

The purpose of this file is to keep the first move small and low-risk.

## Current implementation snapshot

The repo already contains a first extraction pass:

- `dpk/MapLibCore.dpk` created as shared runtime boundary
- `dpk/GMLibRuntime.dpk` now depends on `MapLibCore`
- `MapLibCore` no longer references `uGMLib.CoordinatePoint` from `Common/GM`
  and keeps only provider-neutral units
- `MapLibCore` now owns neutral base classes:
  - `uMapLib.Core.ApiObject`
  - `uMapLib.Core.Component`
- `uGMLib.Core.ApiObject` and `uGMLib.Core.Component` were reduced to
  compatibility facades in `GMLibRuntime`
- provider-neutral bridge/message types moved to:
  - `src/Common/uMapLib.Core.Types.pas`
  - `src/Common/uMapLib.Core.LatLng.pas`
- Google-specific enums/types extracted to:
  - `src/Common/GM/uGMLib.Google.Types.pas`
- `src/Common/uGMLib.Core.Types.pas` now acts mostly as compatibility facade
- empty `OSMLib` runtime skeleton started:
  - `dpk/OSMLibRuntime.dpk`
  - `dpk/OSMLibRuntime.dproj`
  - `src/Common/OSM/uOSMLib.Map.pas`
- initial VCL package skeleton started:
  - `dpk/OSMLibRuntime.Vcl.dpk`
  - `dpk/OSMLibRuntime.Vcl.dproj`
  - `dpk/OSMLibDesign.Vcl.dpk`
  - `dpk/OSMLibDesign.Vcl.dproj`
  - `src/Vcl/OSM/uOSMLib.Vcl.Map.pas`
  - `src/Vcl/OSM/uOSMLib.Vcl.Register.pas`
- first MapLibre bootstrap placeholders added:
  - `src/Vcl/OSM/uOSMLib.Vcl.MapBootstrap.pas`
  - `resources/js/osm/osmlib.map.html`
  - `resources/js/osm/osmlib.map.js`

What this means:

- the package boundary exists in real code, not only in docs
- the shared core boundary is stricter now (no direct `Common/GM` unit inside
  `MapLibCore`)
- `GMLib` is still the active provider implementation
- `OSMLib` exists only as bootstrap/package skeleton for now

## Objective

Do not start by implementing `OSMLib` features.

Start by separating the current codebase into:

- units that are already close to provider-neutral
- units that are clearly Google-specific
- units that look neutral but still need reshaping

## Initial classification

### Strong shared-core candidates

These are the best starting point:

- `src/Common/uGMLib.Core.Types.pas`
- `src/Common/uGMLib.Platform.Format.pas`
- `src/Common/uGMLib.Core.Messages.pas`
- `src/Common/uGMLib.Core.Bridge.pas`
- `src/Common/uGMLib.Core.BridgeRegistry.pas`
- `src/Common/uGMLib.BootstrapAssets.pas`

Why these first:

- they are already used across multiple areas
- they do not directly describe Google map features
- they are good pressure points for a second backend

### Shared with caution

These should be reviewed, not moved blindly:

- `src/Common/uGMLib.Core.ApiObject.pas`
- `src/Common/uGMLib.Core.Component.pas`
- `src/Common/GM/uGMLib.CoordinatePoint.pas`
- `src/Common/GM/uGMLib.Geometry.pas`

Reason:

- they are foundational, but some ownership and event semantics may still be too tied to the current GMLib shape
- `uGMLib.Geometry` also depends on `uGMLib.Polyline` and `uGMLib.Polygon`, so it needs a neutral path abstraction before it can move cleanly

### Keep in GMLib for now

These are not good first extraction targets:

- `src/Common/GM/uGMLib.Map.pas`
- `src/Common/GM/uGMLib.MapOptions.pas`
- `src/Common/GM/uGMLib.Marker.pas`
- `src/Common/GM/uGMLib.InfoWindow.pas`
- `src/Common/GM/uGMLib.Polyline.pas`
- `src/Common/GM/uGMLib.Polygon.pas`
- `src/Common/GM/uGMLib.Rectangle.pas`
- `src/Common/GM/uGMLib.Circle.pas`
- `src/Common/GM/uGMLib.GroundOverlay.pas`
- `src/Common/GM/uGMLib.Layers.pas`
- `src/Common/GM/uGMLib.GeoCode.pas`
- `src/Common/GM/uGMLib.Elevation.pas`
- `src/Common/GM/uGMLib.Routes.pas`

Reason:

- they expose provider-facing semantics
- they include Google-specific feature concepts
- they are more likely to create accidental abstraction debt if moved too early

## First package boundary

The first new boundary should be a **shared core package**, not a full provider package.

Target concept:

- `MapLibCore` or `MapLib.Core`

This package should initially contain only the strong shared-core candidates.

The Google backend should continue to build on top of it without changing its public API.

## First implementation tasks

1. Keep reducing `uGMLib.Core.Types` so it only exposes neutral contracts and backward-compat aliases.
2. Move remaining neutral primitives from `uGMLib.*` naming to `uMapLib.*` naming.
3. Add first browser bridge implementation for `OSMLib`.
4. Add the first minimal `Active` / `MapReady` flow in `TOSMMap`.
5. Wire bootstrap assets into embedded resources once the flow is stable enough.
6. Keep `GMLib` public API behavior unchanged while this extraction progresses.

## First non-goals

Do not do these in the first cut:

- routing abstraction
- geocoding abstraction
- provider-neutral map options
- offline tile storage
- provider-neutral layer model
- provider-neutral marker advanced content model

Those topics matter later, but they are not safe entry points.

## Success criteria for the first cut

The first cut is good enough when:

- the shared core exists as a real package boundary
- `GMLib` still builds and behaves as before
- no Google-specific units were moved just because they looked reusable
- the repo is ready for a future `OSMLib` skeleton


