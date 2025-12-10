# Quantum Flux Versioning System
# Incrementa automáticamente el número de versión del proyecto

$versionFile = "$PSScriptRoot\VERSION.txt"

if (!(Test-Path $versionFile)) {
    "1.0.0" | Out-File $versionFile
}

$version = Get-Content $versionFile
$parts = $version.Split(".")

$parts[2] = [int]$parts[2] + 1

$newVersion = "$($parts[0]).$($parts[1]).$($parts[2])"

$newVersion | Out-File $versionFile

Write-Host "Nueva versión generada: $newVersion"

# IMPORTANTE: devolver la versión para que otros scripts la usen
$newVersion
