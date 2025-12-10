# Quantum Flux Versioning System
# Incrementa automáticamente el número de versión del proyecto

$versionFile = "$PSScriptRoot\VERSION.txt"

# Si el archivo no existe, crea la versión inicial 1.0.0
if (!(Test-Path $versionFile)) {
    "1.0.0" | Out-File $versionFile
}

$version = Get-Content $versionFile
$parts = $version.Split(".")

# Incrementar BUILD (tercer número)
$parts[2] = [int]$parts[2] + 1

# Reconstruir versión completa
$newVersion = "$($parts[0]).$($parts[1]).$($parts[2])"

# Guardar nueva versión
$newVersion | Out-File $versionFile

Write-Host "Nueva versión generada: $newVersion"
