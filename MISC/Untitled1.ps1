$labName = 'SingleMachine'

#create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

#make the network definition
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace 192.168.70.0/24

Set-LabInstallationCredential -Username Conrad -Password Password1

#Our one and only machine with nothing on it
Add-LabMachineDefinition -Name SQL01 -Memory 1GB -Network $labName -IpAddress 192.168.70.10 `
    -OperatingSystem 'Windows Server 2016 SERVERSTANDARD'

Install-Lab

Show-LabDeploymentSummary -Detailed