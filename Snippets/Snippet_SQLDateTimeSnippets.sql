--File: Snippets/Snippet_SQLDateTimeSnippets.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-01-27

-- Get Date_Time formated. IE: 20210127_102157
SELECT CONVERT(VARCHAR(20),GETDATE(),112) + '_' + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')

-- To generate job log with _<DATE>_<TIME> suffix
<PATH>\<LOGNAME>_$(ESCAPE_NONE(STRTDT))-$(ESCAPE_NONE(STRTTM)).log