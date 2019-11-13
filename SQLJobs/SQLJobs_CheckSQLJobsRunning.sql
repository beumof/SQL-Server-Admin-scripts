--File: SQLJobs_CheckSQLJobsRunning.sql
--Compilled in https://www.dbrnd.com/2017/02/sql-server-script-to-find-bad-sessions-or-processes-block-transaction-waiting-session/
--Added in 2019-11-12
--Commentaries: Check SQL jobs running in the SQL instance (with SPID)

SELECT p.spid, j.name
FROM master.dbo.sysprocesses p
JOIN msdb.dbo.sysjobs j 
  ON master.dbo.fn_varbintohexstr(convert(varbinary(16), job_id)) COLLATE Latin1_General_CI_AI = substring(replace(program_name, 'SQLAgent - TSQL JobStep (Job ', ''), 1, 34)
