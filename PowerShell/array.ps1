# Real scenario: Get all non-compliant devices from Intune
$nonCompliantDevices = @()

$devices = Get-MgDeviceManagementManagedDevice -Filter "complianceState eq 'compliant'"

foreach ($device in $devices) {
    $nonCompliantDevices += [PSCustomObject]@{
        DeviceName = $device.DeviceName
        UserEmail  = $device.UserPrincipalName
        OS         = $device.OperatingSystem
        LastSync   = $device.LastSyncDateTime
    }
}

$nonCompliantDevices 