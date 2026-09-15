$logDir = "C:\Temp"
if($(Test-Path -Path $logDir) -eq $false){
    $logDir = Get-Location
}
$logFilePath = "$($logDir)\HomeDirectory$(Get-Date -Format "MM_dd_yyyy__HH_mm").log"

$market=$null
do{
    try{
        [System.Int32]$market=Read-Host "Podaj numer site-u. [Liczba z przedzialu 0-9999]"
    }catch{
        Write-Host "Podaj poprawną wartosc"
        $market=-1
    }

}while($market -lt 0 -or $market -gt 9999)

$serverNumber=$($market.toString('0000'))
$userFilter="SamAccountName -like `"UUPL$($serverNumber)*`" -or SamAccountName -like `"UYPL$($serverNumber)*`""
$serverHostName="XYpl$($serverNumber)001.contoso.local"
$serverHomeDir="\\filePL$($serverNumber).global.contoso.local\home$\"

Write-Host "Wybrany site to PL$serverNumber"

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
$tableHeader | out-file -FilePath "$($logDir)\Site$serverNumber.csv" -Append -Encoding default
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
    $tableRow | out-file -FilePath "$($logDir)\Site$serverNumber.csv" -Append -Encoding default
}




