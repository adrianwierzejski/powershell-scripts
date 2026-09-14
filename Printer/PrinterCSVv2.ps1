$Server="XYpl0000001"
$Domain="contoso.local"

$inPrinterCSV=Get-Content -Path "\\$Server.$($Domain)\ChangeMe\printer.csv"
$hostname="CYPL0055030"

class Printer{
    $Target
    $Printer_Hostname
    $Driver_type
    $Port
    $Name
    $Driver
    $Default
    $Location
    $Comment
    Printer($line){
        $this.Target=$line[0]
        $this.Printer_Hostname=$line[1]
        $this.Driver_type=$line[2]
        $this.Port=$line[3]
        $this.Name=$line[4]
        $this.Driver=$line[5]
        $this.Default=$line[6]
        $this.Location=$line[7]
        $this.Comment=$line[8]
    }
    [string] toString(){
    return "$($this.Target);$($this.Printer_Hostname);$($this.Driver_type);$($this.Port);$($this.Name);$($this.Driver);$($this.Default);$($this.Location);$($this.Comment)"
    
    }
}

foreach($line in $inPrinterCSV){
        $tmp = $line -split ";"
        if($tmp.Length -eq 9){
            $printer = [Printer]::new($tmp)
            if($($printer.Target).Length -eq 4){
                try{
		            Add-PrinterPort -ComputerName "$hostname.$($Domain)" -Name "$($printer.Printer_Hostname)" -PrinterHostAddress "$($printer.Printer_Hostname)" -ErrorAction Stop
		        }catch {
                    Write-Host "Hostname: $hostname Printer: $($printer.Printer_Hostname)"
                    Write-Host "An error occurred: $_"
                }
                try{
                    Add-Printer -ComputerName "$hostname.$($Domain)" -Name "$($printer.Name)" -DriverName "$($printer.Driver)" -PortName "$($printer.Printer_Hostname)" -ErrorAction Stop
                }catch {
                    Write-Host "Hostname: $hostname Printer: $($printer.Printer_Hostname)"
                    Write-Host "An error occurred: $_"
                }

            }else{
                continue
            }
        }else{
             Write-Host "Problem with record: $tmp"
        }
}
