function Get-AzureInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Environment
    )

    Write-Verbose "Connecting to $Environment API..."
    # This only shows up if you run: Get-AzureInventory -Environment "Prod" -Verbose
}