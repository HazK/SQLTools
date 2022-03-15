
	SELECT
	'production_ClaimCenter' AS DatabaseName,
	OBJECT_NAME(i.OBJECT_ID) AS TableName,
	i.name AS IndexName,
	i.index_id AS IndexID,
	8 * SUM(a.used_pages) AS 'Indexsize(KB)',
	8 * SUM(a.used_pages)/1024 AS 'Indexsize(MB)',
	8 * (SUM(a.used_pages)/1024) /1024 AS 'Indexsize(GB)',
	s.Name FileGroupName
	FROM sys.indexes AS i
	INNER JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
	INNER JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
	INNER JOIN [sys].[filegroups] f ON f.[data_space_id] = i.[data_space_id]
	INNER JOIN [sys].[database_files] d ON f.[data_space_id] = d.[data_space_id]
	INNER JOIN [sys].[data_spaces] s ON f.[data_space_id] = s.[data_space_id]
	WHERE s.name = 'INDEXES'
	GROUP BY i.OBJECT_ID,i.index_id,i.name,s.name
	ORDER BY OBJECT_NAME(i.OBJECT_ID),i.index_id
