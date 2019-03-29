--Using Extended Events to find deadlocks (from SQL Server 2012)
SELECT
XEvent.value('(@timestamp)[1]', 'datetime') as UTC_event_time,
XEvent.query('(data/value/deadlock)') AS deadlock_graph
FROM
(
SELECT CAST(event_data AS XML) as [target_data]
FROM sys.fn_xe_file_target_read_file('system_health_*.xel',NULL,NULL,NULL)
WHERE object_name like 'xml_deadlock_report'
) AS [x]
CROSS APPLY target_data.nodes('/event') AS XEventData(XEvent)