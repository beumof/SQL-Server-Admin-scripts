--File: Performance/Performance_FindLargeTransactions.sql
--Extracted from https://techcommunity.microsoft.com/t5/sql-server-support/finding-large-transactions-that-bloat-your-transaction-log/ba-p/333999
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-01-20

set nocount on
go
declare @datetime datetime
select @datetime = GETDATE()
select @datetime logtime, text, tr.database_id, tr.transaction_id, database_transaction_log_bytes_used, database_transaction_log_bytes_reserved,
database_transaction_log_record_count, database_transaction_state, database_transaction_status,
database_transaction_log_bytes_used_system, database_transaction_log_bytes_reserved_system
from sys.dm_tran_database_transactions  tr
inner join sys.dm_exec_requests r
on tr.transaction_id = r.transaction_id
cross apply sys.dm_exec_sql_text(sql_handle)
where database_transaction_log_bytes_used >  100*1024*1024  -- 100 MB