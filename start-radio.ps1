# start-radio.ps1 — Inicia Icecast y reproduce la carpeta tracks en bucle usando ffmpeg
# Uso: Ejecutar PowerShell como administrador o con Docker Desktop en ejecución

$project = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $project

Write-Host "Creando carpeta tracks si no existe..."
$tracksDir = Join-Path $project 'tracks'
if(-not (Test-Path $tracksDir)) { New-Item -ItemType Directory -Path $tracksDir | Out-Null }

Write-Host "Arrancando Icecast con docker compose..."
docker compose up -d

# Esperar a que Icecast esté disponible
$maxWait = 60
$wait = 0
$up = $false
while($wait -lt $maxWait -and -not $up){
    try{
        $r = Invoke-WebRequest -Uri 'http://localhost:8000/' -UseBasicParsing -TimeoutSec 5
        if($r.StatusCode -eq 200){ $up = $true; break }
    }catch{ }
    Start-Sleep -Seconds 2
    $wait += 2
    Write-Host "Esperando Icecast... $wait s"
}

if(-not $up){
    Write-Host "Icecast no respondió en el tiempo esperado. Revisa Docker logs." -ForegroundColor Red
    exit 1
}

Write-Host "Icecast está arriba. Lanzando ffmpeg para reproducir tracks en bucle..."

# Construir lista de archivos mp3
$mp3s = Get-ChildItem -Path $tracksDir -Filter *.mp3 -File -Recurse | Select-Object -ExpandProperty FullName
if(-not $mp3s){
    Write-Host "No se encontraron archivos MP3 en $tracksDir. Copia tus mp3 ahí o usa BUTT para emitir manualmente." -ForegroundColor Yellow
    exit 0
}

# Construir comando ffmpeg que concatena con -stream_loop -1 cada archivo (reproduce en orden, en bucle infinito)
# Usamos un pipe con concat demuxer: crear un archivo temporal .txt con la lista
$listFile = Join-Path $project 'tracks_list.txt'
$mp3s | ForEach-Object { "file '$_'" } | Out-File -FilePath $listFile -Encoding UTF8

$ffmpegCmd = "ffmpeg -re -f concat -safe 0 -i `"$listFile`" -c:a libmp3lame -b:a 128k -f mp3 `"http://source:hV7s9Kq2TzR4mLx1@localhost:8000/hayvida.mp3`""

Write-Host "Ejecutando: $ffmpegCmd"

# Ejecutar ffmpeg en una nueva ventana (para que el script no quede bloqueado)
Start-Process -FilePath powershell -ArgumentList "-NoExit","-Command","$ffmpegCmd"

Write-Host "Proceso de transmisión iniciado. Revisa la ventana de ffmpeg para ver logs."

# -------------------------------
# Local fallback (sin Docker)
# Ejecuta el script `run-ffmpeg.ps1` que lanza ffmpeg localmente y transmite al mount
# Uso: .\start-radio.ps1 -Local
param([switch]$Local)

if($Local){
    $runScript = Join-Path $project 'run-ffmpeg.ps1'
    if(Test-Path $runScript){
        Write-Host "Modo local: ejecutando $runScript"
        Start-Process -FilePath powershell -ArgumentList "-NoExit","-Command","& '$runScript'"
    } else {
        Write-Host "No se encontró $runScript. Asegúrate de que existe." -ForegroundColor Yellow
    }
}