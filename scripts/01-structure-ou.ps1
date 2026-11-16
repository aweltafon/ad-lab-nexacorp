<#
.SYNOPSIS
    Crée l'arborescence d'unités d'organisation (OU) de NexaCorp.
.DESCRIPTION
    NexaCorp
     ├── Utilisateurs
     │    ├── Direction
     │    ├── RH
     │    ├── Comptabilite
     │    └── IT
     ├── Groupes
     └── Ordinateurs

    Utilisateurs, groupes et ordinateurs sont séparés pour pouvoir leur appliquer
    des GPO différentes. Les OU sont protégées contre la suppression accidentelle.
.NOTES
    À exécuter sur le contrôleur de domaine (DC01), PowerShell en administrateur.
#>

$Domaine = "DC=nexacorp,DC=local"
$Racine  = "OU=NexaCorp,$Domaine"
$OUUsers = "OU=Utilisateurs,$Racine"

function New-OUSiAbsente {
    param([string]$Nom, [string]$Chemin)
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Nom'" -SearchBase $Chemin -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $Nom -Path $Chemin -ProtectedFromAccidentalDeletion $true
        Write-Host "OU créée : OU=$Nom,$Chemin"
    } else {
        Write-Host "OU déjà présente : OU=$Nom,$Chemin"
    }
}

New-OUSiAbsente -Nom "NexaCorp"     -Chemin $Domaine
New-OUSiAbsente -Nom "Utilisateurs" -Chemin $Racine
New-OUSiAbsente -Nom "Groupes"      -Chemin $Racine
New-OUSiAbsente -Nom "Ordinateurs"  -Chemin $Racine

foreach ($Service in "Direction", "RH", "Comptabilite", "IT") {
    New-OUSiAbsente -Nom $Service -Chemin $OUUsers
}

# Vérification
Get-ADOrganizationalUnit -Filter * -SearchBase $Racine | Select-Object DistinguishedName
