$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot '..\lib\DossierClient.psm1'
Import-Module -Name $modulePath -Force

Describe "Get-NormalizedCompanyName" {
    It "convertit en majuscules et remplace les espaces" {
        $res = Get-NormalizedCompanyName "gear mania"
        $res | Should Be "GEAR_MANIA"
    }
    It "supprime les caracteres invalides" {
        $res = Get-NormalizedCompanyName "A/B:C"
        $res | Should Be "ABC"
    }
    It "leve une erreur si vide" {
        { Get-NormalizedCompanyName "   " } | Should Throw
    }
}

Describe "New-ClientDossier" {
    It "cree l'arborescence complete" {
        $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("dossiertest-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tmp | Out-Null
        try {
            $root = New-ClientDossier -Year 2026 -CompanyName "Gear Mania" -ParentPath $tmp
            (Test-Path $root) | Should Be $true
            $expected = @(
                "00-2026_Scans_a_traiter_GEAR_MANIA",
                "01-2026_Achats_GEAR_MANIA\Autres Achats",
                "02-2026_Ventes_GEAR_MANIA\Autres Ventes",
                "05-2026_Decl_Fiscal_GEAR_MANIA\01_Tva\01_Excel_Tva_GEAR_MANIA_2026",
                "05-2026_Decl_Fiscal_GEAR_MANIA\02_Delais_Paiement\01_Preparation_DP_Word\2026_Convetion délais de paiement Envoyées",
                "99-2026_Archives_GEAR_MANIA"
            )
            foreach ($rel in $expected) {
                (Test-Path (Join-Path $root $rel)) | Should Be $true
            }
        } finally {
            Remove-Item -Recurse -Force $tmp
        }
    }

    It "leve une erreur si le dossier existe deja" {
        $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("dossiertest-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tmp | Out-Null
        try {
            New-ClientDossier -Year 2026 -CompanyName "Gear Mania" -ParentPath $tmp | Out-Null
            { New-ClientDossier -Year 2026 -CompanyName "Gear Mania" -ParentPath $tmp } | Should Throw
        } finally {
            Remove-Item -Recurse -Force $tmp
        }
    }
}