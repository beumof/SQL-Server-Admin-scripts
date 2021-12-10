--File: SPs/SPs_RecompileSP.sql
--Extracted from https://www.sqlservercentral.com/forums/topic/finding-last-date-compiled-for-a-stored-procedure
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-09-24

EXEC sp_recompile '<SPName>';

--To confirm the recompliation

SELECT
	db_name(database_id) as database_name
	,object_name(object_id) as sp_name
	,cached_time
	,last_execution_time
FROM sys.dm_exec_procedure_stats
WHERE database_id = db_id('<database>')
--AND object_name(object_id)='<SPName>' --Uncomment to filter by the SPName