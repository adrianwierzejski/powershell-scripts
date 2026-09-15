$creds = Get-Credential -credential "contoso.local\user"
$date = Get-Date -Format "dd_MM_yyyy_HH_mm"
$server = "XYPL0000001"
$userList = @()
class userClass{
    [string] $Name
    [string] $GivenNameOld
    [string] $SN
    [string] $GivenNameNew
    [string] $NeedUpdate

    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
    userClass([string] $Name, [string] $GivenNameOld, [string] $SN, [string] $GivenNameNew, [string] $NeedUpdate){
        $this.Init(@{ Name=$Name; GivenNameOld=$GivenNameOld; GivenNameNew=$GivenNameNew; NeedUpdate=$NeedUpdate })
    }
}

foreach($line in Get-Content "C:\Temp\ad.csv" ) {
    $array=$($line -split ';')
    $user = [userClass]::new($array[0],$array[1],$array[2],$array[3],$array[4])
    $userList += $user
}
foreach($user in $userList){
    $ADuser = Get-ADUser -Identity $user.Name -Server "$server.contoso.local" -Credential $creds
    $ADuser | select name,department,givenName,sn | Export-Csv -Path "C:\Temp\Users_before_$date.csv" -Append -Encoding UTF8
    if($user.NeedUpdate -eq "FALSE"){
        $ADuser | Set-ADUser -GivenName $user.GivenNameNew -Server "$server.contoso.local" -Credential $creds 
        $ADuser2 = Get-ADUser -Identity $user.Name -Server "$server.contoso.local" -Credential $creds
        $ADuser2 | select name,department,givenName,sn | Export-Csv -Path "C:\Temp\Users_after_$date.csv" -Append -Encoding UTF8
    }
    
}