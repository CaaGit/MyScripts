#Provide the destination DC in which you want to transfer the fsmo role

$date = Get-Date -Format yyyyMMddTHHmm
#Choose the role you want to transfer

function Show-Menu {
    param (
        [string]$Title = 'Metro Lisboa - FSMORoles Move'
    )
    Clear-Host
    Write-Host "================ $Title ================"  -ForegroundColor DarkRed -BackgroundColor White
    
    Write-Host ""
    Write-Host ""
    Write-Host ""

    Write-Host "Press '0' to get FSMORoles."
    Write-Host "1: Press '1' to move only role DomainNamingMaster."
    Write-Host "2: Press '2' to move only role PDCEmulator."
    Write-Host "3: Press '3' to move only role RIDMaster."
    Write-Host "4: Press '4' to move only role SchemaMaster."
    Write-Host "5: Press '5' to move only role InfrastructureMaster."
    Write-Host "6: Press '6' to move All Roles."
    Write-Host "E: Press 'E' to Exit." -ForegroundColor Yellow

    Write-Host ""
    Write-Host ""
    Write-Host ""

}

do {
    Show-Menu
    Write-Host "Enter the desired option" -ForegroundColor Black -BackgroundColor Yellow                            
    $Option = read-host 
    Switch($Option)
        {

    #This will transfer DomainNamingMaster role to destination server

    "1"{

        $destinationdc= Read-Host "Provide the Destination domain controller"
        Write-Host ""
        Write-Host ""
        Write-Host "You select to move Role DomainNamingMaster to $destinationdc" -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "Press Enter to continue"
        Write-Host ""
        Write-Host ""
    try {      
        Move-ADDirectoryServerOperationMasterRole -OperationMasterRole DomainNamingMaster -Identity $destinationDc -confirm:$false
        }
      catch
      {
        if ($PSItem -eq $null){
        Write-host "PDCEmulator is transferred successfully to $destinationDc" -ForegroundColor Green
            }
            else {
                    Write-Output "Ran into an issue: $PSItem"
               }
            }
       netdom query fsmo |Select-String "PDC"
      }

#This will transfer PDCEmulator role to destination server

    "2"{
        
       try {

        $destinationdc= Read-Host "Provide the Destination domain controller"
        Write-Host ""
        Write-Host ""
        Write-Host "You select to move Role PDCEmulator to $destinationdc" -ForegroundColor Black -BackgroundColor Yellow
        Read-Host "Press Enter to continue"
        Write-Host ""
        Write-Host ""
        
        Move-ADDirectoryServerOperationMasterRole -OperationMasterRole PDCEmulator -Identity $destinationDc -confirm:$false
        }
      catch
      {
        if ($PSItem -eq $null){
        Write-host "PDCEmulator is transferred successfully to $destinationDc" -ForegroundColor Green
            }
            else {
                    Write-Output "Ran into an issue: $PSItem"
               }
            }
       netdom query fsmo |Select-String "PDC"
      }      

#This will transfer RID pool manager role to destination server

    "3"{

        Try {

        $destinationdc= Read-Host "Provide the Destination domain controller"
        Write-Host ""
        Write-Host ""
        Write-Host "You select to move Role RIDMaster to $destinationdc" -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "Press Enter to continue"
        Write-Host ""
        Write-Host ""
        
        Move-ADDirectoryServerOperationMasterRole -OperationMasterRole RIDMaster -Identity $destinationDc -confirm:$false
        }
         
                 
      catch

      {
        if ($PSItem -eq $null){
        Write-host "RIDMaster is transferred successfully to $destinationDc" -ForegroundColor Green
            }
            else {
                    Write-Output "Ran into an issue: $PSItem"
               }
        }  
         netdom query fsmo |Select-String "RID pool manager"
        }


#This will transfer Schema Master role to destination server

   "4" {

        $destinationdc= Read-Host "Provide the Destination domain controller"
        Write-Host ""
        Write-Host ""
        Write-Host "You select to move Role SchemaMaster to $destinationdc" -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "Press Enter to continue"
        Write-Host ""
        Write-Host ""
         Move-ADDirectoryServerOperationMasterRole -OperationMasterRole SchemaMaster -Identity $destinationDc -confirm:$false

         Write-host "SchemaMaster is transferred successfully to $destinationDc" -ForegroundColor Green

         netdom query fsmo |Select-String "Schema Master"
        }

#This will transfer Infrastructure Master role to destination server

    "5"{

    try{
         $destinationdc= Read-Host "Provide the Destination domain controller"
        Write-Host ""
        Write-Host ""
        Write-Host "You select to move Role InfrastructureMaster to $destinationdc" -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "Press Enter to continue"
        Write-Host ""
        Write-Host ""
         Move-ADDirectoryServerOperationMasterRole -OperationMasterRole InfrastructureMaster -Identity $destinationDc -Credential  -confirm:$false
        }

                         
      catch

      {
        if ($PSItem -eq $null){
        Write-host "InfrastructureMaster is transferred successfully to $destinationDc" -ForegroundColor Green
            }
            else {
                    Write-Output "Ran into an issue: $PSItem"
               }
        }  
         Write-host "InfrastructureMaster is transferred successfully to $destinationDc" -ForegroundColor Green

         netdom query fsmo |Select-String "Infrastructure Master"
        }

#This will transfer All roles to destination server

    "6"{

        try{

        $destinationdc= Read-Host "Provide the Destination domain controller"
        Write-Host ""
        Write-Host ""
        Write-Host "You select to move All Roles to $destinationdc" -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "Press Enter to continue"
        Write-Host ""
        Write-Host ""
        Move-ADDirectoryServerOperationMasterRole -OperationMasterRole DomainNamingMaster,PDCEmulator,RIDMaster,SchemaMaster,InfrastructureMaster -Identity $destinationDc  -confirm:$false -ErrorVariable
        }

           catch

      {
        if ($PSItem -eq $null){
        Write-host "InfrastructureMaster is transferred successfully to $destinationDc" -ForegroundColor Green
            }
            else {
                    Write-Output "Ran into an issue: $PSItem"
               }
        }  
         Write-host "InfrastructureMaster is transferred successfully to $destinationDc" -ForegroundColor Green


         Write-host "All roles were transferred successfully to $destinationDc" -ForegroundColor Green

         netdom query fsmo
        }


  
    "0"{

        $domain = read-host "Provide the domain name"
        Write-Host ""
        Write-Host ""
        
        $Forest = Get-ADForest $domain | fl SchemaMaster,DomainNamingMaster
        $ADDomain = Get-ADDomain $domain | fl PDCEmulator,RIDMaster,InfrastructureMaster
        $File = "FSMORoles" + "$date.txt" 
        $Forest  | Out-File "C:\$File"
        $ADDomain | Out-File "C:\$File" -Append

        Write-host "Export FSMO Role successfully to c:\FSMORoles.txt" 
        Write-Host ""
        Write-Host ""
        }

    }

    pause
 }
 until ($Option -eq 'E')
