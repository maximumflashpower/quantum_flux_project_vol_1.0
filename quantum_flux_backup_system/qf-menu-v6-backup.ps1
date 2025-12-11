# Quantum Flux Backup System - Corporate UI v6 (Stable ASCII)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Raiz del proyecto (la carpeta padre de quantum_flux_backup_system)
$projectRoot = Split-Path $PSScriptRoot -Parent

function Get-QFVersion {
    $versionFile = Join-Path $PSScriptRoot "VERSION.txt"
    if (Test-Path $versionFile) {
        try {
            $v = Get-Content $versionFile | Select-Object -First 1
            if ([string]::IsNullOrWhiteSpace($v)) { return "1.0.0" }
            return $v
        } catch {
            return "1.0.0"
        }
    } else {
        return "1.0.0"
    }
}

function Get-LastBackup {
    param(
        [string]$root
    )
    if (-not (Test-Path $root)) {
        return $null
    }

    $files = Get-ChildItem $root -Filter "quantum_flux_backup_*.zip" -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending

    if ($files -and $files.Count -gt 0) {
        return $files[0]
    } else {
        return $null
    }
}

function Splash {
    Clear-Host
    $ver = Get-QFVersion
    $last = Get-LastBackup -root $projectRoot

    Write-Host ""
    Write-Host "==================================================="
    Write-Host "           QUANTUM FLUX BACKUP SYSTEM"
    Write-Host "               Corporate Console v6"
    Write-Host "==================================================="
    Write-Host (" Version actual del sistema: {0}" -f $ver)
    Write-Host (" Ruta base del proyecto: {0}" -f $projectRoot)

    if ($last -ne $null) {
        Write-Host (" Ultimo backup: {0} ({1})" -f $last.Name, $last.LastWriteTime)
    } else {
        Write-Host " Ultimo backup: ninguno encontrado"
    }

    Write-Host "==================================================="
    Write-Host ""
    Write-Host "Inicializando modulo de respaldo..."
    Start-Sleep -Milliseconds 400
    Write-Host "Verificando componentes basicos..."
    Start-Sleep -Milliseconds 400
    Write-Host "Sistema listo."
    Start-Sleep -Milliseconds 400
}

function Header {
    Clear-Host
    Write-Host ""
    Write-Host "==================================================="
    Write-Host "             QUANTUM FLUX BACKUP MENU"
    Write-Host "                    v6 Corporate"
    Write-Host "==================================================="
    Write-Host ""
}

function ProgressBar {
    param([string]$msg)
    Write-Host ""
    Write-Host $msg
    Write-Host ""

    for ($i = 1; $i -le 20; $i++) {
        $bar = "#" * $i
        $pct = [int](($i / 20) * 100)
        Write-Host ("[{0}] {1}%%" -f $bar.PadRight(20), $pct)
        Start-Sleep -Milliseconds 70

        if ($i -ne 20) {
            [Console]::SetCursorPosition(0, [Console]::CursorTop - 1)
        }
    }
    Write-Host ""
}

function ShowStatus {
    $toolsRoot = $PSScriptRoot
    $logFile   = Join-Path $toolsRoot "backup-log.txt"
    $version   = Get-QFVersion
    $last      = Get-LastBackup -root $projectRoot

    Write-Host ""
    Write-Host "================ ESTADO DEL SISTEMA ================"
    Write-Host (" Version Quantum Flux: {0}" -f $version)
    Write-Host (" Ruta del proyecto: {0}" -f $projectRoot)

    if ($last -ne $null) {
        Write-Host (" Ultimo backup: {0}" -f $last.Name)
        Write-Host (" Fecha ultimo backup: {0}" -f $last.LastWriteTime)
    } else {
        Write-Host " Ultimo backup: ninguno encontrado"
    }

    if (Test-Path $logFile) {
        $lines = Get-Content $logFile
        $count = $lines.Count
        Write-Host (" Registros en backup-log: {0}" -f $count)
    } else {
        Write-Host " Registros en backup-log: 0 (archivo no encontrado)"
    }

    $gitOk = (Get-Command git -ErrorAction SilentlyContinue) -ne $null
    $ghOk  = (Get-Command gh  -ErrorAction SilentlyContinue) -ne $null

    Write-Host (" Git instalado: {0}" -f $(if ($gitOk) { "SI" } else { "NO" }))
    Write-Host (" GitHub CLI instalado: {0}" -f $(if ($ghOk) { "SI" } else { "NO" }))
    Write-Host " Estado general: OPERATIVO"
    Write-Host "==================================================="
    Write-Host ""
    Pause
}

function Open-RestoreFolder {
    $restoreRoot = Join-Path $env:USERPROFILE "Documents\QuantumFluxRestore"
    if (-not (Test-Path $restoreRoot)) {
        New-Item -ItemType Directory -Path $restoreRoot | Out-Null
    }
    Start-Process explorer.exe $restoreRoot
}

function Menu {
    Header
    Write-Host "1. Crear Backup Completo"
    Write-Host "2. Backup + Release en GitHub"
    Write-Host "3. Backup Incremental"
    Write-Host "4. Abrir carpeta del proyecto"
    Write-Host "5. Abrir releases de GitHub"
    Write-Host "6. Restaurar Backup"
    Write-Host "7. Ver Log del Sistema"
    Write-Host "8. Ver Estado del Sistema"
    Write-Host "9. Abrir carpeta de Restauraciones"
    Write-Host "0. Salir"
    Write-Host ""
}

# Mostrar splash inicial
Splash

# Loop principal
while ($true) {

    Menu
    $opt = Read-Host "Seleccione una opcion"

    switch ($opt) {

        "1" {
            ProgressBar "Ejecutando backup completo..."
            .\backup-and-sync-github.ps1
            Pause
        }

        "2" {
            ProgressBar "Creando backup + release..."
            .\backup-and-sync-github.ps1
            Pause
        }

        "3" {
            ProgressBar "Creando backup incremental..."
            .\quantum_flux_backup_system\backup-incremental.ps1
            Pause
        }

        "4" {
            Start-Process explorer.exe $projectRoot
        }

        "5" {
            Start-Process "https://github.com/maximumflashpower/quantum_flux_project_vol_1.0/releases"
        }

        "6" {
            .\quantum_flux_backup_system\restore-backup.ps1
            Pause
        }

        "7" {
            notepad .\quantum_flux_backup_system\backup-log.txt
        }

        "8" {
            ShowStatus
        }

        "9" {
            Open-RestoreFolder
        }

        "0" {
            Write-Host ""
            Write-Host "Cerrando sistema Quantum Flux..."
            Start-Sleep -Milliseconds 400
            Write-Host "Sesion finalizada."
            Start-Sleep -Milliseconds 300
            break
        }

        default {
            Write-Host ""
            Write-Host "Opcion invalida."
            Start-Sleep -Milliseconds 600
        }
    }
}
