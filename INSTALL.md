# Installation - ComptaFolders

## Prerequis

- Windows 10 / 11
- PowerShell 5.1 ou superieur
- .NET Framework (pour WPF) - inclus dans Windows

## Installation rapide (EXE)

1. Telechargez la derniere release depuis la page GitHub Releases.
2. Extrayez l'archive dans un dossier (ex. `C:\ComptaFolders`).
3. Verifiez que les fichiers suivants sont presents :
   - `ComptaFolders.exe`
   - `ComptaFolders.ps1`
   - `AppVersion.ps1`
   - `lib\DossierClient.psm1`
   - `Resources\` (MainWindow.xaml, app.ico, templates, ...)
4. Lancez `ComptaFolders.exe`.

L'EXE est un lanceur dynamique : les modifications de `ComptaFolders.ps1` ou des modules sont prises en compte sans recompiler l'EXE.

## Installation depuis les sources

1. Clonez le depot :
   ```powershell
   git clone https://github.com/DevopsAbdel/ComptaFolders.git
   cd ComptaFolders
   ```
2. Lancez directement le script :
   ```powershell
   .\ComptaFolders.ps1
   ```
3. (Optionnel) Recompilez l'EXE :
   ```powershell
   .\Build-Exe.ps1
   ```
   Necessite le module `ps2exe` (`Install-Module ps2exe`).

## Installateur (Inno Setup)

Un script d'installation Inno Setup est fourni dans `installer\ComptaFolders.iss`.
Pour generer l'installateur :

1. Installez [Inno Setup](https://jrsoftware.org/isinfo.php).
2. Ouvrez `installer\ComptaFolders.iss` dans Inno Setup Compiler.
3. Compilez (Build > Compile).

L'installateur cree :
- Un raccourci sur le Bureau.
- Un raccourci dans le Menu Demarrer.
- Une entree de desinstallation propre (Panneau de configuration).

## Desinstallation

- Via l'installateur : Panneau de configuration > Programmes > Desinstaller ComptaFolders.
- Installation manuelle : supprimez simplement le dossier d'installation.