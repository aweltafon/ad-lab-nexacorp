<#
.SYNOPSIS
    Crée un dossier partagé par service, accessible uniquement au groupe du service.
.DESCRIPTION
    Principe du moindre privilège :
    - NTFS : héritage supprimé ; seuls GG_<Service> (Modification), Administrateurs
      et SYSTEM (Contrôle total) ont accès.
    - Partage SMB : GG_<Service> en Modification, Admins du domaine en Contrôle total.
    Les SID sont utilisés pour Administrateurs (S-1-5-32-544) et SYSTEM (S-1-5-18)
    afin que le script fonctionne quelle que soit la langue de Windows.
.NOTES
    À exécuter sur DC01, PowerShell en administrateur.
#>

$Racine = "C:\Partages"

foreach ($Service in "Direction", "RH", "Comptabilite", "IT") {
    $Dossier = Join-Path $Racine $Service
    New-Item -ItemType Directory -Path $Dossier -Force | Out-Null

    # Droits NTFS
    icacls $Dossier /inheritance:r `
        /grant "NEXACORP\GG_$($Service):(OI)(CI)M" `
        /grant "*S-1-5-32-544:(OI)(CI)F" `
        /grant "*S-1-5-18:(OI)(CI)F" | Out-Null

    # Partage réseau
    if (-not (Get-SmbShare -Name $Service -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $Service -Path $Dossier `
            -ChangeAccess "NEXACORP\GG_$Service" `
            -FullAccess "NEXACORP\Admins du domaine" | Out-Null
    }
    Write-Host "Partage prêt : \\$env:COMPUTERNAME\$Service (GG_$Service)"
}

# Vérification
icacls "$Racine\RH"
Get-SmbShare | Where-Object Path -like "$Racine*"
