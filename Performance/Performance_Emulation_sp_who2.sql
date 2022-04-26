--File: Performance/Performance_Emulation_sp_who2.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-10-01


CREATE TABLE #sp_who2 (SPID INT,Status VARCHAR(255),
      Login  VARCHAR(255),HostName  VARCHAR(255), 
      BlkBy  VARCHAR(255),DBName  VARCHAR(255), 
      Command VARCHAR(255),CPUTime INT, 
      DiskIO INT,LastBatch VARCHAR(255), 
      ProgramName VARCHAR(255),SPID2 INT, 
      REQUESTID INT) 

INSERT INTO #sp_who2 EXEC sp_who2

SELECT * 
FROM #sp_who2
WHERE 1=1
--AND DBName NOT IN ('master','msdb','model','tempdb')
--AND SPID<>@@SPID --To exclude current connection
ORDER BY SPID ASC

DROP TABLE #sp_who2