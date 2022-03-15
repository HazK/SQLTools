-- GET CURRENT FILE DETS


USE master
GO
SELECT name AS LogicalFileName, physical_name AS FileLocation
, state_desc AS Status 
FROM sys.master_files 
WHERE database_id = DB_ID('AdventureWorks2012');

-- Take DB OFFLINE

GO
ALTER DATABASE AdventureWorks2012 SET OFFLINE WITH ROLLBACK IMMEDIATE
GO



-- PHYSICALLY MOVE THE FILES

-- DO THE SQL

ALTER DATABASE AdventureWorks2012
MODIFY FILE 
( NAME = AdventureWorks2012_Data, 
FILENAME = 'C:\Disk2\AdventureWorks2012_Data.mdf'); -- New file path
GO

-- SET DB ONLINE

USE master
GO
ALTER DATABASE AdventureWorks2012 SET ONLINE;
GO

-- VERFIY

SELECT name AS FileName, physical_name AS CurrentFileLocation, state_desc AS Status 
FROM sys.master_files 
WHERE database_id = DB_ID('AdventureWorks2012');