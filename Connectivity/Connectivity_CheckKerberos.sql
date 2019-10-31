-- File: Connectivity_CheckKerberos.sql
-- Extracted from "Unkown"
-- Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
-- Added in 2019-10-31

-- To check if your connections are using KERBEROS (check from a remote host)
-- SPNs should be configured for the service account that runs the SQL services & Delegation also configured

SELECT auth_scheme, net_transport, session_id
FROM sys.dm_exec_connections
WHERE session_id = @@SPID

/* Correct configuration output
auth_scheme		net_transport	session_id
KERBEROS		TCP				60			<-- Executed from a remote server
NTLM			Shared memory	64			<-- Executed from the same server
*/