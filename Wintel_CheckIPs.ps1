# File: Wintel_CheckIPs.ps1
# Extracted from https://blogs.technet.microsoft.com/josebda/2015/04/18/windows-powershell-equivalents-for-common-networking-commands-ipconfig-ping-nslookup/
# Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
# Added in 2019-04-29

Get-NetIPAddress | Sort InterfaceIndex | FT InterfaceIndex, InterfaceAlias, AddressFamily, IPAddress, PrefixLength –Autosize
Read-Host -Prompt "Press Enter to continue"