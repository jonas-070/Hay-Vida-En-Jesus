#!/usr/bin/env pwsh
# run-ffmpeg.ps1 — inicia ffmpeg en background y transmite la carpeta tracks en bucle al mount Icecast

$project = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $project

Write-Host "Iniciando transmisión local con ffmpeg (modo background)..."

$ff = 'C:\\Users\\MIRANDA\\AppData\\Local\\Programs\\Gyan\\ffmpeg-8.0-essentials_build\\ffmpeg-8.0-essentials_build\\bin\\ffmpeg.exe'
$tracksDir = Join-Path $project 'tracks'
$listFile = Join-Path $project 'tracks_list.txt'
$log = Join-Path $project 'icecast\\log\\ffmpeg_stream.log'

if(-not (Test-Path $ff)){
    Write-Host "ffmpeg no encontrado en $ff" -ForegroundColor Red
    exit 1
}

if(-not (Test-Path $tracksDir)){
    New-Item -Path $tracksDir -ItemType Directory | Out-Null
}

$mp3s = Get-ChildItem -Path $tracksDir -Filter *.mp3 -File -Recurse | Select-Object -ExpandProperty FullName
if(-not $mp3s){
    Write-Host "No se encontraron MP3 en $tracksDir. Crea o copia archivos mp3 ahí." -ForegroundColor Yellow
    exit 0
}

$mp3s | ForEach-Object { "file '$_'" } | Out-File -FilePath $listFile -Encoding UTF8 -Force

$cmd = "& `"$ff`" -re -f concat -safe 0 -i `"$listFile`" -c:a libmp3lame -b:a 128k -content_type audio/mpeg -f mp3 `"icecast://source:hV7s9Kq2TzR4mLx1@localhost:8000/hayvida.mp3`""

Write-Host "Ejecutando (en job): $cmd"
Start-Job -ScriptBlock { param($command,$log) Invoke-Expression $command *> $log } -ArgumentList $cmd,$log | Out-Null
Write-Host "Job iniciado. Revisa $log para ver la salida de ffmpeg."
