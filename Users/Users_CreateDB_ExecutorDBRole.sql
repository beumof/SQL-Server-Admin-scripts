--File: Users\Users_CreateDB_ExecutorDBRole.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021_10_13

EXEC sp_MSforeachdb 'USE [?];IF ''?'' IN (''master'',''tempdb'',''msdb'') RETURN; IF DATABASEPROPERTY(''?'',''IsReadOnly'') = 1 RETURN; 
IF EXISTS (SELECT * FROM [?].sys.database_principals WHERE type = ''R'' AND UPPER(name) = ''DB_EXECUTOR'' AND ASCII(SUBSTRING(name,4,1)) = 101) RETURN; 
IF EXISTS (SELECT * FROM [?].sys.database_principals WHERE type = ''R'' AND UPPER(name) = ''DB_EXECUTOR'') BEGIN USE [?]; 
ALTER ROLE db_Executor WITH NAME = db_executor END ELSE BEGIN USE [?]; 
CREATE ROLE db_executor; GRANT EXECUTE TO db_executor; END '