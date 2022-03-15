
USE dbadata

IF OBJECT_ID('dba_CheckDBExec') IS NOT NULL
DROP PROC dba_CheckDBExec

GO

CREATE PROC dba_CheckDBExec (@DatabaseList nvarchar(max),@PHYSICAL_ONLY bit)

AS

BEGIN
	
/* HK Custom CheckDB Script V1

@DatabaseList = List of dbs to be checked. If NULL Will do all online databases
@PHYSICAL_ONLY = Will only do a physical check for speed

*/

	SET NOCOUNT ON

	/* DECLARE Stuff */

	DECLARE @DatabaseProcessList TABLE
	(DatabaseName nvarchar(200),
	Processed bit)

	DECLARE @DatabaseInclude TABLE
	(DatabaseName nvarchar(200))

	DECLARE @StartPos int
	DECLARE @Length int
	DECLARE @Counter int
	DECLARE @TSQLString nvarchar(4000)
	DECLARE @DatabaseName nvarchar(300)
	
	-- Extract database exclude list	
	IF @DatabaseList IS NOT NULL
	BEGIN
		SET @DatabaseList = @DatabaseList + ','
		SET @StartPos = 0
		SET @Counter = 0
		WHILE  CHARINDEX(',',@DatabaseList,@StartPos +1) > 0
			BEGIN
				SET @Length = CHARINDEX(',',@DatabaseList,@StartPos + 1) - @StartPos
				
				INSERT INTO @DatabaseInclude
				SELECT
					REPLACE(REPLACE(RTRIM(LTRIM(REPLACE(SUBSTRING(@DatabaseList, @StartPos,@Length),',',''))),'[',''),']','')	
				
				SET @StartPos = CHARINDEX(',',@DatabaseList,@StartPos + 1)
			END
	
	
	INSERT INTO @DatabaseProcessList
		SELECT
			sys.databases.name,
			0 As Processed
		FROM
			sys.databases
				INNER JOIN @DatabaseInclude de on sys.databases.name = de.DatabaseName
	END
	ELSE
	BEGIN 
		INSERT INTO @DatabaseProcessList
		SELECT
			sys.databases.name,
			0 As Processed
		FROM
			sys.databases
		WHERE
			state_desc = 'ONLINE'
	END
-- Now we have our database list do our CheckDB

	WHILE EXISTS (SELECT 1 FROM @DatabaseProcessList WHERE Processed = 0)
		BEGIN
			SET @DatabaseName = (SELECT TOP 1 DatabaseName FROM @DatabaseProcessList WHERE Processed = 0)
			IF @PHYSICAL_ONLY = 1
			BEGIN
			SET @TSQLSTRING = 'USE ' + '[' + @DatabaseName + ']' + '
				DBCC CHECKDB WITH PHYSICAL_ONLY, NO_INFOMSGS'
			EXEC sp_ExecuteSQL @TSQLString
			END
			ELSE
			BEGIN
			SET @TSQLSTRING = 'USE ' + '[' + @DatabaseName + ']' + '
				DBCC CHECKDB WITH NO_INFOMSGS'
			EXEC sp_ExecuteSQL @TSQLString
			END

			UPDATE @DatabaseProcessList
			SET Processed = 1
			WHERE DatabaseName = @DatabaseName
	END

END
