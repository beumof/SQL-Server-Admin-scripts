--File: AlwaysOn\AlwaysOn_FailoverHitory.sql
--Extracted from https://dba.stackexchange.com/questions/76016/how-to-check-history-of-primary-node-in-an-availability-group
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2022-03-14

declare @xel_path varchar(1024);
declare @utc_adjustment int = datediff(hour, getutcdate(), getdate());

-------------------------------------------------------------------------------
------------------- target event_file path retrieval --------------------------
-------------------------------------------------------------------------------
;with target_data_cte as
(
    select  
        target_data = 
            convert(xml, target_data)
    from sys.dm_xe_sessions s
    inner join sys.dm_xe_session_targets st
    on s.address = st.event_session_address
    where s.name = 'alwayson_health'
    and st.target_name = 'event_file'
),
full_path_cte as
(
    select
        full_path = 
            target_data.value('(EventFileTarget/File/@name)[1]', 'varchar(1024)')
    from target_data_cte
)
select
    @xel_path = 
        left(full_path, len(full_path) - charindex('\', reverse(full_path))) + 
        '\AlwaysOn_health*.xel'
from full_path_cte;

-------------------------------------------------------------------------------
------------------- replica state change events -------------------------------
-------------------------------------------------------------------------------
;with state_change_data as
(
    select
        object_name,
        event_data = 
            convert(xml, event_data)
    from sys.fn_xe_file_target_read_file(@xel_path, null, null, null)
)
select
    object_name,
    event_timestamp = 
        dateadd(hour, @utc_adjustment, event_data.value('(event/@timestamp)[1]', 'datetime')),
    ag_name = 
        event_data.value('(event/data[@name = "availability_group_name"]/value)[1]', 'varchar(64)'),
    previous_state = 
        event_data.value('(event/data[@name = "previous_state"]/text)[1]', 'varchar(64)'),
    current_state = 
        event_data.value('(event/data[@name = "current_state"]/text)[1]', 'varchar(64)')
from state_change_data
where object_name = 'availability_replica_state_change'
order by event_timestamp desc;
