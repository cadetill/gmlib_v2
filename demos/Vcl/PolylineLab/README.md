# VCL Polyline Lab

Demo `VCL` para validar la colección `TGMMap.Polylines`.

## Qué comprueba

- creación de una polyline antes de activar el mapa
- sincronización Delphi -> JS de `Path`, `Visible`, `Editable`, `Draggable`,
  `StrokeColor`, `StrokeOpacity` y `StrokeWeight`
- edición visual del `Path` con `Editable=True`
- recepción de `OnClick`, `OnDragStart`, `OnDragEnd` y `OnPathChanged`
- ajuste de viewport con `ZoomToPoints`
- limpieza y recreación de la colección

## Uso

1. Abrir `GMLibPolylineLab.dproj`.
2. Revisar o introducir la `Google Maps API key`.
3. Pulsar `Activate map`.
4. Editar el `Path` en el memo usando una coordenada `lat,lng` por línea.
5. Pulsar `Apply polyline` para sincronizar la polyline.
6. Activar `Editable` si se quiere modificar el trazado desde el mapa.
7. Pulsar `Zoom to polyline` para ajustar el viewport al trazado actual.
8. Revisar el log inferior para ver eventos y cambios de `Path`.

## Nota

La demo lee por defecto la variable de entorno `GOOGLE_MAPS_API_KEY` si existe.
