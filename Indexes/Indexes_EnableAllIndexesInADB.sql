--File: Indexes/Indexes_EnableAllIndexesInADB.sql
--Extracted from https://stackoverflow.com/questions/18236055/disable-and-re-enable-all-indexes-in-a-sql-server-database
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-08-25

DECLARE @cmd NVARCHAR(400);

DECLARE cur_rebuild CURSOR FOR 
   SELECT 'ALTER INDEX ' +  i.name + ' ON ' + SCHEMA_NAME(t.schema_id) + '.' + t.name + ' REBUILD' 
   FROM sys.indexes i 
   JOIN sys.tables t ON i.object_id = t.object_id 
   WHERE i.is_disabled = 1 
   ORDER BY t.name, i.name;

OPEN cur_rebuild;

FETCH NEXT FROM cur_rebuild INTO @cmd;
WHILE @@FETCH_STATUS = 0
   BEGIN
      EXECUTE sp_executesql  @cmd;
      FETCH NEXT FROM cur_rebuild INTO @cmd;
   END;

CLOSE cur_rebuild;
DEALLOCATE cur_rebuild;
GO