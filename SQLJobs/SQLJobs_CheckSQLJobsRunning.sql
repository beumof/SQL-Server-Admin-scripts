--File: SQLJobs\SQLJobs_CheckSQLJobsRunning.sql
--Adadted from https://social.msdn.microsoft.com/Forums/sqlserver/en-US/0eb9c96c-fc06-4ae6-8b30-4e486d62f573/how-to-retrieve-current-step-name-of-currently-running-job?forum=transactsql
-- & https://www.dbrnd.com/2017/02/sql-server-script-to-find-bad-sessions-or-processes-block-transaction-waiting-session/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-11-12
--Commentaries: Check SQL jobs running in the SQL instance (with SPID)

SELECT 
	distinct j.name as JobName
	, spid
	, js.step_id as StepId
	, CASE WHEN ja.last_executed_step_id IS NULL THEN js.step_name  ELSE js2.step_name END as StepName
    , ja.start_execution_date as StartDateTime
	, 'Running' AS RunStatus
	, (SELECT RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(second, start_execution_date, GetDate())/3600), 2) 
	 + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(second, start_execution_date, GetDate())%3600/60), 2) 
	 + ':' + RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(second, start_execution_date, GetDate())%60), 2) ) as Duration
	, program_name
FROM msdb.dbo.sysjobactivity ja 
JOIN msdb.dbo.sysjobs j ON ja.job_id = j.job_id
LEFT JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id
	AND CASE WHEN ja.last_executed_step_id IS NULL THEN j.start_step_id ELSE ja.last_executed_step_id END = js.step_id		    
LEFT JOIN msdb.dbo.sysjobsteps js2 ON js.job_id = js2.job_id AND js.on_success_step_id = js2.step_id
LEFT JOIN master.dbo.sysprocesses sp ON master.dbo.fn_varbintohexstr(convert(varbinary(16), j.job_id)) COLLATE Latin1_General_CI_AI = substring(replace(program_name, 'SQLAgent - TSQL JobStep (Job ', ''), 1, 34)
WHERE ja.session_id = ( SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC )
AND start_execution_date IS NOT NULL
AND stop_execution_date IS NULL

