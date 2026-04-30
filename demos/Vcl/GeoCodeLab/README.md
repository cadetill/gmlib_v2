# VCL GeoCodeLab

Demo VCL para probar el servicio `GeoCode` ligado al mapa.

## Flujo

1. Abrir `GMLibGeoCodeLab.dproj`.
2. Activar el mapa.
3. Pulsar `Geocode addr.` para geocodificar una dirección.
4. Pulsar `Reverse` para geocodificar inversamente el `Lat/Lng`.
5. Pulsar `Geocode id` con un `PlaceId` válido.
6. Pulsar `Center map` para centrar el mapa en el par actual de coordenadas.

## Notas

- `Map click` rellena las coordenadas.
- El primer resultado recibido recentra el mapa de forma automática.
- `Language` y `Region` se envían al request del geocoder.
