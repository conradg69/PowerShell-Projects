#$LastRunDate = (get-date).AddMinutes(-60)
$LastRunDate.GetType()
$results = Invoke-Sqlcmd -ServerInstance LTEAR06371 -Database DBAdmin -Query "SELECT MAX(date) FROM dbo.SqlErrorLogs" 

$lastRunDate = $results[0][0]



Get-SqlErrorLog -ServerInstance LTEAR06371  -after $LastRunDate | Write-SqlTableData -serverinstance LTEAR06371 -DatabaseName DBAdmin -SchemaName dbo -TableName SqlErrorLogs -Force
