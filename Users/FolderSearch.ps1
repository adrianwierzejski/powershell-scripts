for($i =1; $i -lt 100; $i++ ){
	try{
		$tmp=$i.ToString('0000')
		Get-ChildItem -Path "\\XYpl$($tmp)001\c$\Temp\YourFolder" -ErrorAction Stop
	}catch{
	
	}
}