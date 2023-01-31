$user = "username"
$pass = "password"
$srv = "server-name"
$db = "db-name"

$emailSenderAddr = "scripts@domain.ru"
$emailTo = "login@domain.ru"
$emailSmtpServer = 'domain.ru'
$emailPassword = ConvertTo-SecureString -String "password" -AsPlainText -Force
$emailCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $emailSenderAddr, $emailPassword

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

[int32]$trigger_day_30 = 30
[int32]$trigger_day_14 = 14
[int32]$trigger_day_7  = 7
[int32]$trigger_day_3  = 3

$date = Get-Date -f "dd/MM/yyyy"
[DateTime]$gDate = Get-Date "$date"
foreach ($dates in $db_date) {
$mass_date = [string]$dates.Date
$mass_type = [string]$dates.Type
$mass_model = [string]$dates.Model
$mass_desc = [string]$dates.Description
[DateTime]$fDate = Get-Date "$mass_date"
[int32]$days=($fDate-$gDate).Days
if ($days -match "-") {
$day = $days -replace "-"
$text_out = "Название: $mass_type
Версия: $mass_model
Описание: $mass_desc
Срок доступа закончился: $mass_date ($day дней назад)
"
Send-MailMessage -From $emailSenderAddr -To $emailTo -Subject "IT-Invent" -Body $text_out –SmtpServer $emailSmtpServer -Encoding 'UTF8' -Credential $emailCred
} elseif (($days -eq $trigger_day_30) -or ($days -eq $trigger_day_14
) -or ($days -eq $trigger_day_7) -or ($days -eq $trigger_day_3)) {
$text_out = "Название: $mass_type
Версия: $mass_model
Описание: $mass_desc
Срок доступа истекает: $mass_date (через $days дней)
"
Send-MailMessage -From $emailSenderAddr -To $emailTo -Subject "IT-Invent" -Body $text_out –SmtpServer $emailSmtpServer -Encoding 'UTF8' -Credential $emailCred
}}