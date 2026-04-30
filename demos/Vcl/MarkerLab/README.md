# VCL Marker Lab

Demo `VCL` para validar la colección `TGMMap.Markers`.

## Qué comprueba

- creación de marcadores antes de activar el mapa
- creación de marcadores desde código usando botones
- creación de marcadores al hacer click en el mapa
- visualización de los modos `mcmDefault`, `mcmPin`, `mcmHtml` y `mcmLabel`
- recepción de `OnClick` en `TGMMarkerItem`
- arrastre del marcador y recepción de `OnDragStart`, `OnDrag` y `OnDragEnd`
- limpieza y resincronización de la colección

## Uso

1. Abrir `GMLibMarkerLab.dproj`.
2. Introducir una `Google Maps API key` válida.
3. Introducir un `Map ID` válido si se quieren usar marcadores.
4. Pulsar `Activate map`.
5. Verificar los cuatro marcadores de referencia que la demo crea automáticamente al quedar el mapa listo.
6. Activar `Add marker on map click` si se quiere sembrar marcadores desde el mapa.
7. Crear marcadores adicionales con `Add sample marker` si se quiere probar la rotación de modos.
8. Revisar el log inferior para ver creación, clicks, drag y limpieza.

## Modos de contenido

La demo crea por defecto cuatro marcadores de referencia:

- `mcmDefault`
- `mcmHtml`
- `mcmLabel`
- `mcmPin`

Además, el botón `Add sample marker` va rotando entre esos cuatro modos para facilitar comprobaciones visuales rápidas.

`mcmLabel` no es un modo nativo de Google Maps. Es una abstracción de GMLib construida sobre contenido custom de `AdvancedMarkerElement`.

### Ejemplo `mcmHtml`

```pascal
Marker.Options.ContentMode := mcmHtml;
Marker.Options.HtmlOptions.CssClassName := 'price-marker';
Marker.Options.HtmlOptions.Html :=
  '<div style="padding:8px 10px;border-radius:999px;background:#111827;' +
  'color:#f9fafb;border:2px solid #f59e0b">$42</div>';
```

### Ejemplo `mcmLabel`

```pascal
Marker.Options.ContentMode := mcmLabel;
Marker.Options.LabelOptions.Text := 'Cafe';
Marker.Options.LabelOptions.BackgroundCss := '#1d4ed8';
Marker.Options.LabelOptions.BorderColorCss := '#93c5fd';
Marker.Options.LabelOptions.TextColorCss := '#eff6ff';
```

## Nota

La demo lee por defecto las variables de entorno `GOOGLE_MAPS_API_KEY` y `GOOGLE_MAPS_MAP_ID` si existen.

Google Maps exige un `Map ID` válido para `AdvancedMarkerElement`, por lo que sin `Map ID` el mapa puede cargar pero los marcadores no llegarán a materializarse.
La colección `Markers` es actualmente el modelo público de marcadores. No hay un componente visual independiente `TGMMarker` en la API actual del reinicio.
