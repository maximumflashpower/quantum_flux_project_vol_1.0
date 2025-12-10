$PROJECT = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"
$VERSION_FILE = "$PROJECT\backup_version.txt"

if (!(Test-Path $VERSION_FILE)) {
    Set-Content $VERSION_FILE "1"
}

$VERSION = Get-Content $VERSION_FILE
$OUT = "C:\Users\joseb\Downloads\quantum_flux_v$VERSION.zip"

Write-Host "Creating versioned backup v$VERSION..."
Compress-Archive -Path $PROJECT\* -DestinationPath $OUT

$NEXT = [int]$VERSION + 1
Set-Content $VERSION_FILE $NEXT

Write-Host "Backup created:"
Write-Host $OUT
Write-Host "Next version will be v$NEXT"
