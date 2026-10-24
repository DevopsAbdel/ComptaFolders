#Requires -Version 5.1
# Construit ComptaFolders.exe a partir du lanceur dynamique ComptaFolders.Launcher.ps1.
# La version est lue depuis AppVersion.ps1 pour rester synchronisee.

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

. (Join-Path $scriptDir 'AppVersion.ps1')

if (-not (Get-Module -ListAvailable ps2exe)) {
    throw "Le module ps2exe est requis. Installez-le avec : Install-Module ps2exe"
}
Import-Module ps2exe -Force

Invoke-PS2EXE `
    -inputFile (Join-Path $scriptDir 'ComptaFolders.Launcher.ps1') `
    -outputFile (Join-Path $scriptDir 'ComptaFolders.exe') `
    -noConsole -STA `
    -iconFile (Join-Path $scriptDir 'Resources\app.ico') `
    -title $AppName `
    -product $AppName `
    -version $AppVersion

Write-Host "EXE genere : ComptaFolders.exe (v$AppVersion)"