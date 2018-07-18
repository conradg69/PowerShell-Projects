
function not-exist { -not (Test-Path $args) }
#Set-Alias !exist not-exist -Option "Constant, AllScope"
#Set-Alias exist Test-Path -Option "Constant, AllScope"


$Path = "C:\Temp"
if (not-exist $path) {New-Item -ItemType Directory -Path $Path}
else {Remove-Item $Path}