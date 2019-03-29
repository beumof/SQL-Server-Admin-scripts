--REPAIR ALL DBS IN SUSPECT STATE
--REMEMBER TO CHECK THE RESULTS TO SEE IF THERE WAS DATA LOSS

declare @database as nvarchar(40)
declare @CMD as nvarchar(250)
 
declare suspect_dbs cursor for
select name from sys.databases where state_desc='SUSPECT'
 
open suspect_dbs
fetch next from suspect_dbs into @database
while @@FETCH_STATUS=0
begin  
set @CMD='ALTER DATABASE ['+@database+'] SET EMERGENCY'
print @CMD
exec sp_executesql @CMD
set @CMD='DBCC checkdb(['+@database+'])'
print @CMD
exec sp_executesql @CMD
SET @CMD='ALTER DATABASE ['+@database+'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
print @CMD
exec sp_executesql @CMD
SET @CMD='DBCC CheckDB (['+@database+'], REPAIR_ALLOW_DATA_LOSS)'
print @CMD
exec sp_executesql @CMD
SET @CMD='ALTER DATABASE ['+@database+'] SET MULTI_USER'
print @CMD
exec sp_executesql @CMD
fetch next from suspect_dbs into @database
end

close suspect_dbs
deallocate suspect_dbs