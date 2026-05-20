
try {
    Get-ChildItem C:\FakeFolder -erroraction stop
    Write-Host "This line still runs"

}
catch {
    write-host "error accured"
}