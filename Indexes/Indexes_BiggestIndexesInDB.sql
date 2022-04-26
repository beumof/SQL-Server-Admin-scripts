--File: Indexes/Indexes_BiggestIndexesInDB.sql
--Extracted from https://aboutsqlserver.com/2014/12/02/size-does-matter-10-ways-to-reduce-the-database-size-and-improve-performance-in-sql-server/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-04-23

;with SpaceInfo(ObjectId, IndexId, TableName, IndexName, Rows, TotalSpaceMB, UsedSpaceMB)
as
( 
    select  
        t.object_id as [ObjectId]
        ,i.index_id as [IndexId]
        ,s.name + '.' + t.Name as [TableName]
        ,i.name as [Index Name]
        ,sum(p.[Rows]) as [Rows]
        ,sum(au.total_pages) * 8 / 1024 as [Total Space MB]
        ,sum(au.used_pages) * 8 / 1024 as [Used Space MB]
    from sys.tables t with (nolock) 
    join sys.schemas s with (nolock) on s.schema_id = t.schema_id
    join sys.indexes i with (nolock) on t.object_id = i.object_id
    join sys.partitions p with (nolock) on i.object_id = p.object_id and i.index_id = p.index_id
    cross apply
        (
             select 
                 sum(a.total_pages) as total_pages
                 ,sum(a.used_pages) as used_pages
             from sys.allocation_units a with (nolock)
             where p.partition_id = a.container_id 
        )  au
    where i.object_id > 255
    group by t.object_id, i.index_id, s.name, t.name, i.name
)
select 
    ObjectId, IndexId, TableName, IndexName
    ,Rows, TotalSpaceMB, UsedSpaceMB
    ,TotalSpaceMB - UsedSpaceMB as [ReservedSpaceMB]
from SpaceInfo		
order by TotalSpaceMB desc
option (recompile)