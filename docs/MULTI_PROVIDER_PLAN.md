# Multi-provider plan

This document describes a practical path to start a second map-provider backend on top of the current GMLib codebase.

The goal is **not** to force Google Maps semantics onto every provider.
The goal is to reuse the parts that are genuinely common, while keeping each backend explicit and maintainable.

## Scope

Start with **one pilot provider** and validate the architecture before attempting more.

Recommended pilot order:

1. `Mapbox`
2. `HERE`
3. `OpenStreetMap stack` (`Leaflet` / `MapLibre` + `Nominatim` + `OSRM` or equivalent)
4. `TomTom`
5. `ArcGIS`

For this plan, the pilot provider is **Mapbox** because it gives a coherent modern stack and a clear separation between:

- base map rendering
- markers and overlays
- styling
- geocoding
- routing

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

- `TMBMap`
- `TMBMapOptions`
- `TMBMarkers`
- `TMBRoutes`

or, if the provider is not yet fixed in naming:

- `TMapboxMap`
- `TMapboxMapOptions`
- `TMapboxMarkers`
- `TMapboxRoutes`

The important point is that the new backend must be **explicitly separate** from the Google backend.

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

Exit criteria:

- no code yet, only a signed-off plan

### Phase 1: backend skeleton

Deliverables:

- new common-facing component class
- new provider-specific runtime package
- new provider-specific design-time package
- new bootstrap HTML/JS pair
- minimal "map ready" flow
- minimal `Activate` / `Deactivate` flow
- minimal options serialization

Exit criteria:

- a blank map can be created and shown
- the component can initialize and tear down cleanly

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
2. create the skeleton package structure
3. implement map activation and basic rendering
4. implement markers and overlays
5. implement routes and geocoding
6. add provider-specific extras
7. add demos
8. write docs and tests

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
