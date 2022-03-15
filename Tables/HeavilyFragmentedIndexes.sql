

SELECT Object_name(ind.object_id) AS TableName, 
       ind.NAME                   AS IndexName, 
       indexstats.index_type_desc AS IndexType, 
       indexstats.avg_fragmentation_in_percent 
FROM   sys.Dm_db_index_physical_stats(Db_id(), NULL, NULL, NULL, NULL) 
       indexstats 
       INNER JOIN sys.indexes ind 
               ON ind.object_id = indexstats.object_id 
                  AND ind.index_id = indexstats.index_id 
WHERE  indexstats.avg_fragmentation_in_percent > 70 
ORDER  BY indexstats.avg_fragmentation_in_percent DESC  