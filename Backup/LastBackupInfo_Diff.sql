
WITH 
	cte_GetPreviousToLastBackupDate
	AS	
	(SELECT
		RowNum,
		Database_Name,
		Backup_Finish_Date
	FROM
		(
		SELECT
			ROW_NUMBER() OVER ( Partition BY Database_Name ORDER BY Backup_Finish_date) RowNum,
			Backupset.Database_Name,
			Backup_Finish_Date
		FROM
			sys.Databases
				LEFT JOIN msdb.dbo.BackupSet on sys.Databases.Name = msdb.dbo.Backupset.Database_Name
		WHERE
			 msdb.dbo.BackupSet.[Type] = 'I'
		) a1
	WHERE
		RowNum = 2 
	)

SELECT
	ISNULL(MAX(Server_name),'No Backup Record Exists') Instance,
	sys.Databases.Name DatabaseName,
	MAX(msdb.dbo.BackupSet.Backup_Finish_date) LastBackupDate,
	MAX(cte_GetPreviousToLastBackupDate.Backup_Finish_Date) PreviousToLastBackupDate,
	CASE
		WHEN MAX(msdb.dbo.BackupSet.Backup_Finish_date) < GETDATE() - 1 AND msdb.dbo.BackupSet.[Type] = 'D'
		THEN 'Last full backup older than 24 hours'
		WHEN MAX(msdb.dbo.BackupSet.Backup_Finish_date) IS NULL
		THEN 'No backup record exists'
		ELSE 'Backup within less than 24 hours'
	END AS BackupChecker,
	'SELECT Database_Name, Backup_Start_date, Backup_Finish_date, backup_size, Server_Name FROM msdb.dbo.BackupSet WHERE [Type] = ''D'' AND Database_Name = ' + '''' + sys.Databases.Name + '''' + ' ORDER BY BACKUP_SET_ID DESC'
	 AS BackupHistory_SQL_RunMe
FROM
	sys.Databases
		LEFT JOIN msdb.dbo.BackupSet on sys.Databases.Name = msdb.dbo.Backupset.Database_Name
		LEFT JOIN cte_GetPreviousToLastBackupDate on sys.Databases.Name = cte_GetPreviousToLastBackupDate.Database_Name
WHERE
	 ((msdb.dbo.BackupSet.Database_Name IS NOT NULL AND msdb.dbo.BackupSet.[Type] = 'D')
		OR msdb.dbo.BackupSet.Database_Name IS NULL)
		
GROUP BY
	sys.Databases.Name,
	msdb.dbo.BackupSet.[Type]

	
