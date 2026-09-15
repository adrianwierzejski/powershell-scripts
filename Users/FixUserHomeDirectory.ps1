

$user="UUPL0055100"
$users=Get-ADUser -Identity $user


$logFilePath = "C:\Temp\Scripts\HomeDir_$(Get-Date -Format "MM_dd_yyyy__HH_mm").log"


foreach($userG in $users){

    $serverNumber=$userG.SamAccountName.Substring(4,4)
    $serverHostName="XYpl$($serverNumber)001.contoso.local"
    $serverHomeDir="\\filePL$($serverNumber).global.contoso.local\home$\"

    $user=Get-ADUser -Identity $userG -Properties *
    "$($userG.SamAccountName) $($user.SamAccountName) $($user.UserPrincipalName)" |Out-File -FilePath $logFilePath -Encoding default -Append

    if($user -ne $null -and $user.HomeDirectory -eq $null -and $user.SamAccountName -like "UUPL00*"){
            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Zmiana ustawień dla $($user.SamAccountName)"|Out-File -FilePath $logFilePath -Encoding default -Append
            $userHomeDir="$serverHomeDir$(($user.SamAccountName).ToUpper())"
            if($(Test-Path -Path $userHomeDir -PathType Container) -eq $false){
                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Folder $userHomeDir nie istnieje"|Out-File -FilePath $logFilePath -Encoding default -Append
            
                if($(Test-Path -Path $userHomeDir -PathType leaf) -eq $true){
                    "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Plik o nazwie $userHomeDir istnieje"|Out-File -FilePath $logFilePath -Encoding default -Append
                    "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Zmiany w uzytkowniku nie zostały wprowadzone"|Out-File -FilePath $logFilePath -Encoding default -Append
                    }else{
                         try{
                            New-Item -Path $userHomeDir -Type Directory -Verbose
                            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Folder $userHomeDir został utworzony"|Out-File -FilePath $logFilePath -Encoding default -Append
                            if(Test-Path -Path $userHomeDir){
                                $acl = Get-Acl -Path $userHomeDir
                                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Uprawnienia pliku $($userHomeDir): $($acl| Select *)"|Out-File -FilePath $logFilePath -Encoding default -Append

                                $newRule= New-Object System.Security.AccessControl.FileSystemAccessRule($($user.UserPrincipalName), "FullControl", "ContainerInherit,ObjectInherit","None" ,"Allow")
                                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Nowa regula uprawnien: $($newRule| Select *)"|Out-File -FilePath $logFilePath -Encoding default -Append

                                $acl.AddAccessRule($newRule)
                                Set-Acl -Path $userHomeDir -AclObject $acl -Verbose
                
                                $aclAfter = Get-Acl -Path $userHomeDir
                                #$aclAfter=$acl
                                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Uprawnienia pliku po zmainie $($userHomeDir): $($aclAfter| Select *)"|Out-File -FilePath $logFilePath -Encoding default -Append

                                $aclNonInherited = $aclAfter.Access | Where-Object {$_.IsInherited -eq $false}
                                $aclSamAccountName = $aclNonInherited.IdentityReference.ForEach({$_ -split "\\" | Select -last 1})
                                if([system.String]$aclSamAccountName -eq $($user.SamAccountName)){
                                    "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Uprawnienia zostały zmienione"|Out-File -FilePath $logFilePath -Encoding default -Append
                                    Set-ADUser -Identity $($user.SamAccountName) -HomeDirectory $userHomeDir -HomeDrive Y -Server $serverHostName -Verbose
                                    "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Home directory został zmieniny dla użytkownika"|Out-File -FilePath $logFilePath -Encoding default -Append
                                }
                            }
                    
                    
                        }catch{
                            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") $_ "|Out-File -FilePath $logFilePath -Encoding default -Append
                        }                
                    }
                }else{
                    "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Folder $userHomeDir już istnieje nie wykonano żadnej akcji"|Out-File -FilePath $logFilePath -Encoding default -Append
                }
    }
}