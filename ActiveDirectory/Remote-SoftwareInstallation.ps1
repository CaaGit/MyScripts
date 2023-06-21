$servers = gc C:\users\admin\desktop\server.txt ## providing the list of servers##
$source = "\\TEB-TS2\SourceInstFiles" ### share the folder in which the installation file is present ##
$tempath ="\\TEB-TS2\InstTemp" ##temporary path ##
$destination = "c$" ## destination where the file will copy##

foreach ($server in $servers)
{
$server
$session = New-PSSession -ComputerName $server ##create a temporary session on remote server##
if(test-connection -Cn $server -quiet) ## check the connectivity of the servers ##
{
Copy-Item $source -Destination \\$server\$destination -Recurse -Force ##copies the folder with the software to the remote server.

if(Test-Path -path $tempath) ##check the tempath on the remote servers
{
Invoke-command -session $session -ScriptBlock {Msiexec /i C:\OpsView_Agent\Opsview_Windows_Agent_x64_11-03-21-1343.msi /quiet /qn /norestart
start-sleep -Seconds 120
Start-Service -Name "OpsviewAgent"
get-service -Name "OpsviewAgent"
}
Write-Host -ForeGroundColor Green "Installation successful on $server"
}
}
else
{
Write-Host -ForeGroundColor red "Installation failed on $server"
}
}