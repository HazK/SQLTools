

WITH CTE_List_FKEy_Relations

AS
(

SELECT 
	SP.Name ForeignKeyBaseTableSchema,
	TP.Name ForeignKeyBaseTable,
	CP.name ForeignKeyBaseColumn,
	SC.Name PrimaryBaseTableSchema,
	TC.Name PrimaryBaseTable,
	CC.name PrimaryBaseColumn,
	FK.Name AS ForeignKeyName,
	FK.[Object_ID] As ForeignKeyObjectID
FROM 
	sys.foreign_keys FK
		INNER JOIN sys.foreign_key_columns FKC on FK.[object_id] = FKC.constraint_object_id
		INNER JOIN sys.tables TP on FK.parent_object_id = TP.[object_id]
		INNER JOIN sys.tables TC on FK.referenced_object_id = TC.[object_id]
		INNER JOIN sys.schemas SP on TP.[schema_id] = SP.[schema_id]
		INNER JOIN sys.schemas SC on TC.[schema_id] = SC.[schema_id]
		INNER JOIN sys.columns CP on TP.[object_id] = CP.[object_id] AND CP.[column_id] = FKC.parent_column_id
		INNER JOIN sys.columns CC on TC.[object_id] = CC.[object_id] AND CC.[column_id] = FKC.referenced_column_id
),

CTE_List_PKeys AS
(
	SELECT  i.name AS IndexName,
			OBJECT_NAME(ic.OBJECT_ID) AS TableName,
			COL_NAME(ic.OBJECT_ID,ic.column_id) AS ColumnName
	FROM    sys.indexes AS i INNER JOIN 
			sys.index_columns AS ic ON  i.OBJECT_ID = ic.OBJECT_ID
									AND i.index_id = ic.index_id
	WHERE   i.is_primary_key = 1
)

SELECT
	CLFR.ForeignKeyBaseTableSchema,
	CLFR.ForeignKeyBaseTable,
	CLFR.ForeignKeyBaseColumn,
	CLP.ColumnName ForeignBasePrimaryKey,
	CLFR.PrimaryBaseTableSchema,
	CLFR.PrimaryBaseTable,
	CLFR.PrimaryBaseColumn,
	CLP2.ColumnName PrimaryBasePrimaryKey,
	CLFR.ForeignKeyName
FROM
	CTE_List_FKEy_Relations CLFR
		LEFT OUTER JOIN CTE_List_PKeys CLP on CLFR.ForeignKeyBaseTable = CLP.TableName
		LEFT OUTER JOIN CTE_List_PKeys CLP2 on CLFR.PrimaryBaseTable = CLP2.TableName
ORDER BY
	ForeignKeyBaseTable ASC

