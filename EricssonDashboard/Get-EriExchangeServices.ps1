# Import the Exchange PowerShell module
if (-not (Get-Module -Name ExchangeManagementShell -ErrorAction SilentlyContinue)) {
    Import-Module ExchangeManagementShell
}

# Get all Exchange servers in the organization
$ExchangeServers = Get-ExchangeServer | Where-Object { $_.ServerRole -notlike "*UnifiedMessaging*" } | Select-Object -ExpandProperty Name

$ExchangeServices = @(
    "MSExchangeADTopology",
    "MSExchangeAntispamUpdate",
    "MSExchangeEdgeSync",
    "MSExchangeFBA",
    "MSExchangeFrontendTransport",
    "MSExchangeHM",
    "MSExchangeIMAP4",
    "MSExchangeIS",
    "MSExchangeMailboxAssistants",
    "MSExchangeMailboxReplication",
    "MSExchangeMailSubmission",
    "MSExchangeProtectedServiceHost",
    "MSExchangeRepl",
    "MSExchangeRPC",
    "MSExchangeSA",
    "MSExchangeSearch",
    "MSExchangeServiceHost",
    "MSExchangeThrottling",
    "MSExchangeTransport",
    "MSExchangeTransportLogSearch",
    "MSExchangeUM",
    "MSExchangeUMCR",
    "MSExchangeUMCallData"
)

$reportData = @()
foreach ($ExchangeServer in $ExchangeServers) {
    foreach ($Service in $ExchangeServices) {
        $ServiceStatus = Get-Service -Name $Service -ComputerName $ExchangeServer -ErrorAction SilentlyContinue
        if ($ServiceStatus) {
            $ServiceHealth = $ServiceStatus.Status
        } else {
            $ServiceHealth = "Not Installed"
        }
        $reportData += [PSCustomObject]@{
            'Exchange Server' = $ExchangeServer
            'Service' = $Service
            'Health' = $ServiceHealth
        }
    }
}

$FolderPath = "C:\ScriptsResults\EricsonDashboard"
if (-not (Test-Path $FolderPath)) {
    New-Item -ItemType Directory -Path $FolderPath | Out-Null
}

$reportData | Export-Csv -Path (Join-Path -Path $FolderPath -ChildPath "ExchangeServerStatus.csv") -NoTypeInformation
