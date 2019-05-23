--File: Files/ReallocateDBFilessql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-23

-- This script will generate the commands to change the current drive (where @DBname dbfiles are allocated) for a new drive.
-- Later you will have to execute the generated scripts

DECLARE @P1 int;
DECLARE @sql nvarchar(250);

SET @sql=N'SELECT ''ALTER DATABASE [''+DB_NAME(database_id)+''] MODIFY FILE (NAME=''+name+'', FILENAME=''+@NewDrive+substring(physical_name,2,len(physical_name)-1)+'');''
      FROM sys.master_files
      WHERE DB_NAME(database_id)=@DBname';

EXEC sp_executesql @sql,N'@DBname nvarchar(128),@newDrive nvarchar(1)', N'<DBname>', N'<NewDrive>'; -- replace wiht dbname and newdrive letter 
