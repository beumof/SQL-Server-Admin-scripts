--File: Users/Users_SearchForALogin.sql
--Inspired in: a commentary in https://dba.stackexchange.com/questions/81595/a-query-that-lists-all-mapped-users-for-a-given-login & https://stackoverflow.com/questions/7048839/sql-server-query-to-find-all-permissions-access-for-all-users-in-a-database && https://www.mssqltips.com/sqlservertip/6165/find-embedded-sql-server-logins-in-jobs-linked-servers-or-ssisdb/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2020-04-19; Last updated in 2021-02-22

DECLARE @loginName SYSNAME
SET @loginName = N'SQLDBCapacity'; --using LIKE search, use % if required.

-- Getting InstanceRoles
SELECT @@servername AS SQLInstance, p.name AS loginname, type_desc, create_date, modify_date
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
DECLARE @DB_Users TABLE (DBName sysname, loginname sysname, UserName varchar(120), LoginType sysname
, AssociatedRole varchar(max), create_date datetime, modify_date datetime)

INSERT @DB_Users
EXEC sp_MSforeachdb
'use [?]
SELECT ''?'' AS DB_Name
,prin.name AS loginname,
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

SELECT @@servername AS SQLInstance
	, username
	, CASE loginname WHEN username THEN '=' ELSE username END AS loginname
	, dbname
	, logintype
	, create_date
	, modify_date
    , STUFF((SELECT ',' + CONVERT(VARCHAR(500), associatedrole)
        FROM @DB_Users user2
        WHERE user1.DBName=user2.DBName AND user1.UserName=user2.UserName
        FOR XML PATH('')
    ),1,1,'') AS DB_Roles
	,'USE ['+dbname+']; DROP USER ['+username+'];' AS DropUserStatement
FROM @DB_Users user1
WHERE logintype IN ('SQL_USER','WINDOWS_USER','WINDOWS_GROUP')
AND (user1.UserName LIKE @loginName OR user1.loginname like @loginName)
--AND user1.UserName IN ('loginName1','loginName2') -- Use to get a specific list of logins
GROUP BY dbname, loginname, username, logintype, create_date, modify_date
ORDER BY DBName, loginname, username


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


--Getting linked server configurations where user is configured
USE [master]
SELECT @@SERVERNAME AS SQLInstance
	, CASE local_principal_id WHEN 0 THEN 'Public' ELSE USER_NAME(local_principal_id) END AS LocalPrincipal
	, CASE uses_self_credential WHEN 1 THEN 'Yes' ELSE 'No' END AS SelfCredential
	, [s].[name] [LinkedServerName]
	, [s].[data_source] [Database]
	, [ll].[remote_name] [RemotePrincipal]
FROM [sys].[servers] [s]
INNER JOIN [sys].[linked_logins] [ll] ON [ll].[server_id] = [s].[server_id]
 WHERE user_name([ll].local_principal_id) = @loginname OR [ll].[remote_name] = @loginname

--Getting SQL jobs steps where user is configured
USE [msdb]
SELECT @@SERVERNAME AS SQLInstance 
	, @loginName AS loginname
	, [j].[name] [JobName], [js].[step_id], [js].[step_name], [js].[command]
FROM [dbo].[sysjobs] [j]
INNER JOIN [dbo].[sysjobsteps] [js] ON [js].[job_id] = [j].[job_id]
WHERE [js].[command] LIKE '%'+@loginname+'%'

--Getting SSIS info stored in SSISDB database related to the user
IF DB_ID('SSISDB') IS NOT NULL
BEGIN
  SELECT @@SERVERNAME AS SQLInstance 
	, @loginName AS loginname
	, [f].[name] [folder], [p].[name] [project], [op].[object_name] [package], [op].[parameter_name] [parameter],
         [op].[design_default_value], [op].[default_value], [j].[name] [JobName], [js].[step_id], [js].[step_name],
         [js].[command]
  FROM [SSISDB].[catalog].[folders] [f]
  INNER JOIN [SSISDB].[catalog].[projects] [p] ON [p].[folder_id] = [f].[folder_id]
  INNER JOIN [SSISDB].[catalog].[object_parameters] [op] ON [op].[project_id] = [p].[project_id]
   LEFT JOIN [msdb].[dbo].[sysjobsteps] [js] ON [js].[command] LIKE '%'+[op].[object_name]+'%' COLLATE DATABASE_DEFAULT
   LEFT JOIN [msdb].[dbo].[sysjobs] [j] ON [j].[job_id] = [js].[job_id]
  WHERE [op].[design_default_value] = @loginname
     OR [op].[default_value] = @loginname

  SELECT @@SERVERNAME AS SQLInstance 
	, @loginName AS loginname
	, [e].[name] [Environment], [ev].[name] [Variable], [ev].[value]
  FROM [SSISDB].[catalog].[environments] [e]
  INNER JOIN [SSISDB].[catalog].[environment_variables] [ev] ON [ev].[environment_id] = [e].[environment_id]
  WHERE [ev].[value] = @loginname
END
