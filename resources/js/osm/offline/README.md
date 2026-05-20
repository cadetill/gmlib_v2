# OSM Offline Assets

Este directorio contiene assets de ejemplo para arrancar `OSMLib` en modo
offline.

## Incluido

- `style.json`: estilo mínimo offline sin tiles (fondo sólido), útil para
  validar que la app arranca sin red y que overlays (markers, etc.) funcionan.

## Requerido para modo offline real

Además del `style.json`, la demo busca estos ficheros de MapLibre GL JS:

- `resources/js/osm/vendor/maplibre-gl.css`
- `resources/js/osm/vendor/maplibre-gl.js`

Sin esos dos ficheros, `OfflineMode` no puede activarse.

## Offline con tiles reales

Para ver cartografía offline (no solo fondo), usa un `style.json` que apunte a
fuentes/sprites/glyphs/tiles locales y, si hace falta, configura también:

- `OfflineRasterTilesUrlTemplate` en `TOSMMap`

Ejemplo de template raster local:

`file:///D:/map-tiles/{z}/{x}/{y}.png`

## Nota de prueba embedded server

- `tilejson.json` permite probar el flujo de servidor local embebido (`localhost`) sin dependencia de `pmtiles.exe` en runtime.

