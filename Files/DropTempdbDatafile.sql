--File: Files/DropTempdbDatafile.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-22
--Commentaries: remove datafiles from tempdb
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-23

-- We will have to shrink the datafile and then remove it.

-- Datafile shrink before being able to remove it
USE tempdb;
DBCC SHRINKFILE ('<tempdbfile>', emptyfile);

-- Remove tempdb datafile
USE master;
ALTER DATABASE tempdb REMOVE FILE <tempdbfile>
