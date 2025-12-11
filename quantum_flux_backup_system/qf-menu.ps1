# Quantum Flux Backup System - Corporate UI v5 (Stable ASCII)

[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8

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

function Splash {
    Clear-Host
    $ver = Get-QFVersion
    Write-Host ""
    Write-Host "==================================================="
    Write-Host "           QUANTUM FLUX BACKUP SYSTEM"
    Write-Host "               Corporate Console v5"
    Write-Host "==================================================="
    Write-Host (" Version actual del sistema: {0}" -f $ver)
    Write-Host " Ruta base: proyecto Quantum Flux"
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
    Write-Host "                    v5 Corporate"
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

    Write-Host ""
    Write-Host "================ ESTADO DEL SISTEMA ================"
    Write-Host (" Version Quantum Flux: {0}" -f $version)

    if (Test-Path $logFile) {
        $lines = Get-Content $logFile
        $count = $lines.Count
        Write-Host (" Registros de backup: {0}" -f $count)
    } else {
        Write-Host " Registros de backup: 0 (log no encontrado)"
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
    Write-Host "0. Salir"
    Write-Host ""
}

Splash

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
            Start-Process explorer.exe "."
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
