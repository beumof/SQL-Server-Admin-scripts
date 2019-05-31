--File: Backups/SQLBackups_LatestDBBackups.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-31
--Commentaries: Check last backup per DB in the instance

--CHECK Latest DB Backups (Full, Differential and T-log)
SELECT bu.database_name, recovery_model_Desc AS [Recovery_Model],[Full],[Differential],[Transaction_Log]
FROM (
  SELECT database_name,
  CASE [type]
    WHEN 'D' THEN 'Full'
    WHEN 'I' THEN 'Differential'
    WHEN 'L' THEN 'Transaction_Log'
  END As Type,
  max(backup_finish_date) AS lastBackup
  FROM msdb..backupset
  WHERE database_name NOT IN ('master','msdb','model','distribution') -- comment to include system dbs
  --AND description like 'TDPSQL%' -- uncomment to filter backups made with TDPSQL
  GROUP BY database_name, type
) AS SourceTable PIVOT (max(lastBackup) FOR type IN ([Full],[Differential],[Transaction_Log])) As bu
INNER JOIN master.sys.databases db ON bu.database_name = db.name
ORDER BY bu.database_name
