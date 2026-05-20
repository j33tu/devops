$rgParams = @{
    Name     = "rg-image-factory-lookup"
    Location = "EastUS"
    Tag      = @{
        Environment = "Production"
        ManagedBy   = "GitLab-CI"
        Project     = "GoldenImage"
    }
}
New-AzResourceGroup -name $rgparams['name'] -location $rgparams['location'] -Tag $rgparams['tag'] -Verbose



# Define the registry path for ODBC 18 Driver Settings
$registryPath = "HKLM:\SOFTWARE\Microsoft\Microsoft ODBC Driver 19 for SQL Server"
$name = "TrustServerCertificate"
$value = "Yes"

# 1. Check if the path exists, if not, create it
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    Write-Host "Created Registry Path: $registryPath" -ForegroundColor Cyan
}

# 2. Create/Set the TrustServerCertificate value to 'Yes'
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null

Write-Host "Success: ODBC 18 is now configured to Trust Server Certificates." -ForegroundColor Green
Write-Host "Please restart your SCCM Setup to apply changes." -ForegroundColor Yellow