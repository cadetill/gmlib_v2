# Roadmap

## Baseline already implemented

- legacy restart completed
- common architecture defined
- runtime packages created
- `TGMMap` base implemented
- bridge contracts defined
- `VCL + WebView2` adapter implemented
- `FMX + TWebBrowser` adapter implemented
- shared HTML/JS bootstrap implemented
- map options serialization implemented
- map events routing implemented
- demos for `VCL` and `FMX` created
- initial DUnitX tests added
- marker collection implemented as `TGMMap.Markers`
- marker slice closed with content modes, events, docs and aligned `VCL`/`FMX` demos
- `InfoWindows` slice closed
- first functional `Polyline` slice implemented
- `VCL` `PolylineLab` demo created with visual form
- `FMX` `PolylineLabFmx` demo created with visual form
- `VCL` `PolygonLab` demo created with visual form
- `FMX` `PolygonLabFmx` demo created with visual form
- `VCL` `RectangleLab` demo created with visual form
- `FMX` `RectangleLabFmx` demo created with visual form
- shared coordinate point base extracted to `uGMLib.CoordinatePoint`
- polygon path intermediate renamed to `TGMPolygonPath`
- rectangle bounds updates now batch through `TGMLatLngBounds.BeginUpdate/EndUpdate`
- rectangle runtime and demos validated in both `VCL` and `FMX`
- circle implementation validated in both `VCL` and `FMX`
- circle lab demos expanded with center/radius inputs, flags and event logging
- GeoCodeLab demos created in `VCL` and `FMX`
- GeoCode validated in both `VCL` and `FMX`
- Elevation service implemented with matching `VCL` and `FMX` lab demos
- `TGMElevations` validated as async map-associated service for point and path elevation queries
- current validated slices are documented and closed: `Markers`, `Circle`, `GeoCode`, `Elevation` and `Routes`
- Routes service implemented with matching `VCL` and `FMX` lab demos
- `TGMRoutes` validated as async map-associated service with route request/response handling and polyline extraction helper
- `RoutesLab` demo accepts mixed waypoint input using `A|address` or `L|lat,lng`
- initial Delphi 11 compatibility fixes applied
- LCL runtime package scaffold created for the Lazarus port (`.lpk`)
- LCL visual map host added as `TGMLibLclMap`
- LCL map options specialized with native `TColor` background support

## Next milestone

- infrastructure refactors already applied and validated:
  - protect bridge and response `FromJson` calls with controlled error handling
  - fix the base `Assign` contract in `TGMLibApiObject`
  - review bridge lifecycle and callback detachment in `SetBridge`
  - consolidate repeated `importLibrary()` usage behind `window.gmlib.getLib(name)`
  - provide a single transport envelope helper per backend
  - document and keep the bootstrap `map_ids` and `onerror` rules
- consolidate current documentation with implemented API
- centralize on-demand JS library loading behind a single `importLibrary()` helper
- keep transport selection in the host bridge layer, not as browser detection spread through JS
- document bootstrap HTML rules (`map_ids` when available, `onerror` on the Google script)
- improve resource packaging so runtime does not depend on repo files
- document and keep optional CEF bridge outside the default runtime package
- keep the closed slices fixed unless a regression appears in `MarkerLab`, `CircleLab`, `GeoCodeLab`, `ElevationLab` or `RoutesLab`
- keep `RoutesLab` fixed unless a regression appears in the route flow
- expand automated tests beyond current map/marker/polyline/polygon coverage
- decide whether to expose framework-specific wrappers for `PolygonPath`
- continue Delphi 11 validation when the environment is available
- current debug target: `demos/Vcl/Edge/Project2` and general VCL integration/build hygiene
- after the closed Elevation/Routes cycle, continue reviewing the shared codebase for the following refactors:
  - protect bridge `FromJson` calls with controlled error handling
  - fix the base `Assign` contract in `TGMLibApiObject`
  - review bridge lifecycle and callback detachment in `SetBridge`
  - consolidate repeated `importLibrary()` usage behind `window.gmlib.getLib(name)`
  - consider a single transport envelope helper per backend
  - reduce duplicated serialization and overlay boilerplate where it is already stable

## Next functional slices

### Slice 1

- Lazarus design-time bootstrap:
  - `GMLibDesign.Lcl.lpk`
  - registry for `TGMLibLclMap`
  - `src/Lcl` visual map host backed by CEF4Delphi

### Slice 2

- reserved

### Slice 3

- reserved

## Cross-cutting work

- package embedded HTML/JS resources (implemented via embedded resources extracted to a temp directory at runtime)
- expand PasDoc coverage
- improve design-time usability
- add more unit tests where behavior is deterministic
- keep `VCL` and `FMX` demos aligned
- keep overlays work aligned with the current map/marker/info window patterns
- keep Delphi 11 compatibility in mind while new slices are added
- consider an experimental `AirQualityMeterElement` slice in the future; the Google Maps JavaScript API currently documents it only in the `v=alpha` channel, so it should stay out of the stable core for now
