<#
.SYNOPSIS
    Équivalent PowerShell de la GPO « GPO_Verrouillage_Ecran ».
.DESCRIPTION
    Dans le lab, cette GPO a été créée avec la console « Gestion des stratégies de groupe » :
    Configuration utilisateur > Stratégies > Modèles d'administration >
    Panneau de configuration > Personnalisation
      - Activer l'écran de veille                         : Activé
      - Un mot de passe protège l'écran de veille         : Activé
      - Dépassement du délai d'expiration (secondes)      : 300

    Ce script donne la même configuration en PowerShell (module GroupPolicy).
    Il n'a pas été exécuté dans le lab : il est fourni comme alternative scriptable.
.NOTES
    À exécuter sur DC01, PowerShell en administrateur.
#>

$NomGPO = "GPO_Verrouillage_Ecran"
$Cible  = "OU=Utilisateurs,OU=NexaCorp,DC=nexacorp,DC=local"
$Cle    = "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop"

if (-not (Get-GPO -Name $NomGPO -ErrorAction SilentlyContinue)) {
    New-GPO -Name $NomGPO | New-GPLink -Target $Cible | Out-Null
}

Set-GPRegistryValue -Name $NomGPO -Key $Cle -ValueName "ScreenSaveActive"    -Type String -Value "1"
Set-GPRegistryValue -Name $NomGPO -Key $Cle -ValueName "ScreenSaverIsSecure" -Type String -Value "1"
Set-GPRegistryValue -Name $NomGPO -Key $Cle -ValueName "ScreenSaveTimeOut"   -Type String -Value "300"

Write-Host "GPO $NomGPO configurée et liée à $Cible"
