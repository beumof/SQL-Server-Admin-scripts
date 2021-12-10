--File: Users/Users_CreateRoleDBExecutor.sql
--Extracted from https://www.sqlmatters.com/Articles/Adding%20a%20db_executor%20role.aspx
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-08-31

-- Create a db_executor role
CREATE ROLE db_executor

-- Grant execute rights to the new role
GRANT EXECUTE TO db_executor