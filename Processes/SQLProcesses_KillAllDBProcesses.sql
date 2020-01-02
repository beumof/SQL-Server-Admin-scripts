--File: Processes\SQLProcesses_KillAllDBProcesses.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-12-17
--Commentaries: Kill all processes related to a DB. Useful when locking other tasks. BEWARE.

DECLARE @dbname sysname
SET @dbname = '<DBNAME>'

DECLARE @spid int
SELECT @spid = MIN(spid) FROM master.dbo.sysprocesses WHERE dbid = DB_ID(@dbname)

WHILE @spid IS NOT NULL
BEGIN
  EXECUTE ('KILL ' + @spid)
  SELECT @spid = min(spid) FROM master.dbo.sysprocesses WHERE dbid = DB_ID(@dbname) AND spid > @spid
END