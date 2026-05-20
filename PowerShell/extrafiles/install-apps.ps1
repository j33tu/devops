# 02-install-chrome.ps1
# Downloads and silently installs the latest Google Chrome Enterprise MSI.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==> [02] Installing Google Chrome" -ForegroundColor Cyan

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ChromeUrl      = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
$InstallerPath  = "$env:TEMP\chrome_enterprise.msi"
$LogPath        = "$env:TEMP\chrome_install.log"

# ── Download ──────────────────────────────────────────────────────
Write-Host "  -> Downloading Chrome Enterprise MSI..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($ChromeUrl, $InstallerPath)

if (-not (Test-Path $InstallerPath)) {
    throw "Download failed: installer not found at $InstallerPath"
}

# ── Silent Install ────────────────────────────────────────────────
Write-Host "  -> Running silent install..."
$args = @(
    "/i", $InstallerPath,
    "/quiet",
    "/norestart",
    "/l*v", $LogPath
)
$proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $args -Wait -PassThru

if ($proc.ExitCode -notin @(0, 3010)) {
    throw "Chrome install failed. Exit code: $($proc.ExitCode). Check log: $LogPath"
}

# ── Verify installation ───────────────────────────────────────────
$chromePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
if (Test-Path $chromePath) {
    $version = (Get-Item $chromePath).VersionInfo.FileVersion
    Write-Host "  -> Chrome installed: $version" -ForegroundColor Green
} else {
    throw "Chrome executable not found after install."
}

# ── Disable auto-update tasks (optional for golden image) ─────────
Write-Host "  -> Disabling Chrome auto-update scheduled tasks..."
Get-ScheduledTask -TaskName "GoogleUpdate*" -ErrorAction SilentlyContinue |
  Disable-ScheduledTask -ErrorAction SilentlyContinue

# ── Cleanup ───────────────────────────────────────────────────────
Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue

Write-Host "==> [02] Google Chrome installation complete." -ForegroundColor Green




# 03-install-zoom.ps1
# Downloads and silently installs the latest Zoom client.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "==> [03] Installing Zoom" -ForegroundColor Cyan

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ZoomUrl = "https://zoom.us/client/latest/ZoomInstallerFull.msi"
$InstallerPath = "$env:TEMP\ZoomInstaller.msi"
$LogPath = "$env:TEMP\zoom_install.log"

# ── Download ──────────────────────────────────────────────────────
Write-Host "  -> Downloading Zoom MSI..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($ZoomUrl, $InstallerPath)

if (-not (Test-Path $InstallerPath)) {
    throw "Download failed: installer not found at $InstallerPath"
}

# ── Silent Install ────────────────────────────────────────────────
Write-Host "  -> Running silent install..."
$msiArgs = @(
    "/i", $InstallerPath,
    "/quiet",
    "/norestart",
    "ZoomAutoUpdate=0",       # Disable auto-update for golden image
    "NOGOOGLEANALYTICS=1",    # Disable analytics
    "/l*v", $LogPath
)
$proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru

if ($proc.ExitCode -notin @(0, 3010)) {
    throw "Zoom install failed. Exit code: $($proc.ExitCode). Check log: $LogPath"
}

# ── Verify installation ───────────────────────────────────────────
$zoomPath = "${env:ProgramFiles(x86)}\Zoom\bin\Zoom.exe"
$zoomPath64 = "${env:ProgramFiles}\Zoom\bin\Zoom.exe"
$installed = (Test-Path $zoomPath) -or (Test-Path $zoomPath64)

if ($installed) {
    Write-Host "  -> Zoom installed successfully." -ForegroundColor Green
}
else {
    Write-Warning "Zoom executable not found at expected paths; verify manually."
}

# ── Disable Zoom auto-start ───────────────────────────────────────
Write-Host "  -> Disabling Zoom startup entries..."
$regPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($path in $regPaths) {
    if (Get-ItemProperty -Path $path -Name "Zoom" -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $path -Name "Zoom" -Force -ErrorAction SilentlyContinue
    }
}

# ── Cleanup ───────────────────────────────────────────────────────
Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue

Write-Host "==> [03] Zoom installation complete." -ForegroundColor Green


