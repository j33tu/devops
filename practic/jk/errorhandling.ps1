$vnetinput = read-host "provide name of the vnet to be created"
$rgName = "compute"
$location = "South India"
$vnetName = $vnetinput
$vnetAddress = "10.0.0.0/16"
$snetName = "Subnet-Frontend"
$snetAddress = "10.0.1.0/24"
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $snetName -AddressPrefix $snetAddress
try {
    $vnet = New-AzVirtualNetwork -Name $vnetName `
        -ResourceGroupName $rgName `
        -Location $location `
        -AddressPrefix $vnetAddress `
        -Subnet $subnetConfig `
        -Tag @{Environment = "Production"; Owner = "Jitendra" } -ErrorAction Stop

    Write-Host "VNet $($vnet.Name) deployed successfully in $($vnet.Location)." -ForegroundColor Cyan
}

catch {
    Write-Host "VNet $($vnet.Name) did not  deploy successfully in $($vnet.Location)." -ForegroundColor Red
}
finally {
    Write-Host "VNet $($vnet.Name) deployed attempted in $($vnet.Location)." -ForegroundColor Cyan
}