--CHECK Latest DB Backups (Full, Differential and T-log)
SELECT a.name AS [Database Name],a.recovery_model_Desc AS [Recovery Model],
(SELECT MAX(b.backup_finish_date) FROM msdb..backupset b WHERE b.type = 'D' and a.name=b.database_name) AS [Full Backup],
(SELECT MAX(b.backup_finish_date) FROM msdb..backupset b WHERE b.type = 'I' and a.name=b.database_name) AS [Diff Backup],
(SELECT MAX(b.backup_finish_date) FROM msdb..backupset b WHERE b.type = 'L' and a.name=b.database_name) AS [Log Backup]
FROM master.sys.databases a 