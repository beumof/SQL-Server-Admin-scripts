:: File: Connectivity_CheckSPNs.cmd
:: Extracted from "Unkown"
:: Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
:: Added in 2019-10-31

:: List SPNs registered for a SQL Server, searching by service account (try with and witout domain)
setspn -l <serviceAccount>

:: Example of a correct output
:: C:\> setspn -q MSSQLSvc/mymachine.mydomain.com:1433
:: Checking domain DC=domain1,DC=com
:: CN=ServiceAccountName,OU=Service Accounts,OU=OUName,OU=EMEA,DC=zurich,DC=uat
::        MSSQLSvc/mymachine:1433
::        MSSQLSvc/mymachine.mydomain.com:1433


:: List SPNs registered for a SQL Server, searching by server
setspn -l MSSQLSvc/<FQDN>:<port>

:: Example of a correct output
:: C:>setspn -q MSSQLSvc/mymachine.mydomain.com:1433
:: Registered ServicePrincipalNames for CN=MYSERVICEACCOUNT,OU=Service Accounts,DC=mydomain,DC=com
::     MSSQLSvc/mymachine:1433
::     MSSQLSvc/mymachine.mydomain.com:1433