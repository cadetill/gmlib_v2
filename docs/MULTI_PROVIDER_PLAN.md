# Multi-provider plan

This document describes a practical path to start a second map-provider backend on top of the current GMLib codebase.

The goal is **not** to force Google Maps semantics onto every provider.
The goal is to reuse the parts that are genuinely common, while keeping each backend explicit and maintainable.

## Scope

Start with **one pilot provider** and validate the architecture before attempting more.

Recommended pilot order:

1. `OSMLib` on top of `MapLibre + OSM`
2. `Mapbox`
3. `HERE`
4. `TomTom`
5. `ArcGIS`

For this plan, the pilot provider is **OSMLib** built on top of **MapLibre + OSM** because it validates the hardest and most valuable architectural difference early:

- provider separation from Google-specific APIs
- open data instead of Google-managed content
- offline-capable map rendering
- style / tile / source control
- future routing and geocoding composition without forcing Google semantics

## Progress status (current repo)

Completed foundation work:

- shared package boundary added: `MapLibCore`
- `GMLibRuntime` now depends on `MapLibCore`
- first neutral type split implemented (`uMapLib.Core.Types`, `uMapLib.Core.LatLng`)
- neutral base object/component split implemented (`uMapLib.Core.ApiObject`, `uMapLib.Core.Component`)
- first Google-specific type split implemented (`uGMLib.Google.Types`)
- `MapLibCore` cleaned to avoid direct `Common/GM` unit references
- `OSMLibRuntime` package skeleton created with initial `TOSMMap` placeholder
- `OSMLib` VCL runtime/design-time package skeleton created
- first MapLibre bootstrap HTML/JS placeholders added for the VCL path
- single public VCL design-time aggregator introduced: `MapLibDesign.Vcl`
- single public FMX design-time aggregator introduced: `MapLibDesign.Fmx`
- single public LCL design-time package introduced: `MapLibDesign.Lcl`
- legacy design packages removed from active package flow:
  - `GMLibDesign.Fmx`
  - `GMLibDesign.Lcl`
  - `OSMLibDesign.Vcl`
- `GMLibGroup.groupproj` already includes the current `OSMLib` package projects
- JS bridge namespace is unified to `window.maplib` for both providers
- provider folder normalization started:
  - `src/Common/GM`, `src/Common/OSM`
  - `src/Vcl/GM`, `src/Vcl/OSM`
  - `src/Fmx/GM`, `src/Fmx/OSM`
  - `src/Lcl/GM`, `src/Lcl/OSM`
- core namespace cleanup completed:
  - internal references migrated to `uMapLib.Core.*`
  - legacy `uGMLib.Core.*` wrappers removed
  - temporary legacy aliases removed from `uMapLib.Core.*`

Current OSM status and next architectural shift:

- map/bootstrap/event baseline exists in `VCL/FMX/LCL`.
- `MapMode` (`online/offline/hybrid`) and initial offline wiring exist.
- current PMTiles external-process path is considered transitional.
- next target is offline-native runtime for apps (especially `Android/iOS`):
  - embedded `OfflineRegionManager`
  - tiny loopback-only local HTTP serving for runtime assets
  - no mandatory external executable dependency in final app runtime.

## Guiding principles

- Keep the current Google backend untouched unless the change is genuinely shared.
- Do not introduce a fake "lowest common denominator" API if it makes the design worse.
- Split the work between:
  - truly shared primitives
  - provider-specific capabilities
  - optional features that only exist on some providers
- Prefer explicit components over hidden runtime switches.
- Add demos early so the design is validated through actual usage, not only through interfaces.

## What can be shared

These pieces are good candidates for reuse:

- coordinate and bounds types
- shared geometry helpers
- overlay / polyline / polygon / marker patterns where the semantics match
- map-state bookkeeping
- design-time patterns
- bridge contracts and transport envelopes
- asynchronous request tracking
- generic event plumbing

## What should stay provider-specific

These are usually not 1:1 across providers:

- `MapId`
- `AdvancedMarkerElement`
- Google-only layer classes
- KML
- Elevation service
- route request/response shapes
- geocoding response shapes
- traffic / transit / bicycling presentation layers
- provider-specific style and source configuration

## Proposed architecture

Introduce a second root component, separate from `TGMMap`.

Example naming:

- `TOSMMap`
- `TOSMMapOptions`
- `TOSMMarkers`
- `TOSMRoutes`

The important point is that the new backend must be **explicitly separate** from the Google backend.

## First extraction target

The first technical move should be to define a **small neutral core**, not to start with routing or offline packages.

Good candidates from the current repo are:

- `uGMLib.Core.Types`
- `uGMLib.Platform.Format`
- `uGMLib.Core.Messages`
- `uGMLib.Core.Bridge`
- `uGMLib.Core.BridgeRegistry`
- `uGMLib.BootstrapAssets`
- selected base abstractions from `uGMLib.Core.ApiObject` and `uGMLib.Core.Component`

These units are not guaranteed to move 1:1 as they are, but they are the first review set because they are the closest thing to a provider-neutral foundation already present in `GMLib`.

`uGMLib.Geometry` is a good example of why this needs validation by compilation, not only by reading: it looks neutral at first glance, but today still depends on `uGMLib.Polyline` and `uGMLib.Polygon`, so it should stay with the Google runtime until a neutral path abstraction exists.

## Phases

### Phase 0: architectural freeze

Deliverables:

- confirm the pilot provider
- define the new root component name
- define the shared vs provider-specific split
- decide the package layout
- define the JavaScript bootstrap strategy for the new backend
- decide whether the backend uses:
  - the same browser bridge infrastructure
  - a new bootstrap HTML file
  - a shared JS helper layer
- define the initial neutral-core inventory taken from the current `src/Common`

Exit criteria:

- no code yet, only a signed-off plan

### Phase 0.5: extraction inventory

Deliverables:

- classify current common units into:
  - neutral core candidates
  - Google-specific units
  - undecided units that need reshaping
- define the first package boundary for the neutral core
- define naming:
  - shared family name
  - Google provider name
  - OSM provider name

Exit criteria:

- the first move is obvious and low-risk
- no provider-specific code is moved into the core by accident

### Phase 1: backend skeleton

Deliverables:

- neutral core package skeleton
- new `OSMLib` runtime package
- new `OSMLib` design-time package
- new bootstrap HTML/JS pair for MapLibre
- minimal "map ready" flow
- minimal `Activate` / `Deactivate` flow
- minimal style / source bootstrap

Exit criteria:

- a blank map can be created and shown
- the component can initialize and tear down cleanly
- `GMLib` still compiles after the first extraction

Current status:

- `Phase 1` is started but not complete
- package skeleton exists, runtime behavior does not yet

### Phase 2: map core

Deliverables:

- center / zoom / bounds
- map events
- map options
- basic interaction flags
- provider-specific styling or source options

Exit criteria:

- the map behaves like a real control, not just a static browser surface
- state changes can be pushed from Delphi to JS

### Phase 3: overlays and markers

Deliverables:

- markers
- info windows or popups
- polylines
- polygons
- rectangles
- circles
- image overlays, if supported by the provider

Exit criteria:

- the new backend can render the core geometry/overlay set used by GMLib demos
- basic CRUD and visibility are working

### Phase 4: services

Deliverables:

- geocoding
- reverse geocoding
- routing
- optional elevation if the provider supports it

Exit criteria:

- the async request model is stable
- request/response handling is not leaking provider internals into the common layer

### Phase 5: provider-specific extras

Deliverables:

- traffic-like layers if the provider supports them
- transit-like overlays if the provider supports them
- custom style controls
- provider-specific features that are worth exposing

Exit criteria:

- only useful features are added
- no "API-shaped bloat" for features that do not exist in the provider

### Phase 6: demos

Deliverables:

- minimal map demo
- marker demo
- routes demo
- one integrated mega demo if the backend proves stable enough

Exit criteria:

- the backend can be exercised without reading source code
- the demo set makes the provider differences obvious

### Phase 7: docs and validation

Deliverables:

- README updates
- provider comparison updates
- installation instructions
- limitations section
- deterministic tests where possible

Exit criteria:

- the new backend is understandable to a third party
- the docs clearly state what is shared and what is provider-specific

## Implementation order

Recommended order for the pilot:

1. freeze architecture
2. classify existing common units
3. create the neutral core package skeleton
4. keep `GMLib` compiling on top of that skeleton
5. create `OSMLib` runtime and design-time packages
6. implement map activation and basic rendering
7. implement markers and overlays
8. implement routes and geocoding
9. add provider-specific extras
10. add demos
11. write docs and tests

## Immediate next step in this repo

The first concrete step for this codebase should be:

1. create a small shared-core namespace/package boundary without changing public `GMLib` behavior
2. move or wrap only the clearly neutral units listed above
3. keep all map, layer, route, geocode and provider-facing classes in `GMLib`
4. once `GMLib` still builds, create the empty `OSMLib` skeleton

This keeps risk low and forces the shared core to stay honest.

## Risks

- Trying to reuse Google-specific abstractions too aggressively.
- Hiding provider differences behind a generic API that becomes awkward very quickly.
- Mixing the new backend with the current Google backend in the same component root.
- Expanding the scope before the first provider is fully usable.
- Underestimating the browser / JS bootstrap differences between providers.

## Definition of done for the pilot

The pilot backend is good enough when:

- it can be built from source
- it can show a working map
- it can create and manage core overlays
- it can execute at least one service flow
- it has at least one demo
- its docs explain what works and what does not

If that is achieved, the second provider can be added using the same pattern with far less risk.


