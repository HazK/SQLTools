
USE MASTER
DECLARE @Name nvarchar(100)
DECLARE @SQL nvarchar(1000)

SELECT *
INTO
dbadata.dbo.TempTableResults
FROM 
sys.Database_Files

TRUNCATE TABLE dbadata.dbo.TempTableResults

DECLARE crs1 Cursor READ_ONLY 
FOR
SELECT
	Name
FROM
	sys.databases
WHERE State_Desc = 'ONLINE'

OPEN crs1
FETCH NEXT FROM crs1 INTO @Name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = 'USE [' + @Name + '] SELECT * FROM sys.Database_Files'


INSERT INTO dbadata.dbo.TempTableResults
EXEC sp_executesql @SQL
--SELECT @SQL

FETCH NEXT FROM crs1 INTO @NAME

END

CLOSE crs1
DEALLOCATE Crs1

SELECT * FROM dbadata.dbo.TempTableResults
DROP TABLE dbadata.dbo.TempTableResults