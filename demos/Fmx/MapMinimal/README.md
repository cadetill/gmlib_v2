# FMX Map Minimal

Demo mínima `FMX` para validar `TGMLibMap` con `TWebBrowser`.

## Qué comprueba

- activación del mapa
- carga inicial del HTML y bootstrap JavaScript
- evento `map.ready`
- sincronización Delphi -> JS de `Center` y `Zoom`
- recepción de `center_changed`, `zoom_changed`, `maptypeid_changed` y `click`

## Uso

1. Abrir `GMLibMapFmxDemo.dproj`.
2. Introducir una `Google Maps API key` válida.
3. Pulsar `Activate map`.
4. Usar `Apply view` para probar cambios de centro y zoom.
5. Revisar el log inferior para ver los eventos recibidos.

## Nota

La demo lee por defecto la variable de entorno `GOOGLE_MAPS_API_KEY` si existe.
