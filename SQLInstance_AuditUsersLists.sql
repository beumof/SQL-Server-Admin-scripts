-- GENERATE LOGIN/USER LIST FOR AUTIDORY PURPOSES

CREATE TABLE #results (   
    dbname varchar (100), 
    username varchar (50), 
    permission varchar (50) 
)
 
--SELECT SYSADMINS
INSERT INTO #results (dbname, username, permission) 
SELECT null,name,'sysadmin'
FROM master.sys.server_principals
WHERE IS_SRVROLEMEMBER('sysadmin',name)=1
AND is_disabled = 0
 
EXEC SP_MSFOREACHDB'USE [?]
--SELECT DB_OWNERS/DB_DATAWRITERS
INSERT INTO #results (dbname, username, permission)
select ''?'',p.[name],r.[name]
from sys.database_role_members m
join sys.database_principals r on m.role_principal_id = r.principal_id
join sys.database_principals p on m.member_principal_id = p.principal_id
WHERE r.name IN (''db_owner'',''db_datawriter'')
AND db_name() NOT IN(''master'',''tempdb'',''msdb'',''model'') -- exclude system dbs
--AND db_name() NOT IN('''') -- exclude user DBs
--AND db_name() IN ('''') -- include user DBs
'
SELECT @@SERVERNAME as server,* 
FROM #results ORDER BY server, dbname,username
 
DROP TABLE #results