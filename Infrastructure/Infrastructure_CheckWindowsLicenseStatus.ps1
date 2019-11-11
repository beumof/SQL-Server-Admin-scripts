# File: Infrastructure_CheckWindowsLicenseStatus.ps1
# Extracted from Unkonwn
# Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
# Added in 2019-11-07

#defined initial data
$LicenseStatus = @("Unlicensed","Licensed","OOB Grace","OOT Grace","Non-Genuine Grace","Notification","Extended Grace")

$ComputerName = @()
$ComputerName += '<SERVER1>'
$ComputerName += '<SERVER2>'
# …

Foreach($CN in $ComputerName) {
    try {
        Get-CimInstance -ClassName SoftwareLicensingProduct -ComputerName $CN | `
	        Where-Object {$_.PartialProductKey -and $_.Name -like "*Windows*"} | `
            Select-Object `
                @{Expression={$_.PSComputerName}; Name="ComputerName"},`
                @{Expression={$_.Name}; Name="WindowsName"}, `
                ApplicationID, `
	            @{Expression={$LicenseStatus[$($_.LicenseStatus)]}; Name="LicenseStatus"} 
    } catch {
        Wrhite-Host "Error checking $CN server ($_.Exception.ItemName): $_.Exception.Message"
    }
}