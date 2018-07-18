$configfile = "C:\SQL\ConfigurationFile.ini"

$command = "C:\Software\en_sql_server_2016_developer_with_service_pack_1_x64_dvd_9548071\setup.exe /ConfigurationFile=$($configfile)"

Invoke-Expression -Command $command
