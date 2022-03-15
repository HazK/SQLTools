

DECLARE @LastLogBackupDate datetime,
		@msghtml as varchar(max), 
		@msgsubject as varchar(255), 
		@msgheader as varchar(1000), 
		@mailrecipients as varchar(max),
		@emailprofile as varchar(50), 
		@msgbodyfmt as varchar(5), 
		@msgimportance as varchar(10), 
		@bccmailrecipients as varchar(max)

SET @LastLogBackupDate =
	(

		SELECT
			MAX(Backup_Finish_Date) LastBackupDate
		FROM
			msdb.dbo.BackupSet
				INNER JOIN sys.Databases on msdb.dbo.BackupSet.Database_Name = sys.Databases.Name
		WHERE
			[Type] = 'L'
			AND sys.databases.recovery_model = '1'

	)

IF @LastLogBackupDate < GETDATE() - '00:00:30'

BEGIN

	PRINT 'SQL Safe needs verifying'

	set @emailprofile = 'Alert'

	set @mailrecipients = 'HGBISDataAlerts@homeserve.com'
	set @msgsubject = 'SQL Safe Service Potentially Hung on WAL01DBVER01 '
	set @msgheader = ' SQL Safe Service Potentially Hung on WAL01DBVER01.
						Please Verifiy SQL SAFE queue/execution progress and
						restart service if required.'
	set @msgbodyfmt = 'HTML'
	set @msgimportance = 'NORMAL'

	use msdb

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