function write-Message {
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



$users=Get-ADGroupMember -Identity "Group_name"


$logFilePath = "C:\Temp\Nadzor_$(Get-Date -Format "MM_dd_yyyy__HH_mm").log"

$groupName="New_group_name"

foreach($user in $users){

$serverNumber=$user.SamAccountName.Substring(4,4)
$groupNameNew = $groupName.Replace("XXXX",$serverNumber)

Write-Message -message "$($user.SamAccountName) $($user.UserPrincipalName) Nazwa grupy: $($groupNameNew)" -filePath $path

Add-ADGroupMember -Identity $($groupNameNew) -Members $($user.SamAccountName) -Verbose

}

