EXEC sp_ReadErrorLog 1
– Reads SQL Server error log from ERRORLOG.1 file
 
EXEC sp_ReadErrorLog 0, 1
– Reads current SQL Server error log
 
EXEC sp_ReadErrorLog 0, 2
– Reads current SQL Server Agent error log
 
EXEC sp_ReadErrorLog 0, 1, 'Failed'
– Reads current SQL Server error log with text 'Failed'
 
EXEC sp_ReadErrorLog 0, 1, 'Failed', 'Login'
– Reads current SQL Server error log with text ‘Failed’ AND 'Login'
 
EXEC sp_ReadErrorLog 0, 1, 'Failed', 'Login', '20121101', NULL
– Reads current SQL Server error log with text ‘Failed’ AND ‘Login’ from 01-Nov-2012
 
EXEC sp_ReadErrorLog 0, 1, 'Failed', 'Login', '20121101', '20121130'
– Reads current SQL Server error log with text ‘Failed’ AND ‘Login’ between 01-Nov-2012 and 30-Nov-2012
 
EXEC sp_ReadErrorLog 0, 1, NULL, NULL, '20121101', '20121130'
– Reads current SQL Server error between 01-Nov-2012 and 30-Nov-2012
 
EXEC sp_ReadErrorLog 0, 1, NULL, NULL, '20121101', '20121130', 'DESC'
– Reads current SQL Server error log between 01-Nov-2012 and 30-Nov-2012 and sorts in descending order