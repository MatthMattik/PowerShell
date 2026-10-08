<#

.SYNOPSIS
    Lists distribution groups and mail-enabled security groups hidden from the Exchange GAL.

.DESCRIPTION
    Lists distribution groups and mail-enabled security groups hidden from the Exchange GAL.

.NOTES

.LINK

#>


#Domain Controller name or IP address
[string]$DC = '192.168.1.1'

#Searchbase for the distribution groups
[string]$SB = 'OU=Distribution_Groups,OU=Exchange Mailboxes,OU=Fake,DC=corp,DC=Test,DC=com'


[pscredential]$Credential = Get-Credential

#find Distros that are hidden from the GAL in outlook:
Get-AdGroup -Server $DC -SearchBase $SB -filter {msExchHideFromAddressLists -eq $true} -Credential $Credential -Properties "msExchHideFromAddressLists"  | Select-Object "name","GroupCategory", "msExchHideFromAddressLists"



