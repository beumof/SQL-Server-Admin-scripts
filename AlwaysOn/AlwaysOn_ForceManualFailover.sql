--File: AlwaysOn\AlwaysOn_ForceManualFailover.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2022-06-24

ALTER AVAILABILITY GROUP AGTest FORCE_FAILOVER_ALLOW_DATA_LOSS;

--In this case we had to previousle bring the cluster up without QUORUM to make it work!