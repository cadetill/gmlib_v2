# Demos

Demos nuevas del reinicio separadas por framework.

## VCL

- `Vcl/MapMinimal`: vertical mínima del mapa con `TEdgeBrowser`
- `Vcl/MapOptionsLab`: laboratorio de opciones y eventos del mapa
- `Vcl/MarkerLab`: laboratorio de la colección `TGMMap.Markers`, incluyendo `mcmDefault`, `mcmPin`, `mcmHtml` y `mcmLabel`
- `Vcl/PolylineLab`: laboratorio visual de `TGMMap.Polylines`, edición de `Path`, opciones básicas y eventos
- `Vcl/PolygonLab`: laboratorio visual de `TGMMap.Polygons`, edición de `Path`, opciones básicas y eventos, ya alineado visualmente con la demo FMX
- `Vcl/RectangleLab`: laboratorio visual de `TGMMap.Rectangles`, bounds editables, zoom y eventos
- `Vcl/CircleLab`: laboratorio visual de `TGMMap.Circles`, center/radius editables, flags y eventos de circulo, validado en VCL
- `Vcl/GeoCodeLab`: laboratorio validado de geocodificacion con direccion, reverse geocode y place id
- `Vcl/ElevationLab`: laboratorio validado de elevaciones para consultas por puntos y por path
- `Vcl/RoutesLab`: laboratorio validado de rutas con origen, destino y waypoints mixtos, historial de queries y visibilidad por resultado
- `Vcl/Edge`: sandbox de integracion con `TEdgeBrowser`, incluyendo `Project2` para validar hosting y compilacion de `TGMLibVclMap`

## FMX

- `Fmx/MapMinimal`: vertical mínima del mapa con `TWebBrowser`
- `Fmx/MapOptionsLab`: laboratorio FMX de opciones y eventos del mapa
- `Fmx/MarkerLab`: laboratorio FMX de la colección `TGMMap.Markers`, incluyendo `mcmDefault`, `mcmPin`, `mcmHtml` y `mcmLabel`
- `Fmx/PolylineLabFmx`: laboratorio FMX de `TGMMap.Polylines`, edición de `Path`, opciones básicas y eventos
- `Fmx/PolygonLab`: laboratorio FMX de `TGMMap.Polygons`, edición de `Path`, opciones básicas y eventos
- `Fmx/RectangleLab`: laboratorio FMX de `TGMMap.Rectangles`, bounds editables, zoom y eventos
- `Fmx/CircleLab`: laboratorio FMX de `TGMMap.Circles`, center/radius editables, flags y eventos de circulo, validado en FMX
- `Fmx/GeoCodeLab`: laboratorio FMX validado de geocodificacion con direccion, reverse geocode y place id
- `Fmx/ElevationLab`: laboratorio FMX validado de elevaciones para consultas por puntos y por path
- `Fmx/RoutesLab`: laboratorio FMX validado de rutas con origen, destino y waypoints mixtos, historial de queries y visibilidad por resultado

## Nota operativa

Las demos leen la variable de entorno `GOOGLE_MAPS_API_KEY` si existe.

Las demos que usan marcadores leen además `GOOGLE_MAPS_MAP_ID` si existe.

Las opciones `ColorScheme`, `ControlSize`, `MapId` y `RenderingType` son de inicialización y no deben cambiarse después de activar el mapa.

Las demos VCL con `TEdgeBrowser` incluyen ya varios ajustes de compatibilidad para `Delphi 11` evitando acceso directo a propiedades no presentes en versiones antiguas del componente.

## OSM offline (MegaDemo)

La pestaña OSM de `Vcl/MegaDemo` intenta arrancar en modo offline si encuentra
estos ficheros locales:

- `resources/js/osm/vendor/maplibre-gl.css`
- `resources/js/osm/vendor/maplibre-gl.js`
- `resources/js/osm/offline/style.json`

Si falta alguno, queda registrado en el log de la demo.
