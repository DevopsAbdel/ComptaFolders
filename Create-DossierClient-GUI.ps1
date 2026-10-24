#Requires -Version 5.1
param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $scriptDir 'lib\DossierClient.psm1'
Import-Module $modulePath -Force

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$xamlPath = Join-Path $PSScriptRoot 'Resources\MainWindow.xaml'
$xamlText = [System.IO.File]::ReadAllText($xamlPath)
$xamlDoc = New-Object System.Xml.XmlDocument
$xamlDoc.LoadXml($xamlText)
$xmlReader = New-Object System.Xml.XmlNodeReader $xamlDoc
$window = [System.Windows.Markup.XamlReader]::Load($xmlReader)

function Show-DarkMessage {
    param([string]$Title, [string]$Message)
    $dlg = New-Object System.Windows.Window
    $dlg.Title = $Title
    $dlg.Width = 460
    $dlg.Height = 260
    $dlg.WindowStartupLocation = 'CenterOwner'
    $dlg.Owner = $window
    $dlg.Background = '#0E0E0E'
    $dlg.Foreground = '#E6E6E6'
    $dlg.FontFamily = 'Segoe UI'

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Margin = '16'

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = $Message
    $tb.Foreground = '#E6E6E6'
    $tb.TextWrapping = 'Wrap'
    $tb.Margin = '0,0,0,16'
    [void]$sp.Children.Add($tb)

    $btn = New-Object System.Windows.Controls.Button
    $btn.Content = 'OK'
    $btn.Width = 90
    $btn.HorizontalAlignment = 'Right'
    $btn.Padding = '12,6'
    $btn.Background = '#7856FF'
    $btn.Foreground = 'White'
    $btn.Add_Click({ $dlg.Close() })
    [void]$sp.Children.Add($btn)

    $dlg.Content = $sp
    $dlg.ShowDialog() | Out-Null
}

$YearBox = $window.FindName('YearBox')
$CompanyBox = $window.FindName('CompanyBox')
$ParentBox = $window.FindName('ParentBox')
$BrowseBtn = $window.FindName('BrowseBtn')
$CreateBtn = $window.FindName('CreateBtn')
$StatusBox = $window.FindName('StatusBox')
$GuideBtn = $window.FindName('GuideBtn')
$IndexBtn = $window.FindName('IndexBtn')

$BrowseBtn.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ParentBox.Text = $dlg.SelectedPath
    }
})

$CreateBtn.Add_Click({
    try {
        $year = [int]$YearBox.Text
        $company = $CompanyBox.Text
        $parent = $ParentBox.Text
        $root = New-ClientDossier -Year $year -CompanyName $company -ParentPath $parent
        $template = Join-Path $scriptDir 'Resources\InventoryTemplate.html'
        $inv = New-InventoryHtml -DossierPath $root -TemplatePath $template
        $StatusBox.Text = "Dossier cree : $root`nInventaire : $inv"
        Show-DarkMessage -Title "Succes" -Message "Dossier cree avec succes.`n$root"
    } catch {
        $StatusBox.Text = "Erreur : $($_.Exception.Message)"
        Show-DarkMessage -Title "Erreur" -Message $_.Exception.Message
    }
})

$GuideBtn.Add_Click({
    $p = Join-Path $scriptDir 'Documentation\Guide_Utilisation.html'
    Start-Process $p
})
$IndexBtn.Add_Click({
    $p = Join-Path $scriptDir 'Documentation\Index_Documents_Types.html'
    Start-Process $p
})

$window.ShowDialog() | Out-Null