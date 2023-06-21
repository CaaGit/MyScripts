
$domain = read-host "Provide the domain name"
$Forest = Get-ADForest $domain | fl SchemaMaster,DomainNamingMaster
$ADDomain = Get-ADDomain $domain | fl PDCEmulator,RIDMaster,InfrastructureMaster

$Forest  | Out-File c:\FSMORoles.txt 
$ADDomain | Out-File c:\FSMORoles.txt -Append



