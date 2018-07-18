<#
.SYNOPSIS
   Returns pending transaction count of all publications and their subscribers.
.DESCRIPTION
   This script will connect to a SQL server replication publisher, enumerate all publications and their subscriptions, and then get a pending transaction count for each.
   The script will then output the counts to a formatted table.
   You can provide a specific database and/or subscriber (hostname) as optional arguments.

.EXAMPLE
   Show-SQLReplicationTransactions -PublisherName "hostname"
   This will return all publications and their subscriptions from the publisher, as well as pending transaction counts

.OUTPUTS
   List of all sql related services
.NOTES
   v1.0, Drew Furgiuele (@pittfurg) 2014/07/16
#>
param(
    [Parameter(Mandatory=$true)] [string]$PublisherName,
    [Parameter(Mandatory=$false)] [string]$SubscriberName = $null,
    [Parameter(Mandatory=$false)] [string]$DatabaseName = $null
)

##Add-Type -Path 'C:\Program Files\Microsoft SQL Server\120\SDK\Assemblies\Microsoft.SqlServer.Replication.dll' -ErrorAction SilentlyContinue

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.RMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Replication") | Out-Null
$RepInstanceObject = New-Object "Microsoft.SqlServer.Replication.ReplicationServer" $PublisherName
$RepStatusObject = New-Object "Microsoft.SqlServer.Replication.ReplicationMonitor" $PublisherName

$statsTable = New-Object System.Data.DataTable
$statsTable.Columns.Add("Publication") | Out-Null
$statsTable.Columns.Add("Publisher") | Out-Null
$statsTable.Columns.Add("DistributionDB") | Out-Null
$statsTable.Columns.Add("DatabaseName") | Out-Null
$statsTable.Columns.Add("Pending Commands") | Out-Null
$statsTable.Columns.Add("Est Time") | Out-Null

$subscriptions = @()
$opt = New-Object "Microsoft.SqlServer.Replication.Subscriptionoption"

if (!$DatabaseName) 
{
    $publications = $RepInstanceObject.DistributionPublishers.DistributionPublications
}
else 
{
    $publications = $RepInstanceObject.DistributionPublishers.DistributionPublications | Where-Object {$_.PublicationDBName -eq $DatabaseName}
}

ForEach ($pub in $publications)
{
    if (!$SubscriberName)
    {
        $subList = $pub.DistributionSubscriptions
    }
    else
    {
        $subList = $pub.DistributionSubscriptions | Where-Object {$_.SubscriberName -eq $SubscriberName}
    }
    ForEach ($sub in $subList)
    {
        $subscription = New-Object System.Object
        $subscription | Add-Member -type NoteProperty -name PubName -Value $pub.Name
        $subscription | Add-Member -type NoteProperty -name SubName -Value $sub.Name
        $subscription | Add-Member -type NoteProperty -name DistributionDB -Value $sub.DistributionDBName
        $subscription | Add-Member -type NoteProperty -name Publisher -Value $sub.PublisherName
        $subscription | Add-Member -type NoteProperty -name PublisherDBName -Value $sub.PublicationDBName
        $subscription | Add-Member -type NoteProperty -name Subscriber -Value $sub.SubscriberName
        $subscription | Add-Member -type NoteProperty -name SubscriberDBName -Value $sub.SubscriptionDBName
        $subscription | Add-Member -type NoteProperty -name PendingXActions -Value $null
        $subscription | Add-Member -type NoteProperty -name EstLatency  -Value $null
        $subscriptions += $subscription
    }
}

ForEach ($sub in $subscriptions)
{
    $monitor = $RepStatusObject.PublisherMonitors[$PublisherName].PublicationMonitors | Where-Object {$_.Name -eq $sub.PubName}
    $pending = $monitor.TransPendingCommandInfo($sub.Subscriber,$sub.SubscriberDBName,$opt)
    $sub.PendingXactions = $pending.PendingCommands
    $sub.EstLatency = $pending.EstimatedTimeBehind
}


$subscriptions | Format-Table Publisher,PubName,PublisherDBName,Subscriber,SubscriberDBName,PendingXActions, EstLatency -AutoSize