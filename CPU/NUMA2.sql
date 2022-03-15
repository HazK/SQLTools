SELECT parent_node_id, 
  SUM(current_tasks_count) AS [current_tasks_count], 
  SUM(runnable_tasks_count) AS [runnable_tasks_count], 
  SUM(active_workers_count) AS [active_workers_count], 
  AVG(load_factor) AS avg_load_factor
FROM sys.dm_os_schedulers WITH (NOLOCK) 
WHERE [status] = N'VISIBLE ONLINE'
GROUP BY parent_node_id;

SELECT parent_node_id, scheduler_id, cpu_id
FROM sys.dm_os_schedulers WITH (NOLOCK) 
WHERE [status] = N'VISIBLE ONLINE';


SELECT COUNT(Distinct Parent_node_id) FROM sys.dm_os_schedulers WHERE [STATUS] = 'VISIBLE ONLINE' AND Parent_node_ID < 64