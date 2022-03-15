
DECLARE @DatabaseLooping TABLE
(DatabaseName nvarchar(200),
Processed BIT)

DECLARE @DBAMonitor_CheckDBResults TABLE 
	(ParentObject nvarchar(100),
	[Object] nvarchar(100),
	Field nvarchar(100),
	VALUE nvarchar(200))

DECLARE @DBAMonitor_CheckDBResults_2 TABLE 
	(
	InstanceName nvarchar(100),
	DatabaseName nvarchar(200),
	VALUE nvarchar(200))

DECLARE @SQL nvarchar(1000)
DECLARE @DatabaseLoopingDB nvarchar(200)

INSERT INTO @DatabaseLooping
SELECT
	Name,
	0
FROM
	sys.databases
WHERE
	state_Desc = 'ONLINE'


WHILE EXISTS (SELECT 1 FROM @DatabaseLooping WHERE Processed = 0)
BEGIN
	SET @DatabaseLoopingDB = (SELECT TOP 1 DatabaseName FROM @DatabaseLooping WHERE Processed = 0)
	SET @SQL = 'DBCC PAGE (' + @DatabaseLoopingDB + ',1,9,3) WITH TABLERESULTS'

	--SELECT @SQL
	INSERT INTO @DBAMonitor_CheckDBResults
	EXEC sp_executesql @SQL

	INSERT INTO @DBAMonitor_CheckDBResults_2
	SELECT
		@@SERVERNAME,
		@DatabaseLoopingDB,
		VALUE
	FROM
		@DBAMonitor_CheckDBResults
	WHERE 
		Field = 'dbi_dbccLastKnownGood'

	UPDATE
		@DatabaseLooping
	SET
		Processed = 1
	WHERE 
		DatabaseName = @DatabaseLoopingDB

	DELETE FROM @DBAMonitor_CheckDBResults

END

SELECT * FROM @DBAMonitor_CheckDBResults_2
