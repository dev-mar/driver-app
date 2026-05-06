# Detiene daemons de Gradle (suelen bloquear archivos .dex en build\) y ejecuta flutter clean.
# El error "Failed to remove build" en Windows NO viene del código de UCrop; es un archivo
# en uso por java/Gradle, Android Studio, antivirus, o un flutter build en curso.
#
# Uso (desde texi_driver_app):
#   .\scripts\flutter-clean-safe.ps1
# Si sigue fallando, cerrá Android Studio por completo y:
#   .\scripts\flutter-clean-safe.ps1 -KillGradleJava
#
# JAVA_HOME: si no está definido, se intenta el JBR típico de Android Studio.

param(
  [switch]$KillGradleJava
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Test-JavaHome {
  param([string]$JdkRoot)
  return $JdkRoot -and (Test-Path (Join-Path $JdkRoot "bin\java.exe"))
}

if (-not (Test-JavaHome $env:JAVA_HOME)) {
  $candidates = @(
    "$env:ProgramFiles\Android\Android Studio\jbr",
    "${env:ProgramFiles(x86)}\Android\Android Studio\jbr",
    "$env:LOCALAPPDATA\Programs\Android Studio\jbr"
  )
  foreach ($c in $candidates) {
    if (Test-JavaHome $c) {
      $env:JAVA_HOME = $c
      Write-Host "JAVA_HOME no estaba definido; usando: $env:JAVA_HOME"
      break
    }
  }
}

if (Test-JavaHome $env:JAVA_HOME) {
  Push-Location (Join-Path $root "android")
  try {
    Write-Host "Deteniendo Gradle (--stop)..."
    & .\gradlew.bat --stop 2>&1 | Out-Host
  } finally {
    Pop-Location
  }
  Start-Sleep -Seconds 4
} else {
  Write-Warning "JAVA_HOME no encontrado (ni rutas típicas de Android Studio). gradlew --stop se omite."
  Write-Warning "Definí JAVA_HOME al JBR del Android Studio y repetí, o cerrá procesos Java/Gradle a mano."
}

if ($KillGradleJava) {
  Write-Host "Buscando procesos java.exe de Gradle daemon..."
  $killed = 0
  Get-CimInstance Win32_Process -Filter "Name = 'java.exe'" -ErrorAction SilentlyContinue |
    Where-Object {
      $cmd = $_.CommandLine
      $cmd -and (
        $cmd -match 'GradleDaemon' -or
        $cmd -match 'org\.gradle\.launcher\.daemon' -or
        $cmd -match 'worker\.org\.gradle\.process\.internal\.worker\.GradleWorkerMain'
      )
    } |
    ForEach-Object {
      Write-Host "  Forzar cierre PID $($_.ProcessId)"
      Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
      $killed++
    }
  if ($killed -eq 0) { Write-Host "  (ninguno encontrado)" }
  Start-Sleep -Seconds 3
}

Write-Host "Ejecutando flutter clean..."
$ErrorActionPreference = "Continue"
flutter clean
exit $LASTEXITCODE
