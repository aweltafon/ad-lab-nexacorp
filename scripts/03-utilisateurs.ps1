<#
.SYNOPSIS
    Crée les comptes utilisateurs de NexaCorp et les ajoute au groupe de leur service.
.DESCRIPTION
    - Le mot de passe provisoire est saisi au clavier (jamais écrit dans le script).
    - L'utilisateur doit changer son mot de passe à la première connexion.
    - Chaque compte est rangé dans l'OU de son service et ajouté au groupe GG_<Service>.
.NOTES
    À exécuter sur DC01, PowerShell en administrateur.
    Utilisateurs fictifs créés pour le lab.
#>

$Domaine = "nexacorp.local"
$OUUsers = "OU=Utilisateurs,OU=NexaCorp,DC=nexacorp,DC=local"

$Employes = @(
    @{ Prenom = "Marc";   Nom = "Dupont";  Login = "mdupont";  Service = "Direction"    }
    @{ Prenom = "Sophie"; Nom = "Martin";  Login = "smartin";  Service = "RH"           }
    @{ Prenom = "Paul";   Nom = "Bernard"; Login = "pbernard"; Service = "Comptabilite" }
    @{ Prenom = "Julie";  Nom = "Moreau";  Login = "jmoreau";  Service = "IT"           }
)

$MotDePasse = Read-Host "Mot de passe provisoire (12 caractères min., complexe)" -AsSecureString

foreach ($E in $Employes) {
    if (Get-ADUser -Filter "SamAccountName -eq '$($E.Login)'" -ErrorAction SilentlyContinue) {
        Write-Host "Compte déjà présent : $($E.Login)"
        continue
    }

    New-ADUser -Name "$($E.Prenom) $($E.Nom)" `
               -GivenName $E.Prenom -Surname $E.Nom `
               -SamAccountName $E.Login `
               -UserPrincipalName "$($E.Login)@$Domaine" `
               -Path "OU=$($E.Service),$OUUsers" `
               -AccountPassword $MotDePasse `
               -ChangePasswordAtLogon $true `
               -Enabled $true

    Add-ADGroupMember -Identity "GG_$($E.Service)" -Members $E.Login
    Write-Host "Compte créé : $($E.Login) -> GG_$($E.Service)"
}

# Vérification : utilisateurs, état et groupes
Get-ADUser -Filter * -SearchBase $OUUsers -Properties MemberOf |
    Select-Object Name, SamAccountName, Enabled,
        @{ n = "Groupes"; e = { ($_.MemberOf | ForEach-Object { ($_ -split ",")[0] -replace "CN=" }) -join ", " } }
