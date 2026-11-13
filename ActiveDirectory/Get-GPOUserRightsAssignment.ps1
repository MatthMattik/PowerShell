<#
.SYNOPSIS
    Retrieves User Rights Assignments and assigned accounts/groups across Active Directory GPOs.

.DESCRIPTION
    Scans Group Policy Objects (GPOs) in the current Active Directory domain, parses their
    XML settings reports, and returns which accounts or groups (by name and SID) are granted
    specified User Rights Assignments (e.g., SeServiceLogonRight, SeTcbPrivilege, SeDebugPrivilege).

.PARAMETER Privilege
    One or more user rights / privileges or wildcard patterns to search for.
    Accepts a single string or an array of strings (e.g. "SeServiceLogonRight", "SeBackupPrivilege").
    Defaults to "SeRestorePrivilege". Supports wildcards (e.g., "Se*Logon*").

.PARAMETER GPOName
    Optional. The display name of a specific GPO to query. If omitted, all domain GPOs are evaluated.

.PARAMETER PassThru
    Outputs raw custom objects to the pipeline instead of formatted tables (useful when piping to Export-Csv or Out-GridView).

.EXAMPLE
    .\Get-GPOUserRightsAssignment.ps1
    Finds all accounts granted 'SeRestorePrivilege' across all domain GPOs, displayed in a table.

.EXAMPLE
    .\Get-GPOUserRightsAssignment.ps1 -Privilege "SeServiceLogonRight", "SeRestorePrivilege", "SeBackupPrivilege"
    Displays separate tables for each privilege with assigned accounts and SIDs.

.EXAMPLE
    .\Get-GPOUserRightsAssignment.ps1 -Privilege "SeTcbPrivilege"
    Finds all accounts granted 'SeTcbPrivilege' (Act as part of the operating system).

.EXAMPLE
    .\Get-GPOUserRightsAssignment.ps1 -Privilege "Se*Logon*" -PassThru | Export-Csv -Path "C:\temp\LogonRights.csv" -NoTypeInformation
    Exports raw object data to a CSV file.

.EXAMPLE
    .\Get-GPOUserRightsAssignment.ps1 -GPOName "Default Domain Controllers Policy"
    Evaluates rights assignments only on the specified GPO.

.NOTES
    Requires the GroupPolicy module (RSAT).
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string[]]$Privilege = "SeRestorePrivilege",

    [Parameter()]
    [string]$GPOName,

    [switch]$PassThru
)

Import-Module GroupPolicy -ErrorAction Stop

# Retrieve target GPOs (either a specific GPO or all domain GPOs)
$gpos = if ($PSBoundParameters.ContainsKey('GPOName')) {
    Get-GPO -Name $GPOName
} else {
    Get-GPO -All
}

$results = foreach ($gpo in $gpos) {
    [xml]$report = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    
    # In GPO reports, rights are located under UserRightsAssignment
    $rights = $report.GPO.Computer.ExtensionData.Extension.UserRightsAssignment | 
              Where-Object {
                  $rightName = $_.Name
                  foreach ($p in $Privilege) {
                      if ($rightName -like $p) { return $true }
                  }
                  return $false
              }

    foreach ($right in $rights) {
        foreach ($member in $right.Member) {
            $sid  = if ($member["SID"])  { $member["SID"]."#text" } else { $null }
            $name = if ($member["Name"]) { $member["Name"]."#text" } elseif ($sid) {
                try {
                    ([System.Security.Principal.SecurityIdentifier]$sid).Translate([System.Security.Principal.NTAccount]).Value
                } catch {
                    $sid
                }
            } else {
                "(Not Set)"
            }

            [PSCustomObject]@{
                GPOName   = $report.GPO.Name
                Privilege = $right.Name
                Account   = $name
                SID       = $sid
            }
        }
    }
}

# Display separated tables per privilege by default, or pass raw objects if -PassThru is specified
if ($PassThru) {
    $results | Sort-Object Privilege, GPOName
} else {
    $results | Sort-Object Privilege, GPOName | Format-Table -GroupBy Privilege GPOName, Account, SID
}
