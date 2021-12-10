--File: Indexes/Indexes_FindDisabledIndexes.sql
--Extracted from https://aboutsqlserver.com/2014/12/02/size-does-matter-10-ways-to-reduce-the-database-size-and-improve-performance-in-sql-server/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-08-20

select s.name AS schemaName, t.name AS tableName, i.name AS [indexName], i.is_disabled 
from sys.tables t
inner join sys.schemas s on t.schema_id = s.schema_id
inner join sys.indexes i on i.object_id = t.object_id
where i.index_id > 0    
 and i.type in (1, 2) -- clustered & nonclustered only
 and i.is_primary_key = 0 -- do not include PK indexes
 and i.is_unique_constraint = 0 -- do not include UQ
 and i.is_disabled = 1 --remove to find status of all 
 and i.is_hypothetical = 0