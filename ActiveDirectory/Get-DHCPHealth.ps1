﻿########################### Make sure Pstools psexec.exe is there in your system #######################################

$pclist=get-content "path"
[array]$dhcp_info = @()
$dhcp_info = $null
[array]$dhcp_stat = @()
$dhcp_stat = $null

############################# Provide path wherever it is required ############################
$date = get-date
foreach ($server in $pclist) { 
$server
############################## Don't change \\$server C:\windows\system32\netsh #######################
$dhcp_scope, $dhcp_mib = $null
$dhcp_scope= Provide path\PsExec.exe \\$server C:\windows\system32\netsh dhcp server show scope > provide path
$flag1 = $LASTEXITCODE
$dhcp_mib= provide path\PsExec.exe \\$server C:\windows\system32\netsh dhcp server show mibinfo | select-string -pattern "scope", "subnet", "No. of Addresses in use = ", "No. of free Addresses = ", "No. of pending offers ="
$flag2 = $LASTEXITCODE

            #Testing if netsh executed successfuly
            if ($flag1 -eq 0 -and $flag2 -eq 0 )
            {
                    #Dhcp scopes
                    $scope = Get-Content C:\Cap\scope.txt

                    $htmlfile+="<br><br><table>"
                    $htmlfile+= "`r`n" + "<Caption><h3>Scope Information</h3></caption>"

                    #Reading scope info line by line
                    foreach ($scope_line in $scope)
                    {
                         $ser_stat = "" | Select-Object Server,Scope_name,Scope_Address,Description,State,Subnet_Mask,subnet,used,free,pending,percentage,remarks

                         if($scope_line -match "^\S*$")
                        {
                            Write-Host "Ignore white space"
                        }
                        if($scope_line -match "=")
                        {
                            Write-Host "Ignore"
                        }
                        else
                        {
            
                            $addr,$sub_mask,$state,$name,$com = $scope_line.Split("-")
                            if($addr -match "Scope Address")
                            {
		                        Write-Host "Ignore Header"
                            }
                            else
                            {
                                    if($state -match "^[A-Za-z]*$")
                                    {
                                        Write-Host "Ignore"
                                    }
                                   else
                                    {
			                        
                                        $ser_stat.Server = $server
                                        $ser_stat.scope_name = $name
                                        $ser_stat.scope_address = $addr
                                        $ser_stat.description = $com
                                        $ser_stat.state = $state
                                        $ser_stat.subnet_mask = $sub_mask
                                        $ser_stat.remarks = ""
                                    
                                        $dhcp_stat+=$ser_stat
    
                                  
                                     }
                                  
                             }

                         }

                     
                    }#ending loop for reading scope info line by line

                    #mibinfo 

                    $Scopes = $dhcp_mib

                    $mb = @()
               


                    [array]$subnet =[regex]::Matches($Scopes,"Subnet = (\d+\.\d+\.\d+.\d+)")
                    $addr_use = [regex]::Matches($Scopes,"No. of Addresses in use = (\d*)")
                    $addr_free = [regex]::Matches($Scopes,"No. of free Addresses = (\d*)")
                    $addr_pend = [regex]::Matches($Scopes,"No. of pending offers = (\d*)")

                    $len = $subnet.Length
                    $len= $len*2

                    for ($i=1 ;$i -lt $len; $i++)
                    {

                      $mib_info = "" | Select-Object subnet,used,free,pending,percentage
                      $mib_info.subnet= $subnet.groups[$i].value 
                      $mib_info.used= [int]$addr_use.groups[$i].value 
                      $mib_info.free= [int]$addr_free.groups[$i].value 
                      $mib_info.pending= [int]$addr_pend.groups[$i].value 

                      $mb+= $mib_info

                     

                      foreach ($sub_dh in $dhcp_stat)
                      {
                       

                        if ($sub_dh.scope_address.Trim() -eq $subnet.groups[$i].value)
                        {
                            $sub_dh.subnet = $subnet.groups[$i].value
                            $sub_dh.used = [int]$addr_use.groups[$i].value
                            $sub_dh.free = [int]$addr_free.groups[$i].value
                            $sub_dh.pending = [int]$addr_pend.groups[$i].value
                        }
                      }
                       $i=$i+1

                    }

                     foreach ($sub in $mb )
                    {
                        foreach ($sub_dh in $dhcp_stat)
                            {
                                if ($sub.free+$sub.used -eq 0)
                                {
                                   if ($sub_dh.subnet -eq $sub.subnet)
                                    {
                                      $sub_dh.percentage = "NA"
                                    }
                                }
                                else
                                {
                                    $sub.percentage = $sub.used/($sub.free+$sub.used)*100   
                            
                                    if ($sub_dh.subnet -eq $sub.subnet)
                                    {
                                      $sub_dh.percentage = [math]::Round($sub.percentage,2)
                                    }
                                }
                            }    
                     }

               }#ending if for netsh execution
               else
               {
                    $ser_stat = "" | Select-Object Server,Scope_name,Scope_Address,Description,State,Subnet_Mask, Subnet, Used,Free, Pending, Percentage, Remarks

                    $ser_stat.Server = $server
                    $ser_stat.scope_name = "N/A"
                    $ser_stat.scope_address = "N/A"
                    $ser_stat.description = "N/A"
                    $ser_stat.state = "N/A"
                    $ser_stat.subnet_mask = "N/A"
                    $ser_stat.subnet = "N/A"
                    $ser_stat.used = "N/A"
                    $ser_stat.free = "N/A"
                    $ser_stat.pending = "N/A"
                    $ser_stat.percentage = "N/A"
                    $ser_stat.remarks = "Netsh Error"
                                    
                    $dhcp_stat+=$ser_stat
               }
    }

        #Collecting Ping and Service Status info 
        $dhcp_info+=$ser_info              

$htmlfile = $null

$htmlfile = "
<HTML>
<Title>Report</Title>
<head>
<style type='text/css'> 
#TSHead body {font: normal small sans-serif;}
#TSHead table {border-collapse: collapse; width: 100%; background-color:#F5F5F5;}
#TSHead th {font: normal small sans-serif;text-align:left;padding-top:5px;padding-bottom:4px;background-color:#7FB1B3;}
#TSHead th, td {font: normal small sans-serif; padding: 0.25rem;text-align: left;border: 1px solid #FFFFFF;}
#TSHead tbody tr:nth-child(odd) {background: #D3D3D3;}
</Style>
</head>
<Body>
<h1 align='center'> DHCP Status Report - "+$date+"</h1>"


foreach($info in $dhcp_info)
{
    
    if($info.Ping -eq "Reachable")
    {
        if($info.Dhcp_service -eq "Running")
        {
            $htmlfile+="`r`n" + "<tr><td>"+$info.Server+"</td><td bgcolor=#A6CAA9>"+$info.ping+"</td><td bgcolor=#A6CAA9>" +$info.dhcp_service+"</td></tr>"
        }
        else
        {
            $htmlfile+= "`r`n" +"<tr><td>"+$info.Server+"</td><td bgcolor=#A6CAA9>"+$info.ping+"</td><td bgcolor=#db0000>" +$info.dhcp_service+"</td></tr>"
        }
    }
    else
    {
         $htmlfile+= "`r`n" +"<tr><td>"+$info.Server+"</td><td bgcolor=#db0000>"+$info.ping+"</td><td>" +$info.dhcp_service+"</td></tr>"
    }
}


$htmlfile+="`r`n" + "</table>"

$htmlfile+= "`r`n" +"<table border=1 cellpadding=0 cellspacing=0 width=100% id=TSHead class=sortable>"
$htmlfile+= "`r`n" +"<tr><th>Server Name</th><th>Scope Name</th><th>Scope Address</th><th>Scope Description</th><th>Scope State</th><th>Subnet</th><th>Subnet Mask</th><th>Used IP</th><th>Free IP</th><th>Pending Offers</th><th>Used(%)</th><th>Remarks</th></tr>"
$htmlfile+= "`r`n" +"<h3 align=center>Scope Statistics </h3>"

foreach($stat in $dhcp_stat)
{
    
    if ($stat.Remarks -match "Error")
    {
        $htmlfile+= "`r`n" + "<tr><td bgcolor=#db0000>"+$stat.Server+"</td><td>"+$stat.Scope_name+"</td><td>"+$stat.Scope_Address+"</td><td>"+$stat.Description+"</td><td>"+$stat.State+"</td><td>"+$stat.Subnet+"</td><td>"+$stat.Subnet_Mask+"</td><td>"+$stat.Used+"</td><td>"+$stat.Free+"</td><td>"+$stat.Pending+"</td><td>"+$stat.Percentage+"</td><td bgcolor=#db0000>"+$stat.Remarks+"</td></tr>"
    }
    else
    {
        if($stat.State -match "Active")
        {
            
            if($stat.Percentage -gt 90)
            {
                $htmlfile+= "`r`n" + "<tr><td>"+$stat.Server+"</td><td>"+$stat.Scope_name+"</td><td>"+$stat.Scope_Address+"</td><td>"+$stat.Description+"</td><td>"+$stat.State+"</td><td>"+$stat.Subnet+"</td><td>"+$stat.Subnet_Mask+"</td><td>"+$stat.Used+"</td><td>"+$stat.Free+"</td><td>"+$stat.Pending+"</td><td bgcolor=#db0000>"+$stat.Percentage+"</td><td>"+$stat.Remarks+"</td></tr>"
            }
            else
            {
                $htmlfile+= "`r`n" + "<tr><td>"+$stat.Server+"</td><td>"+$stat.Scope_name+"</td><td>"+$stat.Scope_Address+"</td><td>"+$stat.Description+"</td><td>"+$stat.State+"</td><td>"+$stat.Subnet+"</td><td>"+$stat.Subnet_Mask+"</td><td>"+$stat.Used+"</td><td>"+$stat.Free+"</td><td>"+$stat.Pending+"</td><td bgcolor=#A6CAA9>"+$stat.Percentage+"</td><td>"+$stat.Remarks+"</td></tr>"
            }
        }
        else
        {
             $htmlfile+= "`r`n" + "<tr><td>"+$stat.Server+"</td><td>"+$stat.Scope_name+"</td><td>"+$stat.Scope_Address+"</td><td>"+$stat.Description+"</td><td bgcolor=#db0000>"+$stat.State+"</td><td>"+$stat.Subnet+"</td><td>"+$stat.Subnet_Mask+"</td><td>"+$stat.Used+"</td><td>"+$stat.Free+"</td><td>"+$stat.Pending+"</td><td>"+$stat.Percentage+"</td><td>"+$stat.Remarks+"</td></tr>"
        }
    }
}

$htmlfile+="`r`n" + "</table>"


$htmlfile | Out-File -FilePath "Provide path\dhcp_v3.html"

$attachment = "Provide path\dhcp_v3.html"		
    
Send-MailMessage -From "" -To "" -Subject "" -Body $htmlfile -BodyAsHtml -Attachments $attachment -smtpServer ""