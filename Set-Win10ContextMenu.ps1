<#
.NAME
    Set-Windows10ContextMenu

.SYNOPSIS
    this will set the windows 11 right click menu to the windows 10 menu in exporer

.SYNTAX


.DESCRIPTION
    this will set the windows 11 right click menu to the windows 10 menu in exporer. you must restart pc or explorer.exe to take effect

.PARAMETERS


.INPUTS


.OUTPUTS


.NOTES


.RELATED LINKS

#>

reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

#Stop-Process -Name explorer -Force