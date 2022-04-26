--File: Databases/Databases_FindATableInAllDBs.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2020-03-18

--Extracted from https://stackoverflow.com/questions/1443704/query-to-list-number-of-records-in-each-table-in-a-database

SELECT 
    t.NAME AS TableName,
    i.name as indexName,
    p.[Rows],
    sum(a.total_pages) as TotalPages, 
    sum(a.used_pages) as UsedPages, 
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    (sum(a.data_pages) * 8) / 1024 as DataSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.NAME NOT LIKE 'dt%' 
AND i.OBJECT_ID > 255 
AND i.index_id <= 1
GROUP BY t.NAME, i.object_id, i.index_id, i.name, p.[Rows]
ORDER BY object_name(i.object_id) 


--Extracted from: https://blogs.msdn.microsoft.com/martijnh/2010/07/15/sql-serverhow-to-quickly-retrieve-accurate-row-count-for-table/ 

SELECT
    SCHEMA_NAME(schema_id) AS [SchemaName],
    [Tables].name AS [TableName],
    SUM([Partitions].[rows]) AS [TotalRowCount]
FROM sys.tables AS [Tables]
JOIN sys.partitions AS [Partitions] ON [Tables].[object_id] = [Partitions].[object_id]
AND [Partitions].index_id IN (0,1)
-- WHERE [Tables].name = N'name of the table'
GROUP BY SCHEMA_NAME(schema_id), [Tables].name;