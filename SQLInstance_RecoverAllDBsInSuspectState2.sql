DECLARE @P1 int, @P2 int, @P3 int, @P4 int, @P5 int;
DECLARE @database AS nvarchar(40)

EXEC sp_prepare @P1 output,N'@database nvarchar(40)',N'ALTER DATABASE [@database] SET EMERGENCY';
EXEC sp_prepare @P2 output,N'@database nvarchar(40)',N'DBCC CHECKDB([@database])';
EXEC sp_prepare @P3 output,N'@database nvarchar(40)',N'ALTER DATABASE [@database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE';
EXEC sp_prepare @P4 output,N'@database nvarchar(40)',N'DBCC CHECKDB ([@database], REPAIR_ALLOW_DATA_LOSS)';
EXEC sp_prepare @P5 output,N'@database nvarchar(40)',N'ALTER DATABASE [@database] SET MULTI_USER';

DECLARE suspect_dbs CURSOR FOR
SELECT name FROM sys.databases WHERE state_desc='SUSPECT'

OPEN suspect_dbs
FETCH NEXT FROM suspect_dbs INTO @database
PRINT 'Databases in suspect status: '+CAST(@@CURSOR_ROWS AS varchar(100))

WHILE @@FETCH_STATUS=0
BEGIN
  PRINT 'Fixing database: '+@database
  EXEC sp_execute @P1, N'database', @database;
  EXEC sp_execute @P2, N'database', @database;
  EXEC sp_execute @P3, N'database', @database;
  EXEC sp_execute @P4, N'database', @database;
  EXEC sp_execute @P5, N'database', @database;
FETCH NEXT FROM suspect_dbs INTO @database
END

CLOSE suspect_dbs
DEALLOCATE suspect_dbs

EXEC sp_unprepare @P1;
EXEC sp_unprepare @P2;
EXEC sp_unprepare @P3;
EXEC sp_unprepare @P4;
EXEC sp_unprepare @P5;
