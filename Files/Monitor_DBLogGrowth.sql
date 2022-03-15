USE DBADATA

IF OBJECT_ID('dbadata.dbo.MonitorLogGrowth') IS NULL
CREATE TABLE dbadata.dbo.MonitorLogGrowth 
(DatabaseName nvarchar(50),
LogSizeMB float,
LogSpaceUsedPercent float,
Status1 nvarchar(50),
LoggedDate datetime)


DECLARE @DBALogGrowth TABLE
(DatabaseName nvarchar(50),
LogSizeMB float,
LogSpaceUsedPercent float,
Status1 nvarchar(50))

DECLARE @Sql nvarchar(1000)

SET @Sql = 'DBCC SQLPERF(LOGSPACE)'
INSERT INTO @DBALogGrowth
exec sp_executesql @Sql


INSERT INTO dbadata.dbo.MonitorLogGrowth
SELECT
	*,
	GETDATE()
FROM @DBALogGrowth

DELETE FROM dbadata.dbo.MonitorLogGrowth WHERE LoggedDate < GETDATE() - 30