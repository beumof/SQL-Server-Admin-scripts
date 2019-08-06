--File: Backups/SQLBackups_LatestDBBackups.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-31
--Commentaries: Check last backup per DB in the instance

--CHECK Latest DB Backups (Full, Differential and T-log)
SELECT bu.*, recovery_model_Desc AS [Recovery_Model]
FROM (
  SELECT server_name,database_name,
  CASE 
                WHEN physical_device_name LIKE 'TDPSQL%' THEN 'TDP'
                WHEN physical_device_name LIKE '{%' THEN 'TSMVE'
                ELSE 'DISK'
  END As Method,
  CASE [type]
    WHEN 'D' THEN 'Full'
    WHEN 'I' THEN 'Differential'
    WHEN 'L' THEN 'Transaction_Log'
  END As Type,
  max(backup_finish_date) AS lastBackup
  FROM msdb..backupset s
  INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
  WHERE server_name  = @@SERVERNAME
  AND database_name NOT IN ('master','msdb','model','distribution') -- Comment to include system dbs
  --AND backup_finish_date between '2019-01-01 10:00' and '2019-04-16 09:00'
GROUP BY server_name,database_name, CASE WHEN physical_device_name LIKE 'TDPSQL%' THEN 'TDP' WHEN physical_device_name LIKE '{%' THEN 'TSMVE' ELSE 'DISK' END, type
) AS SourceTable PIVOT (max(lastBackup) FOR type IN ([Full],[Differential],[Transaction_Log])) As bu
INNER JOIN master.sys.databases db ON bu.database_name = db.name
WHERE Method = 'TDP' -- Possible methods TDP, TSMVE, DISK
ORDER BY bu.database_name

