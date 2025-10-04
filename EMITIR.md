Emitir tu propia radio — "Hay Vida En Jesus"
=============================================

Esto añade un servidor Icecast ligero como origen para tu emisora y las instrucciones para emitir desde Windows.

Archivos añadidos
- `docker-compose.yml` — arranca un contenedor Icecast (puerto 8000).
- `icecast/icecast.xml` — configuración mínima con un mount `/hayvida.mp3`.
- `stations.json` — incluye la entrada `http://localhost:8000/hayvida.mp3`.

Contraseñas (actuales en este proyecto)
- source password: `hV7s9Kq2TzR4mLx1`
- admin user/password: `admin` / `Gp8Rk3NqV5sYeZ2b`

Pasos rápidos (PowerShell en Windows)
1) Instala Docker Desktop y asegúrate que WSL2 o Hyper-V está activo.
2) Abre PowerShell en la carpeta del proyecto `c:\Users\MIRANDA\Documents\myradio`.
3) Inicia Icecast:

```powershell
Set-Location -Path "c:\Users\MIRANDA\Documents\myradio"; docker compose up -d
```

4) Abre http://localhost:8000/ en tu navegador para ver la interfaz de Icecast.
   - Panel admin: http://localhost:8000/admin (usuario `admin`, contraseña `adminpassword`)

Emitir audio (dos opciones)

Opción A — BUTT (GUI, recomendado para Windows)
- Descarga BUTT: https://danielnoethen.de/butt/
- Abre BUTT y crea una nueva conexión:
  - Server: localhost
  - Port: 8000
  - Password: secretsource
  - Mountpoint: /hayvida.mp3
  - Format: MP3
- Selecciona tu micrófono o un archivo de reproducción (audio output) y presiona "Play" y luego "Connect" para empezar a transmitir.

Opción B — ffmpeg (línea de comandos, puede reproducir archivos o el dispositivo de audio)

Transmitir un archivo MP3 en bucle:

```powershell
ffmpeg -re -stream_loop -1 -i "c:\path\to\tu-cancion.mp3" -c:a libmp3lame -b:a 128k -f mp3 "http://source:secretsource@localhost:8000/hayvida.mp3"
```

Transmitir micro en tiempo real (puede requerir ajustes de dispositivo):

```powershell
ffmpeg -f dshow -i audio="Microphone (Realtek Audio)" -c:a libmp3lame -b:a 128k -f mp3 "http://source:secretsource@localhost:8000/hayvida.mp3"
```

Notas y seguridad
- Las contraseñas incluidas son de ejemplo. Cámbialas en `icecast/icecast.xml` antes de exponer el servicio.
- Si quieres que tu radio sea accesible desde Internet, necesitarás:
  - Abrir/redirigir el puerto 8000 en tu router y firewall.
  - Asegurarte de tener una IP pública o usar un servicio de túnel (ngrok, Cloudflare Tunnel).
  - Considerar usar HTTPS/proxy.

Siguiente paso
- ¿Quieres que arranque el contenedor Icecast aquí y pruebe la conexión (si tienes Docker instalado)?
- ¿Quieres que configure una lista de reproducción automática o un script que reproduzca MP3s desde una carpeta?

Arrancar ffmpeg automáticamente en el inicio (Windows)
-----------------------------------------------
Si quieres que la transmisión se inicie automáticamente al iniciar sesión en Windows, puedes crear una tarea programada que ejecute `run-ffmpeg.ps1`:

1) Abre PowerShell como administrador y ejecuta (ajusta la ruta si tu usuario no es MIRANDA):

```powershell
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -WindowStyle Hidden -File "C:\\Users\\MIRANDA\\Documents\\myradio\\run-ffmpeg.ps1"'
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName 'MyRadio-RunFFmpeg' -Action $action -Trigger $trigger -RunLevel LeastPrivilege -User "$env:USERNAME"
```

2) La tarea se ejecutará en el siguiente inicio de sesión y arrancará ffmpeg en background.

Si prefieres que la tarea se ejecute incluso sin sesión iniciada, usa `-RunLevel Highest` y especifica una cuenta con contraseña.

Dime qué prefieres y lo preparo en el repo (scripts, ejemplos de ffmpeg para playlist, o automatización de arranque).