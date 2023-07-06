# Get all Exchange servers in the organization
$ExchangeServers = Get-ExchangeServer | Where-Object { $_.ServerRole -notlike "*UnifiedMessaging*" } | Select-Object -ExpandProperty Name

$reportData = @()
foreach ($ExchangeServer in $ExchangeServers) {
    $ECPStatus = Test-EcpConnectivity -URL "https://$ExchangeServer/ecp" -MailboxCredential (Get-Credential) -Authentication Basic -ErrorAction SilentlyContinue
    $OWAStatus = Test-OwaConnectivity -URL "https://$ExchangeServer/owa" -MailboxCredential (Get-Credential) -Authentication Basic -ErrorAction SilentlyContinue
    $IMAPStatus = Test-ImapConnectivity -MailboxServer $ExchangeServer -ErrorAction SilentlyContinue
    $POPStatus = Test-PopConnectivity -MailboxServer $ExchangeServer -ErrorAction SilentlyContinue
    $MAPIStatus = Test-MapiConnectivity -Identity $ExchangeServer -ErrorAction SilentlyContinue
    $EWSStatus = Test-WebServicesConnectivity -MailboxCredential (Get-Credential) -Identity $ExchangeServer -ErrorAction SilentlyContinue
    
    $reportData += [PSCustomObject]@{
        'Exchange Server' = $ExchangeServer
        'ECP Status' = $ECPStatus.Result
        'OWA Status' = $OWAStatus.Result
        'IMAP Status' = $IMAPStatus.Result
        'POP Status' = $POPStatus.Result
        'MAPI Status' = $MAPIStatus.Result
        'EWS Status' = $EWSStatus.Result
    }
}

$FolderPath = "C:\ScriptsResults\EricsonDashboard"
if (-not (Test-Path $FolderPath)) {
    New-Item -ItemType Directory -Path $FolderPath | Out-Null
}

$reportData | Export-Csv -Path (Join-Path -Path $FolderPath -ChildPath "ClientConnectivityStatus.csv") -NoTypeInformation
#done