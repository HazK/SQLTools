
CREATE PROC isp_Disable Jobs

AS

SET NOCOUNT ON

CREATE TABLE #Job_Names
( 
 Job_Name SYSNAME NOT NULL
)

INSERT INTO #Job_Names
SELECT name
FROM msdb.dbo.sysjobs
ORDER BY name

DECLARE @job_name SYSNAME
DECLARE @job_id UNIQUEIDENTIFIER

DECLARE disable_jobs CURSOR FOR 
SELECT Job_Name
FROM #Job_Names

SET @job_id = NULL

OPEN disable_jobs
FETCH NEXT FROM disable_jobs INTO @job_name

WHILE @@FETCH_STATUS = 0
BEGIN

 EXEC msdb.dbo.sp_verify_job_identifiers '@job_name', '@job_id', @job_name OUTPUT, @job_id OUTPUT

 EXEC msdb.dbo.sp_update_job @job_id, @enabled = 0
 
 SET @job_id = NULL

 FETCH NEXT FROM disable_jobs INTO @job_name

END

CLOSE disable_jobs
DEALLOCATE disable_jobs

DROP TABLE #Job_Names

RETURN
