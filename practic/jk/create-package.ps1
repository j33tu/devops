# --- 1. CONFIGURATION & PATHS ---
$Config = @{
    WorkDir      = "C:\IntuneTemp"
    PackageDir   = "C:\IntuneTemp\Source"
    OutputDir    = "C:\IntuneTemp\Output"
    ToolPath     = "C:\IntuneTemp\IntuneWinAppUtil.exe"
    # Updated reliable Enterprise URL
    ChromeUrl    = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
    AppName      = "Google Chrome Enterprise (Automated)"
    AppPublisher = "Google"
}

# --- PRE-FLIGHT CHECK ---
if (!(Test-Path $Config.ToolPath)) {
    Write-Error "CRITICAL: IntuneWinAppUtil.exe not found at $($Config.ToolPath). Please download it from GitHub and place it there."
    return
}

# Ensure Directories Exist
foreach ($Path in @($Config.PackageDir, $Config.OutputDir)) {
    if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
}

# --- 2. DOWNLOAD & PACKAGE ---
Write-Host "[*] Downloading Chrome MSI..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $Config.ChromeUrl -OutFile "$($Config.PackageDir)\GoogleChrome.msi" -ErrorAction Stop
    Write-Host "[+] Download Complete." -ForegroundColor Green
}
catch {
    Write-Error "Download failed: $($_.Exception.Message)"
    return
}

Write-Host "[*] Packaging into .intunewin..." -ForegroundColor Cyan
& $Config.ToolPath -c $Config.PackageDir -s "GoogleChrome.msi" -o $Config.OutputDir -q