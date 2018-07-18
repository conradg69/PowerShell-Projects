$SourceServers = 'wercovrdevsqld1','wercovrqaesqld1'#,'wercovruatsqld1' -StartDate $Minus30Mins
$DestServer = 'wercovrdevsqld1'
$Minus30Mins = (Get-Date).AddMinutes(-30)
$SourceServers |Get-DbaAgentJobHistory  -Verbose| Select-Object *, @{L='CaptureDate';E={Get-Date -Format g}} |ConvertTo-DbaDataTable -Verbose | Write-DbaDataTable -SqlInstance $DestServer -Database DBAdmin -Table PS_AgentJobHistory -AutoCreateTable -Verbose


$SourceServers = 'wercovrdevsqld1','wercovrqaesqld1'#,'wercovruatsqld1' 
$DestServer = 'wercovrdevsqld1'
$Minus30Mins = (Get-Date).AddMinutes(-30)
Get-DbaAgentJob --SqlInstance $SourceServers -Verbose| Select-Object *, @{L='CaptureDate';E={Get-Date -Format g}} |ConvertTo-DbaDataTable -Verbose | Write-DbaDataTable -SqlInstance $DestServer -Database DBAdmin -Table PS_AgentJobHistory -AutoCreateTable -Verbose