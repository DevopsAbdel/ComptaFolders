#Requires -Version 5.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:RepoRoot     = Split-Path -Parent $PSScriptRoot
$script:ResourcesDir = Join-Path $script:RepoRoot 'Resources'

function Get-NormalizedCompanyName {
    <#
    .SYNOPSIS
        Normalise un nom de societe : majuscules, espaces -> _, suppression des caracteres invalides.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        throw "Le nom de la societe ne peut pas etre vide."
    }

    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars() + [System.IO.Path]::GetInvalidPathChars()
    $clean = $Name
    foreach ($c in $invalidChars) {
        $clean = $clean.Replace($c.ToString(), '')
    }

    # Remplacement des espaces / tabulations par underscore
    $clean = [regex]::Replace($clean, '\s+', '_')

    # Suppression des caracteres speciaux non autorises (on conserve lettres, chiffres, _, -)
    $clean = [regex]::Replace($clean, '[^A-Za-z0-9_\-]', '')

    # Majuscules
    $clean = $clean.ToUpperInvariant()

    # Compactage des underscores multiples
    $clean = [regex]::Replace($clean, '_{2,}', '_')
    $clean = $clean.Trim('_')

    if ([string]::IsNullOrWhiteSpace($clean)) {
        throw "Le nom de la societe ne contient aucun caractere valide apres normalisation."
    }

    return $clean
}

function Get-DefaultYear {
    return (Get-Date).Year
}

function Get-ClientDossierTree {
    <#
    .SYNOPSIS
        Retourne la liste des chemins relatifs a creer pour un client.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [int]$Year,
        [Parameter(Mandatory = $true)]
        [string]$CompanyName
    )

    $Y = $Year.ToString()
    $C = Get-NormalizedCompanyName -Name $CompanyName

    $paths = New-Object System.Collections.Generic.List[string]
    $paths.Add("")  # racine

    $paths.Add("00-${Y}_Scans_a_traiter_${C}")
    $paths.Add("01-${Y}_Achats_${C}")
    $paths.Add("01-${Y}_Achats_${C}\Autres Achats")
    $paths.Add("02-${Y}_Ventes_${C}")
    $paths.Add("02-${Y}_Ventes_${C}\Autres Ventes")
    $paths.Add("03-${Y}_Banque_${C}")
    $paths.Add("04-${Y}_Sage_${C}")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\01_Tva")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\01_Tva\01_Excel_Tva_${C}_${Y}")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\01_Tva\02_Xml_Tva_${C}_${Y}")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\01_Tva\03_Tva_Recepisse")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\02_Delais_Paiement")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\02_Delais_Paiement\01_Preparation_DP_Word")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\02_Delais_Paiement\01_Preparation_DP_Word\${Y}_Convetion délais de paiement Envoyées")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\02_Delais_Paiement\01_Preparation_DP_Word\${Y}_Convetion délais de paiement Recus")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\02_Delais_Paiement\02_XML_DP")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\02_Delais_Paiement\03_Declaration_DP")
    $paths.Add("05-${Y}_Decl_Fiscal_${C}\03_Autres")
    $paths.Add("06-${Y}_Cnss_${C}")
    $paths.Add("07-${Y}_Attestations_${C}")
    $paths.Add("08-${Y}_Demandes_${C}")
    $paths.Add("09-${Y}_Autres_${C}")
    $paths.Add("99-${Y}_Archives_${C}")

    return $paths.ToArray()
}

function New-ClientDossier {
    <#
    .SYNOPSIS
        Cree l'arborescence complete d'un client. Lance une erreur si le dossier existe deja.
    #>
    param(
        [int]$Year = (Get-Date).Year,
        [Parameter(Mandatory = $true)]
        [string]$CompanyName,
        [Parameter(Mandatory = $true)]
        [string]$ParentPath
    )

    $ErrorActionPreference = 'Stop'

    if (-not (Test-Path -LiteralPath $ParentPath)) {
        throw "Le chemin parent n'existe pas : $ParentPath"
    }

    $company = Get-NormalizedCompanyName -Name $CompanyName
    $rootName = "${Year}_${company}"
    $rootPath = Join-Path $ParentPath $rootName

    if (Test-Path -LiteralPath $rootPath) {
        throw "Le dossier client existe deja : $rootPath"
    }

    $relativePaths = Get-ClientDossierTree -Year $Year -CompanyName $company
    foreach ($rel in $relativePaths) {
        $target = if ([string]::IsNullOrEmpty($rel)) { $rootPath } else { Join-Path $rootPath $rel }
        if (-not (Test-Path -LiteralPath $target)) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        }
    }

    return $rootPath
}

function New-InventoryHtml {
    <#
    .SYNOPSIS
        Genere un rapport d'inventaire HTML a partir du gabarit Resources/InventoryTemplate.html.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$DossierPath,
        [Parameter(Mandatory = $true)]
        [string]$TemplatePath,
        [string]$OutputPath
    )

    $ErrorActionPreference = 'Stop'

    if (-not (Test-Path -LiteralPath $TemplatePath)) {
        throw "Gabarit introuvable : $TemplatePath"
    }

    $rootName = Split-Path -Leaf $DossierPath
    # Extraction annee / societe depuis le nom racine YYYY_COMPANY
    $parts = $rootName -split '_', 2
    $year = $parts[0]
    $company = if ($parts.Count -gt 1) { $parts[1] } else { $rootName }

    $template = Get-Content -LiteralPath $TemplatePath -Raw -Encoding UTF8

    $relativePaths = Get-ClientDossierTree -Year ([int]$year) -CompanyName $company
    $items = foreach ($rel in $relativePaths) {
        if ([string]::IsNullOrEmpty($rel)) { "<li><strong>Racine : $rootName</strong></li>" }
        else { "<li>$rel</li>" }
    }
    $treeHtml = "<ul>`n" + ($items -join "`n") + "`n</ul>"

    $dateStr = Get-Date -Format 'yyyy-MM-dd'
    $html = $template
    $html = $html.Replace('{{YEAR}}', $year)
    $html = $html.Replace('{{COMPANY}}', $company)
    $html = $html.Replace('{{ROOT}}', $DossierPath)
    $html = $html.Replace('{{DATE}}', $dateStr)
    $html = $html.Replace('{{TREE}}', $treeHtml)
    $html = $html.Replace('{{COUNT}}', $relativePaths.Count.ToString())

    if ([string]::IsNullOrWhiteSpace($OutputPath)) {
        $fileName = "${dateStr}_Listes des dossiers et fichiers_${year}_${company}.html"
        $OutputPath = Join-Path $DossierPath $fileName
    }

    Set-Content -LiteralPath $OutputPath -Value $html -Encoding UTF8
    return $OutputPath
}

Export-ModuleMember -Function Get-NormalizedCompanyName, Get-DefaultYear, Get-ClientDossierTree, New-ClientDossier, New-InventoryHtml