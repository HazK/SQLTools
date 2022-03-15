SELECT  p.name AS [loginname] ,
        p.is_disabled,
		s.sysadmin,
		s.securityadmin,
		s.serveradmin,
		s.setupadmin,
		s.processadmin,
		s.diskadmin, 
		s.dbcreator,
		s.bulkadmin
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%'
