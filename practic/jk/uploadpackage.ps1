# 1. Install the module if you don't have it
# Install-Module Microsoft.Graph -Scope CurrentUser

# 2. Connect to your Tenant
Connect-MgGraph -Scopes "DeviceManagementApps.ReadWrite.All"

# 3. Define the Win32 App Metadata
$AppParams = @{
    "@odata.type"                   = "#microsoft.graph.win32LobApp"
    displayName                     = "Google Chrome Enterprise"
    publisher                       = "Google"
    description                     = "Automated Google Chrome Deployment"
    fileName                        = "GoogleChrome.msi"
    setupFilePath                   = "GoogleChrome.msi"
    installCommandLine              = "msiexec /i `"GoogleChrome.msi`" /quiet /norestart"
    uninstallCommandLine            = "msiexec /x {8A69D345-D564-463C-AFF1-A69D9E530F96} /quiet /norestart"
    applicableArchitectures         = "x64"
    minimumSupportedOperatingSystem = @{
        v10_0 = $true
    }
    # Detection Rule: MSI Product Code
    detectionRules                  = @(
        @{
            "@odata.type" = "#microsoft.graph.win32LobAppProductCodeDetection"
            productCode   = "{8A69D345-D564-463C-AFF1-A69D9E530F96}"
        }
    )
}

# 4. Create the App Shell
Write-Host "Creating App entry in Intune..." -ForegroundColor Cyan
$NewApp = New-MgDeviceAppManagementMobileApp -BodyParameter $AppParams

Write-Host "App Created Successfully! ID: $($NewApp.Id)" -ForegroundColor Green