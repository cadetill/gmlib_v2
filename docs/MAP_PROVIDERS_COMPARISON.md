# Map provider comparison

This document compares the current GMLib feature set with a few popular map platforms.

It is a **feature-coverage matrix**, not a pricing, licensing, or quality ranking.

Legend:

- `N` = native / first-class in the official docs
- `C` = possible, but usually through a separate service, plugin, data layer, or custom code
- `-` = no direct equivalent found in the official docs we checked

Note:

- `OpenStreetMap` is shown as a practical stack (`Leaflet` / `MapLibre` + `Nominatim` + `OSRM` or similar), because OSM is data, not a single SDK.
- Some cells are intentionally conservative. A `C` cell usually means "you can build it, but it is not a 1:1 class or service in that ecosystem".

## Core map and overlays

| GMLib feature | Google Maps | OSM stack | Mapbox | HERE | TomTom | ArcGIS |
|---|---:|---:|---:|---:|---:|---:|
| Base map / map options / events | N | N | N | N | N | N |
| Markers | N | N | N | N | N | N |
| Info windows / popups | N | N | N | C | C | N |
| Polylines | N | N | N | N | N | N |
| Polygons | N | N | N | N | N | N |
| Rectangles | N | N | C | N | C | N |
| Circles | N | N | N | N | C | N |
| Ground overlay / image overlay | N | N | N | C | N | N |

## Layers, services, and helpers

| GMLib feature | Google Maps | OSM stack | Mapbox | HERE | TomTom | ArcGIS |
|---|---:|---:|---:|---:|---:|---:|
| Traffic layer | N | C | N | N | N | C |
| Transit layer | N | C | C | N | C | C |
| Bicycling layer | N | C | C | C | C | C |
| KML layer | N | C | C | C | C | N |
| Geocoding / reverse geocoding | N | C | N | N | N | N |
| Elevation | N | C | C | C | C | C |
| Routes / directions | N | C | N | N | N | N |
| Geometry helpers | N | C | C | C | C | C |
| Marker CSV/DataSet import | C | C | C | C | C | C |

## Practical reading

- **Closest 1:1 match to the current GMLib feature set**: Google Maps.
- **Most open stack**: OpenStreetMap, but it usually means composing several pieces instead of using one SDK.
- **Best fit for style-heavy vector maps**: Mapbox.
- **Strong routing and traffic platforms**: HERE and TomTom.
- **Strong GIS and enterprise layer model**: ArcGIS.

## References

- Google Maps JavaScript API:
  - https://developers.google.com/maps/documentation/javascript
  - https://developers.google.com/maps/documentation/javascript/shapes
  - https://developers.google.com/maps/documentation/javascript/reference/map
  - https://developers.google.com/maps/documentation/javascript/reference/kml
  - https://developers.google.com/maps/documentation/javascript/reference/geometry
- Leaflet:
  - https://leafletjs.com/
  - https://leafletjs.com/reference.html
- OpenStreetMap geocoding / routing ecosystem:
  - https://wiki.openstreetmap.org/wiki/Nominatim
  - https://project-osrm.org/docs/
- Mapbox:
  - https://docs.mapbox.com/mapbox-gl-js/
  - https://docs.mapbox.com/mapbox-gl-js/guides/styles/work-with-layers/
  - https://docs.mapbox.com/mapbox-gl-js/api/sources/
  - https://docs.mapbox.com/api/search/
  - https://docs.mapbox.com/api/navigation/directions/
  - https://docs.mapbox.com/data/tilesets/guides/access-elevation-data/
  - https://docs.mapbox.com/data/tilesets/reference/mapbox-traffic-v1/
- HERE:
  - https://developer.here.com/
  - https://developer.here.com/coverage-info.html
  - https://developer.here.com/develop/azure
- TomTom:
  - https://developer.tomtom.com/tomtom-orbis-maps/documentation/tomtom-orbis-maps-apis
  - https://developer.tomtom.com/routing-api/documentation/tomtom-maps/routing-service
  - https://developer.tomtom.com/geocoding-api/documentation/product-information/introduction
  - https://developer.tomtom.com/bridge/documentation/develop/map-library-sdk
- ArcGIS:
  - https://developers.arcgis.com/javascript/latest/
  - https://developers.arcgis.com/javascript/latest/layers/
  - https://developers.arcgis.com/javascript/latest/tutorials/add-a-point-line-and-polygon/
  - https://developers.arcgis.com/javascript/latest/routing/routing-intro/
  - https://developers.arcgis.com/javascript/latest/api-reference/esri-layers-RouteLayer.html
  - https://developers.arcgis.com/javascript/latest/api-reference/esri-layers-support-KMLSublayer.html
