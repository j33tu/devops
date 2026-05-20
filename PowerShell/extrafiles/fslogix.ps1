# Define the storage path
$storageAccountName = "g2sibackupsa"
$shareName = "fslogix"
$vhdPath = "\\$($storageAccountName).file.core.windows.net\$($shareName)"

# Define the Registry Path
$regPath = "HKLM\SOFTWARE\FSLogix\Profiles"

# Create the key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set the VHDLocations value
Set-ItemProperty -Path $regPath -Name "VHDLocations" -Value $vhdPath

# Verify the setting
Get-ItemProperty -Path $regPath -Name "VHDLocations"