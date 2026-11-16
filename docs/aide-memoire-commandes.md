# Aide-mémoire PowerShell – Active Directory

Format des commandes : **Verbe-Nom** — `Get` (voir), `New` (créer), `Set` (modifier), `Remove` (supprimer), `Add` (ajouter), `Disable` / `Enable`, `Unlock`, `Move`.

## Trouver de l'aide

| Commande | Rôle |
|---|---|
| `Get-Command *ADUser*` | Lister les commandes qui contiennent « ADUser » |
| `Get-Help New-ADUser -Examples` | Exemples d'utilisation d'une commande |
| Touche **Tab** | Compléter une commande ou un paramètre |

## Consulter l'annuaire

| Commande | Rôle |
|---|---|
| `Get-ADDomain` | Informations sur le domaine |
| `Get-ADOrganizationalUnit -Filter * \| Select-Object Name` | Lister les OU |
| `Get-ADUser -Filter * \| Select-Object Name, SamAccountName, Enabled` | Lister les utilisateurs |
| `Get-ADGroupMember "GG_RH"` | Membres d'un groupe |
| `Get-ADComputer -Filter *` | Lister les ordinateurs |

## Créer

| Commande | Rôle |
|---|---|
| `New-ADOrganizationalUnit -Name "RH" -Path "<DN parent>"` | Créer une OU |
| `New-ADGroup -Name "GG_RH" -GroupScope Global -GroupCategory Security -Path "<DN>"` | Créer un groupe |
| `New-ADUser -Name "Prénom Nom" -SamAccountName login -Path "<DN>" -AccountPassword $mdp -Enabled $true` | Créer un utilisateur |
| `Add-ADGroupMember -Identity "GG_RH" -Members login` | Ajouter à un groupe |

## Tickets courants

| Ticket | Commande |
|---|---|
| Compte bloqué | `Unlock-ADAccount login` |
| Mot de passe oublié | `Set-ADAccountPassword login -Reset -NewPassword (Read-Host -AsSecureString)` |
| Forcer le changement | `Set-ADUser login -ChangePasswordAtLogon $true` |
| Changement de service | `Remove-ADGroupMember` + `Add-ADGroupMember` + `Move-ADObject` |
| Départ | `Disable-ADAccount login` puis retrait des groupes |

## Sécurité

| Commande | Rôle |
|---|---|
| `Get-ADDefaultDomainPasswordPolicy` | Voir la politique de mots de passe |
| `Set-ADDefaultDomainPasswordPolicy -MinPasswordLength 12 ...` | Modifier la politique |
| `icacls C:\Partages\RH` | Voir les droits NTFS |
| `Get-SmbShare` | Lister les partages |
| `gpupdate /force` | Appliquer les GPO immédiatement (sur le poste) |
| `gpresult /r` | Voir les GPO appliquées (sur le poste) |

## Poste client

| Commande | Rôle |
|---|---|
| `Get-NetIPAddress -AddressFamily IPv4` | Voir les adresses IP |
| `Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 192.168.56.10` | Définir le DNS |
| `Resolve-DnsName nexacorp.local` | Tester la résolution du domaine |
| `Test-Connection 192.168.56.10` | Tester la connexion (ping) |
| `Add-Computer -DomainName nexacorp.local -Restart` | Joindre le domaine |
| `whoami` | Voir l'utilisateur connecté |
