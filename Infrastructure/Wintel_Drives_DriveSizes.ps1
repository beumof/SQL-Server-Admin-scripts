# File: Wintel_CheckDrives.ps1
# Extracted from https://mcpmag.com/articles/2018/01/26/view-drive-information-with-powershell.aspx
# Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
# Added in 2019-09-27

Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '3'" | 
Select-Object DeviceID, @{L="CapacityGB";E={"{0:N2}" -f ($_.Size/1GB)}}, @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}} | Format-Table