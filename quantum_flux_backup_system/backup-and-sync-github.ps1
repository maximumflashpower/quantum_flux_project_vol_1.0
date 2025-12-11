# =====================================================
# Quantum Flux Backup System v8
# Archivo: backup-and-sync-github.ps1
# Funcion: Backup completo + GitHub Release
# =====================================================

$PROJECT = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ZIP_NAME = "quantum_flux_backup_$DATE.zip"
$ZIP_PATH = Join-Path $PROJECT $ZIP_NAME
$LOG_PATH = Join-Path $PROJECT\quantum_flux_backup_system "backup-log.txt"
$RESTORE_FOLDER = "$HOME\Documents\QuantumFluxRestore"

Write-Host "Creating ZIP backup..."
Compress-Archive -Path "$PROJECT\*" -DestinationPath $ZIP_PATH -Force

Write-Host "ZIP created:"
Write-Host $ZIP_PATH

# ==============================================
# Registrar en backup-log
# ==============================================
"[$(Get-Date)] BACKUP CREATED: $ZIP_NAME" | Out-File -FilePath $LOG_PATH -Append -Encoding utf8

# ==============================================
# Git Add + Commit + Push
# ==============================================
Write-Host "Adding files to Git..."
git add . | Out-Null

Write-Host "Creating commit..."
git commit -m "Auto backup $DATE" | Out-Null

Write-Host "Pushing to GitHub..."
git push | Out-Null

# ==============================================
# GitHub Release
# ==============================================
Write-Host "Creating GitHub Release..."

$releaseName = "backup-$DATE"

gh release create $releaseName $ZIP_PATH `
    --title "Backup $DATE" `
    --notes "Automatic Quantum Flux project backup created on $DATE" `
    --repo "maximumflashpower/quantum_flux_project_vol_1.0"

Write-Host "-------------------------------------------"
Write-Host "BACKUP SYNC COMPLETE"
Write-Host "Release created on GitHub:"
Write-Host "https://github.com/maximumflashpower/quantum_flux_project_vol_1.0/releases/tag/$releaseName"
Write-Host "-------------------------------------------"
