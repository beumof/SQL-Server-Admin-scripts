--File: Processes/SQLProcesses_BadSessions.sql
--Compilled in https://www.dbrnd.com/2017/02/sql-server-script-to-find-open-connections-and-cpu-usage-of-each-connected-client-programs/
--Added in 2019-06-26
--Commentaries: Check Client program open connections and CPU Stats.


SELECT
    convert(varchar(50), program_name) as ProgramName
    ,count(*) as TotalInstances
    ,sum(cpu) as CPUSum
    ,sum(datediff(second, login_time, getdate())) as SumOfSecond
    ,convert(float, sum(cpu)) / convert(float, sum(datediff(second, login_time, getdate()))) as PerformanceScore
    ,convert(float, sum(cpu)) / convert(float, sum(datediff(second, login_time, getdate()))) / count(*) as ProgramPerformance
FROM master..sysprocesses
WHERE spid > 50
GROUP BY
    convert(varchar(50), program_name)
ORDER BY PerformanceScore DESC
