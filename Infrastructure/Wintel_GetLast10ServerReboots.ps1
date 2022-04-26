Get-Eventlog system | Where-Object {$_.eventid -eq 6006} | Select-Object -first 10

#For more details

Get-Eventlog system | Where-Object {$_.eventid -eq 1074 -or $_.eventid -eq 6008 -or $_.eventid -eq 1076} `
| FormatTable Machinename, TimeWritten, UserName, EventID, Message -AutoSize -Wrap