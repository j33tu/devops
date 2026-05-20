function Remove-LabVM {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$VMName
    )

    process {
        # This is the "Safety Gate"
        # If the user types -WhatIf, this 'if' block is skipped automatically
        if ($PSCmdlet.ShouldProcess($VMName, "Permanently deleting the VM from the Lab Environment")) {
            
            Write-Host "Action Confirmed! Contacting Azure API to remove $VMName..." -ForegroundColor Cyan
            
            # This is where your actual destructive code lives
            # Invoke-AzRestMethod -Method DELETE -Url "..."
            
            Write-Host "Success: $VMName has been removed." -ForegroundColor Green
        }
    }
}