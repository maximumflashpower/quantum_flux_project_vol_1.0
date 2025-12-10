param(
    [string]$ZipPath,
    [string]$RestorePath = "C:\Users\joseb\Downloads\QuantumFlux_Restored"
)

if (-not (Test-Path $ZipPath)) {
    Write-Host "ERROR: ZIP file not found."
    exit
}

Write-Host "Restoring ZIP to:"
Write-Host $RestorePath

if (Test-Path $RestorePath) {
    Remove-Item $RestorePath -Recurse -Force
}

Expand-Archive -Path $ZipPath -DestinationPath $RestorePath

Write-Host "Restore complete."
