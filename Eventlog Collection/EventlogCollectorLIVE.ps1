#Get the last runtime for all environments
$resultsDWH1 = Invoke-Sqlcmd2 -ServerInstance LTEAR06371 -Database DBAdmin -Query 'SELECT MAX(TimeGenerated) FROM [DBAdmin].[dbo].[PS_WindowsLogsLIVE] where MachineName like ''VLOPVRDWHSQL01%''';
$resultsDWH2 = Invoke-Sqlcmd2 -ServerInstance LTEAR06371 -Database DBAdmin -Query 'SELECT MAX(TimeGenerated) FROM [DBAdmin].[dbo].[PS_WindowsLogsLIVE] where MachineName like ''VLOPVRDWHSQL02%''';
$resultsTravellerNode1 = Invoke-Sqlcmd2 -ServerInstance LTEAR06371 -Database DBAdmin -Query 'SELECT MAX(TimeGenerated) FROM [DBAdmin].[dbo].[PS_WindowsLogsLIVE] where MachineName like ''VLOPVRTRASQL01%''';
$resultsTravellerNode2 = Invoke-Sqlcmd2 -ServerInstance LTEAR06371 -Database DBAdmin -Query 'SELECT MAX(TimeGenerated) FROM [DBAdmin].[dbo].[PS_WindowsLogsLIVE] where MachineName like ''VLOPVRTRASQL02%''';
#$resultsQAE = Invoke-Sqlcmd2 -ServerInstance Wercovrdevsqld1 -Database DBAdmin -Query 'SELECT MAX(TimeGenerated) FROM [DBAdmin].[dbo].[PS_WindowsLogs] where MachineName like ''wercovrqaesqld1%'''; 
#$resultsUAT = Invoke-Sqlcmd2 -ServerInstance Wercovrdevsqld1 -Database DBAdmin -Query 'SELECT MAX(TimeGenerated) FROM [DBAdmin].[dbo].[PS_WindowsLogs] where MachineName like ''wercovruatsqld1%''';  
$DWHlastRunDate = $resultsDWH1[0][0];
$DWH2lastRunDate = $resultsDWH2[0][0];
$TravellerNode1lastRunDate = $resultsTravellerNode1[0][0];
$TravellerNode2lastRunDate = $resultsTravellerNode2[0][0];

#Write-Host Dates Updated
#Copy all event from the Application log to the the databases
#Get-EventLog -ComputerName DWH -LogName Application -After $DWHlastRunDate |ConvertTo-DbaDataTable |Write-DbaDataTable -SqlInstance LTEAR06371 -Database DBAdmin -Table PS_WindowsLogsLIVE -AutoCreateTable
#Write-Host DWH Completed
#Get-EventLog -ComputerName Wercovruatsqld1 -LogName Application -After $UATlastRunDate |ConvertTo-DbaDataTable |Write-DbaDataTable -SqlInstance Wercovrdevsqld1 -Database DBAdmin -Table PS_WindowsLogs -AutoCreateTable
#Write-Host UAT Completed
#Get-EventLog -ComputerName Wercovrdevsqld1 -LogName Application -After $DEVlastRunDate |ConvertTo-DbaDataTable |Write-DbaDataTable -SqlInstance Wercovrdevsqld1 -Database DBAdmin -Table PS_WindowsLogs -AutoCreateTable
#Write-Host Dev Completed

Get-EventLog -ComputerName VLOPVRDWHSQL01 -LogName Application -After $DWHlastRunDate -Verbose |ConvertTo-DbaDataTable |Write-DbaDataTable -SqlInstance LTEAR06371 -Database DBAdmin -Table PS_WindowsLogsLIVE -AutoCreateTable -Verbose
Get-EventLog -ComputerName VLOPVRDWHSQL02 -LogName Application -After $DWH2lastRunDate -verbose |ConvertTo-DbaDataTable |Write-DbaDataTable -SqlInstance LTEAR06371 -Database DBAdmin -Table PS_WindowsLogsLIVE -AutoCreateTable -verbose

Get-EventLog -ComputerName VLOPVRTRASQL01 -LogName Application -After $TravellerNode1lastRunDate -Verbose  |ConvertTo-DbaDataTable |Write-DbaDataTable -SqlInstance LTEAR06371 -Database DBAdmin -Table PS_WindowsLogsLIVE -AutoCreateTable -verbose
Get-EventLog -ComputerName VLOPVRTRASQL02 -LogName Application -After $TravellerNode2lastRunDate -Verbose  |ConvertTo-DbaDataTable |Write-DbaDataTable -SqlInstance LTEAR06371 -Database DBAdmin -Table PS_WindowsLogsLIVE -AutoCreateTable -verbose
