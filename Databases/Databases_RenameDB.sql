--File: Databases/Databases_RenameDB.sql
--Extracted from https://www.mssqltips.com/sqlservertip/1070/simple-script-to-backup-all-sql-server-databases/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-08-31

DECLARE @OLD_DBNAME		varchar(30) -- Nombre Actual DB
DECLARE @NEW_DBNAME		varchar(30) --Nuevo Nombre DB
DECLARE @OLD_DATA_LOGICALNAME		varchar(50) -- Nombre Logico del grupo Primario de Datos actual
DECLARE @NEW_DATA_LOGICALNAME		varchar(50) -- Nuevo Nombre Logico del grupo Primario de Datos
DECLARE @OLD_LOG_LOGICALNAME		varchar(50) -- Nombre Logico del grupo Primario de Log actual
DECLARE @NEW_LOG_LOGICALNAME		varchar(50) -- Nuevo Nombre Lógico del grupo de Log Primario
DECLARE @OLD_DATA_PHYSICALNAME		varchar(200) -- Nombre Fisico del grupo Primario de Datos actual
DECLARE @NEW_DATA_PHYSICALNAME		varchar(200) -- Nuevo Nombre Fisico del grupo Primario de Datos
DECLARE @OLD_LOG_PHYSICALNAME		varchar(200) -- Nombre Fisico del grupo Primario de Log actual
DECLARE @NEW_LOG_PHYSICALNAME		varchar(200) -- Nuevo Nombre Fisico Lógico del grupo de Log Primario
DECLARE @NEW_SO_DATA_PHYSICALNAME	varchar(50)
DECLARE @NEW_SO_LOG_PHYSICALNAME	varchar(50)
DECLARE @CMD						varchar(200)
/* Ejecutar la siguiente Query para extraer los nombres de los ficheros logicos y fisicos que componen una DB
SELECT f.name AS [File Name] , f.physical_name AS [Physical Name], 
CAST((f.size/128.0) AS DECIMAL(15,2)) AS [Total Size in MB],
CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2)) 
AS [Available Space In MB], f.[file_id], fg.name AS [Filegroup Name],
f.is_percent_growth, f.growth, 
fg.is_default, fg.is_read_only
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.filegroups AS fg WITH (NOLOCK)
ON f.data_space_id = fg.data_space_id
ORDER BY f.[file_id] OPTION (RECOMPILE);
*/

/*
La Query anterior nos devolvera algo similar a lo siguiente
File Name	Physical Name	
CHRXS1Prueba_change	E:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\CHRXS1Prueba_change.mdf	
CHRXS1Prueba_change_log	F:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\CHRXS1Prueba_change_log.ldf
*/
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
--VARIABLES ASSIGNMENT SECTION
---------------------------------------------------------------------------------------------------------------------------------------------
--Example DB name is named as "CHRXS1Prueba_change" and then target DB name will be as "CHRXS1Prueba_change_B"
--REMINDER!!! IMPORTANT: USE [XXXXX] FOR OBJECT NAMES WITH SPECIAL CHARACTERS (-, /, SPACE, _, ETC...) AS SHOWN BELOW
SET @OLD_DBNAME = '[CHRXS1Prueba_change]'
SET @NEW_DBNAME = '[CHRXS1Prueba_change_B]'
SET @OLD_DATA_LOGICALNAME = '[CHRXS1Prueba_change]'
SET @NEW_DATA_LOGICALNAME = '[CHRXS1Prueba_change_B]'
SET @OLD_LOG_LOGICALNAME = '[CHRXS1Prueba_change_log]'
SET @NEW_LOG_LOGICALNAME = '[CHRXS1Prueba_change_B_log]'
SET @OLD_DATA_PHYSICALNAME = 'E:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\CHRXS1Prueba_change.mdf'
SET @NEW_DATA_PHYSICALNAME = 'E:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\CHRXS1Prueba_change_B.mdf'
SET @NEW_SO_DATA_PHYSICALNAME = 'CHRXS1Prueba_change_B.mdf'
SET @OLD_LOG_PHYSICALNAME = 'F:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\CHRXS1Prueba_change_log.ldf'
SET @NEW_LOG_PHYSICALNAME = 'F:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\CHRXS1Prueba_change_B_log.ldf'
SET @NEW_SO_LOG_PHYSICALNAME = 'CHRXS1Prueba_change_B_log.ldf'

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

-- Set Database as a Single User 
EXEC('ALTER DATABASE '+ @OLD_DBNAME +' SET SINGLE_USER WITH ROLLBACK IMMEDIATE')

-- Change Logical File Name 
EXEC('ALTER DATABASE '+ @OLD_DBNAME + ' MODIFY FILE (NAME='+ @OLD_DATA_LOGICALNAME +', NEWNAME='+ @NEW_DATA_LOGICALNAME +')')
EXEC('ALTER DATABASE '+ @OLD_DBNAME + ' MODIFY FILE (NAME='+ @OLD_LOG_LOGICALNAME +', NEWNAME='+ @NEW_LOG_LOGICALNAME +')')

--Change physical name 
EXEC('ALTER DATABASE '+@OLD_DBNAME+' MODIFY FILE (NAME = '+@NEW_DATA_LOGICALNAME+', FILENAME = "'+@NEW_DATA_PHYSICALNAME+'")') 
EXEC('ALTER DATABASE '+@OLD_DBNAME+' MODIFY FILE (NAME = '+@NEW_LOG_LOGICALNAME+', FILENAME = "'+@NEW_LOG_PHYSICALNAME+'")') 

--change database name
USE master;  
EXEC('ALTER DATABASE '+@OLD_DBNAME+' Modify Name = '+@NEW_DBNAME)   
 
--SET DATABASE OFFLINE
EXEC('ALTER DATABASE '+@NEW_DBNAME+ ' SET OFFLINE')

--change physical name at os level
-- Cambio DATA
SET @CMD= 'RENAME "'+@OLD_DATA_PHYSICALNAME+'","'+@NEW_SO_DATA_PHYSICALNAME+'"'
exec xp_cmdshell @CMD
--Cambio el Log
SET @CMD= 'RENAME "'+@OLD_LOG_PHYSICALNAME+'","'+@NEW_SO_LOG_PHYSICALNAME+'"'
exec xp_cmdshell @CMD

--SET DATABASE ONLINE
EXEC('ALTER DATABASE '+@NEW_DBNAME+' SET ONLINE')
EXEC('ALTER DATABASE '+@NEW_DBNAME+' SET MULTI_USER')