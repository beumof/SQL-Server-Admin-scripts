--File: Processes/SQLProcesses_BadSessions.sql
--Compilled in https://www.dbrnd.com/2017/02/sql-server-script-to-find-bad-sessions-or-processes-block-transaction-waiting-session/
--Added in 2019-06-26
--Commentaries: Check worst performance connections

SELECT TOP 25
	spid
	,blocked
	,convert(varchar(10),db_name(dbid)) as DBName
	,cpu
	,datediff(second,login_time, getdate()) as Secs
	,convert(float, cpu / datediff(second,login_time, getdate())) as PScore
	,convert(varchar(16), hostname) as Host
	,convert(varchar(50), program_name) as Program
	,convert(varchar(20), loginame) as Login
FROM master..sysprocesses
WHERE datediff(second,login_time, getdate()) > 0 and spid > 50
ORDER BY pscore desc
