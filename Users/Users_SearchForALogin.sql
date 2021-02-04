--File: Users/Users_SearchForALogin.sql
--Inspired in: a commentary in https://dba.stackexchange.com/questions/81595/a-query-that-lists-all-mapped-users-for-a-given-login & https://stackoverflow.com/questions/7048839/sql-server-query-to-find-all-permissions-access-for-all-users-in-a-database
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2020-04-19; Last updated in 2021-02-04

-- Getting InstanceRoles
DECLARE @loginName SYSNAME
SET @loginName = N'loginName'; --using LIKE search, use % if required.

SELECT @@servername AS SQLInstance, p.name AS Principal, type_desc, create_date, modify_date
	, STUFF((SELECT ',' + CONVERT(VARCHAR(500), r.name)
		FROM sys.server_principals r
		INNER JOIN sys.server_role_members m ON r.principal_id = m.role_principal_id
		WHERE p.principal_id = m.member_principal_id
        FOR XML PATH('')
    ),1,1,'') AS InstanceRoles
	, 'USE [master]; DROP LOGIN ['+p.name+'];' AS DropLoginStatement
FROM master.sys.server_principals p 
WHERE type_desc IN ('SQL_LOGIN','WINDOWS_LOGIN','WINDOWS_GROUP')
AND is_disabled = 0
AND (
	p.name NOT IN ('sa','BUILTIN\Administrators','NT AUTHORITY\SYSTEM') 
	AND p.name NOT LIKE 'NT SERVICE\%' 
	AND p.name NOT LIKE '##MS_%##' --exclude Certificate-based SQL Server Logins
) --exclude system logins 
AND p.name LIKE @loginName
--AND p.name IN ('loginName1','loginName2') -- Use to get a specific list of logins
ORDER BY p.name


-- Getting DBRoles
DECLARE @DB_Users TABLE (DBName sysname, UserName sysname, LoginType sysname
, AssociatedRole varchar(max), create_date datetime, modify_date datetime)

INSERT @DB_Users
EXEC sp_MSforeachdb
'use [?]
SELECT ''?'' AS DB_Name,
case prin.name when ''dbo'' then prin.name + '' (''
    + (select SUSER_SNAME(owner_sid) from master.sys.databases where name =''?'') + '')''
    else prin.name end AS UserName
    ,prin.type_desc AS LoginType
    ,isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole
    ,create_date
    ,modify_date
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
--WHERE prin.sid IS NOT NULL and prin.sid NOT IN (0x00) 
--and prin.is_fixed_role <> 1 AND prin.name NOT LIKE ''##%'''

SELECT @@servername AS SQLInstance, username, dbname, logintype, create_date, modify_date
    , STUFF((SELECT ',' + CONVERT(VARCHAR(500), associatedrole)
        FROM @DB_Users user2
        WHERE user1.DBName=user2.DBName AND user1.UserName=user2.UserName
        FOR XML PATH('')
    ),1,1,'') AS DB_Roles
	,'USE ['+dbname+']; DROP USER ['+username+'];' AS DropUserStatement
FROM @DB_Users user1
WHERE logintype IN ('SQL_USER','WINDOWS_USER','WINDOWS_GROUP')
AND user1.UserName LIKE @loginName
--AND user1.UserName IN ('loginName1','loginName2') -- Use to get a specific list of logins
GROUP BY dbname, username, logintype, create_date, modify_date
ORDER BY DBName, username


-- Getting DBObjectPermissions
DECLARE @DB_Users_Permissions TABLE (DBName sysname, DatabaseUserName sysname, PermissionType varchar(150), PermissionState varchar(150)
	, ObjectType varchar(150), ObjectName varchar(150), ColumnName varchar(150))

INSERT @DB_Users_Permissions
EXEC sp_MSforeachdb
'use [?];
SELECT ''?'' AS DBName
    ,princ.[name] AS DatabaseUserName
    ,perm.[permission_name] AS PermissionType
    ,perm.[state_desc] AS PermissionState
    ,obj.type_desc AS ObjectType
    ,OBJECT_NAME(perm.major_id) AS ObjectName
    ,col.[name] AS ColumnName
FROM sys.database_principals princ --database user
LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] --Login accounts
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id] --Permissions
LEFT JOIN sys.columns col ON col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id] --Table columns
LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE princ.[type] in (''S'',''U'')
AND princ.[name] NOT IN (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'')'

SELECT @@SERVERNAME AS SQLInstance, *
FROM @DB_Users_Permissions
WHERE DatabaseUserName LIKE @loginName
--WHERE DatabaseUserName IN ('loginName1','loginName2') -- Use to get a specific list of logins
