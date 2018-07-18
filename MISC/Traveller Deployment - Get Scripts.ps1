<#
Invoke-Item C:\Tmp

Invoke-Item '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180202\Brease.6607.20700\Brease.6607.20700'
Invoke-Item '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180202\WUK.6607.21516'
Invoke-Item '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180220\WUK.6621.20888'
Invoke-Item '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180220\WUK.6624.17171'
Invoke-Item '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180322\WUK.6654.31676'
Invoke-Item '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180410\WUK.6674.22777'
Invoke-Item '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180418\WUK.6682.21480'
invoke-item $Destination
#>

<#
Invoke-Item 	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180202\Brease.6607.20700\Brease.6607.20700'
Invoke-Item  '\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180202\WUK.6607.21516'
Invoke-Item 	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180220\WUK.6621.20888'
Invoke-Item 	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180220\WUK.6624.17171'
Invoke-Item 	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180322\WUK.6654.31676'
Invoke-Item 	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180418\WUK.6682.21480'
Invoke-Item 	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180427\WUK.6688.24444'
Invoke-Item	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180427\WUK.6689.23138'
Invoke-Item	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180427\WUK.6689.28410'
#>

$D1 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180202\Brease.6607.20700\Brease.6607.20700'
$D2 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180202\WUK.6607.21516'
$D3 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180220\WUK.6621.20888'
$D4 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180220\WUK.6624.17171'
$D5 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180322\WUK.6654.31676'
$D6 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180418\WUK.6682.21480'
$D7 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180427\WUK.6688.24444'
$D8 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180427\WUK.6689.23138'
$D9 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180427\WUK.6689.28410'
$D10 =	'\\vrgefs01\shared\IT\Programme Victory\Releases\Web Apps\20180613\WUK.6737.25922'

$Destination = 'C:\Tmp\TravellerDeployment\PreProd\June2018\Scripts'
$WebappsFiles = 'C:\Tmp\TravellerDeployment\PreProd\June2018\WebApps'


Dir -Path $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $D10 -Include *.sql -File -Recurse | copy-item -Destination $Destination -PassThru 
#Dir $Destination -Include *.sql -File -Recurse| copy-item -Destination $DestinationCopy -PassThru |Rename-Item -NewName {$_.Directory.Name + " - " + $_.Name}

$i = 1

     Dir $Destination| Sort-Object | Foreach-Object -Process {
         $NewName = '{0} - {1}' -f $i,$_.Name # String formatting e.x. 1__FileName.txt
         $_ | Rename-Item -NewName $NewName # rename item
         $i ++ # increment number before next iteration

         }


Dir -Path $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $D10 -Include File*.txt -File -Recurse | copy-item -Destination $WebappsFiles -PassThru 
$TableChanges = Select-String -Path $WebappsFiles\*.txt -Pattern stb

Write-Host 'Table Changes'
$TableChanges.line;$TableChanges.filename
   