IF OBJECT_ID('dbo.sp_BlitzWho') IS NULL
	EXEC ('CREATE PROCEDURE dbo.sp_BlitzWho AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_BlitzWho] 
	@Help TINYINT = 0 ,
	@ShowSleepingSPIDs TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @Help = 1
		PRINT '
sp_BlitzWho from http://FirstResponderKit.org

This script gives you a snapshot of everything currently executing on your SQL Server.

To learn more, visit http://FirstResponderKit.org where you can download new
versions for free, watch training videos on how it works, get more info on
the findings, contribute your own code, and more.

Known limitations of this version:
 - Only Microsoft-supported versions of SQL Server. Sorry, 2005 and 2000.
   
MIT License

Copyright (c) 2016 Brent Ozar Unlimited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
';

/* Get the major and minor build numbers */
DECLARE  @ProductVersion NVARCHAR(128)
		,@ProductVersionMajor DECIMAL(10,2)
		,@ProductVersionMinor DECIMAL(10,2)
		,@EnhanceFlag BIT = 0
		,@StringToExecute NVARCHAR(MAX)
		,@EnhanceSQL NVARCHAR(MAX) = 
					N'[query_stats].last_dop,
					  [query_stats].min_dop,
					  [query_stats].max_dop,
					  [query_stats].last_grant_kb,
					  [query_stats].min_grant_kb,
					  [query_stats].max_grant_kb,
					  [query_stats].last_used_grant_kb,
					  [query_stats].min_used_grant_kb,
					  [query_stats].max_used_grant_kb,
					  [query_stats].last_ideal_grant_kb,
					  [query_stats].min_ideal_grant_kb,
					  [query_stats].max_ideal_grant_kb,
					  [query_stats].last_reserved_threads,
					  [query_stats].min_reserved_threads,
					  [query_stats].max_reserved_threads,
					  [query_stats].last_used_threads,
					  [query_stats].min_used_threads,
					  [query_stats].max_used_threads,'

SET @ProductVersion = CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128));
SELECT @ProductVersionMajor = SUBSTRING(@ProductVersion, 1,CHARINDEX('.', @ProductVersion) + 1 ),
@ProductVersionMinor = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 2)



IF @ProductVersionMajor > 9 and @ProductVersionMajor < 11
BEGIN
SET @StringToExecute = N'
					    SELECT  GETDATE() AS [run_date] ,
			            CONVERT(VARCHAR, DATEADD(ms, [r].[total_elapsed_time], 0), 114) AS [elapsed_time] ,
			            [s].[session_id] ,
						DB_NAME(r.database_id) AS database_name,
			            [wt].[wait_info] ,
			            [s].[status] ,
			            ISNULL(SUBSTRING([dest].[text],
			                             ( [query_stats].[statement_start_offset] / 2 ) + 1,
			                             ( ( CASE [query_stats].[statement_end_offset]
			                                   WHEN -1 THEN DATALENGTH([dest].[text])
			                                   ELSE [query_stats].[statement_end_offset]
			                                 END - [query_stats].[statement_start_offset] )
			                               / 2 ) + 1), [dest].[text]) AS [query_text] ,
			            [derp].[query_plan] ,
			            [qmg].[query_cost] ,
					    [r].[blocking_session_id] ,
			            [r].[cpu_time] AS [request_cpu_time],
			            [r].[logical_reads] AS [request_logical_reads],
			            [r].[writes] AS [request_writes],
			            [r].[reads] AS [request_physical_reads] ,
			            [s].[cpu_time] AS [session_cpu],
			            [s].[logical_reads] AS [session_logical_reads],
			            [s].[reads] AS [session_physical_reads] ,
			            [s].[writes] AS [session_writes],
			            [s].[memory_usage] ,
			            [r].[estimated_completion_time] ,
			            [r].[deadlock_priority] ,
			            CASE 
			              WHEN [s].[transaction_isolation_level] = 0 THEN ''Unspecified''
			              WHEN [s].[transaction_isolation_level] = 1 THEN ''Read Uncommitted''
			              WHEN [s].[transaction_isolation_level] = 2 AND EXISTS (SELECT 1 FROM [sys].[dm_tran_active_snapshot_database_transactions] AS [trn] WHERE [s].[session_id] = [trn].[session_id] AND [is_snapshot] = 0 ) THEN ''Read Committed Snapshot Isolation''
						  WHEN [s].[transaction_isolation_level] = 2 AND NOT EXISTS (SELECT 1 FROM [sys].[dm_tran_active_snapshot_database_transactions] AS [trn] WHERE [s].[session_id] = [trn].[session_id] AND [is_snapshot] = 0 ) THEN ''Read Committed''
			              WHEN [s].[transaction_isolation_level] = 3 THEN ''Repeatable Read''
			              WHEN [s].[transaction_isolation_level] = 4 THEN ''Serializable''
			              WHEN [s].[transaction_isolation_level] = 5 THEN ''Snapshot''
			              ELSE ''WHAT HAVE YOU DONE?''
			            END AS [transaction_isolation_level] ,
			            [r].[open_transaction_count] ,
			            [qmg].[dop] AS [degree_of_parallelism] ,
			            [qmg].[request_time] ,
			            COALESCE(CAST([qmg].[grant_time] AS VARCHAR), ''N/A'') AS [grant_time] ,
			            [qmg].[requested_memory_kb] ,
			            [qmg].[granted_memory_kb] AS [grant_memory_kb],
			            CASE WHEN [qmg].[grant_time] IS NULL THEN ''N/A''
                             WHEN [qmg].[requested_memory_kb] < [qmg].[granted_memory_kb]
			                 THEN ''Query Granted Less Than Query Requested''
			                 ELSE ''Memory Request Granted''
			            END AS [is_request_granted] ,
			            [qmg].[required_memory_kb] ,
			            [qmg].[used_memory_kb] ,
			            [qmg].[ideal_memory_kb] ,
			            [qmg].[is_small] ,
			            [qmg].[timeout_sec] ,
			            [qmg].[resource_semaphore_id] ,
			            COALESCE(CAST([qmg].[wait_order] AS VARCHAR), ''N/A'') AS [wait_order] ,
			            COALESCE(CAST([qmg].[wait_time_ms] AS VARCHAR),
			                     ''N/A'') AS [wait_time_ms] ,
			            CASE [qmg].[is_next_candidate]
			              WHEN 0 THEN ''No''
			              WHEN 1 THEN ''Yes''
			              ELSE ''N/A''
			            END AS [next_candidate_for_memory_grant] ,
			            [qrs].[target_memory_kb] ,
			            COALESCE(CAST([qrs].[max_target_memory_kb] AS VARCHAR),
			                     ''Small Query Resource Semaphore'') AS [max_target_memory_kb] ,
			            [qrs].[total_memory_kb] ,
			            [qrs].[available_memory_kb] ,
			            [qrs].[granted_memory_kb] ,
			            [qrs].[used_memory_kb] ,
			            [qrs].[grantee_count] ,
			            [qrs].[waiter_count] ,
			            [qrs].[timeout_error_count] ,
			            COALESCE(CAST([qrs].[forced_grant_count] AS VARCHAR),
			                     ''Small Query Resource Semaphore'') AS [forced_grant_count],
					    [s].[nt_domain] ,
			            [s].[host_name] ,
			            [s].[login_name] ,
			            [s].[nt_user_name] ,
			            [s].[program_name] ,
			            [s].[client_interface_name] ,
			            [s].[login_time] ,
			            [r].[start_time] 
			    FROM    [sys].[dm_exec_sessions] AS [s]
			    INNER JOIN    [sys].[dm_exec_requests] AS [r]
			    ON      [r].[session_id] = [s].[session_id]
			    LEFT JOIN ( SELECT DISTINCT
			                        [wait].[session_id] ,
			                        ( SELECT    [waitwait].[wait_type] + N'' (''
			                                    + CAST(SUM([waitwait].[wait_duration_ms]) AS NVARCHAR(128))
			                                    + N'' ms) ''
			                          FROM      [sys].[dm_os_waiting_tasks] AS [waitwait]
			                          WHERE     [waitwait].[session_id] = [wait].[session_id]
			                          GROUP BY  [waitwait].[wait_type]
			                          ORDER BY  SUM([waitwait].[wait_duration_ms]) DESC
			                        FOR
			                          XML PATH('''') ) AS [wait_info]
			                FROM    [sys].[dm_os_waiting_tasks] AS [wait] ) AS [wt]
			    ON      [s].[session_id] = [wt].[session_id]
			    LEFT JOIN [sys].[dm_exec_query_stats] AS [query_stats]
			    ON      [r].[sql_handle] = [query_stats].[sql_handle]
						AND [r].[plan_handle] = [query_stats].[plan_handle]
			            AND [r].[statement_start_offset] = [query_stats].[statement_start_offset]
			            AND [r].[statement_end_offset] = [query_stats].[statement_end_offset]
			    LEFT JOIN [sys].[dm_exec_query_memory_grants] [qmg]
			    ON      [r].[session_id] = [qmg].[session_id]
						AND [r].[request_id] = [qmg].[request_id]
			    LEFT JOIN [sys].[dm_exec_query_resource_semaphores] [qrs]
			    ON      [qmg].[resource_semaphore_id] = [qrs].[resource_semaphore_id]
					    AND [qmg].[pool_id] = [qrs].[pool_id]
			    OUTER APPLY [sys].[dm_exec_sql_text]([r].[sql_handle]) AS [dest]
			    OUTER APPLY [sys].[dm_exec_query_plan]([r].[plan_handle]) AS [derp]
			    WHERE   [r].[session_id] <> @@SPID
			            AND (([s].[status] <> ''sleeping'' AND ' + CONVERT(NVARCHAR(1), @ShowSleepingSPIDs) + ' = 0) OR ' + CONVERT(NVARCHAR(1), @ShowSleepingSPIDs) + ' = 1)
			    ORDER BY 2 DESC;
			    '
END
IF @ProductVersionMajor >= 11 
BEGIN
SELECT @EnhanceFlag = 
	    CASE WHEN @ProductVersionMajor = 11 AND @ProductVersionMinor >= 6020 THEN 1
		     WHEN @ProductVersionMajor = 12 AND @ProductVersionMinor >= 5000 THEN 1
		     WHEN @ProductVersionMajor = 13 AND	@ProductVersionMinor >= 1601 THEN 1
		     ELSE 0 
	    END

SELECT @StringToExecute = N'
					    SELECT  GETDATE() AS [run_date] ,
			            CONVERT(VARCHAR, DATEADD(ms, [r].[total_elapsed_time], 0), 114) AS [elapsed_time] ,
			            [s].[session_id] ,
						DB_NAME(r.database_id) AS database_name,
			            [wt].[wait_info] ,
			            [s].[status] ,
			            ISNULL(SUBSTRING([dest].[text],
			                             ( [query_stats].[statement_start_offset] / 2 ) + 1,
			                             ( ( CASE [query_stats].[statement_end_offset]
			                                   WHEN -1 THEN DATALENGTH([dest].[text])
			                                   ELSE [query_stats].[statement_end_offset]
			                                 END - [query_stats].[statement_start_offset] )
			                               / 2 ) + 1), [dest].[text]) AS [query_text] ,
			            [derp].[query_plan] ,
			            [qmg].[query_cost] ,
					    [r].[blocking_session_id] ,
			            [r].[cpu_time] AS [request_cpu_time],
			            [r].[logical_reads] AS [request_logical_reads],
			            [r].[writes] AS [request_writes],
			            [r].[reads] AS [request_physical_reads] ,
			            [s].[cpu_time] AS [session_cpu],
			            [s].[logical_reads] AS [session_logical_reads],
			            [s].[reads] AS [session_physical_reads] ,
			            [s].[writes] AS [session_writes],
			            [s].[memory_usage] ,
			            [r].[estimated_completion_time] ,
			            [r].[deadlock_priority] ,'
					    + 
					    CASE @EnhanceFlag
					    WHEN 1 THEN @EnhanceSQL
					    ELSE N'' END +
					    N'CASE 
			              WHEN [s].[transaction_isolation_level] = 0 THEN ''Unspecified''
			              WHEN [s].[transaction_isolation_level] = 1 THEN ''Read Uncommitted''
			              WHEN [s].[transaction_isolation_level] = 2 AND EXISTS (SELECT 1 FROM [sys].[dm_tran_active_snapshot_database_transactions] AS [trn] WHERE [s].[session_id] = [trn].[session_id] AND [is_snapshot] = 0 ) THEN ''Read Committed Snapshot Isolation''
						  WHEN [s].[transaction_isolation_level] = 2 AND NOT EXISTS (SELECT 1 FROM [sys].[dm_tran_active_snapshot_database_transactions] AS [trn] WHERE [s].[session_id] = [trn].[session_id] AND [is_snapshot] = 0 ) THEN ''Read Committed''
			              WHEN [s].[transaction_isolation_level] = 3 THEN ''Repeatable Read''
			              WHEN [s].[transaction_isolation_level] = 4 THEN ''Serializable''
			              WHEN [s].[transaction_isolation_level] = 5 THEN ''Snapshot''
			              ELSE ''WHAT HAVE YOU DONE?''
			            END AS [transaction_isolation_level] ,
			            [r].[open_transaction_count] ,
			            [qmg].[dop] AS [degree_of_parallelism] ,
			            [qmg].[request_time] ,
			            COALESCE(CAST([qmg].[grant_time] AS VARCHAR), ''Memory Not Granted'') AS [grant_time] ,
			            [qmg].[requested_memory_kb] ,
			            [qmg].[granted_memory_kb] AS [grant_memory_kb],
			            CASE WHEN [qmg].[grant_time] IS NULL THEN ''N/A''
                             WHEN [qmg].[requested_memory_kb] < [qmg].[granted_memory_kb]
			                 THEN ''Query Granted Less Than Query Requested''
			                 ELSE ''Memory Request Granted''
			            END AS [is_request_granted] ,
			            [qmg].[required_memory_kb] ,
			            [qmg].[used_memory_kb] ,
			            [qmg].[ideal_memory_kb] ,
			            [qmg].[is_small] ,
			            [qmg].[timeout_sec] ,
			            [qmg].[resource_semaphore_id] ,
			            COALESCE(CAST([qmg].[wait_order] AS VARCHAR), ''N/A'') AS [wait_order] ,
			            COALESCE(CAST([qmg].[wait_time_ms] AS VARCHAR),
			                     ''N/A'') AS [wait_time_ms] ,
			            CASE [qmg].[is_next_candidate]
			              WHEN 0 THEN ''No''
			              WHEN 1 THEN ''Yes''
			              ELSE ''N/A''
			            END AS [next_candidate_for_memory_grant] ,
			            [qrs].[target_memory_kb] ,
			            COALESCE(CAST([qrs].[max_target_memory_kb] AS VARCHAR),
			                     ''Small Query Resource Semaphore'') AS [max_target_memory_kb] ,
			            [qrs].[total_memory_kb] ,
			            [qrs].[available_memory_kb] ,
			            [qrs].[granted_memory_kb] ,
			            [qrs].[used_memory_kb] ,
			            [qrs].[grantee_count] ,
			            [qrs].[waiter_count] ,
			            [qrs].[timeout_error_count] ,
			            COALESCE(CAST([qrs].[forced_grant_count] AS VARCHAR),
			                     ''Small Query Resource Semaphore'') AS [forced_grant_count],
					    [s].[nt_domain] ,
			            [s].[host_name] ,
			            [s].[login_name] ,
			            [s].[nt_user_name] ,
			            [s].[program_name] ,
			            [s].[client_interface_name] ,
			            [s].[login_time] ,
			            [r].[start_time] 
			    FROM    [sys].[dm_exec_sessions] AS [s]
			    INNER JOIN    [sys].[dm_exec_requests] AS [r]
			    ON      [r].[session_id] = [s].[session_id]
			    LEFT JOIN ( SELECT DISTINCT
			                        [wait].[session_id] ,
			                        ( SELECT    [waitwait].[wait_type] + N'' (''
			                                    + CAST(SUM([waitwait].[wait_duration_ms]) AS NVARCHAR(128))
			                                    + N'' ms) ''
			                          FROM      [sys].[dm_os_waiting_tasks] AS [waitwait]
			                          WHERE     [waitwait].[session_id] = [wait].[session_id]
			                          GROUP BY  [waitwait].[wait_type]
			                          ORDER BY  SUM([waitwait].[wait_duration_ms]) DESC
			                        FOR
			                          XML PATH('''') ) AS [wait_info]
			                FROM    [sys].[dm_os_waiting_tasks] AS [wait] ) AS [wt]
			    ON      [s].[session_id] = [wt].[session_id]
			    LEFT JOIN [sys].[dm_exec_query_stats] AS [query_stats]
			    ON      [r].[sql_handle] = [query_stats].[sql_handle]
						AND [r].[plan_handle] = [query_stats].[plan_handle]
			            AND [r].[statement_start_offset] = [query_stats].[statement_start_offset]
			            AND [r].[statement_end_offset] = [query_stats].[statement_end_offset]
			    LEFT JOIN [sys].[dm_exec_query_memory_grants] [qmg]
			    ON      [r].[session_id] = [qmg].[session_id]
						AND [r].[request_id] = [qmg].[request_id]
			    LEFT JOIN [sys].[dm_exec_query_resource_semaphores] [qrs]
			    ON      [qmg].[resource_semaphore_id] = [qrs].[resource_semaphore_id]
					    AND [qmg].[pool_id] = [qrs].[pool_id]
			    OUTER APPLY [sys].[dm_exec_sql_text]([r].[sql_handle]) AS [dest]
			    OUTER APPLY [sys].[dm_exec_query_plan]([r].[plan_handle]) AS [derp]
			    WHERE   [r].[session_id] <> @@SPID
			            AND (([s].[status] <> ''sleeping'' AND ' + CONVERT(NVARCHAR(1), @ShowSleepingSPIDs) + ' = 0) OR ' + CONVERT(NVARCHAR(1), @ShowSleepingSPIDs) + ' = 1)
			    ORDER BY 2 DESC;
			    '

END 

EXEC(@StringToExecute);

END
