$printers=@("PYPL0000001","PYPL0000002","PYPL0000001")
$printersDomain="contoso.local"
$computers=@("CYPL0055030","CYPL0055029","CYPL0055028","CYPL0055027")
$computersDomain="contoso2.local"
foreach($hostname in $computers){
	foreach($printer in $printers){
        try{
		    Add-PrinterPort -ComputerName "$hostname.$($computersDomain)" -Name "$printer.$($printersDomain)" -PrinterHostAddress "$printer.$($printersDomain)" -ErrorAction Stop
		}catch {
            Write-Host "Hostname: $hostname Printer: $printer"
            Write-Host "An error occurred: $_"
        }
        try{
            Add-Printer -ComputerName "$hostname.$($computersDomain)" -Name "$printer" -DriverName "SHARP MX-3071 PCL6" -PortName "$printer.$($printersDomain)" -ErrorAction Stop
        }catch {
            Write-Host "Hostname: $hostname Printer: $printer"
            Write-Host "An error occurred: $_"
        }
	}
}