function get-azurevnetinventory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $true)]
        [string]$rgname
    )
    begin {
        Write-Verbose "connecting to azure "
    }
    Process {
        if ($PSCmdlet.ShouldProcess("Getting inventory for $rgname")) {
            $vnetinventory = Get-AzVirtualNetwork -ResourceGroupName $rgname | Select-Object Name, Location, AddressSpace, Subnets
    
            #}
        }
        end {
            Write-Verbose "finished getting inventory"
            return $vnetinventory
        }

    }
