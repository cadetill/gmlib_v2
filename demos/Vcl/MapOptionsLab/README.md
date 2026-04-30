# VCL Map Options Lab

Demo `VCL` para validar opciones del nuevo `TGMLibMap` antes y después de activar el mapa.

## Qué permite comprobar

- activación del mapa con `API key`
- cambios de centro y zoom
- opciones booleanas principales de `MapOptions`
- `GestureHandling`
- selector y estilo de `MapTypeControl`
- posiciones de controles visibles
- aplicación de opciones normales antes y después de `map.ready`
- eventos de interacción como `click`, `click` enriquecido con `placeId`,
  `contextmenu`, `heading_changed`, `tilt_changed`, `mouseover`, `mouseout`,
  `projection_changed` y `renderingtype_changed`

## Uso

1. Abrir `GMLibMapOptionsLab.dproj`.
2. Revisar o introducir la `Google Maps API key`.
3. Ajustar opciones en el panel izquierdo.
4. Pulsar `Apply options` para probar cambios.
5. Pulsar `Activate map` para lanzar el mapa.
6. Revisar el log inferior para ver el flujo y los eventos recibidos.

## Nota

La demo lee por defecto la variable de entorno `GOOGLE_MAPS_API_KEY` si existe.

`ColorScheme`, `ControlSize`, `MapId` y `RenderingType` son opciones de inicialización. Si se cambian con el mapa ya activo, el componente lanzará una excepción.

`OnMapClick` incluye `placeId` cuando Google Maps lo proporciona al pulsar
sobre un POI del mapa.


