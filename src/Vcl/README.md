# Vcl

Adaptadores e implementación específica de `VCL`.

Contenido actual:

- `uGMLib.Vcl.Map`
- bridge WebView2 en `uGMLib.Vcl.Bridge.WebView2`
- bootstrap HTML/JS en `uGMLib.Vcl.MapBootstrap`, materializado desde recursos embebidos en temporal
- opciones VCL en `uGMLib.Vcl.MapOptions`
- registro design-time en `uGMLib.Vcl.Register`

El componente actual es no visual y requiere un `TEdgeBrowser` externo asignado en la propiedad `Browser`.

Nota de diseño:

- la clase real registrada en el IDE es `TGMLibVclMap`
- dentro de la unit sigue existiendo el alias `TGMLibMap = TGMLibVclMap`
- esta separación evita colisiones de registro con el componente FMX
