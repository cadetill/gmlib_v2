# OSM Offline Assets

Este directorio contiene los assets activos del runtime offline/híbrido de
`OSMLib`.

## Incluido

- `style.template.json`: plantilla de estilo usada por el runtime vectorial
  para construir el estilo final con URLs de `localhost` para tiles y glyphs.

## Requerido para modo offline/hybrid real

Además de `style.template.json`, la demo busca estos ficheros de MapLibre GL JS:

- `resources/js/osm/vendor/maplibre-gl.css`
- `resources/js/osm/vendor/maplibre-gl.js`

Sin esos dos ficheros, la demo no puede arrancar el runtime local de OSM con
assets embebidos/locales.

## Runtime actual

El flujo actual ya no depende de `style.json` ni de `tilejson.json` locales.
El estilo final se genera en runtime a partir de `style.template.json` y del
`RemoteTileTemplate` configurado en `TOSMMap`.
