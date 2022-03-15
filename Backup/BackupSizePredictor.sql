DECLARE @DBName nvarchar(200)
DECLARE @DynaSQL nvarchar(2000)
DECLARE @ProcessList TABLE
(DatabaseName nvarchar(200),
Processed bit)
DECLARE @CaptureTable TABLe
(FileSizeMB nvarchar(100),
UsedSpaceMB nvarchar(100),
UnusedSPaceMB nvarchar(100),
DBFIleName nvarchar(100))


INSERT INTO @ProcessList
SELECT name,0 FROM sys.databases WHERE database_Id > 4

WHILE EXISTS (SELECT 1 FROM @ProcessList WHERE Processed = 0)

BEGIN
	SET @DBName = (SELECT TOp 1 DatabaseName FROM @processList WHERE Processed = 0)

	SET @DynaSQL = 'USE ' + @DBName + ' 
	select [FileSizeMB] = convert(numeric(10,2)
	, round(a.size/128.,2))
	, [UsedSpaceMB] = convert(numeric(10,2)
	, round(fileproperty( a.name,''SpaceUsed'')/128.,2))
	, [UnusedSpaceMB] = convert(numeric(10,2)
	, round((a.size-fileproperty( a.name,''SpaceUsed''))/128.,2))
	, [DBFileName] = a.name
	from sysfiles a
	'
	INSERT INTO @CaptureTable
	EXEC sp_executesql @DynaSQL

	UPDATE @processlist set processed = 1 WHERE DatabaseName = @DBName

END


SELECT * FROM @CaptureTable

SELECT SUM(CONVERT(float, UsedSpaceMB)) As TotalSpaceRequired FROM @CaptureTable