﻿#Import-Module "$home\Documents\WindowsPowerShell\Modules\ReportingServicesTools\src\ReportingServicesTools.psd1" -Force

#Report server URL parameter
$reportServerUri = 'http://wercovrdevsqld1/Reportserver'
#source parameters
$sourceRSFolder = "/FolderA"
$downloadFolder = "T:\FolderA_Reports"

#destination parameters
$destinationFolderPath = "/"
$destinationFolderName = "FolderB"
$newRSFolderPath = "$destinationFolderPath$destinationFolderName"

#data source configuration
$newRSDSFolder = "$destinationFolderPath$destinationFolderName"
$newRSDSName = "Datasource"
$newRSDSExtension = "SQL"
$newRSDSConnectionString = "Initial Catalog=Db1; Data Source=Server1"
$newRSDSCredentialRetrieval = "Store"
$newRSDSCredential = Get-Credential -Message "Enter user credentials for data source"

$DataSourcePath = "$newRSDSFolder/$newRSDSName"

# Creates a new folder on the root of report server
New-RsFolder -ReportServerUri $reportServerUri -RsFolder $destinationFolderPath -FolderName $destinationFolderName

#Download all objects of type Report
Get-RsFolderContent -ReportServerUri $reportServerUri -RsFolder $sourceRSFolder |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $reportServerUri -Destination $downloadFolder


#Download all files in the diretory
#Out-RsFolderContent -ReportServerUri $reportServerUri -RsFolder $sourceRSFolder -Destination $downloadFolder

#Upload all files from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUri -Path $downloadFolder -RsFolder $newRSFolderPath

#Add new datasource
New-RsDataSource -ReportServerUri $reportServerUri -RsFolder $newRSDSFolder -Name $newRSDSName -Extension $newRSDSExtension -ConnectionString $newRSDSConnectionString -CredentialRetrieval $newRSDSCredentialRetrieval -DatasourceCredentials $newRSDSCredential

# Set report datasource
Get-RsCatalogItems -ReportServerUri $reportServerUri -RsFolder $newRSFolderPath | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemReference -ReportServerUri $reportServerUri -Path $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUri -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}