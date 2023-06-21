$myRepInfo = @(repadmin /replsum * /bysrc /bydest /sort:delta)
 
# Initialize our array.
$cleanRepInfo = @()
   # Start @ #10 because all the previous lines are junk formatting
   # and strip off the last 4 lines because they are not needed.
    for ($i=10; $i -lt ($myRepInfo.Count-4); $i++) {
            if($myRepInfo[$i] -ne ""){
            # Remove empty lines from our array.
            $myRepInfo[$i] -replace '\s+', " "           
            $cleanRepInfo += $myRepInfo[$i]            
            }
            }           
$finalRepInfo = @()  
            foreach ($line in $cleanRepInfo) {
            $splitRepInfo = $line -split '\s+',8
            if ($splitRepInfo[0] -eq "Source") { $repType = "Source" }
            if ($splitRepInfo[0] -eq "Destination") { $repType = "Destination" }
           
            if ($splitRepInfo[1] -notmatch "DSA") {      
            # Create an Object and populate it with our values.
           $objRepValues = New-Object System.Object
               $objRepValues | Add-Member -type NoteProperty -name DSAType -value $repType # Source or Destination DSA
               $objRepValues | Add-Member -type NoteProperty -name Hostname  -value $splitRepInfo[1] # Hostname
               $objRepValues | Add-Member -type NoteProperty -name Delta  -value $splitRepInfo[2] # Largest Delta
               $objRepValues | Add-Member -type NoteProperty -name Fails -value $splitRepInfo[3] # Failures
               #$objRepValues | Add-Member -type NoteProperty -name Slash  -value $splitRepInfo[4] # Slash char
               $objRepValues | Add-Member -type NoteProperty -name Total -value $splitRepInfo[5] # Totals
               $objRepValues | Add-Member -type NoteProperty -name "% Error"  -value $splitRepInfo[6] # % errors  
               $objRepValues | Add-Member -type NoteProperty -name ErrorMsg  -value $splitRepInfo[7] # Error code
          
            # Add the Object as a row to our array   
            $finalRepInfo += $objRepValues
           
            }
            }
$html = $finalRepInfo|ConvertTo-Html -Fragment       
           
$xml = [xml]$html

$attr = $xml.CreateAttribute("id")
$attr.Value='diskTbl'
$xml.table.Attributes.Append($attr)


$rows=$xml.table.selectNodes('//tr')
for($i=1;$i -lt $rows.count; $i++){
    $value=$rows.Item($i).LastChild.'#text'
    if($value -ne $null){
       $attr=$xml.CreateAttribute('style')
       $attr.Value='background-color: red;'
       [void]$rows.Item($i).Attributes.Append($attr)
    }
   
    else {
       $value
       $attr=$xml.CreateAttribute('style')
       $attr.Value='background-color: green;'
       [void]$rows.Item($i).Attributes.Append($attr)
    }
}

#embed a CSS stylesheet in the html header
$html=$xml.OuterXml|Out-String
$style='<style type=text/css>#diskTbl { background-color:black ; } 
td, th { border:1px solid black; border-collapse:collapse; }
th { color:black; background-color:yellow; }
table, tr, td, th { padding: 2px; margin: 0px } table { margin-left:50px; }</style>'


ConvertTo-Html -head $style -body $html -Title " AD Replication Report"|Out-File C:\Scripts_new\Replication\ReplicationReport.htm

$html1=get-content C:\Scripts_new\Replication\ReplicationReport.htm
$smtpServer = ""
$smtpFrom = ""
$smtpTo = ""
$messageSubject = ""
 
$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
$message.Subject = $messageSubject
$message.IsBodyHTML = $true
 
$message.Body =$html1
 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($message)

#send-MailMessage  -From "Replication@lycra.mail.onmicrosoft.com" -to "dhrub.bharali@capgemini.com" -Subject "Lycra AD Replication Report(Do not reply)" -SmtpServer "lycra-com.mail.protection.outlook.com" -body  -BodyAsHtml