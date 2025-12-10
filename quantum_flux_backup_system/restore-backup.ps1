# RESTORE-BACKUP.PS1
# Restaura un backup de Quantum Flux en:
# C:\Users\<USER>\Documents\QuantumFluxRestore\Restore_YYYY-MM-DD_HH-mm-ss\

$toolsRoot    = $PSScriptRoot                       # ...\quantum_flux_backup_system
$projectRoot  = Split-Path $toolsRoot -Parent       # carpeta raíz del proyecto
$restoreRoot  = Join-Path $env:USERPROFILE "Documents\QuantumFluxRestore"

if (!(Test-Path $restoreRoot)) {
    New-Item -ItemType Directory -Path $restoreRoot | Out-Null
}

$backups = Get-ChildItem $projectRoot -Filter "quantum_flux_backup_*.zip" |
           Sort-Object LastWriteTime -Descending

if (-not $backups -or $backups.Count -eq 0) {
    Write-Host "No se encontraron archivos de backup en el proyecto."
    exit
}

Write-Host "====================================="
Write-Host "   RESTAURAR BACKUP QUANTUM FLUX"
Write-Host "====================================="
Write-Host ""

$index = 1
foreach ($b in $backups) {
    Write-Host ("{0}. {1}  ({2})" -f $index, $b.Name, $b.LastWriteTime)
    $index++
}

Write-Host ""
Write-Host "Seleccione el número del backup a restaurar:"
$choice = Read-Host "Número"

if (-not [int]::TryParse($choice, [ref]0)) {
    Write-Host "Entrada inválida."
    exit
}

$choice = [int]$choice
if ($choice -lt 1 -or $choice -gt $backups.Count) {
    Write-Host "Número fuera de rango."
    exit
}

$selected = $backups[$choice - 1]
$stamp    = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$destDir  = Join-Path $restoreRoot ("Restore_" + $stamp)

New-Item -ItemType Directory -Path $destDir | Out-Null

Write-Host ""
Write-Host "Restaurando:"
Write-Host "  $($selected.FullName)"
Write-Host "en:"
Write-Host "  $destDir"
Write-Host ""

Expand-Archive -Path $selected.FullName -DestinationPath $destDir -Force

# Log simple en backup-log.txt si existe
$logFile = Join-Path $toolsRoot "backup-log.txt"
if (Test-Path $logFile) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts`tRESTORE`t$($selected.Name)`t$destDir" | Add-Content $logFile
}

Write-Host ""
Write-Host "✅ Restauración completada."
Write-Host "Carpeta restaurada:"
Write-Host "  $destDir"
