--File: Backups/SQLBackups_BackupsChain.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05

-- CHECK DIFFERENTIAL DB BACKUPS SET (CHAIN)
SELECT
s.backup_start_date as 'Start Date',
s.backup_finish_date as 'Full Date',
CONVERT(varchar, s.backup_finish_date, 103) as 'Date',
CONVERT(VARCHAR(8),s.backup_finish_date,108) as 'Time',
DATEDIFF(minute, s.backup_start_date, s.backup_finish_date) as 'Duration (minutes)',
s.database_name as 'Database Name',
CAST(s.backup_size / (1024*1024) as int)  as 'DBSize (MBs)',
CASE
WHEN (s.[type] = 'D' AND s.is_copy_only = 0) THEN 'Full'
WHEN (s.[type] = 'D' AND s.is_copy_only = 1) THEN 'Full - CopyOnly'
WHEN (s.[type] = 'I') THEN 'Differential database'
WHEN (s.[type] = 'L') THEN 'Log'
WHEN (s.[type] = 'F') THEN 'File or filegroup'
WHEN (s.[type] = 'G') THEN 'Differential file'
WHEN (s.[type] = 'P') THEN 'Partial'
WHEN (s.[type] = 'G') THEN 'Differential partial'
ELSE NULL
END AS BackupType,
s.is_damaged,
m.physical_device_name as 'Backup Device',
t.physical_device_name as 'Differential base - Device',
t.backup_finish_date as 'Differential base - Full Date',
s.[user_name] as [User]
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
LEFT JOIN
(SELECT ss.backup_set_uuid, ss.backup_finish_date, mm.physical_device_name
FROM msdb.dbo.backupset ss
INNER JOIN msdb.dbo.backupmediafamily mm ON ss.media_set_id = mm.media_set_id
) as t
ON s.differential_base_guid = t.backup_set_uuid
order by s.backup_start_date desc
GO
