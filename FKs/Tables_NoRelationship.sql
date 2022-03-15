

SELECT
	ss.name SchemaName,
	st.Name TableName
FROM
	sys.tables st
		INNER JOIN sys.schemas ss on st.[schema_id] = ss.[schema_id]
WHERE
	NOT EXISTS(
		SELECT 
			1
		FROM 
			sys.foreign_keys FK
				INNER JOIN sys.foreign_key_columns FKC on FK.[object_id] = FKC.constraint_object_id
				INNER JOIN sys.tables TP on FK.parent_object_id = TP.[object_id]
				INNER JOIN sys.tables TC on FK.referenced_object_id = TC.[object_id]
				INNER JOIN sys.schemas SP on TP.[schema_id] = SP.[schema_id]
				INNER JOIN sys.schemas SC on TC.[schema_id] = SC.[schema_id]
				INNER JOIN sys.columns CP on TP.[object_id] = CP.[object_id] AND CP.[column_id] = FKC.parent_column_id
				INNER JOIN sys.columns CC on TC.[object_id] = CC.[object_id] AND CC.[column_id] = FKC.referenced_column_id
	WHERE st.name = TP.name OR st.name = TC.name

)
ORDER BY
	TableName ASC