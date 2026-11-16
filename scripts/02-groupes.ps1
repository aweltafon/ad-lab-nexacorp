<#
.SYNOPSIS
    Crée un groupe de sécurité global par service.
.DESCRIPTION
    Convention de nommage : GG_<Service> (GG = Groupe Global).
    Principe : les droits sont donnés aux GROUPES, jamais directement aux personnes.
    Quand un employé change de poste, on change seulement ses groupes.
.NOTES
    À exécuter sur DC01, PowerShell en administrateur.
#>

$OUGroupes = "OU=Groupes,OU=NexaCorp,DC=nexacorp,DC=local"

foreach ($Service in "Direction", "RH", "Comptabilite", "IT") {
    $Nom = "GG_$Service"
    if (-not (Get-ADGroup -Filter "Name -eq '$Nom'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $Nom -GroupScope Global -GroupCategory Security -Path $OUGroupes `
                    -Description "Membres du service $Service"
        Write-Host "Groupe créé : $Nom"
    } else {
        Write-Host "Groupe déjà présent : $Nom"
    }
}

Get-ADGroup -Filter * -SearchBase $OUGroupes | Select-Object Name
