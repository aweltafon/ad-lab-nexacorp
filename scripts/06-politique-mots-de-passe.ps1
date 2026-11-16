<#
.SYNOPSIS
    Durcit la politique de mots de passe et de verrouillage du domaine.
.DESCRIPTION
    - Longueur minimale : 12 caractères, complexité activée
    - Verrouillage du compte après 5 échecs, pendant 15 minutes
      (protection contre les attaques par force brute)
.NOTES
    À exécuter sur DC01, PowerShell en administrateur.
#>

Set-ADDefaultDomainPasswordPolicy -Identity "nexacorp.local" `
    -MinPasswordLength 12 `
    -ComplexityEnabled $true `
    -LockoutThreshold 5 `
    -LockoutDuration "00:15:00" `
    -LockoutObservationWindow "00:15:00"

Get-ADDefaultDomainPasswordPolicy
