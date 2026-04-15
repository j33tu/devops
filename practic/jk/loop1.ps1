
$servers = import-Csv C:\Data\codes\devops\ServerInventory.csv
$servers | foreach-object {
    write-host "$($_.ServerName)" and ip is "$($_.ipaddress)"
}

write-host "---------------------------------"
write-host "script block 2" -ForegroundColor green
foreach ($server in $servers) {
    Write-Host "$($server.ServerName) and ip is $($server.ipaddress)"
}






