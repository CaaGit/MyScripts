# Import the Exchange PowerShell module
<# if (-not (Get-Module -Name ExchangeManagementShell -ErrorAction SilentlyContinue)) {
    Import-Module ExchangeManagementShell
}
 #>
# Get all Exchange servers in the organization
$ExchangeServers = Get-ExchangeServer | Where-Object { $_.ServerRole -notlike "*UnifiedMessaging*" } | Select-Object -ExpandProperty Name

$ExchangeServices = @(
    "MSExchangeADTopology",
    "MSExchangeAntispamUpdate",
    "MSExchangeCompliance",
    "MSExchangeDagMgmt",
    "MSExchangeDelivery",
    "MSExchangeDiagnostics",
    "MSExchangeEdgeSync",
    "MSExchangeFastSearch",
    "MSExchangeFrontEndTransport",
    "MSExchangeHM",
    "MSExchangeHMRecovery",
    "MSExchangeImap4",
    "MSExchangeIMAP4BE",
    "MSExchangeIS",
    "MSExchangeMailboxAssistants",
    "MSExchangeMailboxReplication",
    "MSExchangeMitigation",
    "MSExchangePop3",
    "MSExchangePOP3BE",
    "MSExchangeRepl",
    "MSExchangeRPC",
    "MSExchangeServiceHost",
    "MSExchangeSubmission",
    "MSExchangeThrottling",
    "MSExchangeTransport",
    "MSExchangeTransportLogSearch",
    "W3Svc",
    "WinRM"
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
#done