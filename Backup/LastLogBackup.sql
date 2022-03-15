
DECLARE @DB_FULL_REC TABLE
(DatabaseName nvarchar(300))

INSERT INTO @DB_FULL_REC
SELECT
	Name
FROM
	sys.databases
WHERE
	state_desc = 'ONLINE'
	AND recovery_model_desc = 'FULL'

SELECT
	@@SERVERNAME INstance,
	DatabaseName,
	MAX(backup_finish_date) LastLogBackup
FROM
	@DB_FULL_REC FullDbs
		LEFT JOIN msdb.dbo.BackupSet BackupSet on FullDbs.DatabaseName = BackupSet.Database_Name
WHERE
	[Type] = 'L'
GROUP BY
	DatabaseName