# Tests

Proyecto de pruebas automáticas del reinicio.

Contenido actual:

- `GMLibTests.dproj`: runner DUnitX de consola
- `src/uTest.MapOptions.Serialization.pas`: pruebas de serialización para `TGMMapOptions`
- `src/uTest.Marker.Model.pas`: pruebas del modelo de markers
- `src/uTest.InfoWindow.Model.pas`: pruebas del modelo de info windows
- `src/uTest.Polyline.Model.pas`: pruebas del modelo de polylines
- `src/uTest.OSM.Marker.Model.pas`: pruebas del modelo base de `OSMLib`
- `src/uTest.MapLib.Offline.StyleProvider.pas`: pruebas del constructor de `style.json`
- `src/uTest.MapLib.Offline.TileResolver.pas`: pruebas del resolvedor local/híbrido
- `src/uTest.MapLib.Offline.RegionManager.pas`: pruebas del catálogo y cobertura offline

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
- payloads, sincronización básica y bootstrap config del modelo `OSMLib`
- sustitución de placeholders del `StyleProvider`
- resolución local/remota y persistencia tolerante a errores en `TileResolver`
- cobertura, borrado y uso de almacenamiento en `RegionManager`
- **Tests de Polygon pasaron exitosamente (18/04/2026)**

Todavía no hay cobertura automática para demos, bridge runtime ni validación visual en ejecución real.
