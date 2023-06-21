#Provide the list of DHCP server in a text file#

$server= gc C:\users\dbharali\desktop\servers.txt
$DS = get-ADComputer -Filter * -Properties * |select Name -ExpandProperty Name

#Taking the servers from the list#

foreach($servers in $server){

if ($ds -notcontains $servers)

{
write-host "$servers is not found" -BackgroundColor DarkRed
}


else{
write-host "Backing up DHCP for $servers" -BackgroundColor DarkCyan

#Below is the command for Backing up DHCP server

Backup-DhcpServer -ComputerName $servers -Path "C:\Windows\system32\dhcp\backup"}}