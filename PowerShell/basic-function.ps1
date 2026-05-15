function get-status {
    [cmdletbinding()]
    param(
        [parameter(mandatory = $true, ValueFromPipeline = $true)]
        [string]$name
    )    
 
    try {
        write-host "Checking status of service: $name" -ForegroundColor Cyan
    
        # FIX: Put the Stop action on the command that actually fails
        $status = Get-Service $namea -ErrorAction Stop | Select-Object -ExpandProperty Status
    
        write-host "Service $name is $status" -ForegroundColor Green
    }
    catch {
        # This will now catch the "Service not found" error
        write-host "FAILED to check service $name. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        write-host "Execution completed."
    }



}