# JavaScript Resources

Recursos web usados por el mapa.

Estado actual:

- `common/gmlib.map.html`: plantilla HTML única compartida por `VCL`, `FMX` y `LCL`
- `common/gmlib.map.js`: bridge JavaScript común, inicialización del mapa y soporte inicial para markers
- `osm/osmlib.map.html`: plantilla inicial de bootstrap para el piloto `OSMLib` sobre `MapLibre`
- `osm/osmlib.map.js`: esqueleto JavaScript inicial del mapa `OSMLib`

En tiempo de ejecución, los bootstrap de `VCL`/`FMX`/`LCL` extraen estos dos
recursos a una carpeta temporal propia antes de componer el HTML final que se
entrega al navegador embebido.

La arquitectura actual evita duplicar HTML/JS por framework. Las diferencias entre `VCL` y `FMX` están en la capa Delphi del bridge, no en estos recursos.

En `OSMLib`, estos recursos son todavÃ­a un bootstrap mÃ­nimo de arranque. No
hay aÃºn paridad funcional con `GMLib`.
