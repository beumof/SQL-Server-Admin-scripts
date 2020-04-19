Get-Eventlog system | Where-Object {$_.eventid -eq 6006} | Select-Object -first 10
