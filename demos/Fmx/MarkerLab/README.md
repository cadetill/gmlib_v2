# FMX Marker Lab

Demo `FMX` para validar la colección `TGMMap.Markers`.

## Qué permite comprobar

- activación del mapa con `API key`
- creación de marcadores antes o después de activar el mapa
- alta manual de markers con un botón
- siembra de markers al hacer click en el mapa
- limpieza completa de la colección `Markers`
- visualización de los modos `mcmDefault`, `mcmPin`, `mcmHtml` y `mcmLabel`
- recepción de `OnClick` en cada `TGMMarkerItem`
- arrastre del marcador y recepción de `OnDragStart`, `OnDrag` y `OnDragEnd`
- recepción de `OnMouseEnter`, `OnMouseLeave`, `OnMouseDown` y `OnMouseUp`
- validación mínima del arranque del slice `TGMMap.InfoWindows`
- apertura de `InfoWindow` anclado al marker pulsado
- validación visual de `headerContent`, `headerDisabled` y `shouldFocus`

## Uso

1. Abrir `GMLibMarkerLabFmx.dproj`.
2. Revisar o introducir la `Google Maps API key`.
3. Revisar o introducir un `Map ID` válido si se quieren usar marcadores.
4. Pulsar `Activate map`.
5. Verificar los cuatro marcadores de referencia que la demo crea automáticamente al quedar el mapa listo.
6. Verificar también el `InfoWindow` de muestra que se abre al arrancar.
7. Ajustar `Info focus` y `Hide info header` para probar `shouldFocus` y `headerDisabled`.
8. Añadir marcadores con `Add sample marker` o haciendo click en el mapa.
9. Pulsar sobre un marker para abrir su `InfoWindow` anclado.
10. Revisar el log inferior para ver el flujo y los eventos recibidos.

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

Si se elimina un marker que estaba actuando como `anchor` de un `InfoWindow`, la demo sigue el criterio actual de GMLib:

- se elimina el `anchor`
- el `InfoWindow` asociado se cierra
