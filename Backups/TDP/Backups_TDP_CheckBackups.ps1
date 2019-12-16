# File: Backups\TDP\Backups_TDP_CheckBackups.ps1
# Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
# Added in 2019-12-16
# Commentaries: Check Backups made with Tivoli TSM in a server

Import-Module (Get-ChildItem (Get-ItemProperty -Path "HKLM:\SOFTWARE\IBM\FlashCopyManager\CurrentVersion\mmc").Path -Filter fmmodule*.dll).FullName
Get-DpSqlBackup  -Name * -AllTypes -All -COMPATibilityinfo -FROMSQLserver * -QUERYNode DP -ConfigFile "<CFG file>" -TsmOptFile "<OPT file>"
