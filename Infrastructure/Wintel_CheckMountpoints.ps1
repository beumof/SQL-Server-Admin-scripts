# File: Wintel_CheckMountpoints.ps1
# Based on https://learn-powershell.net/2012/08/10/locating-mount-points-using-powershell/
# Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
# Added in 2020-07-02

Get-WmiObject Win32_Volume -Filter "DriveType='3'" | ForEach {
    New-Object PSObject -Property @{
        Name = $_.Name
        Label = $_.Label
        FreeSpace_GB = ([Math]::Round($_.FreeSpace /1GB,2))
        TotalSize_GB = ([Math]::Round($_.Capacity /1GB,2))
    }
} | Select-Object Name, Label, TotalSize_GB, FreeSpace_GB | Sort-Object -Property Name