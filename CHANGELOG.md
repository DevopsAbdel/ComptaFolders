# Changelog

Toutes les modifications notables de ce projet sont documentees dans ce fichier.
Le format est base sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
et ce projet adhere au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2026-10-24

### Ajoute
- Lanceur dynamique `ComptaFolders.exe` : charge `ComptaFolders.ps1` et les modules au demarrage, plus besoin de recompiler l'EXE a chaque modification.
- Ecran "A propos" affichant le nom, la version, l'auteur, le chemin de l'application et la version PowerShell.
- Systeme de version centralise via `AppVersion.ps1` (utilise par l'interface, l'EXE et les releases GitHub).
- Verification des mises a jour GitHub avec notification et ouverture de la page de telechargement.
- Barre de titre sombre (DWM) pour Windows 11.
- Workflows GitHub Actions : CI (tests Pester) et Release (build EXE + publication).

### Modifie
- Renommage du projet en ComptaFolders.
- Script principal renomme en `ComptaFolders.ps1`.

### Corrige
- Gestion de `scriptDir` pour l'EXE (BaseDirectory).
- Ouverture du dossier cree via explorer.exe.