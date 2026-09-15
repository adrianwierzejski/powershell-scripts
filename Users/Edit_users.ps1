$serverNumber="0018"
$serverHostName="XYpl$($serverNumber)001.contoso.local"
$usersCSV = Import-Csv -path 'C:\Temp\Scripts\Site_0018.csv' -Delimiter ','

foreach($user in $usersCSV){
    $groupsToAdd = $user.psobject.Properties | Where-Object { $_.name -Like "GG*" -or $_.name -like "GL*" -and $_.value -eq "TRUE"} | select name
    Write-Host
    Write-Host $user.SamAccountName
    foreach($group in $groupsToAdd){
        Add-ADGroupMember -Identity $($group.Name) -Members $($user.SamAccountName) -Server $serverHostName
    }
    $groupsToAdd | Write-Host
    
    $groupsToDelete = $user.psobject.Properties | Where-Object { $_.name -Like "GG*" -or $_.name -like "GL*" -and $_.value -eq "FALSE"} | select name
    foreach($group in $groupsToDelete){
        Remove-ADGroupMember -Identity $($group.Name) -Members $($user.SamAccountName) -Server $serverHostName -Confirm:$false
    }
}