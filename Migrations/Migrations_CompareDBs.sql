--File: Migrations_CompareDBs.sql
--Extracted from: Unknown (updated with info from MS SQL official web.
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2019-05-02


--USE [DB] --Used for automatizations

SELECT 
	'Count' = COUNT(*)
	, 'Type' = CASE type 
		WHEN 'AF' THEN 'Aggregate function (CLR)'
		WHEN 'C' THEN 'CHECK constraint'
		WHEN 'D' THEN 'Default or DEFAULT constraint'
		WHEN 'F' THEN 'FOREIGN KEY constraint'
		WHEN 'FN' THEN 'Scalar function'
		WHEN 'FS' THEN 'Assembly (CLR) scalar-function'
		WHEN 'FT' THEN 'Assembly (CLR) table-valued function'
		WHEN 'IF' THEN 'In-lined table-function'
		WHEN 'IT' THEN 'Internal table'
		WHEN 'K' THEN 'PRIMARY KEY or UNIQUE constraints'
		WHEN 'L' THEN 'Log'
		WHEN 'P' THEN 'Stored procedure'
		WHEN 'PC' THEN 'Assembly (CLR) stored-procedure'
		WHEN 'PK' THEN 'PRIMARY KEY constraint (type is K)'
		WHEN 'R' THEN 'Rule'
		WHEN 'RF' THEN 'Replication filter stored procedure'
		WHEN 'S' THEN 'System table'
		WHEN 'SN' THEN 'Synonym'
		WHEN 'SQ' THEN 'Service queue'
		WHEN 'TA' THEN 'Assembly (CLR) DML trigger'
		WHEN 'TF' THEN 'Table function'
		WHEN 'TR' THEN 'SQL DML Trigger'
		WHEN 'TT' THEN 'Table type'
		WHEN 'U' THEN 'User table'
		WHEN 'UQ' THEN 'UNIQUE constraint (type is K)'
		WHEN 'V' THEN 'View'
		WHEN 'X' THEN 'Extended stored procedure'
		ELSE TYPE
    END 
    , GETDATE() as 'Date'
    FROM sysobjects 
    GROUP BY type 
    ORDER BY type 
GO