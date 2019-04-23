--File: Indexes/Indexes_IndexFragmentation.sql
--Extracted from https://aboutsqlserver.com/2014/12/02/size-does-matter-10-ways-to-reduce-the-database-size-and-improve-performance-in-sql-server/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-04-23

select 
    index_id, partition_number, alloc_unit_type_desc
    ,index_level, page_count, avg_page_space_used_in_percent
from 
    sys.dm_db_index_physical_stats
    (
        db_id() /*Database */
        ,object_id(N'dbo.MyTable') /* Table (Object_ID) */
        ,1 /* Index ID */
        ,null /* Partition ID – NULL – all partitions */
        ,'detailed' /* Mode */
    )