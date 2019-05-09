--File: Users\CheckObjestsOwnerships.sql
--Extracted from https://dba.stackexchange.com/questions/33551/can-i-retrieve-all-database-objects-owned-by-a-particular-userthe-database-size-and-improve-performance-in-sql-server/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-09

;with objects_cte as
(
    select
        o.name,
        o.type_desc,
        case
            when o.principal_id is null then s.principal_id
            else o.principal_id
        end as principal_id
    from sys.objects o
    on o.schema_id = s.schema_id
    where o.is_ms_shipped = 0
    and o.type in ('U', 'FN', 'FS', 'FT', 'IF', 'P', 'PC', 'TA', 'TF', 'TR', 'V')
)
select
    cte.name,
    cte.type_desc,
    dp.name
from objects_cte cte
inner join sys.database_principals dp
on cte.principal_id = dp.principal_id
--where dp.name = 'YourUser'; --Uncomment to filter by owner

