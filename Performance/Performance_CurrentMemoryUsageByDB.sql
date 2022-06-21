--File: Performance/Performance_CurrentMemoryUsageByDB.sql
--Provided by P. Dominguez
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2022-05-13

WITH MemoryGrants (DBName, MBGrants) AS (
	SELECT DB_NAME(s.database_id) AS DBName
		,SUM(mg.requested_memory_kb/1024) AS MBGrants 
	FROM sys.dm_exec_query_memory_grants mg 
	INNER JOIN sys.dm_exec_sessions s ON mg.session_id = s.session_id 
	GROUP BY DB_NAME(s.database_id)
), MemoryBuffer (DBName, MBBuffer) AS (
	SELECT DB_NAME(database_id) as DBName
		,COUNT(1) * 8 / 1024 AS MBBuffer 
	FROM sys.dm_os_buffer_descriptors 
	GROUP BY database_id
) SELECT SYSDATETIMEOFFSET()
	,mbf.DBName
	,MBBuffer
	,COALESCE(MBGrants,0) AS MBGrants
	,MBBuffer + COALESCE(MBGrants,0) AS MBTotal 
FROM MemoryBuffer mbf 
LEFT JOIN MemoryGrants mgf ON mbf.DBName = mgf.DBName