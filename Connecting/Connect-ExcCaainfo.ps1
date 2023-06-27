#$cred = Get-Credential -UserName "administrator@caannesit.info" -Message "Type your Credentials"
#$cred | Export-Clixml -Path "F:\PSEncrypt\Info.xml"


$cred = Import-Clixml -Path "F:\PSEncrypt\Info.xml"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://10.0.3.3/PowerShell/ -Authentication Basic -Credential $cred
Import-PSSession $session
