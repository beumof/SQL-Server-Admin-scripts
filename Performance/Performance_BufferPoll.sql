--File: Performance/Performance_BufferPool.sql
--Extracted from https://www.sqlskills.com/blogs/paul/inside-the-storage-engine-whats-in-the-buffer-pool/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-01-28

SELECT ObjectName 
,ISNULL(Clean,0) AS CleanPages 
,ISNULL(Dirty,0) AS DirtyPages 
,STR(ISNULL(Clean,0)/128.0,12,2) AS CleanPagesMB 
,STR(ISNULL(Dirty,0/128.0),12,2) AS DirtyPagesMB
FROM (
	SELECT CASE WHEN GROUPING(t.object_id) = 1 THEN '=> Sum' ELSE Quotename(OBJECT_SCHEMA_NAME(t.object_id)) + '.' + Quotename(OBJECT_NAME(t.object_id)) END AS ObjectName 
	,CASE WHEN bd.is_modified = 1 THEN 'Dirty' ELSE 'Clean' END AS 'PageState' ,COUNT (*) AS 'PageCount' 
	FROM sys.dm_os_buffer_descriptors bd 
	INNER JOIN sys.allocation_units AS allc ON allc.allocation_unit_id = bd.allocation_unit_id 
	INNER JOIN sys.partitions part ON allc.container_id = part.partition_id 
	INNER JOIN sys.tables t ON part.object_id = t.object_id 
	WHERE bd.database_id = DB_ID() 
	GROUP BY GROUPING sets ((t.object_id,bd.is_modified),(bd.is_modified)) 
)pgs PIVOT (SUM(PageCount) FOR PageState IN ([Clean],[Dirty])) AS pvt