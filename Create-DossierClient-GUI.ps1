#Requires -Version 5.1
param()

$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) {
    $scriptDir = [System.AppDomain]::CurrentDomain.BaseDirectory
}
if (-not $scriptDir) {
    $scriptDir = (Get-Location).Path
}
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
$OpenAfterCreate = $window.FindName('OpenAfterCreate')

$parentDefault = $PSScriptRoot
if (-not $parentDefault -or -not (Test-Path $parentDefault)) { $parentDefault = $scriptDir }
if (-not $parentDefault -or -not (Test-Path $parentDefault)) { $parentDefault = (Get-Location).Path }
$window.Add_SourceInitialized({
    $ParentBox.Text = $parentDefault
})
$window.Add_Loaded({
    $ParentBox.Dispatcher.Invoke([Action]{
        $ParentBox.Text = $parentDefault
    }, [System.Windows.Threading.DispatcherPriority]::Render)
    $ParentBox.Focus()
})

$BrowseBtn.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ParentBox.Text = $dlg.SelectedPath
    }
})

$CreateBtn.Add_Click({
    try {
        $year = [int]$YearBox.Text
        $companyInput = $CompanyBox.Text
        $parent = $ParentBox.Text

        $companies = $companyInput -split '[;,]' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        if ($companies.Count -eq 0) { throw "Veuillez saisir au moins une société." }

        $results = @()
        foreach ($company in $companies) {
            try {
                $root = New-ClientDossier -Year $year -CompanyName $company -ParentPath $parent
                $compNorm = (Get-NormalizedCompanyName -Name $company)
                try {
                    $charteSrc = Join-Path $scriptDir 'Resources\Charte_Nommage_Repere.txt'
                    if (Test-Path $charteSrc) {
                        $c = [System.IO.File]::ReadAllText($charteSrc)
                        $c = $c.Replace('{ANNEE}', $year).Replace('{SOCIETE}', $compNorm)
                        [System.IO.File]::WriteAllText((Join-Path $root 'Charte_Nommage_Fichiers.txt'), $c, (New-Object System.Text.UTF8Encoding($false)))
                    }
                    $scans = Join-Path $root "00-${year}_Scans_a_traiter_${compNorm}"
                    if (Test-Path $scans) {
                        $s = [System.IO.File]::ReadAllText((Join-Path $scriptDir 'Resources\LisezMoi_Scans.txt'))
                        $s = $s.Replace('{ANNEE}', $year).Replace('{SOCIETE}', $compNorm)
                        [System.IO.File]::WriteAllText((Join-Path $scans 'LisezMoi_Scans.txt'), $s, (New-Object System.Text.UTF8Encoding($false)))
                    }
                    $dem = Join-Path $root "08-${year}_Demandes_${compNorm}"
                    if (Test-Path $dem) {
                        $d = [System.IO.File]::ReadAllText((Join-Path $scriptDir 'Resources\LisezMoi_Demande.txt'))
                        $d = $d.Replace('{ANNEE}', $year).Replace('{SOCIETE}', $compNorm)
                        [System.IO.File]::WriteAllText((Join-Path $dem 'LisezMoi_Demande.txt'), $d, (New-Object System.Text.UTF8Encoding($false)))
                    }
                    $prep = Join-Path $root "05-${year}_Decl_Fiscal_${compNorm}\02_Delais_Paiement"
                    if (Test-Path $prep) {
                        $p = [System.IO.File]::ReadAllText((Join-Path $scriptDir 'Resources\LisezMoi_Preparation.txt'))
                        $p = $p.Replace('{ANNEE}', $year).Replace('{SOCIETE}', $compNorm)
                        [System.IO.File]::WriteAllText((Join-Path $prep 'LisezMoi_Preparation.txt'), $p, (New-Object System.Text.UTF8Encoding($false)))
                    }
                } catch {}
                $template = Join-Path $scriptDir 'Resources\InventoryTemplate.html'
                $inv = New-InventoryHtml -DossierPath $root -TemplatePath $template
                $results += "OK - $root"
                $StatusBox.AppendText("`n[DEBUG] root='$root' [type=$($root.GetType().FullName)] [null=$([string]::IsNullOrEmpty($root))]`n")
                if ($companies.Count -eq 1 -and $OpenAfterCreate -and $OpenAfterCreate.IsChecked) {
                    try {
                        if ([string]::IsNullOrWhiteSpace([string]$root)) {
                            $StatusBox.AppendText("[DEBUG] root is null/empty/whitespace - skip open`n")
                            throw "root is null/empty"
                        }
                        $rootStr = [string]$root
                        if (-not (Test-Path -LiteralPath $rootStr)) {
                            $StatusBox.AppendText("[DEBUG] Test-Path failed for '$rootStr'`n")
                            throw "root does not exist: $rootStr"
                        }
                        $StatusBox.AppendText("[DEBUG] calling explorer for '$rootStr'`n")
                        Start-Process -FilePath "explorer.exe" -ArgumentList $rootStr
                    } catch {
                        $StatusBox.AppendText("[DEBUG][ERR] $($_.Exception.GetType().FullName): $($_.Exception.Message)`n")
                        if ($_.InvocationInfo) {
                            $StatusBox.AppendText("[DEBUG][ERR] at $($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber)`n")
                        }
                        if ($_.ScriptStackTrace) {
                            $StatusBox.AppendText("[DEBUG][ERR] stack: $($_.ScriptStackTrace)`n")
                        }
                    }
                }
            } catch {
                $results += "ERREUR - $company : $($_.Exception.Message)"
            }
        }

        $StatusBox.Text = $results -join "`n"
        if ($companies.Count -eq 1) {
            Show-DarkMessage -Title "Succes" -Message ($results -join "`n")
        } else {
            Show-DarkMessage -Title "Création multiple" -Message ($results -join "`n")
        }
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