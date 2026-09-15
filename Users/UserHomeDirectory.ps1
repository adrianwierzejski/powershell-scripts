$markets=@("0018")

$logFilePath = "C:\Temp\Scripts\HomeDirectory$(Get-Date -Format "MM_dd_yyyy__HH_mm").log"

foreach($market in $markets){
    $serverNumber=$market
    $userFilter="SamAccountName -like `"UUPL$($serverNumber)*`" -or SamAccountName -like `"UYPL$($serverNumber)*`""
    $serverHostName="XYPL$($serverNumber)001.contoso.local"
    $serverHomeDir="\\filePL$($serverNumber).global.contoso.local\home$\"

    Write-Host "Wybrano market to PL$serverNumber"
    $outFile = "C:\Temp\Scripts\Logs\Site$($serverNumber)_$(Get-Date -Format "MM_dd_yyyy__HH_mm").csv"

    $users=Get-ADUser -Filter $userFilter -Properties * -Server $serverHostName
    $groupsAD=@()     
    foreach($user in $users){
        foreach($group in $user.MemberOf){
            if($group -notin $groupsAD){
                $groupsAD+=$group
            }
        }
    }
    $groupsAD = $groupsAD |Sort-Object
    $tableHeader = "SamAccountName,Enabled,HomeDirectory,Title"
    foreach($group in $groupsAD){
        $tableHeader += $($group -split "," -replace "CN=","," | Select -First 1)
    }
    $tableHeader | out-file -FilePath $outFile -Append -Encoding default
    foreach($user in $users){
        $tableRow=""
        $tableRow +=$($user.SamAccountName)
        $tableRow +=",$($user.Enabled)"
        $tableRow +=",$($user.HomeDirectory)"
        $tableRow +=",$($($user.Title) -replace ",",".")"
        foreach($group in $groupsAD){
            if($group -in $user.MemberOf){
                $tableRow+=",True"
            }else{
                $tableRow+=",False"
            }
        }
        $tableRow | out-file -FilePath $outFile -Append -Encoding default
    }
}