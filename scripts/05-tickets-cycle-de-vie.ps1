<#
.SYNOPSIS
    Fonctions pour traiter les tickets courants du cycle de vie d'un compte.
.DESCRIPTION
    - Debloquer-Compte      : compte verrouillé après trop d'erreurs de mot de passe
    - Reinitialiser-MotDePasse : mot de passe oublié
    - Changer-Service       : mobilité interne (groupes + OU)
    - Desactiver-Depart     : départ d'un employé (désactivation, pas suppression)
.EXAMPLE
    . .\05-tickets-cycle-de-vie.ps1
    Changer-Service -Login pbernard -Ancien Comptabilite -Nouveau RH
.NOTES
    À exécuter sur DC01, PowerShell en administrateur.
#>

$OUUsers = "OU=Utilisateurs,OU=NexaCorp,DC=nexacorp,DC=local"

function Debloquer-Compte {
    param([Parameter(Mandatory)][string]$Login)
    Unlock-ADAccount -Identity $Login
    Write-Host "Compte débloqué : $Login"
}

function Reinitialiser-MotDePasse {
    param([Parameter(Mandatory)][string]$Login)
    $Nouveau = Read-Host "Nouveau mot de passe provisoire pour $Login" -AsSecureString
    Set-ADAccountPassword -Identity $Login -Reset -NewPassword $Nouveau
    Set-ADUser -Identity $Login -ChangePasswordAtLogon $true
    Write-Host "Mot de passe réinitialisé (changement obligatoire à la connexion) : $Login"
}

function Changer-Service {
    param(
        [Parameter(Mandatory)][string]$Login,
        [Parameter(Mandatory)][string]$Ancien,
        [Parameter(Mandatory)][string]$Nouveau
    )
    Remove-ADGroupMember -Identity "GG_$Ancien" -Members $Login -Confirm:$false
    Add-ADGroupMember    -Identity "GG_$Nouveau" -Members $Login
    $DN = (Get-ADUser $Login).DistinguishedName
    Move-ADObject -Identity $DN -TargetPath "OU=$Nouveau,$OUUsers"
    Write-Host "$Login : GG_$Ancien -> GG_$Nouveau (OU $Nouveau)"
}

function Desactiver-Depart {
    param([Parameter(Mandatory)][string]$Login)
    # En entreprise on désactive au lieu de supprimer : traçabilité et récupération des données.
    Disable-ADAccount -Identity $Login
    Get-ADUser $Login -Properties MemberOf |
        Select-Object -ExpandProperty MemberOf |
        ForEach-Object { Remove-ADGroupMember -Identity $_ -Members $Login -Confirm:$false }
    Set-ADUser -Identity $Login -Description "Désactivé le $(Get-Date -Format 'dd/MM/yyyy') - départ"
    Write-Host "Compte désactivé et retiré de tous ses groupes : $Login"
}
