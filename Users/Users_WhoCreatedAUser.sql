--File: Users\Users_WhoCreatedAUser.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-01-21

--Find who created a user/login
--This will only work if the info's still logged on the SQL default traces. 
--SQL does not register this info by default.

SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime ,
        t.RoleName ,
        t.TargetUserName ,
        t.TargetLoginName ,
        t.SessionLoginName
FROM sys.fn_trace_gettable(CONVERT(VARCHAR(150), (SELECT TOP 1 f.[value] FROM sys.fn_trace_getinfo(NULL) f WHERE f.property = 2)), DEFAULT) T
JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ('Audit Addlogin Event', 'Audit Add DB User Event','Audit Add Member to DB Role Event')
AND v.subclass_name IN ( 'add', 'Grant database access' )