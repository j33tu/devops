# Auth to ms graph
$scope = "devicemanagementconfiguration.read.all"
connect-mggraph -scope $scope
try {
    write-host "fetching list of non compliance devices from ms graph (intune)" -ForegroundColor Yellow
    $noncompliancedevice = Get-MgDeviceManagementManagedDevice -All | select-object devicename, compliancestate | Where-Object { $_.ComplianceState -eq "noncompliant" } -ErrorAction Stop
    if ($noncompliancedevice.count -gt 0) {
        write-host "there are $($noncompliancedevice.count) non compliant devices in intune" -ForegroundColor Red
    }
    else {
        Write-Host ("there are non compliance devices within limits of intune") -ForegroundColor Green
    }
    $noncompliancedevice | Format-Table -AutoSize
}
catch {
    write-host "an error occurred while fetching the list of non compliant devices from ms graph (intune)" -ForegroundColor Red
}
finally {
    Write-host "Script executed completly " <#Do this after the try block regardless of whether an exception occurred or not#>
    
}