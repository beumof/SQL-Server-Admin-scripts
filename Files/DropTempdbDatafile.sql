--File: Files/DropTempdbDatafile.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-23
--Commentaries: remove datafiles from tempdb


-- We will have to empty the datafile and then remove it.

-- Datafile shrink before being able to remove it
USE tempdb;
DBCC SHRINKFILE ('<tempdbfile>', emptyfile);

-- Remove tempdb datafile
USE master;
ALTER DATABASE tempdb REMOVE FILE <tempdbfile>
