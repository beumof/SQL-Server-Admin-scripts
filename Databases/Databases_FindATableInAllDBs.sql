--File: Databases/Databases_FindATableInAllDBs.sql
--Extracted from https://stackoverflow.com/questions/18141547/display-all-the-names-of-databases-containing-particular-table
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2022-01-10

SELECT name 
FROM sys.databases 
WHERE CASE WHEN state_desc = 'ONLINE' THEN OBJECT_ID(QUOTENAME(name) + '.<SCHEMA>.<TABLE>','U') END IS NOT NULL


--OR even better
--Extracted from https://social.technet.microsoft.com/wiki/contents/articles/17958.find-a-table-on-a-sql-server-across-all-databases.aspx
--Added in 2022-04-21

sp_MSforeachdb 'SELECT "?" AS DB, * FROM [?].sys.tables WHERE name like ''%<TABLE>%'''