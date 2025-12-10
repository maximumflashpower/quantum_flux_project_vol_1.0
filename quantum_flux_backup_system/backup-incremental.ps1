# BACKUP INCREMENTAL INTELIGENTE QUANTUM FLUX

$PROJECT = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$DEST = "$PROJECT\incremental_backup_$DATE.zip"

# Buscar archivos modificados en últimas 24 horas
$files = Get-ChildItem $PROJECT -Recurse |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }

if ($files.Count -eq 0) {
    Write-Host "No hay archivos modificados en últimas 24 horas."
    exit
}

Compress-Archive -Path $files.FullName -DestinationPath $DEST

Write-Host "Backup incremental creado correctamente:"
Write-Host $DEST
