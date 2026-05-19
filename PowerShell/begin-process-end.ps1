class highway {
    #properties
    [string]$NHID
    [string]$cost
    [string]$lenght
    [string]$status

    #constructor
    highway([string]$NHID, [string]$cost, [string]$lenght) {
        $this.NHID = $NHID
        $this.cost = $cost
        $this.lenght = $lenght
        $this.status = "closed"
    }

    #method
    open() {
        $this.status = "open"
        write-host " highway  $($this.NHID) is now Open , made with cost of $($this.cost) MINR and lenght of $($this.lenght) KM"
    }
    close() {
        $this.status = "closed"
        write-host " highway  $($this.NHID) is now Closed"
    }
}
$NH44 = [highway]::new("NH44", "10M", "2000")
$NH48 = [highway]::new("NH48", "15M", "2500")
$NH01 = [highway]::new("NH01", "30M", "4560")

$indiahighways = @($NH44, $NH48, $NH01)

function show-highwaydetails {
    
    param(
        [parameter(valuefrompipeline = $true)]
        [highway]$highway
    )
    begin {
        $highway
    }
    Process {
        foreach ($h in $highway) {
            write-host "Highway ID: $($h.NHID) , Cost: $($h.cost) , Lenght: $($h.lenght) , Status: $($h.status)"
        }
    }
    end {
        write-host  'All highway details are displayed'
    }
}

show-highwaydetails