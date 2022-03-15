-- Blocked Queries
		SELECT session_id ,status ,blocking_session_id
			,wait_type ,wait_time ,wait_resource 
			,transaction_id,text, plan_handle
		FROM sys.dm_exec_requests 
			CROSS APPLY sys.dm_exec_sql_text (sql_handle)
		WHERE status = N'suspended';
