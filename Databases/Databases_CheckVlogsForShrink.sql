--File: Databases/Databases_CheckVlogsForShrink.sql
--Inspired in https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-log-info-transact-sql?view=sql-server-ver15
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-11-24

;WITH cte_vlf AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY s.database_id ORDER BY vlf_begin_offset) AS vlfid
		, DB_NAME(s.database_id) AS [Database Name]
		, vlf_sequence_number
		, vlf_active
		, vlf_begin_offset
		, vlf_size_mb
	FROM sys.databases s
	CROSS APPLY sys.dm_db_log_info(s.database_id) l
	--WHERE DB_NAME(s.database_id) IN ('CHRXS1DBREPOSITORY','BlackBox')
),cte_vlf_cnt AS (
	SELECT [Database Name]
		, COUNT(vlf_sequence_number) AS vlf_count
		, SUM(IIF(vlf_active=0,1,0)) AS vlf_count_inactive
		, SUM(IIF(vlf_active=1,1,0)) AS vlf_count_active
		, MIN(IIF(vlf_active=1,vlfid,NULL)) AS ordinal_min_vlf_active
		, MIN(IIF(vlf_active=1,vlf_sequence_number,NULL)) AS min_vlf_active
		, MAX(IIF(vlf_active=1,vlfid,NULL)) AS ordinal_max_vlf_active
		, MAX(IIF(vlf_active=1,vlf_sequence_number,NULL)) AS max_vlf_active
	FROM cte_vlf cv
	GROUP BY [Database Name]
) --SELECT * FROM cte_vlf_cnt
SELECT [Database Name]
	, vlf_count
	, min_vlf_active
	, ordinal_min_vlf_active
	, max_vlf_active
	, ordinal_max_vlf_active
	, FORMAT((ordinal_min_vlf_active-1)*1.0/vlf_count,'P2') AS free_log_pct_before_active_log
	, FORMAT((ordinal_max_vlf_active-(ordinal_min_vlf_active-1))*1.0/vlf_count,'P2') AS active_log_pct
	, FORMAT((vlf_count-ordinal_max_vlf_active)*1.0/vlf_count,'P2') AS free_log_pct_after_active_log
	, ((vlf_count-ordinal_max_vlf_active)*100.00/vlf_count)
FROM cte_vlf_cnt