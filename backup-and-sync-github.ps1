# BACKUP-AND-SYNC-GITHUB.PS1
# Backup completo + commit + push + release en GitHub
# Con log automático y versionado básico

$projectRoot = $PSScriptRoot                              # raíz del proyecto
$toolsRoot   = Join-Path $projectRoot "quantum_flux_backup_system"
$logFile     = Join-Path $toolsRoot "backup-log.txt"

if (!(Test-Path $toolsRoot)) {
    New-Item -ItemType Directory -Path $toolsRoot | Out-Null
}

if (!(Test-Path $logFile)) {
    New-Item -ItemType File -Path $logFile | Out-Null
}

function Write-Log($type, $message) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts`t$($type.ToUpper())`t$message" | Add-Content $logFile
}

$DATE     = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ZIP_NAME = "quantum_flux_backup_$DATE.zip"
$ZIP_PATH = Join-Path $projectRoot $ZIP_NAME

Write-Host "Creating ZIP backup..."
Write-Log "INFO" "Iniciando backup completo $ZIP_NAME"

# Crear ZIP
if (Test-Path $ZIP_PATH) {
    Remove-Item $ZIP_PATH -Force
}

Compress-Archive -Path "$projectRoot\*" -DestinationPath $ZIP_PATH -Force

Write-Host "ZIP created:"
Write-Host $ZIP_PATH
Write-Log "INFO" "ZIP creado en $ZIP_PATH"

# Versioning (opcional)
$versionScript = Join-Path $toolsRoot "qf-versioning.ps1"
if (Test-Path $versionScript) {
    $version = & $versionScript
    if ($version) {
        Write-Log "INFO" "Versión de build: $version"
    }
}

# Git add + commit + push
Write-Host "Adding files to Git..."
Write-Log "INFO" "Ejecutando git add ."
git add . | Out-Null

Write-Host "Creating commit..."
$commitMsg = "Auto backup $DATE"
git commit -m "$commitMsg" | Out-Null
Write-Log "INFO" "Commit creado: $commitMsg"

Write-Host "Pushing to GitHub..."
git push | Out-Null
Write-Log "INFO" "Push enviado a remoto."

# Crear release en GitHub
Write-Host "Creating GitHub Release..."
$tagName = "backup-$DATE"
$releaseTitle = "Backup $DATE"
$releaseBody  = "Automatic Quantum Flux project backup created on $DATE"

gh release create "$tagName" "$ZIP_PATH" -t "$releaseTitle" -n "$releaseBody"

$releaseUrl = "https://github.com/maximumflashpower/quantum_flux_project_vol_1.0/releases/tag/$tagName"
Write-Host $releaseUrl
Write-Log "INFO" "Release creado: $releaseUrl"

Write-Host "-------------------------------------------"
Write-Host "BACKUP SYNC COMPLETE"
Write-Host "Release created on GitHub:"
Write-Host $releaseUrl
Write-Host "-------------------------------------------"

Write-Log "SUCCESS" "Backup completo y release creado correctamente."
