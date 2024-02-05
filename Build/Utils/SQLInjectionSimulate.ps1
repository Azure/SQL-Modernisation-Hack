
$value =" ' or 1 = 1 UNION SELECT @@VERSION ;--"

$sqlConn = New-Object System.Data.SqlClient.SqlConnection
$sqlConn.ConnectionString = “Server=sqlmirp01.public.ba0bcd32d86b.database.windows.net,3342;Integrated Security=false;User=sqladmin;Password=xxxxx;Initial Catalog=DB02; Application Name = pwshell002”
$sqlConn.Open()

$sqlcmd = $sqlConn.CreateCommand()
$sqlcmd = New-Object System.Data.SqlClient.SqlCommand
$sqlcmd.Connection = $sqlConn
$query = “SELECT top 10 name FROM sys.databases WHERE database_id like '$value' ”
$query ="SELECT TOP (10) [DatabaseUser] FROM [dbo].[DatabaseLog] where DatabaseLogID like '$value' ”
$sqlcmd.CommandText = $query
$adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
$data = New-Object System.Data.DataSet
$adp.Fill($data) | Out-Null
$data.Tables
$data.Tables[0]

 

$sqlConn.Close()