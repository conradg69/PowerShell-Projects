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
$downloadFolderDetailReports = "C:\Temp\ReportBackups\TR4_DEV\Detail Reports $DateTimeFormatted"
$ManualUploadFolder = "Manual_Upload"
$ManualUploadReports = "C:\Temp\ReportBackups\TR4_DEV\$ManualUploadFolder $DateTimeFormatted"
$DataSourcePath2 = "/Brease_Dev/Data Sources/BreaseDev"
$TR4_DEVRootFolder = 'C:\Temp\ReportBackups\TR4_DEV'

#Create Brease Sub Folders in the New Backup folder
New-Item -Path $downloadFolderDetailReports -ItemType directory 
New-Item -Path $ManualUploadReports -ItemType directory 
 

#create Root Backup Folder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $RootBackupFolderPath -FolderName $DevBackupFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$DevBackupFolder" -FolderName $DetailReportsFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$DevBackupFolder" -FolderName $SelectorReportsFolder

#New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $DevBackupFolderLocation -FolderName "Detail Reports"
#New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $DevBackupFolderLocation -FolderName "Selector Reports"

#Download all Reports to a Folder of type Report
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseDevFolder/$DetailReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolderDetailReports

#Move Reports that need to be manually uploaded to the a separate folder
Get-ChildItem -Path $downloadFolderDetailReports  -Recurse -Filter "*[*" | Move-Item -Destination  $ManualUploadReports

#Upload all files from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderDetailReports -RsFolder "$RootBackupFolderPath/$DevBackupFolder/$DetailReportsFolder" -Overwrite

#Clean Up - moved RDL's folder to a New folder
New-Item -Path "$TR4_DEVRootFolder/ReportBackups$DateTimeFormatted" -ItemType directory
Move-Item -Path $ManualUploadReports -Destination "$TR4_DEVRootFolder/ReportBackups$DateTimeFormatted"
Move-Item -Path $downloadFolderDetailReports -Destination "$TR4_DEVRootFolder/ReportBackups$DateTimeFormatted"


$BackedUpReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$DevBackupFolder/$DetailReportsFolder"
# Set report datasource
$BackedUpReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

