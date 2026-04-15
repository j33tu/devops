# 1. Install the specific submodule for Intune Apps
Install-Module Microsoft.Graph.Devices.CorporateManagement -Scope CurrentUser -Force

# 2. Import it into your current session
Import-Module Microsoft.Graph.Devices.CorporateManagement

# 3. Verify the command now exists (should return a definition)
Get-Command New-MgDeviceAppManagementMobileApp