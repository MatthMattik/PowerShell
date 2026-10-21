<#
.SYNOPSIS
   

.DESCRIPTION
    

.NOTES
    

.LINK

#>

#Dell Command to update drivers, Bios, and firmware...

& "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" /applyupdates

#update known apps via winget
winget upgrade --all

Update-Module *














$ScriptName = Split-Path $PSCommandPath -Leaf
"`n"
Write-Warning "$ScriptName is now complete."