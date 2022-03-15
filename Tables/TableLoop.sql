DECLARE @Table nvarchar(100)
DECLARE @DYNASQL nvarchar(500)

DECLARE @RecordTable TABLE
(TableName nvarchar(50),
Count1 int)

DECLARE crs1 CURSOR READ_ONLY
FOR
SELECT NAME FROM [Central_DWH_HKTEMP].sys.tables ORDER BY NAme ASC

OPEN crs1
FETCH NEXT FROM crs1 INTO @TABLE

WHILE @@FETCH_STATUS = 0

BEGIN

SET @DYNASQL = ('SELECT ' + '''' + @Table + '''' + ',COUNT(*) FROM ' + @Table)

INSERT INTO @RecordTable
exec sp_Executesql @DYNASQL

FETCH NEXT FROM crs1 INTO @TABLE

END

CLOSE crs1
DEALLOCATE crs1

SELECT * FROM @RecordTable