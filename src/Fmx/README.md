# Fmx

Adaptadores e implementación específica de `FMX`.

Contenido actual:

- `uGMLib.Fmx.Map`
- `uOSMLib.Fmx.Map`
- bridge basado en ``TWebBrowser``
- bootstrap HTML/JS en `uGMLib.Fmx.MapBootstrap` y `uOSMLib.Fmx.MapBootstrap`, materializado desde recursos embebidos en temporal
- opciones FMX en `uGMLib.Fmx.MapOptions`
- registro design-time en `uGMLib.Fmx.Register`

El componente actual es no visual y requiere un ``TWebBrowser`` externo asignado en la propiedad `Browser`.

Contrato actual de `Browser`:

- `TGMLibFmxMap` y `TOSMLibFmxMap` esperan un `TWebBrowser`
- el bridge FMX usa polling de la cola JavaScript
- `BridgeInterval` ajusta ese polling del bridge FMX

Nota de diseño:

- la clase real registrada en el IDE es `TGMLibFmxMap`
- para OSM la clase registrada es `TOSMLibFmxMap`
- dentro de la unit sigue existiendo el alias `TGMLibMap = TGMLibFmxMap`
- esta separación evita colisiones de registro con el componente VCL

Estado OSM actual:

- `TOSMLibFmxMap` ya expone la superficie pública principal de `OSMLib`
- el bootstrap FMX acepta assets locales de `MapLibre` con la misma estrategia
  de incrustado o carga por URL usada en `VCL`


Nota técnica del bridge:

- el canal `JS -> Delphi` en FMX no depende solo de navegación interceptada
- además mantiene una cola JavaScript consultada por polling con `EvaluateJavaScript`
- esto se añadió para dar un comportamiento más estable con `TWebBrowser` y
  Edge/WebView2 en eventos del mapa




