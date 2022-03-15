

DECLARE @OutputFile NVARCHAR(100) ,    
@FilePath NVARCHAR(100) ,    
@bcpCommand NVARCHAR(1000),
@Delimiter NVARCHAR(1)

SET @Delimiter = '|'
SET @bcpCommand = 'bcp "SELECT TOP 1000 * FROM [1stTouch_Production_DW].dbo.Transaction_Task_VisitG_Table1 " queryout '
SET @FilePath = 'C:\temp\'
SET @OutputFile = 'Top1000_Transaction_Task_VisitG_Table1.txt'
SET @bcpCommand = @bcpCommand + @FilePath + @OutputFile + ' -c -t^'+@Delimiter+' -T -S'+ @@servername
SELECT @bcpCommand
exec master..xp_cmdshell @bcpCommand

