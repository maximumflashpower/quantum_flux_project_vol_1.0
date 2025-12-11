# Quantum Flux Backup System - Corporate UI v8 (Stable ASCII)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Raiz del proyecto (carpeta padre de quantum_flux_backup_system)
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
    $ver  = Get-QFVersion
    $last = Get-LastBackup -root $projectRoot

    Write-Host ""
    Write-Host "==================================================="
    Write-Host "           QUANTUM FLUX BACKUP SYSTEM"
    Write-Host "               Corporate Console v8"
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
    Write-Host "                    v8 Corporate"
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
        $line = "[" + $bar.PadRight(20) + "] " + $pct + "%"
        Write-Host $line
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

function Clean-OldBackups {
    $toolsRoot   = $PSScriptRoot
    $logFile     = Join-Path $toolsRoot "backup-log.txt"
    $restoreRoot = Join-Path $env:USERPROFILE "Documents\QuantumFluxRestore"
    $keepCount   = 6

    Write-Host ""
    Write-Host "=========== LIMPIEZA AUTOMATICA DE BACKUPS ========="
    Write-Host (" Carpeta proyecto: {0}" -f $projectRoot)
    Write-Host (" Carpeta restauraciones: {0}" -f $restoreRoot)
    Write-Host (" Mantener ultimos: {0} backups y restauraciones" -f $keepCount)
    Write-Host "===================================================="
    Write-Host ""

    if (Test-Path $projectRoot) {
        $backups = Get-ChildItem $projectRoot -Filter "quantum_flux_backup_*.zip" -ErrorAction SilentlyContinue |
                   Sort-Object LastWriteTime -Descending

        if ($backups.Count -gt $keepCount) {
            $toDelete = $backups[$keepCount..($backups.Count - 1)]
            foreach ($f in $toDelete) {
                Write-Host (" Eliminando backup antiguo: {0}" -f $f.FullName)
                Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host " No hay suficientes backups para limpiar (se mantienen todos)."
        }
    } else {
        Write-Host " Ruta del proyecto no encontrada."
    }

    if (Test-Path $restoreRoot) {
        $dirs = Get-ChildItem $restoreRoot -Directory -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending

        if ($dirs.Count -gt $keepCount) {
            $toDeleteDirs = $dirs[$keepCount..($dirs.Count - 1)]
            foreach ($d in $toDeleteDirs) {
                Write-Host (" Eliminando carpeta de restauracion antigua: {0}" -f $d.FullName)
                Remove-Item $d.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host " No hay suficientes restauraciones para limpiar (se mantienen todas)."
        }
    } else {
        Write-Host " Carpeta de restauraciones no encontrada (se creara cuando se restaure algo)."
    }

    if (Test-Path $logFile) {
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$ts`tCLEAN`tLimpieza automatica de backups y restauraciones ejecutada." | Add-Content $logFile
    }

    Write-Host ""
    Write-Host " Limpieza automatica completada."
    Write-Host "===================================================="
    Write-Host ""
    Pause
}

function Open-Dashboard {
    $dashFile = Join-Path $PSScriptRoot "qf-dashboard.html"
    if (Test-Path $dashFile) {
        Start-Process $dashFile
    } else {
        Write-Host ""
        Write-Host "Archivo qf-dashboard.html no encontrado en:"
        Write-Host "  $PSScriptRoot"
        Write-Host "Cree el dashboard o copie el archivo en esa ruta."
        Write-Host ""
        Pause
    }
}

function Schedule-BackupDaily {
    $taskName   = "QuantumFluxDailyBackup"
    $scriptPath = Join-Path $projectRoot "backup-and-sync-github.ps1"
    if (-not (Test-Path $scriptPath)) {
        Write-Host ""
        Write-Host "No se encuentra backup-and-sync-github.ps1 en:"
        Write-Host "  $projectRoot"
        Write-Host "No se puede crear tarea programada."
        Write-Host ""
        Pause
        return
    }

    Write-Host ""
    Write-Host "Creando tarea programada diaria (21:00) para:"
    Write-Host "  $scriptPath"
    Write-Host ""

    $psExe  = "powershell.exe"
    $psArgs = "-ExecutionPolicy Bypass -File `"$scriptPath`""

    Start-Process schtasks.exe -ArgumentList "/Create","/TN",$taskName,"/SC","DAILY","/ST","21:00","/F","/TR","$psExe $psArgs" -NoNewWindow -Wait

    Write-Host ""
    Write-Host "Tarea programada creada (QuantumFluxDailyBackup)."
    Write-Host "Puede revisarla en el Programador de Tareas de Windows."
    Write-Host ""
    Pause
}

function Generate-Report {
    $toolsRoot   = $PSScriptRoot
    $logFile     = Join-Path $toolsRoot "backup-log.txt"
    $restoreRoot = Join-Path $env:USERPROFILE "Documents\QuantumFluxRestore"
    $reportFile  = Join-Path $toolsRoot "QuantumFluxBackupReport.txt"
    $version     = Get-QFVersion
    $last        = Get-LastBackup -root $projectRoot

    $lines = @()
    $lines += "==============================================="
    $lines += " QUANTUM FLUX BACKUP REPORT"
    $lines += "==============================================="
    $lines += " Fecha reporte:  " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $lines += " Version sistema: " + $version
    $lines += " Ruta proyecto:   " + $projectRoot

    if ($last -ne $null) {
        $lines += " Ultimo backup:   " + $last.Name
        $lines += " Fecha ultimo:    " + $last.LastWriteTime
        $lines += " Tamaño ultimo:   " + ("{0:N2} MB" -f ($last.Length / 1MB))
    } else {
        $lines += " Ultimo backup:   ninguno encontrado"
    }

    if (Test-Path $logFile) {
        $logLines = Get-Content $logFile
        $lines += " Registros en backup-log: " + $logLines.Count
    } else {
        $lines += " backup-log: no encontrado"
    }

    if (Test-Path $restoreRoot) {
        $dirs = Get-ChildItem $restoreRoot -Directory -ErrorAction SilentlyContinue
        $lines += " Carpetas de restauracion: " + $dirs.Count
    } else {
        $lines += " Carpeta de restauracion: no existe aun"
    }

    $gitOk = (Get-Command git -ErrorAction SilentlyContinue) -ne $null
    $ghOk  = (Get-Command gh  -ErrorAction SilentlyContinue) -ne $null

    $lines += " Git instalado:   " + $(if ($gitOk) { "SI" } else { "NO" })
    $lines += " GitHub CLI:      " + $(if ($ghOk) { "SI" } else { "NO" })

    $lines += "==============================================="
    $lines += " FIN DEL REPORTE"
    $lines += "==============================================="

    Set-Content -Path $reportFile -Value $lines

    Write-Host ""
    Write-Host "Reporte generado en:"
    Write-Host "  $reportFile"
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
    Write-Host "9. Abrir carpeta de Restauraciones"
    Write-Host "10. Limpiar Backups Antiguos"
    Write-Host "11. Abrir Dashboard HTML"
    Write-Host "12. Programar Backup Diario (21:00)"
    Write-Host "13. Generar Reporte de Sistema"
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

        "10" {
            Clean-OldBackups
        }

        "11" {
            Open-Dashboard
        }

        "12" {
            Schedule-BackupDaily
        }

        "13" {
            Generate-Report
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
