$PROJECT = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$OUT = "C:\Users\joseb\Downloads\quantum_flux_backup_$DATE.zip"

Write-Host "Creating dated backup..."
Compress-Archive -Path $PROJECT\* -DestinationPath $OUT

Write-Host "Backup complete:"
Write-Host $OUT
