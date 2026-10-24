@echo off
REM Script batch historique de creation rapide de dossiers clients (majuscules)
REM Usage: creer_dossiers_majuscules.bat "Nom Societe" "Annee" "CheminParent"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0lib\DossierClient.psm1'; $r = New-ClientDossier -Year %~2 -CompanyName '%~1' -ParentPath '%~3'; Write-Host $r"