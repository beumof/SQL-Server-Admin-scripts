--File: Backups/SQLBackups_BackupsDone.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-06-25

--CHECK ALL BACKUPS DONE AND TIME TAKEN
SELECT TOP 100 
s.database_name,
m.physical_device_name,
CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize,
CAST(CAST(s.compressed_backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkCompressedSize,
CAST(DATEDIFF(second, s.backup_start_date,
s.backup_finish_date) AS VARCHAR(15)) + ' ' + 'Seconds' TimeTaken,
s.backup_start_date,
--CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn,
--CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn,
CASE s.[type]
    WHEN 'D' THEN 'Full'
    WHEN 'I' THEN 'Differential'
    WHEN 'L' THEN 'Transaction Log'
END AS BackupType,
s.server_name,
s.recovery_model
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = DB_NAME() -- Commnent this line for all the database
AND s.type='D' --configure this line to choose the backup type to show (D/I/L)
--AND database_name NOT IN ('master','msdb','model','distribution') -- Uncomment this line to exclude system dbs
ORDER BY backup_start_date DESC, backup_finish_date
GO 