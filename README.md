# Google Maps Library (GMLib) v3

Google Maps Library is an open source (MPL-2.0 license) cross-platform Delphi/Lazarus wrapper for the Google Maps JavaScript API.

The current codebase includes:

- a working Google backend (`TGMMap`) for `VCL`, `FMX`, and `LCL`
- a provider-neutral core (`uMapLib.Core.*`)
- provider-separated source layout (`Common/Vcl/Fmx/Lcl` split into `GM` and `OSM`)
- design-time packages and demos
- an initial `OSMLib` skeleton (MapLibre + OSM pilot), still in early stage

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

### Multi-provider status

- `MapLibCore` is already extracted and used by runtime packages.
- `GMLib` (Google provider) is functional and organized under provider folders.
- `OSMLib` package skeleton exists (pilot provider), but full runtime behavior is still pending.

## Demos

- VCL includes broad feature demos and the full-library `MegaDemo`.
- FMX includes runtime demos for the implemented Google slices.
- LCL support is available for Google runtime with CEF4Delphi bridge path.

## How to install

In Delphi:
- Open `GMLibGroup`.
- Compile `MapLibCore`, `GMLibRuntime`, `GMLibRuntime.Vcl` and `GMLibRuntime.FMX`.
- Compile and install `MapLibDesign.Vcl` (and FMX design package if used in your setup).
- Put the corresponding path for each platform in the library path:
  `...\lib\$(ProductVersion)\$(Platform)\Delphi`
- Put the corresponding source paths in the library path.

In Lazarus:
- Use the package files under `dpk/` as the canonical ones:
  - `dpk/GMLibRuntime.Lcl.lpk`
  - `dpk/GMLibDesign.Lcl.lpk`
- Compile/install in this order:
  1. Open and compile `GMLibRuntime.Lcl.lpk`
  2. Open and install `GMLibDesign.Lcl.lpk`
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
* [PasDoc](https://github.com/pasdoc/pasdoc/)
