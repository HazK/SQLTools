USE DBADATA

GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'sp_DBAMonitor_CheckDBLogs_Central')
DROP PROC sp_DBAMonitor_CheckDBLogs_Central

GO

CREATE PROC sp_DBAMonitor_CheckDBLogs_Central

AS

BEGIN

DECLARE @sql nvarchar(max)
DECLARE @OpenQuery varchar(max)
DECLARE @NextServer nvarchar(200)
DECLARE @Close nvarchar(10)
DECLARE @ErrorMessage nvarchar(400)

DECLARE @ProcessTable TABLE
(Instance nvarchar(200),
Complete bit)	
TRUNCATE TABLE [dbo].[DBAMonitor_CheckDBLogLastRunTime]
TRUNCATE TABLE DBAMonitor_CheckDBLogResults_Central


INSERT INTO @ProcessTable
SELECT 
	InstanceName,
	0 
FROM 
	dbadata.dbo.DBAMonitor_SupportedServers
WHERE
	[CheckDB] = 1

WHILE EXISTS (SELECT 1 FROM @ProcessTable WHERE Complete = 0)
	BEGIN
	SET @Close = ''')'
	SET @NextServer = (SELECT TOP 1 '[' + Instance + ']' FROM @ProcessTable WHERE Complete = 0)
	SET @OpenQuery = 'SELECT * FROM OPENQUERY('+ @NextServer + ',''SET FMTONLY OFF'

	SET @sql = 

	'
		BEGIN
			SELECT @@SERVERNAME,
				  ''''Tim'''' + ''''Dave'''' AS  DatabaseName1,
				  NULL LogDate,
				  NULL LogText,
				  GETDATE() MonitorRunDate,
				  0 ProcInstalled
		END
'

SELECT @sql
	INSERT INTO DBAMonitor_CheckDBLogResults_Central
	EXEC (@OPENQUERY + @sql + @Close)
	UPDATE @ProcessTable SET Complete = 1 WHERE  '[' + Instance + ']' = @NextServer

	
	END


INSERT INTO [dbo].[DBAMonitor_CheckDBLogLastRunTime] SELECT GETDATE()

END

SELECT * FROM DBAMonitor_CheckDBLogResults_Central