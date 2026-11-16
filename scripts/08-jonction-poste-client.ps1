<#
.SYNOPSIS
    Joint un poste Windows au domaine nexacorp.local.
.DESCRIPTION
    1. Le poste utilise DC01 (192.168.56.10) comme serveur DNS sur la carte du réseau du lab.
    2. Cette carte est rendue prioritaire (métrique basse).
    3. Tests : résolution du domaine et ping du contrôleur de domaine.
    4. Jonction au domaine, renommage en PC-RH01, rangement dans l'OU Ordinateurs.
.NOTES
    À exécuter SUR LE POSTE CLIENT, PowerShell en administrateur.
    Le mot de passe de NEXACORP\Administrateur est demandé dans une fenêtre.
#>

$Carte = "Ethernet 2"          # carte connectée au réseau host-only du lab
$IP_DC = "192.168.56.10"

Set-DnsClientServerAddress -InterfaceAlias $Carte -ServerAddresses $IP_DC
Set-NetIPInterface         -InterfaceAlias $Carte -InterfaceMetric 5

Resolve-DnsName nexacorp.local
Test-Connection $IP_DC -Count 2

Add-Computer -DomainName "nexacorp.local" `
             -NewName "PC-RH01" `
             -OUPath "OU=Ordinateurs,OU=NexaCorp,DC=nexacorp,DC=local" `
             -Credential "NEXACORP\Administrateur" `
             -Restart
