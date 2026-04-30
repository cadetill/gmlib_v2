# JavaScript Resources

Recursos web usados por el mapa.

Estado actual:

- `common/gmlib.map.html`: plantilla HTML única compartida por `VCL`, `FMX` y `LCL`
- `common/gmlib.map.js`: bridge JavaScript común, inicialización del mapa y soporte inicial para markers

En tiempo de ejecución, los bootstrap de `VCL`/`FMX`/`LCL` extraen estos dos
recursos a una carpeta temporal propia antes de componer el HTML final que se
entrega al navegador embebido.

La arquitectura actual evita duplicar HTML/JS por framework. Las diferencias entre `VCL` y `FMX` están en la capa Delphi del bridge, no en estos recursos.
