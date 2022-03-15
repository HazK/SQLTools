USE [RestoreCommandCentre]
GO
/****** Object:  StoredProcedure [dbo].[Restore_Database]    Script Date: 25/10/2016 09:48:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[Restore_Database] (@DriveLetter nvarchar(1), @ServerName nvarchar(100), @DatabaseToRestoreName nvarchar(100), @DebugMode bit)

AS

SET NOCOUNT ON

/* Automated Restore Database Validation from CIF

Parameters:
@DriveLetter - Drive letter where CIFS share is mapped to
@ServerName - Server name to restore from (to match existing folder name in CIFS share)
@DatabaseToRestoreName - Database name to restore (to match existing folder name in CIFS share)

What happens next:
- Validation of parameters
- Database created to restore to; @DatabaseToRestoreName_Restore log will be created
- Database files to restore are gathered - supports striped file restore
- Latest FULL backup (within FULL folder name on CIFS share) is restore
- Data and log files are automatically move to local default location
- Database restored to is deleted after restoring to conserve disk space
- All activities are logged in table RestoreLog which can be used for reporting activity

Version 1.0 Harrison Kirby -- Initial build


*/

DECLARE @ShowAdvancedOptions TABLE (name nvarchar(50), minumum int, maximum int, config_value int, run_value int)
DECLARE @xp_cmdshellCapture TABLE (name nvarchar(20), minumum int, maximum int, config_value int, run_value int)
DECLARE @DriveLetterCapture TABLE ([Output] nvarchar(400))
DECLARE @DirectoryCaptureLevel1 TABLE (subdirectory nvarchar(100), depth int)
DECLARE @DirectoryCaptureLevel2 TABLE (subdirectory nvarchar(100), depth int)
DECLARE @BackupFileCapture TABLE (subdirectory nvarchar(100), depth int, [file] int)
DECLARE @BackupFileFinalList TABLE (backupdate nvarchar(20), backupfile nvarchar(200))
DECLARE @ChildFolderCapture TABLE (CurrentPos int)
DECLARE @DataLogFileCapture TABLE (LogicalName nvarchar(50), PhysicalName nvarchar(500), [Type] nvarchar(4), FileGroupName nvarchar(50), Size bigint, MaxSize bigint, FileID bigint, CREATELSN bigint, DropLSN bigint, UniqID nvarchar(500), ReadOnlyLSN bigint, ReadWriteLSN bigint, BackupSizeInBytes bigint, SourceBlockSize bigint, FileGroupID bigint, LogGroupGUID nvarchar(500), DifferentialBaseLSN nvarchar(500), DifferentialBaseGUID nvarchar(500), IsReadOnly bigint, IsPresesnt bigint, TDEThumprint nvarchar(500))
DECLARE @BackupFilePath nvarchar(300)
DECLARE @SessionCapture TABLE (DatabaseName nvarchar(100), SPID Int)
DECLARE @NextMessageID int
DECLARE @SetErrorMessageNumber int
DECLARE @DriveLetterFQ nvarchar(3)
DECLARE @DirectorySearch nvarchar(200)
DECLARE @DriveLetterCaptureString nvarchar(2)
DECLARE @ValidationOK bit
DECLARE @BatchID int
DECLARE @DestinationDatabase nvarchar(50)
DECLARE @DatabaseCreateString nvarchar(100)
DECLARE @Subdirectory nvarchar(500)
DECLARE @CurrentBackupFile nvarchar(200)
DECLARE @RestoreExecutionString nvarchar(max)
DECLARe @BackupFileString nvarchar(max)
DECLARe @RestoreExecutionFileString nvarchar(max)
DECLARe @RestoreExecutionLogString nvarchar(max)
DECLARE @CurrentLogName nvarchar(100)
DECLARE @CurrentDataName nvarchar(100)
DECLARE @CurrentFileType nvarchar(10)
DECLARE @CurrentFileID int
DECLARE @CurrentDatabaseFileCount int
DECLARE @CountOfBackupFiles Tinyint
DECLARE @RestoreToDataPath nvarchar(100)
DECLARE @RestoreToLogPath nvarchar(100)
DECLARE @DatabaseDropString nvarchar(200)
DECLARE @DynamicFileName nvarchar(200)
DECLARE @RestorePath nvarchar(100)
DECLARE @CountSlashCurrent int
DECLARE @StartPos int
DECLARE @FinalPos int
DECLARE @ProcessContinue int
DECLARE @DataChildFolder nvarchar(1000)
DECLARE @FileExtension nvarchar(5)


SET @ValidationOK = 1

/* Parameter Validation Steps */


-- Validate Log Table existance

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RestoreLog')
BEGIN
	RAISERROR('RestoreLog Table Missing: Create Schema:
		CREATE TABLE RestoreLog
		(
		batchID int,
		runid int identity(1,1) NOT NULL,
		[State] nvarchar(200),
		[Description] nvarchar(1000),
		LogDate datetime)

		GO

		ALTER TABLE [dbo].[RestoreLog] ADD PRIMARY KEY CLUSTERED 
		(
			[runid] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
		GO
	',16,1)
RETURN
END

SET @BatchID = (SELECT ISNULL(MAX(BatchID),0) + 1 FROM RestoreLog)

INSERT INTO RestoreLog SELECT @BatchID, 'START', 'Starting batch ' + CONVERT(nvarchar(5),@BatchID) + ' for database: ' + @DatabaseToRestoreName + ' from ' + @ServerName, GETDATE()

-- Validate Show Advanced Options is on so we can see if xp_cmdshell is enabled

INSERT INTO @ShowAdvancedOptions
EXEC sp_Configure 'show advanced options'

IF (SELECT run_value FROM @ShowAdvancedOptions) = 0
BEGIN
	SET @ValidationOK = 0
	RAISERROR('show advanced options is not enabled, therefore we cannot check for xp_cmdshell availability',16,1)
	INSERT INTO RestoreLog SELECT @BatchID, 'ERROR', 'show advanced options is not enabled, therefore we cannot check for xp_cmdshell availability', GETDATE()
RETURN
END

-- Validate xp_cmdshell is enabled

INSERT INTO @xp_cmdshellCapture
EXEC sp_configure 'xp_cmdshell'

IF (SELECT run_value FROM @xp_cmdshellCapture) = 0
BEGIN
	SET @ValidationOK = 0
	RAISERROR('xp_cmdshell is not enabled, please enable and re run',16,1)
	INSERT INTO RestoreLog SELECT @BatchID, 'ERROR', 'xp_cmdshell is not enabled, please enable and re run', GETDATE()
RETURN
END

-- Validate @DriveLetter and capture available directorys
SET @DriveLetterCaptureString = @DriveLetter + ':' 
INSERT INTO @DriveLetterCapture
EXEC XP_cmdshell @DriveLetterCaptureString


IF @DriveLetter IS NULL OR @DriveLetter = '' OR EXISTS (SELECT 1 FROM @DriveLetterCapture WHERE [Output] = 'The system cannot find the drive specified.')
BEGIN
	SET @ValidationOK = 0
	RAISERROR('@DriveLetter Not supplied, unavailable or invalid',16,1)
	INSERT INTO RestoreLog SELECT @BatchID, 'ERROR', '@DriveLetter Not supplied, unavailable or invalid', GETDATE()
RETURN 
END

INSERT INTO RestoreLog SELECT @BatchID, 'OK',  '@DriveLetter verified', GETDATE()

SET @DriveLetterFQ = @DriveLetter + ':\'
INSERT INTO @DirectoryCaptureLevel1
EXEC xp_dirtree @DriveLetterFQ,1,0

-- Validate @ServerName and capture available files
IF NOT EXISTS (SELECT 1 FROM @DirectoryCaptureLevel1 WHERE subdirectory = @ServerName)
OR @ServerName IS NULL OR @ServerName = ''
BEGIN
	SET @ValidationOK = 0
	RAISERROR('Database Folder Name (passed by parameter @ServerName) does not exist, or invalid parameter has been passed to @ServerName',16,1)
	INSERT INTO RestoreLog SELECT @BatchID, 'ERROR', 'Database Folder Name (passed by parameter @ServerName) does not exist, or invalid parameter has been passed to @ServerName', GETDATE()
RETURN
END

INSERT INTO RestoreLog SELECT @BatchID, 'OK',  '@ServerName verified', GETDATE()

SET @DirectorySearch = @DriveLetterFQ  + @ServerName
INSERT INTO @DirectoryCaptureLevel2
EXEC xp_dirtree @DirectorySearch,1,0

-- Validate @DatabaseToRestoreName
IF NOT EXISTS (SELECT 1 FROM @DirectoryCaptureLevel2 WHERE subdirectory = @DatabaseToRestoreName)
OR @DatabaseToRestoreName IS NULL OR @DatabaseToRestoreName = ''
BEGIN
	SET @ValidationOK = 0
	RAISERROR('Database Restore Name (passed by parameter @DatabaseToRestoreName) does not exist, or invalid parameter has been passed to @DatabaseToRestoreName',16,1)
	INSERT INTO RestoreLog SELECT @BatchID, 'ERROR', 'Database Restore Name (passed by parameter @DatabaseToRestoreName) does not exist, or invalid parameter has been passed to @DatabaseToRestoreName', GETDATE()
RETURN
END

INSERT INTO RestoreLog SELECT @BatchID,'OK',  '@DatabaseToRestoreName verified', GETDATE()


-- Validate full path
SET @BackupFilePath = @DirectorySearch  + '\' + @DatabaseToRestoreName + '\' + 'FULL'
INSERT INTO @BackupFileCapture
EXEC xp_dirtree @BackupFilePath,1,1


IF NOT EXISTS (SELECT 1 FROM @BackupFileCapture)
BEGIN	
	SET @ValidationOK = 0
	RAISERROR('Full path is empty, or FULL folder is missing, see restore log',16,1)
	INSERT INTO RestoreLog SELECT @BatchID, 'ERROR', 'Full path empty or invalid, please validate path = '+@BackupFilePath ,  GETDATE() FROM @SessionCapture
RETURN
END

INSERT INTO RestoreLog SELECT @BatchID,'OK',  'Full path verified', GETDATE()

/* Validation Steps Complete */

/* Start Preparing For Restore */

IF @ValidationOK = 1

INSERT INTO RestoreLog SELECT @BatchID,'OK',  'Parameters verified, beginning restore process', GETDATE()
	BEGIN

	SET @DestinationDatabase = @DatabaseToRestoreName + '_Restore'

	-- Validate @DestinationDatabase existance , if it does not create the database
	IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE Name = @DestinationDatabase)
	BEGIN
		INSERT INTO RestoreLog SELECT @BatchID, 'OK', 'Creating database to restore to', GETDATE()
		SET @DatabaseCreateString = 'CREATE DATABASE ' + @DestinationDatabase
		EXEC sp_executesql @DatabaseCreateString
	END
	ELSE
	BEGIN
		INSERT INTO RestoreLog SELECT @BatchID, 'OK', @DestinationDatabase + ' already exists, using this to restore to', GETDATE()
	END


	SET @RestoreToDataPath = (SELECT sys.master_files.physical_name FROM sys.master_files INNER JOIN sys.databases on sys.master_files.database_id = sys.databases.database_id  WHERE sys.databases.name = @DestinationDatabase AND [File_id] = 1)
	SET @RestoreToLogPath = (SELECT sys.master_files.physical_name FROM sys.master_files INNER JOIN sys.databases on sys.master_files.database_id = sys.databases.database_id  WHERE sys.databases.name = @DestinationDatabase AND [File_id] = 2)

	INSERT INTO RestoreLog SELECT @BatchID,'OK',  '@DestinationDatabase verified', GETDATE()

	-- Validate there are no connections to @DestinationDatabase

	INSERT INTO @SessionCapture
	SELECT @DestinationDatabase, session_id FROM sys.dm_exec_sessions WHERE database_id = DB_ID(@DestinationDatabase)
	IF NOT EXISTS (SELECT 1 FROM @SessionCapture)

	IF EXISTS (SELECT 1 FROM @SessionCapture)
	BEGIN
		SET @ValidationOK = 0
		RAISERROR('Sessions still active against @DestinationDatabase, see table RestoreLog for details ',16,1)
		INSERT INTO RestoreLog SELECT @BatchID, 'ERROR', 'Active session: ' + CONVERT(nvarchar(5), SPID) + ' exists for database: ' + DatabaseName ,  GETDATE() FROM @SessionCapture
	RETURN
	END

	INSERT INTO RestoreLog SELECT @BatchID,'OK',  '@SessionCapture verified', GETDATE()

	-- Get latest file(s)

	INSERT INTO RestoreLog SELECT @BatchID,'OK',  'Building restore string', GETDATE()
	INSERT INTO @BackupFileFinalList
	SELECT 
		SUBSTRING(subdirectory,(PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][_][0-9][0-9][0-9][0-9][0-9][0-9]%',subdirectory)),15 )BackupDate,
		subdirectory AS BackupFile
	FROM @BackupFileCapture 

	-- Get list log and data file name 

	SET @CurrentBackupFile = (SELECT MAX(BackupFile) FROM @BackupFileFinalList)
	SET @RestoreExecutionString = 'RESTORE FILELISTONLY FROM DISK = ''' + @BackupFilePath + '\' + @CurrentBackupFile +''''

	INSERT INTO @DataLogFileCapture
	EXEC sp_executeSQL @RestoreExecutionString 

	-- Generate data part of restore string 
	SET @CountOfBackupFiles =	(SELECT COUNT(1) FROM @DataLogFileCapture WHERE [Type] = 'D')
	SET @RestoreExecutionFileString = ''

	SET @RestorePath = (SELECT sys.master_files.physical_name FROM sys.master_files INNER JOIN sys.databases on sys.master_files.database_id = sys.databases.database_id  WHERE sys.databases.name = @DestinationDatabase AND [File_id] = 1)
		
	-- Extract just the data path, by getting to the lowest level child folder

	INSERT INTO RestoreLog SELECT @BatchID,'OK',  'getting data path', GETDATE()

	SET @CountSlashCurrent = 0
	SET @StartPos = 0
	SET @ProcessContinue = 1
	WHILE @ProcessContinue = 1
	BEGIN
		SET @CountSlashCurrent = CHARINDEX('\',@RestorePath,@StartPos)
		IF @CountSlashCurrent <> 0
			BEGIN
				INSERT INTO @ChildFolderCapture SELECT @CountSlashCurrent
			END
			ELSE
			BEGIN
				SET @ProcessContinue = 0
			END
		SET @StartPos = @CountSlashCurrent + 1
	END

	SET @FinalPos = (SELECT MAX(CurrentPos) FROM @ChildFolderCapture)
	SET @DataChildFolder = (SELECT SUBSTRING(@RestorePath,1,@FinalPos))

	INSERT INTO RestoreLog SELECT @BatchID,'OK',  'datapath =  ' + @DataChildFolder, getdate()

	SET @CurrentDatabaseFileCount = (SELECT COUNT(1) FROM @DataLogFileCapture)

	-- Create string
	DECLARE crsr_GenDataExecString CURSOR FAST_FORWARD
	FOR
	SELECT
		LogicalName,
		FIleID,
		[Type] 
	FROM
		@DataLogFileCapture
	ORDER BY FileID ASC

	OPEN crsr_GenDataExecString
	FETCH NEXT FROM crsr_GenDataExecString INTO @CurrentDataName, @CurrentFileID, @CurrentFileType
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		
		IF @CurrentFileID = 1 AND @CurrentFileType = 'D'
		SET @FileExtension = '.mdf'
	
		IF @CurrentFileID <> 1 AND @CurrentFileType = 'D'
		SET @FileExtension = '.ndf'

		IF @CurrentFileID <> 1 AND @CurrentFileType = 'L'
		SET @FileExtension = '.ldf'

		IF @CurrentDatabaseFileCount <> 1
		BEGIN
			SET @RestoreExecutionFileString = @RestoreExecutionFileString + 'MOVE ' + '''' + @CurrentDataName + '''' + ' TO ' + '''' + @DataChildFolder + @CurrentDataName + @FileExtension + '''' + ','
		END
		ELSE
		BEGIN
			SET @RestoreExecutionFileString = @RestoreExecutionFileString + 'MOVE ' + '''' + @CurrentDataName + '''' + ' TO ' + '''' + @DataChildFolder + @CurrentDataName + @FileExtension + ''''
		END

		SET @CurrentDatabaseFileCount = @CurrentDatabaseFileCount - 1
		FETCH NEXT FROM crsr_GenDataExecString INTO @CurrentDataName, @CurrentFileID, @CurrentFileType
		
	END
	CLOSE crsr_GenDataExecString
	DEALLOCATE crsr_GenDataExecString


	SET @CountOfBackupFiles =	(SELECT COUNT(backupfile) FROM @BackupFileFinalList WHERE BackupDate  = (SELECT MAX(backupdate) FROM @BackupFileFinalList))
	SET @BackupFileString = ''

	DECLARE crsr_GenResExecString CURSOR FAST_FORWARD
	FOR	
		SELECT backupfile 
		FROM @BackupFileFinalList
		WHERE BackupDate  = (SELECT MAX(backupdate) FROM @BackupFileFinalList)
		ORDER BY backupfile ASC
	OPEN crsr_GenResExecString
	FETCH NEXT FROM crsr_GenResExecString INTO @CurrentBackupFile

	-- Create backup file execution string, supports multiple files
	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CountOfBackupFiles <> 1
				BEGIN
					SET @BackupFileString = @BackupFileString + ' DISK = N'''+  @BackupFilePath + '\' + @CurrentBackupFile + ''','
					FETCH NEXT FROM crsr_GenResExecString INTO @CurrentBackupFile
				END
				ELSE
				BEGIN
					SET @BackupFileString = @BackupFileString + ' DISK = N'''+  @BackupFilePath + '\' + @CurrentBackupFile  + ''''
					FETCH NEXT FROM crsr_GenResExecString INTO @CurrentBackupFile
				END
			SET @CountOfBackupFiles = @CountOfBackupFiles - 1
		END
	CLOSE crsr_GenResExecString
	DEALLOCATE crsr_GenResExecString

/* Do The Restore */
SET @RestoreExecutionString = 'RESTORE DATABASE ' + @DestinationDatabase + ' FROM ' + @BackupFileString + 'WITH FILE = 1, ' + @RestoreExecutionFileString + ' , REPLACE,  STATS = 1'
IF @DebugMode = 0
	BEGIN
		INSERT INTO RestoreLog SELECT @BatchID,'OK',  'Executing Restore String '  , GETDATE()
		EXEC sp_executesql @RestoreExecutionString
	INSERT INTO RestoreLog SELECT @BatchID,'OK',  'Execution Complete' , GETDATE()
	END
	ELSE
	BEGIN
		SELECT @RestoreExecutionString
		INSERT INTO RestoreLog SELECT @BatchID,'OK',  'IN DEBUG MODE' , GETDATE()
	END

/* Finish up */

-- Drop database

SET @DatabaseDropString = 'DROP DATABASE ' + @DestinationDatabase

EXEC sp_executesql  @DatabaseDropString

-- Purge Log

INSERT INTO RestoreLog SELECT @BatchID, 'FINISH', 'Process Finished', GETDATE()


END