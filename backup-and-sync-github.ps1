# ============================================
# Auto Backup + GitHub Sync
# Repo: maximumflashpower/quantum_flux_project_vol_1.0
# ============================================

$PROJECT = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ZIP = "quantum_flux_backup_$DATE.zip"
$ZIP_PATH = "$PROJECT\$ZIP"

Write-Host "Creating ZIP backup..."
Compress-Archive -Path $PROJECT\* -DestinationPath $ZIP_PATH -Force

Write-Host "ZIP created:"
Write-Host $ZIP_PATH

# --------------------------------------------
# Git Commit and Push
# --------------------------------------------

Write-Host "Adding files to Git..."
git add . 

Write-Host "Creating commit..."
git commit -m "Auto backup $DATE"

Write-Host "Pushing to GitHub..."
git push origin main

# --------------------------------------------
# GitHub Release
# --------------------------------------------

Write-Host "Creating GitHub Release..."

gh release create "backup-$DATE" $ZIP_PATH `
    --repo maximumflashpower/quantum_flux_project_vol_1.0 `
    --title "Backup $DATE" `
    --notes "Automatic Quantum Flux project backup created on $DATE"

Write-Host "-------------------------------------------"
Write-Host "BACKUP SYNC COMPLETE"
Write-Host "Release created on GitHub:"
Write-Host "https://github.com/maximumflashpower/quantum_flux_project_vol_1.0/releases/tag/backup-$DATE"
Write-Host "-------------------------------------------"
