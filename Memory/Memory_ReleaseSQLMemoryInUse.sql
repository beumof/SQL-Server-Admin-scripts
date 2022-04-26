--File: Memory_ReleaseSQLMemoryInUse.sql
--Extracted from: https://stackoverflow.com/questions/38998909/how-do-you-force-sql-server-to-release-memory
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-12-16

sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
/*** Drop the max down to XX GB temporarily ***/
sp_configure 'max server memory', 49152;  --48GB
GO  
RECONFIGURE;  
GO  
/**** Wait a couple minutes to let SQLServer to naturally release the RAM..... ****/
WAITFOR DELAY '00:02:00'; 
GO
/** now bump it back up to "lots of RAM"! ****/
sp_configure 'max server memory', 50068;   
GO  
RECONFIGURE;    
GO  
sp_configure 'show advanced options', 0;  
GO  
RECONFIGURE;  
GO 