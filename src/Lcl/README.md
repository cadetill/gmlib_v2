# Lcl

Adaptadores e implementación específica de `LCL`.

Estructura actual:

- `src/Lcl/GM`: backend Google Maps para LCL
- `src/Lcl/OSM`: backend OSM/MapLibre para LCL

Contrato actual de `Browser`:

- `TGMLibLclMap` y `TOSMLibLclMap` esperan un componente de navegador con
  bridge registrado
- hoy el bridge real mantenido en el repo es `CEF4Delphi`
- `BridgeInterval` se expone en el componente para mantener una API uniforme
  con `VCL` y `FMX`, aunque su efecto depende del bridge concreto registrado

Estado actual:

- el paquete `GMLibRuntime.Lcl` compila correctamente
- siguen apareciendo `Notes` y algunos `Warnings` de `FPC` en
  `generics.collections` / `generics.dictionaries`
- de momento se consideran ruido del compilador, no fallo funcional del
  componente
