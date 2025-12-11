# =====================================================
# Quantum Flux Backup System v8.1
# Archivo: backup-and-sync-github.ps1
# Funcion:
#   - Crear backup completo (ZIP)
#   - Calcular hash SHA256
#   - (Opcional) Encriptar ZIP con AES256
#   - Registrar en backup-log
#   - Hacer git add / commit / push
#   - Crear release en GitHub
#   - Generar reporte tecnico por backup
# =====================================================

# Ruta raiz del proyecto
$PROJECT = "C:\Users\joseb\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0"

# Opciones de configuracion
$ENABLE_ENCRYPTION = $false        # Cambiar a $true si quieres encriptar
$ENCRYPTION_PASSWORD = "CAMBIAR_ESTA_CLAVE"  # Cambiar antes de activar

# Rutas internas
$DATE       = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ZIP_NAME   = "quantum_flux_backup_$DATE.zip"
$ZIP_PATH   = Join-Path $PROJECT $ZIP_NAME

$SYSTEM_DIR = Join-Path $PROJECT "quantum_flux_backup_system"
$LOG_PATH   = Join-Path $SYSTEM_DIR "backup-log.txt"
$REPORTS_DIR = Join-Path $SYSTEM_DIR "reports"

if (-not (Test-Path $SYSTEM_DIR)) {
    New-Item -ItemType Directory -Path $SYSTEM_DIR | Out-Null
}
if (-not (Test-Path $REPORTS_DIR)) {
    New-Item -ItemType Directory -Path $REPORTS_DIR | Out-Null
}

$REPORT_FILE = Join-Path $REPORTS_DIR "QuantumFluxBackup_$DATE.txt"

# =====================================================
# Funciones auxiliares
# =====================================================

function Write-Section {
    param([string]$msg)
    Write-Host ""
    Write-Host "-----------------------------------------------------"
    Write-Host $msg
    Write-Host "-----------------------------------------------------"
}

function Protect-FileAes256 {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [string]$Password
    )

    if (-not (Test-Path $InputPath)) {
        throw "Archivo a encriptar no encontrado: $InputPath"
    }

    $bytes = [System.IO.File]::ReadAllBytes($InputPath)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Password)
    $keyHash = $sha.ComputeHash($keyBytes)

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256
    $aes.Key = $keyHash
    $aes.GenerateIV()

    $iv = $aes.IV

    $ms = New-Object System.IO.MemoryStream
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $aes.CreateEncryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)
    $cs.Write($bytes, 0, $bytes.Length)
    $cs.FlushFinalBlock()
    $cipherBytes = $ms.ToArray()
    $cs.Dispose()
    $ms.Dispose()
    $aes.Dispose()
    $sha.Dispose()

    $outBytes = New-Object byte[] ($iv.Length + $cipherBytes.Length)
    [Array]::Copy($iv, 0, $outBytes, 0, $iv.Length)
    [Array]::Copy($cipherBytes, 0, $outBytes, $iv.Length, $cipherBytes.Length)

    [System.IO.File]::WriteAllBytes($OutputPath, $outBytes)
}

# =====================================================
# Proceso principal
# =====================================================

$errors = @()
$status = "OK"
$hashValue = ""
$finalBackupPath = $ZIP_PATH
$finalBackupName = $ZIP_NAME

try {
    Write-Section "CREANDO ZIP"
    Write-Host "Origen: $PROJECT"
    Write-Host "Destino: $ZIP_PATH"
    Compress-Archive -Path "$PROJECT\*" -DestinationPath $ZIP_PATH -Force
    Write-Host "ZIP creado correctamente."
}
catch {
    $msg = "ERROR ZIP: " + $_.Exception.Message
    Write-Host $msg
    $errors += $msg
    $status = "ERROR"
}

if ($status -eq "OK") {
    try {
    Write-Section "CALCULANDO SHA256"
    $hash = Get-FileHash -Path $ZIP_PATH -Algorithm SHA256
    $hashValue = $hash.Hash
    Write-Host "SHA256: $hashValue"
    }
    catch {
        $msg = "ERROR HASH: " + $_.Exception.Message
        Write-Host $msg
        $errors += $msg
        $status = "ERROR"
    }
}

if ($status -eq "OK" -and $ENABLE_ENCRYPTION) {
    try {
        Write-Section "ENCRIPTANDO ZIP (AES256)"
        $encPath = $ZIP_PATH + ".aes"
        Protect-FileAes256 -InputPath $ZIP_PATH -OutputPath $encPath -Password $ENCRYPTION_PASSWORD
        Write-Host "Archivo encriptado: $encPath"

        # Opcional: eliminar el ZIP sin encriptar
        # Remove-Item $ZIP_PATH -Force

        $finalBackupPath = $encPath
        $finalBackupName = [System.IO.Path]::GetFileName($encPath)
    }
    catch {
        $msg = "ERROR ENCRIPTACION: " + $_.Exception.Message
        Write-Host $msg
        $errors += $msg
        $status = "ERROR"
    }
}

try {
    Write-Section "REGISTRO EN BACKUP-LOG"
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts`t$status`t$finalBackupName`t$hashValue"
    $line | Out-File -FilePath $LOG_PATH -Append -Encoding utf8
    Write-Host "Linea registrada en backup-log."
}
catch {
    $msg = "ERROR LOG: " + $_.Exception.Message
    Write-Host $msg
    $errors += $msg
    $status = "ERROR"
}

if ($status -eq "OK") {
    try {
        Write-Section "GIT ADD / COMMIT / PUSH"
        git add . | Out-Null
        git commit -m "Auto backup $DATE" | Out-Null
        git push | Out-Null
        Write-Host "Cambios enviados a GitHub (rama actual)."
    }
    catch {
        $msg = "ERROR GIT: " + $_.Exception.Message
        Write-Host $msg
        $errors += $msg
        $status = "ERROR"
    }
}

$releaseName = "backup-$DATE"
$releaseUrl  = "https://github.com/maximumflashpower/quantum_flux_project_vol_1.0/releases/tag/$releaseName"

if ($status -eq "OK") {
    try {
        Write-Section "CREANDO RELEASE EN GITHUB"
        gh release create $releaseName $finalBackupPath `
            --title "Backup $DATE" `
            --notes "Automatic Quantum Flux project backup created on $DATE" `
            --repo "maximumflashpower/quantum_flux_project_vol_1.0"
        Write-Host "Release creado correctamente."
    }
    catch {
        $msg = "ERROR RELEASE GH: " + $_.Exception.Message
        Write-Host $msg
        $errors += $msg
        $status = "ERROR"
    }
}

try {
    Write-Section "GENERANDO REPORTE TECNICO"
    $reportLines = @()
    $reportLines += "==============================================="
    $reportLines += " QUANTUM FLUX BACKUP REPORT (v8.1)"
    $reportLines += "==============================================="
    $reportLines += " Fecha:          $((Get-Date -Format "yyyy-MM-dd HH:mm:ss"))"
    $reportLines += " Estado:         $status"
    $reportLines += " Proyecto:       $PROJECT"
    $reportLines += " Archivo backup: $finalBackupName"
    $reportLines += " Ruta backup:    $finalBackupPath"
    if ($hashValue -ne "") {
        $reportLines += " SHA256:         $hashValue"
    } else {
        $reportLines += " SHA256:         N/D"
    }
    $reportLines += " Encriptado:     " + $(if ($ENABLE_ENCRYPTION) { "SI (AES256)" } else { "NO" })
    $reportLines += " Release GH:     $releaseName"
    $reportLines += " URL Release:    $releaseUrl"
    if ($errors.Count -gt 0) {
        $reportLines += "-----------------------------------------------"
        $reportLines += " ERRORES ENCONTRADOS:"
        foreach ($e in $errors) {
            $reportLines += " - $e"
        }
    } else {
        $reportLines += " Sin errores reportados."
    }
    $reportLines += "==============================================="
    $reportLines += " FIN DEL REPORTE"
    $reportLines += "==============================================="

    Set-Content -Path $REPORT_FILE -Value $reportLines -Encoding utf8

    Write-Host "Reporte generado:"
    Write-Host "  $REPORT_FILE"
}
catch {
    $msg = "ERROR REPORTE: " + $_.Exception.Message
    Write-Host $msg
    $errors += $msg
}

Write-Section "RESUMEN FINAL"

Write-Host "Estado: $status"
Write-Host "Backup: $finalBackupName"
if ($hashValue -ne "") {
    Write-Host "SHA256: $hashValue"
}
Write-Host "Reporte: $REPORT_FILE"
Write-Host "Release URL (si aplica):"
Write-Host "  $releaseUrl"
Write-Host ""
Write-Host "Proceso de backup v8.1 finalizado."
Write-Host "==================================================="
