SELECT
	SUM(KB) / 1024 TotalMB
FROM
(


SELECT count(*)AS cached_pages_count,(count(*) * 8) as KB 
	,(count(*) * 8)/1024 as MB 
	,((count(*) * 8)/1024) / 1024 as GB 
    ,CASE database_id 
        WHEN 32767 THEN 'ResourceDb' 
        ELSE db_name(database_id) 
        END AS Database_name 
 FROM sys.dm_os_buffer_descriptors 
 GROUP BY db_name(database_id) ,database_id 

)
p1

SELECT count(*)AS cached_pages_count,(count(*) * 8) as KB 
	,(count(*) * 8)/1024 as MB 
	,((count(*) * 8)/1024) / 1024 as GB 
    ,CASE database_id 
        WHEN 32767 THEN 'ResourceDb' 
        ELSE db_name(database_id) 
        END AS Database_name 
 FROM sys.dm_os_buffer_descriptors 
 GROUP BY db_name(database_id) ,database_id 
 ORDER BY cached_pages_count DESC; 