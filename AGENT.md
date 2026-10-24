Voici le fichier **AGENTS.md** complet et mis à jour, intégrant l'ensemble de la structure réelle issue de l'inventaire (`00-2026_Scans_a_traiter...`, sous-dossiers complets de la TVA, des Délais de Paiement, etc.), la charte de nommage, le guide d'utilisation et l'index des documents types en HTML :

```markdown
# Createur-Dossier-Clients-Comptables

Scripts et outils pour automatiser et standardiser la création des dossiers comptables, fiscaux et juridiques annuels des clients du cabinet (`YYYY_NOM_SOCIETE`)[cite: 1, 2, 3].

---

## ??? Architecture du Projet

```text
Create-DossierClient-GUI.ps1      # Point d'entrée de l'application (Interface utilisateur)[cite: 3]
creer_dossiers_majuscules.bat     # Script Batch d'origine pour création rapide[cite: 1]
lib/
+-- DossierClient.psm1            # Logique métier : normalisation, création arborescence, inventaire[cite: 3]
Resources/
+-- InventoryTemplate.html        # Gabarit du rapport d'inventaire interactif HTML[cite: 2, 3]
+-- LisezMoi_Demande.txt          # Fiche repère "Demande"[cite: 3]
+-- LisezMoi_Preparation.txt      # Fiche repère "Préparation"[cite: 3]
Documentation/
+-- Charte_Nommage_Fichiers.md    # Normes et règles de nommage des fichiers/dossiers
+-- Guide_Utilisation.html        # Guide d'utilisation interactif pour le cabinet
+-- Index_Documents_Types.html    # Index et catalogue des documents types (TVA, DP, CNSS...)
tests/
+-- DossierClient.Tests.ps1       # Tests unitaires Pester[cite: 3]
.github/workflows/ci.yml          # Pipeline CI / Validation du code[cite: 3]

```

---

## ?? Structure Complète des Dossiers Créés (Charte Cabinet)

Pour une année `YYYY` et un nom de société normalisé `COMPANY` (ex: `2026_GEAR_MANIA`), l'arborescence complète générée est la suivante :

```text
YYYY_COMPANY/
+-- 00-YYYY_Scans_a_traiter_COMPANY/
+-- 01-YYYY_Achats_COMPANY/
¦   +-- Autres Achats/
+-- 02-YYYY_Ventes_COMPANY/
¦   +-- Autres Ventes/
+-- 03-YYYY_Banque_COMPANY/
+-- 04-YYYY_Sage_COMPANY/
+-- 05-YYYY_Decl_Fiscal_COMPANY/
¦   +-- 01_Tva/
¦   ¦   +-- 01_Excel_Tva_COMPANY_YYYY/
¦   ¦   +-- 02_Xml_Tva_COMPANY_YYYY/
¦   ¦   +-- 03_Tva_Recepisse/
¦   +-- 02_Delais_Paiement/
¦   ¦   +-- 01_Preparation_DP_Word/
¦   ¦   ¦   +-- YYYY_Convetion délais de paiement Envoyées/
¦   ¦   ¦   +-- YYYY_Convetion délais de paiement Recus/
¦   ¦   +-- 02_XML_DP/
¦   ¦   +-- 03_Declaration_DP/
¦   +-- 03_Autres/
+-- 06-YYYY_Cnss_COMPANY/
+-- 07-YYYY_Attestations_COMPANY/
+-- 08-YYYY_Demandes_COMPANY/
+-- 09-YYYY_Autres_COMPANY/
+-- 99-YYYY_Archives_COMPANY/

```

---

## ??? Charte de Nommage et Normalisation

### 1. Formats des Répertoires

* **Dossier Racine Client** : `YYYY_SOCIETE_MAJUSCULE` (ex: `2026_GEAR_MANIA`).


* **Conversion Société** : Tout texte saisi pour le nom de la société est automatiquement converti en majuscules et les espaces sont remplacés par des underscores `_`.


* **Prefixes Numérotés** : Tous les dossiers principaux de travail portent un préfixe à deux chiffres (`00-`, `01-`, `02-`, ..., `99-`) suivi de l'année et de la désignation.



### 2. Normes de Nommage des Fichiers Types

* **Scans TVA complets** : `YYYY-MM_TVA_SOCIETE_Dos-complet.pdf`


* **Récépissés / Déclarations TVA** : `YYYY-MM_Recu_Decl_Tva_SOCIETE.pdf`


* **Fichiers Excel TVA (Deductions)** : `Deductions_SOCIETE_MM_YYYY.xlsx`


* **Archives XML TVA** : `Releve_Deductions_MM_YYYY.zip`


* **Délais de Paiement (DP)** :
* Convention Word envoyée : `Convention_delais_paiement_FOURNISSEUR.docx`


* Convention scannée reçue : `Convention délais de paiement FOURNISSEUR Scan.pdf`


* Récépissé de déclaration DP : `YYYY-XTr_Recu_Decl_Delais_Paiement_SOCIETE.pdf`




* **Attestations Fiscales** : `YYYY-MM_Attestation_CA_SOCIETE.pdf`, `YYYY-MM_IF_SOCIETE.pdf`, `YYYY-MM_TP_SOCIETE.pdf`



---

## ?? Guide d'Utilisation (Guide_Utilisation.html)

L'application intègre un guide d'utilisation sous forme de page web HTML interactive hébergée dans `Documentation/Guide_Utilisation.html`.

### Étapes d'utilisation de l'Application GUI :

1. **Sélection de l'Année** : Par défaut l'année en cours (ex: `2026`), modifiable pour les dossiers antérieurs.


2. **Saisie de la Société** : Entrer le nom commercial ou la raison sociale. L'application applique automatiquement la majuscule et remplace les espaces par des tirets bas.


3. **Sélection du Chemin Parent** : Choisir l'emplacement racine (ex: `OneDrive - JoCons\01_Clients\`).


4. **Génération & Inventaire HTML** : L'application crée la structure de répertoires standard et génère automatiquement un rapport HTML d'inventaire interactif (`YYYY-MM-DD_Listes des dossiers et fichiers_YYYY_SOCIETE.html`) intégrant tableau, arborescence et statistiques.



---

## ?? Index des Documents Types (Index_Documents_Types.html)

Un catalogue HTML est généré dans `Documentation/Index_Documents_Types.html` pour servir de référence aux collaborateurs du cabinet sur la répartition des pièces :

| Catégorie | Dossier Cible | Extension / Modèle Type |
| --- | --- | --- |
| **Ventes / Achats à classer** | `00-YYYY_Scans_a_traiter_COMPANY/` | `.pdf`, `.jpeg`

 |
| **Factures d'Achats** | `01-YYYY_Achats_COMPANY/` | `Fact_Achats_YYYY-MM_SOCIETE.pdf`

 |
| **Factures de Ventes** | `02-YYYY_Ventes_COMPANY/` | `Fact_Ventes_YYYY-MM_SOCIETE.pdf`

 |
| **Relevés Bancaires** | `03-YYYY_Banque_COMPANY/` | `Rlv_YYYY_NNN_SOCIETE.pdf`

 |
| **Exports Comptables** | `04-YYYY_Sage_COMPANY/` | `YYYY-MM-DD_Journals_SOCIETE.xlsx`

 |
| **Fichiers / XML TVA** | `05-.../01_Tva/` | `.xlsx`, `.xml`, `.zip`, `.pdf`

 |
| **Délais de Paiement** | `05-.../02_Delais_Paiement/` | `Delais_Paiement_Trimestre X_YYYY.xlsx`

 |
| **Bordereaux CNSS** | `06-YYYY_Cnss_COMPANY/` | `YYYY-MM_Bordereau_CNSS.pdf` |
| **Attestations Fiscales** | `07-YYYY_Attestations_COMPANY/` | `Attestation_REG_Fis_SOCIETE.pdf`

 |

---

## ??? Développement & Commandes

```powershell
# Lancement de l'interface graphique PowerShell / WPF
.\Create-DossierClient-GUI.ps1

# Exécution du script batch historique
.\creer_dossiers_majuscules.bat

# Lancer les tests Pester
Invoke-Pester -Path .\tests -CI

```

```

```