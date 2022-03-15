-- See https://msdn.microsoft.com/en-us/library/hh710046.aspx for setup

-- Validation 


-- USE WAL01DBDST01 for AAG !!

USE distribution;
GO
DECLARE @redirected_publisher sysname;
EXEC sys.sp_validate_replica_hosts_as_publishers
    @original_publisher = 'WAL01DBMER06', -- Current active node
    @publisher_db = 'SPProduction',
    @redirected_publisher = @redirected_publisher output;