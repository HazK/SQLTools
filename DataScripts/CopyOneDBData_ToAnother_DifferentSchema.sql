USE Master

GO

/*

**** ENSURE BACKUP HAS BEEN TAKEN, ANY EXISTING DATA WILL BE DELETED ****

Update one database to another for mismatched schemas where the @DatabaseFrom is on an older version than @DatabaseTo

V0.1 Harrison Kirby	2017/03/16


User Variables

@DatabaseFrom = Database to take data from
@DatabaseTo = Database to insert data too **** ENSURE BACKUP HAS BEEN TAKEN, ANY EXISTING DATA WILL BE DELETED ****

*/

DECLARE @DatabaseFrom nvarchar(100)
DECLARE @DatabaseTo nvarchar(100)
DECLARE @DynaSQL nvarchar(1000)
DECLARE @NextTableTruncate nvarchar(100)
DECLARE @NextTableSchemaTruncate nvarchar(100)


/* USER PARAMETERS */
SET @DatabaseFrom = 'SodexoOMS_SIT'
SET @DatabaseTo = 'SodexoOMS_PVT'

-- Capture DatabaseFrom schema
IF OBJECT_ID('tempdb..##DatabaseFromSchema') is not null
DROP TABLE ##DatabaseFromSchema

SET @DynaSQL = '
SELECT
	*
INTO ##DatabaseFromSchema -- Global temp table for dyna sql
FROM
	'+@DatabaseFrom+'.INFORMATION_SCHEMA.COLUMNS'

EXEC sp_executesql @DynaSQL

-- Capture DatabaseTo Schema
IF OBJECT_ID('tempdb..##DatabaseToSchema') is not null
DROP TABLE ##DatabaseToSchema

SET @DynaSQL = '
SELECT
	*
INTO ##DatabaseToSchema -- Global temp table for dyna sql
FROM
	'+@DatabaseTo+'.INFORMATION_SCHEMA.COLUMNS'

EXEC sp_executesql @DynaSQL


-- Check for new tables and remove them

DELETE
FROM
	##DatabaseFromSchema
WHERE
	TABLE_NAME NOT IN (SELECT TABLE_NAME FROM ##DatabaseToSchema)

-- Check for new columns and remove them


DELETE
FROM
	##DatabaseFromSchema
WHERE
	TABLE_NAME in (

	SELECT
		DS.TABLE_NAME
	FROM
		##DatabaseFromSchema DS
		LEFT JOIN ##DatabaseToSchema DF on DS.Table_Name = DF.Table_Name AND DS.Column_Name = DF.Column_Name
	WHERE
		DF.COLUMN_NAME IS NULL
		)
	AND
	
	COLUMN_NAME in(

	SELECT
		DS.COLUMN_NAME
	FROM
		##DatabaseFromSchema DS
		LEFT JOIN ##DatabaseToSchema DF on DS.Table_Name = DF.Table_Name AND DS.Column_Name = DF.Column_Name
	WHERE
		DF.COLUMN_NAME IS NULL
	)

-- Same again for DatabaseTo
DELETE
FROM
	##databasetoSchema
WHERE
	TABLE_NAME NOT IN (SELECT TABLE_NAME FROM ##DatabaseToSchema)

-- Check for new columns and remove them


DELETE
FROM
	##databasetoSchema
WHERE
	TABLE_NAME in (

	SELECT
		DS.TABLE_NAME
	FROM
		##databasetoSchema DS
		LEFT JOIN ##DatabaseToSchema DF on DS.Table_Name = DF.Table_Name AND DS.Column_Name = DF.Column_Name
	WHERE
		DF.COLUMN_NAME IS NULL
		)
	AND
	
	COLUMN_NAME in(

	SELECT
		DS.COLUMN_NAME
	FROM
		##databasetoSchema DS
		LEFT JOIN ##DatabaseToSchema DF on DS.Table_Name = DF.Table_Name AND DS.Column_Name = DF.Column_Name
	WHERE
		DF.COLUMN_NAME IS NULL
	)

-- Disable all FKeys

-- Disable all fkeys 

DECLARE CURSOR123 CURSOR FAST_FORWARD READ_ONLY
FOR
	SELECT DISTINCT
		TABLE_NAME,
		TABLE_SCHEMA
	FROM
		##DatabaseToSchema

OPEN CURSOR123
FETCH NEXT FROM CURSOR123 INTO @NextTableTruncate,@NextTableSchemaTruncate
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @DynaSQL = ('ALTER TABLE ' + @DatabaseTo +'.'+ @NextTableSchemaTruncate +'.' +@NextTableTruncate +' NOCHECK CONSTRAINT ALL')
	SELECT @DynaSQL
	EXEC sp_executesql @DynaSQL
FETCH NEXT FROM CURSOR123 INTO @NextTableTruncate, @NextTableSchemaTruncate
END

CLOSE CURSOR123
DEALLOCATE CURSOR123

-- Truncate all tables in DatabaseToSchema

DECLARE CURSOR123 CURSOR FAST_FORWARD READ_ONLY
FOR
	SELECT DISTINCT
		TABLE_NAME,
		TABLE_SCHEMA
	FROM
		##DatabaseToSchema

OPEN CURSOR123
FETCH NEXT FROM CURSOR123 INTO @NextTableTruncate,@NextTableSchemaTruncate
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @DynaSQL = ('TRUNCATE TABLE ' + @DatabaseTo +'.'+ @NextTableSchemaTruncate +'.' +@NextTableTruncate)
	EXEC sp_executesql @DynaSQL
FETCH NEXT FROM CURSOR123 INTO @NextTableTruncate, @NextTableSchemaTruncate
END

CLOSE CURSOR123
DEALLOCATE CURSOR123

