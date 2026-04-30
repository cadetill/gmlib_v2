# Tests

Proyecto de pruebas automáticas del reinicio.

Contenido actual:

- `GMLibTests.dproj`: runner DUnitX de consola
- `src/uTest.MapOptions.Serialization.pas`: pruebas de serialización para `TGMMapOptions`
- `src/uTest.Marker.Model.pas`: pruebas del modelo de markers
- `src/uTest.InfoWindow.Model.pas`: pruebas del modelo de info windows
- `src/uTest.Polyline.Model.pas`: pruebas del modelo de polylines

Cobertura actual:

- campos opcionales de `TGMMapOptions`
- opciones `startup only`
- `Restriction`
- cursores
- `MapTypeControlOptions.MapTypeIds`
- serialización y routing básico del modelo `Marker`
- serialización y estado del modelo `InfoWindow`
- serialización, eventos, `path_changed` y `ZoomToPoints` del modelo `Polyline`
- serialización, command building, eventos click y path_changed, y `ZoomToPoints` del modelo `Polygon`
- **Tests de Polygon pasaron exitosamente (18/04/2026)**

Todavía no hay cobertura automática para demos, bridge runtime ni validación visual en ejecución real.
