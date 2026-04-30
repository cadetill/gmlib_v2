# Arquitectura

## Objetivo

Definir una arquitectura que permita compartir la mayor parte posible del comportamiento entre `VCL` y `FMX`, dejando las diferencias reales en adaptadores pequeños y explícitos.

## Capas

### `src/Common`

Contendrá la lógica común y agnóstica de framework:

- tipos base
- contratos
- modelos de opciones
- serialización y deserialización de mensajes
- sincronización de estado
- registro de objetos del mapa
- lógica de routing de eventos

### `src/Vcl`

Contendrá:

- wrappers específicos de `VCL`
- adaptadores de navegador para Windows
- registro de componentes en la paleta
- demos VCL

### `src/Fmx`

Contendrá:

- wrappers específicos de `FMX`
- adaptadores por plataforma o por navegador
- integración con Windows, Android, iOS y macOS

## Modelo de objetos

## Público

- `TGMMap`
- `TGMMarkers`
- `TGMInfoWindow`
- `TGMPolyline`
- `TGMPolygon`
- `TGMRectangle`
- `TGMCircle`
- `TGMGeoCode`
- `TGMElevations`

## Base interna prevista

- `TGMCustomApiObject`
  Propiedad común `APIUrl`.
- `TGMCustomMapLinkedComponent`
  Base para objetos vinculados a un `TGMMap`.
- `TGMCustomOverlayPath`
  Base compartida para objetos con rutas o listas de coordenadas.
- `TGMMessageEnvelope`
  Mensaje estándar Delphi <-> JS.
- `IGMBridgeTransport`
  Contrato de transporte del bridge.

## Bridge

El bridge tendrá dos direcciones:

- `Delphi -> JS`
  Comandos explícitos.
- `JS -> Delphi`
  Mensajes JSON normalizados.

El código común no debe depender de `WebView2`, `CEF` ni de una API concreta de `FMX`.

## Transporte

Cada backend implementará un transporte concreto:

- `VCL + WebView2`
- `VCL + CEF` como bridge opcional, registrado por unidad fuente y no ligado al paquete base
- `FMX + backend a decidir por plataforma`

Todos expondrán el mismo contrato lógico.

## Carga Dinámica JS

El runtime JavaScript debe concentrar la carga on-demand de librerías de Google Maps en un helper único basado en `importLibrary()`.

Reglas prácticas:

- `window.gmlib.getLib(name)` debe cachear el `Promise` por librería.
- `marker`, `geocoding`, `elevation` y futuras librerías no deben duplicar lógica de carga.
- El contrato Delphi/Lazarus no debe exponer `await`; el `await` vive dentro del runtime JS.
- La capa Delphi/Lazarus solo recibe respuestas ya resueltas por `requestId`.

Recomendación de implementación:

- `window.gmlib.getLib(name)` debe cachear el `Promise` por librería.
- el helper debe ser el único punto donde se decide si una librería ya está cargada o debe pedirse al API de Google.
- los slices nuevos deben reutilizar ese helper en lugar de crear su propia lógica de carga.

## Bootstrap HTML

El HTML de bootstrap debe seguir siendo declarativo y mínimo, pero con dos reglas prácticas:

- si existe `MapId`, debe pasar a la URL del loader mediante `map_ids`
- el `script` principal de Google debe exponer `onerror` para reportar fallos de carga al bridge

No se recomienda añadir un callback público artificial tipo `gmlibInitMap` a la URL del script de Google si el bootstrap ya usa el loader dinámico con `importLibrary()`. La inicialización propia de GMLib debe vivir en su capa HTML/JS, separada del callback interno del loader.

## Salida de Mensajes

La detección del transporte no debe depender de heurísticas dispersas dentro del runtime JS.

Preferencia arquitectónica:

- un punto único `window.gmlib.sendEnvelope(...)` o equivalente
- cada backend inyecta su implementación concreta de transporte
- WebView2, CEF y el fallback por iframe comparten el mismo formato de envelope
- el fallback por iframe queda como última red, no como mecanismo principal

Recomendación de implementación:

- el runtime JS debe llamar siempre a una abstracción única de salida, no a un transporte concreto disperso por ramas.
- el backend Delphi/Lazarus inyecta el transport real; el JS común no decide entre WebView2, CEF o iframe.
- el formato de envelope debe permanecer estable para que el bridge sea intercambiable.

## Reglas de sincronización

- Delphi mantiene el estado canónico de los componentes.
- JS informa de eventos y cambios producidos por interacción del usuario.
- Los cambios entrantes desde JS no deben provocar bucles de eco.
- Cada objeto visual tendrá un identificador estable dentro del mapa.
- Los overlays que dependen de un mapa estable deben materializarse solo cuando el runtime confirme estado estable, no en el primer `map.ready`.

## Flujo interno actual

### `TGMMap`

`TGMMap` actúa como coordinador único entre Delphi y JavaScript.

Responsabilidades actuales:

- mantiene el estado canónico del mapa en `Options`
- serializa cambios Delphi -> JS mediante `setOptions(...)` u órdenes concretas
- recibe todos los mensajes JS -> Delphi a través del bridge
- decide si un mensaje va dirigido al propio mapa o a un objeto enlazado
- mantiene el registro interno de objetos enlazados por `ObjectId`

### `TGMCustomMapLinkedComponent`

`TGMCustomMapLinkedComponent` es la base común para futuros componentes
enlazados de primer nivel.

Responsabilidades actuales:

- mantiene una referencia al `Map` propietario
- dispone de un `ObjectId` estable para routing
- notifica cambios Delphi -> mapa mediante `StateChanged`
- puede enviar JavaScript pasando siempre por el mapa
- recibe mensajes JS ya filtrados por `targetId`

## Recorrido de mensajes

### Delphi -> JS

1. Un cambio en `TGMMap` o en un objeto enlazado modifica el estado Delphi.
2. El componente enlazado notifica al mapa mediante `StateChanged`.
3. `TGMMap` decide qué comando JavaScript debe emitirse.
4. El bridge ejecuta el comando o lo deja en cola si el mapa aún no está listo.

### JS -> Delphi

1. JavaScript envía un `TGMMessageEnvelope` normalizado.
2. El bridge entrega el mensaje a `TGMMap`.
3. `TGMMap` inspecciona `targetId`.
4. Si `targetId = map_1` o el id del mapa, procesa el mensaje el propio mapa.
5. Si `targetId` pertenece a un objeto enlazado registrado, el mensaje se reenvía a ese componente.
6. Si `targetId` pertenece a un item de una colección propiedad del mapa, el
   mensaje se reenvía al item correspondiente.

## `targetId`

Regla práctica:

- el mapa usa su propio `MapId`
- cada objeto enlazado usa su `ObjectId`
- cada item de colección del mapa usa también su `ObjectId`
- el routing Delphi se basa en esa distinción

Esto permite que el bridge siga siendo único aunque existan múltiples objetos
visuales dentro del mismo mapa.

## Formato de mensaje previsto

```json
{
  "type": "map.zoom_changed",
  "targetId": "map_1",
  "payload": {
    "zoom": 12
  }
}
```

## Decisiones de API relevantes

- Se usará `AdvancedMarkerElement` para el nuevo componente de marcadores.
- `Polyline`, `Polygon`, `Rectangle` y `Circle` seguirán siendo componentes públicos separados.
- La documentación de código seguirá en español con PasDoc.

## Primera colección real del mapa

La primera colección real que valida esta infraestructura es `TGMMarkers`,
publicada directamente por `TGMMap`.

Slice inicial previsto y ya alineado con la arquitectura:

- `TGMMap.Markers` como colección publicada
- `TGMMarkerItem` con `ObjectId` estable para routing
- materialización JS mediante `AdvancedMarkerElement`
- patrón de configuración mediante objeto `Options`
- soporte inicial para:
  - `Options.Position`
  - `Options.Title`
  - `Options.Visible`
  - `OnClick`

### Flujo de la colección

1. El usuario modifica un `TGMMarkerItem` dentro de `TGMMap.Markers`.
2. La colección notifica el cambio al mapa.
3. `TGMMap` sincroniza altas, cambios y bajas hacia JavaScript.
4. JavaScript materializa cada marker con su `markerId` propio.
5. En eventos como `click`, JavaScript usa `targetId = markerId`.
6. `TGMMap` localiza el `TGMMarkerItem` afectado y le reenvía el evento.

La intención es validar primero el flujo completo de una colección propiedad del
mapa antes de ampliar opciones del propio marker o crear overlays más complejos.
