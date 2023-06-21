$domain= read-host "Provide the domain name"
$DCserver = read-host "Provide DC server name"
Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $domain -Server $DCserver -Confirm:$false