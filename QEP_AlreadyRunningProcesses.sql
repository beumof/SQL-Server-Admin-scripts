--SQL Server active processes (including query plan)
SELECT 
r.session_id
,st.TEXT AS batch_text
,SUBSTRING(st.TEXT, statement_start_offset / 2 + 1, (
  (
  CASE 
  WHEN r.statement_end_offset = - 1
  THEN (LEN(CONVERT(NVARCHAR(max), st.TEXT)) * 2)
  ELSE r.statement_end_offset
  END
  ) - r.statement_start_offset
) / 2 + 1) AS statement_text
,qp.query_plan AS 'XML Plan'
,r.*
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
ORDER BY cpu_time DESC