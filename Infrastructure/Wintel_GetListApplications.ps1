# File: Wintel_GetListApplications.ps1
# Extracted from https://www.howtogeek.com/165293/how-to-get-a-list-of-software-installed-on-your-pc-with-a-single-command/#:~:text=First%2C%20open%20PowerShell%20by%20clicking,with%20an%20empty%20PowerShell%20prompt.&text=PowerShell%20will%20give%20you%20a,the%20date%20you%20installed%20it.
# Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
# Added in 2020-11-24_2

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
 Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize