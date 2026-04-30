# Google Maps Library (GMLib) v2

Google Maps Library is an open source (MPL-2.0 license) cross-platform Delphi/Lazarus wrapper for the Google Maps JavaScript API.

The current codebase includes a working `TGMMap` foundation, `VCL` (TEdgeBrowser/CEF4Delphi), `FMX` (TWebBrowser/CEF4Delphi), and `LCL` (CEF4Delphi) platform adapters, a shared JavaScript bootstrap, design-time packages, demos, and several implemented slices.

GMLib was developed and tested on Delphi 11, 12 and 13, and Lazarus 4.6.

GMLib demos have been tested in Windows 10 and Windows 11.

For more information about CEF4Delphi see [their repo](https://github.com/salvadordf/CEF4Delphi).

## Google Maps Requirements

Google Maps imposes several requirements for normal map usage:

- You need an `API Key` to show a map without a watermark.
- You need a `Map ID` for several components, such as `AdvancedMarkerElement`.

For more information and to create your `API Key` and `Map ID`, visit the [Google Cloud Console](https://console.cloud.google.com/).

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

## Demos

There are demos for practically everything in VCL and FMX.

There is also a full-library demo, MegaDemo, in VCL.

# How to install

In Delphi:
- Open `GMLibGroup`.
- Compile `GMLibRuntime`, `GMLibRuntime.Vcl` and `GMLibRuntime.FMx`.
- Compile and install `GMLibDesign.Vcl` and `GMLibDesign.FMx`.
- Put the corresponding path for each platform in the library path:
  `...\lib\$(ProductVersion)\$(Platform)\Delphi`
- Put the corresponding source paths in the library path.

In Lazarus:
- Open `GMLibRuntimeGroup`.
- Compile `GMLibRuntime`.
- Install `GMLibDesign`.

## Docs

- Architecture: [`docs/ARCHITECTURE.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/ARCHITECTURE.md)
- CEF integration: [`docs/CEF.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/CEF.md)
- Roadmap: [`docs/ROADMAP.md`](/D:/cadetill/Documents/GitHub/gmlib_v2/docs/ROADMAP.md)

## Links

* [CEF4Delphi](https://github.com/salvadordf/CEF4Delphi)
* [PasDoc](https://github.com/pasdoc/pasdoc/)
