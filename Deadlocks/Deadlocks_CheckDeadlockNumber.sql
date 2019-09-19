-- File: DeadLocks_CheckDeadlocksNumber.sql
-- Extracted from "Unkown"
-- Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
-- Added in 2019-09-19

-- To check the number of deadlocks since last SQL instance reboot

SELECT 
    'Deadlocks Occurrences Report', 
    CONVERT(BIGINT,((1.0 * p.cntr_value / 
NULLIF(datediff(DD,d.create_date,CURRENT_TIMESTAMP),0)))) as 
AveragePerDay,
    CAST(p.cntr_value AS NVARCHAR(100)) + ' deadlocks have been recorded 
since startup.' AS Details, 
    d.create_date as StartupDateTime
FROM sys.dm_os_performance_counters p
INNER JOIN sys.databases d ON d.name = 'tempdb'
WHERE RTRIM(p.counter_name) = 'Number of Deadlocks/sec'
AND RTRIM(p.instance_name) = '_Total';