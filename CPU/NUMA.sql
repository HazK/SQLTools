

-- hand in hand with http://sqlperformance.com/2012/11/system-configuration/2012-cal-problems


SELECT 
  parent_node_id,
  scheduler_id, 
  [cpu_id], 
  is_idle, 
  current_tasks_count, 
  runnable_tasks_count, 
  active_workers_count, 
  load_factor
FROM sys.dm_os_schedulers
WHERE [status] = N'VISIBLE ONLINE';



SELECT 
  parent_node_id, 
  SUM(current_tasks_count) AS current_tasks_count, 
  SUM(runnable_tasks_count) AS runnable_tasks_count, 
  SUM(active_workers_count) AS active_workers_count, 
  AVG(load_factor) AS avg_load_factor
FROM sys.dm_os_schedulers
WHERE [status] = N'VISIBLE ONLINE'
GROUP BY parent_node_id;
