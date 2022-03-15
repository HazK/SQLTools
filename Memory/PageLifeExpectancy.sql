SELECT @@SERVERNAME INSTANCE, object_name, counter_name, instance_name, cntr_value, cntr_type, GETDATE()LoggedDate
FROM sys.dm_os_performance_counters
WHERE
	object_name like 'SQLServer:Buffer Manager%'
	AND Counter_Name like  'Page life expectancy%'