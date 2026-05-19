class mg {
    #properties
    [string]$name
    [string]$model
    [string]$servicestatus
    [string]$number
    #constructor
    mg([string]$n, [string]$m, [string]$number) {
        $this.name = $n
        $this.model = $m
        $this.servicestatus = "pending"
        $this.number = $number
    }
    #method
    servicedone() {
        $this.servicestatus = "service done"
        write-host "car $($this.name), $($this.number)      is serviced"
    }
}

$cardetails = [System.Collections.Generic.list[object]]::new()
