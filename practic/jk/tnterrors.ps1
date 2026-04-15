try {
    # If this file is missing, it prints red text but keeps going.
    # The 'catch' block is ignored!
    Get-Item "C:\Data\codes\devops\missing.txt"  
    Write-Host "I will still run even if the file is missing!" -ForegroundColor Cyan
}
catch {
    Write-Host "I am never reached." -ForegroundColor RED
}