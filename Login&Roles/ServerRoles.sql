/* RUN ON WAL01DBACT01 */


DECLARE @ProcessTable TABLE
(Instance nvarchar(200),
Complete bit)

DECLARE @Tbl1 TABLE
(Instance nvarchar (200),
LoginName nvarchar (300),
TypeDesc nvarchar (200),
RoleName nvarchar (200),
RoleDesc nvarchar (200))

DECLARE @sql nvarchar(max)
DECLARE @sql2 nvarchar(300)
DECLARE @OpenQuery varchar(max)
DECLARE @NextServer nvarchar(200)
DECLARE @Close nvarchar(10)
DECLARE @ErrorMessage nvarchar(400)

/* Set SQL To Exec Here */
	SET @sql = '
	
	select @@SERVERNAME ServerName, p.name, p.type_desc, pp.name as name1, pp.type_desc typedesc1
	from  sys.server_role_members roles
	join sys.server_principals p on roles.member_principal_id = p.principal_id
	join sys.server_principals pp on roles.role_principal_id = pp.principal_id '



INSERT INTO @ProcessTable
	SELECT 
		InstanceName,
		0 
	FROM 
		dbadata.dbo.DBAMonitor_SupportedServers
	WHERE
		[Backup] = 1

WHILE EXISTS (SELECT 1 FROM @ProcessTable WHERE Complete = 0)

BEGIN
	SET @Close = ''')'
	SET @NextServer = (SELECT TOP 1 '[' + Instance + ']' FROM @ProcessTable WHERE Complete = 0)
	SET @OpenQuery = 'SELECT * FROM OPENQUERY('+ @NextServer + ','''

	INSERT INTO @Tbl1
	exec (@OPENQUERY + @sql + @Close)			
	UPDATE @ProcessTable SET Complete = 1 WHERE  '[' + Instance + ']' = @NextServer
END


SELECT * FROM @Tbl1