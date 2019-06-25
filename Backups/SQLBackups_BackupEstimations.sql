--File: Backups/SQLBackups_BackupEstimations.sql
--Extracted from https://www.mssqltips.com/sqlservertip/5253/sql-server-stored-procedure-to-calculate-database-backup-compression-ratio/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-06-25

-- Create this SP and then call it (see how at the bottom)
USE master
GO

CREATE PROCEDURE usp_Calc_DB_Compression_Ratio_Pct (
   @dbName SYSNAME,
   @compressPct DECIMAL (5, 1) OUTPUT
   )
AS
BEGIN
   DECLARE @dynaTSQL VARCHAR(400)

   SET NOCOUNT ON
   SET @dynaTSQL = CONCAT (
         'BACKUP DATABASE ',
         @dbName,
         ' TO DISK = N',
         '''',
         'nul',
         '''',
         ' with compression, copy_only '
         )

   EXEC (@dynaTSQL)

   SELECT @compressPct = cast (100.0*a.compressed_backup_size / a.backup_size AS DECIMAL (5, 1))
   FROM msdb..backupset a
   WHERE lower (a.database_name) = @dbName AND a.backup_finish_date = (
         SELECT max (backup_finish_date)
         FROM msdb..backupset
         )

   SET NOCOUNT OFF
END
GO

-- To get the estimation
USE master
GO

DECLARE @comppct DECIMAL (5, 1)

EXEC usp_Calc_DB_Compression_Ratio_Pct @dbname = 'Northwind',
   @compressPct = @comppct OUTPUT

PRINT @comppct
