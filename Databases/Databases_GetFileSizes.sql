--File: Databases/Databases_GetFileSizes.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2022-04-07

DECLARE @FileType NVARCHAR(5) = '%' --Possible values: ROWS & LOG, use % for all files
DECLARE @OnlyUserDBs bit = 0 --Possible values: 0: include all dbs, 1: include only UserDBs

DECLARE @SqlStatement nvarchar(MAX);
CREATE TABLE #DatabaseSpace (DBName sysname, [FileName] sysname, Used_KB bigint);

SET @SqlStatement= N'USE [?];
	SELECT DB_NAME(), f.name, CONVERT(bigint,fileproperty(f.name,''SpaceUsed''))*8
	FROM sys.database_files f;';

INSERT INTO #DatabaseSpace
EXECUTE sp_MSforeachdb @SqlStatement;

SELECT DB_NAME(f.database_id) AS DBName
	,f.name AS [FileName]
	,f.type_desc
	,volume_mount_point
	,CAST(total_bytes/1024.0/1024.0/1024.0 AS decimal(12,2)) AS DriveSize_GB
	,CAST(available_bytes /1024.0/1024.0/1024.0 AS decimal(12,2)) AS DriveFree_GB 
	,CAST(Used_KB/1024.0/1024.0 AS decimal(12,2)) AS Used_GB
	,CAST(size/128.0/1024.0 AS decimal(12,2)) AS FileSize_GB
	,CAST(CASE --not taking in account if autogrowth is disabled
		WHEN max_size=0 THEN size/128.0/1024.0 --it will grow until current file gets full.
		WHEN max_size=-1 THEN total_bytes/1024.0/1024.0/1024.0 --datafile that will grow until drive is full
		ELSE max_size/128.0/1024.0 
		END AS decimal(12,2)) AS FileMaxSize_GB
	,CAST(CASE --taking in account if autogrowth is disabled
		WHEN growth=0 OR max_size=0 THEN size/128.0/1024.0 --Autogrowth disabled, so it will grow until current file gets full.
		WHEN max_size=-1 THEN total_bytes/1024.0/1024.0/1024.0 --datafile that will grow until drive is full
		ELSE max_size/128.0/1024.0 
		END AS decimal(12,2)) AS RealFileMaxSize_GB
	,CASE f.growth
		WHEN 0 THEN 'Disabled'
		ELSE 'By '+IIF(f.is_percent_growth = 1, CAST(f.growth AS VARCHAR(12))+'%', CONVERT(VARCHAR(30), CAST((f.growth*8) / 1024.0 AS DECIMAL(12,2)))+' MB') 
		END AS [Autogrowth]
FROM sys.master_files AS f  
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
INNER JOIN #DatabaseSpace ds ON DB_NAME(f.database_id)=ds.DBName AND f.name=ds.FileName
WHERE type_desc LIKE @FileType
AND (@OnlyUserDBs=0 OR DB_NAME(f.database_id) NOT IN ('master','model','msdb','tempdb')) --To exclude system DBs
AND (@OnlyUserDBs=0 OR DB_NAME(f.database_id) NOT LIKE 'CHRX%') --To exclude any other management DBs
ORDER BY DB_NAME(f.database_id),f.type_desc,f.name ASC

DROP TABLE #DatabaseSpace
