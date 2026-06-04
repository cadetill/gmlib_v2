# Vcl

Adaptadores e implementación específica de `VCL`.

Estructura actual:

- `src/Vcl/GM`: backend Google Maps para VCL
- `src/Vcl/OSM`: backend OSM/MapLibre para VCL

Contenido actual (backend GM):

- `uGMLib.Vcl.Map`
- bridge WebView2 en `uGMLib.Vcl.Bridge.WebView2`
- bootstrap HTML/JS en `uGMLib.Vcl.MapBootstrap`, materializado desde recursos embebidos en temporal
- opciones VCL en `uGMLib.Vcl.MapOptions`
- registro design-time en `uGMLib.Vcl.Register`

El componente actual es no visual y requiere un `TEdgeBrowser` externo asignado en la propiedad `Browser`.

Contrato actual de `Browser`:

- `TGMLibVclMap` y `TOSMLibVclMap` esperan un `TEdgeBrowser`
- el bridge VCL usa `WebView2`
- `BridgeInterval` existe como propiedad de componente para ajustar el timer
  interno del bridge cuando aplique

Nota de diseño:

- la clase real registrada en el IDE es `TGMLibVclMap`
- dentro de la unit sigue existiendo el alias `TGMLibMap = TGMLibVclMap`
- esta separación evita colisiones de registro con el componente FMX

