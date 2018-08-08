
#Import-Module "$home\Documents\WindowsPowerShell\Modules\ReportingServicesTools\src\ReportingServicesTools.psd1" -Force
#$reportServerUriDest2 = "http://wercovrdevsqld1/Reportserver"
#Remove-RsRestFolder -RsFolder $newRSFolderPath -ReportPortalUri $reportServerUriDest2
#Report server URL parameter
#get-help Remove-RsCatalogItem  -Examples


$reportServerUri = 'http://wercovrdevsqld1/Reportserver'
$reportServerUriDest = 'http://wercovrdevsqld1/Reportserver'
#source parameters
$sourceRSFolder = "/BreaseLive Reports"
$downloadFolder = "C:\Temp\SSRSReportUpload\LiveReports\"
$ManualUploadFolder = "C:\Temp\SSRSReportUpload\ManualUpload\"
$RootFolder = "C:\Temp\SSRSReportUpload\"
#destination parameters
$destinationFolderPath = "/"
$destinationFolderName = "BreaseReportUploads"
$newRSFolderPath = "$destinationFolderPath$destinationFolderName"
#$newRSFolderPath2 = "/BreaseLive Reports"
# Creates a new folder on the root of report server

 

#Download all Reports to a Folder of type Report
Get-RsFolderContent -ReportServerUri $reportServerUri -RsFolder $sourceRSFolder |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUri -Destination $downloadFolder


Get-ChildItem -Path $downloadFolder  -Recurse -Filter "*[*" | Move-Item -Destination  $ManualUploadFolder


#Download all files in the diretory
#Out-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder $sourceRSFolder -Destination $downloadFolder

New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $destinationFolderPath -FolderName $destinationFolderName

#Upload all files from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolder -RsFolder $newRSFolderPath -Overwrite


$Results = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder $newRSFolderPath
$DataSourcePath2 = "/Brease_Dev/Data Sources/BreaseDev"
# Set report datasource
$Results | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}