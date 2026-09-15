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

foreach($user in $usersCSV){
    Write-Message -message "Aktualny użytkownik $user" -filePath $path
    if($user.UserPrincipleName -eq "0"){
        Write-Message -message "Użytkownik  $($user.Store) $($user.UserPrincipleName) błędne dane" -filePath $path
    }else{
        $userAD = Get-ADUser -Filter "UserPrincipalName -eq `"$($user.UserPrincipleName)`"" -Properties * -Server "XYpl0050001.contoso.local"
        if($userAD -ne $null ){

            if($($userAD.SamAccountName.Substring(2,6)) -eq $($user.Store)){
														   

                $serverNumber = $userAD.SamAccountName.Substring(4,4)
                $serverHostName="XYpl$($serverNumber)001.contoso.local"
																		
				foreach($permission in $permissionsCSV){
					if($user.title_no_PL_chars -eq $($permission.title_no_PL_chars) ){
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

            }else{
                Write-Message -message "Użytkownika znajduje się w innym markecie Store z CSV: $($user.Store) Store z AD: $($userAD.SamAccountName.Substring(2,6)) $($user.UserPrincipleName) nie znaleziono w AD" -filePath $path
            }
        
        }else{
            Write-Message -message "Użytkownika $($user.Store) $($user.UserPrincipleName) nie znaleziono w AD" -filePath $path
        }
    
    }
    
}