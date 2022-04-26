--File: Users/Users_ExportLogin.sql
--Author: beumof@gmail.com (v.0.1)
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2022-01-27

-- Generates the SQL to create the login/users and grant roles/permissions.
-- Execute in SSMS with "Results as text" activated.

DECLARE @loginName SYSNAME, @DBName SYSNAME
SET @loginName = N'%<LOGINNAME>%'; --using LIKE search, use % if required.
SET @DBName = N'%' --default value must be %

SET NOCOUNT ON

SELECT 'USE [master]; IF '''+l.name+''' NOT IN (SELECT name FROM sys.syslogins) CREATE LOGIN ['+l.name+'] FROM '+CASE type_desc WHEN 'WINDOWS_LOGIN' THEN 'WINDOWS' ELSE '???' END+' WITH DEFAULT_LANGUAGE=['+default_language_name+'] , DEFAULT_DATABASE=['+default_database_name+']; ALTER LOGIN ['+l.name+'] '+CASE is_disabled WHEN 1 THEN 'DISABLE' ELSE 'ENABLE' END +';'
FROM sys.server_principals l
WHERE l.type_desc IN ('SQL_LOGIN','WINDOWS_LOGIN','WINDOWS_GROUP')
AND l.[name] NOT LIKE N'##%'
AND l.[name] NOT LIKE N'NT SERVICE%'
AND l.[name] NOT LIKE N'NT AUTH%'
AND l.name NOT IN ('sa')
AND l.name LIKE @loginName
ORDER BY l.name ASC

SELECT 'USE [master]; EXEC master..sp_addsrvrolemember @loginame=N'''+l.name+''', @rolename='''+r.name+''''
FROM sys.server_principals l
LEFT JOIN sys.server_role_members srm ON l.principal_id = srm.member_principal_id
LEFT JOIN sys.server_principals r ON srm.role_principal_id = r.principal_id
WHERE l.type_desc IN ('SQL_LOGIN','WINDOWS_LOGIN','WINDOWS_GROUP')
AND l.[name] NOT LIKE N'##%'
AND l.[name] NOT LIKE N'NT SERVICE%'
AND l.[name] NOT LIKE N'NT AUTH%'
AND l.name NOT IN ('sa')
AND l.name LIKE @loginName
AND r.name IS NOT NULL
ORDER BY l.name ASC

SELECT 'USE [master]; '+state_desc+' '+permission_name COLLATE Latin1_General_CI_AS+' TO ['+name+']'
FROM sys.server_permissions ssperm 
LEFT JOIN sys.server_principals ssprin ON ssperm.grantee_principal_id = ssprin.principal_id
WHERE name LIKE @loginName

-- Getting DBRoles
DECLARE @DB_Users TABLE (DBName sysname, loginname sysname, UserName varchar(120), LoginType sysname
, AssociatedRole varchar(max), create_date datetime, modify_date datetime)

INSERT @DB_Users
EXEC sp_MSforeachdb
'use [?]
SELECT ''?'' AS DBName
	,prin.name AS loginname
	,prin.name AS UserName
	,prin.type_desc AS LoginType
	,isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole
	,create_date
	,modify_date
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
WHERE mem.role_principal_id IS NOT NULL'

SELECT 'USE ['+DBName+']; CREATE USER ['+UserName+'] FOR LOGIN ['+loginName+']'
FROM @DB_Users
WHERE loginName LIKE @loginName
AND DBName like @DBName
GROUP BY DBName,UserName,loginName 
ORDER BY DBName,UserName,loginName 

SELECT 'USE ['+DBName+']; ALTER ROLE ['+AssociatedRole+'] ADD MEMBER ['+UserName+']'
FROM @DB_Users
WHERE loginName LIKE @loginName
AND DBName like @DBName


DECLARE @DB_Users_Permissions TABLE (DBName sysname, DatabaseUserName sysname, PermissionType varchar(150), PermissionState varchar(150)
	, ObjectType varchar(150), SchemaName varchar(150), ObjectName varchar(150), ColumnName varchar(150))

INSERT @DB_Users_Permissions
EXEC sp_MSforeachdb
'use [?];
SELECT ''?'' AS DBName
    ,princ.[name] AS DatabaseUserName
    ,perm.[permission_name] AS PermissionType
    ,perm.[state_desc] AS PermissionState
    ,obj.type_desc AS ObjectType
	,IsNull(SCHEMA_NAME(obj.schema_id),'''') AS SchemaName
    ,OBJECT_NAME(perm.major_id) AS ObjectName
    ,col.[name] AS ColumnName
FROM sys.database_principals princ --database user
LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid] --Login accounts
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id] --Permissions
LEFT JOIN sys.columns col ON col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id] --Table columns
LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE princ.[type] in (''S'',''U'')
AND (obj.type_desc IS NULL OR obj.type_desc<>''SYSTEM_TABLE'')'

SELECT 'USE ['+DBName+']; '+PermissionState+' '+PermissionType+CASE ObjectType WHEN 'SQL_STORED_PROCEDURE' THEN ' ON ['+SchemaName+'].['+ObjectName+']' ELSE '' END +' TO ['+DatabaseUserName+']'
FROM @DB_Users_Permissions
WHERE DatabaseUserName LIKE @loginName
AND DBName like @DBName