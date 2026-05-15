# Weekend-ScaleDown-Runbook.ps1
# Trigger: Friday 8PM via Azure Automation Schedule

param(
    [string]$ResourceGroupName = "RG-AVD",
    [string]$HostPoolName = "HostPool-Pooled-01",
    [int]$DrainWaitMinutes = 30
)

Connect-AzAccount -Identity  # Managed Identity

$sessionHosts = Get-AzWvdSessionHost `
    -ResourceGroupName $ResourceGroupName `
    -HostPoolName $HostPoolName

foreach ($host in $sessionHosts) {
    $hostName = $host.Name.Split("/")[1]
    $vmName = $hostName.Split(".")[0]

    # Step 1: Enable drain mode
    Update-AzWvdSessionHost `
        -ResourceGroupName $ResourceGroupName `
        -HostPoolName $HostPoolName `
        -Name $hostName `
        -AllowNewSession:$false

    Write-Output "Drain mode ON: $hostName"
}

# Step 2: Wait for sessions to drain
Write-Output "Waiting $DrainWaitMinutes minutes for sessions to clear..."
Start-Sleep -Seconds ($DrainWaitMinutes * 60)

# Step 3: Force logoff remaining sessions + deallocate
foreach ($host in $sessionHosts) {
    $hostName = $host.Name.Split("/")[1]
    $vmName = $hostName.Split(".")[0]

    # Force logoff any remaining sessions
    $sessions = Get-AzWvdUserSession `
        -ResourceGroupName $ResourceGroupName `
        -HostPoolName $HostPoolName `
        -SessionHostName $hostName

    foreach ($session in $sessions) {
        $sessionId = $session.Name.Split("/")[2]
        Remove-AzWvdUserSession `
            -ResourceGroupName $ResourceGroupName `
            -HostPoolName $HostPoolName `
            -SessionHostName $hostName `
            -Id $sessionId `
            -Force
        Write-Output "Logged off session: $sessionId on $hostName"
    }

    # Step 4: DEALLOCATE (not stop)
    Stop-AzVM -ResourceGroupName $ResourceGroupName `
        -Name $vmName `
        -Force
    Write-Output "DEALLOCATED: $vmName"
}

Write-Output "Weekend scale-down complete. All hosts deallocated."