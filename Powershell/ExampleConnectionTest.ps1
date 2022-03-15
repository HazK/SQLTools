
$SQLServer = "DEV03DBMER01DEV" #use Server\Instance for named SQL instances! 
$SQLDBName = "1stTouch_DEV01"
$SqlQuery = "SELECT 'I can Connect' FROM msdb.dbo.sysjobs"
 
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"
 
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
 
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
 
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
 
$SqlConnection.Close()
 
clear
 
$DataSet.Tables[0]