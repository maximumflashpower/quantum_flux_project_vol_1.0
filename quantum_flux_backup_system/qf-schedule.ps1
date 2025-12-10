# Crear tarea programada para backup automático diario

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-File `"$env:USERPROFILE\Downloads\chatgpt_organized_quantum_flux_project\quantum_flux_project_vol_1.0\backup-and-sync-github.ps1`""

$trigger = New-ScheduledTaskTrigger -Daily -At 00:00

Register-ScheduledTask -TaskName "QuantumFluxDailyBackup" `
    -Action $action `
    -Trigger $trigger `
    -Description "Backup automático diario Quantum Flux"

Write-Host "Tarea programada creada correctamente."
