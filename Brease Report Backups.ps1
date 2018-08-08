$reportServerUriDest = 'http://wercovrdevsqld1/Reportserver'
$RootFolderPath = "/"
$RootBackupFolderName = 'BreaseReportBackups'
$RootBackupFolderPath = "$RootFolderPath$RootBackupFolderName"
$BreaseDevFolder = 'Brease_DEV'
$BreaseMaintenanceFolder = 'Brease_MaintenanceDev'
$CurrentDateTime = Get-Date -Format FileDateTime 
$DateTimeFormatted = $CurrentDateTime.Substring(0,13)
$DevBackupFolder = "$BreaseDevFolder-$DateTimeFormatted"
$DevBackupFolderLocation = "$RootBackupFolderPath/$DevBackupFolder"
$DetailReportsFolder = "Detail Reports"
$SelectorReportsFolder = "Selector Reports"
$downloadFolder = "C:\Temp\ReportBackups\"

#create Root Backup Folder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $RootBackupFolderPath -FolderName $DevBackupFolder

#Create Brease Sub Folders in the New Backup folder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $DevBackupFolderLocation -FolderName "Detail Reports"
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $DevBackupFolderLocation -FolderName "Selector Reports"

#Download all Reports to a Folder of type Report
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseDevFolder/$DetailReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolder


<#
destination parameters
$destinationFolderPath = "/BreaseReportBackups"
$destinationFolderName = "FolderB"
$newRSFolderPath = "$destinationFolderPath$destinationFolderName"
#>