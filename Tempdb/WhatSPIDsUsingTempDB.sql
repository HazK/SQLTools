SELECT SU.session_id, 
sum (SU.internal_objects_alloc_page_count)/128  as session_internal_alloc,
sum (SU.internal_objects_dealloc_page_count)/128 as sesion_internal_dealloc, 
sum (SU.user_objects_alloc_page_count) as session_user_alloc,
sum (SU.user_objects_dealloc_page_count) as sesion_user_dealloc, 
sum (TS.internal_objects_alloc_page_count) as task_internal_alloc ,
sum (TS.internal_objects_dealloc_page_count) as task_internal_dealloc,
sum (TS.user_objects_alloc_page_count) as task_user_alloc ,
sum (TS.user_objects_dealloc_page_count) as task_user_dealloc
FROM sys.dm_db_session_space_usage SU
inner join sys.dm_db_task_space_usage TS
on SU.session_id = TS.session_id
where SU.session_id > 50    
GROUP BY SU.session_id
ORDER BY sum (SU.internal_objects_alloc_page_count) DESC