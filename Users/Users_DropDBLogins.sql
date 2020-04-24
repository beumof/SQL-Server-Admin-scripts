--File: Users/Users_DropDBLogins.sql
--Inspired from: https://dba.stackexchange.com/questions/81595/a-query-that-lists-all-mapped-users-for-a-given-login
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2020-04-24


DECLARE @DBNameToDelete SYSNAME = N'psg_cam';

--Generate scripts to drop DB
DECLARE @DB_Users TABLE (DBName sysname, UserName varchar(150), LoginType sysname
, AssociatedRole varchar(max), create_date datetime, modify_date datetime)

INSERT @DB_Users
EXEC sp_MSforeachdb
'use [?]
SELECT ''?'' AS DB_Name,
case prin.name when ''dbo'' then prin.name + '' (''
    + (select SUSER_SNAME(owner_sid) from master.sys.databases where name =''?'') + '')''
    else prin.name end AS UserName,
    prin.type_desc AS LoginType,
    isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole, 
    create_date, modify_date
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
WHERE prin.sid IS NOT NULL and prin.sid NOT IN (0x00) 
and prin.is_fixed_role <> 1 AND prin.name NOT LIKE ''##%'''

;WITH RemoveLogins_CTE (SQLInstance, Username, LoginType, DBNames)
AS (
SELECT @@servername AS SQLInstance, username, logintype,
    STUFF((SELECT DISTINCT ',' + CONVERT(VARCHAR(500), DBName)
        FROM @DB_Users user2
        WHERE user1.UserName=user2.UserName
        FOR XML PATH('')
    ),1,1,'') AS DBNames
FROM @DB_Users user1
WHERE logintype IN ('SQL_USER','WINDOWS_USER','WINDOWS_GROUP')
GROUP BY username, logintype
)
SELECT *, 'DROP LOGIN ['+UserName+'];' AS '--Query'
FROM RemoveLogins_CTE
WHERE UserName NOT LIKE 'dbo%'
AND DBNames = @DBNameToDelete
ORDER BY username