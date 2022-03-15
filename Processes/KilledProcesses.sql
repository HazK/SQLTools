
EXEC sys.xp_readerrorlog 0,1,'kill'

select login_name,* from sys.dm_exec_sessions where host_process_id = '30224'