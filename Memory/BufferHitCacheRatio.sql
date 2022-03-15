DECLARE @NonBaseBufferRatio FLOAT
DECLARE @BaseBufferRatio FLOAT
DECLARE @BufferHitCacheRatio FLOAT

SET @NonBaseBufferRatio  = (

		SELECT 
			   cntr_value
		FROM sys.dm_os_performance_counters 
		WHERE
			object_name like 'SQLServer:Buffer Manager%'
			AND counter_name like 'Buffer cache hit ratio%'
			AND cntr_type = 537003264
		)
SET @BaseBufferRatio = (
		SELECT 
			   cntr_value
		FROM sys.dm_os_performance_counters 
		WHERE
			object_name like 'SQLServer:Buffer Manager%'
			AND counter_name like 'Buffer cache hit ratio%'
			AND cntr_type = 1073939712
		)

SET @BufferHitCacheRatio = @NonBaseBufferRatio / @BaseBufferRatio


SELECT		@@SERVERNAME Instance,
			object_name ,
			counter_name, 
			instance_name, 
			@BufferHitCacheRatio Ratio, 
			cntr_type,
			GETDATE() LoggedDate
	FROM sys.dm_os_performance_counters
	WHERE
		object_name like 'SQLServer:Buffer Manager%'
		AND counter_name like 'Buffer cache hit ratio%'
		AND cntr_type = 537003264