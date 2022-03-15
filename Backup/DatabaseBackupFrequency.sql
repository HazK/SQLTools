

SELECT 
	AVG(FrequencyDays) FrequencyDays,
	Database_Name,
	BackupType
FROM
	(
	SELECT
		p1.Database_Name,
		p1.Backup_Finish_Date,
		MIN(p2.Backup_Finish_Date)Backup_Finish_Date_2,
		DATEDIFF("D",p1.Backup_Finish_Date, MIN(p2.Backup_Finish_Date)) FrequencyDays,
		'FULL' AS BackupType
	FROM
		sys.Databases
			LEFT JOIN msdb.dbo.BackupSet p1 on sys.Databases.Name = p1.Database_Name
			LEFT JOIN msdb.dbo.BackupSet p2 on p1.database_name = p2.database_name
	WHERE
		p1.backup_finish_date > GETDATE() - 365
		AND p1.[Type] = 'D' AND p2.[Type] = 'D'
		AND sys.Databases.State_desc = 'ONLINE'
		AND 	 p2.Backup_Finish_Date > p1.Backup_Finish_Date
	GROUP BY
		p1.database_name,
		p1.backup_finish_date
	UNION
	SELECT
		p1.Database_Name,
		p1.Backup_Finish_Date,
		MIN(p2.Backup_Finish_Date)Backup_Finish_Date_2,
		DATEDIFF("D",p1.Backup_Finish_Date, MIN(p2.Backup_Finish_Date)) FrequencyDays,
		'DIFF' AS BackupType
	FROM
		sys.Databases
			LEFT JOIN msdb.dbo.BackupSet p1 on sys.Databases.Name = p1.Database_Name
			LEFT JOIN msdb.dbo.BackupSet p2 on p1.database_name = p2.database_name
	WHERE
		p1.backup_finish_date > GETDATE() - 365
		AND p1.[Type] = 'I' AND p2.[Type] = 'I'
		AND sys.Databases.State_desc = 'ONLINE'
		AND 	 p2.Backup_Finish_Date > p1.Backup_Finish_Date
	GROUP BY
		p1.database_name,
		p1.backup_finish_date
	) sqry1
GROUP BY
	Database_Name,
	BackupType
ORDER BY
	Database_Name ASC