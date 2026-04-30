# Fmx

Adaptadores e implementación específica de `FMX`.

Contenido actual:

- `uGMLib.Fmx.Map`
- bridge basado en ``TWebBrowser``
- bootstrap HTML/JS en `uGMLib.Fmx.MapBootstrap`, materializado desde recursos embebidos en temporal
- opciones FMX en `uGMLib.Fmx.MapOptions`
- registro design-time en `uGMLib.Fmx.Register`

El componente actual es no visual y requiere un ``TWebBrowser`` externo asignado en la propiedad `Browser`.

Nota de diseño:

- la clase real registrada en el IDE es `TGMLibFmxMap`
- dentro de la unit sigue existiendo el alias `TGMLibMap = TGMLibFmxMap`
- esta separación evita colisiones de registro con el componente VCL


Nota técnica del bridge:

- el canal `JS -> Delphi` en FMX no depende solo de navegación interceptada
- además mantiene una cola JavaScript consultada por polling con `EvaluateJavaScript`
- esto se añadió para dar un comportamiento más estable con `TWebBrowser` y
  Edge/WebView2 en eventos del mapa




