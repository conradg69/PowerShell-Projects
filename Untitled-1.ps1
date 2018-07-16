$servername = 'WERCOVRDEVSQLD1'
$repserver = New-Object "Microsoft.SqlServer.Replication.ReplicationServer"
$srv = New-Object "Microsoft.SqlServer.Management.Common.ServerConnection" $servername
$srv.connect()
$repserver.ConnectionContext = $srv

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Rmo")

$databasename = 'FusionILTCacheSearch'
$repdb = $repserver.ReplicationDatabases[$databasename]

$repdb.transpublications
$publication_name = 'pubFusionILTCacheSearch'
$publication_object = $repdb.transpublications[$publication_name]
$publication_object.TransArticles
$publication_object.TransSubscriptions

$script_val = [Microsoft.SqlServer.Replication.ScriptOptions]::Creation -bxor 
[Microsoft.SqlServer.Replication.ScriptOptions]::IncludeGo

$script_val = [Microsoft.SqlServer.Replication.ScriptOptions]::Creation -bxor
[Microsoft.SqlServer.Replication.ScriptOptions]::IncludePublications -bxor
[Microsoft.SqlServer.Replication.ScriptOptions]::IncludePublicationAccesses -bxor
[Microsoft.SqlServer.Replication.ScriptOptions]::IncludeArticles -bxor
[Microsoft.SqlServer.Replication.ScriptOptions]::IncludeRegisteredSubscribers -bxor
[Microsoft.SqlServer.Replication.ScriptOptions]::IncludeGo



$publication_object.Script($script_val) |export-dba


$publication_object.Script($script_val)
Foreach ($article in $publication_object.TransArticles) {

    $article.Script($script_val)
}