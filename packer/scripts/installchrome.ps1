Write-Host "Installing Google Chrome..."

$chromeUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
$output = "$env:TEMP\chrome.exe"

Invoke-WebRequest -Uri $chromeUrl -OutFile $output
Start-Process -FilePath $output -ArgumentList "/silent /install" -Wait

Write-Host "Chrome installed successfully"