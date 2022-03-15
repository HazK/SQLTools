
/*
HK MAXDOP Base Recommendation

AS per MS articles:
https://support.microsoft.com/en-us/kb/2806535/en-us
https://support.microsoft.com/en-us/kb/322385

Assumptions:

Hyperthreading ratio is 2:1

Instructions: Set @HyperThreadingEnabled. You'll need to find if hyperthreading is enabled out of SQL

*/


SET NOCOUNT ON
DECLARE @Staging TABLE
(Name nvarchar(100),minimum int, maxiumum int,config_value int,run_value int)
DECLARE @HyperThreadingEnabled int
DECLARE @HyperThreadRatio int
DECLARE @LogicalCPUS int
DECLARE @PhysicalCPUs int
DECLARE @LogicalCPUsPerNuma int
DECLARE @NumberOfNUMA int
DECLARE @RecommendedMAXDOP int
DECLARE @CurrentMAXDOP int
DECLARE @Message nvarchar(200)

SET @HyperThreadingEnabled = 3
   -- <<<<<<<<<<<<<<<<<<<<<<<< SET ME !!!


SET @Message = 'Hyperthreading value not set correctly, 1 = yes, 0 = no - ABORTING'
IF @HyperThreadingEnabled =3
BEGIN
RAISERROR(@Message,1,1)
RETURN
END

INSERT INTO @Staging
EXEC sp_configure 'max degree of parallelism'

SET @CurrentMAXDOP = ( SELECT run_value FROM @Staging)


SET @LogicalCPUs = (SELECT cpu_Count FROM sys.dm_os_sys_info)
IF @HyperThreadingEnabled = 1
		SET @PhysicalCPUs = (@LogicalCPUS / 2)
	ELSE IF @HyperThreadingEnabled = 0
		SET @PhysicalCPUs = @LogicalCPUs


SET @LogicalCPUsPerNuma = (SELECT MAX(MaxCount) FROM (SELECT COUNT(Parent_Node_ID) MaxCount FROM sys.dm_os_schedulers WHERE [STATUS] = 'VISIBLE ONLINE' AND Parent_node_ID < 64 GROUP BY Parent_node_ID) p1)
SET @NumberOfNUMA = (SELECT COUNT(Distinct Parent_node_id) FROM sys.dm_os_schedulers WHERE [STATUS] = 'VISIBLE ONLINE' AND Parent_node_ID < 64)

IF @NumberOfNUMA > 1 AND @HyperThreadingEnabled = 0 -- Server With Multiple NUMA Nodes without hyperthreading, i.e. all phyiscal
	BEGIN
	SET @RecommendedMAXDOP = @LogicalCPUsPerNuma
	SET @Message = 'Multiple NUMAs - No hyperthreading - MAXDOP should be set to the maximum number of physical CPUs within a NUMA to avoid cross NUMA resource contention'
	END
ELSE IF @NumberOfNumA > 1 AND @HyperThreadingEnabled = 1 -- Server with multiple NUMA nodes with hyperthreading enabled
	BEGIN
	SET @RecommendedMAXDOP = ROUND(@PhysicalCPUs/@NumberOfNumA * 1.0,0)
	SET @Message = 'Multiple NUMAs - Hyperthreading enabled - MAXDOP should be set to the maximum number of physical CPUs within a NUMA to avoid cross NUMA resource contention'
	END
ELSE IF @HyperThreadingEnabled = 0 -- No hyperthreading single numa. Use all processors
	BEGIN
	SET @RecommendedMAXDOP = @LogicalCPUS
	SET @Message = 'No NUMA - No Hyperthreading - MAXDOP should be set to the number of physical CPUs available'
	END
ELSE IF @HyperThreadingEnabled = 1 -- Hyperthreading single numa. Only use the physical processors
	BEGIN
	SET @RecommendedMAXDOP = @PhysicalCPUs
	SET @Message = 'No NUMA - Hyperthreading enabled - MAXDOP should be set to the number of physical CPUs not logical CPUs available'
	END

IF @RecommendedMAXDOP > 8 SET @RecommendedMAXDOP = 8


PRINT ' ***** THE HEADLINES ***** '
PRINT ' '
PRINT 'Recommended MAXDOP from above calculations = ' + CONVERT(nvarchar,@RecommendedMAXDOP) + '. This for the following reason: ' + @Message
PRINT 'Current MAXDOP is set to : ' + CONVERT(nvarchar,@CurrentMAXDOP)
PRINT ' '
PRINT ' '
PRINT ' ***** THE INFO ***** '
PRINT ' '

PRINT 'Number of NUMAs = ' + CONVERT(nvarchar,@NumberOfNUMA)
PRINT 'Number of Logical CPUS = ' +  CONVERT(nvarchar,@LogicalCPUS)
PRINT 'Number of Physical CPUS = ' +  CONVERT(nvarchar,@PhysicalCPUs) 
PRINT 'HyperthreadingEnabled = ' + CONVERT(nvarchar,@HyperThreadingEnabled) 


