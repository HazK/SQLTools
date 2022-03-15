

EXEC sp_spaceused 


dbcc opentran -- Any open transactions preventing shrink?

select log_reuse_wait_desc,name from sys.databases -- Whats using the log?

SELECT file_id, name, type_desc, physical_name, size, max_size
FROM sys.database_files


DBCC SHRINKFILE (2, , TARGETMB, NOTRUNCATE)
DBCC SHRINKFILE (2, TARGETMB, TRUNCATEONLY)

DBCC SQLPERF(LOGSPACE)
