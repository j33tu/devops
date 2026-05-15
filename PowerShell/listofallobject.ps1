$resourcegroups = [System.Collections.Generic.list[System.Object]]::new()


$rg = get-azresourcegroup

foreach ($r in $rg ) {
    $object = [pscustomobject]@{
        name              = $r.ResourceGroupName
        location          = $r.Location
        ProvisioningState = $r.ProvisioningState
    }
    $resourcegroups.add($object)
}

$resourcegroups
