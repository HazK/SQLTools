


DECLARE @TempStore TABLE
(DatabaseName nvarchar(100),
Processed bit)
DECLARE @DatabaseName nvarchar(100)
DECLARE @DestinationWithFileName nvarchar(300)
DECLARE @DestinationPath nvarchar (300)

SET @DestinationPath = 'I:\Backups_Harrison_DoNotDelete\'

INSERT INTO @TempStore
SELECT 
	name,
	0
FROM 
	sys.databases 
WHERE
	database_id > 4

WHILE EXISTS (SELECT 1 FROM @TempStore WHERE Processed = 0)

BEGIN

	PRINT 'Starting backup up for ' + @DatabaseName + ' at ' + CONVERT(nvarchar,(GETDATE()))
	SET @DatabaseName = (SELECT TOP 1 DatabaseName FROM @TempStore WHERE Processed = 0)
	SET @DestinationWithFileName = @DestinationPath + @DatabaseName + '_' + '(YYMMDD)' + CONVERT(nvarchar,GETDATE(),12) + '_(HHMMSS)' + LEFT(REPLACE(CONVERT(nvarchar,GETDATE(),114),':',''),6)  + '.bak'
	BACKUP DATABASE @DatabaseName
	TO DISK = @DestinationWithFileName
	WITH COPY_ONLY, STATS
	PRINT 'Backup Complete for ' + @DatabaseName + ' at ' + CONVERT(nvarchar,(GETDATE()))
	
	UPDATE @TempStore
	SET Processed = 1
	WHERE DatabaseName = @DatabaseName

END

