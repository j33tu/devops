function remove-customerrg {
    [cmdletbinding()]
    param(
        [parameter(mandatory = $true)]
        [string]$rgname,
        [parameter(mandatory = $true)]
        [string]$location
    )
    begin {
        connect-azaccount 
    }
    process {
        write-host ("Starting process to remove resource group: " + $rgname)
        Remove-AzResourceGroup -Name $rgname -Force -verbose
    }
    end {
        write-host ("Process completed for resource group: " + $rgname)
    }
}