$guesses = 1..100| ForEach-Object {New-Guid}


ForEach($password in $guesses.Guid)
{

try{
$password
$sqlConn = New-Object System.Data.SqlClient.SqlConnection
$sqlConn.ConnectionString = “Server=sqlmirp01.public.ba0bcd32d86b.database.windows.net,3342;Integrated Security=false;User=sqladmin;Password=$password;Initial Catalog=TenantCRM; Application Name = pwshell002”
$sqlConn.Open()
}
Catch{
}

}