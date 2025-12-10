[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Menu {
    Clear-Host
    Write-Host "====================================="
    Write-Host "      QUANTUM FLUX BACKUP MENU"
    Write-Host "====================================="
    Write-Host "1. Crear Backup Completo"
    Write-Host "2. Backup + Release en GitHub"
    Write-Host "3. Backup Incremental"
    Write-Host "4. Abrir carpeta del proyecto"
    Write-Host "5. Abrir releases de GitHub"
    Write-Host "0. Salir"
}

while ($true) {
    Show-Menu
    
    Write-Host "Selecciona opcion: " -NoNewline
    $opt = [Console]::ReadLine()

    switch ($opt) {
        "1" { .\backup-and-sync-github.ps1 }
        "2" { .\backup-and-sync-github.ps1 }
        "3" { .\quantum_flux_backup_system\backup-incremental.ps1 }
        "4" { Start-Process explorer.exe "." }
        "5" { Start-Process "https://github.com/maximumflashpower/quantum_flux_project_vol_1.0/releases" }
        "0" { break }
        default { Write-Host "Opcion invalida" }
    }
}
