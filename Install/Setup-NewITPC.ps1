<#

.SYNOPSIS
    A script to setup a new IT pc with software, modules, etc.

    

.DESCRIPTION
    A script to setup a new pc with software and powershell modules using winget


.NOTES
login into windows as the admin account you will use with winget to initialize winget. then login back into windows as ur normal account and elevate as that admin account.

force winget to install to the machine level:  use the command "winget settings" to open the settings json file. then add...

{
  "$schema": "https://aka.ms/winget-settings.schema.json",
  "installBehavior": {
    "preferences": {
      "scope": "machine"
    }
  }
}

.LINK
https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md

#>



#basic settings

Set-TimeZone -Id "Eastern Standard Time"
Enable-PSRemoting
Install-PackageProvider NuGet -Force
Set-PSRepository PSGallery -InstallationPolicy Trusted


#Install powershell modules - comment out # the ones u want or dont want

Install-Module Microsoft.Graph.Users
Install-Module Microsoft.Graph.Groups
Install-Module ExchangeOnlineManagement
Install-module POSH-SSH
#Install-Module VCF.PowerCLI - but just vsphere. will research later
#Install-Module AWSPowershell
#Install-Module PSFramework
#Install-Module PSUtil

#optional features (found in control panel applet)
Enable-WindowsOptionalFeature -FeatureName "Microsoft-Windows-Subsystem-Linux" -Online
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online -All


#optional capabilities (found in settings app)
Add-WindowsCapability -Name "OpenSSH.Client" -Online
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online



# Add custom module path to powershell profile
$path = $profile.CurrentUserAllHosts
if (-not (Test-Path $path)) {
    New-Item -ItemType File -Path $path$
    }

if (-not (Get-Content -Path $path | Select-String -Pattern 'IT')){
    '$env:Psmodulepath += ";\\Sensaria\Raleigh\Departments\IT\Powershell\Modules\"' | Out-file -Filepath $path -append
    }




#Prompt user for winget json file

Add-Type -AssemblyName System.Windows.Forms

$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.InitialDirectory = "\\sensaria\raleigh\Departments\IT\PowerShell\Install"
$dialog.Filter = "Text files (*.txt)|*.txt"
$dialog.Title = "Select a WinGet .txt file"

if ($dialog.ShowDialog() -eq "OK") {
    $selectedFile = $dialog.FileName
    Write-Host "You selected: $selectedFile"
} else {
    Write-Host "No file selected."
}

#Use winget to download and install applications
winget import -i $SelectedFile --accept-package-agreements --accept-source-agreements --disable-interactivity


#pin licensed apps so they dont update to the free versions
winget pin add "Mobaxterm"
winget pin add "HD Tune Pro version 6.10"


#optional features (found in control panel applet)



