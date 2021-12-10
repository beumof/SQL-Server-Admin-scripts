--File: Performance/Performance_ActiveTrasactions.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-10-01

/* Este script obtiene las transacciones activas en el servidor e información sobre las mismas:
- Cuando comenzó la transacción
- La sesión y login de quién lo ejecuta, el hostname desde dónde llega la petición y la aplicación cliente desde dónde llega la petición
- La query/procedure que se ejecuta en la request actual de la transacción
- La cantidad (En MBs) de Log que está usando la transacción, como el numero de registros que lleva modificados.
- WARNING! En caso de transacciones "huerfanas" o de "irse al cafe" no aparecerán aquí, las transacciones abiertas pero sin nada en ejecución se ven en la tabla dm_tran_database_transactions pero no tienen registro asignado en la tabla dm_exec_requests (Estos casos de transacciones "de café" serían relevantes como causa de que el Log no se trunque con los backups o en casos de Bloqueos)
*/

select database_transaction_begin_time as BeginTime
	, r.session_id, s.login_name AS Login
	, text
	, DB_NAME(tr.database_id) as DatabaseName
	, s.HOST_NAME as HostName
	, s.program_name as ClientApp
	, tr.transaction_id
	, database_transaction_log_bytes_used/1024/1024 as TlogMBsUsed
	, database_transaction_log_bytes_reserved/1024/1024 as TlogMBsReserved
	, database_transaction_log_record_count
	, database_transaction_state
	, database_transaction_status
	, database_transaction_log_bytes_used_system
	, database_transaction_log_bytes_reserved_system
from sys.dm_tran_database_transactions tr
inner join sys.dm_exec_requests r on tr.transaction_id = r.transaction_id
inner join sys.dm_exec_sessions s on r.session_id = s.session_id
cross apply sys.dm_exec_sql_text(sql_handle)
where r.session_id != @@SPID -- to exclude our session from the results.
--AND database_transaction_log_bytes_used > 100*1024*1024 --To show transactions just bigger than 100 MB