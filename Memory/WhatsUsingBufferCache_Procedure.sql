SELECT
	SUM(KB)/1024 As TotalProcCacheUseMB
FROM
(

SELECT  [text], 
		cp.objtype, 
		cp.size_in_bytes,
		cp.size_in_bytes / 1024 KB,
		(cp.size_in_bytes / 1024) / 1024 MB
FROM sys.dm_exec_cached_plans AS cp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
--WHERE cp.cacheobjtype = N'Compiled Plan'
--    AND cp.objtype IN(N'Adhoc', N'Prepared')

) p1

GO



SELECT  [text], 
		cp.objtype, 
		cp.size_in_bytes,
		cp.size_in_bytes / 1024 KB,
		(cp.size_in_bytes / 1024) / 1024 MB
FROM sys.dm_exec_cached_plans AS cp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st

ORDER BY cp.size_in_bytes DESC
OPTION (RECOMPILE);
