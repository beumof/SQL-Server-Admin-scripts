--File: Users\Users_AuditConnections
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2022-01-26

-- Use Extended Events to trak to disk all the connections to a SQL instance.

CREATE EVENT SESSION [DB_Usage] ON SERVER
ADD EVENT sqlserver.sql_statement_completed(
ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.sql_text,sqlserver.username)
--WHERE ([sqlserver].[username] NOT IN ('<USERNAME>') --Uncomment to exclude users
ADD TARGET package0.event_file(SET filename=N'<PATH>\CHeckConnections.xel',metadatafile=N'<PATH>\CHeckConnections.xem')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO