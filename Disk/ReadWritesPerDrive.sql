SELECT left(f.physical_name, 1) AS DriveLetter, 	
DATEADD(MS,sample_ms * -1, 
GETDATE()) AS [Start Date],	
SUM(v.num_of_writes) AS total_num_of_writes, 	
SUM(v.num_of_bytes_written) AS total_num_of_bytes_written, 	
SUM(v.num_of_reads) AS total_num_of_reads, 	
SUM(v.num_of_bytes_read) AS total_num_of_bytes_read, 	
SUM(v.size_on_disk_bytes) AS total_size_on_disk_bytes
FROM sys.master_files f INNER JOIN sys.dm_io_virtual_file_stats(NULL, NULL) v 
ON f.database_id=v.database_id and f.file_id=v.file_id 
GROUP BY left(f.physical_name, 1),DATEADD(MS,sample_ms * -1, GETDATE());