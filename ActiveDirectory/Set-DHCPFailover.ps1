#Provide the source server name 
$Sourceserver = Read-host "Provide the Source server"

#Provide the destination server name 
$Destinationserver = Read-host "Provide the destination server"

#Provide the scopeid for which you want to create the failover
$scopeid=Read-host "Provide the scopeid"

#Provide the failover name
$failoverName = Read-host "Provide the failover Name"

#Provide the shared key between servers
$key=Read-host "Provide the Key"

#Below command will create failover between 2 DHCP server
Add-DhcpServerv4Failover -ComputerName $Sourceserver -Name $failoverName -PartnerServer $Destinationserver -ScopeId $scopeid -SharedSecret $key -Confirm :$false