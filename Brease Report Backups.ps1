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
$downloadFolderSelectorReports = "C:\Temp\ReportBackups\TR4_DEV\Selector Reports $DateTimeFormatted"
$ManualUploadFolder = "Manual_Upload"
$ManualUploadReports = "C:\Temp\ReportBackups\TR4_DEV\$ManualUploadFolder $DateTimeFormatted"
$DataSourcePath2 = "/Brease_Dev/Data Sources/BreaseDev"
$TR4_DEVRootFolder = 'C:\Temp\ReportBackups\TR4_DEV'

#Create Brease Sub Folders in the New Backup folder
New-Item -Path $downloadFolderDetailReports -ItemType directory 
New-Item -Path $downloadFolderSelectorReports -ItemType directory 
New-Item -Path $ManualUploadReports -ItemType directory 

write-host 'Creating SSRS Folders'

#create SSRS Backup Folders
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $RootBackupFolderPath -FolderName $DevBackupFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$DevBackupFolder" -FolderName $DetailReportsFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$DevBackupFolder" -FolderName $SelectorReportsFolder

write-host 'Downloading Detail Reports'

#Download all Detail Reports to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseDevFolder/$DetailReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolderDetailReports

write-host 'Downloading Selector Reports'

#Download all Selector Reports to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseDevFolder/$SelectorReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolderSelectorReports

    #Move Reports that need to be manually uploaded to the a separate folder
Get-ChildItem -Path $downloadFolderDetailReports  -Recurse -Filter "*[*" | Move-Item -Destination  $ManualUploadReports

write-host 'Uploading Detail Reports'

#Upload all Detail Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderDetailReports -RsFolder "$RootBackupFolderPath/$DevBackupFolder/$DetailReportsFolder" -Overwrite

write-host 'Downloading Selector Reports'

#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderSelectorReports -RsFolder "$RootBackupFolderPath/$DevBackupFolder/$SelectorReportsFolder" -Overwrite

#Clean Up - moved RDL's folder to a New folder
New-Item -Path "$TR4_DEVRootFolder/ReportBackups $DateTimeFormatted" -ItemType directory
Move-Item -Path $ManualUploadReports -Destination "$TR4_DEVRootFolder/ReportBackups $DateTimeFormatted"
Move-Item -Path $downloadFolderDetailReports -Destination "$TR4_DEVRootFolder/ReportBackups $DateTimeFormatted"
Move-Item -Path $downloadFolderSelectorReports -Destination "$TR4_DEVRootFolder/ReportBackups $DateTimeFormatted"

write-host 'Updating DataSourses - Selector Reports'

$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$DevBackupFolder/$SelectorReportsFolder"
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

write-host 'Updating DataSourses - Detail Reports'

$BackedUpDetailReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$DevBackupFolder/$DetailReportsFolder"
# Set report datasource
$BackedUpDetailReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

