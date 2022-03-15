USE dbadata

GO

IF OBJECT_ID('sp_ManualEmailAgentJobLastRun_24Hour','P') IS NOT NULL

DROP PROCEDURE sp_ManualEmailAgentJobLastRun_24Hour

GO

CREATE PROCEDURE sp_ManualEmailAgentJobLastRun_24Hour (@Job_ID nvarchar(400))

AS

-- HK - 09/04/2015 - See's whether SQL agent job (as per JobID) has been run in last 24 hours, sends email dependant on outcome)


SET NOCOUNT ON

DECLARE @msghtml as varchar(max),
	    @msgsubject as varchar(255),
		@msgheader as varchar(1000), 
		@mailrecipients as varchar(max),
		@emailprofile as varchar(50),
		@msgbodyfmt as varchar(5), 
		@msgimportance as varchar(10), 
		@bccmailrecipients as varchar(max),
		@LastBackupJobDate datetime

SET @emailprofile = 'Backup'
SET @mailrecipients = 'Harrison.kirby@homeserve.com'
SET @LastBackupJObDate = (

							SELECT	
								LEFT(LastBackupJobDate,4) + '/' +
								SUBSTRING(CONVERT(nvarchar,LastBackupJobDate),5,2) + '/' +
								RIGHT(LastBackupJobDate,2)
							FROM
								(
									SELECT 
										MAX(run_date) As LastBackupJobDate
									FROM 
										PRE01DBFAL01.msdb.[dbo].[sysjobhistory] 
									WHERE Job_ID = @Job_ID
										AND Run_Status = 1
										AND step_id = 0
								) p1
						)

IF @LastBackupJobDate < GETDATE() - 1

BEGIN
	PRINT 'Last Backup Less than 24 Hours'

	
set @msgsubject = 'Backup Job Check - Backups PRE01DBFAL01 OK'
set @msgheader = ' PRE01DBFAL01 SQL Agent Job - "DB Backup Job for DB Maintenance Plan "DBA_Backup_ALL" OK'
set @msgbodyfmt = 'HTML'
set @msgimportance = 'NORMAL'
set @msgsubject = @msgsubject + convert(varchar,getdate(),107) 
set @msghtml = '<font face="Arial" size="+1" color="#000000">
				<h><p><b> </b></p></h></font>
				<p></p>
				<font face="Arial" size="+1" color="#000000">
				<p>' + @msgheader + '</p>
				<p></p>'
--run users update stored procedure	
--moved to seperate steps 28/07/2010

exec msdb.dbo.sp_send_dbmail
		@profile_name = @emailprofile,
		@recipients = @mailrecipients,
		@subject =  @msgsubject,
		@body = @msghtml,
		@body_format = @msgbodyfmt,
		@importance = @msgimportance

END
ELSE 
BEGIN
	PRINT 'Last Backup Older than 24 Hours'

set @msgsubject = '*** Potential Failure *** Backup Job Check - Backups PRE01DBFAL01 require checking'
set @msgheader = ' PRE01DBFAL01 SQL Agent Job - "DB Backup Job for DB Maintenance Plan "DBA_Backup_ALL" has not completed with last 24 hours'
set @msgbodyfmt = 'HTML'
set @msgimportance = 'NORMAL'
set @msgsubject = @msgsubject + convert(varchar,getdate(),107) 
set @msghtml = '<font face="Arial" size="+1" color="#000000">
				<h><p><b> </b></p></h></font>
				<p></p>
				<font face="Arial" size="+1" color="#000000">
				<p>' + @msgheader + '</p>
				<p></p>'
--run users update stored procedure	
--moved to seperate steps 28/07/2010

exec msdb.dbo.sp_send_dbmail
		@profile_name = @emailprofile,
		@recipients = @mailrecipients,
		@subject =  @msgsubject,
		@body = @msghtml,
		@body_format = @msgbodyfmt,
		@importance = @msgimportance
END



