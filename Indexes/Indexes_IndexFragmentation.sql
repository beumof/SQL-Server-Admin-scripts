--File: Indexes/Indexes_IndexFragmentation.sql
--Extracted from https://www.sqlshack.com/how-to-identify-and-resolve-sql-server-index-fragmentation/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-09-28

SELECT S.name as 'Schema',
T.name as 'Table',
I.name as 'Index',
DDIPS.avg_fragmentation_in_percent,
DDIPS.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
INNER JOIN sys.schemas S on T.schema_id = S.schema_id
INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
AND DDIPS.index_id = I.index_id
WHERE DDIPS.database_id = DB_ID()
and I.name is not null
AND DDIPS.avg_fragmentation_in_percent > 0
--AND T.name IN ('<TableName>') --uncomment to filter by tablename.
ORDER BY DDIPS.avg_fragmentation_in_percent desc


-- Another option

select 
    index_id, partition_number, alloc_unit_type_desc
    ,index_level, page_count, avg_page_space_used_in_percent
from 
    sys.dm_db_index_physical_stats
    (
        db_id() /*Database */
        ,object_id(N'dbo.MyTable') /* Table (Object_ID) */
        ,1 /* Index ID */
        ,null /* Partition ID "NULL" all partitions */
        ,'detailed' /* Mode */
    )