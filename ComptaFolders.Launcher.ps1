#Requires -Version 5.1
# Lanceur dynamique : charge ComptaFolders.ps1 a cote de l'EXE au demarrage.
# L'EXE n'embarque plus le code metier : toute modification de ComptaFolders.ps1
# ou de lib\DossierClient.psm1 est prise en compte sans recompiler l'EXE.

$ErrorActionPreference = 'Stop'

try {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
} catch {}

$scriptDir = [System.AppDomain]::CurrentDomain.BaseDirectory
if (-not $scriptDir -or -not (Test-Path -LiteralPath $scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir -or -not (Test-Path -LiteralPath $scriptDir)) {
    $scriptDir = $PSScriptRoot
}
if (-not $scriptDir -or -not (Test-Path -LiteralPath $scriptDir)) {
    $scriptDir = (Get-Location).Path
}

$target = Join-Path $scriptDir 'ComptaFolders.ps1'
if (-not (Test-Path -LiteralPath $target)) {
    [System.Windows.Forms.MessageBox]::Show(
        "ComptaFolders.ps1 introuvable dans :`n$scriptDir",
        "ComptaFolders - Erreur",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}

try {
    & $target
} catch {
    [System.Windows.Forms.MessageBox]::Show(
        "Erreur au demarrage :`n$($_.Exception.Message)",
        "ComptaFolders - Erreur",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    exit 1
}