-- File: DeadLocks_CheckDeadlocks.sql
-- Extracted from "Unkown"
-- Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
-- Added in 2019-09-19

-- Check Deadlocks using extended-events (system_health default session)

SELECT
XEvent.value('(@timestamp)[1]', 'datetime') as UTC_event_time,
XEvent.query('(data/value/deadlock)') AS deadlock_graph
FROM (
	SELECT CAST(event_data AS XML) as [target_data]
	FROM sys.fn_xe_file_target_read_file('system_health_*.xel',NULL,NULL,NULL)
	WHERE object_name like 'xml_deadlock_report'
	) AS [x]
CROSS APPLY target_data.nodes('/event') AS XEventData(XEvent)


-- Execute these sentences to active deadlocks traces on SQL log:
-- DBCC TRACEON (1204,-1)
-- DBCC TRACEON (1222,-1)
-- To find the info regarding the deadlocks, check the SQL logs on SSMS or ERRORLOG files.