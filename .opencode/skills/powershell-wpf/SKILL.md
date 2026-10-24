---
name: powershell-wpf
description: Use when editing PowerShell + WPF/XAML code in this project: Resources/MainWindow.xaml, Create-DossierJuridique-GUI.ps1, event handlers, module separation, encoding and STA concerns. Trigger on words like XAML, WPF, bouton, événements, interface GUI, Add_Checkbox, ShowDialog.
---

# PowerShell + WPF — Bonnes pratiques

## Règles d'or pour une GUI WPF en PowerShell

1. **STA** : le chargement WPF et `ShowDialog()` exigent un thread *single
   threaded apartment*. PowerShell 5.1 (et pwsh 7 sur hôte STA) le garantit ;
   ne jamais créer de Runspace MTA pour charger le XAML.
2. **XAML séparé** : l'interface vit dans `Resources/MainWindow.xaml`, chargée
   au démarrage par le script d'entrée. Ne jamais coller le XAML dans le `.ps1`.
3. **Encodage** : ressources lisées en UTF-8 (ou UTF-8 BOM). Fichiers *générés*
   (inventaire, historiques) écrits en UTF-8 avec BOM
   (`New-Object System.Text.UTF8Encoding($true)` puis `[IO.File]::WriteAllText`).
   Console : `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` dans un
   `try/catch` (aucun effet si lancé en mode fenêtre).

## Chargement du XAML depuis un fichier

```powershell
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$xamlPath = Join-Path $PSScriptRoot 'Resources\MainWindow.xaml'
if (-not (Test-Path -LiteralPath $xamlPath)) {
    throw "Fichier d'interface introuvable : $xamlPath"
}
$xamlText  = [System.IO.File]::ReadAllText($xamlPath)
$xamlDoc   = New-Object System.Xml.XmlDocument
$xamlDoc.LoadXml($xamlText)
$reader = New-Object System.Xml.XmlNodeReader($xamlDoc)
$window = [System.Windows.Markup.XamlReader]::Load($reader)
```

Ensuite récupérer chaque contrôle nommé via `FindName` et le stocker dans une
table de hachage `$controls` (unique source de vérité).

## Câblage des événements

- Utiliser `Add_<Event>` : `$control.Add_Click({ ... })`, `Add_TextChanged`,
  `Add_Checked`, `Add_SelectionChanged`.
- Un `return` dans un handler n'interrompt que le handler ; pour couvrir un
  chemin d'erreur utiliser `try/finally` (le `finally` s'exécute toujours).
- Ne pas bloquer le thread UI : pendant un traitement long (inventaire),
  passer le curseur en attente et désactiver les boutons dans `try`, restaurer
  dans `finally`. Éviter les runspaces tant que la fonction est synchrone.

## Séparation logique / UI

- Toute la logique (calculs, création de dossiers, inventaire, historique)
  vit dans `lib/DossierJuridique.psm1`. Le script `.ps1` ne fait que : charger
  le XAML, câbler les événements, lire/écrire via le module.
- Le module ne référence jamais WPF → testable avec Pester sans interface.
- Vérifier que les noms de fonctions utilisent des verbes approuvés
  (`Format-*`, `ConvertTo-*`, `Get-*`, `New-*`, `Add-*`).

## Pièges fréquents

- `New-Item` sans `-ErrorAction Stop` dans un `try/catch` : l'erreur est
  *non-terminante*, le `catch` ne se déclenche pas et la suite s'exécute.
- Diagnostics PSScriptAnalyzer sensibles : `PSUseDeclaredVarsMoreThanAssignments`,
  `PSAvoidUsingEmptyCatchBlock`, `PSUseApprovedVerbs`.
- `MessageBox.Show` nécessite `PresentationFramework` (déjà ajouté).

## Commandes utiles

```powershell
Invoke-ScriptAnalyzer -Path .\Create-DossierJuridique-GUI.ps1, .\lib\DossierJuridique.psm1 -Severity Warning, Error -Recurse
```