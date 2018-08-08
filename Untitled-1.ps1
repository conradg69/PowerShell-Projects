Get-Command -Module ReportingServicesTools
get-help  Get-RsItemReference  -Examples

$reportServerUri = 'http://wercovrdevsqld1/Reportserver'
Get-RsItemReferences -ReportServerUri $reportServerUri -Path 'C:\Temp\SSRSReportUpload\LiveReports'

Get-RsFolderContent -ReportServerUri $reportServerUri -RsFolder /BreaseReportUploads

get-help Move-Item -Examples


New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $destinationFolderPath -FolderName BreaseReportBackups
#Remove-RsRestFolder -RsFolder $newRSFolderPath 
<#
#Report server URL parameter
$reportServerUri = 'http://thgdocuments/Reportserver'
$reportServerUriDest = 'http://wercovrdevsqld1/Reportserver'
#source parameters
$sourceRSFolder = "/Brease/Detail Reports"
$downloadFolder = "C:\Temp\ReportBackups"

#destination parameters
$destinationFolderPath = "/"
$destinationFolderName = "FolderB"
$newRSFolderPath = "$destinationFolderPath$destinationFolderName"

# Creates a new folder on the root of report server
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $destinationFolderPath -FolderName $destinationFolderName

#Download all objects of type Report
Get-RsFolderContent -ReportServerUri $reportServerUri -RsFolder $sourceRSFolder |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUri -Destination $downloadFolder
    

#Upload all files from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolder -RsFolder $newRSFolderPath
#>