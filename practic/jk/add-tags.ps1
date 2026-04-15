function add-azrgtags {
    [cmdletbinding()]
    param (
        #Parameter help description
        [Parameter(Mandatory = $true, HelpMessage = "Enter the name of the resource group to which you want to add tags.")]
        [string]$subid
    )
    
    begin {
        write-host("connecting to azure and setting up context")
        Connect-AzAccount
        #Get-AzsSubscription -name $subname
        set-azcontext -Subscription $subid 
        
    }
    Process {
        $rgname = Get-AzResourceGroup
        foreach ($rg in $rgname) {
            try {
                $tags = @{ "Environment" = "Production"; "Department" = "IT" }
                Set-AzResourceGroup -Name $rg.ResourceGroupName -Tag $tags -ErrorAction stop
                Write-Host("Tags added to resource group: $($rg.ResourceGroupName)")
            }
            catch {
                Write-Host("An error occurred while adding tags to resource group: $($rg.ResourceGroupName). Error: $_")
            }
       
        } 
           
       
    }
    end {
        Write-Host("All operations completed.")
    }
}
