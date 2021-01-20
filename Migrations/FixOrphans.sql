--File: Migraations/Migrations_FixOrphans.sql
--Extracted from: Unknown (updated with info from MS SQL official web)
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-10-14

SELECT 'ALTER USER ['+[name]+'] WITH LOGIN = ['+[name]+']'
FROM sysusers
WHERE sid IS NOT NULL 
AND [name] NOT IN ('dbo','guest','public') 
AND [name] NOT LIKE 'db_%' 
AND [name] NOT LIKE 'BUILTIN%'


/* Old version, it creates the login if it does not exist, but sp will be deprecated
-- EXEC master..sp_change_users_login 'report' -- list users to fix

SELECT 'EXEC master..sp_change_users_login ''auto_fix'','''+[name]+''''
FROM sysusers
WHERE sid IS NOT NULL 
AND [name] NOT IN ('dbo','guest','public') 
AND [name] NOT LIKE 'db_%' 
AND [name] NOT LIKE 'BUILTIN%'

*/