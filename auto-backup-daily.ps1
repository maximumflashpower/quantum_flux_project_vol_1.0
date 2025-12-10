$PROJECT = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"
$TODAY = Get-Date -Format "yyyy-MM-dd"
$OUT = "C:\Users\joseb\Downloads\quantum_flux_daily_$TODAY.zip"

if (Test-Path $OUT) {
    Write-Host "Backup for today already exists:"
    Write-Host $OUT
    exit
}

Write-Host "Creating daily backup..."
Compress-Archive -Path $PROJECT\* -DestinationPath $OUT

Write-Host "Daily backup completed:"
Write-Host $OUT
