Get-SqlAgentJob -ServerInstance TravellerSQLCL

mkdir C:\PS\DWH
$Jobs = Get-DbaAgentJob -SqlInstance Wercovrdevsqld1 #| Export-DbaScript -Path 'C:\PS\DWH'

$Jobs |Export-DbaScript -Path C:\Tmp

Get-DbaAgentJobStep -SqlInstance wercovrdevsqld1

Get-DbaMaintenanceSolutionLog -SqlInstance DWH - -LogType IndexOptimize 


Get-DbaBackupInformation -SqlInstance BUSAPPS\BUSAPPS -Path \\VLOPVRSTOAPP01\SQLBackups_BusApps\BUSAPPS\ -Verbose |ogv




Install-DbaMaintenanceSolution -SqlInstance LTEAR06371 -Database DBAtoolKit -BackupLocation P:\BackupsTest -LogToTable Backup  -CleanupTime 48 -Solution IndexOptimize