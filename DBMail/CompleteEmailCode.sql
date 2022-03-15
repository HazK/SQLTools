
declare @msghtml as varchar(max), @msgsubject as varchar(255), @msgheader as varchar(1000), @mailrecipients as varchar(max),
		@emailprofile as varchar(50), @msgbodyfmt as varchar(5), @msgimportance as varchar(10), @bccmailrecipients as varchar(max)

set @emailprofile = 'Backup'

set @mailrecipients = 'x'
set @msgsubject = 'Backup Job Check - User Backups completed at '
set @msgheader = ' SQL Agent Job - "DBA_Backup_DB.DB_Backup" has completed'
set @msgimportance = 'NORMAL'

use msdb

set @msgsubject = @msgsubject + convert(varchar,getdate(),120) 




--run users update stored procedure	
--moved to seperate steps 28/07/2010

exec msdb.dbo.sp_send_dbmail
		@profile_name = @emailprofile,
		@recipients = @mailrecipients,
		@subject =  @msgsubject,
		@body = @msgheader, 
		@importance = @msgimportance;
