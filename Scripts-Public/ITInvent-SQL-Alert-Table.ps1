$user = "username"
$pass = "password"
$srv = "server-name"
$db = "db-name"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "server=$srv;database=$db;user id=$user;password=$pass;Integrated Security=false"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand

$table_type = "SELECT TYPE_NO,TYPE_NAME FROM ITINVENT.dbo.CI_TYPES where CI_TYPE like '2'"
$SqlCmd.CommandText = $table_type
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$db_type = $DataSet.Tables[0] | select @{Label="Num"; Expression={$_.TYPE_NO}},@{Label="Type"; Expression={$_.TYPE_NAME}}

$table_model = "SELECT MODEL_NO,MODEL_NAME FROM ITINVENT.dbo.CI_MODELS where CI_TYPE like '2'"
$SqlCmd.CommandText = $table_model
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$db_model = $DataSet.Tables[0] | select @{Label="Num"; Expression={$_.MODEL_NO}},@{Label="Model"; Expression={$_.MODEL_NAME}}

$table_date = "SELECT LICENCE_DATE,DESCR,MODEL_NO,TYPE_NO FROM ITINVENT.dbo.ITEMS where LICENCE_DATE IS NOT NULL"
$SqlCmd.CommandText = $table_date
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$db_date = $DataSet.Tables[0] | select @{Label="Date"; Expression={$_.LICENCE_DATE -replace " 0:00:00"}
},@{Label="Type"; Expression={($db_type -match $_.TYPE_NO).Type}},@{
Label="Model"; Expression={($db_model -match $_.MODEL_NO).Model}},@{
Label="Description"; Expression={$_.DESCR}}

$SqlConnection.Close()

$db_date | Out-GridView
pause