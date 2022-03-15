USE [dbadata]
GO
/****** Object:  StoredProcedure [dbo].[sp_MonitorTempDbSize]    Script Date: 23/09/2015 17:07:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROC [dbo].[sp_MonitorTempDbSize]

AS

BEGIN
	

	IF NOT EXISTS (SELECT 1 FROM dbadata.sys.tables WHERE name = 'tblTempDbSizeMonitor')

	CREATE TABLE tblTempDBSizeMonitor
	(dbname nvarchar(200),
	[Filename] nvarchar(200),
	CurrentSizeMB int,
	FreeSpaceMB int)

	DECLARE @SQL nvarchar(max)

	

	SET @SQL = '
	USE tempdb
	SELECT DB_NAME() AS DbName, 
	name AS FileName, 
	size/128.0 AS CurrentSizeMB,  
	size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB 
	FROM sys.database_files; '
	INSERT INTO tblTempDbSizeMonitor
	EXEC sp_Executesql @SQL
END