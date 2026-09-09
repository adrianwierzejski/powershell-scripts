$Domain="contoso.local"
$ServerCount=100
$Prefix="XYpl"
$Postfix="001"
for($i = 0; $i -lt $ServerCount; $i++){
$ServerNumber=$i.ToString('0000')
	try{
		$DHCPv4Scope =Get-DhcpServerv4Scope -ComputerName "$($Prefix)$($ServerNumber)$($Postfix).$($Domain)" -ErrorAction Stop
		Write-Host "$($Prefix)$($ServerNumber)$($Postfix).$($Domain) dhcp options"
		Get-DhcpServerv4OptionValue -ComputerName "$($Prefix)$($ServerNumber)$($Postfix).$($Domain)" -All
		foreach ($Scope in $DHCPv4Scope){
            Write-Host "$($Prefix)$($ServerNumber)$($Postfix).$($Domain) ScopeId: $($Scope.ScopeId) Vlan: $($Scope.Name) Vlan Options:"
		    Get-DhcpServerv4OptionValue -ComputerName "$($Prefix)$($ServerNumber)$($Postfix).$($Domain)" -ScopeId $Scope.ScopeId -All
		}
        Write-Host ""
	}catch{
		
	}
}