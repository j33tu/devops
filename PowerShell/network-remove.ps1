# Get all Network Watchers
$watchers = Get-AzNetworkWatcher

foreach ($watcher in $watchers) {
    Write-Host "Deleting Network Watcher: $($watcher.Name) in Resource Group: $($watcher.ResourceGroupName)"
    Remove-AzNetworkWatcher -Name $watcher.Name -ResourceGroupName $watcher.ResourceGroupName 
}