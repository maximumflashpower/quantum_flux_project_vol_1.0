# Export project folder to ZIP safely
$PROJECT_PATH = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"
$ZIP_OUTPUT = "C:\Users\joseb\Downloads\quantum_flux_project_backup.zip"

Write-Host "Creating ZIP backup..."
Write-Host "Source: $PROJECT_PATH"
Write-Host "Destination: $ZIP_OUTPUT"

if (Test-Path $ZIP_OUTPUT) {
    Write-Host "Existing ZIP found. Removing old file..."
    Remove-Item $ZIP_OUTPUT -Force
}

Compress-Archive -Path $PROJECT_PATH\* -DestinationPath $ZIP_OUTPUT

Write-Host "-------------------------------------------"
Write-Host "ZIP BACKUP CREATED SUCCESSFULLY!"
Write-Host "FILE LOCATION:"
Write-Host $ZIP_OUTPUT
Write-Host "-------------------------------------------"
