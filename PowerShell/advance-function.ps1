function delete-AzVM {
    [CmdletBinding(supportsshouldprocess = $true)]
    param(
        [parameter(mandatory = $true, valuefrompipeline = $true)]
        [string]$vmname
    )
    process {
        if ($PSCmdlet.ShouldProcess($vmname, "Delete VM")) {
            Write-Host "Deleting VM $vmname"
            # Code to delete the VM goes here
            remove-azvm -name $vmname 
        }
    }
}