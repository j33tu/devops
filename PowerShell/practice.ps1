# 1. Get the list of all devices from SCCM (or a text file)

$AllSccmDevices = Get-MgDeviceManagementManagedDevice 

# 2. Start the loop
$Report = foreach ($sccmDevice in $AllSccmDevices) {
    
    # We find the matching Intune device for the current SCCM device in the loop
    $intuneDevice = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$($sccmDevice.deviceName)'"

    # 3. This is your [PSCustomObject] logic, now running for every device
    [PSCustomObject]@{
        ComputerName    = $sccmDevice.deviceName
        LastSCCMSync    = $sccmDevice.LastSyncDateTime
        IntuneCompliant = if ($intuneDevice) { $intuneDevice.ComplianceState } else { "Not Enrolled" }
        PrimaryUser     = $sccmDevice.UserDisplayName
        OSVersion       = $sccmDevice.OSVersion
        OperatingSystem = $sccmDevice.OperatingSystem
    }
}

# 4. Now $Report contains EVERY device. Export it all at once.
$Report | Export-Csv -Path ".\FullDeviceReport.csv" -NoTypeInformation