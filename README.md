Mi Radio FM Online
===================

Aplicación web ligera para escuchar emisoras de radio por streaming (MP3/AAC/OGG) desde el navegador.

Características
- Lista de estaciones de ejemplo (SomaFM, Radio Paradise).
- Reproducir/Pausar, control de volumen y silenciar.
- Añadir estaciones personalizadas (se guardan en localStorage).
- Soporte básico de Media Session API (metadatos cuando el navegador lo permite).

Limitaciones y notas
- Algunos streams pueden bloquearse por CORS o exigir cabeceras/referrer; esto no puede solucionarse desde el frontend si el servidor no lo permite.
- Si un stream no funciona, prueba con otra URL o usa un servidor proxy (no incluido aquí).

Cómo usar
1) Opción rápida: abrir el archivo `index.html` en tu navegador (arrastrando al navegador). Algunos navegadores bloquean la reproducción automática hasta que interactúes con la página.

2) Opción recomendada (servidor estático): en PowerShell, sitúate en la carpeta del proyecto y arranca un servidor simple:

```powershell
Set-Location -Path "c:\Users\MIRANDA\Documents\myradio"; python -m http.server 8000
```

Luego abre http://localhost:8000 en tu navegador.

Personalizar
- Edita `stations.json` para cambiar las estaciones por defecto.
- Las estaciones añadidas con el formulario se guardan en el almacenamiento local del navegador.

Siguientes pasos (opcional)
- Empaquetar como app de escritorio con Electron o Tauri.
- Añadir verificación de disponibilidad de streams en servidor (proxy) para evitar problemas CORS.
- Mostrar metadatos de pista vía un servicio backend que consulte la cabecera ICY.

Si quieres, puedo:
- Añadir un backend mínimo para esquivar CORS y obtener metadata.
- Convertir esto en una app Electron lista para distribuir.
- Mejorar la UI o añadir favoritos y búsqueda.

