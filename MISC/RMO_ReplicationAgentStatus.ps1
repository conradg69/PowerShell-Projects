#Execution Script

$AgentStatus=Read-Host "What you want to Montior [L]Logreader,[D] Distributor and [S]snapshot Agent?:"
$RefreshTimings=Read-Host "Refresh Rate (seconds):"

for(;;) {
try {
CLs
Write-Host "******************************************************************"
Write-Host "Monitoring " $AgentStatus
$Command= "C:\Users\conradgauntlett\Box Sync\Work Directory\P\Powershell\RMO_ReplicationAgentStatus2.ps1" +" "+ $AgentStatus
Write-Host ""

Invoke-Expression $Command
}
catch
{

}
Write-Host "Script will execute every " $RefreshTimings " secs"
Start-Sleep -Seconds $RefreshTimings

}