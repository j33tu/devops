function get-lservice {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(mandatory = $true, valuefrompipeline = $true)]
        [string]$sirname
    )
    begin {
        write-host "starting process"
    }
    process {
        if ($pscmdlet.ShouldProcess("checking for service ")) {
            start-service -name $sirname
        }

    }
    end {
        write-host "process ending" 
    }
}