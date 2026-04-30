# VCL Polygon Lab

Demo `VCL` para validar la coleccion `TGMMap.Polygons`.

## Que comprueba

- creacion de un poligono antes de activar el mapa
- sincronizacion Delphi -> JS de `Path`, `Visible`, `Editable`, `Draggable`,
  `Geodesic`, `FillColor`, `FillOpacity`, `StrokeColor`, `StrokeOpacity` y `StrokeWeight`
- edicion visual del trazado con `Editable=True`
- recepcion de `OnClick`, `OnDragStart`, `OnDragEnd` y `OnPathChanged`
- ajuste de viewport con `ZoomToPoints`
- limpieza y recreacion de la coleccion

## Uso

1. Abrir `GMLibPolygonLab.dproj`.
2. Revisar o introducir la `Google Maps API key`.
3. Pulsar `Activate map`.
4. Editar el trazado en el memo usando una coordenada `lat,lng` por linea.
5. Pulsar `Apply polygon` para sincronizar el poligono.
6. Activar `Editable` si se quiere modificar el trazado desde el mapa.
7. Pulsar `Zoom to polygon` para ajustar el viewport al trazado actual.
8. Revisar el log inferior para ver eventos y cambios de `Path`.

## Nota

La demo lee por defecto la variable de entorno `GOOGLE_MAPS_API_KEY` si existe.
