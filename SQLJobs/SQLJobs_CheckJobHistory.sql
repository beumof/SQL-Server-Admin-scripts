--File: SQLJobs\SQLJobs_CheckJobHistory
--Adadted from https://www.mssqltips.com/sqlservertip/2850/querying-sql-server-agent-job-history-data/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2020-01-02
--Commentaries: Check job history, or even failures

SELECT
j.name AS 'JobName'
,msdb.dbo.agent_datetime(run_date, run_time) AS 'RunDateTime'
,(run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) AS 'RunDurationSeconds'
,run_status
FROM msdb.dbo.sysjobs j 
INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id 
WHERE j.enabled = 1   -- only Enabled Jobs
-- AND j.name = 'Checklogspace' -- uncomment to search for a particular job
-- AND msdb.dbo.agent_datetime(run_date, run_time) BETWEEN '12/08/2012' AND '12/10/2012'  -- uncomment for date range queries
-- AND run_status = 0 -- uncomment to check for job failures
ORDER BY RunDateTime DESC