--File: Users/Users_UserPermissionInDB.sql
--Inspired from: https://dba.stackexchange.com/questions/81595/a-query-that-lists-all-mapped-users-for-a-given-login
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-08-30

 WITH    perms_cte as
(
        select USER_NAME(p.grantee_principal_id) AS principal_name,
                dp.principal_id,
                dp.type_desc AS principal_type_desc,
                p.class_desc,
                OBJECT_NAME(p.major_id) AS object_name,
                p.permission_name,
                p.state_desc AS permission_state_desc
        from    sys.database_permissions p
        inner   JOIN sys.database_principals dp
        on     p.grantee_principal_id = dp.principal_id
)
--role members
SELECT rm.member_principal_name, rm.principal_type_desc, p.class_desc, 
    p.object_name, p.permission_name, p.permission_state_desc,rm.role_name
FROM    perms_cte p
right outer JOIN (
    select role_principal_id, dp.type_desc as principal_type_desc, 
   member_principal_id,user_name(member_principal_id) as member_principal_name,
   user_name(role_principal_id) as role_name--,*
    from    sys.database_role_members rm
    INNER   JOIN sys.database_principals dp
    ON     rm.member_principal_id = dp.principal_id
) rm
ON     rm.role_principal_id = p.principal_id
where member_principal_name like '%' --specify the user to search for
order by 1