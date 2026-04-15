$rgs = get-azresourcegroup
$azrg = @()
foreach ($rg in $rgs) {
    $obj = [PSCustomObject]@{
        Name     = $rg.ResourceGroupName
        Location = $rg.Location
    }
    $azrg += $obj 
}
$azrg
