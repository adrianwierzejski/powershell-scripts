function Write-Message {
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $message,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $filePath
    )
    Write-Host "$(Get-Date -Format "MM_dd_yyyy__HH_mm"): $message"
    "$(Get-Date -Format "MM_dd_yyyy__HH_mm"): $message" | Out-File -FilePath $filePath -Encoding default -Append
}

$path = "C:\Temp\Scripts\fix_user_groups_$(Get-Date -Format "MM_dd_yyyy__HH_mm").log"

$usersCSV = Import-Csv -path 'C:\Temp\Scripts\users2.csv' -Delimiter ',' -Encoding Default
$permissionsCSV = Import-Csv -path 'C:\Temp\Scripts\groups.csv' -Delimiter ',' -Encoding Default

foreach($user in $($usersCSV.UserPrincipleName)){

    $userAD = Get-ADUser -Filter "UserPrincipalName -eq `"$user`"" -Properties * -Server "XYpl0050001.contoso.local"
    if($userAD -eq $null ){
        Write-Message -message "Użytkownika $user nie znaleziono w AD" -filePath $path
        continue
    }


    $serverNumber = $userAD.SamAccountName.Substring(4,4)
    $serverHostName="XYpl$($serverNumber)002.contoso.local"

    $userAD = Get-ADUser -Filter "UserPrincipalName -eq `"$user`"" -Properties * -Server $serverHostName
    if($userAD -eq $null ){
        Write-Message("Użytkownika $userAD nie znalezionow w AD",$path)
        continue
    }

    $userADTitle=$userAD.Title.split(",").GetValue(0)
    
    foreach($permission in $permissionsCSV){
        if($userADTitle -eq $($permission.Title)){
            $groupsToAdd = $permission.psobject.Properties | Where-Object { $_.name -Like "GG*" -or $_.name -like "GL*" -and $_.value -eq "TRUE"} | select name
            foreach($group in $groupsToAdd){
                if($($group.Name) -like "*XXXX*"){
                    $group.Name = $group.Name.Replace("XXXX",$serverNumber)
                }
                Write-Message -message "$($userAD.SamAccountName) $($userAD.UserPrincipalName) Dodane grupa:$($group.Name)" -filePath $path
                Add-ADGroupMember -Identity $($group.Name) -Members $($userAD.SamAccountName) -Server $serverHostName -Verbose
            }
        
        }
    }
}