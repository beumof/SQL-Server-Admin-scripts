--File: Snippets/Snippet_CursorSnippets.sql
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-12-02

DECLARE cCursor CURSOR  
    FOR SELECT * FROM TableName

DECLARE @variable type;

OPEN cCursor  
FETCH NEXT FROM cCursor INTO @variable;  
WHILE @@FETCH_STATUS = 0  
BEGIN
	FETCH NEXT FROM cCursor INTO @variable;  
END   
CLOSE cCursor;  
DEALLOCATE cCursor;  