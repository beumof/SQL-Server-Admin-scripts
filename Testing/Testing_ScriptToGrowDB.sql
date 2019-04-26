--File: Testing/Testing_ScriptToGrowDB.sql
--Extracted from https://www.sqlskills.com/blogs/paul/why-you-should-not-shrink-your-data-files/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-04-26
--Commentaries: use it to make a DB grow for testing purposes.

SET NOCOUNT ON;
GO
 
-- Create the 10MB filler table at the 'front' of the data file
CREATE TABLE [FillerTable] (
    [c1] INT IDENTITY,
    [c2] CHAR (8000) DEFAULT 'filler');
GO
 
-- Fill up the filler table
INSERT INTO [FillerTable] DEFAULT VALUES;
GO 1280
 
-- Create the production table, which will be 'after' the filler table in the data file
CREATE TABLE [ProdTable] (
    [c1] INT IDENTITY,
    [c2] CHAR (8000) DEFAULT 'production');
CREATE CLUSTERED INDEX [prod_cl] ON [ProdTable] ([c1]);
GO
 
INSERT INTO [ProdTable] DEFAULT VALUES;
GO 1280