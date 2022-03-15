-- sid from sys.server_principles and sys.database_principles mismatch for login/user

exec sp_change_users_login 'report' -- on db with issue. this will show orphaned user
exec sp_change_users_login 'Auto_Fix', 'TraceLogUser' -- Autofix

SELECT * FROM sys.server_principals
SELECT * FROM sys.database_principals


-- if above doesnt work to fix find the ssid of the user, this needs to match the login. If it does not the login needs dropping and creating with correct sid

drop login YourLogin;
go

create login YourLogin
with
    password = 'password',
    check_policy = off,     -- simple password and no check policy for example only
    sid = 0xC26909...................; -- user ssid
go

