
USE dbaData

IF OBJECT_ID('sp_dba_MonitorDBGrowthDiskSpace') IS NOT NULL
DROP PROC sp_dba_MonitorDBGrowthDiskSpace

GO

CREATE PROC sp_dba_MonitorDBGrowthDiskSpace

AS

BEGIN

	IF OBJECT_ID('dbo.dba_MonitorDBGrowthDiskSpace_DBSize') IS NULL
	CREATE TABLE dbo.dba_MonitorDBGrowthDiskSpace_DBSize
	(DatabaseName nvarchar(200),
	DatabaseSize float,
	LogSize float,
	LoggedDate datetime)

	IF OBJECT_ID('dbo.dba_MonitorDBGrowthDiskSpace_DiskSpace') IS NULL
	CREATE TABLE dbo.dba_MonitorDBGrowthDiskSpace_DiskSpace
	(DiskDrive nvarchar(200),
	SpaceFree float,
	LoggedDate datetime)

	DECLARE @cteDatabaseFileSize TABLE
	(Database_ID int,
	Name nvarchar(100),
	SizeMB Float)

	DECLARE @cteLogFileSize TABLE
	(Database_ID int,
	Name nvarchar(100),
	SizeMB Float)

	DECLARE @cteDriveSpace TABLE
	(Drive nvarchar(10),
	FreeSpace float)

	
	INSERT INTO @cteDatabaseFileSize
	SELECT
		sys.Databases.Database_ID,
		sys.Databases.Name,
		SUM(Size) * 8.0 / 1024 SizeMB
	FROM
		sys.master_files
			INNER JOIN sys.databases ON sys.master_files.Database_ID = sys.databases.Database_ID
	WHERE
		[Type] = 0
	GROUP BY
		sys.Databases.Database_ID,
		sys.Databases.Name

	INSERT INTO @cteLogFileSize
	SELECT
		sys.Databases.Database_ID,
		sys.Databases.Name,
		SUM(Size) * 8.0 / 1024 SizeMB
	FROM
		sys.master_files
			INNER JOIN sys.databases ON sys.master_files.Database_ID = sys.databases.Database_ID
	WHERE
		[Type] = 0
	GROUP BY
		sys.Databases.Database_ID,
		sys.Databases.Name


	INSERT INTO dbo.dba_MonitorDBGrowthDiskSpace_DBSize
	SELECT
		cteDatabaseFileSize.Name,
		cteDatabaseFileSize.SizeMB as DatabaseSize,
		cteLogFileSize.SizeMB As LogSize,
		GETDATE() AS LoggedDate
	FROM
		@cteDatabaseFileSize AS cteDatabaseFileSize
			INNER JOIN @cteLogFileSize AS cteLogFileSize on cteDatabaseFileSize.Database_ID = cteLogFIleSize.Database_ID

	INSERT INTO @cteDriveSpace
	EXEC master.sys.xp_fixeddrives

	INSERT INTO dbo.dba_MonitorDBGrowthDiskSpace_DiskSpace
	SELECT
		Drive,
		FreeSpace,
		GETDATE()
	FROM
		@cteDriveSpace


END
