--File: Databases/Database_DatafileSplitProgressCheck.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-10-14


SELECT @@servername as SQLInstance
	, DB_NAME() AS DBName
	, name AS FileName
	, type_desc
	, size/128.0 AS CurrentSizeMB
	, CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS UsedMB
	, size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
	, max_size/128.0 AS MaxSizeMB
FROM sys.database_files
WHERE type IN (0,1)
ORDER BY type,name