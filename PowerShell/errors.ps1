
Write-Host "checking non terminating errors ." -ForegroundColor green
try {
    # This generates a NON-terminating error
    Get-Item "C:\NonExistentFile.txt"  -ErrorAction Stop
    Write-Host "I will still run! will not go to catch block " -ForegroundColor Green
}
catch {
    Write-Host "non temrinating moved to catch ." -ForegroundColor Red
}

Write-Host "checking terminating errors ." -ForegroundColor Cyan

try {
    # This generates a -terminating error
    $r = 1 / 0
    Write-Host "I will still run!$r " -ForegroundColor Green
}
catch {
    Write-Host "moved to catch block." -ForegroundColor Yellow
}