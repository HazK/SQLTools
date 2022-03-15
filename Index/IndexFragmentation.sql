SELECT [DatabaseName]
    ,[ObjectId]
    ,[ObjectName]
    ,[IndexId]
	,s.Name
	,s.Fill_Factor
    ,[IndexDescription]
    ,CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024))) AS [IndexSize(MB)]
    ,[lastupdated] AS [StatisticLastUpdated]
    ,AvgExternalFragmentation
	,AvgInternalSpaceUsed
	,CASE
	WHEN SizeBytes < 1000000 -- 1MB
	THEN 'Index Too Small For Consideration'
	 WHEN avg_page_space_used_in_percent < 75 AND SizeBytes > 1000000 -- 1MB
	THEN 'Bad'
	WHEN avg_page_space_used_in_percent > 75 AND avg_page_space_used_in_percent < 87.5 AND SizeBytes > 1000000 -- 1MB
	THEN 'Good'
	WHEN avg_page_space_used_in_percent > 87.5 AND SizeBytes > 1000000 -- 1MB
	THEN 'Excellent'
	ELSE 'Index Not Considered'
	END AS InternalFragmentationStatus,
	SizeBytes

FROM (
		SELECT DISTINCT DB_Name(Database_id) AS 'DatabaseName'
			,OBJECT_ID AS ObjectId
			,Object_Name(Object_id) AS ObjectName
			,Index_ID AS IndexId
			,Index_Type_Desc AS IndexDescription
			,avg_record_size_in_bytes
			,record_count
			,avg_record_size_in_bytes * Record_count as SizeBytes
			,STATS_DATE(object_id, index_id) AS 'lastupdated'
			,CONVERT([varchar](512), round(Avg_Fragmentation_In_Percent, 3)) AS 'AvgExternalFragmentation'
			,CONVERT([varchar](512), round(avg_page_space_used_in_percent, 3)) AS 'AvgInternalSpaceUsed'
			,avg_page_space_used_in_percent
		FROM sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'SAMPLED') sysstats
		WHERE OBJECT_ID IS NOT NULL
			
    ) T
		INNER JOIN (SELECT DISTINCT Index_ID, Name, fill_factor, [Object_id] From sys.indexes WHERE [Object_ID] > 100 AND NAME IS NOT NULL) AS S on T.ObjectId = S.[object_id]
	WHERE IndexDescription <> 'HEAP'
	GROUP BY DatabaseName
    ,ObjectId
    ,ObjectName
    ,IndexId
    ,IndexDescription
    ,lastupdated
    ,AvgExternalFragmentation
	,AvgInternalSpaceUsed
	,avg_page_space_used_in_percent
	,s.Name
	,s.Fill_Factor
	,SizeBytes

