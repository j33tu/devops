function test-localhostrdp {
    param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [int]$port,
        [Parameter(mandatory = $true)]
        [string]$hostname
    )
   
    begin {
        write-verbose("Testing $port connectivity on $hostname ...") 
    }
    Process {
        
        $testresult = Test-NetConnection -Port $port -ComputerName $hostname -Debug
        write-verbose("$testresult") 
        if ($testresult.tcptestsucceeded) {
            write-verbose("$port is enabled on local host") 
            return $true
        }
        else {
            write-verbose("$port is NOT enabled on $hostname") 
            return $false
        }
    }
    end {
        write-verbose("Testing completed.") 
    }
}

$portinput = Read-Host("Enter the port number to test")
$hostnameinput = Read-Host("Enter the hostname to test")

$result = test-localhostrdp -port $portinput -hostname $hostnameinput
try {
    if ($result) {
        write-verbose("Port $portinput is open on $hostnameinput , no action needed ")
    }
    else {
        write-verbose("Port $portinput is closed on $hostnameinput") 
        $reply = Read-Host("you want to enable it ? (Y/N)")
        if ($reply -eq "Y") {
            write-verbose("Enabling port $portinput on $hostnameinput...") 
            start-service -name "wlidsvc" -ErrorAction Stop
            write-verbose("service started ") -ForegroundColor Green
        }
    }

}
catch {
    write-verbose("An error occurred while testing the port.") 
}
finally {
    write-verbose("Script execution completed.") 
}

