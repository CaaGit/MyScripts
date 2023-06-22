$cred = Get-Credential -UserName administrator@caannesit.info -Message "Type your Credentials"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://10.0.3.3/PowerShell/ -Authentication Basic -Credential $cred
Import-PSSession $session