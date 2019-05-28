Get-Eventlog system | Where-Object {$_.eventid -eq 6006} | SELECT -first 10
