--File: SQLJobs/SQLJobs_EnableAgentXPs.sql
--Extracted from https://www.sqlshack.com/how-to-fix-the-agent-xps-disabled-error/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-10-21

use master
go
exec sp_configure 'Show advanced options',1
Go
reconfigure with override
go

use master
go
exec sp_configure 'Agent XPs',1
Go
reconfigure with override
go

use master
go
exec sp_configure 'Show advanced options',0
Go
reconfigure with override
go

--To check it, value field should be 1.
use master
go
select * from sys.configurations where name='Agent XPs'