SET nocount ON; 

DECLARE @SearchString VARCHAR(205) 

-------------------------------------------------------------- 
--SET PARAMETERS HERE FOR SPECIFIC SEARCH SQL DEFINITIONS 
-------------------------------------------------------------- 
SET @SearchString = '%DivisionID%' 

-------------------------------------------------------------- 
SELECT NAME 
FROM   sysobjects 
WHERE  id IN (SELECT id 
              FROM   syscomments 
              WHERE  text LIKE @SearchString) 
ORDER  BY NAME  