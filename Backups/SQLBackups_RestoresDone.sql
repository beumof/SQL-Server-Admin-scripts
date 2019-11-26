--File: Backups/SQLBackups_RestoresDone.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-06-25

--CHECK DB RESTORES
SELECT [rs].[restore_date], 
CASE [rs].[restore_type]
  WHEN 'D' THEN 'Full'
  WHEN 'I' THEN 'Differential'
  WHEN 'L' THEN 'Transaction Log'
END AS RestoreType,
[rs].[destination_database_name], 
rs.user_name as 'RestoredBy',
CASE rs.[replace]
  WHEN NULL THEN 'NULL'
  WHEN 1 THEN 'YES'
  WHEN 0 THEN 'NO'
END AS 'Database Replaced',
[bs].[backup_start_date], 
[bs].[backup_finish_date], 
[bs].[database_name] as [source_database_name], 
[bmf].[physical_device_name] as [backup_file_used_for_restore]
FROM msdb..restorehistory rs
INNER JOIN msdb..backupset bs ON [rs].[backup_set_id] = [bs].[backup_set_id]
INNER JOIN msdb..backupmediafamily bmf ON [bs].[media_set_id] = [bmf].[media_set_id] 
ORDER BY [rs].[restore_date] DESC