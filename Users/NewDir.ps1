$markets=@("0050","0060","0070")


$logFilePath = "C:\Temp\Scripts\NewDir$(Get-Date -Format "MM_dd_yyyy__HH_mm").log"


foreach($market in $markets){
$serverNumber=$market
$serverHostName="XYpl$($serverNumber)001.contoso.local"
$serverDir="\\filePL$($serverNumber).global.contoso.local\Shared"
$newDir="NewDirName"
$pathNewDir="$serverDir\$newDir"

#New-ADGroup -Name "GGPL$($serverNumber)006_NewDirName" -SamAccountName "GGPL$($serverNumber)006_NewDirName" -GroupCategory Security -GroupScope Global -DisplayName "GGPL$($serverNumber)006_NewDirName" -Path "DC=contoso,DC=local" -Verbose
#Add-ADGroupMember -Identity "GL_File_H_NewDirName_C" -Members "GGPL$($serverNumber)006_NewDirName" -Verbose

$disableInheritance = $true    #$false             # Wylacz dziedziczenie dla folderu 
$preserveInheritance = $false               # Zachowaj wpisy odziedziczone wpisy z uprawnieniami

Write-Host "Wybrano market to PL$serverNumber"
"$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Wybrano market to PL$serverNumber"|Out-File -FilePath $logFilePath -Encoding default -Append
        "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Zmiana ustawień dla $($serverDir)\$filedir"|Out-File -FilePath $logFilePath -Encoding default -Append
        if($(Test-Path -Path $pathNewDir -PathType Container) -eq $false){
            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Folder $pathNewDir nie istnieje"|Out-File -FilePath $logFilePath -Encoding default -Append
            
            if($(Test-Path -Path $pathNewDir -PathType leaf) -eq $true){
                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Plik o nazwie $pathNewDir istnieje"|Out-File -FilePath $logFilePath -Encoding default -Append
                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Zmiany w uzytkowniku nie zostały wprowadzone"|Out-File -FilePath $logFilePath -Encoding default -Append
                continue
                }
            try{
                New-Item -Path $pathNewDir -Type Directory -Verbose
                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Folder $pathNewDir został utworzony"|Out-File -FilePath $logFilePath -Encoding default -Append
            }catch{
                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") $_ "|Out-File -FilePath $logFilePath -Encoding default -Append
                continue
            }
            }else{
                "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Folder $pathNewDir już istnieje"|Out-File -FilePath $logFilePath -Encoding default -Append
            }
        if(Test-Path -Path $pathNewDir){
            $acl = Get-Acl -Path $pathNewDir
            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Uprawnienia pliku $($pathNewDir): $($acl| Select *)"|Out-File -FilePath $logFilePath -Encoding default -Append
            
            $acl = New-Object System.Security.AccessControl.DirectorySecurity
            $acl.SetAccessRuleProtection($disableInheritance, $preserveInheritance)

            $newRule = New-Object System.Security.AccessControl.FileSystemAccessRule("CREATOR OWNER", "Modify", "ContainerInherit,ObjectInherit","InheritOnly" ,"Allow")
            $acl.AddAccessRule($newRule)
            
            $newRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit,ObjectInherit","None" ,"Allow")
            $acl.AddAccessRule($newRule)

            $newRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit,ObjectInherit","None" ,"Allow")
            $acl.AddAccessRule($newRule)
            
            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Uprawnienia pliku $($pathNewDir): $($acl| Select *)"|Out-File -FilePath $logFilePath -Encoding default -Append

            #$newRule= New-Object System.Security.AccessControl.FileSystemAccessRule("", "FullControl", "ContainerInherit,ObjectInherit","None" ,"Allow")
            $newRule= New-Object System.Security.AccessControl.FileSystemAccessRule("STORENET\GL_File_H_NewDirName_C", "Modify", "ContainerInherit,ObjectInherit","None" ,"Allow")
            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Nowa regula uprawnien: $($newRule| Select *)"|Out-File -FilePath $logFilePath -Encoding default -Append

            $acl.AddAccessRule($newRule)
            Set-Acl -Path $pathNewDir -AclObject $acl -Verbose
                
            $aclAfter = Get-Acl -Path $pathNewDir
            "$(Get-Date -Format "[MM/dd/yyyy HH:mm]") Uprawnienia pliku po zmainie $($pathNewDir): $($aclAfter| Select *)"|Out-File -FilePath $logFilePath -Encoding default -Append

            
        } 
    
}    