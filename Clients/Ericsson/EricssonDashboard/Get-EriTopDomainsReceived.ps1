# Define the output file
$outputFile = ".\DomainStatistics.csv"

# Get the list of Exchange servers
$servers = Get-ExchangeServer | Where-Object { $_.IsMailboxServer -eq $true -or $_.IsHubTransportServer -eq $true } | Select-Object -ExpandProperty Name

# Get the message tracking logs from each server
$logs = foreach ($server in $servers) {
    Get-MessageTrackingLog -ResultSize Unlimited -Start (Get-Date).AddDays(-150) -Server $server   
}

# Get the top 5 received email domains
$receivedDomains = $logs |
Where-Object { $_.eventid -eq "RECEIVE" -and $_.source -eq "STOREDRIVER" } |
Group-Object -Property { $_.Sender -replace '.*@' } |
Sort-Object -Property Count -Descending |
Select-Object -First 5 |
Select-Object @{Name = "Domain"; Expression = { $_._GroupByValue } }, @{Name = "Number of Emails"; Expression = { $_.Count } }


# For each domain, get the top sender and receiver of emails
$statistics = foreach ($domain in $receivedDomains.Domain) {
    $domainLogs = $logs | Where-Object { ($_.Recipients -replace '.*@') -eq $domain -or ($_.Sender -replace '.*@') -eq $domain }
    $topSender = $domainLogs |
    Where-Object { $_.EventId -eq "SEND" } |
    Group-Object -Property Sender |
    Sort-Object -Property Count -Descending |
    Select-Object -First 1
    $topReceiver = $domainLogs |
    Where-Object { $_.EventId -eq "RECEIVE" } |
    Group-Object -Property Recipients |
    Sort-Object -Property Count -Descending |
    Select-Object -First 1
    [PSCustomObject]@{
        Domain                            = $domain
        "Number of Emails"                = ($receivedDomains | Where-Object { $_.Domain -eq $domain })."Number of Emails"
        TopSender                         = $topSender.Name
        "Number of Emails (Top Sender)"   = $topSender.Count
        TopReceiver                       = $topReceiver.Name
        "Number of Emails (Top Receiver)" = $topReceiver.Count
    }
}

# Export the statistics to a CSV file
$statistics | Export-Csv -Path $outputFile -NoTypeInformation