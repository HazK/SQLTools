--CREATE TABLE Person
--(PersonID int identity(1,1) primary key,
--PersonName nvarchar(500),
--PersonSex nvarchar(10))


-- Loop insert

DECLARE @CurrentCount int
DECLARE @NumberRowsToINSERT int
DECLARE @Name nvarchar(50)
DECLARE @NameAlphaOnly nvarchar(50)
DECLARE @NameFinal nvarchar(50)
DECLARE @Num int
DECLARE @MorF varchar(1)

SET @CurrentCount = 0
SET @NumberRowsToINSERT = 50000
SET @MorF = 'M'

WHILE @CurrentCount <> @NumberRowsToINSERT
BEGIN
	--SET STATISTICS IO ON
	--SELECT TOP 1 PersonName FROM Person ORDER BY PersonID DESC
	SET @Name = (SELECT TOP 1 PersonName FROM Person ORDER BY PersonID DESC)

	IF @Name IS NULL-- OR @Name = ''
	BEGIN
		SET @Name = 'Name1'
		SELECT @Name AS [NAME]
	END

	SET @NameAlphaOnly = @Name

	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'1',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'2',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'3',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'4',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'5',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'6',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'7',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'8',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'9',''))
	SET @NameAlphaOnly = (SELECT REPLACE(@NameAlphaOnly,'0',''))


	SET @Num = (SELECT SUBSTRING(@Name,(SELECT PATINDEX('%[0-9]%',@Name)),(SELECT PATINDEX('%[0-9]',@Name))))
	SET @Num = @Num + 1

	SET @NameFinal = @NameAlphaOnly + CONVERT(nvarchar, @Num) 
	--SELECT @Num
	INSERT INTO Person
	SELECT @NameFinal,
	@MorF

	SET @CurrentCount = @CurrentCount + 1

END

SELECT * FROM Person
--TRUNCATE TABLE Person