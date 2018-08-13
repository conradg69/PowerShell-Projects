$reportServerUriDest = 'http://wercovrqaesqld1/Reportserver'
$RootFolderPath = "/"
$RootBackupFolderName = 'BreaseReportBackups'
$RootBackupFolderPath = "$RootFolderPath$RootBackupFolderName"
$BreaseQAEFolder = 'TR4_QAEFinance'
$BreaseQAEFolderSSRS = 'Brease_FinanceQAE'
$CurrentDateTime = Get-Date -Format FileDateTime 
$DateTimeFormatted = $CurrentDateTime.Substring(0,13)
$QAEBackupFolder = "$BreaseQAEFolder-$DateTimeFormatted"
$DetailReportsFolder = "Detail Reports"
$SelectorReportsFolder = "Selector Reports"
$downloadFolderDetailReports = "C:\Temp\ReportBackups\TR4_QAEFinance\Detail Reports $DateTimeFormatted"
$downloadFolderSelectorReports = "C:\Temp\ReportBackups\TR4_QAEFinance\Selector Reports $DateTimeFormatted"
$DataSourcePath2 = "/Brease_FinanceQAE/DataSources/Brease_FinanceQAE"
$TR4_QAERootFolder = 'C:\Temp\ReportBackups\TR4_QAEFinance'

#Create Brease  Folders for the RDL files
New-Item -Path $downloadFolderDetailReports -ItemType directory 
New-Item -Path $downloadFolderSelectorReports -ItemType directory 


write-host 'Creating SSRS Folders'

#create SSRS Backup Folders
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $RootBackupFolderPath -FolderName $QAEBackupFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder" -FolderName $DetailReportsFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder" -FolderName $SelectorReportsFolder

write-host 'Downloading Detail Reports'

#Download all Detail Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$DetailReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolderDetailReports

write-host 'Downloading Selector Reports'

#Download all Selector Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$SelectorReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolderSelectorReports

#Move Reports that need to be manually uploaded to the a separate folder
Get-ChildItem -Path $downloadFolderDetailReports  -Recurse -Filter "*[*" | Remove-Item
Get-ChildItem -Path $downloadFolderDetailReports  -Recurse -Filter "*WebAppsTest*" | Remove-Item

write-host 'Uploading Detail Reports'

#Upload all Detail Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderDetailReports -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$DetailReportsFolder" -Overwrite

write-host 'Downloading Selector Reports'

#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderSelectorReports -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$SelectorReportsFolder" -Overwrite

#Clean Up - moved RDL's folder to a New folder
New-Item -Path "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted" -ItemType directory
Move-Item -Path $downloadFolderDetailReports -Destination "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted"
Move-Item -Path $downloadFolderSelectorReports -Destination "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted"

write-host 'Updating DataSourses - Selector Reports'

$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$SelectorReportsFolder"
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

$BackedUpDetailReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$DetailReportsFolder"
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

