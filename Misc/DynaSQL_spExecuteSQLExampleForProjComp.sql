
/* Project Complete Fornightly Tool */

/* SYSTEM */
SET NOCOUNT ON
DECLARE @CountValidation1 nvarchar(500)
DECLARE @CountValidation2 nvarchar(500)
DECLARE @OutputParameterDefinition nvarchar(500)
DECLARE @TABLE nvarchar(500)
DECLARE @DynaSQL nvarchar(500)
DECLARE @ValidFrom datetime
DECLARE @NewValidFrom datetime
DECLARE @UpdatedRowCount int

SET @OutputParameterDefinition = N'@CountOUT int OUTPUT'

/*** ******** USER DEFINED PARAMS *********************************************/
SET @NewValidFrom = '2015-09-20 00:00:00'	-- NEW DATE						/**/	
SET @TABLE = 'SORMapping'					-- TABLE						/**/
SET @ValidFrom = '2015-09-21 00:00:00'		-- CURRENT INCORRECT DATE		/**/
																			/**/
/******************************************************************************/

SET @DynaSQL = N'SELECT @CountOUT = COUNT(1) FROM ' + @TABLE + ' WHERE ValidTo = ''2099-12-31 00:00:00'''
EXEC sp_executesql @DynaSQL, @OutputParameterDefinition, @CountOUT = @CountValidation1 OUTPUT

SET @DynaSQL = N'SELECT @CountOUT = COUNT(1) FROM ' + @TABLE + ' WHERE ValidFrom =' + '''' + CONVERT(nvarchar,@ValidFrom,120) + ''''
EXEC sp_executesql @DynaSQL, @OutputParameterDefinition, @CountOUT = @CountValidation2 OUTPUT


IF @CountValidation1 = @CountValidation2
BEGIN
	BEGIN TRANSACTION
	PRINT 'Lets go, processing: ' + CONVERT(nvarchar, @CountValidation1) + ' records.'
	SET @DynaSQL = N'UPDATE ' + @TABLE + ' SET ValidFrom = ' + '''' +  CONVERT(nvarchar,@NewValidFrom,120) + '''' + ' WHERE ValidTo = ''2099-12-31 00:00:00'''
	EXEC sp_executesql @DynaSQL
	SET @UpdatedRowCount = (SELECT @@ROWCOUNT)
	IF @UpdatedRowCount = @CountValidation1
	BEGIN
		PRINT 'Expected Row Count = ' + CONVERT(nvarchar,@UpdatedRowCount) + ': Updated Row Count = ' + CONVERT(nvarchar,@UpdatedRowCount)
		PRINT '** COMMITTING TRANSACTION **'
		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'Counts do not match' 
		PRINT '** ROLLING BACK TRANSACTION **'
		ROLLBACK TRANSACTION
	END
END
ELSE
BEGIN
	PRINT 'Initial Counts Do Not Match'
END
