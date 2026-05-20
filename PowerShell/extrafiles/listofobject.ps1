$nonCompliantDevices = [System.Collections.generic.list[object]]::new()

$devices = Get-MgDeviceManagementManagedDevice -Filter "complianceState eq 'compliant'"

foreach ($device in $devices) {
    $nonCompliantDevices.add( [PSCustomObject]@{
            DeviceName = $device.DeviceName
            UserEmail  = $device.UserPrincipalName
            OS         = $device.OperatingSystem
            LastSync   = $device.LastSyncDateTime
        })
}

$nonCompliantDevices